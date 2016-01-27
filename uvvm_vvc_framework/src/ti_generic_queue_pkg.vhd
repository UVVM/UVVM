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

package ti_generic_queue_pkg is

generic (type t_generic_element; 
         GC_QUEUE_COUNT_MAX       : natural := 1000;
         GC_QUEUE_COUNT_THRESHOLD : natural := 950);

-- A generic queue for verification
type t_generic_queue is protected
  procedure put(
    constant element : in t_generic_element);
  impure function get(
    constant dummy : in t_void)
    return t_generic_element;
  impure function is_empty(
    constant dummy : in t_void)
    return boolean;
  impure function is_not_empty(
    constant dummy : in t_void)
    return boolean;
  procedure set_scope(
    constant scope : in string);
  impure function get_scope(
    constant dummy : in t_void)
    return string;
  impure function get_count(
    constant dummy : in t_void)
    return natural;
  procedure set_queue_count_threshold(
    constant queue_count_alert_level : in natural);
  impure function get_queue_count_threshold(
    constant dummy : in t_void) return natural;
  impure function get_queue_count_threshold_severity(
    constant dummy : in t_void) return t_alert_level;
  procedure set_queue_count_threshold_severity(
    constant alert_level : in t_alert_level);
  impure function get_queue_count_max(
    constant dummy : in t_void) return natural;
  procedure set_queue_count_max(
    constant queue_count_max : in natural);
  procedure flush(
    void : t_void
    );
end protected;

end package ti_generic_queue_pkg;

package body ti_generic_queue_pkg is

type t_generic_queue is protected body

  -- Types and control variables for the linked list implementation
  type t_element;
  type t_element_ptr is access t_element;
  type t_element is 
    record
      next_element  : t_element_ptr;
      element_data  : t_generic_element;
    end record;
  
  variable vr_last_element_ptr      : t_element_ptr;
  variable vr_first_element_ptr     : t_element_ptr;
  variable vr_num_elements_in_queue : natural := 0;
  
  -- Scope variables
  variable vr_scope            : string(1 to 30)   := (others => NUL);
  variable vr_scope_is_defined : boolean           := false;
  
  variable vr_queue_count_max : natural := GC_QUEUE_COUNT_MAX;
  variable vr_queue_count_threshold : natural := GC_QUEUE_COUNT_THRESHOLD;
  variable vr_queue_count_threshold_severity : t_alert_level := TB_WARNING;
  
  -- Fill level alert
  type t_queue_count_threshold_alert_frequency is (ALWAYS, FIRST_TIME_ONLY);
  constant C_ALERT_FREQUENCY : t_queue_count_threshold_alert_frequency := FIRST_TIME_ONLY;
  variable vr_queue_count_threshold_triggered : boolean := false;
  
  
  procedure put(
    constant element : in t_generic_element
  ) is
    variable v_previous_ptr : t_element_ptr;
  begin
    check_value(vr_scope_is_defined, TB_WARNING, "Scope name must be defined for this generic queue", "???", ID_NEVER);
    
    if((vr_queue_count_threshold /= 0) and (vr_num_elements_in_queue >= vr_queue_count_threshold)) then
      if((C_ALERT_FREQUENCY = ALWAYS) or (C_ALERT_FREQUENCY = FIRST_TIME_ONLY and not vr_queue_count_threshold_triggered)) then
        alert(vr_queue_count_threshold_severity, "Queue is now at " & to_string(vr_queue_count_threshold) & " of " & to_string(vr_queue_count_max) & " elements.", vr_scope);
        vr_queue_count_threshold_triggered := true;
      end if;
    end if;
    check_value(vr_num_elements_in_queue < vr_queue_count_max, TB_ERROR, "put() into generic queue (of size " & to_string(vr_queue_count_max) & ") when full", vr_scope, ID_NEVER);
    
    -- Set read and write pointers when appending element to existing list
    if vr_num_elements_in_queue > 0 then
      v_previous_ptr              := vr_last_element_ptr;
      vr_last_element_ptr         := new t_element'(next_element => null, element_data => element);
      v_previous_ptr.next_element := vr_last_element_ptr;     -- Insert the new element into the linked list
    else -- List is empty
      vr_last_element_ptr         := new t_element'(next_element => null, element_data => element);
      vr_first_element_ptr        := vr_last_element_ptr;     -- Update read pointer, since this is the first and only element in the list.
    end if;
    
    -- Increment number of elements
    vr_num_elements_in_queue := vr_num_elements_in_queue + 1;
  end procedure;


  impure function get(
    constant dummy : in t_void
  ) return t_generic_element is
    variable v_element                : t_generic_element;
    variable v_to_be_deallocated_ptr  : t_element_ptr; 
  begin
    check_value(vr_scope_is_defined, TB_WARNING, "Scope name must be defined for this generic queue", "???", ID_NEVER);
    check_value(vr_num_elements_in_queue > 0, TB_ERROR, "get() out of generic queue when empty", vr_scope, ID_NEVER);

    if(vr_num_elements_in_queue < vr_queue_count_threshold) then
      -- reset alert trigger if set
      vr_queue_count_threshold_triggered := false;
    end if;
    
    if vr_num_elements_in_queue > 0 then
      v_element                 := vr_first_element_ptr.element_data;
      v_to_be_deallocated_ptr   := vr_first_element_ptr;
      vr_first_element_ptr      := vr_first_element_ptr.next_element; -- Update read pointer. If no new item in list, the read pointer will be NULL.
      -- Decrement number of elements
      vr_num_elements_in_queue  := vr_num_elements_in_queue - 1;
      
      -- Memory management
      DEALLOCATE(v_to_be_deallocated_ptr);
    end if;
    
    return v_element;
  end function;

  
  procedure flush(
    void : t_void
    ) is
    variable v_to_be_deallocated_ptr  : t_element_ptr;
  begin
    check_value(vr_scope_is_defined, TB_WARNING, "Scope name must be defined for this generic queue", "???", ID_NEVER);
    
    -- Deallocate all entries in the list
    -- Setting the last element to null and iterating over the queue until finding the null element
    vr_last_element_ptr := null;
    while vr_first_element_ptr /= null loop
      v_to_be_deallocated_ptr   := vr_first_element_ptr;
      vr_first_element_ptr      := vr_first_element_ptr.next_element;
      DEALLOCATE(v_to_be_deallocated_ptr);
    end loop;
    
    -- Reset the queue counter
    vr_num_elements_in_queue := 0;
    vr_queue_count_threshold_triggered := false;
  end procedure;

  impure function is_empty(
    constant dummy : in t_void
  ) return boolean is
  begin
    if vr_num_elements_in_queue = 0 then
      return true;
    else
      return false;
    end if;
  end function;


  impure function is_not_empty(
    constant dummy : in t_void
  ) return boolean is
  begin
    return not is_empty(VOID);
  end function;

  
  procedure set_scope(
    constant scope : in string) is
  begin
    vr_scope(1 to scope'length)  := scope;
    vr_scope_is_defined          := true;
  end procedure;

  
  impure function get_scope(
    constant dummy : in t_void
  ) return string is
  begin
    return to_string(vr_scope);
  end function;
  
  impure function get_count(
    constant dummy : in t_void
  ) return natural is
  begin
    return vr_num_elements_in_queue;
  end function;
  

  impure function get_queue_count_max(
    constant dummy : in t_void
  ) return natural is
  begin
    return vr_queue_count_max;
  end function;
  
  
  procedure set_queue_count_max(
    constant queue_count_max : in natural) is
  begin
    vr_queue_count_max := queue_count_max;
    check_value(vr_num_elements_in_queue < vr_queue_count_max, TB_ERROR, "set_queue_count_max() new queue max count (" & to_string(vr_queue_count_max) & ") is less than current queue count(" & to_string(vr_num_elements_in_queue) & ").", vr_scope, ID_NEVER);
  end procedure;
    
  
  procedure set_queue_count_threshold(
    constant queue_count_alert_level : in natural) is
  begin
    vr_queue_count_threshold := queue_count_alert_level;
  end procedure;
  
    
  impure function get_queue_count_threshold(
    constant dummy : in t_void
  ) return natural is
  begin
    return vr_queue_count_threshold;
  end function;
    
    
  impure function get_queue_count_threshold_severity(
    constant dummy : in t_void
  ) return t_alert_level is 
  begin
    return vr_queue_count_threshold_severity;
  end function;
    
    
  procedure set_queue_count_threshold_severity(
    constant alert_level : in t_alert_level) is
  begin
    vr_queue_count_threshold_severity := alert_level;
  end procedure;
    
end protected body;

end package body ti_generic_queue_pkg;

