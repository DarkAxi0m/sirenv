package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strings"
	"time"

	"matrixstatus/internal/config"
	"matrixstatus/internal/gui"
	"matrixstatus/internal/matrix"
	"matrixstatus/internal/status"
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(args []string) error {
	fs := flag.NewFlagSet("matrixstatus", flag.ContinueOnError)
	fs.SetOutput(os.Stderr)
	configPath := fs.String("config", "", "path to config.toml")
	forceLogin := fs.Bool("login", false, "force Matrix SSO login")
	help := fs.Bool("help", false, "show help")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *help {
		printUsage()
		return nil
	}

	store, err := config.Load(*configPath)
	if err != nil {
		return err
	}
	if *forceLogin {
		if err := matrix.Login(context.Background(), store); err != nil {
			return err
		}
		fmt.Printf("Saved Matrix token for %s to %s\n", store.Matrix.UserID, store.Path)
		return nil
	}

	if fs.NArg() == 0 {
		return gui.Run(store)
	}

	client := matrix.NewClient(store)
	if err := client.EnsureToken(context.Background()); err != nil {
		return err
	}

	name := fs.Arg(0)
	message := strings.Join(fs.Args()[1:], " ")
	preset, err := status.Resolve(store, name, message)
	if err != nil {
		return err
	}
	if err := client.Apply(context.Background(), preset); err != nil {
		return err
	}
	fmt.Printf("Matrix status set: %s\n", preset.Name)

	if preset.Duration > 0 {
		go func() {
			time.Sleep(preset.Duration)
			back, err := status.Resolve(store, "Back", "")
			if err == nil {
				_ = client.Apply(context.Background(), back)
			}
		}()
	}
	return nil
}

func printUsage() {
	fmt.Println("Usage: matrixstatus [--config path] [--login] <status> [status message]")
	fmt.Println("Available statuses:")
	fmt.Println("  - online")
	fmt.Println("  - unavailable")
	fmt.Println("  - offline")
	fmt.Println("")
	fmt.Println("  - Back")
	fmt.Println("  - Away")
	fmt.Println("  - Busy")
	fmt.Println("  - Coffee")
}
