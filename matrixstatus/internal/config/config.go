package config

import (
	"bufio"
	"errors"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/BurntSushi/toml"
)

const (
	DefaultURL         = "https://matrix.accede.au"
	DefaultUserID      = "@chris:matrix.accede.au"
	DefaultDisplayName = "Chris"
	DefaultPort        = 8765
)

type Store struct {
	Path    string         `toml:"-"`
	Matrix  MatrixConfig   `toml:"matrix"`
	UI      UIConfig       `toml:"ui"`
	Presets []PresetConfig `toml:"presets"`
}

type MatrixConfig struct {
	URL         string `toml:"url"`
	UserID      string `toml:"user_id"`
	DisplayName string `toml:"display_name"`
	AccessToken string `toml:"access_token"`
	DeviceID    string `toml:"device_id"`
	SSOPort     int    `toml:"sso_port"`
}

type UIConfig struct {
	Theme string `toml:"theme"`
}

type PresetConfig struct {
	Name           string `toml:"name"`
	Presence       string `toml:"presence"`
	DefaultMessage string `toml:"default_message"`
	DisplayFormat  string `toml:"display_format"`
	ResetDisplay   bool   `toml:"reset_display"`
	Icon           string `toml:"icon"`
	Accent         string `toml:"accent"`
}

func Load(path string) (*Store, error) {
	if path == "" {
		var err error
		path, err = DefaultPath()
		if err != nil {
			return nil, err
		}
	}

	store := defaults(path)
	if _, err := os.Stat(path); err == nil {
		if _, err := toml.DecodeFile(path, store); err != nil {
			return nil, err
		}
	} else if !errors.Is(err, os.ErrNotExist) {
		return nil, err
	} else {
		importLegacyEnv(store)
		if err := store.Save(); err != nil {
			return nil, err
		}
	}
	normalize(store)
	return store, nil
}

func DefaultPath() (string, error) {
	base, err := os.UserConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(base, "matrixstatus", "config.toml"), nil
}

func (s *Store) Save() error {
	if s.Path == "" {
		path, err := DefaultPath()
		if err != nil {
			return err
		}
		s.Path = path
	}
	if err := os.MkdirAll(filepath.Dir(s.Path), 0o700); err != nil {
		return err
	}
	file, err := os.OpenFile(s.Path, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0o600)
	if err != nil {
		return err
	}
	defer file.Close()
	return toml.NewEncoder(file).Encode(s)
}

func defaults(path string) *Store {
	return &Store{
		Path: path,
		Matrix: MatrixConfig{
			URL:         DefaultURL,
			UserID:      DefaultUserID,
			DisplayName: DefaultDisplayName,
			SSOPort:     DefaultPort,
		},
		UI: UIConfig{Theme: "system"},
	}
}

func normalize(s *Store) {
	s.Matrix.URL = strings.TrimRight(s.Matrix.URL, "/")
	if s.Matrix.URL == "" {
		s.Matrix.URL = DefaultURL
	}
	if s.Matrix.UserID == "" {
		s.Matrix.UserID = DefaultUserID
	}
	if s.Matrix.DisplayName == "" {
		s.Matrix.DisplayName = DefaultDisplayName
	}
	if s.Matrix.SSOPort == 0 {
		s.Matrix.SSOPort = DefaultPort
	}
	if s.UI.Theme == "" {
		s.UI.Theme = "system"
	}
}

func importLegacyEnv(s *Store) {
	envPath := filepath.Join("/home/chris/sirenv", "scripts", ".env")
	values, err := readEnvFile(envPath)
	if err != nil {
		return
	}
	if value := values["MATRIX_URL"]; value != "" {
		s.Matrix.URL = strings.TrimRight(value, "/")
	}
	if value := values["MATRIX_USER_ID"]; value != "" {
		s.Matrix.UserID = value
	}
	if value := values["MATRIX_DISPLAY_NAME"]; value != "" {
		s.Matrix.DisplayName = value
	}
	if value := values["MATRIX_ACCESS_TOKEN"]; value != "" {
		s.Matrix.AccessToken = value
	}
	if value := values["MATRIX_DEVICE_ID"]; value != "" {
		s.Matrix.DeviceID = value
	}
	if value := values["MATRIX_SSO_PORT"]; value != "" {
		if port, err := strconv.Atoi(value); err == nil {
			s.Matrix.SSOPort = port
		}
	}
}

func readEnvFile(path string) (map[string]string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	values := make(map[string]string)
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		key, value, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}
		values[strings.TrimSpace(key)] = strings.Trim(strings.TrimSpace(value), `"'`)
	}
	return values, scanner.Err()
}
