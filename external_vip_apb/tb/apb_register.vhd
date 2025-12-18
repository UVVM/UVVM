library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity apb_register is
  generic (
    GC_ADDR_WIDTH                 : integer := 32;  -- Address width (default 32-bit)
    GC_DATA_WIDTH                 : integer := 32   -- Data width (default 32-bit)
  );
  port (
    -- APB Interface
    PCLK                  : in  std_logic;
    PRESETn               : in  std_logic;
    PADDR                 : in  std_logic_vector(GC_ADDR_WIDTH-1 downto 0);
    PSEL                  : in  std_logic;
    PENABLE               : in  std_logic;
    PWRITE                : in  std_logic;
    PWDATA                : in  std_logic_vector(GC_DATA_WIDTH-1 downto 0);
    PRDATA                : out std_logic_vector(GC_DATA_WIDTH-1 downto 0);
    PREADY                : out std_logic;
    PSLVERR               : out std_logic;
    -- Control signals
    number_of_wait_states : in  integer := 0
  );
end apb_register;

architecture rtl of apb_register is

  constant C_REG_ADDR : std_logic_vector(GC_ADDR_WIDTH-1 downto 0) := x"00001000";

  type t_pready_state is (WAIT_FOR_PSEL, WAIT_FOR_PREADY);

  signal reg                  : std_logic_vector(GC_DATA_WIDTH-1 downto 0);
  signal pready_state         : t_pready_state;
  signal pready_wait_counter  : integer := 0;

begin

  p_apb_reg : process (PCLK, PRESETn)
  begin
    if PRESETn = '0' then
      reg     <= (others => '0');
      PSLVERR <= '0'; 
    elsif rising_edge(PCLK) then

      if PSEL = '1' and PWRITE = '0' then --Read
        if PADDR = C_REG_ADDR then
          PRDATA <= reg;
        else
          PRDATA <= (others => '0');
        end if;
      end if;


      if PSEL = '1' and PENABLE = '1' and PWRITE = '1' then --Write
        if PADDR = C_REG_ADDR then
          reg <= PWDATA;
        end if;
      end if;

    end if;
  end process p_apb_reg;

  p_apb_PREADY: process (PCLK, PRESETn)
  begin
    if PRESETn = '0' then
      PREADY        <= '0';
      pready_state  <= WAIT_FOR_PSEL;
    elsif rising_edge(PCLK) then
      case pready_state is
        when WAIT_FOR_PSEL =>
          PREADY <= '0';
          if PSEL = '1' then
            if number_of_wait_states = 0 then
              PREADY <= '1';
            else
              pready_state <= WAIT_FOR_PREADY;
            end if;
          end if;
        when WAIT_FOR_PREADY =>
          if pready_wait_counter >= number_of_wait_states-1 then
            PREADY              <= '1';
            pready_wait_counter <= 0;
            pready_state        <= WAIT_FOR_PSEL;
          else
            pready_wait_counter <= pready_wait_counter + 1;
          end if;
      end case;
    end if;
  end process p_apb_PREADY;
end rtl;