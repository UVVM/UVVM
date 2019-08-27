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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_data_fifo_pkg.all;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;


entity sbi_fifo is
  generic (
    GC_DATA_WIDTH_1       : integer range 1 to 128  := 8;
    GC_ADDR_WIDTH_1       : integer range 1 to 128  := 8;
    GC_DATA_WIDTH_2       : integer range 1 to 128  := 8;
    GC_ADDR_WIDTH_2       : integer range 1 to 128  := 8
  );
  port (
    clk         : in std_logic;
    sbi_if_1    : inout t_sbi_if(addr(GC_ADDR_WIDTH_1-1 downto 0), wdata(GC_DATA_WIDTH_1-1 downto 0), rdata(GC_DATA_WIDTH_1-1 downto 0));
    sbi_if_2    : inout t_sbi_if(addr(GC_ADDR_WIDTH_2-1 downto 0), wdata(GC_DATA_WIDTH_2-1 downto 0), rdata(GC_DATA_WIDTH_2-1 downto 0))
  );
end entity sbi_fifo;


architecture behave of sbi_fifo is

  constant C_SCOPE            : string  := "SBI_FIFO";

  constant C_BUFFER_INDEX_1   : natural := 1;
  constant C_BUFFER_INDEX_2   : natural := 2;

  constant C_BUFFER_SIZE_1    : natural := 256;
  constant C_BUFFER_SIZE_2    : natural := 256;

  signal fifo_ready_1         : std_logic := '0';
  signal fifo_ready_2         : std_logic := '0';
  signal write_ready_1        : std_logic := '0';
  signal write_ready_2        : std_logic := '0';
  signal read_ready_1         : std_logic := '0';
  signal read_ready_2         : std_logic := '0';

  -- Register map :
  constant C_ADDR_FIFO_PUT            : integer := 0;
  constant C_ADDR_FIFO_GET            : integer := 1;
  constant C_ADDR_FIFO_COUNT          : integer := 2;
  constant C_ADDR_FIFO_PEEK           : integer := 3;
  constant C_ADDR_FIFO_FLUSH          : integer := 4;
  constant C_ADDR_FIFO_MAX_COUNT      : integer := 5;

begin

  p_init : process
  begin
    -- Init FIFO
    uvvm_fifo_init(C_BUFFER_INDEX_1, C_BUFFER_SIZE_1);
    uvvm_fifo_init(C_BUFFER_INDEX_2, C_BUFFER_SIZE_1);
    wait;
  end process;

  p_fifo_ready : process (clk)
  begin
    if falling_edge(clk) then
      fifo_ready_1 <= '1' when uvvm_fifo_get_count(C_BUFFER_INDEX_1) > 0 else '0';
      fifo_ready_2 <= '1' when uvvm_fifo_get_count(C_BUFFER_INDEX_2) > 0 else '0';
    end if;
  end process;



  -- Read registers for SBI IF 1
  p_read_reg_sbi_1 : process (sbi_if_1.cs, sbi_if_1.rena, sbi_if_1.addr, fifo_ready_1)
  begin
    sbi_if_1.rdata(GC_DATA_WIDTH_1-1 downto 0) <= (others => '0');
    read_ready_1 <= '0';
    if sbi_if_1.cs = '1' and sbi_if_1.rena = '1' then
      -- Decode read address
      case to_integer(sbi_if_1.addr) is
        when C_ADDR_FIFO_GET =>
          if fifo_ready_1 then
            sbi_if_1.rdata <= uvvm_fifo_get(C_BUFFER_INDEX_1, GC_DATA_WIDTH_1);
            read_ready_1 <= '1';
          end if;
        when C_ADDR_FIFO_PEEK =>
          if fifo_ready_1 then
            sbi_if_1.rdata <= uvvm_fifo_peek(C_BUFFER_INDEX_1, GC_DATA_WIDTH_1);
            read_ready_1 <= '1';
          end if;
        when C_ADDR_FIFO_COUNT =>
          sbi_if_1.rdata <= std_logic_vector(to_unsigned(uvvm_fifo_get_count(C_BUFFER_INDEX_1),GC_DATA_WIDTH_1));
          read_ready_1 <= '1';
        when C_ADDR_FIFO_MAX_COUNT =>
          sbi_if_1.rdata <= std_logic_vector(to_unsigned(uvvm_fifo_get_max_count(C_BUFFER_INDEX_1),GC_DATA_WIDTH_1));
          read_ready_1 <= '1';
        when others =>
          alert(ERROR, "SBI_IF_1 Read Address " & to_string(to_integer(sbi_if_1.addr)) & " not supported!", C_SCOPE);
      end case;
    end if;
  end process;


   -- Write registers for SBI IF 1
  p_write_reg_sbi_1 : process (clk)
  begin
    if rising_edge(clk) then
      write_ready_1 <= '0';
      if sbi_if_1.cs = '1' and sbi_if_1.wena = '1' then
        -- Decode write address
        case to_integer(sbi_if_1.addr) is
          when C_ADDR_FIFO_PUT =>
            if not uvvm_fifo_is_full(C_BUFFER_INDEX_2) then
              uvvm_fifo_put(C_BUFFER_INDEX_2, sbi_if_1.wdata);
              write_ready_1 <= '1';
            end if;
          when C_ADDR_FIFO_FLUSH =>
            uvvm_fifo_flush(C_BUFFER_INDEX_2);
            write_ready_1 <= '1';
          when others =>
            alert(ERROR, "SBI_IF_1 Write Address " & to_string(to_integer(sbi_if_1.addr)) & " not supported!", C_SCOPE);
          end case;
      end if;
    end if;
  end process;


   -- Read registers for SBI IF 2
  p_read_reg_sbi_2 : process (sbi_if_2.cs, sbi_if_2.rena, sbi_if_2.addr, fifo_ready_2)
  begin
    sbi_if_2.rdata(GC_DATA_WIDTH_2-1 downto 0) <= (others => '0');
    read_ready_2 <= '0';
    if sbi_if_2.cs = '1' and sbi_if_2.rena = '1' then
      -- Decode read address
      case to_integer(sbi_if_2.addr) is
        when C_ADDR_FIFO_GET =>
          if fifo_ready_2 then
            sbi_if_2.rdata <= uvvm_fifo_get(C_BUFFER_INDEX_2, GC_DATA_WIDTH_2);
            read_ready_2 <= '1';
          end if;
        when C_ADDR_FIFO_PEEK =>
          if fifo_ready_2 then
            sbi_if_2.rdata <= uvvm_fifo_peek(C_BUFFER_INDEX_2, GC_DATA_WIDTH_2);
            read_ready_2 <= '1';
          end if;
        when C_ADDR_FIFO_COUNT =>
          sbi_if_2.rdata <= std_logic_vector(to_unsigned(uvvm_fifo_get_count(C_BUFFER_INDEX_2), GC_DATA_WIDTH_2));
          read_ready_2 <= '1';
        when C_ADDR_FIFO_MAX_COUNT =>
          sbi_if_2.rdata <= std_logic_vector(to_unsigned(uvvm_fifo_get_max_count(C_BUFFER_INDEX_2), GC_DATA_WIDTH_2));
          read_ready_2 <= '1';
        when others =>
          alert(ERROR, "SBI_IF_2 Read Address " & to_string(to_integer(sbi_if_2.addr)) & " not supported!", C_SCOPE);
      end case;
    end if;
  end process;


   -- Write registers for SBI IF 2
  p_write_reg_sbi_2 : process (clk)
  begin
    if rising_edge(clk) then
      write_ready_2 <= '0';
      if sbi_if_2.cs = '1' and sbi_if_2.wena = '1' then
        -- Decode write address
        case to_integer(sbi_if_2.addr) is
          when C_ADDR_FIFO_PUT =>
            if not uvvm_fifo_is_full(C_BUFFER_INDEX_1) then
              uvvm_fifo_put(C_BUFFER_INDEX_1, sbi_if_2.wdata);
              write_ready_2 <= '1';
            end if;
          when C_ADDR_FIFO_FLUSH =>
            uvvm_fifo_flush(C_BUFFER_INDEX_1);
            write_ready_2 <= '1';
          when others =>
            alert(ERROR, "SBI_IF_2 Write Address " & to_string(to_integer(sbi_if_2.addr)) & " not supported!", C_SCOPE);
          end case;
      end if;
    end if;
  end process;


  -- Set input ports to Z, since they are declared as inout.
  sbi_if_1.cs <= 'Z';
  sbi_if_1.addr <= (others => 'Z');
  sbi_if_1.rena <= 'Z';
  sbi_if_1.wena <= 'Z';
  sbi_if_1.wdata <= (others => 'Z');

  sbi_if_2.cs <= 'Z';
  sbi_if_2.addr <= (others => 'Z');
  sbi_if_2.rena <= 'Z';
  sbi_if_2.wena <= 'Z';
  sbi_if_2.wdata <= (others => 'Z');

  sbi_if_1.ready <= write_ready_1 or read_ready_1;
  sbi_if_2.ready <= write_ready_2 or read_ready_2;

end behave;

