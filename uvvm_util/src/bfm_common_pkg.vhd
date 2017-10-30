--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.types_pkg.all;
use work.string_methods_pkg.all;
use work.methods_pkg.all;
use work.adaptations_pkg.all;


package bfm_common_pkg is
  -- General declarations related to BFMs
  type t_normalization_mode is (ALLOW_WIDER, ALLOW_NARROWER, ALLOW_WIDER_NARROWER, ALLOW_EXACT_ONLY);
  alias t_normalisation_mode is t_normalization_mode;

  -- Functions/procedures
  impure function normalise(
    constant value       : in std_logic_vector;
    constant target      : in std_logic_vector;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "slv"
    ) return std_logic_vector;

  impure function normalise(
    constant value       : in unsigned;
    constant target      : in unsigned;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "unsigned"
    ) return unsigned;

  impure function normalise(
    constant value       : in signed;
    constant target      : in signed;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "signed"
    ) return signed;

  impure function normalise(
    constant value       : in t_slv_array;
    constant target      : in t_slv_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_slv_array"
    ) return t_slv_array;

  impure function normalise(
    constant value       : in t_unsigned_array;
    constant target      : in t_unsigned_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_unsigned_array"
    ) return t_unsigned_array;

  impure function normalise(
    constant value       : in t_signed_array;
    constant target      : in t_signed_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_signed_array"
    ) return t_signed_array;


  -- Functions/procedures
  impure function normalize_and_check(
    constant value       : in std_logic_vector;
    constant target      : in std_logic_vector;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "slv"
    ) return std_logic_vector;

  impure function normalize_and_check(
    constant value       : in unsigned;
    constant target      : in unsigned;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "unsigned"
    ) return unsigned;

  impure function normalize_and_check(
    constant value       : in signed;
    constant target      : in signed;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "signed"
    ) return signed;

  impure function normalize_and_check(
    constant value       : in t_slv_array;
    constant target      : in t_slv_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_slv_array"
    ) return t_slv_array;

  impure function normalize_and_check(
    constant value       : in t_unsigned_array;
    constant target      : in t_unsigned_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_unsigned_array"
    ) return t_unsigned_array;

  impure function normalize_and_check(
    constant value       : in t_signed_array;
    constant target      : in t_signed_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_signed_array"
    ) return t_signed_array;

  procedure wait_until_given_time_after_rising_edge (
    signal clk         : in std_logic;
    constant wait_time : in time
    );
  procedure wait_until_given_time_before_rising_edge (
    signal clk            : in std_logic;
    constant time_to_edge : in time;
    constant clk_period   : in time
    );
  procedure wait_num_rising_edge (
    signal clk               : in std_logic;
    constant num_rising_edge : in natural
    );

  procedure wait_num_rising_edge_plus_margin (
    signal clk               : in std_logic;
    constant num_rising_edge : in natural;
    constant margin          : in time
    );



end package bfm_common_pkg;
--=================================================================================================

package body bfm_common_pkg is
  constant C_SCOPE : string := "bfm_common";

  -- Normalize 'value' to the width given by 'target' and perform sanity check.
  impure function normalize_and_check(
    constant value       : in std_logic_vector;
    constant target      : in std_logic_vector;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "slv"
    ) return std_logic_vector is
    constant name : string := "normalize_and_check(" & val_type & ": " &
                              value_name & "=" & to_string(value, HEX, AS_IS) & ", " &
                              target_name & "=" & to_string(target, HEX, AS_IS) & ")";
    alias a_value               : std_logic_vector(value'length - 1 downto 0) is value;
    alias a_target              : std_logic_vector(target'length - 1 downto 0) is target;
    variable v_normalized_value : std_logic_vector(target'length - 1 downto 0);
  begin
    -- Verify that value and target are not zero-length vectors
    if value'length = 0 then
      tb_error(name & " => Value length is zero! " & add_msg_delimiter(msg), C_SCOPE);
      return v_normalized_value;
    elsif target'length = 0 then
      tb_error(name & " => Target length is zero! " & add_msg_delimiter(msg), C_SCOPE);
      return v_normalized_value;
    end if;
    -- If value'length > target'length, remove leading zeros from value
    if (a_value'length > a_target'length) then
      v_normalized_value := a_value(a_target'length - 1 downto 0);
      -- Sanity checks
      if not (mode = ALLOW_WIDER or mode = ALLOW_WIDER_NARROWER) then
        tb_error(name & " => " & value_name & " is wider than " & target_name & " without using ALLOW_WIDER mode. " & add_msg_delimiter(msg), C_SCOPE);
      end if;
      if not matching_widths(a_value, a_target) then
        tb_error(name & " => " & value_name & " is wider than " & target_name & " and has non-zeros in the extended MSB. " & add_msg_delimiter(msg), C_SCOPE);
      end if;
    -- If value'length = target'length
    elsif (a_value'length = a_target'length) then
      v_normalized_value := a_value;
    -- If value'length < target'length, add padding (leading zeros) to value
    elsif (a_value'length < a_target'length) then
      v_normalized_value                              := (others => '0');
      v_normalized_value(a_value'length - 1 downto 0) := a_value;
      -- Sanity check
      if not (mode = ALLOW_NARROWER or mode = ALLOW_WIDER_NARROWER) then
        tb_error(name & " => " & value_name & " is narrower than " & target_name & " without using ALLOW_NARROWER mode. " & add_msg_delimiter(msg), C_SCOPE);
      end if;
    end if;

    return v_normalized_value;
  end;

  impure function normalize_and_check(
    constant value       : in unsigned;
    constant target      : in unsigned;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "unsigned"
    ) return unsigned is
  begin
    return unsigned(normalize_and_check(std_logic_vector(value), std_logic_vector(target), mode, value_name, target_name, msg, val_type));
  end;

  impure function normalize_and_check(
    constant value       : in signed;
    constant target      : in signed;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "signed"
    ) return signed is
    constant name : string := "normalize_and_check(" & val_type & ": " &
                              value_name & "=" & to_string(std_logic_vector(value)) & ", " &
                              target_name & "=" & to_string(std_logic_vector(target)) & ")";
    alias a_value               : signed(value'length - 1 downto 0) is value;
    alias a_target              : signed(target'length - 1 downto 0) is target;
    variable v_normalized_value : signed(target'length - 1 downto 0);
  begin
    -- Verify that value and target are not zero-length vectors
    if value'length = 0 then
      tb_error(name & " => Value length is zero! " & add_msg_delimiter(msg), C_SCOPE);
      return v_normalized_value;
    elsif target'length = 0 then
      tb_error(name & " => Target length is zero! " & add_msg_delimiter(msg), C_SCOPE);
      return v_normalized_value;
    end if;
    -- If value'length > target'length, remove leading zeros/ones from value
    if a_value'length > a_target'length then
      v_normalized_value := a_value(a_target'length - 1 downto 0);
      -- Sanity checks
      if not (mode = ALLOW_WIDER or mode = ALLOW_WIDER_NARROWER) then
        tb_error(name & " => " & value_name & " is wider than " & target_name & " without using ALLOW_WIDER mode. " & add_msg_delimiter(msg), C_SCOPE);
      end if;

      if a_value(a_value'high) = '0' then     -- positive value
        if not matching_widths(a_value, a_target) then
          tb_error(name & " => " & value_name & " is wider than " & target_name & " and has non-zeros in the extended MSB. " & add_msg_delimiter(msg), C_SCOPE);
        end if;
      elsif a_value(a_value'high) = '1' then  -- negative value
        for i in a_value'high downto a_target'length loop
          if a_value(i) = '0' then
            tb_error(name & " => " & value_name & " is wider than " & target_name & " and has non-sign bits in the extended MSB. " & add_msg_delimiter(msg), C_SCOPE);
          end if;
        end loop;
      end if;
    -- If value'length = target'length
    elsif a_value'length = a_target'length then
      v_normalized_value := a_value;
    -- If value'length < target'length, add padding (leading zeros/ones) to value
    elsif a_value'length < a_target'length then
      if a_value(a_value'high) = '0' then     -- positive value
        v_normalized_value := (others => '0');
      elsif a_value(a_value'high) = '1' then  -- negative value
        v_normalized_value := (others => '1');
      end if;
      v_normalized_value(a_value'length - 1 downto 0) := a_value;
      -- Sanity check
      if not (mode = ALLOW_NARROWER or mode = ALLOW_WIDER_NARROWER) then
        tb_error(name & " => " & value_name & " is narrower than " & target_name & " without using ALLOW_NARROWER mode. " & add_msg_delimiter(msg), C_SCOPE);
      end if;
    end if;

    return v_normalized_value;
  end;

  impure function normalize_and_check(
    constant value       : in t_slv_array;
    constant target      : in t_slv_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_slv_array"
    ) return t_slv_array is
    -- Helper variables
    variable v_slv_array_ascending  : t_slv_array(0 to target'length-1)(0 to target(0)'length-1);
    variable v_slv_array_descending : t_slv_array(target'length-1 downto 0)(target(0)'length-1 downto 0);
  begin
    -- check directions
    if (value'ascending and not(target'ascending)) then
      tb_error("value instanciated as 'to', target instanciated as 'dowto'." & add_msg_delimiter(msg), C_SCOPE);
    elsif (not(value'ascending) and target'ascending) then
      tb_error("value instanciated as 'downto', target instanciated as 'to'." & add_msg_delimiter(msg), C_SCOPE);
    end if;
    if (value(0)'ascending and not(target(0)'ascending)) then
      tb_error("value(n) instanciated as 'to', target(n) instanciated as 'dowto'." & add_msg_delimiter(msg), C_SCOPE);
    elsif (not(value(0)'ascending) and target(0)'ascending) then
      tb_error("value(n) instanciated as 'downto', target(n) instanciated as 'to'." & add_msg_delimiter(msg), C_SCOPE);
    end if;

    -- return ascending t_slv_array
    if (value'ascending) then
      if value'length > target'length then
        for idx in target'range loop
          v_slv_array_ascending(idx) := normalize_and_check(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
        end loop;
      else
        for idx in value'range loop
          v_slv_array_ascending(idx) := normalize_and_check(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
        end loop;
      end if;
      return v_slv_array_ascending;

    else -- return descending t_slv_array
      if value'length > target'length then
        for idx in target'range loop
          v_slv_array_descending(idx) := normalize_and_check(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
        end loop;
      else
        for idx in value'range loop
          v_slv_array_descending(idx) := normalize_and_check(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
        end loop;
      end if;
      return v_slv_array_descending;

    end if;
  end;

  impure function normalize_and_check(
    constant value       : in t_signed_array;
    constant target      : in t_signed_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_signed_array"
    ) return t_signed_array is
    -- Helper variables
    variable v_signed_array : t_signed_array(target'length-1 downto 0)(target(0)'length-1 downto 0);
  begin
    -- check directions
    if (value'ascending and not(target'ascending)) then
      tb_error("value instanciated as 'to', target instanciated as 'dowto'." & add_msg_delimiter(msg), C_SCOPE);
    elsif (not(value'ascending) and target'ascending) then
      tb_error("value instanciated as 'downto', target instanciated as 'to'." & add_msg_delimiter(msg), C_SCOPE);
    end if;

    if value'length > target'length then
      for idx in target'range loop
        v_signed_array(idx) := normalize_and_check(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    else
      for idx in value'range loop
        v_signed_array(idx) := normalize_and_check(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    end if;
    return v_signed_array;
  end;

  impure function normalize_and_check(
    constant value       : in t_unsigned_array;
    constant target      : in t_unsigned_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_unsigned_array"
    ) return t_unsigned_array is
    variable v_unsigned_array : t_unsigned_array(target'length-1 downto 0)(target(0)'length-1 downto 0);
  begin
    -- check directions
    if (value'ascending and not(target'ascending)) then
      tb_error("value instanciated as 'to', target instanciated as 'dowto'." & add_msg_delimiter(msg), C_SCOPE);
    elsif (not(value'ascending) and target'ascending) then
      tb_error("value instanciated as 'downto', target instanciated as 'to'." & add_msg_delimiter(msg), C_SCOPE);
    end if;

    if value'length > target'length then
      for idx in target'range loop
        v_unsigned_array(idx) := normalize_and_check(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    else
      for idx in value'range loop
        v_unsigned_array(idx) := normalize_and_check(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    end if;
    return v_unsigned_array;
  end;

  -- Normalise 'value' to the width given by 'target'.
  impure function normalise(
    constant value       : in std_logic_vector;
    constant target      : in std_logic_vector;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "slv"
    ) return std_logic_vector is
    constant name : string := "normalise(" & val_type & ": " &
                              value_name & "=" & to_string(value, HEX, AS_IS) & ", " &
                              target_name & "=" & to_string(target, HEX, AS_IS) & ")";
    alias a_value               : std_logic_vector(value'length - 1 downto 0) is value;
    alias a_target              : std_logic_vector(target'length - 1 downto 0) is target;
    variable v_normalised_value : std_logic_vector(target'length - 1 downto 0);
  begin
    deprecate(get_procedure_name_from_instance_name(value'instance_name), "Use normalize_and_check().");
    -- Verify that value and target are not zero-length vectors
    if value'length = 0 then
      tb_error(name & " => Value length is zero! " & add_msg_delimiter(msg), C_SCOPE);
      return v_normalised_value;
    elsif target'length = 0 then
      tb_error(name & " => Target length is zero! " & add_msg_delimiter(msg), C_SCOPE);
      return v_normalised_value;
    end if;
    -- If value'length > target'length, remove leading zeros from value
    if (a_value'length > a_target'length) then
      v_normalised_value := a_value(a_target'length - 1 downto 0);
      -- Sanity checks
      if not (mode = ALLOW_WIDER or mode = ALLOW_WIDER_NARROWER) then
        tb_error(name & " => " & value_name & " is wider than " & target_name & " without using ALLOW_WIDER mode. " & add_msg_delimiter(msg), C_SCOPE);
      end if;
      if not matching_widths(a_value, a_target) then
        tb_error(name & " => " & value_name & " is wider than " & target_name & " and has non-zeros in the extended MSB. " & add_msg_delimiter(msg), C_SCOPE);
      end if;
    -- If value'length = target'length
    elsif (a_value'length = a_target'length) then
      v_normalised_value := a_value;
    -- If value'length < target'length, add padding (leading zeros) to value
    elsif (a_value'length < a_target'length) then
      v_normalised_value                              := (others => '0');
      v_normalised_value(a_value'length - 1 downto 0) := a_value;
      -- Sanity check
      if not (mode = ALLOW_NARROWER or mode = ALLOW_WIDER_NARROWER) then
        tb_error(name & " => " & value_name & " is narrower than " & target_name & " without using ALLOW_NARROWER mode. " & add_msg_delimiter(msg), C_SCOPE);
      end if;
    end if;

    return v_normalised_value;
  end;

  impure function normalise(
    constant value       : in unsigned;
    constant target      : in unsigned;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "unsigned"
    ) return unsigned is
  begin
    return unsigned(normalise(std_logic_vector(value), std_logic_vector(target), mode, value_name, target_name, msg, val_type));
  end;

  impure function normalise(
    constant value       : in signed;
    constant target      : in signed;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "signed"
    ) return signed is
    constant name : string := "normalise(" & val_type & ": " &
                              value_name & "=" & to_string(std_logic_vector(value)) & ", " &
                              target_name & "=" & to_string(std_logic_vector(target)) & ")";
    alias a_value               : signed(value'length - 1 downto 0) is value;
    alias a_target              : signed(target'length - 1 downto 0) is target;
    variable v_normalised_value : signed(target'length - 1 downto 0);
  begin
    deprecate(get_procedure_name_from_instance_name(value'instance_name), "Use normalize_and_check().");
    -- Verify that value and target are not zero-length vectors
    if value'length = 0 then
      tb_error(name & " => Value length is zero! " & add_msg_delimiter(msg), C_SCOPE);
      return v_normalised_value;
    elsif target'length = 0 then
      tb_error(name & " => Target length is zero! " & add_msg_delimiter(msg), C_SCOPE);
      return v_normalised_value;
    end if;
    -- If value'length > target'length, remove leading zeros/ones from value
    if a_value'length > a_target'length then
      v_normalised_value := a_value(a_target'length - 1 downto 0);
      -- Sanity checks
      if not (mode = ALLOW_WIDER or mode = ALLOW_WIDER_NARROWER) then
        tb_error(name & " => " & value_name & " is wider than " & target_name & " without using ALLOW_WIDER mode. " & add_msg_delimiter(msg), C_SCOPE);
      end if;

      if a_value(a_value'high) = '0' then     -- positive value
        if not matching_widths(a_value, a_target) then
          tb_error(name & " => " & value_name & " is wider than " & target_name & " and has non-zeros in the extended MSB. " & add_msg_delimiter(msg), C_SCOPE);
        end if;
      elsif a_value(a_value'high) = '1' then  -- negative value
        for i in a_value'high downto a_target'length loop
          if a_value(i) = '0' then
            tb_error(name & " => " & value_name & " is wider than " & target_name & " and has non-sign bits in the extended MSB. " & add_msg_delimiter(msg), C_SCOPE);
          end if;
        end loop;
      end if;
    -- If value'length = target'length
    elsif a_value'length = a_target'length then
      v_normalised_value := a_value;
    -- If value'length < target'length, add padding (leading zeros/ones) to value
    elsif a_value'length < a_target'length then
      if a_value(a_value'high) = '0' then     -- positive value
        v_normalised_value := (others => '0');
      elsif a_value(a_value'high) = '1' then  -- negative value
        v_normalised_value := (others => '1');
      end if;
      v_normalised_value(a_value'length - 1 downto 0) := a_value;
      -- Sanity check
      if not (mode = ALLOW_NARROWER or mode = ALLOW_WIDER_NARROWER) then
        tb_error(name & " => " & value_name & " is narrower than " & target_name & " without using ALLOW_NARROWER mode. " & add_msg_delimiter(msg), C_SCOPE);
      end if;
    end if;

    return v_normalised_value;
  end;

  impure function normalise(
    constant value       : in t_slv_array;
    constant target      : in t_slv_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_slv_array"
    ) return t_slv_array is
    -- Helper variables
    variable v_slv_array : t_slv_array(target'length-1 downto 0)(target(0)'length-1 downto 0);
  begin
    if value'length > target'length then
      for idx in target'range loop
        v_slv_array(idx) := normalise(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    else
      for idx in value'range loop
        v_slv_array(idx) := normalise(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    end if;
    return v_slv_array;
  end;

  impure function normalise(
    constant value       : in t_signed_array;
    constant target      : in t_signed_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_signed_array"
    ) return t_signed_array is
    -- Helper variables
    variable v_signed_array : t_signed_array(target'length-1 downto 0)(target(0)'length-1 downto 0);
  begin
    if value'length > target'length then
      for idx in target'range loop
        v_signed_array(idx) := normalise(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    else
      for idx in value'range loop
        v_signed_array(idx) := normalise(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    end if;
    return v_signed_array;
  end;

  impure function normalise(
    constant value       : in t_unsigned_array;
    constant target      : in t_unsigned_array;
    constant mode        : in t_normalization_mode;
    constant value_name  :    string;
    constant target_name :    string;
    constant msg         :    string;
    constant val_type    :    string := "t_unsigned_array"
    ) return t_unsigned_array is
    -- Helper variable
    variable v_unsigned_array : t_unsigned_array(target'length-1 downto 0)(target(0)'length-1 downto 0);
  begin
    if value'length > target'length then
      for idx in target'range loop
        v_unsigned_array(idx) := normalise(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    else
      for idx in value'range loop
        v_unsigned_array(idx) := normalise(value(idx), target(idx), mode, value_name, target_name, msg, val_type);
      end loop;
    end if;
    return v_unsigned_array;
  end;

  -- Wait until wait_time after rising_edge(clk)
  procedure wait_until_given_time_after_rising_edge (
    signal clk         : in std_logic;
    constant wait_time : in time
    ) is
    variable v_remaining_wait_time : time;
  begin
    -- If the time since the previous rising_edge is less than wait_time,
    -- we don't have to wait until the next rising_edge,
    -- only wait_time minus the time already passed since rising_edge
    if (clk'last_event <= wait_time and  -- less than wait_time has passed since last event
        clk'last_value = '0' and clk = '1'  -- last event was a rising_edge
        ) then
      v_remaining_wait_time := wait_time - clk'last_event;  -- Wait until wait_time after rising_edge
    else
      wait until rising_edge(clk);
      v_remaining_wait_time := wait_time;  -- Wait until wait_time after rising_edge
    end if;
    wait for v_remaining_wait_time;
  end;

  -- Wait until time_to_edge before rising_edge(clk)
  procedure wait_until_given_time_before_rising_edge (
    signal clk            : in std_logic;
    constant time_to_edge : in time;
    constant clk_period   : in time
    ) is
    variable v_remaining_wait_time : time;
  begin
    check_value(clk_period > 2*time_to_edge, TB_ERROR, "time_to_edge must be less than half clk_period", C_SCOPE, ID_NEVER);

    -- If the time to the next rising edge is greater than time_to_edge and clk is low,
    -- we don't have to wait until the next falling_edge,
    -- only wait_time minus the time already passed since falling_edge
    if (clk'last_event <= clk_period/2 - time_to_edge and
        clk'last_value = '1' and clk = '0') then
      v_remaining_wait_time := (clk_period/2 - time_to_edge) - clk'last_event;  -- Wait until time_to_edge before rising_edge
    else
      wait until falling_edge(clk);
      v_remaining_wait_time := (clk_period/2 - time_to_edge);  -- Wait until time_to_edge before rising_edge
    end if;

    wait for v_remaining_wait_time;
  end;

  procedure wait_num_rising_edge (
    signal clk               : in std_logic;
    constant num_rising_edge : in natural
    ) is
  begin
    wait_num_rising_edge_plus_margin(clk, num_rising_edge, 0 ns);
  end procedure;


  procedure wait_num_rising_edge_plus_margin (
    signal clk               : in std_logic;
    constant num_rising_edge : in natural;
    constant margin          : in time
    ) is
  begin
    -- Wait for number of rising edges
    if num_rising_edge /= 0 then
      for i in 1 to num_rising_edge loop
        wait until rising_edge(clk);
      end loop;
    end if;
    -- Wait for remaining margin, if any
    wait for margin;
  end procedure;

end package body bfm_common_pkg;
