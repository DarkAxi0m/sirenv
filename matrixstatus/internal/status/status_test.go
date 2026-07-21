package status

import (
	"testing"

	"matrixstatus/internal/config"
)

func TestResolveBuiltIns(t *testing.T) {
	cfg := &config.Store{Matrix: config.MatrixConfig{DisplayName: "Chris"}}
	tests := []struct {
		name        string
		message     string
		presence    string
		statusMsg   string
		displayName string
	}{
		{"Back", "", "online", "", "Chris"},
		{"Away", "", "unavailable", "Away", "Chris - 🟡 Away"},
		{"Busy", "", "unavailable", "Busy", "Chris - 🔴 Busy"},
		{"Coffee", "", "unavailable", "Coffee BRB", "Chris - ☕ Coffee BRB"},
		{"online", "here", "online", "here", "Chris"},
		{"unavailable", "", "unavailable", "", "Chris - 🟡 Away"},
		{"offline", "", "offline", "", "Chris - ⚫ Offline"},
	}

	for _, tt := range tests {
		got, err := Resolve(cfg, tt.name, tt.message)
		if err != nil {
			t.Fatalf("Resolve(%q): %v", tt.name, err)
		}
		if got.Presence != tt.presence || got.Message != tt.statusMsg || got.DisplayName != tt.displayName {
			t.Fatalf("Resolve(%q) = %#v", tt.name, got)
		}
	}
}

func TestUnknownStatus(t *testing.T) {
	_, err := Resolve(&config.Store{}, "Nope", "")
	if err == nil {
		t.Fatal("expected error")
	}
}
