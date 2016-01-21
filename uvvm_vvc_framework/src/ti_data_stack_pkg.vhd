--========================================================================================================================
-- Copyright (c) 2016 by Bitvis AS.  All rights reserved. Patent pending.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
-- contact Bitvis AS <support@bitvis.no>.
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_data_queue_pkg.all;

package ti_data_stack_pkg is

  impure function stack_init(
    buffer_size_in_bits   : natural;
    scope                 : string := "data_stack"
  ) return natural;

  procedure stack_init(
    buffer_index          : natural;
    buffer_size_in_bits   : natural;
    scope                 : string := "data_stack"
  );

  procedure stack_push(
    buffer_index          : natural;
    data                  : std_logic_vector;
    scope                 : string := "data_stack"
  );

  impure function stack_pop(
    buffer_index          : natural;
    entry_size_in_bits    : natural;
    scope                 : string := "data_stack"
  ) return std_logic_vector;

  procedure stack_flush(
    buffer_index          : natural;
    scope                 : string := "data_stack"
  );

  impure function stack_peek(
    buffer_index          : natural;
    entry_size_in_bits    : natural;
    scope                 : string := "data_stack"
  ) return std_logic_vector;

  impure function stack_get_count(
    buffer_idx            : natural;
    scope                 : string := "data_stack"
  ) return natural;

  impure function stack_get_max_count(
    buffer_index          : natural;
    scope                 : string := "data_stack"
  ) return natural;

  shared variable shared_data_stack : t_data_queue;
  
end package ti_data_stack_pkg;

package body ti_data_stack_pkg is

  impure function stack_init(
    buffer_size_in_bits   : natural;
    scope                 : string := "data_stack"
  ) return natural is
  begin
    return shared_data_stack.init_queue(buffer_size_in_bits, scope);
  end function;

  procedure stack_init(
    buffer_index          : natural;
    buffer_size_in_bits   : natural;
    scope                 : string := "data_stack"
  ) is 
  begin
    shared_data_stack.init_queue(buffer_index, buffer_size_in_bits, scope);
  end procedure;

  procedure stack_push(
    buffer_index      : natural;
    data              : std_logic_vector;
    scope             : string := "data_stack"
  ) is 
  begin
    shared_data_stack.push_back(buffer_index,data, scope);
  end procedure;

  impure function stack_pop(
    buffer_index       : natural;
    entry_size_in_bits : natural;
    scope              : string := "data_stack"
  ) return std_logic_vector is
  begin
    return shared_data_stack.pop_back(buffer_index, entry_size_in_bits, scope);
  end function;

  procedure stack_flush(
    buffer_index      : natural;
    scope             : string := "data_stack"
  ) is 
  begin
    shared_data_stack.flush(buffer_index, scope);
  end procedure;

  impure function stack_peek(
    buffer_index       : natural;
    entry_size_in_bits : natural;
    scope              : string := "data_stack"
  ) return std_logic_vector is
  begin
    return shared_data_stack.peek_back(buffer_index, entry_size_in_bits, scope);
  end function;

  impure function stack_get_count(
    buffer_idx     : natural;
    scope          : string := "data_stack"
  ) return natural is
  begin
    return shared_data_stack.get_count(buffer_idx, scope);
  end function;

  impure function stack_get_max_count(
    buffer_index      : natural;
    scope             : string := "data_stack"
  ) return natural is
  begin
    return shared_data_stack.get_queue_count_max(buffer_index, scope);
  end function;


end package body ti_data_stack_pkg;

