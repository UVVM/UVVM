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

-- WARNING! This package will be deprecated and no longer receive updates or bug fixes!
-- The generic_queue_pkg in uvvm_util/src/generic_queue_pkg.vhd has replaced ti_generic_queue_pkg

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package ti_generic_queue_pkg is

  generic(type t_generic_element;
          scope                    : string  := C_SCOPE;
          GC_QUEUE_COUNT_MAX       : natural := 1000;
          GC_QUEUE_COUNT_THRESHOLD : natural := 950);

  -- When find_* doesn't find a match, they return C_NO_MATCH.
  constant C_NO_MATCH : integer := -1;

  -- A generic queue for verification
  type t_generic_queue is protected

    procedure add(
      constant instance : in integer;
      constant element  : in t_generic_element);

    procedure add(
      constant element : in t_generic_element);

    procedure put(
      constant instance : in integer;
      constant element  : in t_generic_element);

    procedure put(
      constant element : in t_generic_element);

    impure function get(
      constant instance : in integer)
    return t_generic_element;

    impure function get(
      constant dummy : in t_void)
    return t_generic_element;

    impure function is_empty(
      constant instance : in integer)
    return boolean;

    impure function is_empty(
      constant dummy : in t_void)
    return boolean;

    procedure set_scope(
      constant instance : in integer;
      constant scope    : in string);

    procedure set_scope(
      constant scope : in string);

    procedure set_name(
      constant name : in string);

    impure function get_scope(
      constant instance : in integer)
    return string;

    impure function get_scope(
      constant dummy : in t_void)
    return string;

    impure function get_count(
      constant instance : in integer)
    return natural;

    impure function get_count(
      constant dummy : in t_void)
    return natural;

    procedure set_queue_count_threshold(
      constant instance                : in integer;
      constant queue_count_alert_level : in natural);

    procedure set_queue_count_threshold(
      constant queue_count_alert_level : in natural);

    impure function get_queue_count_threshold(
      constant instance : in integer) return natural;

    impure function get_queue_count_threshold(
      constant dummy : in t_void) return natural;

    impure function get_queue_count_threshold_severity(
      constant dummy : in t_void) return t_alert_level;

    procedure set_queue_count_threshold_severity(
      constant alert_level : in t_alert_level);

    impure function get_queue_count_max(
      constant instance : in integer) return natural;

    impure function get_queue_count_max(
      constant dummy : in t_void) return natural;

    procedure set_queue_count_max(
      constant instance        : in integer;
      constant queue_count_max : in natural);

    procedure set_queue_count_max(
      constant queue_count_max : in natural);

    procedure flush(
      constant instance : in integer);

    procedure flush(
      constant dummy : in t_void);

    procedure reset(
      constant instance : in integer);

    procedure reset(
      constant dummy : in t_void);

    procedure insert(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant element           : in t_generic_element);

    procedure insert(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant element           : in t_generic_element);

    procedure delete(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive);

    procedure delete(
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive);

    procedure delete(
      constant instance : in integer;
      constant element  : in t_generic_element
    );

    procedure delete(
      constant element : in t_generic_element
    );

    procedure delete(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option
    );

    procedure delete(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option
    );

    impure function peek(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive
    ) return t_generic_element;

    impure function peek(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive
    ) return t_generic_element;

    impure function peek(
      constant instance : in integer
    ) return t_generic_element;

    impure function peek(
      constant dummy : in t_void
    ) return t_generic_element;

    impure function fetch(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive
    ) return t_generic_element;

    impure function fetch(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive
    ) return t_generic_element;

    impure function fetch(
      constant instance : in integer
    ) return t_generic_element;

    impure function fetch(
      constant dummy : in t_void
    ) return t_generic_element;

    impure function find_position(
      constant element : in t_generic_element) return integer;

    impure function find_position(
      constant instance : in integer;
      constant element  : in t_generic_element) return integer;

    impure function find_entry_num(
      constant element : in t_generic_element) return integer;

    impure function find_entry_num(
      constant instance : in integer;
      constant element  : in t_generic_element) return integer;

    impure function exists(
      constant instance : in integer;
      constant element  : in t_generic_element
    ) return boolean;

    impure function exists(
      constant element : in t_generic_element
    ) return boolean;

    impure function get_entry_num(
      constant instance     : in integer;
      constant position_val : in positive) return integer;

    impure function get_entry_num(
      constant position_val : in positive) return integer;

    procedure print_queue(
      constant instance : in integer);

    procedure print_queue(
      constant dummy : in t_void);

  end protected;

end package ti_generic_queue_pkg;

package body ti_generic_queue_pkg is

  type t_generic_queue is protected body

    -- Types and control variables for the linked list implementation
    type t_element;
    type t_element_ptr is access t_element;
    type t_element is record
      entry_num    : natural;
      next_element : t_element_ptr;
      element_data : t_generic_element;
    end record;

    type t_element_ptr_array is array (integer range 0 to C_MAX_QUEUE_INSTANCE_NUM) of t_element_ptr;

    type t_string_array is array (integer range 0 to C_MAX_QUEUE_INSTANCE_NUM) of string(1 to C_LOG_SCOPE_WIDTH);

    variable v_last_element          : t_element_ptr_array                           := (others => null); -- Back entry
    variable v_first_element         : t_element_ptr_array                           := (others => null); -- Front entry
    variable v_num_elements_in_queue : integer_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => 0);

    -- Scope variables
    variable v_scope            : t_string_array                                := (others => (others => NUL));
    variable v_scope_is_defined : boolean_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => false);

    -- Name variables
    variable v_name            : string(1 to C_LOG_SCOPE_WIDTH) := (others => NUL);
    variable v_name_is_defined : boolean                        := false;

    variable v_queue_count_max                : integer_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => GC_QUEUE_COUNT_MAX);
    variable v_queue_count_threshold          : integer_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => GC_QUEUE_COUNT_THRESHOLD);
    variable v_queue_count_threshold_severity : t_alert_level                                 := TB_WARNING;

    variable v_entry_num : integer_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => 0); --  Incremented before first insert

    -- Fill level alert
    type t_queue_count_threshold_alert_frequency is (ALWAYS, FIRST_TIME_ONLY);
    constant C_ALERT_FREQUENCY                 : t_queue_count_threshold_alert_frequency       := FIRST_TIME_ONLY;
    variable v_queue_count_threshold_triggered : boolean_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => false);

    ------------------------------------------------------------------------------------------------------
    --
    -- Helper methods (not visible from outside)
    --
    ------------------------------------------------------------------------------------------------------

    ------------------------------------------------------------------------------------------------------
    -- Helper method: Check if an Alert shall be triggered (to be called before adding another entry)
    ------------------------------------------------------------------------------------------------------
    procedure perform_pre_add_checks(
      constant instance : in integer
    ) is
    begin
      if ((v_queue_count_threshold(instance) /= 0) and (v_num_elements_in_queue(instance) >= v_queue_count_threshold(instance))) then
        if ((C_ALERT_FREQUENCY = ALWAYS) or (C_ALERT_FREQUENCY = FIRST_TIME_ONLY and not v_queue_count_threshold_triggered(instance))) then
          alert(v_queue_count_threshold_severity, "Queue is now at " & to_string(v_queue_count_threshold(instance)) & " of " & to_string(v_queue_count_max(instance)) & " elements.", v_scope(instance));
          v_queue_count_threshold_triggered(instance) := true;
        end if;
      end if;
    end procedure;

    ------------------------------------------------------------------------------------------------------
    -- Helper method: Iterate through all entries, and match the one with element_data = element
    -- This also works if the element is a record or array, whereas all entries/indexes must match
    ------------------------------------------------------------------------------------------------------
    procedure match_element_data(
      instance            : in integer; -- Queue instance
      element             : in t_generic_element; -- Element to search for
      found_match         : out boolean; -- True if a match was found.
      matched_position    : out integer; -- valid if found_match=true
      matched_element_ptr : out t_element_ptr -- valid if found_match=true
    ) is
      variable v_position_ctr : integer := 1; -- Keep track of POSITION when traversing the linked list
      variable v_element_ptr  : t_element_ptr; -- Entry currently being checked for match
    begin
      -- Default
      found_match         := false;
      matched_position    := C_NO_MATCH;
      matched_element_ptr := null;

      if v_num_elements_in_queue(instance) > 0 then
        -- Search from front to back element
        v_element_ptr := v_first_element(instance);

        loop
          if v_element_ptr.element_data = element then -- Element matched entry
            found_match         := true;
            matched_position    := v_position_ctr;
            matched_element_ptr := v_element_ptr;
            exit;
          else                          -- No match.
            if v_element_ptr.next_element = null then
              exit;                     -- Last entry. All queue entries have been searched through.
            end if;
            v_element_ptr  := v_element_ptr.next_element; -- next queue entry
            v_position_ctr := v_position_ctr + 1;
          end if;
        end loop;
      end if;
    end procedure;

    -- Find and return entry that matches the identifier
    procedure match_identifier(
      instance              : in integer; -- Queue instance
      identifier_option     : in t_identifier_option; -- Determines what 'identifier' means
      identifier            : in positive; -- Identifier value to search for
      found_match           : out boolean; -- True if a match was found.
      matched_position      : out integer; -- valid if found_match=true
      matched_element_ptr   : out t_element_ptr; -- valid if found_match=true
      preceding_element_ptr : out t_element_ptr -- valid if found_match=true. Element at position-1, pointing to elemnt_ptr
    ) is
      -- Search from front to back element. Init pointers/counters to the first entry:
      variable v_element_ptr  : t_element_ptr := v_first_element(instance); -- Entry currently being checked for match
      variable v_position_ctr : integer       := 1; -- Keep track of POSITION when traversing the linked list
    begin
      -- Default
      found_match           := false;
      matched_position      := C_NO_MATCH;
      matched_element_ptr   := null;
      preceding_element_ptr := null;

      -- If queue is not empty and indentifier in valid range
      if (v_num_elements_in_queue(instance) > 0) and ((identifier_option = POSITION and identifier <= v_num_elements_in_queue(instance)) or (identifier_option = ENTRY_NUM and identifier <= v_entry_num(instance))) then
        loop
          -- For each element in queue:
          -- Check if POSITION or ENTRY_NUM matches v_element_ptr

          if (identifier_option = POSITION) and (v_position_ctr = identifier) then
            found_match := true;
          end if;

          if (identifier_option = ENTRY_NUM) and (v_element_ptr.entry_num = identifier) then
            found_match := true;
          end if;

          if found_match then
            -- This element matched. Done searching.
            matched_position    := v_position_ctr;
            matched_element_ptr := v_element_ptr;
            exit;
          else
            -- No match.
            if v_element_ptr.next_element = null then
              -- report "last v_position_ctr = " & to_string(v_position_ctr);
              exit;                     -- Last entry. All queue entries have been searched through.
            end if;
            preceding_element_ptr := v_element_ptr; -- the entry at the postition before element_ptr
            v_element_ptr         := v_element_ptr.next_element; -- next queue entry
            v_position_ctr        := v_position_ctr + 1;
          end if;
        end loop;                       -- for each element in queue
      end if;                           -- Not empty

    end procedure;

    ------------------------------------------------------------------------------------------------------
    --
    -- Public methods, visible from outside
    --
    ------------------------------------------------------------------------------------------------------

    -- add : Insert element in the back of queue, i.e. at the highest position
    procedure add(
      constant instance : in integer;
      constant element  : in t_generic_element
    ) is
      constant proc_name      : string := "add";
      variable v_previous_ptr : t_element_ptr;
    begin
      check_value(v_scope_is_defined(instance), TB_WARNING, proc_name & ": Scope name must be defined for this generic queue", v_scope(instance), ID_NEVER);
      perform_pre_add_checks(instance);
      check_value(v_num_elements_in_queue(instance) < v_queue_count_max(instance), TB_ERROR, proc_name & "() into generic queue (of size " & to_string(v_queue_count_max(instance)) & ") when full", v_scope(instance), ID_NEVER);

      -- Increment v_entry_num
      v_entry_num(instance) := v_entry_num(instance) + 1;

      -- Set read and write pointers when appending element to existing list
      if v_num_elements_in_queue(instance) > 0 then
        v_previous_ptr              := v_last_element(instance);
        v_last_element(instance)   := new t_element'(entry_num => v_entry_num(instance), next_element => null, element_data => element);
        v_previous_ptr.next_element := v_last_element(instance); -- Insert the new element into the linked list
      else                              -- List is empty
        v_last_element(instance)  := new t_element'(entry_num => v_entry_num(instance), next_element => null, element_data => element);
        v_first_element(instance) := v_last_element(instance); -- Update read pointer, since this is the first and only element in the list.
      end if;

      -- Increment number of elements
      v_num_elements_in_queue(instance) := v_num_elements_in_queue(instance) + 1;
    end procedure;

    procedure add(
      constant element : in t_generic_element
    ) is
    begin
      add(1, element);
    end procedure;

    procedure put(
      constant instance : in integer;
      constant element  : in t_generic_element
    ) is
    begin
      add(instance, element);
    end procedure;

    procedure put(
      constant element : in t_generic_element
    ) is
    begin
      put(1, element);
    end procedure;

    impure function get(
      constant instance : in integer
    ) return t_generic_element is
    begin
      return fetch(instance);
    end function;

    impure function get(
      constant dummy : in t_void
    ) return t_generic_element is
    begin
      return get(1);
    end function;

    procedure flush(
      constant instance : in integer
    ) is
      variable v_to_be_deallocated_ptr : t_element_ptr;
    begin
      check_value(v_scope_is_defined(instance), TB_WARNING, "Scope name must be defined for this generic queue " & to_string(instance), "???", ID_NEVER);

      -- Deallocate all entries in the list
      -- Setting the last element to null and iterating over the queue until finding the null element
      v_last_element(instance) := null;
      while v_first_element(instance) /= null loop
        v_to_be_deallocated_ptr   := v_first_element(instance);
        v_first_element(instance) := v_first_element(instance).next_element;
        DEALLOCATE(v_to_be_deallocated_ptr);
      end loop;

      -- Reset the queue counter
      v_num_elements_in_queue(instance)           := 0;
      v_queue_count_threshold_triggered(instance) := false;
    end procedure;

    procedure flush(
      constant dummy : in t_void
    ) is
    begin
      flush(1);
    end procedure;

    procedure reset(
      constant instance : in integer) is
    begin
      flush(instance);
      v_entry_num(instance) := 0;      -- Incremented before first insert
    end procedure;

    procedure reset(
      constant dummy : in t_void) is
    begin
      reset(1);
    end procedure;

    impure function is_empty(
      constant instance : in integer
    ) return boolean is
    begin
      if v_num_elements_in_queue(instance) = 0 then
        return true;
      else
        return false;
      end if;
    end function;

    impure function is_empty(
      constant dummy : in t_void
    ) return boolean is
    begin
      return is_empty(1);
    end function;

    procedure set_scope(
      constant instance : in integer;
      constant scope    : in string) is
      constant C_SCOPE_NORMALISED : string(1 to scope'length) := scope;
    begin
      if instance = ALL_INSTANCES then
        if C_SCOPE_NORMALISED'length > C_LOG_SCOPE_WIDTH then
          v_scope := (others => C_SCOPE_NORMALISED(1 to C_LOG_SCOPE_WIDTH));
        else
          for idx in v_scope'range loop
            v_scope(idx)                                 := (others => NUL);
            v_scope(idx)(1 to C_SCOPE_NORMALISED'length) := C_SCOPE_NORMALISED;
          end loop;
        end if;
        v_scope_is_defined := (others => true);
      else
        if C_SCOPE_NORMALISED'length > C_LOG_SCOPE_WIDTH then
          v_scope(instance) := C_SCOPE_NORMALISED(1 to C_LOG_SCOPE_WIDTH);
        else
          v_scope(instance)                                 := (others => NUL);
          v_scope(instance)(1 to C_SCOPE_NORMALISED'length) := C_SCOPE_NORMALISED;
        end if;
        v_scope_is_defined(instance) := true;
      end if;
    end procedure;

    procedure set_scope(
      constant scope : in string) is
    begin
      set_scope(1, scope);
    end procedure;

    procedure set_name(
      constant name : in string) is
    begin
      v_name(1 to name'length) := name;
      v_name_is_defined        := true;
    end procedure;

    impure function get_scope(
      constant instance : in integer
    ) return string is
    begin
      return to_string(v_scope(instance));
    end function;

    impure function get_scope(
      constant dummy : in t_void
    ) return string is
    begin
      return get_scope(1);
    end function;

    impure function get_count(
      constant instance : in integer
    ) return natural is
    begin
      return v_num_elements_in_queue(instance);
    end function;

    impure function get_count(
      constant dummy : in t_void
    ) return natural is
    begin
      return get_count(1);
    end function;

    impure function get_queue_count_max(
      constant instance : in integer
    ) return natural is
    begin
      return v_queue_count_max(instance);
    end function;

    impure function get_queue_count_max(
      constant dummy : in t_void
    ) return natural is
    begin
      return get_queue_count_max(1);
    end function;

    procedure set_queue_count_max(
      constant instance        : in integer;
      constant queue_count_max : in natural
    ) is
    begin
      v_queue_count_max(instance) := queue_count_max;
      check_value(v_num_elements_in_queue(instance) < v_queue_count_max(instance), TB_ERROR, "set_queue_count_max() new queue max count (" & to_string(v_queue_count_max(instance)) & ") is less than current queue count(" & to_string(v_num_elements_in_queue(instance)) & ").", v_scope(instance), ID_NEVER);
    end procedure;

    procedure set_queue_count_max(
      constant queue_count_max : in natural
    ) is
    begin
      set_queue_count_max(1, queue_count_max);
    end procedure;

    procedure set_queue_count_threshold(
      constant instance                : in integer;
      constant queue_count_alert_level : in natural
    ) is
    begin
      v_queue_count_threshold(instance) := queue_count_alert_level;
    end procedure;

    procedure set_queue_count_threshold(
      constant queue_count_alert_level : in natural
    ) is
    begin
      set_queue_count_threshold(1, queue_count_alert_level);
    end procedure;

    impure function get_queue_count_threshold(
      constant instance : in integer
    ) return natural is
    begin
      return v_queue_count_threshold(instance);
    end function;

    impure function get_queue_count_threshold(
      constant dummy : in t_void
    ) return natural is
    begin
      return get_queue_count_threshold(1);
    end function;

    impure function get_queue_count_threshold_severity(
      constant dummy : in t_void
    ) return t_alert_level is
    begin
      return v_queue_count_threshold_severity;
    end function;

    procedure set_queue_count_threshold_severity(
      constant alert_level : in t_alert_level) is
    begin
      v_queue_count_threshold_severity := alert_level;
    end procedure;

    ----------------------------------------------------
    -- Insert:
    ----------------------------------------------------
    -- Inserts element into the queue after the matching entry with specified identifier:
    --
    -- When identifier_option = POSITION:
    --   identifier = position in queue, counting from 1
    --
    -- When identifier_option = ENTRY_NUM:
    --   identifier = entry number, counting from 1
    procedure insert(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant element           : in t_generic_element) is
      constant proc_name               : string := "insert";
      variable v_element_ptr           : t_element_ptr; -- The element currently being processed
      variable v_new_element_ptr       : t_element_ptr; -- Used when creating a new element
      variable v_preceding_element_ptr : t_element_ptr; -- Used when creating a new element
      variable v_found_match           : boolean;
      variable v_matched_position      : integer;
    begin
      -- pre insert checks
      check_value(v_scope_is_defined(instance), TB_WARNING, proc_name & ": Scope name must be defined for this generic queue", v_scope(instance), ID_NEVER);
      perform_pre_add_checks(instance);
      check_value(v_num_elements_in_queue(instance) < v_queue_count_max(instance), TB_ERROR, proc_name & "() into generic queue (of size " & to_string(v_queue_count_max(instance)) & ") when full", v_scope(instance), ID_NEVER);
      check_value(v_num_elements_in_queue(instance) > 0, TB_ERROR, proc_name & "() into empty queue isn't supported. Use add() instead", v_scope(instance), ID_NEVER);
      if identifier_option = POSITION then
        check_value(v_num_elements_in_queue(instance) >= identifier, TB_ERROR, proc_name & "() into position larger than number of elements in queue. Use add() instead when inserting at the back of the queue", v_scope(instance), ID_NEVER);
      end if;

      -- Search from front to back element.
      match_identifier(
        instance              => instance,
        identifier_option     => identifier_option,
        identifier            => identifier,
        found_match           => v_found_match,
        matched_position      => v_matched_position,
        matched_element_ptr   => v_element_ptr,
        preceding_element_ptr => v_preceding_element_ptr
      );

      if v_found_match then
        -- Make new element
        v_entry_num(instance) := v_entry_num(instance) + 1; -- Increment v_entry_num

        -- POSITION: insert at matched position
        if identifier_option = POSITION then
          v_new_element_ptr := new t_element'(entry_num    => v_entry_num(instance),
                                            next_element => v_element_ptr,
                                            element_data => element);
          -- if match is first element
          if v_preceding_element_ptr = null then
            v_first_element(instance) := v_new_element_ptr; -- Insert the new element into the front of the linked list
          else
            v_preceding_element_ptr.next_element := v_new_element_ptr; -- Insert the new element into the linked list
          end if;

        --ENTRY_NUM: insert at position after match
        else
          v_new_element_ptr          := new t_element'(entry_num    => v_entry_num(instance),
                                            next_element => v_element_ptr.next_element,
                                            element_data => element);
          v_element_ptr.next_element := v_new_element_ptr; -- Insert the new element into the linked list
        end if;
        v_num_elements_in_queue(instance) := v_num_elements_in_queue(instance) + 1; -- Increment number of elements
      elsif identifier_option = ENTRY_NUM then
        if (v_num_elements_in_queue(instance) > 0) then -- if not already reported tb_error due to empty
          tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " & "instance=" & to_string(instance) & ", identifier_option=" & t_identifier_option'image(identifier_option) & ", identifier=" & to_string(identifier) & ", element...", scope);
        end if;
      end if;

    end procedure;

    procedure insert(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant element           : in t_generic_element) is
    begin
      insert(1, identifier_option, identifier, element);
    end procedure;

    ----------------------------------------------------
    -- delete:
    ----------------------------------------------------
    -- Read and remove the entry matching the identifier
    --
    -- When identifier_option = POSITION:
    --   identifier = position in queue, counting from 1
    --
    -- When identifier_option = ENTRY_NUM:
    --   identifier = entry number, counting from 1
    procedure delete(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive
    ) is
      constant proc_name               : string := "delete";
      variable v_matched_element_ptr   : t_element_ptr; -- The element being deleted
      variable v_element_to_delete_ptr : t_element_ptr; -- The element being deleted
      variable v_matched_element_data  : t_generic_element; -- Return value
      variable v_preceding_element_ptr : t_element_ptr;
      variable v_matched_position      : integer;
      variable v_found_match           : boolean;
      variable v_deletes_remaining     : integer;
    begin
      check_value(v_scope_is_defined(instance), TB_WARNING, proc_name & ": Scope name must be defined for this generic queue", v_scope(instance), ID_NEVER);

      if (v_num_elements_in_queue(instance) < v_queue_count_threshold(instance)) then
        -- reset alert trigger if set
        v_queue_count_threshold_triggered(instance) := false;
      end if;

      -- delete based on POSITION :
      -- Note that when deleting the first position, all above positions are decremented by one.
      -- Find the identifier_min, delete it, and following next_element until we reach number of positions to delete
      if (identifier_option = POSITION) then
        check_value(v_num_elements_in_queue(instance) >= identifier_max, TB_ERROR, proc_name & " where identifier_max > generic queue size", v_scope(instance), ID_NEVER);
        check_value(identifier_max >= identifier_min, TB_ERROR, "Check that identifier_max >= identifier_min", v_scope(instance), ID_NEVER);
        v_deletes_remaining := 1 + identifier_max - identifier_min;

        -- Find min position
        match_identifier(
          instance              => instance,
          identifier_option     => identifier_option,
          identifier            => identifier_min,
          found_match           => v_found_match,
          matched_position      => v_matched_position,
          matched_element_ptr   => v_matched_element_ptr,
          preceding_element_ptr => v_preceding_element_ptr
        );

        if v_found_match then
          v_element_to_delete_ptr := v_matched_element_ptr; -- Delete element at identifier_min first

          while v_deletes_remaining > 0 loop

            -- Update pointer to the element about to be removed.
            if (v_preceding_element_ptr = null) then -- Removing the first entry,
              v_first_element(instance) := v_first_element(instance).next_element;
            else                        -- Removing an intermediate or last entry
              v_preceding_element_ptr.next_element := v_element_to_delete_ptr.next_element;
              -- If the element is the last entry, update v_last_element
              if v_element_to_delete_ptr.next_element = null then
                v_last_element(instance) := v_preceding_element_ptr;
              end if;
            end if;

            -- Decrement number of elements
            v_num_elements_in_queue(instance) := v_num_elements_in_queue(instance) - 1;

            -- Memory management
            DEALLOCATE(v_element_to_delete_ptr);

            v_deletes_remaining := v_deletes_remaining - 1;

            -- Prepare next iteration:
            -- Next element to delete:
            if v_deletes_remaining > 0 then
              if (v_preceding_element_ptr = null) then
                -- We just removed the first entry, so there's no pointer from a preceding entry. Next to delete is the first entry.
                v_element_to_delete_ptr := v_first_element(instance);
              else                      -- Removed an intermediate or last entry. Next to delete is the pointer from the preceding element
                v_element_to_delete_ptr := v_preceding_element_ptr.next_element;
              end if;
            end if;
          end loop;

        else                            -- v_found_match
          if (v_num_elements_in_queue(instance) > 0) then -- if not already reported tb_error due to empty
            tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " & "instance=" & to_string(instance) & ", identifier_option=" & t_identifier_option'image(identifier_option) & ", identifier_min=" & to_string(identifier_min) & ", identifier_max=" & to_string(identifier_max) & ", non-matching identifier=" & to_string(identifier_min), scope);
          end if;
        end if;                         -- v_found_match

      -- delete based on ENTRY_NUM :
      -- Unlike position, an entry's Entry_num is stable when deleting other entries
      -- Entry_num is not necessarily increasing as we follow next_element pointers.
      -- This means that we must do a complete search for each entry we want to delete
      elsif (identifier_option = ENTRY_NUM) then
        check_value(v_entry_num(instance) >= identifier_max, TB_ERROR, proc_name & " where identifier_max > highest entry number", v_scope(instance), ID_NEVER);
        check_value(identifier_max >= identifier_min, TB_ERROR, "Check that identifier_max >= identifier_min", v_scope(instance), ID_NEVER);

        v_deletes_remaining := 1 + identifier_max - identifier_min;

        -- For each entry to delete, find it based on entry_num , then delete it
        for identifier in identifier_min to identifier_max loop
          match_identifier(
            instance              => instance,
            identifier_option     => identifier_option,
            identifier            => identifier,
            found_match           => v_found_match,
            matched_position      => v_matched_position,
            matched_element_ptr   => v_matched_element_ptr,
            preceding_element_ptr => v_preceding_element_ptr
          );

          if v_found_match then
            v_element_to_delete_ptr := v_matched_element_ptr;

            -- Update pointer to the element about to be removed.
            if (v_preceding_element_ptr = null) then -- Removing the first entry,
              v_first_element(instance) := v_first_element(instance).next_element;
            else                        -- Removing an intermediate or last entry
              v_preceding_element_ptr.next_element := v_element_to_delete_ptr.next_element;
              -- If the element is the last entry, update v_last_element
              if v_element_to_delete_ptr.next_element = null then
                v_last_element(instance) := v_preceding_element_ptr;
              end if;
            end if;

            -- Decrement number of elements
            v_num_elements_in_queue(instance) := v_num_elements_in_queue(instance) - 1;

            -- Memory management
            DEALLOCATE(v_element_to_delete_ptr);

          else                          -- v_found_match
            if (v_num_elements_in_queue(instance) > 0) then -- if not already reported tb_error due to empty
              tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " & "instance=" & to_string(instance) & ", identifier_option=" & t_identifier_option'image(identifier_option) & ", identifier_min=" & to_string(identifier_min) & ", identifier_max=" & to_string(identifier_max) & ", non-matching identifier=" & to_string(identifier), scope);
            end if;
          end if;                       -- v_found_match

        end loop;

      end if;                           -- identifier_option

    end procedure;

    procedure delete(
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive
    ) is
    begin
      delete(1, identifier_option, identifier_min, identifier_max);
    end procedure;

    procedure delete(
      constant instance : in integer;
      constant element  : in t_generic_element
    ) is
      variable v_entry_num : integer := find_entry_num(element);
    begin
      delete(instance, ENTRY_NUM, v_entry_num, v_entry_num);
    end procedure;

    procedure delete(
      constant element : in t_generic_element
    ) is
    begin
      delete(1, element);
    end procedure;

    procedure delete(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option
    ) is
    begin
      case range_option is
        when SINGLE =>
          delete(instance, identifier_option, identifier, identifier);
        when AND_LOWER =>
          delete(instance, identifier_option, 1, identifier);
        when AND_HIGHER =>
          if identifier_option = POSITION then
            delete(instance, identifier_option, identifier, v_num_elements_in_queue(instance));
          elsif identifier_option = ENTRY_NUM then
            delete(instance, identifier_option, identifier, v_entry_num(instance));
          end if;
      end case;
    end procedure;

    procedure delete(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option
    ) is
    begin
      delete(1, identifier_option, identifier, range_option);
    end procedure;

    ----------------------------------------------------
    -- peek:
    ----------------------------------------------------
    -- Read the entry matching the identifier, but don't remove it.
    --
    -- When identifier_option = POSITION:
    --   identifier = position in queue, counting from 1
    --
    -- When identifier_option = ENTRY_NUM:
    --   identifier = entry number, counting from 1
    impure function peek(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive
    ) return t_generic_element is
      constant proc_name               : string  := "peek";
      variable v_matched_element_data  : t_generic_element; -- Return value
      variable v_matched_element_ptr   : t_element_ptr; -- The element currently being processed
      variable v_preceding_element_ptr : t_element_ptr;
      variable v_matched_position      : integer; -- Keep track of POSITION when traversing the linked list
      variable v_found_match           : boolean := false;
    begin
      check_value(v_scope_is_defined(instance), TB_WARNING, proc_name & ": Scope name must be defined for this generic queue", v_scope(instance), ID_NEVER);
      check_value(v_num_elements_in_queue(instance) > 0, TB_ERROR, proc_name & "() from generic queue when empty", v_scope(instance), ID_NEVER);

      match_identifier(
        instance              => instance,
        identifier_option     => identifier_option,
        identifier            => identifier,
        found_match           => v_found_match,
        matched_position      => v_matched_position,
        matched_element_ptr   => v_matched_element_ptr,
        preceding_element_ptr => v_preceding_element_ptr
      );

      if v_found_match then
        v_matched_element_data := v_matched_element_ptr.element_data;
      else
        if (v_num_elements_in_queue(instance) > 0) then -- if not already reported tb_error due to empty
          tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " & "instance=" & to_string(instance) & ", identifier_option=" & t_identifier_option'image(identifier_option) & ", identifier=" & to_string(identifier), scope);
        end if;
      end if;

      return v_matched_element_data;
    end function;

    impure function peek(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive
    ) return t_generic_element is
    begin
      return peek(1, identifier_option, identifier);
    end function;

    -- If no identifier is specified, return the oldest entry (first position)
    impure function peek(
      constant instance : in integer
    ) return t_generic_element is
    begin
      return peek(instance, POSITION, 1);
    end function;

    impure function peek(
      constant dummy : in t_void
    ) return t_generic_element is
    begin
      return peek(1);
    end function;

    ----------------------------------------------------
    -- Fetch:
    ----------------------------------------------------
    -- Read and remove the entry matching the identifier
    --
    -- When identifier_option = POSITION:
    --   identifier = position in queue, counting from 1
    --
    -- When identifier_option = ENTRY_NUM:
    --   identifier = entry number, counting from 1
    impure function fetch(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive
    ) return t_generic_element is
      constant proc_name               : string := "fetch";
      variable v_matched_element_ptr   : t_element_ptr; -- The element being fetched
      variable v_matched_element_data  : t_generic_element; -- Return value
      variable v_preceding_element_ptr : t_element_ptr;
      variable v_matched_position      : integer;
      variable v_found_match           : boolean;
    begin
      check_value(v_scope_is_defined(instance), TB_WARNING, proc_name & ": Scope name must be defined for this generic queue", v_scope(instance), ID_NEVER);
      check_value(v_num_elements_in_queue(instance) > 0, TB_ERROR, proc_name & "() from generic queue when empty", v_scope(instance), ID_NEVER);

      if (v_num_elements_in_queue(instance) < v_queue_count_threshold(instance)) then
        -- reset alert trigger if set
        v_queue_count_threshold_triggered(instance) := false;
      end if;

      match_identifier(
        instance              => instance,
        identifier_option     => identifier_option,
        identifier            => identifier,
        found_match           => v_found_match,
        matched_position      => v_matched_position,
        matched_element_ptr   => v_matched_element_ptr,
        preceding_element_ptr => v_preceding_element_ptr
      );

      if v_found_match then
        -- Keep info about element before removing it from queue
        v_matched_element_data := v_matched_element_ptr.element_data;

        -- Update pointer to the element about to be removed.
        if (v_preceding_element_ptr = null) then -- Removing the first entry,
          v_first_element(instance) := v_first_element(instance).next_element;
        else                            -- Removing an intermediate or last entry
          v_preceding_element_ptr.next_element := v_matched_element_ptr.next_element;
          -- If the element is the last entry, update v_last_element
          if v_matched_element_ptr.next_element = null then
            v_last_element(instance) := v_preceding_element_ptr;
          end if;
        end if;

        -- Decrement number of elements
        v_num_elements_in_queue(instance) := v_num_elements_in_queue(instance) - 1;

        -- Memory management
        DEALLOCATE(v_matched_element_ptr);

      else
        if (v_num_elements_in_queue(instance) > 0) then -- if not already reported tb_error due to empty
          tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " & "instance=" & to_string(instance) & ", identifier_option=" & t_identifier_option'image(identifier_option) & ", identifier=" & to_string(identifier), scope);
        end if;
      end if;

      return v_matched_element_data;
    end function;

    impure function fetch(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive
    ) return t_generic_element is
    begin
      return fetch(1, identifier_option, identifier);
    end function;

    -- If no identifier is specified, return the oldest entry (first position)
    impure function fetch(
      constant instance : in integer
    ) return t_generic_element is
    begin
      return fetch(instance, POSITION, 1);
    end function;

    impure function fetch(
      constant dummy : in t_void
    ) return t_generic_element is
    begin
      return fetch(1);
    end function;

    -- Returns position of entry if found, else C_NO_MATCH.
    impure function find_position(
      constant instance : in integer;
      constant element  : in t_generic_element --
    ) return integer is
      variable v_element_ptr      : t_element_ptr;
      variable v_matched_position : integer;
      variable v_found_match      : boolean;
    begin
      check_value(v_scope_is_defined(instance), TB_WARNING, "find_position: Scope name must be defined for this generic queue", v_scope(instance), ID_NEVER);

      -- Don't include this check, because we may want to use exists() on an empty queue.
      -- check_value(v_num_elements_in_queue(instance) > 0, TB_ERROR, "find_position() from generic queue when empty", v_scope(instance), ID_NEVER);

      match_element_data(
        instance            => instance,
        element             => element,
        found_match         => v_found_match,
        matched_position    => v_matched_position,
        matched_element_ptr => v_element_ptr
      );

      if v_found_match then
        return v_matched_position;
      else
        return C_NO_MATCH;
      end if;

    end function;

    impure function find_position(
      constant element : in t_generic_element
    ) return integer is
    begin
      return find_position(1, element);
    end function;

    impure function exists(
      constant instance : in integer;
      constant element  : in t_generic_element
    ) return boolean is
    begin
      return (find_position(instance, element) /= C_NO_MATCH);
    end function;

    impure function exists(
      constant element : in t_generic_element
    ) return boolean is
    begin
      return exists(1, element);
    end function;

    -- Returns entry number or position to entry if found, else C_NO_MATCH.
    impure function find_entry_num(
      constant instance : in integer;
      constant element  : in t_generic_element
    ) return integer is
      variable v_element_ptr      : t_element_ptr;
      variable v_matched_position : integer;
      variable v_found_match      : boolean;
    begin
      check_value(v_scope_is_defined(instance), TB_WARNING, "find_entry_num(): Scope name must be defined for this generic queue", v_scope(instance), ID_NEVER);
      check_value(v_num_elements_in_queue(instance) > 0, TB_ERROR, "find_entry_num() from generic queue when empty", v_scope(instance), ID_NEVER);

      match_element_data(
        instance            => instance,
        element             => element,
        found_match         => v_found_match,
        matched_position    => v_matched_position,
        matched_element_ptr => v_element_ptr
      );

      if v_found_match then
        return v_element_ptr.entry_num;
      else
        return C_NO_MATCH;
      end if;

    end function;

    impure function find_entry_num(
      constant element : in t_generic_element
    ) return integer is
    begin
      return find_entry_num(1, element);
    end function;

    impure function get_entry_num(
      constant instance     : in integer;
      constant position_val : in positive
    ) return integer is
      variable v_found_match           : boolean;
      variable v_matched_position      : integer;
      variable v_matched_element_ptr   : t_element_ptr;
      variable v_preceding_element_ptr : t_element_ptr;
    begin
      check_value(v_scope_is_defined(instance), TB_WARNING, "get_entry_num(): Scope name must be defined for this generic queue", v_scope(instance), ID_NEVER);
      check_value(v_num_elements_in_queue(instance) > 0, TB_ERROR, "get_entry_num() from generic queue when empty", v_scope(instance), ID_NEVER);

      match_identifier(
        instance              => instance,
        identifier_option     => POSITION,
        identifier            => position_val,
        found_match           => v_found_match,
        matched_position      => v_matched_position,
        matched_element_ptr   => v_matched_element_ptr,
        preceding_element_ptr => v_preceding_element_ptr
      );

      if v_found_match then
        return v_matched_element_ptr.entry_num;
      else
        return -1;
      end if;
    end function get_entry_num;

    impure function get_entry_num(
      constant position_val : in positive
    ) return integer is
    begin
      return get_entry_num(1, position_val);
    end function get_entry_num;

    -- for debugging:
    -- print each entry's position and entry_num
    procedure print_queue(
      constant instance : in integer
    ) is
      variable v_element_ptr     : t_element_ptr; -- The element currently being processed
      variable v_new_element_ptr : t_element_ptr; -- Used when creating a new element
      variable v_position_ctr    : natural := 1; -- Keep track of POSITION when traversing the linked list
      variable v_found_match     : boolean := false;
    begin
      -- Search from front to back element. Initalise pointers/counters to the first entry:
      v_element_ptr := v_first_element(instance);
      if v_element_ptr = NULL then
        return;                         -- Return if queue is empty
      end if;

      loop
        log(ID_UVVM_DATA_QUEUE, "Pos=" & to_string(v_position_ctr) & ", entry_num=" & to_string(v_element_ptr.entry_num), scope);

        if v_element_ptr.next_element = null then
          exit;                         -- Last entry. All queue entries have been searched through.
        end if;
        v_element_ptr  := v_element_ptr.next_element; -- next queue entry
        v_position_ctr := v_position_ctr + 1;
      end loop;

    end procedure;

    procedure print_queue(
      constant dummy : in t_void) is
    begin
      print_queue(1);
    end procedure;

  end protected body;

end package body ti_generic_queue_pkg;

