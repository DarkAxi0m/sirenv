package matrix

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os/exec"
	"runtime"
	"strings"
	"time"

	"matrixstatus/internal/config"
	"matrixstatus/internal/status"
)

type Client struct {
	store      *config.Store
	httpClient *http.Client
}

func NewClient(store *config.Store) *Client {
	return &Client{
		store:      store,
		httpClient: &http.Client{Timeout: 15 * time.Second},
	}
}

func (c *Client) EnsureToken(ctx context.Context) error {
	if c.store.Matrix.AccessToken != "" {
		return nil
	}
	fmt.Println("MATRIX_ACCESS_TOKEN is not set; starting Matrix SSO login.")
	return Login(ctx, c.store)
}

func (c *Client) Apply(ctx context.Context, req status.ApplyRequest) error {
	if err := c.SetDisplayName(ctx, req.DisplayName); err != nil {
		return err
	}
	return c.SetPresence(ctx, req.Presence, req.Message)
}

func (c *Client) SetPresence(ctx context.Context, presence string, message string) error {
	payload := map[string]string{
		"presence":   presence,
		"status_msg": message,
	}
	userID := encodeUserID(c.store.Matrix.UserID)
	endpoint := fmt.Sprintf("%s/_matrix/client/v3/presence/%s/status", c.store.Matrix.URL, userID)
	return c.putJSON(ctx, endpoint, payload)
}

func (c *Client) SetDisplayName(ctx context.Context, displayName string) error {
	payload := map[string]string{"displayname": displayName}
	userID := encodeUserID(c.store.Matrix.UserID)
	endpoint := fmt.Sprintf("%s/_matrix/client/v3/profile/%s/displayname", c.store.Matrix.URL, userID)
	return c.putJSON(ctx, endpoint, payload)
}

func (c *Client) putJSON(ctx context.Context, endpoint string, payload any) error {
	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPut, endpoint, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+c.store.Matrix.AccessToken)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		return fmt.Errorf("Matrix API request failed: %s: %s", resp.Status, string(body))
	}
	return nil
}

func openBrowser(rawURL string) error {
	switch runtime.GOOS {
	case "linux":
		return exec.Command("xdg-open", rawURL).Start()
	case "darwin":
		return exec.Command("open", rawURL).Start()
	case "windows":
		return exec.Command("rundll32", "url.dll,FileProtocolHandler", rawURL).Start()
	default:
		return fmt.Errorf("unsupported platform for browser launch: %s", runtime.GOOS)
	}
}

func encodeUserID(userID string) string {
	encoded := url.PathEscape(userID)
	encoded = strings.ReplaceAll(encoded, "@", "%40")
	encoded = strings.ReplaceAll(encoded, ":", "%3A")
	return encoded
}
