# Misc Folder
The misc or "miscellaneous" folder contains supplementary files that provide additional functionality to UVVM (Universal VHDL Verification Methodology). This includes the UVVM context files and the vendor extensions files. The context files are created to simplify the inclusion of necessary libraries used in UVVM. The vendor extensions files are created to add extended vendor-dependent functionality to UVVM.

## Directory Structure
This section provides an overview of the directory structure.

    |__misc                     :: A collection of supplementary files
    |   |__context                  +- UVVM context files
    |   |__vendor_extentions        +- Vendor extension files
    |      |__questa                    -> Extension files for Questa

## Context
This folder contains two UVVM context files: `uvvm_support_context.vhd` and `uvvm_all_context.vhd`. The libraries included in each context file are shown below.

    uvvm_support_context.vhd    : utility library, scoreboard, spec_cov, and UVVM assertions (i.e. UVVM functionality except for VVCs and BFMs)
        uvvm_all_context.vhd    : all inclusive UVVM libraries (i.e. all VIPs, uvvm_vvc_framework, and uvvm_support_context)

## Vendor Extensions
This folder contains packages that provide extended functionality for different vendors. Each vendor's dependent packages are grouped into their own folder.

Note: Questa's extended functionality will soon be available and supported by Questa One v2026.1 and later.

## UVVM Maintainers
The UVVM steering group (currently Inventas and EmLogic, Norway) has released UVVM as open source and both EmLogic and Inventas are committed to develop this system further.
We do however appreciate contributions and suggestions from users.

Please use Pull requests for contributions and we will evaluate them for inclusion in our release on the master branch.
