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
-- Description   : Package for the read data queue
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.axi_bfm_pkg.all;
use work.vvc_cmd_pkg.all;

package axi_read_data_queue_pkg is
  type t_axi_read_data_queue is protected

    impure function exists(
      constant rid : in std_logic_vector
    ) return boolean;

    impure function fetch_from_queue(
      constant rid : in std_logic_vector
    ) return t_vvc_result;

    procedure add_to_queue(
      constant rid   : in std_logic_vector;
      constant rdata : in std_logic_vector;
      constant rresp : in t_xresp;
      constant ruser : in std_logic_vector
    );

    procedure set_scope(
      constant scope : in string
    );

  end protected t_axi_read_data_queue;
end package axi_read_data_queue_pkg;

package body axi_read_data_queue_pkg is

  package axi_read_data_generic_queue_pkg is new uvvm_util.generic_queue_pkg
    generic map(t_generic_element => t_vvc_result);

  use axi_read_data_generic_queue_pkg.all;

  type t_axi_read_data_queue is protected body

    variable priv_queue : axi_read_data_generic_queue_pkg.t_generic_queue;

    impure function exists(
      constant rid : in std_logic_vector
    ) return boolean is
      variable v_queue_count    : natural;
      variable v_read_data      : t_vvc_result;
      variable v_normalized_rid : std_logic_vector(v_read_data.rid'length - 1 downto 0);
    begin
      if priv_queue.is_empty(VOID) then
        return false;
      else
        v_queue_count := priv_queue.get_count(VOID);
        if rid'length = 0 then
          -- If the RID length is zero, all read data must arrive in order. All we need to check is that the queue is not empty
          if v_queue_count > 0 then
            return true;
          end if;
        else
          v_normalized_rid := normalize_and_check(rid, v_normalized_rid, ALLOW_NARROWER, "rid", "v_normalized_rid", "Normalizing rid");
          for i in 1 to v_queue_count loop
            v_read_data := priv_queue.peek(POSITION, i);
            if v_read_data.rid = v_normalized_rid then
              return true;
            end if;
          end loop;
        end if;
        return false;
      end if;
    end function exists;

    impure function fetch_from_queue(
      constant rid : in std_logic_vector
    ) return t_vvc_result is
      variable v_queue_count    : natural;
      variable v_read_data      : t_vvc_result;
      variable v_normalized_rid : std_logic_vector(v_read_data.rid'length - 1 downto 0) := (others => '0');
    begin
      if exists(rid) then
        if rid'length > 0 then
          v_normalized_rid := normalize_and_check(rid, v_normalized_rid, ALLOW_NARROWER, "rid", "v_normalized_rid", "Normalizing rid");
        end if;
        v_queue_count := priv_queue.get_count(VOID);
        for i in 1 to v_queue_count loop
          v_read_data := priv_queue.peek(POSITION, i);
          if rid'length = 0 or v_read_data.rid = v_normalized_rid then
            priv_queue.delete(POSITION, i, SINGLE);
            return v_read_data;
          end if;
        end loop;
      end if;
      tb_error("Trying to fetch a non-existing element from queue");
      return v_read_data;
    end function fetch_from_queue;

    procedure add_to_queue(
      constant rid   : in std_logic_vector;
      constant rdata : in std_logic_vector;
      constant rresp : in t_xresp;
      constant ruser : in std_logic_vector
    ) is
      variable v_read_data : t_vvc_result := C_EMPTY_VVC_RESULT;
      variable v_index     : integer;
    begin

      if not exists(rid) then
        v_read_data.len      := 0;
        if rid'length > 0 then
          v_read_data.rid := normalize_and_check(rid, v_read_data.rid, ALLOW_NARROWER, "rid", "v_read_data.rid", "Normalizing rid");
        end if;
        v_read_data.rdata(0) := normalize_and_check(rdata, v_read_data.rdata(0), ALLOW_NARROWER, "rdata", "v_read_data.rdata(0)", "Normalizing rdata");
        v_read_data.rresp(0) := rresp;
        if ruser'length > 0 then
          v_read_data.ruser(0) := normalize_and_check(ruser, v_read_data.ruser(0), ALLOW_NARROWER, "ruser", "v_read_data.ruser(0)", "Normalizing ruser");
        end if;
        priv_queue.add(v_read_data);
      else
        v_read_data                := fetch_from_queue(rid);
        v_index                    := v_read_data.len + 1;
        v_read_data.len            := v_index;
        v_read_data.rdata(v_index) := normalize_and_check(rdata, v_read_data.rdata(v_index), ALLOW_NARROWER, "rdata", "v_read_data.rdata(" & to_string(v_index) & ")", "Normalizing rdata");
        v_read_data.rresp(v_index) := rresp;
        if ruser'length > 0 then
          v_read_data.ruser(v_index) := normalize_and_check(ruser, v_read_data.ruser(v_index), ALLOW_NARROWER, "ruser", "v_read_data.ruser(" & to_string(v_index) & ")", "Normalizing ruser");
        end if;
        priv_queue.add(v_read_data);
      end if;
    end procedure add_to_queue;

    procedure set_scope(
      constant scope : in string
    ) is
    begin
      priv_queue.set_scope(scope);
    end procedure set_scope;

  end protected body t_axi_read_data_queue;

end package body axi_read_data_queue_pkg;
