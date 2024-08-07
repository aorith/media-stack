SHELL := bash

ARCH := $(shell uname -m)
NAME := media-stack

.PHONY: build
build:
	nix build .

.PHONY: import
import:
	sudo machinectl poweroff $(NAME) 2>/dev/null && sleep 5 || true
	sudo machinectl remove $(NAME) 2>/dev/null || true
	sudo machinectl import-fs result/root $(NAME)
	sudo mkdir -p /etc/systemd/nspawn
	sudo cp ./media-stack.nspawn /etc/systemd/nspawn/

.PHONY: start
start:
	sudo machinectl start $(NAME)

.PHONY: poweroff
poweroff:
	sudo machinectl poweroff $(NAME)

.PHONY: enable
enable:
	sudo machinectl enable $(NAME)

.PHONY: disable
disable:
	sudo machinectl disable $(NAME)

.PHONY: remove
remove:
	sudo machinectl remove $(NAME)

.PHONY: status
status:
	sudo machinectl status $(NAME)

.PHONY: login
login:
	sudo machinectl login $(NAME)
