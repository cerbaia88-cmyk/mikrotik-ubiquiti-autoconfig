#!/bin/bash
# ubnt-verify.sh
# Verifies the antenna is reachable after upgrade/configuration

ANTENNA_IP="${1:-192.168.100.10}"
SSH_USER="${SSH_USER:-ubnt}"
SSH_PASS="${SSH_PASS:-ubnt}"

sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$SSH_USER@$ANTENNA_IP" "echo ok && cat /etc/version 2>/dev/null | head -n 1" >/tmp/ubnt-verify.out 2>/dev/null || {
  echo "Antenna not reachable"
  exit 1
}

echo "Antenna reachable"
cat /tmp/ubnt-verify.out
