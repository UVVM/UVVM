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

package data_queue_pkg is

  -- Declaration of storage
  subtype t_data_buffer is std_logic_vector(C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER - 1 downto 0);
  shared variable shared_data_buffer : t_data_buffer;

  type t_buffer_natural_array is array (C_NUMBER_OF_DATA_BUFFERS - 1 downto 0) of natural;
  type t_buffer_boolean_array is array (C_NUMBER_OF_DATA_BUFFERS - 1 downto 0) of boolean;

  type t_data_queue is protected
    ------------------------------------------
    -- init_queue
    ------------------------------------------
    -- This function allocates space in the buffer and returns an index that
    -- must be used to access the queue.
    --
    --  - Parameters:
    --        - queue_size_in_bits (natural) - The size of the queue
    --        - scope                        - Log scope for all alerts/logs
    --
    --  - Returns: The index of the initiated queue (natural).
    --             Returns 0 on error.
    --
    impure function init_queue(
      queue_size_in_bits : natural;
      scope              : string := "data_queue"
    ) return natural;

    ------------------------------------------
    -- init_queue
    ------------------------------------------
    -- This procedure allocates space in the buffer at the given queue_idx.
    --
    --  - Parameters:
    --        - queue_idx                    - The index of the queue (natural)
    --                                         that shall be initialized.
    --        - queue_size_in_bits (natural) - The size of the queue
    --        - scope                        - Log scope for all alerts/logs
    --
    procedure init_queue(
      queue_idx          : natural;
      queue_size_in_bits : natural;
      scope              : string := "data_queue"
    );

    ------------------------------------------
    -- flush
    ------------------------------------------
    -- This procedure empties the queue given
    -- by queue_idx.
    --
    --  - Parameters:
    --        - queue_idx - The index of the queue (natural)
    --                      that shall be flushed.
    --
    procedure flush(
      queue_idx : natural
    );

    ------------------------------------------
    -- push_back
    ------------------------------------------
    -- This procedure pushes data to the end of a queue.
    -- The size of the data is unconstrained, meaning that
    -- it can be any size. Pushing data with a size that is
    -- larger than the queue size results in wrapping, i.e.,
    -- that when reaching the end the data remaining will over-
    -- write the data that was written first.
    --
    --  - Parameters:
    --        - queue_idx - The index of the queue (natural)
    --                      that shall be pushed to.
    --        - data      - The data that shall be pushed (slv)
    --
    procedure push_back(
      queue_idx : natural;
      data      : std_logic_vector
    );

    ------------------------------------------
    -- peek_front
    ------------------------------------------
    -- This function returns the data from the front
    -- of the queue without popping it.
    --
    --  - Parameters:
    --        - queue_idx          - The index of the queue (natural)
    --                               that shall be read.
    --        - entry_size_in_bits - The size of the returned slv (natural)
    --
    --  - Returns: The data from the front of the queue (slv). The size of the
    --             return data is given by the entry_size_in_bits parameter.
    --             Attempting to peek from an empty queue is allowed but triggers a
    --             TB_WARNING and returns garbage.
    --             Attempting to peek a larger value than the queue size is allowed
    --             but triggers a TB_WARNING. Will wrap.
    --
    --
    impure function peek_front(
      queue_idx          : natural;
      entry_size_in_bits : natural
    ) return std_logic_vector;

    ------------------------------------------
    -- peek_back
    ------------------------------------------
    -- This function returns the data from the back
    -- of the queue without popping it.
    --
    --  - Parameters:
    --        - queue_idx          - The index of the queue (natural)
    --                               that shall be read.
    --        - entry_size_in_bits - The size of the returned slv (natural)
    --
    --  - Returns: The data from the back of the queue (slv). The size of the
    --             return data is given by the entry_size_in_bits parameter.
    --             Attempting to peek from an empty queue is allowed but triggers a
    --             TB_WARNING and returns garbage.
    --             Attempting to peek a larger value than the queue size is allowed
    --             but triggers a TB_WARNING. Will wrap.
    --
    --
    impure function peek_back(
      queue_idx          : natural;
      entry_size_in_bits : natural
    ) return std_logic_vector;

    ------------------------------------------
    -- pop_back
    ------------------------------------------
    -- This function returns the data from the back
    -- and removes the returned data from the queue.
    --
    --  - Parameters:
    --        - queue_idx          - The index of the queue (natural)
    --                               that shall be read.
    --        - entry_size_in_bits - The size of the returned slv (natural)
    --
    --  - Returns: The data from the back of the queue (slv). The size of the
    --             return data is given by the entry_size_in_bits parameter.
    --             Attempting to pop from an empty queue is allowed but triggers a
    --             TB_WARNING and returns garbage.
    --             Attempting to pop a larger value than the queue size is allowed
    --             but triggers a TB_WARNING.
    --
    --
    impure function pop_back(
      queue_idx          : natural;
      entry_size_in_bits : natural
    ) return std_logic_vector;

    ------------------------------------------
    -- pop_front
    ------------------------------------------
    -- This function returns the data from the front
    -- and removes the returned data from the queue.
    --
    --  - Parameters:
    --        - queue_idx          - The index of the queue (natural)
    --                               that shall be read.
    --        - entry_size_in_bits - The size of the returned slv (natural)
    --
    --  - Returns: The data from the front of the queue (slv). The size of the
    --             return data is given by the entry_size_in_bits parameter.
    --             Attempting to pop from an empty queue is allowed but triggers a
    --             TB_WARNING and returns garbage.
    --             Attempting to pop a larger value than the queue size is allowed
    --             but triggers a TB_WARNING.
    --
    --
    impure function pop_front(
      queue_idx          : natural;
      entry_size_in_bits : natural
    ) return std_logic_vector;

    ------------------------------------------
    -- get_count
    ------------------------------------------
    -- This function returns a natural indicating the number of elements
    -- currently occupying the buffer given by queue_idx.
    --
    --  - Parameters:
    --        - queue_idx          - The index of the queue (natural)
    --
    --  - Returns: The number of elements occupying the queue (natural).
    --
    --
    impure function get_count(
      queue_idx : natural
    ) return natural;

    ------------------------------------------
    -- get_queue_count_max
    ------------------------------------------
    -- This function returns a natural indicating the maximum number
    -- of elements that can occupy the buffer given by queue_idx.
    --
    --  - Parameters:
    --        - queue_idx          - The index of the queue (natural)
    --
    --  - Returns: The maximum number of elements that can be placed
    --             in the queue (natural).
    --
    --
    impure function get_queue_count_max(
      queue_idx : natural
    ) return natural;

    ------------------------------------------
    -- get_queue_is_full
    ------------------------------------------
    -- This function returns a boolean indicating if the
    -- queue is full or not.
    --
    --  - Parameters:
    --        - queue_idx          - The index of the queue (natural)
    --
    --  - Returns: TRUE if queue is full, FALSE if not.
    --
    --
    impure function get_queue_is_full(
      queue_idx : natural
    ) return boolean;

    ------------------------------------------
    -- deallocate_buffer
    ------------------------------------------
    -- This procedure resets the entire std_logic_vector and all
    -- variable arrays related to the buffer, effectively removing all queues.
    --
    --  - Parameters:
    --        - dummy - VOID
    --
    --
    procedure deallocate_buffer(
      dummy : t_void
    );

  end protected;

end package data_queue_pkg;

package body data_queue_pkg is

  type t_data_queue is protected body
    -- Internal variables for the data queue
    -- The buffer is one large std_logic_vector of size C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER.
    -- There are several queues that can be instantiated in the slv.
    -- There is one set of variables per queue.

    variable priv_queue_initialized  : t_buffer_boolean_array := (others => false);
    variable priv_queue_size_in_bits : t_buffer_natural_array := (others => 0);
    variable priv_count              : t_buffer_natural_array := (others => 0);

    -- min_idx/max idx: These variables set the upper and lower limit of each queue in the buffer.
    --                  This is how the large slv buffer is divided into several smaller queues.
    --                  After a queue has been instantiated, all queue operations in the buffer
    --                  for a given idx will happen within the priv_min_idx and priv_max_idx boundary.
    --                  These variables will be set when a queue is instantiated, and will not
    --                  change afterwards.
    variable priv_min_idx : t_buffer_natural_array := (others => 0);
    variable priv_max_idx : t_buffer_natural_array := (others => 0);

    variable priv_next_available_idx : natural := 0; -- Where the priv_min_idx of the next queue initialized shall be set.

    -- first_idx/last_idx: These variables set the current indices within a queue, i.e., within
    --                     the min_idx/max_idx boundary. These variables will change every time
    --                     a given queue has data pushed or popped.
    variable priv_first_idx : t_buffer_natural_array := (others => 0);
    variable priv_last_idx  : t_buffer_natural_array := (others => 0);

    type t_string_pointer is access string;
    variable priv_scope : t_string_pointer := NULL;

    ------------------------------------------
    -- init_queue
    ------------------------------------------
    impure function init_queue(
      queue_size_in_bits : natural;
      scope              : string := "data_queue"
    ) return natural is
      variable v_queue_idx       : natural;
      variable v_queue_idx_found : boolean := false;
    begin
      if priv_scope = NULL then
        priv_scope := new string'(scope);
      end if;

      if not check_value(priv_next_available_idx < C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER, TB_ERROR,
                           "init_queue called, but no more space in buffer!", priv_scope.all, ID_NEVER) then
        return 0;
      end if;

      -- Find first available queue
      -- and tag as initialized
      for i in t_buffer_boolean_array'range loop
        if not priv_queue_initialized(i) then
          -- Save queue idx
          v_queue_idx                      := i;
          v_queue_idx_found                := true;
          -- Tag this queue as initialized
          priv_queue_initialized(v_queue_idx) := true;
          exit;                         -- exit loop
        end if;
      end loop;

      -- Verify that an available queue idx was found, else trigger alert and return 0
      if not check_value(v_queue_idx_found, TB_ERROR,
                           "init_queue called, but all queues have already been initialized!", priv_scope.all, ID_NEVER) then
        return 0;
      end if;

      -- Set buffer size for this buffer to queue_size_in_bits
      if queue_size_in_bits <= (C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER - 1) - (priv_next_available_idx - 1) then -- less than or equal to the remaining total buffer space available
        priv_queue_size_in_bits(v_queue_idx) := queue_size_in_bits;
      else
        alert(TB_ERROR, "queue_size_in_bits larger than maximum allowed!", priv_scope.all);
        priv_queue_size_in_bits(v_queue_idx) := (C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER - 1) - priv_next_available_idx; -- Set to remaining available bits
      end if;

      -- Set starting and ending indices for this queue_idx
      priv_min_idx(v_queue_idx)   := priv_next_available_idx;
      priv_max_idx(v_queue_idx)   := priv_min_idx(v_queue_idx) + priv_queue_size_in_bits(v_queue_idx) - 1;
      priv_first_idx(v_queue_idx) := priv_min_idx(v_queue_idx);
      priv_last_idx(v_queue_idx)  := priv_min_idx(v_queue_idx);

      priv_next_available_idx := priv_max_idx(v_queue_idx) + 1;

      log(ID_UVVM_DATA_QUEUE, "Queue " & to_string(v_queue_idx) & " initialized with buffer size " & to_string(priv_queue_size_in_bits(v_queue_idx)) & ".", priv_scope.all);

      -- Clear the buffer just to be sure
      flush(v_queue_idx);

      -- Return the index of the buffer
      return v_queue_idx;
    end function;

    ------------------------------------------
    -- init_queue
    ------------------------------------------
    procedure init_queue(
      queue_idx          : natural;
      queue_size_in_bits : natural;
      scope              : string := "data_queue"
    ) is
    begin
      if priv_scope = NULL then
        priv_scope := new string'(scope);
      end if;
      if not priv_queue_initialized(queue_idx) then

        -- Set buffer size for this buffer to queue_size_in_bits
        if queue_size_in_bits <= (C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER - 1) - (priv_next_available_idx - 1) then -- less than or equal to the remaining total buffer space available
          priv_queue_size_in_bits(queue_idx) := queue_size_in_bits;
        else
          alert(TB_ERROR, "queue_size_in_bits larger than maximum allowed!", priv_scope.all);
          priv_queue_size_in_bits(queue_idx) := (C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER - 1) - priv_next_available_idx; -- Set to remaining available bits
        end if;

        -- Set starting and ending indices for this queue_idx
        priv_min_idx(queue_idx)   := priv_next_available_idx;
        priv_max_idx(queue_idx)   := priv_min_idx(queue_idx) + priv_queue_size_in_bits(queue_idx) - 1;
        priv_first_idx(queue_idx) := priv_min_idx(queue_idx);
        priv_last_idx(queue_idx)  := priv_min_idx(queue_idx);

        priv_next_available_idx := priv_max_idx(queue_idx) + 1;

        -- Tag this buffer as initialized
        priv_queue_initialized(queue_idx) := true;

        log(ID_UVVM_DATA_QUEUE, "Queue " & to_string(queue_idx) & " initialized with buffer size " & to_string(priv_queue_size_in_bits(queue_idx)) & ".", priv_scope.all);

        -- Clear the buffer just to be sure
        flush(queue_idx);
      else
        alert(TB_ERROR, "init_queue called, but the desired buffer index is already in use! No action taken.", priv_scope.all);
        return;
      end if;
    end procedure;

    ------------------------------------------
    -- push_back
    ------------------------------------------
    procedure push_back(
      queue_idx : natural;
      data      : std_logic_vector
    ) is
      alias a_data : std_logic_vector(data'length - 1 downto 0) is data;
    begin
      if check_value(priv_queue_initialized(queue_idx), TB_ERROR,
                       "push_back called, but queue " & to_string(queue_idx) & " not initialized.", priv_scope.all, ID_NEVER) then
        for i in a_data'right to a_data'left loop -- From right to left since LSB shall be first in the queue.
          shared_data_buffer(priv_last_idx(queue_idx)) := a_data(i);

          if priv_last_idx(queue_idx) /= priv_max_idx(queue_idx) then
            priv_last_idx(queue_idx) := priv_last_idx(queue_idx) + 1;
          else
            priv_last_idx(queue_idx) := priv_min_idx(queue_idx);
          end if;
          priv_count(queue_idx) := priv_count(queue_idx) + 1;
        end loop;

        log(ID_UVVM_DATA_QUEUE, "Data " & to_string(data, HEX) & " pushed to back of queue " & to_string(queue_idx) & " (index " & to_string(priv_last_idx(queue_idx)) & "). Fill level is " & to_string(priv_count(queue_idx)) & "/" & to_string(priv_queue_size_in_bits(queue_idx)) & ".", priv_scope.all);
      end if;
    end procedure;

    ------------------------------------------
    -- flush
    ------------------------------------------
    procedure flush(
      queue_idx : natural
    ) is
    begin
      check_value(priv_queue_initialized(queue_idx), TB_WARNING, "flush called, but queue " & to_string(queue_idx) & " not initialized.", priv_scope.all, ID_NEVER);

      shared_data_buffer(priv_max_idx(queue_idx) downto priv_min_idx(queue_idx)) := (others => '0');
      priv_first_idx(queue_idx)                                               := priv_min_idx(queue_idx);
      priv_last_idx(queue_idx)                                                := priv_min_idx(queue_idx);
      priv_count(queue_idx)                                                   := 0;
    end procedure;

    ------------------------------------------
    -- peek_front
    ------------------------------------------
    impure function peek_front(
      queue_idx          : natural;
      entry_size_in_bits : natural
    ) return std_logic_vector is
      variable v_return_entry : std_logic_vector(entry_size_in_bits - 1 downto 0) := (others => '0');
      variable v_current_idx  : natural;
    begin
      check_value(priv_queue_initialized(queue_idx), TB_ERROR, "peek_front() called, but queue " & to_string(queue_idx) & " not initialized.", priv_scope.all, ID_NEVER);
      check_value(priv_count(queue_idx) > 0, TB_WARNING, "peek_front() when queue " & to_string(queue_idx) & " is empty. Return value will be garbage.", priv_scope.all, ID_NEVER);
      check_value(entry_size_in_bits <= priv_queue_size_in_bits(queue_idx), TB_WARNING, "peek_front called, but entry size is larger than buffer size!", priv_scope.all, ID_NEVER);

      v_current_idx := priv_first_idx(queue_idx);

      -- Generate return value
      for i in 0 to v_return_entry'length - 1 loop
        v_return_entry(i) := shared_data_buffer(v_current_idx);

        if v_current_idx < priv_max_idx(queue_idx) then
          v_current_idx := v_current_idx + 1;
        else
          v_current_idx := priv_min_idx(queue_idx);
        end if;
      end loop;

      return v_return_entry;
    end function;

    ------------------------------------------
    -- peek_back
    ------------------------------------------
    impure function peek_back(
      queue_idx          : natural;
      entry_size_in_bits : natural
    ) return std_logic_vector is
      variable v_return_entry : std_logic_vector(entry_size_in_bits - 1 downto 0) := (others => '0');
      variable v_current_idx  : natural;
    begin
      check_value(priv_queue_initialized(queue_idx), TB_ERROR, "peek_back called, but queue not initialized.", priv_scope.all, ID_NEVER);
      check_value(priv_count(queue_idx) > 0, TB_WARNING, "peek_back() when queue " & to_string(queue_idx) & " is empty. Return value will be garbage.", priv_scope.all, ID_NEVER);
      check_value(entry_size_in_bits <= priv_queue_size_in_bits(queue_idx), TB_WARNING, "peek_back called, but entry size is larger than buffer size!", priv_scope.all, ID_NEVER);

      if priv_last_idx(queue_idx) > 0 then
        v_current_idx := priv_last_idx(queue_idx) - 1;
      else
        v_current_idx := priv_max_idx(queue_idx);
      end if;

      -- Generate return value
      for i in v_return_entry'length - 1 downto 0 loop
        v_return_entry(i) := shared_data_buffer(v_current_idx);

        if v_current_idx > priv_min_idx(queue_idx) then
          v_current_idx := v_current_idx - 1;
        else
          v_current_idx := priv_max_idx(queue_idx);
        end if;
      end loop;

      return v_return_entry;
    end function;

    ------------------------------------------
    -- pop_back
    ------------------------------------------
    impure function pop_back(
      queue_idx          : natural;
      entry_size_in_bits : natural
    ) return std_logic_vector is
      variable v_return_entry : std_logic_vector(entry_size_in_bits - 1 downto 0);
      variable v_current_idx  : natural;
    begin
      check_value(priv_queue_initialized(queue_idx), TB_ERROR, "pop_back called, but queue " & to_string(queue_idx) & " not initialized.", priv_scope.all, ID_NEVER);
      check_value(entry_size_in_bits <= priv_queue_size_in_bits(queue_idx), TB_WARNING, "pop_back called, but entry size is larger than buffer size!", priv_scope.all, ID_NEVER);

      if priv_queue_initialized(queue_idx) then
        v_return_entry := peek_back(queue_idx, entry_size_in_bits);

        if priv_count(queue_idx) > 0 then
          if priv_last_idx(queue_idx) > priv_min_idx(queue_idx) then
            v_current_idx := priv_last_idx(queue_idx) - 1;
          else
            v_current_idx := priv_max_idx(queue_idx);
          end if;

          -- Clear fields that belong to the return value
          for i in 0 to entry_size_in_bits - 1 loop
            shared_data_buffer(v_current_idx) := '0';

            if v_current_idx > priv_min_idx(queue_idx) then
              v_current_idx := v_current_idx - 1;
            else
              v_current_idx := priv_max_idx(queue_idx);
            end if;

            priv_count(queue_idx) := priv_count(queue_idx) - 1;
          end loop;

          -- Set last idx
          if v_current_idx < priv_max_idx(queue_idx) then
            priv_last_idx(queue_idx) := v_current_idx + 1;
          else
            priv_last_idx(queue_idx) := priv_min_idx(queue_idx);
          end if;
        end if;
      end if;

      return v_return_entry;
    end function;

    ------------------------------------------
    -- pop_front
    ------------------------------------------
    impure function pop_front(
      queue_idx          : natural;
      entry_size_in_bits : natural
    ) return std_logic_vector is
      variable v_return_entry : std_logic_vector(entry_size_in_bits - 1 downto 0);
      variable v_current_idx  : natural := priv_first_idx(queue_idx);
    begin
      check_value(entry_size_in_bits <= priv_queue_size_in_bits(queue_idx), TB_WARNING, "pop_front called, but entry size is larger than buffer size!", priv_scope.all, ID_NEVER);

      if check_value(priv_queue_initialized(queue_idx), TB_ERROR,
                       "pop_front called, but queue " & to_string(queue_idx) & " not initialized.", priv_scope.all, ID_NEVER) then
        v_return_entry := peek_front(queue_idx, entry_size_in_bits);

        if priv_count(queue_idx) > 0 then
          -- priv_first_idx points to the idx PREVIOUS to the first element in the buffer.
          -- Therefore must correct if at max_idx.
          v_current_idx := priv_first_idx(queue_idx);

          -- Clear fields that belong to the return value
          for i in 0 to entry_size_in_bits - 1 loop
            shared_data_buffer(v_current_idx) := '0';

            if v_current_idx < priv_max_idx(queue_idx) then
              v_current_idx := v_current_idx + 1;
            else
              v_current_idx := priv_min_idx(queue_idx);
            end if;

            priv_count(queue_idx) := priv_count(queue_idx) - 1;
          end loop;

          priv_first_idx(queue_idx) := v_current_idx;
        end if;

        return v_return_entry;
      end if;

      v_return_entry := (others => '0');
      return v_return_entry;
    end function;

    ------------------------------------------
    -- get_count
    ------------------------------------------
    impure function get_count(
      queue_idx : natural
    ) return natural is
    begin
      check_value(priv_queue_initialized(queue_idx), TB_WARNING, "get_count called, but queue " & to_string(queue_idx) & " not initialized.", priv_scope.all, ID_NEVER);
      return priv_count(queue_idx);
    end function;

    ------------------------------------------
    -- get_queue_count_max
    ------------------------------------------
    impure function get_queue_count_max(
      queue_idx : natural
    ) return natural is
    begin
      check_value(priv_queue_initialized(queue_idx), TB_WARNING, "get_queue_count_max called, but queue " & to_string(queue_idx) & " not initialized.", priv_scope.all, ID_NEVER);
      return priv_queue_size_in_bits(queue_idx);
    end function;

    ------------------------------------------
    -- get_queue_is_full
    ------------------------------------------
    impure function get_queue_is_full(
      queue_idx : natural
    ) return boolean is
    begin
      check_value(priv_queue_initialized(queue_idx), TB_WARNING, "get_queue_is_full called, but queue " & to_string(queue_idx) & " not initialized.", priv_scope.all, ID_NEVER);
      if priv_count(queue_idx) >= priv_queue_size_in_bits(queue_idx) then
        return true;
      else
        return false;
      end if;
    end function;

    ------------------------------------------
    -- deallocate_buffer
    ------------------------------------------
    procedure deallocate_buffer(
      dummy : t_void
    ) is
    begin
      shared_data_buffer := (others => '0');

      priv_queue_initialized  := (others => false);
      priv_queue_size_in_bits := (others => 0);
      priv_count              := (others => 0);
      priv_min_idx            := (others => 0);
      priv_max_idx            := (others => 0);
      priv_first_idx          := (others => 0);
      priv_last_idx           := (others => 0);

      priv_next_available_idx := 0;

      log(ID_UVVM_DATA_QUEUE, "Buffer has been deallocated, i.e., all queues removed.", priv_scope.all);
    end procedure;

  end protected body;

end package body data_queue_pkg;

