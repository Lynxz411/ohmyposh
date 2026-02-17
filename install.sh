#!/bin/bash

echo "Installing Lynxz OhMyPosh Theme..."

mkdir -p ~/.config/ohmyposh
cp themes/lynxz.omp.json ~/.config/ohmyposh/

echo 'oh-my-posh init fish --config ~/.config/ohmyposh/lynxz.omp.json | source' >> ~/.config/fish/config.fish

echo "Done! Restart terminal."
