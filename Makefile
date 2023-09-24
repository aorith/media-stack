SHELL := bash

ARCH := $(shell uname -m)
NAME := media-stack

.PHONY: build
build:
	nix build .

.PHONY: import
import:
	sudo machinectl import-tar ."/result/tarball/nixos-system-$(ARCH)-linux.tar.xz" $(NAME)

.PHONY: start
start:
	sudo machinectl start $(NAME)

.PHONY: enable
enable:
	sudo machinectl enable $(NAME)

.PHONY: disable
disable:
	sudo machinectl disable $(NAME)

.PHONY: remove
remove:
	sudo machinectl remove $(NAME)
