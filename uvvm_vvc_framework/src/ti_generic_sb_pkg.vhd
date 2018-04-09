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

use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package ti_generic_sb_pkg is

generic (type t_generic_element;
         GC_SB_FIFO_COUNT_MAX       : natural := 1000;
         GC_SB_FIFO_COUNT_THRESHOLD : natural := 950;
         GC_SB_ARRAY_WIDTH          : natural := 10
         );


  -- A generic SB for verification
  type t_generic_sb is protected

    --------------------------------------------------------
    -- Initialize SB
    procedure init_sb(
      constant dummy : t_void
    );

    --------------------------------------------------------
    -- Put item in SB FIFO
    procedure put(
      constant element  : in t_generic_element; -- generic element
      constant tag      : in string;            -- element tag
      constant sb_index : in integer            -- index in SB array
    );
    procedure put(
      constant element : in t_generic_element;  -- generic element
      constant sb_index : in integer            -- index in SB array
    );
    procedure put(
      constant element  : in t_generic_element; -- generic element
      constant tag      : in string             -- element tag
    );
    procedure put(
      constant element  : in t_generic_element  -- generic element
    );

    --------------------------------------------------------
    -- Compare expected element with SB FIFO
    impure function check(
      constant expected_element : in t_generic_element; -- generic element
      constant tag              : in string;            -- element tag
      constant sb_index         : integer               -- index in SB array
    ) return boolean;
    impure function check(
      constant expected_element : in t_generic_element; -- generic element
      constant tag              : in string             -- element tag
    ) return boolean;
    impure function check(
      constant expected_element : in t_generic_element; -- generic element
      constant sb_index         : in integer            -- index in SB array
    ) return boolean;
    impure function check(
      constant expected_element : in t_generic_element  -- generic element
    ) return boolean;


    --------------------------------------------------------
    -- Remove item from SB FIFO
    procedure remove(
      constant tag      : in string; -- element tag (will remove oldest element with this tag)
      constant sb_index : in integer -- index in SB array
    );
    procedure remove(
      constant sb_index : in integer -- index in SB array
    );
    procedure remove(
      dummy : t_void
    );

    --------------------------------------------------------
    -- Peek inside SB
    impure function peek(
      constant sb_fifo_index  : in integer; -- index in SB FIFO
      constant sb_index       : in integer  -- index in SB array
    ) return t_generic_element;
    impure function peek(
      constant sb_fifo_index  : in integer -- index in SB FIFO
    ) return t_generic_element;
    impure function peek(
      constant dummy  : in t_void
    ) return t_generic_element;

    --------------------------------------------------------
    -- Check if element exist
    impure function exist(
      constant element        : in t_generic_element; -- generic element
      constant tag            : in string;            -- element tag
      constant sb_index       : in integer            -- index in SB array
    ) return boolean;
    impure function exist(
      constant element  : in t_generic_element; -- generic element
      constant tag      : in string             -- element tag
    ) return boolean;
    impure function exist(
      constant element : in t_generic_element -- generic element
    ) return boolean;


    --------------------------------------------------------
    -- Get item from SB FIFO
    impure function get(
      constant sb_index : in integer -- index in SB array
    ) return t_generic_element;
    impure function get(
      constant dummy : in t_void
    ) return t_generic_element;

    --------------------------------------------------------
    -- Empty SB FIFO
    procedure flush(
      constant sb_index : integer -- index in SB array
    );
    procedure flush(
      void : t_void
    );

    --------------------------------------------------------
    -- Check SB FIFO empty
    impure function is_empty(
      constant sb_index : integer -- index in SB array
    ) return boolean;
    impure function is_empty(
      constant dummy : in t_void
    ) return boolean;

    --------------------------------------------------------
    -- Check SB FIFO not empty
    impure function is_not_empty(
      constant sb_index : integer -- index in SB array
    ) return boolean;
    impure function is_not_empty(
      constant dummy : in t_void
    ) return boolean;

    --------------------------------------------------------
    -- Set SB scope
    procedure set_scope(
      constant scope : in string
    );

    --------------------------------------------------------
    -- Get SB scope
    impure function get_scope(
      constant dummy : in t_void
    ) return string;

    --------------------------------------------------------
    -- Set SB name
    procedure set_name(
      constant name     : in string;  -- SB name
      constant sb_index : in integer  -- index in SB array
    );
    procedure set_name(
      constant name : in string       -- SB name
    );

    --------------------------------------------------------
    -- Get SB name
    impure function get_name(
      constant sb_index : in integer  -- index in SB array
    ) return string;
    impure function get_name(
      constant dummy : in t_void
    ) return string;

    --------------------------------------------------------
    -- Get SB FIFO element count
    impure function get_count(
      constant sb_index : in integer  -- index in SB array
    ) return natural;
    impure function get_count(
      constant dummy : in t_void
    ) return natural;

    --------------------------------------------------------
    -- Set SB threshold limit
    procedure set_sb_count_threshold(
      constant sb_index                   : in integer; -- index in SB array
      constant sb_fifo_count_alert_level  : in natural  -- alert level
    );
    procedure set_sb_count_threshold(
      constant sb_fifo_count_alert_level  : in natural  -- alert level
    );

    --------------------------------------------------------
    -- Get SB threshold limit
    impure function get_sb_count_threshold(
      constant sb_index : integer -- index in SB array
    ) return natural;
    impure function get_sb_count_threshold(
      constant dummy : in t_void
    ) return natural;

    --------------------------------------------------------
    -- Set SB threshold severity
    procedure set_sb_count_threshold_severity(
      constant alert_level : in t_alert_level
    );

    --------------------------------------------------------
    -- Get SB threshold severity
    impure function get_sb_count_threshold_severity(
      constant dummy : in t_void
    ) return t_alert_level;

    --------------------------------------------------------
    -- Set SB FIFO max limit
    procedure set_sb_count_max(
      constant sb_index           : in integer; -- index in SB array
      constant sb_fifo_count_max  : in natural
    );
    procedure set_sb_count_max(
      constant sb_fifo_count_max : in natural
    );

    --------------------------------------------------------
    -- Get SB FIFO max limit
    impure function get_sb_count_max(
      constant sb_index : integer -- index in SB array
    ) return natural;
    impure function get_sb_count_max(
      constant dummy : in t_void
    ) return natural;

    --------------------------------------------------------
    -- Statistical SB information

    -- num currently in SB FIFO (not checked yet)
    impure function num_items(
      constant sb_index   : in integer -- index in SB array
    ) return natural;
    impure function num_items(
      constant dummy : in t_void
    ) return natural;

    -- num passed in checks
    impure function num_passed(
      constant sb_index   : in integer -- index in SB array
    ) return natural;
    impure function num_passed(
      constant dummy : in t_void
    ) return natural;

    -- num failed in checks
    impure function num_failed(
      constant sb_index   : in integer -- index in SB array
    ) return natural;
    impure function num_failed(
      constant dummy : in t_void
    ) return natural;

    -- total seen by SB
    impure function num_total(
      constant sb_index   : in integer -- index in SB array
    ) return natural;
    impure function num_total(
      constant dummy : in t_void
    ) return natural;

  end protected;

end package ti_generic_sb_pkg;





package body ti_generic_sb_pkg is



  type t_generic_sb is protected body
    -- Types and control variables for the linked list implementation
    type t_element;
    type t_element_ptr is access t_element;
    type t_element is
      record
        index         : integer;
        tag           : line;
        next_element  : t_element_ptr;
        element_data  : t_generic_element;
      end record;

    -- SB related types
    type t_sb_array           is array(integer range <>) of t_element_ptr;
    type t_sb_array_ptr       is access t_sb_array;
    type t_integer_array      is array(integer range <>) of integer;
    type t_integer_array_ptr  is access t_integer_array;
    type t_natural_array      is array(integer range <>) of natural;
    type t_natural_array_ptr  is access t_natural_array;
    type t_boolean_array      is array(integer range <>) of boolean;
    type t_boolean_array_ptr  is access t_boolean_array;
    type t_string_array       is array(integer range <>) of string(1 to C_LOG_SCOPE_WIDTH);
    type t_string_array_ptr   is access t_string_array;

    variable vr_sb_is_initialized       : boolean := false;

    -- Array of SB pointers
    variable vr_last_element_ptr        : t_sb_array_ptr := new t_sb_array(1 to GC_SB_ARRAY_WIDTH); -- SB array
    variable vr_first_element_ptr       : t_sb_array_ptr := new t_sb_array(1 to GC_SB_ARRAY_WIDTH); -- SB array

    -- Various counters
    variable vr_num_elements_in_sb_fifo : t_natural_array_ptr := new t_natural_array(1 to GC_SB_ARRAY_WIDTH);  --'(1 => 0); -- num currently in SB FIFO
    variable vr_num_elements_seen       : t_natural_array_ptr := new t_natural_array(1 to GC_SB_ARRAY_WIDTH);  --'(1 => 0); -- total seen by SB FIFO
    variable vr_num_elements_passed     : t_natural_array_ptr := new t_natural_array(1 to GC_SB_ARRAY_WIDTH);  --'(1 => 0); -- num checked by SB and passed
    variable vr_num_elements_failed     : t_natural_array_ptr := new t_natural_array(1 to GC_SB_ARRAY_WIDTH);  --'(1 => 0); -- num checked by SB and failed

    -- SB FIFO index number
    variable vr_current_index : t_integer_array_ptr := new t_integer_array(1 to GC_SB_ARRAY_WIDTH); --'(1 => 0);

    -- Scope variables
    variable vr_scope            : string(1 to C_LOG_SCOPE_WIDTH) := (others => NUL);
    variable vr_scope_is_defined : boolean                        := false;

    -- Name variables
    variable vr_name              : t_string_array_ptr  := new t_string_array(1 to GC_SB_ARRAY_WIDTH); --'(1 => (others => NUL));
    variable vr_name_is_defined   : t_boolean_array_ptr := new t_boolean_array(1 to GC_SB_ARRAY_WIDTH); --'(1 => false);

    variable vr_sb_fifo_count_max                 : t_integer_array_ptr := new t_integer_array(1 to GC_SB_ARRAY_WIDTH); --'(1 => GC_SB_FIFO_COUNT_MAX);
    variable vr_sb_fifo_count_threshold           : t_integer_array_ptr := new t_integer_array(1 to GC_SB_ARRAY_WIDTH); --'(1 => GC_SB_FIFO_COUNT_THRESHOLD);
    variable vr_sb_fifo_count_threshold_severity  : t_alert_level := TB_WARNING;

    -- Fill level alert
    type t_sb_fifo_count_threshold_alert_frequency is (ALWAYS, FIRST_TIME_ONLY);
    constant C_ALERT_FREQUENCY                    : t_sb_fifo_count_threshold_alert_frequency := FIRST_TIME_ONLY;
    variable vr_sb_fifo_count_threshold_triggered : t_boolean_array_ptr := new t_boolean_array(1 to GC_SB_ARRAY_WIDTH); --'(1 => false);


    procedure init_sb(
      constant dummy : t_void
    ) is
    begin
      -- init all counters and indicators
      for sb_index in 1 to GC_SB_ARRAY_WIDTH loop
        vr_num_elements_in_sb_fifo(sb_index)            := 0;
        vr_num_elements_seen(sb_index)                  := 0;
        vr_num_elements_passed(sb_index)                := 0;
        vr_num_elements_failed(sb_index)                := 0;
        vr_current_index(sb_index)                      := 0;
        vr_name(sb_index)                               := (others => NUL);
        vr_name_is_defined(sb_index)                    := false;
        vr_sb_fifo_count_max(sb_index)                  := GC_SB_FIFO_COUNT_MAX;
        vr_sb_fifo_count_threshold(sb_index)            := GC_SB_FIFO_COUNT_THRESHOLD;
        vr_sb_fifo_count_threshold_triggered(sb_index)  := false;
      end loop;

      vr_sb_is_initialized := true;
    end procedure init_sb;


    --------------------------------------------------------------------
    -- procedure put() -- add element to SB FIFO
    --
    --   The procedure will add an element to a SB FIFO.
    --   If an array of SBs are used, the SB index has to be set.
    --   Adding a tag to the SB item is optional.
    --
    --------------------------------------------------------------------
    procedure put(
      constant element  : in t_generic_element; -- generic element
      constant tag      : in string;            -- element tag
      constant sb_index : in integer            -- index in SB array
    ) is
      variable v_previous_ptr : t_element_ptr;
      variable v_tag_ptr      : line;
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "put: SB not initialized", vr_scope, ID_NEVER);
      check_value(vr_scope_is_defined, TB_WARNING, "put: Scope name must be defined for this generic SB", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "put: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      -- check awailable space in SB FIFO
      if( (vr_sb_fifo_count_threshold(sb_index) /= 0) and
        (vr_num_elements_in_sb_fifo(sb_index) >= vr_sb_fifo_count_threshold(sb_index))) then
        if((C_ALERT_FREQUENCY = ALWAYS) or (C_ALERT_FREQUENCY = FIRST_TIME_ONLY and not vr_sb_fifo_count_threshold_triggered(sb_index))) then
          alert(vr_sb_fifo_count_threshold_severity, "SB FIFO is now at " & to_string(vr_sb_fifo_count_threshold(sb_index)) & " of "
                                                      & to_string(vr_sb_fifo_count_max(sb_index)) & " elements.", vr_scope);
          vr_sb_fifo_count_threshold_triggered(sb_index) := true;
        end if;
      end if;
      check_value(vr_num_elements_in_sb_fifo(sb_index) < vr_sb_fifo_count_max(sb_index), TB_ERROR,
                  "put() into generic SB (of size " & to_string(vr_sb_fifo_count_max(sb_index)) & ") when full", vr_scope, ID_NEVER);

      -- Increment SB FIFO element index
      vr_current_index(sb_index) := vr_current_index(sb_index) + 1;
      -- Set read and write pointers when appending element to existing list
      v_tag_ptr := new string'(tag);
      if vr_num_elements_in_sb_fifo(sb_index) > 0 then
        v_previous_ptr                := vr_last_element_ptr(sb_index);
        vr_last_element_ptr(sb_index) := new t_element'(next_element  => null,
                                                      element_data  => element,
                                                      tag           => v_tag_ptr,
                                                      index         => vr_current_index(sb_index));
        v_previous_ptr.next_element := vr_last_element_ptr(sb_index);     -- Insert the new element into the linked list
      else -- List is empty
        vr_last_element_ptr(sb_index) := new t_element'(next_element  => null,
                                                      element_data  => element,
                                                      tag           => v_tag_ptr,
                                                      index         => vr_current_index(sb_index));
        vr_first_element_ptr(sb_index) := vr_last_element_ptr(sb_index);     -- Update read pointer, since this is the first and only element in the list.
      end if;

      -- Increment counters
      vr_num_elements_in_sb_fifo(sb_index)  := vr_num_elements_in_sb_fifo(sb_index) + 1; -- currently in FIFO
      vr_num_elements_seen(sb_index)        := vr_num_elements_seen(sb_index) + 1;       -- total seen by FIFO
    end procedure put;

    --
    -- Array of SBs with no tag
    --
    procedure put(
      constant element  : in t_generic_element; -- generic element
      constant sb_index : in integer            -- index in SB array
    ) is
    begin
      put(element, "", sb_index);
    end procedure put;

    --
    -- Single SB with tag
    --
    procedure put(
      constant element  : in t_generic_element; -- generic element
      constant tag      : in string             -- element tag
    ) is
    begin
      put(element, tag, 1);
    end procedure put;

    --
    -- Single SB and no tag
    --
    procedure put(
      constant element  : in t_generic_element  -- generic element
    ) is
    begin
      put(element, "", 1);
    end procedure put;


    --------------------------------------------------------
    -- function check() - Compare item with SB FIFO
    --
    --   This will compare the expected_element with the oldest
    --   item and remove the item from the SB FIFO.
    --   When using more than one SB, the SB index has to
    --   be set (default is first).
    --
    --------------------------------------------------------
    impure function check(
      constant expected_element : in t_generic_element; -- generic element
      constant tag              : in string;            -- element tag
      constant sb_index         : integer               -- index in SB array
    ) return boolean is
      -- helper variables
      variable v_actual_element       : t_generic_element;
      variable v_current_element_ptr  : t_element_ptr     := vr_first_element_ptr(sb_index);
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "check: SB not initialized", vr_scope, ID_NEVER);
      check_value(vr_scope_is_defined, TB_WARNING, "check: Scope name must be defined for this generic SB", vr_scope, ID_NEVER);
      check_value(vr_num_elements_in_sb_fifo(sb_index) > 0, TB_ERROR, "check: out of generic SB when empty", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "check: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      -- update SB counter for elements put and checked
      vr_num_elements_seen(sb_index) := vr_num_elements_seen(sb_index) + 1;

      if vr_num_elements_in_sb_fifo(sb_index) > 0 then
        v_actual_element := vr_first_element_ptr(sb_index).element_data; -- default

        -- find oldest element with set tag
        if tag /= "" then
          while v_current_element_ptr /= NULL loop
            if v_current_element_ptr.tag.all = tag then
              v_actual_element := v_current_element_ptr.element_data;
              exit;
            else
              v_current_element_ptr := v_current_element_ptr.next_element;
            end if;
          end loop;
        end if;

        -- remove if found
        if (expected_element = v_actual_element) and ( (v_current_element_ptr.tag.all = tag) or (tag = "") ) then
          vr_num_elements_passed(sb_index) := vr_num_elements_passed(sb_index) + 1;
          remove(tag, sb_index); -- remove element from FIFO
          return true;
        end if;
      end if;

      -- not found
      vr_num_elements_failed(sb_index) := vr_num_elements_failed(sb_index) + 1;
      return false;
    end function check;

    --
    -- Single SB with tag
    --
    impure function check(
      constant expected_element : in t_generic_element; -- generic element
      constant tag              : in string             -- element tag
    ) return boolean is
    begin
      return check(expected_element, tag, 1);
    end function check;

    --
    -- Array of SBs, no tag
    --
    impure function check(
      constant expected_element : in t_generic_element; -- generic element
      constant sb_index         : in integer            -- index in SB array
    ) return boolean is
      variable v_check_result : boolean;
    begin
      return check(expected_element, "", sb_index);
    end function check;

     --
     -- Single SB, no tag
     --
    impure function check(
      constant expected_element : in t_generic_element  -- generic element
    ) return boolean is
    begin
      return check(expected_element, "", 1);
    end function check;


    --------------------------------------------------------
    -- procedure remove() - remove element from SB FIFO
    --
    --   Will remove an element from the SB FIFO without
    --   checking.
    --   Passing an empty tag will remove oldest element,
    --   regardless of tag.
    --   SB index 1 is used for single SB.
    --
    --------------------------------------------------------
    procedure remove(
      constant tag      : in string; -- element tag (will remove oldest element with this tag)
      constant sb_index : in integer -- index in SB array
    ) is
      -- helper variables
      variable v_current_ptr  : t_element_ptr := vr_first_element_ptr(sb_index);
      variable v_previous_ptr : t_element_ptr; -- := vr_first_element_ptr(sb_index);
      variable v_next_ptr     : t_element_ptr;
      variable v_tag_found    : boolean := false;
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "remove: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "remove: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);
      check_value(vr_scope_is_defined, TB_WARNING, "remove: Scope name must be defined for this generic SB", vr_scope, ID_NEVER);
      check_value(vr_num_elements_in_sb_fifo(sb_index) > 0, TB_ERROR, "remove: from generic SB when empty", vr_scope, ID_NEVER);

      if vr_num_elements_in_sb_fifo(sb_index) > 0 then
        -- find by tag
        while v_current_ptr /= NULL loop
          if v_current_ptr.tag.all = tag then
            v_next_ptr  := v_current_ptr.next_element;
            v_tag_found := true;
            exit;
          else
            v_previous_ptr := v_current_ptr;
          end if;
        end loop;

        -- remove from FIFO
        if v_tag_found then
          if v_previous_ptr /= NULL then -- not oldest element in FIFO
            v_previous_ptr.next_element := v_next_ptr;
            DEALLOCATE(v_current_ptr);
          else -- oldest element in FIFO
            vr_first_element_ptr(sb_index) := v_next_ptr;
          end if;

          -- Decrement number of elements
          vr_num_elements_in_sb_fifo(sb_index)  := vr_num_elements_in_sb_fifo(sb_index) - 1;
        end if;
      end if;
    end procedure remove;

    --
    -- Remove oldest element in indexed SB in array
    --
    procedure remove(
      constant sb_index : in integer -- index in SB array
    ) is
    begin
      remove("", sb_index);
    end procedure remove;

    --
    -- Remove oldest element in single SB
    --
    procedure remove(
      dummy : t_void
    ) is
    begin
      remove("", 1);
    end procedure remove;

    --------------------------------------------------------
    -- function peek() - look at element in SB FIFO
    --
    --   Will return an element located at given index
    --   without removing it.
    --   Oldest element in SB FIFO will be returned if no
    --   element is located at given index.
    --   If array of SBs, the SB index has to be set.
    --
    --------------------------------------------------------
    impure function peek(
      constant sb_fifo_index  : in integer; -- index in SB FIFO
      constant sb_index       : in integer  -- index in SB array
    ) return t_generic_element is
      -- helper variables
      variable v_current_ptr    : t_element_ptr := vr_first_element_ptr(sb_index);
      variable v_return_element : t_generic_element;
      variable v_idx            : natural := 1;
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "peek: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "peek: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);
      check_value(vr_scope_is_defined, TB_WARNING, "peek: Scope name must be defined for this generic SB", vr_scope, ID_NEVER);
      check_value(vr_num_elements_in_sb_fifo(sb_index) > 0, TB_ERROR, "peek: in generic SB when empty", vr_scope, ID_NEVER);

      if vr_num_elements_in_sb_fifo(sb_index) > 0 then
        v_return_element := vr_first_element_ptr(sb_index).element_data; -- oldest element is default return

        while (v_current_ptr /= NULL) and (v_idx < sb_fifo_index) loop
          v_current_ptr := v_current_ptr.next_element;
          v_idx := v_idx + 1;
        end loop;

      end if;

      -- update return if element at given index was found
      if v_idx > 0 then
        v_return_element := v_current_ptr.element_data;
      end if;

      return v_return_element;
    end function peek;

    --
    -- Peek at indexed element in single SB
    --
    impure function peek(
      constant sb_fifo_index  : in integer -- index in SB FIFO
    ) return t_generic_element is
    begin
      -- SB array index 1 is used for single SB
      return peek(sb_fifo_index, 1);
    end function peek;

    --
    -- Peek at oldest element in single SB
    --
    impure function peek(
      constant dummy  : in t_void
    ) return t_generic_element is
    begin
      -- SB array index 1 is used for single SB
      return peek(1, 1);
    end function peek;

    --------------------------------------------------------
    -- function exist() - check if element is in SB FIFO
    --
    --   Will return true if element found and false if not.
    --   Search for SB FIFO index or tag.
    --
    --------------------------------------------------------
    impure function exist(
      constant element        : in t_generic_element; -- generic element
      constant tag            : in string;            -- element tag
      constant sb_index       : in integer            -- index in SB array
    ) return boolean is
      -- helper variables

    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "exist: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "exist: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);



      return false;
    end function exist;

    --
    -- Check if an element with tag exist, single SB.
    --
    impure function exist(
      constant element  : in t_generic_element; -- generic element
      constant tag      : in string             -- element tag
    ) return boolean is
    begin
      return exist(element, tag, 1);
    end function exist;

    --
    -- Check if an element exist at SB FIFO index,
    -- indexed SB in array of SBs.
    --
    impure function exist(
      constant element : in t_generic_element -- generic element
    ) return boolean is
    begin
      -- to do - loop all elements in SB FIFO
      return exist(element, "", 1);
    end function exist;


    --------------------------------------------------------------------
    -- function get() - get element from SB FIFO
    --
    --   Will return element and remove it from the SB FIFO.
    --   Use index 1 for non-array SB.
    --
    --------------------------------------------------------------------
    impure function get(
      constant sb_index : in integer
    ) return t_generic_element is
      variable v_element                : t_generic_element;
      variable v_to_be_deallocated_ptr  : t_element_ptr;
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "get: SB not initialized", vr_scope, ID_NEVER);
      check_value(vr_scope_is_defined, TB_WARNING, "get: Scope name must be defined for this generic SB", vr_scope, ID_NEVER);
      check_value(vr_num_elements_in_sb_fifo(sb_index) > 0, TB_ERROR, "get: out of generic SB when empty", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "get: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      if(vr_num_elements_in_sb_fifo(sb_index) < vr_sb_fifo_count_threshold(sb_index)) then
        -- reset alert trigger if set
        vr_sb_fifo_count_threshold_triggered(sb_index) := false;
      end if;

      if vr_num_elements_in_sb_fifo(sb_index) > 0 then
        v_element                       := vr_first_element_ptr(sb_index).element_data;
        v_to_be_deallocated_ptr         := vr_first_element_ptr(sb_index);
        vr_first_element_ptr(sb_index)  := vr_first_element_ptr(sb_index).next_element; -- Update read pointer. If no new item in list, the read pointer will be NULL.
        -- Decrement number of elements
        vr_num_elements_in_sb_fifo(sb_index)  := vr_num_elements_in_sb_fifo(sb_index) - 1;

        -- Memory management
        DEALLOCATE(v_to_be_deallocated_ptr);
      end if;

      return v_element;
    end function get;

    --
    -- Single SB get
    --
    impure function get(
      constant dummy : in t_void
    ) return t_generic_element is
    begin
      return get(1);
    end function get;


    --------------------------------------------------------------------
    -- procedure flush() - empty SB FIFO
    --
    --   Will remove all content from indexed SB FIFO.
    --   Use index 1 for a non-array SB.
    --
    --------------------------------------------------------------------
    procedure flush(
      constant sb_index : integer -- index in SB array
      ) is
      variable v_to_be_deallocated_ptr  : t_element_ptr;
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "flush: SB not initialized", vr_scope, ID_NEVER);
      check_value(vr_scope_is_defined, TB_WARNING, "Scope name must be defined for this generic SB", "???", ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "flush: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      -- Deallocate all entries in the list
      -- Setting the last element to null and iterating over the SB FIFO until finding the null element
      vr_last_element_ptr(sb_index) := null;
      while vr_first_element_ptr(sb_index) /= null loop
        v_to_be_deallocated_ptr         := vr_first_element_ptr(sb_index);
        vr_first_element_ptr(sb_index)  := vr_first_element_ptr(sb_index).next_element;
        DEALLOCATE(v_to_be_deallocated_ptr);
      end loop;

      -- Reset the SB FIFO counter
      vr_num_elements_in_sb_fifo(sb_index)  := 0; -- currently in SB FIFO
      vr_num_elements_failed(sb_index)      := 0; -- checked and failed
      vr_num_elements_passed(sb_index)      := 0; -- checked and passed
      vr_num_elements_seen(sb_index)        := 0; -- total num seen
      vr_sb_fifo_count_threshold_triggered(sb_index) := false;
    end procedure flush;

    --
    -- Single SB flush
    --
    procedure flush(
      void : t_void
    ) is
    begin
      flush(1);
    end procedure flush;


    --------------------------------------------------------------------
    -- function is_empty() - check if SB FIFO has content
    --
    --   Will return true if SB FIFO has content and false unless.
    --   Use index 1 for non-array SB.
    --
    --------------------------------------------------------------------
    impure function is_empty(
      constant sb_index : integer -- index in SB array
    ) return boolean is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "is_empty: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "is_empty: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      if vr_num_elements_in_sb_fifo(sb_index) = 0 then
        return true;
      else
        return false;
      end if;
    end function;

    --
    -- Check if single SB is empty
    --
    impure function is_empty(
      constant dummy : in t_void
    ) return boolean is
    begin
      return is_empty(1);
    end function;


    --------------------------------------------------------------------
    -- function is_not_empty() - check if SB FIFO has content
    --
    --   Will return false if SB FIFO has content and true unless.
    --   Use index 1 for non-array SB.
    --
    --------------------------------------------------------------------
    impure function is_not_empty(
      constant sb_index : integer -- index in SB array
    ) return boolean is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "is_not_empty: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "is_not_empty: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return not is_empty(sb_index);
    end function is_not_empty;

    --
    -- Check if single SB is not empty
    --
    impure function is_not_empty(
      constant dummy : in t_void
    ) return boolean is
    begin
      return not is_empty(VOID);
    end function;


    --------------------------------------------------------------------
    -- procedure set_scope() - set SB scope
    --
    --   Set SB scope.
    --   Scope is common for all SBs in array.
    --
    --------------------------------------------------------------------
    procedure set_scope(
      constant scope : in string
    ) is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "set_scope: SB not initialized", vr_scope, ID_NEVER);

      vr_scope(1 to scope'length)  := scope;
      vr_scope_is_defined          := true;
    end procedure set_scope;


    --------------------------------------------------------------------
    -- function get_scope() - get SB scope
    --
    --   Get scope of SB.
    --   Scope is common for all SBs in array.
    --
    --------------------------------------------------------------------
    impure function get_scope(
      constant dummy : in t_void
    ) return string is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "get_scope: SB not initialized", vr_scope, ID_NEVER);

      return to_string(vr_scope);
    end function get_scope;


    --------------------------------------------------------------------
    -- procedure set_name() - set name of SB
    --
    --   Set name of SB.
    --   Use index 1 for non-array SB.
    --
    --------------------------------------------------------------------
    procedure set_name(
      constant name     : in string;
      constant sb_index : in integer
    ) is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "set_name: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "set_name: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      vr_name(sb_index)(1 to name'length)  :=name;
      vr_name_is_defined(sb_index)         := true;
    end procedure set_name;

    --
    -- Single SB
    --
    procedure set_name(
      constant name : in string
    ) is
    begin
      set_name(name, 1);
    end procedure set_name;


    --------------------------------------------------------------------
    -- function get_name() - get name of SB
    --
    --   Get name of SB.
    --   Use index 1 for non-array SB.
    --
    --------------------------------------------------------------------
    impure function get_name(
      constant sb_index : in integer
    ) return string is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "get_name: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "get_name: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return vr_name(sb_index);
    end function get_name;

    --
    -- Single SB
    --
    impure function get_name(
      constant dummy : in t_void
    ) return string is
    begin
      return get_name(1);
    end function get_name;


    --------------------------------------------------------------------
    -- function get_count() - get number of elements in SB FIFO
    --
    --   Get the number of elements in the SB FIFO.
    --
    --------------------------------------------------------------------
    impure function get_count(
      constant sb_index : in integer -- index in SB array
    ) return natural is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "get_count: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "get_count: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return vr_num_elements_in_sb_fifo(sb_index);
    end function get_count;

    --
    -- Single SB
    --
    impure function get_count(
      constant dummy : in t_void
    ) return natural is
    begin
      return vr_num_elements_in_sb_fifo(1);
    end function get_count;


    --------------------------------------------------------------------
    -- procedure set_sb_cout_max() - set maximum SB FIFO width
    --
    --   Will set the maximum with for the FIFO in the SB.
    --
    --------------------------------------------------------------------
    procedure set_sb_count_max(
      constant sb_index           : in integer; -- index in SB array
      constant sb_fifo_count_max  : in natural  -- SB FIFO maximum with
    ) is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "set_sb_count_max: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "sb_set_count_max: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      vr_sb_fifo_count_max(sb_index) := sb_fifo_count_max;
      check_value(vr_num_elements_in_sb_fifo(sb_index) < vr_sb_fifo_count_max(sb_index), TB_ERROR,
                 "set_sb_count_max() new SB FIFO max count (" & to_string(vr_sb_fifo_count_max(sb_index)) & ") is less than current SB FIFO count(" & to_string(vr_num_elements_in_sb_fifo(sb_index)) & ").", vr_scope, ID_NEVER);
    end procedure set_sb_count_max;

    --
    -- Single SB
    --
    procedure set_sb_count_max(
      constant sb_fifo_count_max : in natural -- SB FIFO maximum width
    ) is
    begin
      set_sb_count_max(1, sb_fifo_count_max);
    end procedure set_sb_count_max;


    --------------------------------------------------------------------
    -- function get_sb_count_max() - get maximum SB FIFO width
    --
    --   Will return the maximum with for the FIFO in the SB.
    --
    --------------------------------------------------------------------
    impure function get_sb_count_max(
      constant sb_index : integer -- index in SB array
    ) return natural is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "get_sb_count_max: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "get_sb_count_max: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return vr_sb_fifo_count_max(sb_index);
    end function get_sb_count_max;

    --
    -- Single SB
    --
    impure function get_sb_count_max(
      constant dummy : in t_void
    ) return natural is
    begin
      return get_sb_count_max(1);
    end function get_sb_count_max;


    --------------------------------------------------------------------
    -- procedure set_sb_count_threshold() - set the SB FIFO threshold
    --
    --   Will set the alert level threshold for the SB FIFO.
    --
    --------------------------------------------------------------------
    procedure set_sb_count_threshold(
      constant sb_index                   : in integer; -- index in SB array
      constant sb_fifo_count_alert_level  : in natural  -- threshold
    ) is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "set_sb_count_threshold: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "set_sb_count_threshold: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      vr_sb_fifo_count_threshold(sb_index) := sb_fifo_count_alert_level;
    end procedure set_sb_count_threshold;

    --
    -- Single SB
    --
    procedure set_sb_count_threshold(
      constant sb_fifo_count_alert_level : in natural -- threshold
    ) is
    begin
      set_sb_count_threshold(1, sb_fifo_count_alert_level);
    end procedure set_sb_count_threshold;


    --------------------------------------------------------------------
    -- function get_sb_count_threshold() - get the SB FIFO threshold
    --
    --   Will return the alert level threshold for the SB FIFO
    --
    --------------------------------------------------------------------
    impure function get_sb_count_threshold(
      constant sb_index : in integer -- index in SB array
    ) return natural is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "get_sb_count_threshold: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "get_sb_count_threshold: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return vr_sb_fifo_count_threshold(sb_index);
    end function get_sb_count_threshold;

    --
    -- Single SB
    --
    impure function get_sb_count_threshold(
      constant dummy : in t_void
    ) return natural is
    begin
      return get_sb_count_threshold(1);
    end function get_sb_count_threshold;


    --------------------------------------------------------------------
    -- procedure set_sb_count_threshold_severity() - set severity for
    --                                               threshold limit.
    --
    --   Will set the alert level for SB FIFO threshold limit.
    --   Alert level is common for all SBs.
    --
    --------------------------------------------------------------------
    procedure set_sb_count_threshold_severity(
      constant alert_level : in t_alert_level) is
    begin
      vr_sb_fifo_count_threshold_severity := alert_level;
    end procedure set_sb_count_threshold_severity;


    --------------------------------------------------------------------
    -- function get_sb_count_threshold_severity() - get severity for
    --                                              threshold limit.
    --
    --   Will return the alert level for SB FIFO threshold limit.
    --   Alert level is common for all SBs.
    --
    --------------------------------------------------------------------
    impure function get_sb_count_threshold_severity(
      constant dummy : in t_void
    ) return t_alert_level is
    begin
      return vr_sb_fifo_count_threshold_severity;
    end function get_sb_count_threshold_severity;



    --------------------------------------------------------------------
    -- function num_items() - number of elements in SB FIFO
    --
    --  Will return the number of elements currently in the SB FIFO,
    --  that is elements yet not checked by the SB.
    --
    --------------------------------------------------------------------
    impure function num_items(
      constant sb_index   : in integer -- index in SB array
    ) return natural is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "num_items: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "num_items: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return vr_num_elements_in_sb_fifo(sb_index);
    end function num_items;

    --
    -- Single SB
    --
    impure function num_items(
      constant dummy : in t_void
    ) return natural is
    begin
      return num_items(1);
    end function num_items;

    --------------------------------------------------------------------
    -- function num_passed() - number of items checked and passed.
    --
    --   Will return the number of items checked and passed by the SB.
    --
    --------------------------------------------------------------------
    impure function num_passed(
      constant sb_index   : in integer -- index in SB array
    ) return natural is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "num_passed: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "num_passed: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return vr_num_elements_passed(sb_index);
    end function num_passed;

    --
    -- Single SB
    --
    impure function num_passed(
      constant dummy : in t_void
    ) return natural is
    begin
      return num_passed(1);
    end function num_passed;

    --------------------------------------------------------------------
    -- function num_failed() - number of items checked and failed
    --
    --   Will return the number of items checked and failed by the SB.
    --
    --------------------------------------------------------------------
    impure function num_failed(
      constant sb_index   : in integer -- index in SB array
    ) return natural is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "num_failed: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "num_failed: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return vr_num_elements_failed(sb_index);
    end function num_failed;

    --
    -- Single SB
    --
    impure function num_failed(
      constant dummy : in t_void
    ) return natural is
    begin
      return num_failed(1);
    end function num_failed;

    --------------------------------------------------------------------
    -- function num_total() - number of items seen by SB FIFO
    --
    --   Will return the total number of elements seen by the SB FIFO.
    --   The counter will increment for each put() and check() command.
    --
    --------------------------------------------------------------------
    impure function num_total(
      constant sb_index   : in integer -- index in SB array
    ) return natural is
    begin
      -- basic checking
      check_value(vr_sb_is_initialized, TB_ERROR, "num_total: SB not initialized", vr_scope, ID_NEVER);
      check_value((sb_index <= GC_SB_ARRAY_WIDTH) and (sb_index > 0), TB_ERROR, "num_total: SB index must be within range 1 to " & to_string(GC_SB_ARRAY_WIDTH), vr_scope, ID_NEVER);

      return vr_num_elements_seen(sb_index);
    end function num_total;

    --
    -- Single SB
    --
    impure function num_total(
      constant dummy : in t_void
    ) return natural is
    begin
      return num_total(1);
    end function num_total;

  end protected body;



end package body ti_generic_sb_pkg;

