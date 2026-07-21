package matrix

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"net/url"
	"time"

	"matrixstatus/internal/config"
)

type loginResponse struct {
	UserID      string `json:"user_id"`
	DeviceID    string `json:"device_id"`
	AccessToken string `json:"access_token"`
}

func Login(ctx context.Context, store *config.Store) error {
	token, err := receiveLoginToken(ctx, store)
	if err != nil {
		return err
	}
	data, err := exchangeLoginToken(ctx, store, token)
	if err != nil {
		return err
	}
	store.Matrix.UserID = data.UserID
	store.Matrix.DeviceID = data.DeviceID
	store.Matrix.AccessToken = data.AccessToken
	return store.Save()
}

func receiveLoginToken(ctx context.Context, store *config.Store) (string, error) {
	tokenCh := make(chan string, 1)
	errCh := make(chan error, 1)

	mux := http.NewServeMux()
	server := &http.Server{Handler: mux, ReadHeaderTimeout: 5 * time.Second}
	mux.HandleFunc("/callback", func(w http.ResponseWriter, r *http.Request) {
		token := r.URL.Query().Get("loginToken")
		if token == "" {
			http.Error(w, "missing loginToken", http.StatusBadRequest)
			return
		}
		tokenCh <- token
		_, _ = w.Write([]byte("Matrix login token received. You can close this tab.\n"))
	})

	listener, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", store.Matrix.SSOPort))
	if err != nil {
		return "", err
	}
	defer listener.Close()

	go func() {
		if err := server.Serve(listener); err != nil && err != http.ErrServerClosed {
			errCh <- err
		}
	}()
	defer server.Shutdown(context.Background())

	redirect := fmt.Sprintf("http://127.0.0.1:%d/callback", store.Matrix.SSOPort)
	loginURL := store.Matrix.URL + "/_matrix/client/v3/login/sso/redirect?" + url.Values{
		"redirectUrl": {redirect},
		"action":      {"login"},
	}.Encode()

	fmt.Println("Opening browser for Matrix SSO...")
	fmt.Println(loginURL)
	if err := openBrowser(loginURL); err != nil {
		fmt.Printf("Could not open browser automatically: %v\n", err)
	}

	select {
	case token := <-tokenCh:
		return token, nil
	case err := <-errCh:
		return "", err
	case <-ctx.Done():
		return "", ctx.Err()
	case <-time.After(5 * time.Minute):
		return "", fmt.Errorf("timed out waiting for Matrix SSO login")
	}
}

func exchangeLoginToken(ctx context.Context, store *config.Store, token string) (loginResponse, error) {
	payload := map[string]string{
		"type":                        "m.login.token",
		"token":                       token,
		"initial_device_display_name": "matrixstatus",
	}
	body, err := json.Marshal(payload)
	if err != nil {
		return loginResponse{}, err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, store.Matrix.URL+"/_matrix/client/v3/login", bytes.NewReader(body))
	if err != nil {
		return loginResponse{}, err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 15 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return loginResponse{}, err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return loginResponse{}, fmt.Errorf("Matrix SSO token exchange failed: %s", resp.Status)
	}

	var data loginResponse
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return loginResponse{}, err
	}
	if data.AccessToken == "" || data.UserID == "" {
		return loginResponse{}, fmt.Errorf("Matrix SSO response did not include token and user ID")
	}
	return data, nil
}
