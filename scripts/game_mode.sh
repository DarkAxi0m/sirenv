#!/usr/bin/env bash
set -e

echo "== Game mode: stopping background services =="

# System services
for svc in fwupd packagekit pop-upgrade; do
  if systemctl is-active --quiet "$svc"; then
    echo "Stopping service: $svc"
    sudo systemctl stop "$svc"
  fi
done

# User services
systemctl --user stop tracker-miner-fs-3.service 2>/dev/null || true

# Extra daemons you probably don't need while gaming
for svc in snapclient libvirtd; do
  if systemctl is-active --quiet "$svc"; then
    echo "Stopping service: $svc"
    sudo systemctl stop "$svc"
  fi
done

echo "== Killing heavy user-space helpers =="

# execsnoop-bpfcc (runs as python3)
if pgrep -f execsnoop-bpfcc >/dev/null 2>&1; then
  echo "Killing execsnoop-bpfcc"
  pkill -f execsnoop-bpfcc || true
fi

# AppCenter
if pgrep -f io.elementary.appcenter >/dev/null 2>&1; then
  echo "Killing AppCenter"
  pkill -f io.elementary.appcenter || true
fi

# Steam webhelpers
if pgrep steamwebhelper >/dev/null 2>&1; then
  echo "Killing Steam webhelpers"
  pkill steamwebhelper || true
fi

echo "Game mode tweaks done."

