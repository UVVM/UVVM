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

package ti_data_stack_pkg is

  shared variable shared_data_stack : t_data_queue;

  ------------------------------------------
  -- uvvm_stack_init
  ------------------------------------------
  -- This function allocates space in the buffer and returns an index that 
  -- must be used to access the stack.
  --   
  --  - Parameters: 
  --        - buffer_size_in_bits (natural) - The size of the stack
  --
  --  - Returns: The index of the initiated stack (natural). 
  --             Returns 0 on error.
  --
  impure function uvvm_stack_init(
    buffer_size_in_bits   : natural
  ) return natural;

  ------------------------------------------
  -- uvvm_stack_init
  ------------------------------------------
  -- This procedure allocates space in the buffer at the given buffer_idx.
  --
  --  - Parameters: 
  --        - buffer_idx                    - The index of the stack (natural)
  --                                          that shall be initialized.  
  --        - buffer_size_in_bits (natural) - The size of the stack
  --
  procedure uvvm_stack_init(
    buffer_index          : natural;
    buffer_size_in_bits   : natural
  );

  ------------------------------------------
  -- uvvm_stack_push
  ------------------------------------------
  -- This procedure puts data into a stack with index buffer_idx.
  -- The size of the data is unconstrained, meaning that 
  -- it can be any size. Pushing data with a size that is
  -- larger than the stack size results in wrapping, i.e.,
  -- that when reaching the end the data remaining will over-
  -- write the data that was written first.
  -- 
  --  - Parameters: 
  --        - buffer_idx - The index of the stack (natural) 
  --                       that shall be pushed to.  
  --        - data       - The data that shall be pushed (slv)
  --
  procedure uvvm_stack_push(
    buffer_index          : natural;
    data                  : std_logic_vector
  );

  ------------------------------------------
  -- uvvm_stack_pop
  ------------------------------------------
  -- This function returns the data from the stack
  -- and removes the returned data from the stack.
  -- 
  --  - Parameters: 
  --        - buffer_idx          - The index of the stack (natural) 
  --                                that shall be read.  
  --        - entry_size_in_bits  - The size of the returned slv (natural)
  --
  --  - Returns: Data from the stack (slv). The size of the 
  --             return data is given by the entry_size_in_bits parameter.
  --             Attempting to pop from an empty stack is allowed but triggers a 
  --             TB_WARNING and returns garbage.
  --             Attempting to pop a larger value than the stack size is allowed
  --             but triggers a TB_WARNING.
  --             
  --
  impure function uvvm_stack_pop(
    buffer_index          : natural;
    entry_size_in_bits    : natural
  ) return std_logic_vector;

  ------------------------------------------
  -- uvvm_stack_flush
  ------------------------------------------
  -- This procedure empties the stack given
  -- by buffer_idx.
  --
  --  - Parameters: 
  --        - buffer_idx - The index of the stack (natural)
  --                       that shall be flushed.
  --
  procedure uvvm_stack_flush(
    buffer_index          : natural
  );

  ------------------------------------------
  -- uvvm_stack_peek
  ------------------------------------------
  -- This function returns the data from the stack
  -- without removing it.
  -- 
  --  - Parameters: 
  --        - buffer_idx          - The index of the stack (natural) 
  --                                that shall be read.  
  --        - entry_size_in_bits  - The size of the returned slv (natural)
  --
  --  - Returns: Data from the stack. The size of the 
  --             return data is given by the entry_size_in_bits parameter.
  --             Attempting to peek from an empty stack is allowed but triggers a 
  --             TB_WARNING and returns garbage.
  --             Attempting to peek a larger value than the stack size is allowed
  --             but triggers a TB_WARNING. Will wrap.
  --             
  --
  impure function uvvm_stack_peek(
    buffer_index          : natural;
    entry_size_in_bits    : natural
  ) return std_logic_vector;

  ------------------------------------------
  -- uvvm_stack_get_count
  ------------------------------------------
  -- This function returns a natural indicating the number of elements
  -- currently occupying the stack given by buffer_idx.
  -- 
  --  - Parameters: 
  --        - buffer_idx          - The index of the stack (natural)
  --
  --  - Returns: The number of elements occupying the stack (natural).
  --             
  --
  impure function uvvm_stack_get_count(
    buffer_idx            : natural
  ) return natural;

  ------------------------------------------
  -- uvvm_stack_get_max_count
  ------------------------------------------
  -- This function returns a natural indicating the maximum number 
  -- of elements that can occupy the stack given by buffer_idx.
  --
  --  - Parameters: 
  --        - buffer_idx          - The index of the stack (natural)
  --
  --  - Returns: The maximum number of elements that can be placed
  --             in the stack (natural).
  --             
  --
  impure function uvvm_stack_get_max_count(
    buffer_index          : natural
  ) return natural;

end package ti_data_stack_pkg;

package body ti_data_stack_pkg is

  impure function uvvm_stack_init(
    buffer_size_in_bits   : natural
  ) return natural is
  begin
    return shared_data_stack.init_queue(buffer_size_in_bits, "UVVM_STACK");
  end function;

  procedure uvvm_stack_init(
    buffer_index          : natural;
    buffer_size_in_bits   : natural
  ) is 
  begin
    shared_data_stack.init_queue(buffer_index, buffer_size_in_bits, "UVVM_STACK");
  end procedure;

  procedure uvvm_stack_push(
    buffer_index      : natural;
    data              : std_logic_vector
  ) is 
  begin
    shared_data_stack.push_back(buffer_index,data);
  end procedure;

  impure function uvvm_stack_pop(
    buffer_index       : natural;
    entry_size_in_bits : natural
  ) return std_logic_vector is
  begin
    return shared_data_stack.pop_back(buffer_index, entry_size_in_bits);
  end function;

  procedure uvvm_stack_flush(
    buffer_index      : natural
  ) is 
  begin
    shared_data_stack.flush(buffer_index);
  end procedure;

  impure function uvvm_stack_peek(
    buffer_index       : natural;
    entry_size_in_bits : natural
  ) return std_logic_vector is
  begin
    return shared_data_stack.peek_back(buffer_index, entry_size_in_bits);
  end function;

  impure function uvvm_stack_get_count(
    buffer_idx     : natural
  ) return natural is
  begin
    return shared_data_stack.get_count(buffer_idx);
  end function;

  impure function uvvm_stack_get_max_count(
    buffer_index      : natural
  ) return natural is
  begin
    return shared_data_stack.get_queue_count_max(buffer_index);
  end function;


end package body ti_data_stack_pkg;

