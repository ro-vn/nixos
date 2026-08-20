# Lifecycle commands for this config. Run `just` to list them.
# Requires the `just` binary (provided by the dev shell: `nix develop`).
#
# Two kinds of machine here:
#   macmini, macbook   nix-darwin owns the system  -> darwin-rebuild
#   rpi5               home-manager only           -> home-manager switch
#
# On a Mac the flake attribute is taken from the machine's own hostname, so the
# same command works on both. Before the very first switch the hostname is still
# whatever macOS shipped with, so pass it explicitly: `just switch macbook`.

set shell := ["bash", "-euo", "pipefail", "-c"]

# List available recipes
default:
    @just --list

# Build and activate the configuration for the current machine. Usage: just switch [macmini|macbook]
switch host="":
    if [[ "$(uname)" == "Darwin" ]]; then \
        h="{{host}}"; [[ -n "$h" ]] || h="$(scutil --get LocalHostName)"; \
        sudo darwin-rebuild switch --flake ".#$h"; \
    else \
        home-manager switch --flake .#rpi5 -b hm-bak; \
    fi

# Build without activating (dry run). Usage: just build [macmini|macbook]
build host="":
    if [[ "$(uname)" == "Darwin" ]]; then \
        h="{{host}}"; [[ -n "$h" ]] || h="$(scutil --get LocalHostName)"; \
        darwin-rebuild build --flake ".#$h"; \
    else \
        home-manager build --flake .#rpi5; \
    fi

# Apply the rpi5 home config over SSH from a Mac. Usage: just deploy-rpi5 [host]
# Standalone home-manager has no --target-host, so run the switch on the Pi.
deploy-rpi5 host="rpi5":
    ssh {{host}} 'set -euo pipefail; \
        cd ~/repos/nixos && git pull --ff-only && \
        nix run home-manager/release-25.05 -- switch --flake .#rpi5 -b hm-bak'

# Update all flake inputs
update:
    nix flake update

# Evaluate the flake (both Macs + formatting; not rpi5 — see README)
check:
    nix flake check

# Format all Nix files
fmt:
    nix fmt

# Garbage-collect generations older than 14 days
gc:
    nix-collect-garbage --delete-older-than 14d
    if [[ "$(uname)" == "Darwin" ]]; then sudo nix-collect-garbage --delete-older-than 14d; fi

# First-time bootstrap on a Mac — no darwin-rebuild yet. Usage: just bootstrap-darwin macbook
bootstrap-darwin host:
    nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake .#{{host}}

# First-time bootstrap on the Pi — no home-manager binary yet. Run on the Pi.
bootstrap-home:
    nix run home-manager/release-25.05 -- switch --flake .#rpi5 -b hm-bak
