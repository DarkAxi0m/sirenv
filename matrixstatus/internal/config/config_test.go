package config

import (
	"path/filepath"
	"testing"
)

func TestLoadCreatesDefaultConfig(t *testing.T) {
	path := filepath.Join(t.TempDir(), "config.toml")
	store, err := Load(path)
	if err != nil {
		t.Fatal(err)
	}
	if store.Matrix.URL != DefaultURL {
		t.Fatalf("URL = %q", store.Matrix.URL)
	}
	if store.Matrix.UserID != DefaultUserID {
		t.Fatalf("UserID = %q", store.Matrix.UserID)
	}
	if store.Matrix.SSOPort != DefaultPort {
		t.Fatalf("SSOPort = %d", store.Matrix.SSOPort)
	}
}
