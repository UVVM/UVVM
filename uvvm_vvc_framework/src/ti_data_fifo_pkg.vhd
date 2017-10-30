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
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_data_queue_pkg.all;

package ti_data_fifo_pkg is

  shared variable shared_data_fifo : t_data_queue;

  ------------------------------------------
  -- uvvm_fifo_init
  ------------------------------------------
  -- This function allocates space in the buffer and returns an index that
  -- must be used to access the FIFO.
  --
  --  - Parameters:
  --        - buffer_size_in_bits (natural) - The size of the FIFO
  --
  --  - Returns: The index of the initiated FIFO (natural).
  --             Returns 0 on error.
  --
  impure function uvvm_fifo_init(
    buffer_size_in_bits   : natural
  ) return natural;

  ------------------------------------------
  -- uvvm_fifo_init
  ------------------------------------------
  -- This procedure allocates space in the buffer at the given buffer_idx.
  --
  --  - Parameters:
  --        - buffer_idx                    - The index of the FIFO (natural)
  --                                          that shall be initialized.
  --        - buffer_size_in_bits (natural) - The size of the FIFO
  --
  procedure uvvm_fifo_init(
    buffer_idx            : natural;
    buffer_size_in_bits   : natural
  );

  ------------------------------------------
  -- uvvm_fifo_put
  ------------------------------------------
  -- This procedure puts data into a FIFO with index buffer_idx.
  -- The size of the data is unconstrained, meaning that
  -- it can be any size. Pushing data with a size that is
  -- larger than the FIFO size results in wrapping, i.e.,
  -- that when reaching the end the data remaining will over-
  -- write the data that was written first.
  --
  --  - Parameters:
  --        - buffer_idx - The index of the FIFO (natural)
  --                       that shall be pushed to.
  --        - data       - The data that shall be pushed (slv)
  --
  procedure uvvm_fifo_put(
    buffer_idx        : natural;
    data              : std_logic_vector
  );

  ------------------------------------------
  -- uvvm_fifo_get
  ------------------------------------------
  -- This function returns the data from the FIFO
  -- and removes the returned data from the FIFO.
  --
  --  - Parameters:
  --        - buffer_idx          - The index of the FIFO (natural)
  --                                that shall be read.
  --        - entry_size_in_bits  - The size of the returned slv (natural)
  --
  --  - Returns: Data from the FIFO (slv). The size of the
  --             return data is given by the entry_size_in_bits parameter.
  --             Attempting to get() from an empty FIFO is allowed but triggers a
  --             TB_WARNING and returns garbage.
  --             Attempting to get() a larger value than the FIFO size is allowed
  --             but triggers a TB_WARNING.
  --
  --
  impure function uvvm_fifo_get(
    buffer_idx            : natural;
    entry_size_in_bits    : natural
  ) return std_logic_vector;

  ------------------------------------------
  -- uvvm_fifo_flush
  ------------------------------------------
  -- This procedure empties the FIFO given
  -- by buffer_idx.
  --
  --  - Parameters:
  --        - buffer_idx - The index of the FIFO (natural)
  --                       that shall be flushed.
  --
  procedure uvvm_fifo_flush(
    buffer_idx            : natural
  );

  ------------------------------------------
  -- uvvm_fifo_peek
  ------------------------------------------
  -- This function returns the data from the FIFO
  -- without removing it.
  --
  --  - Parameters:
  --        - buffer_idx          - The index of the FIFO (natural)
  --                                that shall be read.
  --        - entry_size_in_bits  - The size of the returned slv (natural)
  --
  --  - Returns: Data from the FIFO. The size of the
  --             return data is given by the entry_size_in_bits parameter.
  --             Attempting to peek from an empty FIFO is allowed but triggers a
  --             TB_WARNING and returns garbage.
  --             Attempting to peek a larger value than the FIFO size is allowed
  --             but triggers a TB_WARNING. Will wrap.
  --
  --
  impure function uvvm_fifo_peek(
    buffer_idx            : natural;
    entry_size_in_bits    : natural
  ) return std_logic_vector;

  ------------------------------------------
  -- uvvm_fifo_get_count
  ------------------------------------------
  -- This function returns a natural indicating the number of elements
  -- currently occupying the FIFO given by buffer_idx.
  --
  --  - Parameters:
  --        - buffer_idx          - The index of the FIFO (natural)
  --
  --  - Returns: The number of elements occupying the FIFO (natural).
  --
  --
  impure function uvvm_fifo_get_count(
    buffer_idx            : natural
  ) return natural;

  ------------------------------------------
  -- uvvm_fifo_get_max_count
  ------------------------------------------
  -- This function returns a natural indicating the maximum number
  -- of elements that can occupy the FIFO given by buffer_idx.
  --
  --  - Parameters:
  --        - buffer_idx          - The index of the FIFO (natural)
  --
  --  - Returns: The maximum number of elements that can be placed
  --             in the FIFO (natural).
  --
  --
  impure function uvvm_fifo_get_max_count(
    buffer_idx            : natural
  ) return natural;

  ------------------------------------------
  -- uvvm_fifo_is_full
  ------------------------------------------
  -- This function returns a boolean indicating if
  -- the FIFO is full or not.
  --
  --  - Parameters:
  --        - buffer_idx          - The index of the FIFO (natural)
  --
  --  - Returns: TRUE if FIFO is full, else FALSE.
  --
  --
  impure function uvvm_fifo_is_full(
    buffer_idx      : natural
  ) return boolean;

end package ti_data_fifo_pkg;

package body ti_data_fifo_pkg is

  impure function uvvm_fifo_init(
    buffer_size_in_bits   : natural
  ) return natural is
  begin
    return shared_data_fifo.init_queue(buffer_size_in_bits, "UVVM_FIFO");
  end function;

  procedure uvvm_fifo_init(
    buffer_idx            : natural;
    buffer_size_in_bits   : natural
  ) is
  begin
    shared_data_fifo.init_queue(buffer_idx, buffer_size_in_bits, "UVVM_FIFO");
  end procedure;

  procedure uvvm_fifo_put(
    buffer_idx        : natural;
    data              : std_logic_vector
  ) is
  begin
    shared_data_fifo.push_back(buffer_idx, data);
  end procedure;

  impure function uvvm_fifo_get(
    buffer_idx         : natural;
    entry_size_in_bits : natural
  ) return std_logic_vector is
  begin
    return shared_data_fifo.pop_front(buffer_idx, entry_size_in_bits);
  end function;

  procedure uvvm_fifo_flush(
    buffer_idx         : natural
  ) is
  begin
    shared_data_fifo.flush(buffer_idx);
  end procedure;

  impure function uvvm_fifo_peek(
    buffer_idx         : natural;
    entry_size_in_bits : natural
  ) return std_logic_vector is
  begin
    return shared_data_fifo.peek_front(buffer_idx, entry_size_in_bits);
  end function;

  impure function uvvm_fifo_get_count(
    buffer_idx  : natural
  ) return natural is
  begin
    return shared_data_fifo.get_count(buffer_idx);
  end function;

  impure function uvvm_fifo_get_max_count(
    buffer_idx      : natural
  ) return natural is
  begin
    return shared_data_fifo.get_queue_count_max(buffer_idx);
  end function;

  impure function uvvm_fifo_is_full(
    buffer_idx      : natural
  ) return boolean is
  begin
    return shared_data_fifo.get_queue_is_full(buffer_idx);
  end function;

end package body ti_data_fifo_pkg;

