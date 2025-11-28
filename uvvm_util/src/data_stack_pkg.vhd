--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.methods_pkg.all;
use work.string_methods_pkg.all;
use work.data_queue_pkg.all;

package data_stack_pkg is

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
    buffer_size_in_bits : natural
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
    buffer_idx          : natural;
    buffer_size_in_bits : natural
  );

  ------------------------------------------
  -- uvvm_stack_push
  ------------------------------------------
  -- This procedure pushes data into a stack with index buffer_idx.
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
    buffer_idx : natural;
    data       : std_logic_vector
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
  --             Attempting to pop() from an empty stack is allowed but triggers a
  --             TB_WARNING and returns garbage.
  --             Attempting to pop() a larger value than the stack size is allowed
  --             but triggers a TB_WARNING.
  --
  --
  impure function uvvm_stack_pop(
    buffer_idx         : natural;
    entry_size_in_bits : natural
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
    buffer_idx : natural
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
    buffer_idx         : natural;
    entry_size_in_bits : natural
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
    buffer_idx : natural
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
    buffer_idx : natural
  ) return natural;

  ------------------------------------------
  -- uvvm_stack_is_full
  ------------------------------------------
  -- This function returns a boolean indicating if
  -- the stack is full or not.
  --
  --  - Parameters:
  --        - buffer_idx          - The index of the stack (natural)
  --
  --  - Returns: TRUE if stack is full, else FALSE.
  --
  --
  impure function uvvm_stack_is_full(
    buffer_idx : natural
  ) return boolean;

  ------------------------------------------
  -- uvvm_stack_deallocate
  ------------------------------------------
  -- This procedure deallocates all the stacks
  -- in the buffer.
  --
  procedure uvvm_stack_deallocate(
    dummy : t_void
  );

end package data_stack_pkg;

package body data_stack_pkg is

  impure function uvvm_stack_init(
    buffer_size_in_bits : natural
  ) return natural is
  begin
    return shared_data_stack.init_queue(buffer_size_in_bits, "UVVM_STACK");
  end function;

  procedure uvvm_stack_init(
    buffer_idx          : natural;
    buffer_size_in_bits : natural
  ) is
  begin
    shared_data_stack.init_queue(buffer_idx, buffer_size_in_bits, "UVVM_STACK");
  end procedure;

  procedure uvvm_stack_push(
    buffer_idx : natural;
    data       : std_logic_vector
  ) is
  begin
    shared_data_stack.push_back(buffer_idx, data);
  end procedure;

  impure function uvvm_stack_pop(
    buffer_idx         : natural;
    entry_size_in_bits : natural
  ) return std_logic_vector is
  begin
    return shared_data_stack.pop_back(buffer_idx, entry_size_in_bits);
  end function;

  procedure uvvm_stack_flush(
    buffer_idx : natural
  ) is
  begin
    shared_data_stack.flush(buffer_idx);
  end procedure;

  impure function uvvm_stack_peek(
    buffer_idx         : natural;
    entry_size_in_bits : natural
  ) return std_logic_vector is
  begin
    return shared_data_stack.peek_back(buffer_idx, entry_size_in_bits);
  end function;

  impure function uvvm_stack_get_count(
    buffer_idx : natural
  ) return natural is
  begin
    return shared_data_stack.get_count(buffer_idx);
  end function;

  impure function uvvm_stack_get_max_count(
    buffer_idx : natural
  ) return natural is
  begin
    return shared_data_stack.get_queue_count_max(buffer_idx);
  end function;

  impure function uvvm_stack_is_full(
    buffer_idx : natural
  ) return boolean is
  begin
    return shared_data_stack.get_queue_is_full(buffer_idx);
  end function;

  procedure uvvm_stack_deallocate(
    dummy : t_void
  ) is
  begin
    shared_data_stack.deallocate_buffer(VOID);
  end procedure;

end package body data_stack_pkg;

