( [Click here to go to the UVVM overall overview](./../README.md) )

# UVVM Assertions Library
The Open Source 'UVVM (Universal VHDL Verification Methodology) - Assertions Library', a VHDL testbench infrastructure for making better VHDL testbenches for verification of FPGA.
This library is a part of the overall [UVVM](./../README.md)

## For what do I need this Assertions Library?
UVVM Assertions Library (previously part of UVVM Utility Library) is a collection of basic assertions following the UVVM logging and verbosity system. It may be used to check/assure that a signal property is upheld during the entire simulation (or when the 'enable' is upheld). See: https://uvvm.github.io/uvvm_assertions.html. UVVM assertions is split into two different types of assertions: "Basic assertions" and "window assertions", where the basic is intended for any pure VHDL assert usage (within the uvvm logging), and the "window assertions" is meant as a more advanced usage (without using PSL or other assertion syntaxes.)

## What are the benefits of using this system?
The base functionality of Utility Library is dead easy to use. UVVM Assertions adds all the functionality of native assertions while still keeping it within the familiar UVVM alert system. Although The most basic of the assertions `assert_value(ena(sl), tracked_value(bool), true)` may be encapsulated to assert almost any signal quality, UVVM assertions allow for simple pick and place of the ones most common (inspired by OVL).

## Prerequisites
UVVM Assertion Library requires the compilation of UVVM Utility Library, and must be compiled with VHDL-2008 or newer.
See the overall [UVVM](./../README.md) documentation for prerequisites, license, maintainers, etc.

## UVVM Maintainers
The UVVM steering group (currently Inventas and EmLogic, Norway) has released UVVM as open source and both EmLogic and Inventas are committed to develop this system further.
We do however appreciate contributions and suggestions from users.

Please use Pull requests for contributions and we will evaluate them for inclusion in our release on the master branch.
