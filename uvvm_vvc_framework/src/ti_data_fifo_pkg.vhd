--========================================================================================================================
-- Copyright (c) 2016 by Bitvis AS.  All rights reserved.
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
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_data_queue_pkg.all;

package ti_data_fifo_pkg is
  
  impure function fifo_init(
    buffer_size_in_bits   : natural;
    scope                 : string := "data_fifo"
  ) return natural;
  
  procedure fifo_init(
    buffer_idx            : natural;
    buffer_size_in_bits   : natural;
    scope                 : string := "data_fifo"
  );

  procedure fifo_put(
    buffer_idx        : natural;
    data              : std_logic_vector;
    scope             : string := "data_fifo"
  );

  impure function fifo_get(
    buffer_idx            : natural;
    entry_size_in_bits    : natural;
    scope                 : string := "data_fifo"
  ) return std_logic_vector;

  procedure fifo_flush(
    buffer_idx            : natural;
    scope                 : string := "data_fifo"
  );

  impure function fifo_peek(
    buffer_idx            : natural;
    entry_size_in_bits    : natural;
    scope                 : string := "data_fifo"
  ) return std_logic_vector;
  
  impure function fifo_get_count(
    buffer_idx            : natural;
    scope                 : string := "data_fifo"
  ) return natural;

  impure function fifo_get_max_count(
    buffer_idx            : natural;
    scope                 : string := "data_fifo"
  ) return natural;
  
  shared variable shared_data_fifo : t_data_queue;

end package ti_data_fifo_pkg;

package body ti_data_fifo_pkg is

  impure function fifo_init(
    buffer_size_in_bits   : natural;
    scope                 : string := "data_fifo"
  ) return natural is
  begin
    return shared_data_fifo.init_queue(buffer_size_in_bits, scope);
  end function;

  procedure fifo_init(
    buffer_idx            : natural;
    buffer_size_in_bits   : natural;
    scope                 : string := "data_fifo"
  ) is 
  begin
    shared_data_fifo.init_queue(buffer_idx, buffer_size_in_bits, scope);
  end procedure;

  procedure fifo_put(
    buffer_idx        : natural;
    data              : std_logic_vector;
    scope             : string := "data_fifo"
  ) is 
  begin
    shared_data_fifo.push_back(buffer_idx, data, scope);
  end procedure;

  impure function fifo_get(
    buffer_idx         : natural;
    entry_size_in_bits : natural;
    scope              : string := "data_fifo"
  ) return std_logic_vector is
  begin
    return shared_data_fifo.pop_front(buffer_idx, entry_size_in_bits, scope);
  end function;

  procedure fifo_flush(
    buffer_idx         : natural;
    scope             : string := "data_fifo"
  ) is 
  begin
    shared_data_fifo.flush(buffer_idx, scope);
  end procedure;

  impure function fifo_peek(
    buffer_idx         : natural;
    entry_size_in_bits : natural;
    scope              : string := "data_fifo"
  ) return std_logic_vector is
  begin
    return shared_data_fifo.peek_front(buffer_idx, entry_size_in_bits, scope);
  end function;
  
  impure function fifo_get_count(
    buffer_idx  : natural;
    scope       : string := "data_fifo"
  ) return natural is
  begin
    return shared_data_fifo.get_count(buffer_idx, scope);
  end function;

  impure function fifo_get_max_count(
    buffer_idx      : natural;
    scope           : string := "data_fifo"
  ) return natural is
  begin
    return shared_data_fifo.get_queue_count_max(buffer_idx, scope);
  end function;

end package body ti_data_fifo_pkg;

