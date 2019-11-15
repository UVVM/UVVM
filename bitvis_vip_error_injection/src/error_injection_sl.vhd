library ieee;
use ieee.std_logic_1164.all;

library bitvis_vip_error_injection;
use bitvis_vip_error_injection.error_injection_pkg.all;


entity error_injection_sl is
  generic (
    GC_START_TIME     : time    := 0 ns;
    GC_INSTANCE_IDX   : natural := 1
  );
  port (
    ei_in             : in std_logic;
    ei_out            : out std_logic
  );
end entity error_injection_sl;



architecture behave of error_injection_sl is

  component error_injection_slv
    generic (
      GC_START_TIME     : time;
      GC_INSTANCE_IDX   : natural
      );
    port (
      ei_in             : in std_logic_vector(0 downto 0);
      ei_out            : out std_logic_vector(0 downto 0)
    );
  end component;

begin

  error_injector_slv: error_injection_slv
    generic map (
      GC_START_TIME       => GC_START_TIME,
      GC_INSTANCE_IDX     => GC_INSTANCE_IDX
    )
    port map (
      ei_in(0)  => ei_in,
      ei_out(0) => ei_out
    );

end behave;