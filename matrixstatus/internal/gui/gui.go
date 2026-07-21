package gui

import (
	"context"
	_ "embed"
	"fmt"
	"strconv"
	"strings"
	"sync"
	"time"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/driver/desktop"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"

	"matrixstatus/internal/config"
	"matrixstatus/internal/matrix"
	"matrixstatus/internal/status"
)

//go:embed matrixstatus.png
var appIconData []byte

var appIcon = fyne.NewStaticResource("matrixstatus.png", appIconData)

func Run(store *config.Store) error {
	a := app.NewWithID("au.accede.matrixstatus")
	a.SetIcon(appIcon)
	switch strings.ToLower(store.UI.Theme) {
	case "dark":
		a.Settings().SetTheme(theme.DarkTheme())
	case "light":
		a.Settings().SetTheme(theme.LightTheme())
	}

	w := a.NewWindow("Matrix Status")
	w.Resize(fyne.NewSize(860, 520))

	client := matrix.NewClient(store)
	state := &uiState{app: a, store: store, client: client, window: w}
	state.build()
	state.setupTray()

	w.ShowAndRun()
	return nil
}

type uiState struct {
	app         fyne.App
	store       *config.Store
	client      *matrix.Client
	window      fyne.Window
	presets     []status.Preset
	selected    int
	list        *widget.List
	message     *widget.Entry
	duration    *widget.Entry
	title       *widget.Label
	subtitle    *widget.Label
	result      *widget.Label
	applyButton *widget.Button
	restoreMu   sync.Mutex
	restoreStop context.CancelFunc
}

func (s *uiState) build() {
	s.presets = status.AllPresets(s.store)
	s.selected = 0

	s.title = widget.NewLabelWithStyle("", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})
	s.subtitle = widget.NewLabel("")
	s.result = widget.NewLabel("Ready")
	s.message = widget.NewEntry()
	s.message.SetPlaceHolder("Optional status message, such as in a meeting")
	s.duration = widget.NewEntry()
	s.duration.SetPlaceHolder("Minutes, such as 30")

	s.list = widget.NewList(
		func() int { return len(s.presets) },
		func() fyne.CanvasObject {
			return newPresetRow(func(id widget.ListItemID) {
				s.list.Select(id)
			}, s.applyPreset)
		},
		func(id widget.ListItemID, obj fyne.CanvasObject) {
			preset := s.presets[id]
			row := obj.(*presetRow)
			row.setPreset(id, preset)
		},
	)
	s.list.OnSelected = func(id widget.ListItemID) {
		s.selectPreset(id)
	}
	s.list.Select(0)

	s.applyButton = widget.NewButtonWithIcon("Apply", theme.ConfirmIcon(), s.applySelected)
	tempButton := widget.NewButtonWithIcon("Temporary", theme.HistoryIcon(), s.applyTemporary)
	addButton := widget.NewButtonWithIcon("Add", theme.ContentAddIcon(), s.addPreset)
	editButton := widget.NewButtonWithIcon("Edit", theme.DocumentCreateIcon(), s.editPreset)
	deleteButton := widget.NewButtonWithIcon("Delete", theme.DeleteIcon(), s.deletePreset)
	loginButton := widget.NewButtonWithIcon("Login", theme.LoginIcon(), s.forceLogin)

	actions := container.NewHBox(s.applyButton, tempButton, addButton, editButton, deleteButton, loginButton)
	form := container.NewVBox(
		s.title,
		s.subtitle,
		widget.NewSeparator(),
		widget.NewLabel("Message"),
		hintedControl(s.message, "Overrides the preset message for this apply only."),
		widget.NewLabel("Temporary duration"),
		hintedControl(s.duration, "Use with Temporary to automatically restore Back after this many minutes."),
		actions,
		widget.NewSeparator(),
		s.result,
	)
	content := container.NewHSplit(container.NewPadded(s.list), container.NewPadded(form))
	content.Offset = 0.34
	s.window.SetContent(content)
	s.syncSelected()
}

func (s *uiState) syncSelected() {
	if len(s.presets) == 0 || s.selected >= len(s.presets) {
		return
	}
	preset := s.presets[s.selected]
	s.title.SetText(fmt.Sprintf("%s  %s", iconFor(preset), preset.Name))
	detail := preset.Presence
	if preset.DefaultMessage != "" {
		detail += " · " + preset.DefaultMessage
	}
	s.subtitle.SetText(detail)
	s.message.SetText(preset.DefaultMessage)
}

func (s *uiState) selectPreset(id widget.ListItemID) {
	s.selected = id
	s.syncSelected()
}

func (s *uiState) applyPreset(id widget.ListItemID) {
	s.selectPreset(id)
	s.list.Select(id)
	s.applySelected()
}

func (s *uiState) applySelected() {
	s.setBusy("Applying...")
	go func() {
		err := s.applyCurrent(0)
		s.finish(err, "Status applied")
	}()
}

func (s *uiState) applyTemporary() {
	minutes, err := strconv.Atoi(strings.TrimSpace(s.duration.Text))
	if err != nil || minutes <= 0 {
		dialog.ShowError(fmt.Errorf("enter a temporary duration in minutes"), s.window)
		return
	}
	s.setBusy("Applying temporary status...")
	go func() {
		err := s.applyCurrent(time.Duration(minutes) * time.Minute)
		if err != nil {
			s.finish(err, "")
			return
		}
		s.finish(nil, fmt.Sprintf("Temporary status applied; Back will be restored in %d minutes", minutes))
		s.scheduleRestore(time.Duration(minutes) * time.Minute)
	}()
}

func (s *uiState) applyCurrent(duration time.Duration) error {
	if err := s.client.EnsureToken(context.Background()); err != nil {
		return err
	}
	preset := s.presets[s.selected]
	req, err := status.Resolve(s.store, preset.Name, s.message.Text)
	if err != nil {
		return err
	}
	req.Duration = duration
	return s.client.Apply(context.Background(), req)
}

func (s *uiState) addPreset() {
	s.showPresetDialog(status.Preset{Name: "New Status", Presence: "unavailable", DisplayFormat: "%s - 🟡 %s", Icon: "●", Accent: "yellow"}, -1)
}

func (s *uiState) editPreset() {
	preset := s.presets[s.selected]
	if preset.BuiltIn {
		dialog.ShowInformation("Built-in status", "Built-in statuses cannot be edited. Add a custom preset instead.", s.window)
		return
	}
	s.showPresetDialog(preset, s.customIndex(preset.Name))
}

func (s *uiState) deletePreset() {
	preset := s.presets[s.selected]
	if preset.BuiltIn {
		dialog.ShowInformation("Built-in status", "Built-in statuses cannot be deleted.", s.window)
		return
	}
	index := s.customIndex(preset.Name)
	if index < 0 {
		return
	}
	dialog.ShowConfirm("Delete preset", "Delete "+preset.Name+"?", func(ok bool) {
		if !ok {
			return
		}
		s.store.Presets = append(s.store.Presets[:index], s.store.Presets[index+1:]...)
		if err := s.store.Save(); err != nil {
			dialog.ShowError(err, s.window)
			return
		}
		s.refresh()
	}, s.window)
}

func (s *uiState) forceLogin() {
	s.setBusy("Starting SSO login...")
	go func() {
		err := matrix.Login(context.Background(), s.store)
		s.finish(err, "Login saved")
	}()
}

func (s *uiState) setupTray() {
	desk, ok := s.app.(desktop.App)
	if !ok {
		return
	}

	show := fyne.NewMenuItem("Show Matrix Status", func() {
		s.window.Show()
		s.window.RequestFocus()
	})
	show.Icon = theme.VisibilityIcon()
	hide := fyne.NewMenuItem("Hide to Tray", func() {
		s.window.Hide()
	})
	hide.Icon = theme.VisibilityOffIcon()
	back := fyne.NewMenuItem("Apply Back", func() {
		s.setBusy("Applying Back...")
		go func() {
			if err := s.client.EnsureToken(context.Background()); err != nil {
				s.finish(err, "")
				return
			}
			preset, err := status.Resolve(s.store, "Back", "")
			if err == nil {
				s.cancelRestore()
				err = s.client.Apply(context.Background(), preset)
			}
			s.finish(err, "Back applied")
		}()
	})
	back.Icon = theme.ConfirmIcon()
	quit := fyne.NewMenuItem("Quit", func() {
		s.cancelRestore()
		s.app.Quit()
	})
	quit.Icon = theme.CancelIcon()

	desk.SetSystemTrayMenu(fyne.NewMenu("Matrix Status", show, hide, fyne.NewMenuItemSeparator(), back, fyne.NewMenuItemSeparator(), quit))
	desk.SetSystemTrayWindow(s.window)
}

func (s *uiState) scheduleRestore(delay time.Duration) {
	s.cancelRestore()
	ctx, cancel := context.WithCancel(context.Background())
	s.restoreMu.Lock()
	s.restoreStop = cancel
	s.restoreMu.Unlock()

	go func() {
		timer := time.NewTimer(delay)
		defer timer.Stop()

		select {
		case <-timer.C:
		case <-ctx.Done():
			return
		}

		back, err := status.Resolve(s.store, "Back", "")
		if err == nil {
			err = s.client.Apply(context.Background(), back)
		}
		if err != nil {
			s.finish(err, "")
			return
		}
		s.finish(nil, "Temporary status expired; restored Back")
		s.app.SendNotification(&fyne.Notification{
			Title:   "Matrix Status",
			Content: "Temporary status expired; restored Back",
		})
	}()
}

func (s *uiState) cancelRestore() {
	s.restoreMu.Lock()
	defer s.restoreMu.Unlock()
	if s.restoreStop == nil {
		return
	}
	s.restoreStop()
	s.restoreStop = nil
}

func (s *uiState) showPresetDialog(preset status.Preset, index int) {
	name := widget.NewEntry()
	name.SetText(preset.Name)
	name.SetPlaceHolder("Lunch, Focus, On call")
	presence := widget.NewSelect([]string{"online", "unavailable", "offline"}, nil)
	presence.SetSelected(preset.Presence)
	message := widget.NewEntry()
	message.SetText(preset.DefaultMessage)
	message.SetPlaceHolder("Shown as your Matrix status message")
	format := widget.NewEntry()
	format.SetText(preset.DisplayFormat)
	format.SetPlaceHolder("%s - status text")
	icon := widget.NewEntry()
	icon.SetText(preset.Icon)
	icon.SetPlaceHolder("Short icon or symbol for the sidebar")
	reset := widget.NewCheck("Reset display name", nil)
	reset.SetChecked(preset.ResetDisplay)

	items := []*widget.FormItem{
		hintedFormItem("Name", name, "The label shown in the sidebar and accepted by the CLI."),
		hintedFormItem("Presence", presence, "Matrix presence value to send: online, unavailable, or offline."),
		hintedFormItem("Default message", message, "Used when you apply this preset without typing a custom message."),
		hintedFormItem("Display format", format, "Optional display name format. Use %s for your name and %s for the message."),
		hintedFormItem("Icon", icon, "A short marker shown next to the preset in the sidebar."),
		hintedFormItem("", reset, "When checked, applying this preset restores your configured Matrix display name."),
	}
	form := widget.NewForm(items...)
	formContent := container.NewVScroll(form)
	formContent.SetMinSize(fyne.NewSize(640, 420))
	presetDialog := dialog.NewCustomConfirm("Status preset", "Save", "Cancel", formContent, func(ok bool) {
		if !ok {
			return
		}
		if strings.TrimSpace(name.Text) == "" {
			dialog.ShowError(fmt.Errorf("preset name is required"), s.window)
			return
		}
		next := config.PresetConfig{
			Name:           strings.TrimSpace(name.Text),
			Presence:       presence.Selected,
			DefaultMessage: message.Text,
			DisplayFormat:  format.Text,
			ResetDisplay:   reset.Checked,
			Icon:           icon.Text,
			Accent:         preset.Accent,
		}
		if next.Presence == "" {
			next.Presence = "unavailable"
		}
		if index >= 0 {
			s.store.Presets[index] = next
		} else {
			s.store.Presets = append(s.store.Presets, next)
		}
		if err := s.store.Save(); err != nil {
			dialog.ShowError(err, s.window)
			return
		}
		s.refresh()
	}, s.window)
	presetDialog.Resize(fyne.NewSize(700, 520))
	presetDialog.Show()
}

func (s *uiState) customIndex(name string) int {
	for i, preset := range s.store.Presets {
		if preset.Name == name {
			return i
		}
	}
	return -1
}

func (s *uiState) refresh() {
	s.presets = status.AllPresets(s.store)
	s.list.Refresh()
	if s.selected >= len(s.presets) {
		s.selected = len(s.presets) - 1
	}
	s.list.Select(s.selected)
	s.syncSelected()
}

func (s *uiState) setBusy(message string) {
	fyne.Do(func() {
		s.result.SetText(message)
		s.applyButton.Disable()
	})
}

func (s *uiState) finish(err error, message string) {
	fyne.Do(func() {
		if err != nil {
			s.result.SetText("Error: " + err.Error())
			dialog.ShowError(err, s.window)
		} else {
			s.result.SetText(message)
		}
		s.applyButton.Enable()
	})
}

func hintedControl(control fyne.CanvasObject, hint string) fyne.CanvasObject {
	label := widget.NewLabel(hint)
	label.Wrapping = fyne.TextWrapWord
	return container.NewVBox(control, label)
}

func hintedFormItem(label string, control fyne.CanvasObject, hint string) *widget.FormItem {
	return widget.NewFormItem(label, hintedControl(control, hint))
}

type presetRow struct {
	widget.BaseWidget

	id       widget.ListItemID
	selectID func(widget.ListItemID)
	applyID  func(widget.ListItemID)
	icon     *widget.Label
	name     *widget.Label
	detail   *widget.Label
	content  fyne.CanvasObject
}

func newPresetRow(selectID func(widget.ListItemID), applyID func(widget.ListItemID)) *presetRow {
	row := &presetRow{
		selectID: selectID,
		applyID:  applyID,
		icon:     widget.NewLabelWithStyle("●", fyne.TextAlignCenter, fyne.TextStyle{Bold: true}),
		name:     widget.NewLabelWithStyle("Status", fyne.TextAlignLeading, fyne.TextStyle{Bold: true}),
		detail:   widget.NewLabel("presence"),
	}
	row.content = container.NewBorder(nil, nil, row.icon, nil, container.NewVBox(row.name, row.detail))
	row.ExtendBaseWidget(row)
	return row
}

func (r *presetRow) CreateRenderer() fyne.WidgetRenderer {
	return widget.NewSimpleRenderer(r.content)
}

func (r *presetRow) Tapped(*fyne.PointEvent) {
	if r.selectID != nil {
		r.selectID(r.id)
	}
}

func (r *presetRow) DoubleTapped(*fyne.PointEvent) {
	if r.applyID != nil {
		r.applyID(r.id)
	}
}

func (r *presetRow) setPreset(id widget.ListItemID, preset status.Preset) {
	r.id = id
	r.icon.SetText(iconFor(preset))
	r.name.SetText(preset.Name)
	r.detail.SetText(preset.Presence)
}

func iconFor(preset status.Preset) string {
	if preset.Icon != "" {
		return preset.Icon
	}
	switch preset.Accent {
	case "green":
		return "✓"
	case "red":
		return "●"
	case "coffee":
		return "☕"
	default:
		return "●"
	}
}
