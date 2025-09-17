--================================================================================================================================
-- Copyright 2025 UVVM
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
-- Description   : See the library documentation.
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types_pkg.all;
use work.methods_pkg.all;

package association_list_pkg is
  generic(
    GC_SCOPE : string := "association_list_pkg";
    type GC_VALUE_TYPE;
    type GC_KEY_TYPE
  );

  ------------------------------------------
  -- Association list type
  --
  -- Protected type implementing a generic association list
  -- data structure.
  ------------------------------------------
  type t_association_list is protected

    ------------------------------------------
    -- append
    ------------------------------------------
    -- This function appends the given key-value pair to
    -- the list.
    --
    --  - Parameters:
    --    - key
    --    - value
    --
    --  - Returns:
    --    ASSOCIATION_LIST_FAILURE if the key is already in the list,
    --    else ASSOCIATION_LIST_SUCCESS.
    --
    impure function append (
        constant key   : GC_KEY_TYPE;
        constant value : GC_VALUE_TYPE
    ) return t_association_list_status;

    ------------------------------------------
    -- delete
    ------------------------------------------
    -- Deletes the list item given by the key.
    --
    --  - Parameters:
    --    - key
    --
    --  - Returns:
    --    ASSOCIATION_LIST_FAILURE if the key is not in the list,
    --    else ASSOCIATION_LIST_SUCCESS.
    --
    impure function delete (
      constant key : in GC_KEY_TYPE
    ) return t_association_list_status;

    ------------------------------------------
    -- get
    ------------------------------------------
    -- Gets the value associated with the given key.
    --
    -- This function assumes that the given key is in the
    -- list. This means that calling this function with a
    -- key that is not in the list will result in a
    -- failure.
    --
    --  - Parameters:
    --    - key
    --
    --  - Returns:
    --    The value associated with the given key.
    --
    impure function get (
      constant key : GC_KEY_TYPE
    ) return GC_VALUE_TYPE;

    ------------------------------------------
    -- length
    ------------------------------------------
    -- Returns the number of items in the list.
    --
    --  - Returns:
    --    The list length.
    --
    impure function length (
      constant dummy : t_void
    ) return natural;

    ------------------------------------------
    -- clear
    ------------------------------------------
    -- Clears the list by deleting all list items.
    --
    --  - Returns:
    --    ASSOCIATION_LIST_FAILURE if it is not able to delete all
    --    list items, else ASSOCIATION_LIST_SUCCESS.
    --
    impure function clear (
      constant dummy : t_void
    ) return t_association_list_status;

    ------------------------------------------
    -- key_in_list
    ------------------------------------------
    -- Searches for the given key in the list.
    --
    --  - Parameters:
    --        - key
    --
    --  - Returns:
    --    'true' if the key is in the list, else 'false'.
    --
    impure function key_in_list (
      constant key : GC_KEY_TYPE
    ) return boolean;

    ------------------------------------------
    -- set
    ------------------------------------------
    -- Sets the given value for the given key.
    --
    --  - Parameters:
    --        - key
    --        - value
    --
    --  - Returns:
    --    ASSOCIATION_LIST_FAILURE if the key is not in the list,
    --    else ASSOCIATION_LIST_SUCCESS.
    --
    impure function set (
      constant key   : GC_KEY_TYPE;
      constant value : GC_VALUE_TYPE
    ) return t_association_list_status;

  end protected t_association_list;

end package association_list_pkg;

package body association_list_pkg is

  type t_value_ptr is access GC_VALUE_TYPE;
  type t_key_ptr is access GC_KEY_TYPE;

  type t_node; -- forward declaration
  type t_node_ptr is access t_node;
  type t_node is record
    key       : t_key_ptr;
    value     : t_value_ptr;
    next_node : t_node_ptr;
  end record t_node;

  type t_association_list is protected body

    ------------------------------------------
    -- Variables
    ------------------------------------------
    variable priv_head : t_node_ptr := NULL;      -- head of list
    variable priv_tail : t_node_ptr := priv_head; -- tail of list
    variable priv_last : t_node_ptr := priv_head; -- last node referenced
    variable priv_num_alloc : natural := 0; -- node allocation counter

    ------------------------------------------
    -- length
    ------------------------------------------
    impure function length (
      constant dummy : t_void
    ) return natural is
    begin
      return priv_num_alloc;
    end function length;

    ------------------------------------------
    -- search
    ------------------------------------------
    impure function search (
      constant key : GC_KEY_TYPE
    ) return t_node_ptr is
      variable v_node_ptr : t_node_ptr := NULL;
      variable v_ret : t_node_ptr := NULL;
    begin

      -- Skip searching the list if the last node
      -- referenced is the key
      if priv_last /= NULL then
        if priv_last.key.all = key then
          v_ret := priv_last;
        end if;
      end if;

      -- if the key is not the last node referenced,
      -- search the list from the head
      if v_ret = NULL then
        v_node_ptr := priv_head;

        while v_node_ptr /= NULL loop
          if v_node_ptr.key.all = key then
            v_ret := v_node_ptr;
            priv_last := v_node_ptr;
            exit;
          else
            v_node_ptr := v_node_ptr.next_node;
          end if;
        end loop;
      end if;

      return v_ret;
    end function search;

    ------------------------------------------
    -- key_in_list
    ------------------------------------------
    impure function key_in_list (
      constant key : GC_KEY_TYPE
    ) return boolean is
      variable v_ret : boolean := false;
    begin

      if search(key) /= NULL then
        v_ret := true;
      else
        v_ret := false;
      end if;

      return v_ret;
    end function key_in_list;

    ------------------------------------------
    -- append
    ------------------------------------------
    impure function append (
        constant key   : GC_KEY_TYPE;
        constant value : GC_VALUE_TYPE
    ) return t_association_list_status is
        variable v_node : t_node;
        variable v_node_ptr : t_node_ptr := NULL;
        variable v_ret : t_association_list_status;
    begin

      if key_in_list(key) = false then --  the key is not in the list
        -- create a new node
        v_node.key := new GC_KEY_TYPE'(key);
        v_node.value := new GC_VALUE_TYPE'(value);
        v_node.next_node := NULL;

        v_node_ptr := new t_node'(v_node);
        priv_num_alloc := priv_num_alloc + 1;

        if priv_head = NULL then -- the list is empty

          if priv_tail /= NULL then
            alert(failure, "The list is not empty", GC_SCOPE & ".append()");
          end if;

          -- head and tail points to the same node
          priv_head := v_node_ptr;
          priv_tail := v_node_ptr;
        else -- the list is not empty
          -- append the new node to end of the list and
          -- set it as tail
          priv_tail.next_node := v_node_ptr;
          priv_tail           := v_node_ptr;
        end if;
        priv_last := priv_tail;
        v_ret := ASSOCIATION_LIST_SUCCESS;
      else
        v_ret := ASSOCIATION_LIST_FAILURE;
      end if;

      return v_ret;
    end function append;

    ------------------------------------------
    -- delete
    ------------------------------------------
    impure function delete (
      constant key : in GC_KEY_TYPE
    ) return t_association_list_status is
      variable v_node_ptr : t_node_ptr := NULL;
      variable v_node_to_delete_ptr : t_node_ptr := NULL;
      variable v_ret : t_association_list_status := ASSOCIATION_LIST_FAILURE;
    begin

      v_node_ptr := priv_head;

      if v_node_ptr /= NULL then -- the list is not empty

        if v_node_ptr.key.all = key then -- key is the head

          -- update the head before deleting the node
          priv_head := v_node_ptr.next_node;

          if v_node_ptr = priv_tail then -- update the tail
            priv_tail := NULL;
          end if;

          if v_node_ptr = priv_last then -- update the last node referenced
            priv_last := NULL;
          end if;

          -- deallocate all memory allocated in the node
          -- and for the node itself
          DEALLOCATE(v_node_ptr.key);
          DEALLOCATE(v_node_ptr.value);
          DEALLOCATE(v_node_ptr);
          priv_num_alloc := priv_num_alloc - 1;

          v_ret := ASSOCIATION_LIST_SUCCESS;
        else -- search the rest of the list for the key
          while v_node_ptr /= NULL loop
            if v_node_ptr /= priv_tail then -- the node is not the tail

              if v_node_ptr.next_node.key.all = key then -- the key is the next node
                v_node_to_delete_ptr := v_node_ptr.next_node;

                if v_node_to_delete_ptr = priv_tail then -- update the tail pointer
                  priv_tail := v_node_ptr;
                  priv_tail.next_node := NULL;
                else -- update the next pointer
                  v_node_ptr.next_node := v_node_ptr.next_node.next_node;
                end if;

                if v_node_to_delete_ptr = priv_last then -- update the last node referenced
                  priv_last := NULL;
                end if;

                -- deallocate all memory allocated in the
                -- node and for the node itself
                DEALLOCATE(v_node_to_delete_ptr.key);
                DEALLOCATE(v_node_to_delete_ptr.value);
                DEALLOCATE(v_node_to_delete_ptr);
                priv_num_alloc := priv_num_alloc - 1;

                v_ret := ASSOCIATION_LIST_SUCCESS;
                exit;
              else
                v_node_ptr := v_node_ptr.next_node;
              end if;
            else -- node is the tail
              if v_node_ptr.key.all = key then -- key is the tail

                if v_node_ptr = priv_last then -- update the last node referenced
                  priv_last := NULL;
                end if;

                -- deallocate all memory allocated in the
                -- node and for the node itself
                DEALLOCATE(v_node_ptr.key);
                DEALLOCATE(v_node_ptr.value);
                DEALLOCATE(v_node_ptr);
                priv_num_alloc := priv_num_alloc - 1;

                priv_tail := NULL;
                v_ret := ASSOCIATION_LIST_SUCCESS;
              end if;

              exit;
            end if;
          end loop;
        end if;
      end if;

      return v_ret;
    end function delete;

    ------------------------------------------
    -- get
    ------------------------------------------
    impure function get (
      constant key : GC_KEY_TYPE
    ) return GC_VALUE_TYPE is
      variable v_node_ptr : t_node_ptr := NULL;
    begin
      v_node_ptr := search(key);

      if v_node_ptr = NULL then
        alert(failure, "Key is not in the list.", GC_SCOPE & ".get()");
      end if;

      priv_last := v_node_ptr;
      return v_node_ptr.value.all;
    end function get;

    ------------------------------------------
    -- clear
    ------------------------------------------
    impure function clear (
      constant dummy : t_void
    ) return t_association_list_status is
      variable v_node_ptr : t_node_ptr := NULL;
      variable v_node_to_delete_ptr : t_node_ptr := NULL;
      variable v_ret : t_association_list_status := ASSOCIATION_LIST_SUCCESS;
    begin

      v_node_ptr := priv_head;

      -- update member pointers
      priv_head := NULL;
      priv_tail := NULL;
      priv_last := NULL;

      -- visit all the nodes in the list and deallocate
      -- all allocated memory
      while v_node_ptr /= NULL loop
        v_node_to_delete_ptr := v_node_ptr;
        v_node_ptr := v_node_ptr.next_node;

        DEALLOCATE(v_node_to_delete_ptr.key);
        DEALLOCATE(v_node_to_delete_ptr.value);
        DEALLOCATE(v_node_to_delete_ptr);
        priv_num_alloc := priv_num_alloc - 1;
      end loop;

      if priv_num_alloc /= 0 then
        alert(failure,
          "Not all allocated memory has been deallocated (Nodes not deallocated: " & to_string(priv_num_alloc) & ")",
          GC_SCOPE & ".clear()");
      end if;

      return v_ret;
    end function clear;

    ------------------------------------------
    -- set
    ------------------------------------------
    impure function set (
      constant key   : GC_KEY_TYPE;
      constant value : GC_VALUE_TYPE
    ) return t_association_list_status is
      variable v_node_ptr : t_node_ptr := NULL;
      variable v_ret : t_association_list_status;
    begin
      v_node_ptr := search(key);

      if v_node_ptr = NULL then -- the key is not in the list
        v_ret := ASSOCIATION_LIST_FAILURE;
      else -- the key is in the list
        priv_last := v_node_ptr;
        v_node_ptr.value.all := value;
        v_ret := ASSOCIATION_LIST_SUCCESS;
      end if;

      return v_ret;
    end function set;

  end protected body t_association_list;

end package body association_list_pkg;