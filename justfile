# Lifecycle commands for this config. Run `just` to list them.
# Requires the `just` binary (provided by the dev shell: `nix develop`).

set shell := ["bash", "-euo", "pipefail", "-c"]

# List available recipes
default:
    @just --list

# Build and activate the configuration for the current machine
switch:
    if [[ "$(uname)" == "Darwin" ]]; then \
        sudo darwin-rebuild switch --flake .#macbook; \
    else \
        sudo nixos-rebuild switch --flake .#n100; \
    fi

# Build without activating (dry run)
build:
    if [[ "$(uname)" == "Darwin" ]]; then \
        darwin-rebuild build --flake .#macbook; \
    else \
        nixos-rebuild build --flake .#n100; \
    fi

# Deploy a NixOS host over SSH (run from the Mac). Usage: just deploy n100
deploy host="n100":
    nixos-rebuild switch --flake .#{{host}} \
        --target-host {{host}} --use-remote-sudo

# Update all flake inputs
update:
    nix flake update

# Evaluate the whole flake (all hosts + formatting)
check:
    nix flake check

# Format all Nix files
fmt:
    nix fmt

# Garbage-collect generations older than 14 days
gc:
    nix-collect-garbage --delete-older-than 14d
    if [[ "$(uname)" == "Darwin" ]]; then sudo nix-collect-garbage --delete-older-than 14d; fi

# First-time bootstrap on macOS (installs nix-darwin, then use `just switch`)
bootstrap-darwin:
    nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake .#macbook
