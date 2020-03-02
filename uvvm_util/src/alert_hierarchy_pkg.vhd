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
use std.env.all;

use work.types_pkg.all;
use work.protected_types_pkg.all;
use work.hierarchy_linked_list_pkg.all;
use work.string_methods_pkg.all;
use work.adaptations_pkg.all;

package alert_hierarchy_pkg is

  shared variable global_hierarchy_tree : t_hierarchy_linked_list;

  procedure initialize_hierarchy(
      constant base_scope : string := C_BASE_HIERARCHY_LEVEL;
      constant stop_limit : t_alert_counters := (others => 0)
    );

  procedure add_to_alert_hierarchy(
    constant scope : string;
    constant parent_scope : string := C_BASE_HIERARCHY_LEVEL;
    constant stop_limit : t_alert_counters := (others => 0)
    );

  procedure set_hierarchical_alert_top_level_stop_limit(
    constant alert_level : t_alert_level;
    constant value : natural
    );

  impure function get_hierarchical_alert_top_level_stop_limit(
    constant alert_level : t_alert_level
    ) return natural;

  procedure hierarchical_alert(
    constant alert_level: t_alert_level;
    constant msg : string;
    constant scope : string;
    constant attention : t_attention
    );

  procedure increment_expected_alerts(
    constant scope : string;
    constant alert_level: t_alert_level;
    constant amount : natural := 1
    );

  procedure set_expected_alerts(
    constant scope : string;
    constant alert_level: t_alert_level;
    constant expected_alerts : natural
    );

  procedure increment_stop_limit(
    constant scope : string;
    constant alert_level: t_alert_level;
    constant amount : natural := 1
    );

  procedure set_stop_limit(
    constant scope : string;
    constant alert_level: t_alert_level;
    constant stop_limit : natural
    );

  procedure print_hierarchical_log(
    constant order : t_order := FINAL
  );

  procedure clear_hierarchy(
    constant VOID : t_void
  );


end package alert_hierarchy_pkg;

package body alert_hierarchy_pkg is

  procedure initialize_hierarchy(
    constant base_scope : string := C_BASE_HIERARCHY_LEVEL;
    constant stop_limit : t_alert_counters := (others => 0)
  ) is
  begin
    global_hierarchy_tree.initialize_hierarchy(justify(base_scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH), stop_limit);
  end procedure;

  procedure add_to_alert_hierarchy(
    constant scope : string;
    constant parent_scope : string := C_BASE_HIERARCHY_LEVEL;
    constant stop_limit : t_alert_counters := (others => 0)
    ) is
    variable v_scope : string(1 to C_HIERARCHY_NODE_NAME_LENGTH) := justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
    variable v_parent_scope : string(1 to C_HIERARCHY_NODE_NAME_LENGTH) := justify(parent_scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH);
    variable v_hierarchy_node : t_hierarchy_node;
    variable v_found : boolean := false;
  begin
      global_hierarchy_tree.contains_scope_return_data(v_scope, v_found, v_hierarchy_node);
      if v_found then
        -- Scope already in tree.

        -- If the new parent is not C_BASE_HIERARCHY_LEVEL, change parent.
        -- The reason is that a child should be able to register itself
        -- with C_BASE_HIERARCHY_LEVEL as parent. The actual parent can then
        -- override the registration with a new parent_scope. However, the other
        -- way should not be possible. I.e., a child registration should not be able
        -- to override a parent registration later. That means that parents can't be
        -- changed back to base level once another parent_scope has been chosen.
        if v_parent_scope /= justify(C_BASE_HIERARCHY_LEVEL, LEFT, C_HIERARCHY_NODE_NAME_LENGTH) then
          -- Verify that new parent is in tree. If not, the old parent will be kept.
          global_hierarchy_tree.change_parent(v_scope, v_parent_scope);
        end if;

      else
        -- Scope not in tree. Check if parent is in tree. Set node data if
        -- parent is in tree.
        v_hierarchy_node := (v_scope, (others => (others => 0)), stop_limit, (others => true));
        global_hierarchy_tree.insert_in_tree(v_hierarchy_node, v_parent_scope);
      end if;
  end procedure;

  procedure set_hierarchical_alert_top_level_stop_limit(
    constant alert_level : t_alert_level;
    constant value : natural
    ) is
  begin
    global_hierarchy_tree.set_top_level_stop_limit(alert_level, value);
  end procedure;

  impure function get_hierarchical_alert_top_level_stop_limit(
    constant alert_level : t_alert_level
    ) return natural is
  begin
    return global_hierarchy_tree.get_top_level_stop_limit(alert_level);
  end function;

  procedure hierarchical_alert(
    constant alert_level: t_alert_level;
    constant msg : string;
    constant scope : string;
    constant attention : t_attention
    ) is
  begin
    global_hierarchy_tree.alert(justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH), alert_level, attention, msg);
  end procedure;

  procedure increment_expected_alerts(
    constant scope : string;
    constant alert_level: t_alert_level;
    constant amount : natural := 1
    ) is
  begin
    global_hierarchy_tree.increment_expected_alerts(justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH), alert_level, amount);
  end procedure;

  procedure set_expected_alerts(
    constant scope : string;
    constant alert_level: t_alert_level;
    constant expected_alerts : natural
    ) is
  begin
    global_hierarchy_tree.set_expected_alerts(justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH), alert_level, expected_alerts);
  end procedure;

  procedure increment_stop_limit(
    constant scope : string;
    constant alert_level: t_alert_level;
    constant amount : natural := 1
    ) is
  begin
    global_hierarchy_tree.increment_stop_limit(justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH), alert_level, amount);
  end procedure;

  procedure set_stop_limit(
    constant scope : string;
    constant alert_level: t_alert_level;
    constant stop_limit : natural
    ) is
  begin
    global_hierarchy_tree.set_stop_limit(justify(scope, LEFT, C_HIERARCHY_NODE_NAME_LENGTH), alert_level, stop_limit);
  end procedure;

  procedure print_hierarchical_log(
    constant order : t_order := FINAL
  ) is
  begin
    global_hierarchy_tree.print_hierarchical_log(order);
  end procedure;

  procedure clear_hierarchy(
    constant VOID : t_void
  ) is
  begin
    global_hierarchy_tree.clear;
  end procedure;

end package body alert_hierarchy_pkg;
