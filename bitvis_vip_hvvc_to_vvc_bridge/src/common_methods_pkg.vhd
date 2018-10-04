library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package common_methods_pkg is

  procedure hvvc_to_vvc_trigger(
    signal hvvc_to_vvc : out t_hvvc_to_vvc
  );

  procedure send_to_sub(
    signal   hvvc_to_vvc               : out t_hvvc_to_vvc;
    constant operation                 : in  t_sub_vvc_operation;
    constant data_bytes                : in  t_byte_array;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural
  );

  procedure send_to_sub_and_await_finish(
    signal   hvvc_to_vvc               : out t_hvvc_to_vvc;
    signal   vvc_to_hvvc               : in  t_vvc_to_hvvc;
    constant operation                 : in  t_sub_vvc_operation;
    constant data_bytes                : in  t_byte_array;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural
  );

end package common_methods_pkg;

package body common_methods_pkg is

  procedure hvvc_to_vvc_trigger(
    signal hvvc_to_vvc : out t_hvvc_to_vvc
  ) is
  begin
    hvvc_to_vvc.trigger <= '1';
    wait for 0 ns;
    hvvc_to_vvc.trigger <= '0';
  end procedure hvvc_to_vvc_trigger;

  procedure send_to_sub(
    signal   hvvc_to_vvc               : out t_hvvc_to_vvc;
    constant operation                 : in  t_sub_vvc_operation;
    constant data_bytes                : in  t_byte_array;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural
  ) is
  begin
    hvvc_to_vvc.operation                            <= operation;
    hvvc_to_vvc.num_data_bytes                       <= data_bytes'length;
    hvvc_to_vvc.data_bytes(0 to data_bytes'length-1) <= data_bytes;
    hvvc_to_vvc.dut_if_field_idx                     <= dut_if_field_idx;
    hvvc_to_vvc.current_byte_idx_in_field            <= current_byte_idx_in_field;
    hvvc_to_vvc_trigger(hvvc_to_vvc);
  end procedure send_to_sub;

  procedure send_to_sub_and_await_finish(
    signal   hvvc_to_vvc               : out t_hvvc_to_vvc;
    signal   vvc_to_hvvc               : in  t_vvc_to_hvvc;
    constant operation                 : in  t_sub_vvc_operation;
    constant data_bytes                : in  t_byte_array;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural
  ) is
  begin
    send_to_sub(hvvc_to_vvc, operation, data_bytes, dut_if_field_idx, current_byte_idx_in_field);
    wait until vvc_to_hvvc.trigger = '1';
  end procedure send_to_sub_and_await_finish;


end package body common_methods_pkg;