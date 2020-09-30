--================================================================================================================================
-- Copyright 2020 Bitvis
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
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.generic_sb_support_pkg.all;

package generic_sb_pkg is

  generic (type t_element;
           function element_match(received_element : t_element;
                                  expected_element : t_element) return boolean;
           function to_string_element(element : t_element) return string;
           constant sb_config_default        : t_sb_config := C_SB_CONFIG_DEFAULT;
           constant GC_QUEUE_COUNT_MAX       : natural := 1000;
           constant GC_QUEUE_COUNT_THRESHOLD : natural := 950);

  type t_generic_sb is protected

    procedure config(
      constant sb_config_array : in t_sb_config_array;
      constant msg             : in string := "");

    procedure config(
      constant instance      : in integer;
      constant sb_config     : in t_sb_config;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure config(
      constant sb_config : in t_sb_config;
      constant msg       : in string := "");

    procedure enable(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure enable(
      constant msg : in string);

    procedure enable(
      constant void : in t_void);

    procedure disable(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure disable(
      constant msg : in string);

    procedure disable(
      constant void : in t_void);

    procedure add_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant source           : in string := "";
      constant ext_proc_call    : in string := "");

    procedure add_expected(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant source           : in string := "");

    procedure add_expected(
      constant expected_element : in t_element;
      constant msg              : in string := "";
      constant source           : in string := "");

    procedure add_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant msg              : in string := "";
      constant source           : in string := "");

    procedure check_received(
      constant instance         : in integer;
      constant received_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := "");

    procedure check_received(
      constant received_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "");

    procedure check_received(
      constant instance         : in integer;
      constant received_element : in t_element;
      constant msg              : in string := "");

    procedure check_received(
      constant received_element : in t_element;
      constant msg              : in string := "");

    procedure flush(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure flush(
      constant msg : in string);

    procedure flush(
      constant void : in t_void);

    procedure reset(
      constant instance      : in integer;
      constant msg           : in string := "";
      constant ext_proc_call : in string := "");

    procedure reset(
      constant msg : in string);

    procedure reset(
      constant void : in t_void);

    impure function is_empty(
      constant instance : in integer) return boolean;

    impure function is_empty(
      constant void : in t_void) return boolean;

    impure function get_entered_count(
      constant instance : in integer) return integer;

    impure function get_entered_count(
      constant void : in t_void) return integer;

    impure function get_pending_count(
      constant instance : in integer) return integer;

    impure function get_pending_count(
      constant void : in t_void) return integer;

    impure function get_match_count(
      constant instance : in integer) return integer;

    impure function get_match_count(
      constant void : in t_void) return integer;

    impure function get_mismatch_count(
      constant instance : in integer) return integer;

    impure function get_mismatch_count(
      constant void : in t_void) return integer;

    impure function get_drop_count(
      constant instance : in integer) return integer;

    impure function get_drop_count(
      constant void : in t_void) return integer;

    impure function get_initial_garbage_count(
      constant instance : in integer) return integer;

    impure function get_initial_garbage_count(
      constant void : in t_void) return integer;

    impure function get_delete_count(
      constant instance : in integer) return integer;

    impure function get_delete_count(
      constant void : in t_void) return integer;

    impure function get_overdue_check_count(
      constant instance : in integer) return integer;

    impure function get_overdue_check_count(
      constant void : in t_void) return integer;

    procedure set_scope(
      constant scope : in string);

    impure function get_scope(
      constant void : in t_void) return string;

    procedure enable_log_msg(
      constant instance      : in integer;
      constant msg_id        : in t_msg_id;
      constant ext_proc_call : in string := "");

    procedure enable_log_msg(
      constant msg_id   : in t_msg_id);

    procedure disable_log_msg(
      constant instance      : in integer;
      constant msg_id        : in t_msg_id;
      constant ext_proc_call : in string := "");

    procedure disable_log_msg(
      constant msg_id   : in t_msg_id);

    procedure report_counters(
      constant instance      : in integer;
      constant ext_proc_call : in string := "");

    procedure report_counters(
      constant void : in t_void);

    procedure insert_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant tag_usage         : in t_tag_usage;
      constant tag               : in string;
      constant msg               : in string := "";
      constant source            : in string := "";
      constant ext_proc_call     : in string := "");

    procedure insert_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant tag_usage         : in t_tag_usage;
      constant tag               : in string;
      constant msg               : in string := "";
      constant source            : in string := "");

      procedure insert_expected(
        constant instance          : in integer;
        constant identifier_option : in t_identifier_option;
        constant identifier        : in positive;
        constant expected_element  : in t_element;
        constant msg               : in string := "";
        constant source            : in string := "");
  
      procedure insert_expected(
        constant identifier_option : in t_identifier_option;
        constant identifier        : in positive;
        constant expected_element  : in t_element;
        constant msg               : in string := "";
        constant source            : in string := "");

    procedure delete_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := "");

    procedure delete_expected(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "");

    procedure delete_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant msg              : in string := "");

    procedure delete_expected(
      constant expected_element : in t_element;
      constant msg              : in string := "");

    procedure delete_expected(
      constant instance         : in integer;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := "");

    procedure delete_expected(
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "");

    procedure delete_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive;
      constant msg               : in string := "";
      constant ext_proc_call     : in string := "");

    procedure delete_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive;
      constant msg               : in string := "");

    procedure delete_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option;
      constant msg               : in string := "";
      constant ext_proc_call     : in string := "");

    procedure delete_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option;
      constant msg               : in string := "");

    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_entry_num(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant expected_element : in t_element) return integer;

    impure function find_expected_entry_num(
      constant expected_element : in t_element) return integer;

    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_entry_num(
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_position(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_position(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_position(
      constant instance         : in integer;
      constant expected_element : in t_element) return integer;

    impure function find_expected_position(
      constant expected_element : in t_element) return integer;

    impure function find_expected_position(
      constant instance         : in integer;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function find_expected_position(
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string) return integer;

    impure function peek_expected(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return t_element;

    impure function peek_expected(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return t_element;

    impure function peek_expected(
      constant instance          : integer) return t_element;

    impure function peek_expected(
      constant void : t_void) return t_element;

    impure function peek_source(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return string;

    impure function peek_source(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return string;

    impure function peek_source(
      constant instance          : integer) return string;

    impure function peek_source(
      constant void : t_void) return string;

    impure function peek_tag(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return string;

    impure function peek_tag(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive) return string;

    impure function peek_tag(
      constant instance          : integer) return string;

    impure function peek_tag(
      constant void : t_void) return string;

    impure function fetch_expected(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := "") return t_element;

    impure function fetch_expected(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "") return t_element;

    impure function fetch_expected(
      constant instance          : integer;
      constant msg               : string := "") return t_element;

    impure function fetch_expected(
      constant msg : string) return t_element;

    impure function fetch_expected(
      constant void : t_void) return t_element;

    impure function fetch_source(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := "") return string;

    impure function fetch_source(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "") return string;

    impure function fetch_source(
      constant instance          : integer;
      constant msg               : string := "") return string;

    impure function fetch_source(
      constant msg : string) return string;

    impure function fetch_source(
      constant void : t_void) return string;

    impure function fetch_tag(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "";
      constant ext_proc_call     : string := "") return string;

    impure function fetch_tag(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := "") return string;

    impure function fetch_tag(
      constant instance          : integer;
      constant msg               : string := "") return string;

    impure function fetch_tag(
      constant msg : string) return string;

    impure function fetch_tag(
      constant void : t_void) return string;

    impure function exists(
      constant instance         : integer;
      constant expected_element : t_element;
      constant tag_usage        : t_tag_usage := NO_TAG;
      constant tag              : string      := "") return boolean;

    impure function exists(
      constant expected_element : t_element;
      constant tag_usage        : t_tag_usage := NO_TAG;
      constant tag              : string      := "") return boolean;

    impure function exists(
      constant instance         : integer;
      constant tag_usage        : t_tag_usage;
      constant tag              : string) return boolean;

    impure function exists(
      constant tag_usage        : t_tag_usage;
      constant tag              : string) return boolean;

  end protected t_generic_sb;


end package generic_sb_pkg;





package body generic_sb_pkg is

  -- SB type declaration
  type t_sb_entry is record
    expected_element : t_element;
    source           : string(1 to C_SB_SOURCE_WIDTH);
    tag              : string(1 to C_SB_TAG_WIDTH);
    entry_time       : time;
  end record;

  ---- Declaration of sb_queue_pkg used to store all entries
  --package sb_queue_pkg is new uvvm_util.generic_queue_pkg
  --generic map (
  --      t_sb_entry        => t_sb_entry,
  --      scope                    => "SB_queue",
  --      GC_QUEUE_COUNT_MAX       => GC_QUEUE_COUNT_MAX,
  --      GC_QUEUE_COUNT_THRESHOLD => GC_QUEUE_COUNT_THRESHOLD);
  --use sb_queue_pkg.all;

  type t_generic_sb is protected body


    --==================================================================================================
    -- NON PUBLIC QUEUE TYPES, VARIABLES AND METHODS 
    --==================================================================================================
    
    --------------------------------------------
    -- constants
    --------------------------------------------
    -- when find_* doesn't find a match, they return C_NO_MATCH.
    constant C_NO_MATCH : integer := -1;

    --------------------------------------------
    -- types
    --------------------------------------------
    type t_sb_element;
    type t_sb_element_ptr is access t_sb_element;
    type t_sb_element is record
      entry_num    : natural;
      next_element : t_sb_element_ptr;
      element_data : t_sb_entry;
    end record;

    type t_sb_element_ptr_array is array(integer range 0 to C_MAX_QUEUE_INSTANCE_NUM) of t_sb_element_ptr;
    type t_string_array is array(integer range 0 to C_MAX_QUEUE_INSTANCE_NUM) of string(1 to C_LOG_SCOPE_WIDTH);
    type     t_queue_count_threshold_alert_frequency is (ALWAYS, FIRST_TIME_ONLY);

    --------------------------------------------
    -- variables
    --------------------------------------------
    -- pointer arrays
    variable vr_queue_last_element          : t_sb_element_ptr_array := (others => null); -- back entry
    variable vr_queue_first_element         : t_sb_element_ptr_array := (others => null); -- front entry
    variable vr_queue_num_elements_in_queue : integer_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => 0);
    -- scopes
    variable vr_queue_scope             : t_string_array := (others => (others => NUL));
    variable vr_queue_scope_is_defined  : boolean_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => false);
    -- name
    variable vr_queue_name            : string(1 to C_LOG_SCOPE_WIDTH) := (others => NUL);
    variable vr_queue_name_is_defined : boolean                        := false;
    -- counters
    variable vr_queue_count_threshold          : integer_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => GC_QUEUE_COUNT_THRESHOLD);
    variable vr_queue_count_max                : integer_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => GC_QUEUE_COUNT_MAX);
    variable vr_queue_count_threshold_severity : t_alert_level                                 := TB_WARNING;
    variable vr_queue_entry_num : integer_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => 0); --  Incremented before first insert
    -- fill level alert
    variable vr_queue_count_threshold_triggered : boolean_vector(0 to C_MAX_QUEUE_INSTANCE_NUM) := (others => false);

    --------------------------------------------
    -- methods
    --------------------------------------------
  
    --
    -- Helper Method: Match Identifier
    --   Find and return entry that matches the identifier.
    --
    procedure priv_match_identifier (
      instance                : in  integer;              -- Queue instance
      identifier_option       : in  t_identifier_option;  -- Determines what 'identifier' means
      identifier              : in  positive;             -- Identifier value to search for
      found_match             : out boolean;              -- True if a match was found.
      matched_position        : out integer;              -- valid if found_match=true
      matched_element_ptr     : out t_sb_element_ptr;     -- valid if found_match=true
      preceding_element_ptr   : out t_sb_element_ptr      -- valid if found_match=true. Element at position-1, pointing to elemnt_ptr
    ) is
      -- Search from front to back element. Init pointers/counters to the first entry:
      variable v_element_ptr  : t_sb_element_ptr  := vr_queue_first_element(instance);  -- Entry currently being checked for match
      variable v_position_ctr : integer           := 1;                                 -- Keep track of POSITION when traversing the linked list
    begin
      -- Default
      found_match           := false;
      matched_position      := C_NO_MATCH;
      matched_element_ptr   := null;
      preceding_element_ptr := null;

      -- If queue is not empty and indentifier in valid range
      if (vr_queue_num_elements_in_queue(instance) > 0) and
         ((identifier_option = POSITION and identifier <= vr_queue_num_elements_in_queue(instance)) or
          (identifier_option = ENTRY_NUM and identifier <= vr_queue_entry_num(instance))) then
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
              exit;  -- Last entry. All queue entries have been searched through.
            end if;
            preceding_element_ptr := v_element_ptr;  -- the entry at the postition before element_ptr
            v_element_ptr         := v_element_ptr.next_element;  -- next queue entry
            v_position_ctr        := v_position_ctr + 1;
          end if;
        end loop;  -- for each element in queue
      end if; -- Not empty
    end procedure priv_match_identifier;

    --
    -- Helper Method: Perform Pre Add Checks
    --   Check if an Alert shall be triggered (to be called before adding another entry)
    --
    procedure priv_perform_pre_add_checks (
      constant instance : in integer
      ) is
    begin
      if((vr_queue_count_threshold(instance) /= 0) and (vr_queue_num_elements_in_queue(instance) >= vr_queue_count_threshold(instance))) then
        if not vr_queue_count_threshold_triggered(instance) then
          alert(vr_queue_count_threshold_severity, "Queue is now at " & to_string(vr_queue_count_threshold(instance)) & " of " & to_string(vr_queue_count_threshold(instance)) & " elements.", vr_queue_scope(instance));
          vr_queue_count_threshold_triggered(instance) := true;
        end if;
      end if;
    end procedure priv_perform_pre_add_checks;

    --
    -- Helper Method: Match Element Data.
    --   Iterate through all entries, and match the one with element_data = element.
    --   This also works if the element is a record or array, whereas all entries/indexes must match.
    --
    procedure priv_match_element_data (
      instance                : in  integer;          -- Queue instance
      element                 : in  t_sb_entry;       -- Element to search for
      found_match             : out boolean;          -- True if a match was found.
      matched_position        : out integer;          -- valid if found_match=true
      matched_element_ptr     : out t_sb_element_ptr  -- valid if found_match=true
      ) is
      variable v_position_ctr : integer := 1;         -- Keep track of POSITION when traversing the linked list
      variable v_element_ptr  : t_sb_element_ptr;     -- Entry currently being checked for match
    begin
      -- Default
      found_match         := false;
      matched_position    := C_NO_MATCH;
      matched_element_ptr := null;

      if vr_queue_num_elements_in_queue(instance) > 0 then
        -- Search from front to back element
        v_element_ptr := vr_queue_first_element(instance);

        loop
          if v_element_ptr.element_data = element then  -- Element matched entry
            found_match         := true;
            matched_position    := v_position_ctr;
            matched_element_ptr := v_element_ptr;
            exit;
          else                            -- No match.
            if v_element_ptr.next_element = null then
              exit;  -- Last entry. All queue entries have been searched through.
            end if;
            v_element_ptr  := v_element_ptr.next_element;  -- next queue entry
            v_position_ctr := v_position_ctr + 1;
          end if;
        end loop;
      end if;
    end procedure priv_match_element_data;

    --
    -- Queue is empty
    --
    impure function priv_queue_is_empty(
      constant instance : in integer
      ) return boolean is
    begin
      if vr_queue_num_elements_in_queue(instance) = 0 then
        return true;
      else
        return false;
      end if;
    end function priv_queue_is_empty;

    --
    -- Set Scope
    --
    procedure priv_set_scope(
      constant instance : in integer;
      constant scope    : in string) is
    begin
      if instance = ALL_INSTANCES then
        if scope'length > C_LOG_SCOPE_WIDTH then
          vr_queue_scope := (others => scope(1 to C_LOG_SCOPE_WIDTH));
        else
          for idx in vr_queue_scope'range loop
            vr_queue_scope(idx)                     := (others => NUL);
            vr_queue_scope(idx)(1 to scope'length)  := scope;
          end loop;
        end if;
        vr_queue_scope_is_defined := (others => true);
      else
        if scope'length > C_LOG_SCOPE_WIDTH then
          vr_queue_scope(instance) := scope(1 to C_LOG_SCOPE_WIDTH);
        else
          vr_queue_scope(instance)                    := (others =>  NUL);
          vr_queue_scope(instance)(1 to scope'length) := scope;
        end if;
        vr_queue_scope_is_defined(instance) := true;
      end if;
    end procedure priv_set_scope;


    --
    -- Add
    --
    --   Insert element in the back of queue, i.e. at the highest position
    --
    procedure priv_add(
      constant instance       : in integer;
      constant element        : in t_sb_entry
      ) is
      constant proc_name      : string := "priv_add";
      variable v_previous_ptr : t_sb_element_ptr;
    begin
      check_value(vr_queue_scope_is_defined(instance), TB_WARNING, proc_name & ": Scope name must be defined for this generic queue", vr_queue_scope(instance), ID_NEVER);
      priv_perform_pre_add_checks(instance);
      check_value(vr_queue_num_elements_in_queue(instance) < vr_queue_count_threshold(instance), TB_ERROR, proc_name & "() into generic queue (of size " & to_string(vr_queue_count_threshold(instance)) & ") when full", vr_queue_scope(instance), ID_NEVER);
  
      -- Increment vr_queue_entry_num
      vr_queue_entry_num(instance) := vr_queue_entry_num(instance)+1;
  
      -- Set read and write pointers when appending element to existing list
      if vr_queue_num_elements_in_queue(instance) > 0 then
        v_previous_ptr                := vr_queue_last_element(instance);
        vr_queue_last_element(instance) := new t_sb_element'(entry_num => vr_queue_entry_num(instance), next_element => null, element_data => element);
        v_previous_ptr.next_element   := vr_queue_last_element(instance);  -- Insert the new element into the linked list
      else                                -- List is empty
        vr_queue_last_element(instance)  := new t_sb_element'(entry_num => vr_queue_entry_num(instance), next_element => null, element_data => element);
        vr_queue_first_element(instance) := vr_queue_last_element(instance);  -- Update read pointer, since this is the first and only element in the list.
      end if;
  
      -- Increment number of elements
      vr_queue_num_elements_in_queue(instance) := vr_queue_num_elements_in_queue(instance) + 1;
    end procedure priv_add;



    --
    -- Peek
    --
    --   Read the entry matching the identifier, but don't remove it:
    --     When identifier_option = POSITION:
    --       identifier = position in queue, counting from 1
    --     When identifier_option = ENTRY_NUM:
    --       identifier = entry number, counting from 1
    --
    impure function priv_peek(
      constant instance                 : in integer;
      constant identifier_option        : in t_identifier_option;
      constant identifier               : in positive
    ) return t_sb_entry is
      constant proc_name                : string := "priv_peek";
      variable v_matched_element_data   : t_sb_entry; -- Return value
      variable v_matched_element_ptr    : t_sb_element_ptr;  -- The element currently being processed
      variable v_preceding_element_ptr  : t_sb_element_ptr;
      variable v_matched_position       : integer;  -- Keep track of POSITION when traversing the linked list
      variable v_found_match            : boolean := false;
    begin
      check_value(vr_queue_scope_is_defined(instance), TB_WARNING, 
                  proc_name & ": Scope name must be defined for this generic queue", vr_queue_scope(instance), ID_NEVER);
      check_value(vr_queue_num_elements_in_queue(instance) > 0, TB_ERROR, 
                  proc_name & "() from generic queue when empty", vr_queue_scope(instance), ID_NEVER);

      priv_match_identifier(
        instance              => instance ,
        identifier_option     => identifier_option ,
        identifier            => identifier ,
        found_match           => v_found_match ,
        matched_position      => v_matched_position ,
        matched_element_ptr   => v_matched_element_ptr ,
        preceding_element_ptr => v_preceding_element_ptr
        );

      if v_found_match then
        v_matched_element_data := v_matched_element_ptr.element_data;
      else
        if (vr_queue_num_elements_in_queue(instance) > 0) then  -- if not already reported tb_error due to empty
          tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " &
                   "instance=" & to_string(instance) &
                   ", identifier_option=" & t_identifier_option'image(identifier_option) &
                   ", identifier=" & to_string(identifier), vr_queue_scope(instance));
        end if;
      end if;

      return v_matched_element_data;
    end function priv_peek;

    -- overloading function: if no identifier is specified, return the oldest entry (first position)
    impure function priv_peek(
      constant instance : in integer
      ) return t_sb_entry is
    begin
      return priv_peek(instance, POSITION, 1);
    end function priv_peek;

    --
    -- Delete
    --
    --   Read and remove the entry matching the identifier:
    --     When identifier_option = POSITION:
    --       identifier = position in queue, counting from 1
    --     When identifier_option = ENTRY_NUM:
    --       identifier = entry number, counting from 1
    --  
    procedure priv_delete(
      constant instance                 : in integer;
      constant identifier_option        : in t_identifier_option;
      constant identifier_min           : in positive;
      constant identifier_max           : in positive
    ) is
      constant proc_name                : string := "priv_delete";
      variable v_matched_element_ptr    : t_sb_element_ptr;     -- The element being deleted
      variable v_element_to_delete_ptr  : t_sb_element_ptr;     -- The element being deleted
      variable v_matched_element_data   : t_sb_entry;           -- Return value
      variable v_preceding_element_ptr  : t_sb_element_ptr;
      variable v_matched_position       : integer;
      variable v_found_match            : boolean;
      variable v_deletes_remaining      : integer;
    begin
      check_value(vr_queue_scope_is_defined(instance), TB_WARNING, 
                  proc_name & ": Scope name must be defined for this generic queue", vr_queue_scope(instance), ID_NEVER);

      if(vr_queue_num_elements_in_queue(instance) < vr_queue_count_threshold(instance)) then
        -- reset alert trigger if set
        vr_queue_count_threshold_triggered(instance) := false;
      end if;

      -- delete based on POSITION :
      -- Note that when deleting the first position, all above positions are decremented by one.
      -- Find the identifier_min, delete it, and following next_element until we reach number of positions to delete
      if (identifier_option = POSITION) then
        check_value(vr_queue_num_elements_in_queue(instance) >= identifier_max, TB_ERROR, proc_name & " where identifier_max > generic queue size", vr_queue_scope(instance), ID_NEVER);
        check_value(identifier_max >= identifier_min, TB_ERROR, "Check that identifier_max >= identifier_min", vr_queue_scope(instance), ID_NEVER);
        v_deletes_remaining := 1 + identifier_max - identifier_min;

        -- Find min position
        priv_match_identifier(
          instance              => instance ,
          identifier_option     => identifier_option ,
          identifier            => identifier_min,
          found_match           => v_found_match ,
          matched_position      => v_matched_position ,
          matched_element_ptr   => v_matched_element_ptr ,
          preceding_element_ptr => v_preceding_element_ptr
          );

        if v_found_match then
          v_element_to_delete_ptr := v_matched_element_ptr; -- Delete element at identifier_min first

          while v_deletes_remaining > 0 loop

            -- Update pointer to the element about to be removed.
            if (v_preceding_element_ptr = null) then  -- Removing the first entry,
              vr_queue_first_element(instance) := vr_queue_first_element(instance).next_element;
            else  -- Removing an intermediate or last entry
              v_preceding_element_ptr.next_element := v_element_to_delete_ptr.next_element;
              -- If the element is the last entry, update vr_queue_last_element
              if v_element_to_delete_ptr.next_element = null then
                vr_queue_last_element(instance) := v_preceding_element_ptr;
              end if;
            end if;

            -- Decrement number of elements
            vr_queue_num_elements_in_queue(instance) := vr_queue_num_elements_in_queue(instance) - 1;

            -- Memory management
            DEALLOCATE(v_element_to_delete_ptr);

            v_deletes_remaining := v_deletes_remaining - 1;

            -- Prepare next iteration:
            -- Next element to delete:
            if v_deletes_remaining > 0 then
              if (v_preceding_element_ptr = null) then
                -- We just removed the first entry, so there's no pointer from a preceding entry. Next to delete is the first entry.
                v_element_to_delete_ptr := vr_queue_first_element(instance);
              else  -- Removed an intermediate or last entry. Next to delete is the pointer from the preceding element
                v_element_to_delete_ptr := v_preceding_element_ptr.next_element;
              end if;
            end if;
          end loop;

        else -- v_found_match
          if (vr_queue_num_elements_in_queue(instance) > 0) then  -- if not already reported tb_error due to empty
            tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " &
                     "instance=" & to_string(instance) &
                     ", identifier_option=" & t_identifier_option'image(identifier_option) &
                     ", identifier_min=" &  to_string(identifier_min) &
                     ", identifier_max=" &  to_string(identifier_max) &
                     ", non-matching identifier=" & to_string(identifier_min), vr_queue_scope(instance));
          end if;
        end if; -- v_found_match

      -- delete based on ENTRY_NUM :
      -- Unlike position, an entry's Entry_num is stable when deleting other entries
      -- Entry_num is not necessarily increasing as we follow next_element pointers.
      -- This means that we must do a complete search for each entry we want to delete
      elsif (identifier_option = ENTRY_NUM) then
        check_value(vr_queue_entry_num(instance) >= identifier_max, TB_ERROR, proc_name & " where identifier_max > highest entry number", vr_queue_scope(instance), ID_NEVER);
        check_value(identifier_max >= identifier_min, TB_ERROR, "Check that identifier_max >= identifier_min", vr_queue_scope(instance), ID_NEVER);

        v_deletes_remaining := 1 + identifier_max - identifier_min;

        -- For each entry to delete, find it based on entry_num , then delete it
        for identifier in identifier_min to identifier_max loop
          priv_match_identifier(
            instance              => instance ,
            identifier_option     => identifier_option ,
            identifier            => identifier,
            found_match           => v_found_match ,
            matched_position      => v_matched_position ,
            matched_element_ptr   => v_matched_element_ptr ,
            preceding_element_ptr => v_preceding_element_ptr
            );

          if v_found_match then
            v_element_to_delete_ptr := v_matched_element_ptr;

            -- Update pointer to the element about to be removed.
            if (v_preceding_element_ptr = null) then  -- Removing the first entry,
              vr_queue_first_element(instance) := vr_queue_first_element(instance).next_element;
            else  -- Removing an intermediate or last entry
              v_preceding_element_ptr.next_element := v_element_to_delete_ptr.next_element;
              -- If the element is the last entry, update vr_queue_last_element
              if v_element_to_delete_ptr.next_element = null then
                vr_queue_last_element(instance) := v_preceding_element_ptr;
              end if;
            end if;

            -- Decrement number of elements
            vr_queue_num_elements_in_queue(instance) := vr_queue_num_elements_in_queue(instance) - 1;

            -- Memory management
            DEALLOCATE(v_element_to_delete_ptr);

          else -- v_found_match
            if (vr_queue_num_elements_in_queue(instance) > 0) then  -- if not already reported tb_error due to empty
              tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " &
                       "instance=" & to_string(instance) &
                       ", identifier_option=" & t_identifier_option'image(identifier_option) &
                       ", identifier_min=" &  to_string(identifier_min) &
                       ", identifier_max=" &  to_string(identifier_max) &
                       ", non-matching identifier=" & to_string(identifier), vr_queue_scope(instance));
            end if;
          end if; -- v_found_match
        end loop;
      end if; -- identifier_option
    end procedure priv_delete;

    -- overload procedure: range options
    procedure priv_delete(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option
    ) is
    begin
      case range_option is
        when SINGLE =>
          priv_delete(instance, identifier_option, identifier, identifier);
        when AND_LOWER =>
          priv_delete(instance, identifier_option, 1, identifier);
        when AND_HIGHER =>
          if identifier_option = POSITION then
            priv_delete(instance, identifier_option, identifier, vr_queue_num_elements_in_queue(instance));
          elsif identifier_option = ENTRY_NUM then
            priv_delete(instance, identifier_option, identifier, vr_queue_entry_num(instance));
          end if;
      end case;
    end procedure priv_delete;

    --
    -- Get Count
    --
    impure function priv_get_count(
      constant instance : in integer
      ) return natural is
    begin
      return vr_queue_num_elements_in_queue(instance);
    end function priv_get_count;

    --
    -- Flush
    --
    procedure priv_flush(
      constant instance : in integer
      ) is
      variable v_to_be_deallocated_ptr : t_sb_element_ptr;
    begin
      check_value(vr_queue_scope_is_defined(instance), TB_WARNING, "Scope name must be defined for this generic queue " &to_string(instance), "???", ID_NEVER);

      -- Deallocate all entries in the list
      -- Setting the last element to null and iterating over the queue until finding the null element
      vr_queue_last_element(instance) := null;
      while vr_queue_first_element(instance) /= null loop
        v_to_be_deallocated_ptr        := vr_queue_first_element(instance);
        vr_queue_first_element(instance) := vr_queue_first_element(instance).next_element;
        DEALLOCATE(v_to_be_deallocated_ptr);
      end loop;

      -- Reset the queue counter
      vr_queue_num_elements_in_queue(instance)           := 0;
      vr_queue_count_threshold_triggered(instance) := false;
    end procedure priv_flush;

    --
    -- Reset
    --
    procedure priv_reset(
      constant instance : in integer) is
    begin
      priv_flush(instance);
      vr_queue_entry_num(instance) := 0; -- Incremented before first insert
    end procedure priv_reset;

    --
    -- Insert
    --
    --   Inserts element into the queue after the matching entry with specified identifier:
    --     When identifier_option = POSITION:
    --       identifier = position in queue, counting from 1
    --     When identifier_option = ENTRY_NUM:
    --       identifier = entry number, counting from 1
    --
    procedure priv_insert(
      constant instance                 : in integer;
      constant identifier_option        : in t_identifier_option;
      constant identifier               : in positive;
      constant element                  : in t_sb_entry)
    is
      constant proc_name                : string := "priv_insert";
      variable v_element_ptr            : t_sb_element_ptr;  -- The element currently being processed
      variable v_new_element_ptr        : t_sb_element_ptr;  -- Used when creating a new element
      variable v_preceding_element_ptr  : t_sb_element_ptr;  -- Used when creating a new element
      variable v_found_match            : boolean;
      variable v_matched_position       : integer;
    begin
      -- pre insert checks
      check_value(vr_queue_scope_is_defined(instance), TB_WARNING, proc_name & ": Scope name must be defined for this generic queue", vr_queue_scope(instance), ID_NEVER);
      priv_perform_pre_add_checks(instance);
      check_value(vr_queue_num_elements_in_queue(instance) < vr_queue_count_threshold(instance), TB_ERROR, proc_name & "() into generic queue (of size " & to_string(vr_queue_count_threshold(instance)) & ") when full", vr_queue_scope(instance), ID_NEVER);
      check_value(vr_queue_num_elements_in_queue(instance) > 0, TB_ERROR, proc_name & "() into empty queue isn't supported. Use add() instead", vr_queue_scope(instance), ID_NEVER);
      if identifier_option = POSITION then
        check_value(vr_queue_num_elements_in_queue(instance) >= identifier, TB_ERROR, proc_name & "() into position larger than number of elements in queue. Use add() instead when inserting at the back of the queue", vr_queue_scope(instance), ID_NEVER);
      end if;

      -- Search from front to back element.
      priv_match_identifier(
        instance              => instance ,
        identifier_option     => identifier_option ,
        identifier            => identifier ,
        found_match           => v_found_match ,
        matched_position      => v_matched_position ,
        matched_element_ptr   => v_element_ptr ,
        preceding_element_ptr => v_preceding_element_ptr
        );

      if v_found_match then
        -- Make new element
        vr_queue_entry_num(instance) := vr_queue_entry_num(instance)+1;  -- Increment vr_queue_entry_num

        -- POSITION: insert at matched position
        if identifier_option = POSITION then
          v_new_element_ptr := new t_sb_element'(entry_num    => vr_queue_entry_num(instance),
                                              next_element => v_element_ptr,
                                              element_data => element);
          -- if match is first element
          if v_preceding_element_ptr = null then
            vr_queue_first_element(instance) := v_new_element_ptr; -- Insert the new element into the front of the linked list
          else
            v_preceding_element_ptr.next_element := v_new_element_ptr;  -- Insert the new element into the linked list
          end if;

        --ENTRY_NUM: insert at position after match
        else
          v_new_element_ptr := new t_sb_element'(entry_num    => vr_queue_entry_num(instance),
                                              next_element => v_element_ptr.next_element,
                                              element_data => element);
          v_element_ptr.next_element := v_new_element_ptr;  -- Insert the new element into the linked list
        end if;
        vr_queue_num_elements_in_queue(instance) := vr_queue_num_elements_in_queue(instance) + 1;  -- Increment number of elements
      elsif identifier_option = ENTRY_NUM then
        if (vr_queue_num_elements_in_queue(instance) > 0) then  -- if not already reported tb_error due to empty
          tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " &
                   "instance=" & to_string(instance) &
                   ", identifier_option=" & t_identifier_option'image(identifier_option) &
                   ", identifier=" & to_string(identifier) &
                   ", element...", vr_queue_scope(instance));
        end if;
      end if;
    end procedure priv_insert;


    --
    -- Get Entry Number
    --
    impure function priv_get_entry_num(
      constant instance     : in integer;
      constant position_val : in positive
    ) return integer is
      variable v_found_match           : boolean;
      variable v_matched_position      : integer;
      variable v_matched_element_ptr   : t_sb_element_ptr;
      variable v_preceding_element_ptr : t_sb_element_ptr;
    begin
      check_value(vr_queue_scope_is_defined(instance), TB_WARNING, 
                  "get_entry_num(): Scope name must be defined for this generic queue", vr_queue_scope(instance), ID_NEVER);
      check_value(vr_queue_num_elements_in_queue(instance) > 0, TB_ERROR, 
                  "get_entry_num() from generic queue when empty", vr_queue_scope(instance), ID_NEVER);

      priv_match_identifier(
        instance              => instance ,
        identifier_option     => POSITION ,
        identifier            => position_val,
        found_match           => v_found_match ,
        matched_position      => v_matched_position ,
        matched_element_ptr   => v_matched_element_ptr ,
        preceding_element_ptr => v_preceding_element_ptr
      );
    
      if v_found_match then
       return v_matched_element_ptr.entry_num;
      else
        return -1;
      end if;
    end function priv_get_entry_num;

    --
    -- Fetch
    --
    --   Read and remove the entry matching the identifier:
    --     When identifier_option = POSITION:
    --       identifier = position in queue, counting from 1
    --     When identifier_option = ENTRY_NUM:
    --       identifier = entry number, counting from 1
    --
    impure function priv_fetch(
      constant instance                 : in integer;
      constant identifier_option        : in t_identifier_option;
      constant identifier               : in positive
      ) return t_sb_entry is
      constant proc_name                : string := "priv_fetch";
      variable v_matched_element_ptr    : t_sb_element_ptr;     -- The element being fetched
      variable v_matched_element_data   : t_sb_entry;           -- Return value
      variable v_preceding_element_ptr  : t_sb_element_ptr;
      variable v_matched_position       : integer;
      variable v_found_match            : boolean;
    begin
      check_value(vr_queue_scope_is_defined(instance), TB_WARNING, 
                  proc_name & ": Scope name must be defined for this generic queue", vr_queue_scope(instance), ID_NEVER);
      check_value(vr_queue_num_elements_in_queue(instance) > 0, TB_ERROR, 
                  proc_name & "() from generic queue when empty", vr_queue_scope(instance), ID_NEVER);

      if(vr_queue_num_elements_in_queue(instance) < vr_queue_count_threshold(instance)) then
        -- reset alert trigger if set
        vr_queue_count_threshold_triggered(instance) := false;
      end if;

      priv_match_identifier(
        instance              => instance ,
        identifier_option     => identifier_option ,
        identifier            => identifier ,
        found_match           => v_found_match ,
        matched_position      => v_matched_position ,
        matched_element_ptr   => v_matched_element_ptr ,
        preceding_element_ptr => v_preceding_element_ptr
        );

      if v_found_match then
        -- Keep info about element before removing it from queue
        v_matched_element_data := v_matched_element_ptr.element_data;

        -- Update pointer to the element about to be removed.
        if (v_preceding_element_ptr = null) then  -- Removing the first entry,
          vr_queue_first_element(instance) := vr_queue_first_element(instance).next_element;
        else  -- Removing an intermediate or last entry
          v_preceding_element_ptr.next_element := v_matched_element_ptr.next_element;
          -- If the element is the last entry, update vr_queue_last_element
          if v_matched_element_ptr.next_element = null then
            vr_queue_last_element(instance) := v_preceding_element_ptr;
          end if;
        end if;

        -- Decrement number of elements
        vr_queue_num_elements_in_queue(instance) := vr_queue_num_elements_in_queue(instance) - 1;
        -- Memory management
        DEALLOCATE(v_matched_element_ptr);
      else
        if (vr_queue_num_elements_in_queue(instance) > 0) then  -- if not already reported tb_error due to empty
          tb_error(proc_name & "() did not match an element in queue. It was called with the following parameters: " &
                   "instance=" & to_string(instance) &
                   ", identifier_option=" & t_identifier_option'image(identifier_option) &
                   ", identifier=" & to_string(identifier), vr_queue_scope(instance));
        end if;
      end if;

      return v_matched_element_data;
    end function priv_fetch;

    
    --==================================================================================================
    -- NON PUBLIC SCOREBOARD VARIABLES, TYPES AND METHODS
    --==================================================================================================

    --------------------------------------------
    -- variables and types
    --------------------------------------------
    -- scope
    variable vr_sb_scope            : string(1 to C_LOG_SCOPE_WIDTH) := (1 to 4 => "?_SB", others => NUL);
    -- configurations
    variable vr_config              : t_sb_config_array(0 to C_MAX_SB_INSTANCE_IDX) := (others => sb_config_default);
    -- enable
    variable vr_instance_enabled    : boolean_vector(0 to C_MAX_SB_INSTANCE_IDX)    := (others => false);
    -- msg id panel
    type t_msg_id_panel_array is array(0 to C_MAX_SB_INSTANCE_IDX) of t_msg_id_panel;
    variable vr_msg_id_panel_array  : t_msg_id_panel_array := (others => C_SB_MSG_ID_PANEL_DEFAULT);
    -- counters
    variable vr_entered_cnt         : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable vr_match_cnt           : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable vr_mismatch_cnt        : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable vr_drop_cnt            : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable vr_initial_garbage_cnt : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable vr_delete_cnt          : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);
    variable vr_overdue_check_cnt   : integer_vector(0 to C_MAX_SB_INSTANCE_IDX) := (others => -1);

    --------------------------------------------
    -- methods
    --------------------------------------------

    --
    -- Check Instance In Range
    --
    procedure priv_check_instance_in_range(
      constant instance : in integer
    ) is
    begin
      check_value_in_range(instance, 0, C_MAX_SB_INSTANCE_IDX, TB_ERROR,
          "Instance must be within range 0 to C_MAX_SB_INSTANCE_IDX, " & to_string(C_MAX_SB_INSTANCE_IDX) & ".", vr_sb_scope, ID_NEVER);
    end procedure priv_check_instance_in_range;

    --
    -- Check Instance Enabled
    --
    procedure priv_check_instance_enabled(
      constant instance : in integer
    ) is
    begin
      check_value(vr_instance_enabled(instance), TB_ERROR, "The instance is not enabled", vr_sb_scope, ID_NEVER);
    end procedure priv_check_instance_enabled;

    --
    -- Check Queue Empty
    --
    procedure priv_check_queue_empty(
      constant instance : in natural
    ) is
    begin
      check_value(not priv_queue_is_empty(instance), TB_ERROR, "The queue is empty", vr_sb_scope, ID_NEVER);
    end procedure priv_check_queue_empty;

    --
    -- Check Config Validity
    --
    procedure priv_check_config_validity(
      constant config : in t_sb_config
    ) is
    begin
      check_value(config.allow_out_of_order and config.allow_lossy, false, TB_ERROR,
        "allow_out_of_order and allow_lossy cannot both be enabled. Se documentation for how to handle both modes.", vr_sb_scope, ID_NEVER);
      check_value(config.overdue_check_time_limit >= 0 ns, TB_ERROR,
        "overdue_check_time_limit cannot be less than 0 ns.", vr_sb_scope, ID_NEVER);
    end procedure;

    --
    -- Match Received VS Entry
    --
    impure function priv_match_received_vs_entry (
      constant received_element : in t_element;
      constant sb_entry         : in t_sb_entry;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return boolean is
    begin
      -- If TAG then check if tag match
      if tag_usage = uvvm_util.types_pkg.TAG then
        if pad_string(tag, NUL, C_SB_TAG_WIDTH) /= sb_entry.tag then
          return false;
        end if;
      end if;
      return element_match(received_element, sb_entry.expected_element);
    end function priv_match_received_vs_entry;

    --
    -- Match Expected VS Entry
    --
    impure function priv_match_expected_vs_entry (
      constant expected_element : in t_element;
      constant sb_entry         : in t_sb_entry;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return boolean is
    begin
      -- If TAG then check if tag match
      if tag_usage = uvvm_util.types_pkg.TAG then
        if pad_string(tag, NUL, C_SB_TAG_WIDTH) /= sb_entry.tag then
          return false;
        end if;
      end if;
      return expected_element = sb_entry.expected_element;
    end function priv_match_expected_vs_entry;

    --
    -- Log
    --
    procedure priv_log(
      instance : natural;
      msg_id   : t_msg_id;
      msg      : string;
      scope    : string
    ) is
    begin
      if vr_msg_id_panel_array(instance)(msg_id) = ENABLED then
        log(msg_id, msg, scope, C_MSG_ID_PANEL_DEFAULT);
      end if;
    end procedure priv_log;

    --
    --  Peek Entry
    --    Used by all peek functions
    --
    impure function priv_peek_entry(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return t_sb_entry is
    begin
      -- Check that instance is in valid range and enabled
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      priv_check_queue_empty(instance);

      return priv_peek(instance, identifier_option, identifier);
    end function priv_peek_entry;


    --
    -- Fetch Entry
    --    Used by all fetch functions
    --
    impure function priv_fetch_entry(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return t_sb_entry is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      priv_check_queue_empty(instance);

      v_sb_entry := priv_fetch(instance, identifier_option, identifier);

      vr_delete_cnt(instance) := vr_delete_cnt(instance) + 1;

      return v_sb_entry;
    end function priv_fetch_entry;



    --==================================================================================================
    -- PUBLIC METHODS
    --==================================================================================================

    --
    --  Config
    --
    --    Sets config for each instance, by array or instance parameter
    --
    procedure config(
      constant sb_config_array  : in t_sb_config_array;
      constant msg              : in string := ""
    ) is
      constant proc_name        : string := "config";
    begin

      -- Check if range is within limits
      check_value(sb_config_array'low >= 0 and sb_config_array'high <= C_MAX_SB_INSTANCE_IDX, TB_ERROR,
        "Configuration array must be within range 0 to C_MAX_SB_INSTANCE_IDX, " & to_string(C_MAX_SB_INSTANCE_IDX) & ".", vr_sb_scope, ID_NEVER);

      -- Apply config to the defined range
      for i in sb_config_array'low to sb_config_array'high loop
        priv_check_config_validity(sb_config_array(i));
        priv_log(i, ID_CTRL, proc_name & "() => config applied to SB. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(i));
        vr_config(i) := sb_config_array(i);
      end loop;
    end procedure config;

    -- overload: set config for instance
    procedure config(
      constant instance       : in integer;
      constant sb_config      : in t_sb_config;
      constant msg            : in string := "";
      constant ext_proc_call  : in string := ""
    ) is
      constant proc_name      : string := "config";
    begin
      -- Sanity checks
      priv_check_instance_in_range(instance);
      priv_check_config_validity(sb_config);

      if ext_proc_call = "" then
        -- Called directly from sequencer/VVC.
        priv_log(instance, ID_CTRL, proc_name & "() => config applied to SB. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      else
        -- Called from other SB method
        priv_log(instance, ID_CTRL, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      end if;

      vr_config(instance) := sb_config;
    end procedure config;

    -- overload: set config for instance 1
    procedure config(
      constant sb_config : in t_sb_config;
      constant msg       : in string := ""
    ) is
    begin
      config(1, sb_config, msg, "config() => config applied to SB. ");
    end procedure config;


    --
    --  Enable
    --
    --    Enable one instance or all instances. Counters is set froom -1 to 0 When enabled for the
    --    first time.
    --
    procedure enable(
      constant instance       : in integer;
      constant msg            : in string := "";
      constant ext_proc_call  : in string := ""
    ) is
      constant proc_name      : string    := "enable";
    begin
      -- Check if instance is within range and not already enabled
      if instance /= ALL_INSTANCES then
        priv_check_instance_in_range(instance);
        check_value(not vr_instance_enabled(instance), TB_WARNING, "Instance " & to_string(instance) & " is already enabled", vr_sb_scope, ID_NEVER);
      end if;

      if ext_proc_call = "" then
        -- Called directly from sequencer/VVC.
        if instance = ALL_INSTANCES then
          log(ID_CTRL, proc_name & "() => all instances enabled. " & add_msg_delimiter(msg), vr_sb_scope);
        else
          priv_log(instance, ID_CTRL, proc_name & "() => SB enabled. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
      else
        -- Called from other SB method
        priv_log(instance, ID_CTRL, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      end if;

      if instance = ALL_INSTANCES then
        vr_instance_enabled := (others => true);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if vr_entered_cnt(i) = -1 then
            vr_entered_cnt(i)         := 0;
            vr_match_cnt(i)           := 0;
            vr_mismatch_cnt(i)        := 0;
            vr_drop_cnt(i)            := 0;
            vr_initial_garbage_cnt(i) := 0;
            vr_delete_cnt(i)          := 0;
            vr_overdue_check_cnt(i)   := 0;
          end if;
        end loop;
      else
        vr_instance_enabled(instance) := true;
        if vr_entered_cnt(instance) = -1 then
          vr_entered_cnt(instance)         := 0;
          vr_match_cnt(instance)           := 0;
          vr_mismatch_cnt(instance)        := 0;
          vr_drop_cnt(instance)            := 0;
          vr_initial_garbage_cnt(instance) := 0;
          vr_delete_cnt(instance)          := 0;
          vr_overdue_check_cnt(instance)   := 0;
        end if;
      end if;

      priv_set_scope(instance, "SB queue");
    end procedure enable;

    -- overload: enable instance 1
    procedure enable(
      constant msg : in string
    ) is
    begin
      enable(1, msg, "enable() => SB enabled. ");
    end procedure enable;
    
    -- overload: enable instance 1, no msg.
    procedure enable(
      constant void : in t_void
    ) is
    begin
      enable(1, "", "enable() => SB enabled. ");
    end procedure enable;


    --
    --  Disable
    --
    --    Disable one instance or all instances.
    --
    procedure disable(
      constant instance       : in integer;
      constant msg            : in string := "";
      constant ext_proc_call  : in string := ""
    ) is
      constant proc_name      : string    := "disable";
    begin
      -- Check if instance is within range and not already disabled
      if instance /= ALL_INSTANCES then
        priv_check_instance_in_range(instance);
        check_value(vr_instance_enabled(instance), TB_WARNING, "Instance " & to_string(instance) & " is already disabled", vr_sb_scope, ID_NEVER);
      end if;

      if instance = ALL_INSTANCES then
        vr_instance_enabled := (others => false);
      else
        vr_instance_enabled(instance) := false;
      end if;

      if ext_proc_call = "" then
        -- Called directly from sequencer/VVC.
        if instance = ALL_INSTANCES then
          log(ID_CTRL, proc_name & "() => all instances disabled. " & add_msg_delimiter(msg), vr_sb_scope);
        else
          priv_log(instance, ID_CTRL, proc_name & "() => SB disabled. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
      else
        -- Called from other SB method
        priv_log(instance, ID_CTRL, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      end if;
    end procedure disable;

    -- overload: disable instance 1
    procedure disable(
      constant msg : in string
    ) is
    begin
      disable(1, msg, "disable() => SB disabled. ");
    end procedure disable;

    -- overload: disable instance 1, no msg.
    procedure disable(
      constant void : in t_void
    ) is
    begin
      disable(1, "", "disable() => SB disabled. ");
    end procedure disable;


    --
    --  Add Expected
    --
    --    Adds expected element at the back of queue. Optional tag and source.
    --
    procedure add_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant source           : in string := "";
      constant ext_proc_call    : in string := ""
    ) is
      constant proc_name        : string    := "add_expected";
      variable v_sb_entry       : t_sb_entry;
    begin

      v_sb_entry := (expected_element => expected_element,
                     source           => pad_string(source, NUL, C_SB_SOURCE_WIDTH),
                     tag              => pad_string(tag, NUL, C_SB_TAG_WIDTH),
                     entry_time       => now);

      if instance = ALL_INSTANCES then
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if vr_instance_enabled(i) then
            -- add entry
            priv_add(i, v_sb_entry);
            -- increment counters
            vr_entered_cnt(i) := vr_entered_cnt(i)+1;

            if tag_usage = NO_TAG then
              priv_log(i, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) &
                ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(i));
            else
              priv_log(i, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) & ", tag: " & to_string(tag) &
              ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(i));
            end if;
          end if;
        end loop;
      else
        -- Sanity checks
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);

        -- add entry
        priv_add(instance, v_sb_entry);
        -- increment counters
        vr_entered_cnt(instance) := vr_entered_cnt(instance)+1;

        if ext_proc_call = "" then
          if tag_usage = NO_TAG then
            priv_log(instance, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) &
              ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
          else
            priv_log(instance, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) & ", tag: " & to_string(tag) &
              ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
          end if;
        else
          -- Called from other SB method
          priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
      end if;
    end procedure add_expected;

    -- overload: add expected to instance 1
    procedure add_expected(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant source           : in string := ""
    ) is
    begin
      if tag_usage = NO_TAG then
        add_expected(1, expected_element, tag_usage, tag, msg, source, "add_expected() => expected: " & to_string_element(expected_element) & ". ");
      else
        add_expected(1, expected_element, tag_usage, tag, msg, source, "add_expected() => expected: " & to_string_element(expected_element) & ", tag: " & to_string(tag) & ". ");
      end if;
    end procedure add_expected;

    -- overload: add expected with NO_TAG
    procedure add_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant msg              : in string := "";
      constant source           : in string := ""
    ) is
    begin
      add_expected(instance, expected_element, NO_TAG, "", msg, source);
    end procedure add_expected;

    -- overload: add expected with NO_TAG and no instace.
    procedure add_expected(
      constant expected_element : in t_element;
      constant msg              : in string := "";
      constant source           : in string := ""
    ) is
    begin
      add_expected(expected_element, NO_TAG, "", msg, source);
    end procedure add_expected;


    --
    --  Check Received
    --
    --    Checks received against expected. Updates counters acording to match/mismatch and configuration.
    --
    procedure check_received(
      constant instance           : in integer;
      constant received_element   : in t_element;
      constant tag_usage          : in t_tag_usage;
      constant tag                : in string;
      constant msg                : in string := "";
      constant ext_proc_call      : in string := ""
    ) is
      constant proc_name          : string    := "check_received";

      -- helper procedure
      procedure check_pending_exists(
        constant instance : in integer
      ) is
      begin
        check_value(not priv_queue_is_empty(instance), TB_ERROR, "No pending entries to check.", vr_sb_scope & "," & to_string(instance), ID_NEVER);
      end procedure check_pending_exists;

      -- helper procedure
      procedure check_received_instance(
        constant instance : in integer
      ) is
        variable v_matched     : boolean := false;
        variable v_entry       : t_sb_entry;
        variable v_dropped_num : natural := 0;
      begin
        check_pending_exists(instance);

        -- If OOB
        if vr_config(instance).allow_out_of_order then

          -- Loop through entries in queue until match
          for i in 1 to get_pending_count(instance) loop
            v_entry := priv_peek(instance, POSITION, i);
            if priv_match_received_vs_entry(received_element, v_entry, tag_usage, tag) then
              v_matched := true;

              -- Delete entry
              priv_delete(instance, POSITION, i, SINGLE);

              exit;
            end if;
          end loop;

        -- If LOSSY
        elsif vr_config(instance).allow_lossy then

          -- Loop through entries in queue until match
          for i in 1 to get_pending_count(instance) loop
            v_entry := priv_peek(instance, POSITION, i);
            if priv_match_received_vs_entry(received_element, v_entry, tag_usage, tag) then
              v_matched := true;

              -- Delete matching entry and preceding entries
              for j in i downto 1 loop
                priv_delete(instance, POSITION, j, SINGLE);
              end loop;
              v_dropped_num := i - 1;
              exit;
            end if;
          end loop;

        -- Not OOB or LOSSY
        else
          v_entry := priv_peek(instance);
          if priv_match_received_vs_entry(received_element, v_entry, tag_usage, tag) then
            v_matched := true;
            -- delete entry
            priv_delete(instance, POSITION, 1, SINGLE);
          elsif not(vr_match_cnt(instance) = 0 and vr_config(instance).ignore_initial_garbage) then
            priv_delete(instance, POSITION, 1, SINGLE);
          end if;
        end if;

        -- Update counters
        vr_drop_cnt(instance) := vr_drop_cnt(instance) + v_dropped_num;
        if v_matched then
          vr_match_cnt(instance) := vr_match_cnt(instance) + 1;
        elsif vr_match_cnt(instance) = 0 and vr_config(instance).ignore_initial_garbage then
          vr_initial_garbage_cnt(instance) := vr_initial_garbage_cnt(instance) + 1;
        else
          vr_mismatch_cnt(instance) := vr_mismatch_cnt(instance) + 1;
        end if;


        -- Check if overdue time
        if v_matched and (vr_config(instance).overdue_check_time_limit /= 0 ns) and (now-v_entry.entry_time > vr_config(instance).overdue_check_time_limit) then
          if ext_proc_call = "" then
            alert(vr_config(instance).overdue_check_alert_level, proc_name & "() => TIME LIMIT OVERDUE: time limit is " & to_string(vr_config(instance).overdue_check_time_limit) &
              ", time from entry is " & to_string(now-v_entry.entry_time) & ". " & add_msg_delimiter(msg) , vr_sb_scope & "," & to_string(instance));
          else
            alert(vr_config(instance).overdue_check_alert_level, ext_proc_call & " => TIME LIMIT OVERDUE: time limit is " & to_string(vr_config(instance).overdue_check_time_limit) &
              ", time from entry is " & to_string(now-v_entry.entry_time) & ". " & add_msg_delimiter(msg) , vr_sb_scope & "," & to_string(instance));
          end if;
          -- Update counter
          vr_overdue_check_cnt(instance) := vr_overdue_check_cnt(instance) + 1;
        end if;

        -- Logging
        if v_matched then
          if ext_proc_call = "" then
            if tag_usage = NO_TAG then
              priv_log(instance, ID_DATA, proc_name & "() => MATCH, for value: " & to_string_element(v_entry.expected_element) &
                ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
            else
              priv_log(instance, ID_DATA, proc_name & "() => MATCH, for value: " & to_string_element(v_entry.expected_element) &
                ". tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
            end if;
          -- Called from other SB method
          else
            if tag_usage = NO_TAG then
              priv_log(instance, ID_DATA, ext_proc_call & " => MATCH, for received: " & to_string_element(received_element) &
                ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
            else
              priv_log(instance, ID_DATA, ext_proc_call & " => MATCH, for received: " & to_string_element(received_element) &
                ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
            end if;
          end if;
        -- Initial garbage
        elsif not(vr_match_cnt(instance) = 0 and vr_config(instance).ignore_initial_garbage) then
          if ext_proc_call = "" then
            if tag_usage = NO_TAG then
              alert(vr_config(instance).mismatch_alert_level, proc_name & "() => MISMATCH, expected: "  & to_string_element(v_entry.expected_element) &
                "; received: " & to_string_element(received_element) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
            else
              alert(vr_config(instance).mismatch_alert_level, proc_name & "() => MISMATCH, expected: " & to_string_element(v_entry.expected_element) & ", tag: '" & to_string(v_entry.tag) &
                "'; received: " & to_string_element(received_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
            end if;
          else
            if tag_usage = NO_TAG then
              alert(vr_config(instance).mismatch_alert_level, ext_proc_call & " => MISMATCH, expected: " & to_string_element(v_entry.expected_element) &
                "; received: " & to_string_element(received_element) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
            else
              alert(vr_config(instance).mismatch_alert_level, ext_proc_call & " => MISMATCH, expected: " & to_string_element(v_entry.expected_element) & ", tag: " & to_string(v_entry.tag) &
                "; received: " & to_string_element(received_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
            end if;
          end if;
        end if;
      end procedure check_received_instance;

    begin

      if instance = ALL_INSTANCES then
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if vr_instance_enabled(i) then
            check_received_instance(i);
          end if;
        end loop;
      else
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        check_received_instance(instance);
      end if;

    end procedure check_received;

    -- overload: check received on instance 1
    procedure check_received(
      constant received_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := ""
    ) is
    begin
      check_received(1, received_element, tag_usage, tag, msg, "check_received()");
    end procedure check_received;

    -- overload: check recevied with NO_TAG
    procedure check_received(
      constant instance         : in integer;
      constant received_element : in t_element;
      constant msg              : in string := ""
    ) is
    begin
      check_received(instance, received_element, NO_TAG, "", msg);
    end procedure check_received;

    -- overload: check received with NO_TAG on instance 1
    procedure check_received(
      constant received_element : in t_element;
      constant msg              : in string := ""
    ) is
    begin
      check_received(received_element, NO_TAG, "", msg);
    end procedure check_received;


    --
    --  Flush
    --
    --    Deletes all entries in queue and updates delete counter.
    --
    procedure flush(
      constant instance       : in integer;
      constant msg            : in string := "";
      constant ext_proc_call  : in string := ""
    ) is
      constant proc_name      : string    := "flush";
    begin
      if instance = ALL_INSTANCES then
        log(ID_DATA, proc_name & "() => flushing all instances. " & add_msg_delimiter(msg), vr_sb_scope);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          -- update counters
          vr_delete_cnt(i) := vr_delete_cnt(i) + priv_get_count(i);
          -- flush queue
          priv_flush(i);
        end loop;
      else
        if ext_proc_call = "" then
          priv_log(instance, ID_DATA, proc_name & "() => flushing SB. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        else
          priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        -- update counters
        vr_delete_cnt(instance) := vr_delete_cnt(instance) + priv_get_count(instance);
        -- flush queue
        priv_flush(instance);
      end if;
    end procedure flush;

    -- overload: flush instance 1
    procedure flush(
      constant msg : in string
    ) is
    begin
      flush(1, msg, "flush() => flushing SB. ");
    end procedure flush;

    -- overload: flush instance 1 with no msg
    procedure flush(
      constant void : in t_void
    ) is
    begin
      flush("");
    end procedure flush;


    --
    --  Reset
    --
    --    Resets all counters and flushes queue. Also resets entry number count.
    --
    procedure reset(
      constant instance       : in integer;
      constant msg            : in string := "";
      constant ext_proc_call  : in string := ""
    ) is
      constant proc_name      : string    := "reset";

      -- helper procedure
      procedure reset_instance(
        constant instance : natural
      ) is
      begin
        -- reset instance 0 only if it is used
        if not(priv_queue_is_empty(0)) or (instance > 0) then
            priv_reset(instance);
            vr_entered_cnt(instance)         := 0;
            vr_match_cnt(instance)           := 0;
            vr_mismatch_cnt(instance)        := 0;
            vr_drop_cnt(instance)            := 0;
            vr_initial_garbage_cnt(instance) := 0;
            vr_delete_cnt(instance)          := 0;
            vr_overdue_check_cnt(instance)   := 0;
        end if;
      end procedure reset_instance;

    begin
      if instance = ALL_INSTANCES then
        log(ID_CTRL, proc_name & "() => reseting all instances. " & add_msg_delimiter(msg), vr_sb_scope);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
            reset_instance(i);
        end loop;
      else
        if ext_proc_call = "" then
          priv_log(instance, ID_CTRL, proc_name & "() => reseting SB. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        else
          priv_log(instance, ID_CTRL, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        reset_instance(instance);
      end if;
    end procedure reset;

    -- overload: reset instance 1
    procedure reset(
      constant msg : in string
    ) is
    begin
      reset(1, msg, "reset() => reseting SB. ");
    end procedure reset;

    -- overload: reset instance 1 with no msg
    procedure reset(
      constant void : in t_void
    ) is
    begin
      reset("");
    end procedure reset;


    --
    --  Is Empty
    --
    --    Returns true if scoreboard instance is empty, false if not.
    --
    impure function is_empty(
      constant instance   : in integer
    ) return boolean is
      variable v_is_empty : boolean := true;
    begin
      if instance /= ALL_INSTANCES then
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        v_is_empty := priv_queue_is_empty(instance);
      else
        for idx in 0 to C_MAX_SB_INSTANCE_IDX loop
          -- an instance is not empty
          if vr_instance_enabled(idx) then
            if not(priv_queue_is_empty(idx)) then
              v_is_empty := false;
            end if;
          end if;
        end loop; 
      end if;
      
      return v_is_empty;
    end function is_empty;

    -- overload: is empty instance 1
    impure function is_empty(
      constant void : in t_void
    ) return boolean is
    begin
      return is_empty(1);
    end function is_empty;


    --
    --  Get Entered Count
    --
    --    Returns total number of entries made to scoreboard instance.
    --    Added + inserted.
    --
    impure function get_entered_count(
      constant instance : in integer
    ) return integer is
    begin
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      return vr_entered_cnt(instance);
    end function get_entered_count;

    -- overload: get entered count for instance 1
    impure function get_entered_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_entered_count(1);
    end function get_entered_count;


    --
    --  Get Pending Count
    --
    --    Returns number of entries en scoreboard instance at the moment.
    --    Added + inserted - checked - deleted.
    --
    impure function get_pending_count(
      constant instance : in integer
    ) return integer is
    begin
      if vr_entered_cnt(instance) = -1 then
        return -1;
      else
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        return priv_get_count(instance);
      end if;
    end function get_pending_count;

    -- overload: get pending count for instance 1
    impure function get_pending_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_pending_count(1);
    end function get_pending_count;


    --
    --  Get Match Count
    --
    --    Returns number of entries checked and matched against a received.
    --
    impure function get_match_count(
      constant instance : in integer
    ) return integer is
    begin
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      return vr_match_cnt(instance);
    end function get_match_count;

    -- overload: get match count for instance 1
    impure function get_match_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_match_count(1);
    end function get_match_count;


    --
    --  Get Mismatch Count
    --
    --    Returns number of entries checked and not matched against a received.
    --
    impure function get_mismatch_count(
      constant instance : in integer
    ) return integer is
    begin
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      return vr_mismatch_cnt(instance);
    end function get_mismatch_count;

    -- overload: get mismatch count for instance 1
    impure function get_mismatch_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_mismatch_count(1);
    end function get_mismatch_count;


    --
    --  Get Drop Count
    --
    --    Returns number of entries dropped, total number of preceding entries before match.
    --    Only relevant during lossy mode.
    --
    impure function get_drop_count(
      constant instance : in integer
    ) return integer is
    begin
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      return vr_drop_cnt(instance);
    end function get_drop_count;

    -- overload: get dropt count for instance 1
    impure function get_drop_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_drop_count(1);
    end function get_drop_count;


    --
    --  Get Initial Garbage Count
    --
    --    Returns number of received checked before first match.
    --    Only relevant when allow_initial_garbage is enabled.
    --
    impure function get_initial_garbage_count(
      constant instance : in integer
    ) return integer is
    begin
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      return vr_initial_garbage_cnt(instance);
    end function get_initial_garbage_count;

    -- overload: get initial garbage count for instance 1
    impure function get_initial_garbage_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_initial_garbage_count(1);
    end function get_initial_garbage_count;


    --
    --  Get Delete Count
    --
    --    Returns number of deleted entries.
    --    Delete + fetch + flush.
    --
    impure function get_delete_count(
      constant instance : in integer
    ) return integer is
    begin
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      return vr_delete_cnt(instance);
    end function get_delete_count;

    -- overload: get delete count for instance 1
    impure function get_delete_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_delete_count(1);
    end function get_delete_count;


    --
    --  Get Overdue Check Count
    --
    --    Returns number of received checked when time limit is overdue.
    --    Only relevant when overdue_check_time_limit is set.
    --
    impure function get_overdue_check_count(
      constant instance : in integer
    ) return integer is
    begin
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      return vr_overdue_check_cnt(instance);
    end function get_overdue_check_count;

    -- overload: get overdue check count for instance 1
    impure function get_overdue_check_count(
      constant void : in t_void
    ) return integer is
    begin
      return get_overdue_check_count(1);
    end function get_overdue_check_count;


    --
    --  Set Scope
    --
    --    Set the scope of the scoreboard.
    --
    procedure set_scope(
      constant scope : in string
    ) is
    begin
      vr_sb_scope := pad_string(scope, NUL, C_LOG_SCOPE_WIDTH);
    end procedure set_scope;

    --
    --  Get Scope
    --
    --    Get the scope of the scoreboard.
    --
    impure function get_scope(
      constant void : in t_void
    ) return string is
    begin
      return vr_sb_scope;
    end function get_scope;


    --
    --  Enable Log Msg
    --
    --    Enables the specified message id for the instance.
    --
    procedure enable_log_msg(
      constant instance      : in integer;
      constant msg_id        : in t_msg_id;
      constant ext_proc_call : in string := ""
    ) is
      constant proc_name : string := "enable_log_msg";
    begin
      if instance = ALL_INSTANCES then
        log(ID_CTRL, proc_name & "() => message id " & to_string(msg_id) & " enabled for all instances.", vr_sb_scope);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          vr_msg_id_panel_array(i)(msg_id) := ENABLED;
        end loop;
      else
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        if ext_proc_call = "" then
          priv_log(instance, ID_CTRL, proc_name & "() => message id " & to_string(msg_id) & " enabled.", vr_sb_scope & "," & to_string(instance));
        else
          priv_log(instance, ID_CTRL, ext_proc_call, vr_sb_scope & "," & to_string(instance));
        end if;
        vr_msg_id_panel_array(instance)(msg_id) := ENABLED;
      end if;
    end procedure enable_log_msg;

    -- overload: enable log msg for instance 1
    procedure enable_log_msg(
      constant msg_id        : in t_msg_id
    ) is
    begin
      enable_log_msg(1, msg_id, "enable_log_msg() => message id " & to_string(msg_id) & " enabled. ");
    end procedure enable_log_msg;


    --
    --  Disable Log Msg
    --
    --    Disables the specified message id for the instance.
    --
    procedure disable_log_msg(
      constant instance      : in integer;
      constant msg_id        : in t_msg_id;
      constant ext_proc_call : in string := ""
    ) is
      constant proc_name : string := "disable_log_msg";
    begin
      if instance = ALL_INSTANCES then
        log(ID_CTRL, proc_name & "() => message id " & to_string(msg_id) & " disabled for all instances.", vr_sb_scope);
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          vr_msg_id_panel_array(i)(msg_id) := DISABLED;
        end loop;
      else
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        if ext_proc_call = "" then
          priv_log(instance, ID_CTRL, proc_name & "() => message id " & to_string(msg_id) & " disabled.", vr_sb_scope & "," & to_string(instance));
        else
          priv_log(instance, ID_CTRL, ext_proc_call, vr_sb_scope & "," & to_string(instance));
        end if;
        vr_msg_id_panel_array(instance)(msg_id) := DISABLED;
      end if;
    end procedure disable_log_msg;

    -- overload: disable log msg for instance 1
    procedure disable_log_msg(
      constant msg_id : in t_msg_id
    ) is
    begin
      disable_log_msg(1, msg_id, "disable_log_msg() => message id " & to_string(msg_id) & " disabled. ");
    end procedure disable_log_msg;


    --
    --  Report Conters
    --
    --    Prints a report of all counters to transcript for either specified instance, all enabled
    --    instances or all instances.
    --
    procedure report_counters(
      constant instance      : in integer;
      constant ext_proc_call : in string := ""
    ) is
      variable v_line                               : line;
      variable v_line_copy                          : line;
      variable v_status_failed                      : boolean   := true;
      variable v_mismatch                           : boolean   := false;
      variable v_no_enabled_instances               : boolean   := true;
      constant C_HEADER                             : string    := "*** SCOREBOARD COUNTERS SUMMARY: " & to_string(vr_sb_scope) & " ***";
      constant prefix                               : string    := C_LOG_PREFIX & "     ";
      constant log_counter_width                    : positive  := 8; -- shouldn't be smaller than 8 due to the counters names
      variable v_log_extra_space                    : integer   := 0;
      constant C_MAX_SB_INSTANCE_IDX_STRING      : string    := to_string(C_MAX_SB_INSTANCE_IDX);
      constant C_MAX_SB_INSTANCE_IDX_STRING_LEN  : natural   := C_MAX_SB_INSTANCE_IDX_STRING'length;


        -- helper method: add simulation time stamp to scoreboard report header
        impure function timestamp_header(value : time; txt : string) return string is
            variable v_line             : line;
            variable v_delimiter_pos    : natural;
            variable v_timestamp_width  : natural;
            variable v_result           : string(1 to 50);
            variable v_return           : string(1 to txt'length) := txt;
          begin
            -- get a time stamp
            write(v_line, value, LEFT, 0, C_LOG_TIME_BASE);
            v_timestamp_width := v_line'length;
            v_result(1 to v_timestamp_width) := v_line.all;
            deallocate(v_line);
            v_delimiter_pos := pos_of_leftmost('.', v_result(1 to v_timestamp_width), 0);

            -- truncate decimals and add units
            if v_delimiter_pos > 0 then
              if C_LOG_TIME_BASE = ns then
                v_result(v_delimiter_pos+2 to v_delimiter_pos+4) := " ns";
              else
                v_result(v_delimiter_pos+2 to v_delimiter_pos+4) := " ps";
              end if;
              v_timestamp_width := v_delimiter_pos + 4;
            end if;
            -- add a space after the timestamp
            v_timestamp_width := v_timestamp_width + 1;
            v_result(v_timestamp_width to v_timestamp_width) := " ";

            -- add time string to return string
            v_return := v_result(1 to v_timestamp_width) & txt(1 to txt'length-v_timestamp_width);
            return v_return(1 to txt'length);
          end function timestamp_header;

    begin
      -- Calculate how much space we can insert between the columns of the report
      v_log_extra_space := (C_LOG_LINE_WIDTH - prefix'length - 20 - log_counter_width*6 - 15 - 13)/8;
      if v_log_extra_space < 1 then
        alert(TB_WARNING, "C_LOG_LINE_WIDTH is too small, the report will not be properly aligned.", vr_sb_scope);
        v_log_extra_space := 1;
      end if;

      write(v_line,
            LF &
            fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF &
            timestamp_header(now, justify(C_HEADER, LEFT, C_LOG_LINE_WIDTH - prefix'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF &
            fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF);

      write(v_line,
        justify(
          fill_string(' ', 16) &
          justify("ENTERED"        , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify("PENDING"        , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify("MATCH"          , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify("MISMATCH"       , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify("DROP"           , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify("INITIAL_GARBAGE", center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify("DELETE"         , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify("OVERDUE_CHECK"  , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
          left, C_LOG_LINE_WIDTH - prefix'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);

      if instance = ALL_INSTANCES THEN
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if (instance = ALL_INSTANCES and vr_instance_enabled(i)) then
            v_no_enabled_instances := false;

            write(v_line,
            justify(
              "instance: " &
              justify(to_string(i), right, C_MAX_SB_INSTANCE_IDX_STRING_LEN, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
              fill_string(' ', 20-4-10-C_MAX_SB_INSTANCE_IDX_STRING_LEN) &
              justify(to_string(get_entered_count(i))        , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(get_pending_count(i))        , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(get_match_count(i))          , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(get_mismatch_count(i))       , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(get_drop_count(i))           , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(get_initial_garbage_count(i)), center, 15, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(get_delete_count(i))         , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(get_overdue_check_count(i))  , center, 13, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
              left, C_LOG_LINE_WIDTH - prefix'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
          end if;
        end loop;

        -- report if no enabled instances was found
        if v_no_enabled_instances then
          write(v_line, "No enabled instances was found." & LF);
        end if;

      else
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        write(v_line,
          justify(
            "instance: " &
            justify(to_string(instance), right, C_MAX_SB_INSTANCE_IDX_STRING_LEN, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
            fill_string(' ', 20-4-10-C_MAX_SB_INSTANCE_IDX_STRING_LEN) &
            justify(to_string(get_entered_count(instance))        , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_pending_count(instance))        , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_match_count(instance))          , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_mismatch_count(instance))       , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_drop_count(instance))           , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_initial_garbage_count(instance)), center, 15, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_delete_count(instance))         , center, log_counter_width, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_overdue_check_count(instance))  , center, 13, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
            left, C_LOG_LINE_WIDTH - prefix'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
      end if;

      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - prefix'length)) & LF & LF);
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH-prefix'length);
      prefix_lines(v_line, prefix);

      -- Write the info string to transcript
      write (v_line_copy, v_line.all);  -- copy line
      writeline(OUTPUT, v_line);
      writeline(LOG_FILE, v_line_copy);
    end procedure report_counters;

    -- overload: report counters of instance 1
    procedure report_counters(
      constant void : in t_void
    ) is
    begin
      report_counters(1, "no instance label");
    end procedure report_counters;



    --
    --  Insert Expected
    --
    --    Inserts expected element to the queue based on position or entry number
    --
    procedure insert_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant tag_usage         : in t_tag_usage;
      constant tag               : in string;
      constant msg               : in string := "";
      constant source            : in string := "";
      constant ext_proc_call     : in string := ""
    ) is
      constant proc_name : string := "insert_expected";
      variable v_sb_entry : t_sb_entry;
    begin
      -- Check if instance is within range
      if instance /= ALL_INSTANCES then
        priv_check_instance_in_range(instance);
      end if;

      v_sb_entry := (expected_element => expected_element,
                     source           => pad_string(source, NUL, C_SB_SOURCE_WIDTH),
                     tag              => pad_string(tag, NUL, C_SB_TAG_WIDTH),
                     entry_time       => now);

      if instance = ALL_INSTANCES then
        for i in 0 to C_MAX_SB_INSTANCE_IDX loop
          if vr_instance_enabled(i) then
            -- Check that instance is enabled
            priv_check_queue_empty(i);
            -- add entry
            priv_insert(i, identifier_option, identifier, v_sb_entry);
            -- increment counters
            vr_entered_cnt(i) := vr_entered_cnt(i)+1;
          end if;
        end loop;
      else
        -- Check that instance is in valid range and enabled
        priv_check_instance_in_range(instance);
        priv_check_instance_enabled(instance);
        priv_check_queue_empty(instance);
        -- add entry
        priv_insert(instance, identifier_option, identifier, v_sb_entry);
        -- increment counters
        vr_entered_cnt(instance) := vr_entered_cnt(instance)+1;
      end if;

      -- Logging
      if ext_proc_call = "" then
        if instance = ALL_INSTANCES then
          if identifier_option = POSITION then
            if tag_usage = NO_TAG then
              log(ID_DATA, proc_name & "() => inserted expected after entry with position " & to_string(identifier) & " for all enabled instances. Expected: "
                & to_string_element(expected_element) & ". " & add_msg_delimiter(msg), vr_sb_scope);
            else
              log(ID_DATA, proc_name & "() => inserted expected after entry with position " & to_string(identifier) & " for all enabled instances. Expected: "
                & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope);
            end if;
          else
            if tag_usage = NO_TAG then
              log(ID_DATA, proc_name & "() => inserted expected after entry with entry number " & to_string(identifier) & " for all enabled instances. Expected: "
                & to_string_element(expected_element) & ". " & add_msg_delimiter(msg), vr_sb_scope);
            else
              log(ID_DATA, proc_name & "() => inserted expected after entry with entry number " & to_string(identifier) & " for all enabled instances. Expected: "
                & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope);
            end if;
          end if;
        else
          if identifier_option = POSITION then
            priv_log(instance, ID_DATA, proc_name & "() => inserted expected after entry with position " & to_string(identifier) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
          else
            priv_log(instance, ID_DATA, proc_name & "() => inserted expected after entry with entry number " & to_string(identifier) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
          end if;
        end if;
      else
        if tag_usage = NO_TAG then
          priv_log(instance, ID_DATA, ext_proc_call & " Expected: " & to_string_element(expected_element) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        else
          priv_log(instance, ID_DATA, ext_proc_call & " Expected: " & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
      end if;
    end procedure insert_expected;

    -- overload: insert expected to instance 1
    procedure insert_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant tag_usage         : in t_tag_usage;
      constant tag               : in string;
      constant msg               : in string := "";
      constant source            : in string := ""
    ) is
    begin
      if identifier_option = POSITION then
        insert_expected(1, identifier_option, identifier, expected_element, tag_usage, tag, msg, source, "insert_expected() => inserted expected after entry with position " & to_string(identifier) & ". ");
      else
        insert_expected(1, identifier_option, identifier, expected_element, tag_usage, tag, msg, source, "insert_expected() => inserted expected after entry with entry number " & to_string(identifier) & ". ");
      end if;
    end procedure insert_expected;

    -- overload: insert expected with NO_TAG
    procedure insert_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant msg               : in string := "";
      constant source            : in string := ""
      ) is
      begin
        insert_expected(instance, identifier_option, identifier, expected_element, NO_TAG, "", msg, source, "insert_expected() => inserted expected without TAG in position " & to_string(identifier) & ". ");
      end procedure insert_expected;

    -- overload: insert expected to instance 1 with NO_TAG
    procedure insert_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant expected_element  : in t_element;
      constant msg               : in string := "";
      constant source            : in string := ""
      ) is
      begin
        insert_expected(1, identifier_option, identifier, expected_element, NO_TAG, "", msg, source, "insert_expected() => inserted expected without TAG in position " & to_string(identifier) & ". ");
      end procedure insert_expected;

      
    --
    --  Find Expected Entry Number
    --
    --    Returns entry number of matching entry, no match returns -1
    --
    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      priv_check_queue_empty(instance);

      for i in 1 to get_pending_count(instance) loop
        -- get entry i
        v_sb_entry := priv_peek(instance, POSITION, i);

        -- check if match
        if priv_match_expected_vs_entry(expected_element, v_sb_entry, tag_usage, tag) then
          return priv_get_entry_num(instance, i);
        end if;
      end loop;

      return -1;
    end function find_expected_entry_num;

    -- overload: find expected entry number in instance 1
    impure function find_expected_entry_num(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
    begin
      return find_expected_entry_num(1, expected_element, tag_usage, tag);
    end function find_expected_entry_num;

    -- overload: find expected entry number with NO_TAG
    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant expected_element : in t_element
    ) return integer is
    begin
      return find_expected_entry_num(instance, expected_element, NO_TAG, "");
    end function find_expected_entry_num;

    -- overload: find expected entry number in instance 1 with NO_TAG
    impure function find_expected_entry_num(
      constant expected_element : in t_element
    ) return integer is
    begin
      return find_expected_entry_num(1, expected_element, NO_TAG, "");
    end function find_expected_entry_num;

    -- overload: find expected entry number without expected_element
    impure function find_expected_entry_num(
      constant instance         : in integer;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      priv_check_queue_empty(instance);

      for i in 1 to get_pending_count(instance) loop
        -- get entry i
        v_sb_entry := priv_peek(instance, POSITION, i);

        -- check if match
        if v_sb_entry.tag = pad_string(tag, NUL, C_SB_TAG_WIDTH) then
          return priv_get_entry_num(instance, i);
        end if;
      end loop;

      return -1;
    end function find_expected_entry_num;

    -- overload: find expected entry number in instance 1 without expected_element
    impure function find_expected_entry_num(
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
    begin
      return find_expected_entry_num(1, tag_usage, tag);
    end function find_expected_entry_num;


    --
    --  Find Expected Position
    --
    --    Returns position of matching entry, no match returns -1
    --
    impure function find_expected_position(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      priv_check_queue_empty(instance);

      for i in 1 to get_pending_count(instance) loop
        -- get entry i
        v_sb_entry := priv_peek(instance, POSITION, i);

        -- check if match
        if priv_match_expected_vs_entry(expected_element, v_sb_entry, tag_usage, tag) then
          return i;
        end if;
      end loop;

      return -1;
    end function find_expected_position;

    -- overload: find expected position in instance 1
    impure function find_expected_position(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
    begin
      return find_expected_position(1, expected_element, tag_usage, tag);
    end function find_expected_position;

    -- overload: find expected position with NO_TAG
    impure function find_expected_position(
      constant instance         : in integer;
      constant expected_element : in t_element
    ) return integer is
    begin
      return find_expected_position(instance, expected_element, NO_TAG, "");
    end function find_expected_position;

    -- overload: find expected position in instance 1 with NO_TAG
    impure function find_expected_position(
      constant expected_element : in t_element
    ) return integer is
    begin
      return find_expected_position(1, expected_element, NO_TAG, "");
    end function find_expected_position;

    -- overload: find expected position without expected_element
    impure function find_expected_position(
      constant instance         : in integer;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
      variable v_sb_entry : t_sb_entry;
    begin
      -- Sanity check
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      priv_check_queue_empty(instance);

      for i in 1 to get_pending_count(instance) loop
        -- get entry i
        v_sb_entry := priv_peek(instance, POSITION, i);

        -- check if match
        if v_sb_entry.tag = pad_string(tag, NUL, C_SB_TAG_WIDTH) then
          return i;
        end if;
      end loop;

      return -1;
    end function find_expected_position;

    -- overload: find expected position in instance 1 without expected_element
    impure function find_expected_position(
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string
    ) return integer is
    begin
      return find_expected_position(1, tag_usage, tag);
    end function find_expected_position;


    --
    --  Delete Expected
    --
    --    Deletes expected element in queue based on specified element, position or entry number
    --
    procedure delete_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := ""
    ) is
      constant proc_name        : string := "delete_expected";
      variable v_position       : integer;
    begin
      -- Sanity checks done in find_expected_position

      v_position := find_expected_position(instance, expected_element, tag_usage, tag);

      if v_position /= -1 then
        priv_delete(instance, POSITION, v_position, SINGLE);
        vr_delete_cnt(instance) := vr_delete_cnt(instance) + 1;

        if ext_proc_call = "" then
          priv_log(instance, ID_DATA, proc_name & "() => value: " & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        else
          priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
      else
        priv_log(instance, ID_DATA, proc_name & "() => NO DELETION. Did not find matching entry. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      end if;
    end procedure delete_expected;

    -- overload: delete expected in instance 1
    procedure delete_expected(
      constant expected_element : in t_element;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := ""
    ) is
    begin
      delete_expected(1, expected_element, tag_usage, tag, msg, "delete_expected() => value: " & to_string_element(expected_element) & ", tag: '" & to_string(tag) & "'. ");
    end procedure delete_expected;

    -- overload: delete expected with NO_TAG
    procedure delete_expected(
      constant instance         : in integer;
      constant expected_element : in t_element;
      constant msg              : in string := ""
    ) is
    begin
      delete_expected(instance, expected_element, NO_TAG, "", msg, "delete_expected() => value: " & to_string_element(expected_element) & ". ");
    end procedure delete_expected;

    -- overload: delete expected in instance 1 with NO_TAG
    procedure delete_expected(
      constant expected_element : in t_element;
      constant msg              : in string := ""
    ) is
    begin
      delete_expected(1, expected_element, NO_TAG, "", msg, "delete_expected() => value: " & to_string_element(expected_element) & ". ");
    end procedure delete_expected;

    -- overload: delete expected without expected_element
    procedure delete_expected(
      constant instance         : in integer;
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := "";
      constant ext_proc_call    : in string := ""
    ) is
      constant proc_name  : string := "delete_expected";
      variable v_position : integer;
    begin
      -- Sanity checks done in find_expected_position

      v_position := find_expected_position(instance, tag_usage, tag);

      if v_position /= -1 then
        priv_delete(instance, POSITION, v_position, SINGLE);
        vr_delete_cnt(instance) := vr_delete_cnt(instance) + 1;

        if ext_proc_call = "" then
          priv_log(instance, ID_DATA, proc_name & "() => tag: '" & to_string(tag) & "'. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        else
          priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope);
        end if;
      else
        priv_log(instance, ID_DATA, proc_name & "() => NO DELETION. Did not find matching entry. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      end if;
    end procedure delete_expected;

    -- overload: delete expected in instance 1 without expected_element
    procedure delete_expected(
      constant tag_usage        : in t_tag_usage;
      constant tag              : in string;
      constant msg              : in string := ""
    ) is
    begin
      delete_expected(1, tag_usage, tag, msg, "delete_expected() => tag: '" & to_string(tag) & "'. ");
    end procedure delete_expected;

    -- overload: delete expected without expected_element
    procedure delete_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive;
      constant msg               : in string := "";
      constant ext_proc_call     : in string := ""
    ) is
      constant proc_name : string := "delete_expected";
      constant C_PRE_DELETE_PENDING_CNT : natural := priv_get_count(instance);
      variable v_num_deleted            : natural;
    begin
      -- Sanity check
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      priv_check_queue_empty(instance);

      -- Delete entries
      priv_delete(instance, identifier_option, identifier_min, identifier_max);
      v_num_deleted := C_PRE_DELETE_PENDING_CNT - priv_get_count(instance);
      vr_delete_cnt(instance) := vr_delete_cnt(instance) + v_num_deleted;

      -- If error
      if v_num_deleted = 0 then
        priv_log(instance, ID_DATA, proc_name & "() => NO DELETION. Did not find matching entry. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      else
        if ext_proc_call = "" then
          priv_log(instance, ID_DATA, proc_name & "() => entries with identifier " & to_string(identifier_option) &
            " range " & to_string(identifier_min) & " to " & to_string(identifier_max) & " deleted. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        else
          priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
      end if;
    end procedure delete_expected;

    -- overload: delete expected in instance 1 without expected_element
    procedure delete_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier_min    : in positive;
      constant identifier_max    : in positive;
      constant msg               : in string := ""
    ) is
    begin
      delete_expected(1, identifier_option, identifier_min, identifier_max, msg, "delete_expected() => entries with identifier " & to_string(identifier_option) &
        " range " & to_string(identifier_min) & " to " & to_string(identifier_max) & " deleted. ");
    end procedure delete_expected;

    -- overload: delete expected with position and without expected_element
    procedure delete_expected(
      constant instance          : in integer;
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option;
      constant msg               : in string := "";
      constant ext_proc_call     : in string := ""
    ) is
      constant proc_name : string := "delete_expected";
      constant C_PRE_DELETE_PENDING_CNT : natural := priv_get_count(instance);
      variable v_num_deleted            : natural;
    begin
      -- Sanity check
      priv_check_instance_in_range(instance);
      priv_check_instance_enabled(instance);
      priv_check_queue_empty(instance);

      -- Delete entries
      priv_delete(instance, identifier_option, identifier, range_option);
      v_num_deleted := C_PRE_DELETE_PENDING_CNT - priv_get_count(instance);
      vr_delete_cnt(instance) := vr_delete_cnt(instance) + v_num_deleted;

      -- If error
      if v_num_deleted = 0 then
        priv_log(instance, ID_DATA, proc_name & "() => NO DELETION. Did not find matching entry. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      else
        if ext_proc_call = "" then
          if range_option = SINGLE then
            priv_log(instance, ID_DATA, proc_name & "() => entry with identifier " & to_string(identifier_option) &
              " " & to_string(identifier) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
          else
            priv_log(instance, ID_DATA, proc_name & "() => entries with identifier " & to_string(identifier_option) &
              " range " & to_string(identifier) & " " & to_string(range_option) & " deleted. " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
          end if;
        else
          priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
        end if;
      end if;
    end procedure delete_expected;

    -- overload: delete expected in instance 1 with range option and without expected_element
    procedure delete_expected(
      constant identifier_option : in t_identifier_option;
      constant identifier        : in positive;
      constant range_option      : in t_range_option;
      constant msg               : in string := ""
    ) is
    begin
      if range_option = SINGLE then
        delete_expected(1, identifier_option, identifier, range_option, msg, "delete_expected() => entry with identifier '" & to_string(identifier_option) &
          " " & to_string(identifier) & " deleted. ");
      else
        delete_expected(1, identifier_option, identifier, range_option, msg, "delete_expected() => entries with identifier '" & to_string(identifier_option) &
          " range " & to_string(identifier) & " to " & to_string(range_option) & " deleted. ");
      end if;
    end procedure delete_expected;


    --
    --  Peek Expected
    --
    --    Returns expected element from queue entry based on position or entry number without deleting entry
    --
    impure function peek_expected(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return t_element is
    begin
      return priv_peek_entry(instance, identifier_option, identifier).expected_element;
    end function peek_expected;

    -- overload: peek expected in instance 1
    impure function peek_expected(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return t_element is
    begin
      return priv_peek_entry(1, identifier_option, identifier).expected_element;
    end function peek_expected;

    -- overload: peek exteced with identifier option = POSITION
    impure function peek_expected(
      constant instance          : integer
    ) return t_element is
    begin
      return priv_peek_entry(instance, POSITION, 1).expected_element;
    end function peek_expected;

    -- overload: peek expected in instance 1 with identifier option = POSITION
    impure function peek_expected(
      constant void : t_void
    ) return t_element is
    begin
      return priv_peek_entry(1, POSITION, 1).expected_element;
    end function peek_expected;


    --
    --  Peek Source
    --
    --    Returns source element from queue entry based on position or entry number without deleting entry
    --
    impure function peek_source(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return string is
    begin
      return to_string(priv_peek_entry(instance, identifier_option, identifier).source);
    end function peek_source;

    -- overload: peek source in instance 1
    impure function peek_source(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return string is
    begin
      return peek_source(1, identifier_option, identifier);
    end function peek_source;

    -- overload: peek source with identifier option = POSITION
    impure function peek_source(
      constant instance          : integer
    ) return string is
    begin
      return peek_source(instance, POSITION, 1);
    end function peek_source;

    -- overload: peek source in instance 1 with identifier option = POSITION
    impure function peek_source(
      constant void : t_void
    ) return string is
    begin
      return peek_source(1, POSITION, 1);
    end function peek_source;

    --
    --  Peek Tag
    --
    --    Returns tag from queue entry based on position or entry number without deleting entry
    --
    impure function peek_tag(
      constant instance          : integer;
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return string is
    begin
      return to_string(priv_peek_entry(instance, identifier_option, identifier).tag);
    end function peek_tag;

    -- overload: peek tag in instance 1
    impure function peek_tag(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive
    ) return string is
    begin
      return peek_tag(1, identifier_option, identifier);
    end function peek_tag;

    -- overload: peek tag with identifier option = POSITION
    impure function peek_tag(
      constant instance          : integer
    ) return string is
    begin
      return peek_tag(instance, POSITION, 1);
    end function peek_tag;

    -- overload: peek tag in instance 1 with identifier option = POSITION
    impure function peek_tag(
      constant void : t_void
    ) return string is
    begin
      return peek_tag(1, POSITION, 1);
    end function peek_tag;


    --
    --  Fetch Expected
    --
    --    Returns expected element from queue entry based on position or entry number and deleting entry
    --
    impure function fetch_expected(
      constant instance           : integer;
      constant identifier_option  : t_identifier_option;
      constant identifier         : positive;
      constant msg                : string := "";
      constant ext_proc_call      : string := ""
    ) return t_element is
      constant proc_name          : string := "fetch_expected";
    begin
      -- Sanity checks in fetch entry
      -- Logging
      if ext_proc_call = "" then
        priv_log(instance, ID_DATA, proc_name & "() => fetching expected by " & to_string(identifier_option) & " " &
          to_string(identifier) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      else
        priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      end if;
      return priv_fetch_entry(instance, identifier_option, identifier).expected_element;
    end function fetch_expected;

    -- overload: fetch expected in instance 1
    impure function fetch_expected(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := ""
    ) return t_element is
    begin
      return fetch_expected(1, identifier_option, identifier, msg, "fetch_expected() => fetching expected by " &
        to_string(identifier_option) & " " & to_string(identifier) & ". ");
    end function fetch_expected;

    -- overload: fetch expected with identifier option = POSITION
    impure function fetch_expected(
      constant instance          : integer;
      constant msg               : string := ""
    ) return t_element is
    begin
      return fetch_expected(instance, POSITION, 1, msg);
    end function fetch_expected;

    -- overload: fetch expected in instance 1 with identifier option = POSITION
    impure function fetch_expected(
      constant msg : string
    ) return t_element is
    begin
      return fetch_expected(POSITION, 1, msg);
    end function fetch_expected;

    -- overload: fetch expcted in instance 1 with identifier option = POSITION and no msg
    impure function fetch_expected(
      constant void : t_void
    ) return t_element is
    begin
      return fetch_expected(POSITION, 1);
    end function fetch_expected;


    --
    --  Fetch Source
    --
    --    Returns source element from queue entry based on position or entry number and deleting entry
    --
    impure function fetch_source(
      constant instance           : integer;
      constant identifier_option  : t_identifier_option;
      constant identifier         : positive;
      constant msg                : string := "";
      constant ext_proc_call      : string := ""
    ) return string is
      constant proc_name          : string := "fetch_source";
    begin
      -- Sanity checks in fetch entry
      -- Logging
      if ext_proc_call = "" then
        priv_log(instance, ID_DATA, proc_name & "() => fetching source by " & to_string(identifier_option) & " " &
          to_string(identifier) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      else
        priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      end if;
      return to_string(priv_fetch_entry(instance, identifier_option, identifier).source);
    end function fetch_source;

    -- overload: fetch source in instance 1
    impure function fetch_source(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := ""
    ) return string is
    begin
      return fetch_source(1, identifier_option, identifier, msg, "fetch_source() => fetching source by " &
        to_string(identifier_option) & " " & to_string(identifier) & ". ");
    end function fetch_source;

    -- overload: fetch source with identifier option = POSITION
    impure function fetch_source(
      constant instance          : integer;
      constant msg               : string := ""
    ) return string is
    begin
      return fetch_source(instance, POSITION, 1, msg);
    end function fetch_source;

    -- overload: fetch source in instance 1 with identifier option = POSITION
    impure function fetch_source(
      constant msg : string
    ) return string is
    begin
      return fetch_source(POSITION, 1, msg);
    end function fetch_source;

    -- overload: fetch source in instance 1 with identifier option = POSITION and no msg
    impure function fetch_source(
      constant void : t_void
    ) return string is
    begin
      return fetch_source(POSITION, 1);
    end function fetch_source;


    --
    --  Fetch Tag
    --
    --    Returns tag from queue entry based on position or entry number and deleting entry
    --
    impure function fetch_tag(
      constant instance           : integer;
      constant identifier_option  : t_identifier_option;
      constant identifier         : positive;
      constant msg                : string := "";
      constant ext_proc_call      : string := ""
    ) return string is
      constant proc_name          : string := "fetch_tag";
    begin
      -- Sanity checks in fetch entry
      -- Logging
      if ext_proc_call = "" then
        priv_log(instance, ID_DATA, proc_name & "() => fetching tag by " & to_string(identifier_option) & " " &
          to_string(identifier) & ". " & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      else
        priv_log(instance, ID_DATA, ext_proc_call & add_msg_delimiter(msg), vr_sb_scope & "," & to_string(instance));
      end if;
      return to_string(priv_fetch_entry(instance, identifier_option, identifier).tag);
    end function fetch_tag;

    -- overload: fetch tag in instance 1
    impure function fetch_tag(
      constant identifier_option : t_identifier_option;
      constant identifier        : positive;
      constant msg               : string := ""
    ) return string is
    begin
      return fetch_tag(1, identifier_option, identifier, msg, "fetch_tag() => fetching tag by " &
        to_string(identifier_option) & " " & to_string(identifier) & ". ");
    end function fetch_tag;

    -- overload: fetch tag with identifier option = POSITION
    impure function fetch_tag(
      constant instance          : integer;
      constant msg               : string := ""
    ) return string is
    begin
      return fetch_tag(instance, POSITION, 1, msg);
    end function fetch_tag;

    -- overload: fetch tag in instance 1 with identifier option = POSITION
    impure function fetch_tag(
      constant msg : string
    ) return string is
    begin
      return fetch_tag(POSITION, 1, msg);
    end function fetch_tag;

    -- overload: fetch tag in instance 1 with identifier option = POSITION and no msg
    impure function fetch_tag(
      constant void : t_void
    ) return string is
    begin
      return fetch_tag(POSITION, 1);
    end function fetch_tag;


    --
    --  Exists
    --
    --    Returns true if entry exists, false if not.
    --
    impure function exists(
      constant instance         : integer;
      constant expected_element : t_element;
      constant tag_usage        : t_tag_usage := NO_TAG;
      constant tag              : string      := ""
    ) return boolean is
    begin
      return (find_expected_position(instance, expected_element, tag_usage, tag) /= C_NO_MATCH);
    end function exists;

    -- overload: exsists with instance 1
    impure function exists(
      constant expected_element : t_element;
      constant tag_usage        : t_tag_usage := NO_TAG;
      constant tag              : string      := ""
    ) return boolean is
    begin
      return exists(1, expected_element, tag_usage, tag);
    end function exists;

    -- overload: exists with no expected_element
    impure function exists(
      constant instance         : integer;
      constant tag_usage        : t_tag_usage;
      constant tag              : string
    ) return boolean is
    begin
      return (find_expected_position(instance, tag_usage, tag) /= C_NO_MATCH);
    end function exists;

    -- overload: exists in instance 1 and no expected_element
    impure function exists(
      constant tag_usage        : t_tag_usage;
      constant tag              : string
    ) return boolean is
    begin
      return exists(1, tag_usage, tag);
    end function exists;

  end protected body;

end package body generic_sb_pkg;
