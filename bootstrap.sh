#!/usr/bin/env bash
cd "$(dirname -- "$0")" || exit 1

# Copy the nspawn file for the containers

sudo mkdir -p /etc/systemd/nspawn
sudo cp ./media-stack.nspawn /etc/systemd/nspawn/
