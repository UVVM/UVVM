library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package common_methods_pkg is

  procedure hvvc_to_vvc_trigger(
    signal hvvc_to_vvc : out t_hvvc_to_vvc
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

end package body common_methods_pkg;