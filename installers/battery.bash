#!/bin/bash 

sudo pacman -S tlp tlp-rdw # Reason: Bateria
sudo pacman -S thermald # Reason: Bateria

# Enable TLP (Power Management)
sudo systemctl enable --now tlp.service

# Enable Thermald (Prevents Intel CPUs from overheating/throttling poorly)
sudo systemctl enable --now thermald.service

# Mask the standard power-profiles-daemon (it conflicts with TLP)
sudo systemctl mask power-profiles-daemon.service
