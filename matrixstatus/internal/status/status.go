package status

import (
	"fmt"
	"strings"
	"time"

	"matrixstatus/internal/config"
)

type ApplyRequest struct {
	Name        string
	Presence    string
	Message     string
	DisplayName string
	Duration    time.Duration
}

type Preset struct {
	Name           string
	Presence       string
	DefaultMessage string
	DisplayFormat  string
	ResetDisplay   bool
	Icon           string
	Accent         string
	BuiltIn        bool
}

func BuiltIns() []Preset {
	return []Preset{
		{Name: "Back", Presence: "online", ResetDisplay: true, Icon: "✓", Accent: "green", BuiltIn: true},
		{Name: "Away", Presence: "unavailable", DefaultMessage: "Away", DisplayFormat: "%s - 🟡 %s", Icon: "●", Accent: "yellow", BuiltIn: true},
		{Name: "Busy", Presence: "unavailable", DefaultMessage: "Busy", DisplayFormat: "%s - 🔴 %s", Icon: "●", Accent: "red", BuiltIn: true},
		{Name: "Coffee", Presence: "unavailable", DefaultMessage: "Coffee BRB", DisplayFormat: "%s - ☕ %s", Icon: "☕", Accent: "coffee", BuiltIn: true},
		{Name: "online", Presence: "online", ResetDisplay: true, Icon: "✓", Accent: "green", BuiltIn: true},
		{Name: "unavailable", Presence: "unavailable", DefaultMessage: "", DisplayFormat: "%s - 🟡 %s", Icon: "●", Accent: "yellow", BuiltIn: true},
		{Name: "offline", Presence: "offline", DefaultMessage: "", DisplayFormat: "%s - ⚫ %s", Icon: "●", Accent: "grey", BuiltIn: true},
	}
}

func AllPresets(cfg *config.Store) []Preset {
	presets := BuiltIns()
	for _, custom := range cfg.Presets {
		presets = append(presets, Preset{
			Name:           custom.Name,
			Presence:       custom.Presence,
			DefaultMessage: custom.DefaultMessage,
			DisplayFormat:  custom.DisplayFormat,
			ResetDisplay:   custom.ResetDisplay,
			Icon:           custom.Icon,
			Accent:         custom.Accent,
		})
	}
	return presets
}

func Resolve(cfg *config.Store, name string, message string) (ApplyRequest, error) {
	preset, ok := Find(cfg, name)
	if !ok {
		return ApplyRequest{}, fmt.Errorf("unknown Matrix presence: %s\nUse one of: %s", name, strings.Join(Names(cfg), ", "))
	}

	msg := message
	if msg == "" {
		msg = preset.DefaultMessage
	}

	displayName := cfg.Matrix.DisplayName
	if displayName == "" {
		displayName = config.DefaultDisplayName
	}

	switch preset.Name {
	case "unavailable":
		displayMessage := msg
		if displayMessage == "" {
			displayMessage = "Away"
		}
		displayName = fmt.Sprintf(preset.DisplayFormat, displayName, displayMessage)
	case "offline":
		displayMessage := msg
		if displayMessage == "" {
			displayMessage = "Offline"
		}
		displayName = fmt.Sprintf(preset.DisplayFormat, displayName, displayMessage)
	default:
		if !preset.ResetDisplay && preset.DisplayFormat != "" {
			displayName = fmt.Sprintf(preset.DisplayFormat, displayName, msg)
		}
	}

	return ApplyRequest{
		Name:        preset.Name,
		Presence:    preset.Presence,
		Message:     msg,
		DisplayName: displayName,
	}, nil
}

func Find(cfg *config.Store, name string) (Preset, bool) {
	for _, preset := range AllPresets(cfg) {
		if preset.Name == name {
			return preset, true
		}
	}
	return Preset{}, false
}

func Names(cfg *config.Store) []string {
	presets := AllPresets(cfg)
	names := make([]string, 0, len(presets))
	for _, preset := range presets {
		names = append(names, preset.Name)
	}
	return names
}
