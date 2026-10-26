This folder contains configuration files and custom rules for (VHDL Style Guide)[https://github.com/jeremiah-c-leary/vhdl-style-guide/] 
that follow the UVVM conventions.

Usage:

  vsg -c <YAML file path> -f <VHDL file path>

e.g.

  vsg -c C:/uvvm/release/code_conventions/uvvm.yaml -f C:/uvvm/bitvis_*/src/*.vhd -of syntastic
  vsg -c C:/uvvm/release/code_conventions/uvvm.yaml -f C:/uvvm/external_*/src*/*.vhd -of syntastic
  vsg -c C:/uvvm/release/code_conventions/uvvm.yaml -f C:/uvvm/uvvm_*/src*/*.vhd -of syntastic