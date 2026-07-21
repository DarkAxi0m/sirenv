package matrix

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"matrixstatus/internal/config"
	"matrixstatus/internal/status"
)

func TestApplySendsDisplayAndPresence(t *testing.T) {
	var paths []string
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		paths = append(paths, r.URL.EscapedPath())
		if r.Header.Get("Authorization") != "Bearer token" {
			t.Fatalf("missing auth header")
		}
		var payload map[string]string
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			t.Fatal(err)
		}
		if r.Method != http.MethodPut {
			t.Fatalf("method = %s", r.Method)
		}
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	store := &config.Store{Matrix: config.MatrixConfig{
		URL:         server.URL,
		UserID:      "@chris:matrix.accede.au",
		AccessToken: "token",
	}}
	client := NewClient(store)
	err := client.Apply(context.Background(), status.ApplyRequest{
		Presence:    "unavailable",
		Message:     "Coffee BRB",
		DisplayName: "Chris - ☕ Coffee BRB",
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(paths) != 2 {
		t.Fatalf("requests = %v", paths)
	}
	if paths[0] != "/_matrix/client/v3/profile/%40chris%3Amatrix.accede.au/displayname" {
		t.Fatalf("display path = %s", paths[0])
	}
	if paths[1] != "/_matrix/client/v3/presence/%40chris%3Amatrix.accede.au/status" {
		t.Fatalf("presence path = %s", paths[1])
	}
}
