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

entity sbi_slave is
  generic (
    GC_ADDR_WIDTH              : integer range 1 to 64 := 8;
    GC_DATA_WIDTH              : integer range 1 to 128 := 8;
    GC_FIXED_WAIT_CYCLES_READ  : integer range 0 to 10 := 0;
    GC_CLK_PERIOD              : time                  := 10 ns
  );
  port(
    clk            : in  std_logic;
    rst            : in  std_logic;
    sbi_cs         : in  std_logic;
    sbi_rd         : in  std_logic;
    sbi_wr         : in  std_logic;
    sbi_addr       : in  unsigned(GC_ADDR_WIDTH-1 downto 0);
    sbi_wdata      : in  std_logic_vector(GC_DATA_WIDTH-1 downto 0);
    sbi_rdata      : out std_logic_vector(GC_DATA_WIDTH-1 downto 0);
    last_write     : out std_logic_vector(GC_DATA_WIDTH-1 downto 0);
    data_in        : in  std_logic_vector(GC_DATA_WIDTH-1 downto 0)
  );
end entity sbi_slave;
--    sbi_req_valid  : in  std_logic;                                    -- Indicates that there is a valid request
--    sbi_be         : in  std_logic_vector(GC_DATA_WIDTH/8-1 downto 0); -- Indicates valid bytes lanes of data
--    sbi_ready      : out std_logic;                                    -- Indicates that the slave is ready to accept requests
--    sbi_resp_valid : out std_logic;                                    -- Indicates that there is a valid response
--    sbi_resp_ready   : in  std_logic;                                    -- Indicates that the master is ready to accept responses

architecture rtl of sbi_slave is

  -- The registers
  signal reg_0 : std_logic_vector(GC_DATA_WIDTH-1 downto 0);
  signal reg_1 : std_logic_vector(GC_DATA_WIDTH-1 downto 0);
  signal reg_2 : std_logic_vector(GC_DATA_WIDTH-1 downto 0);

  -- Register map :
  constant C_ADDR_REG_0 : integer := 0;
  constant C_ADDR_REG_1 : integer := 1;
  constant C_ADDR_REG_2 : integer := 2;
  constant C_ADDR_REG_3 : integer := 3;
  signal sbi_rdata_i :std_logic_vector(GC_DATA_WIDTH-1 downto 0);
begin

  sbi_rdata <= sbi_rdata_i after GC_FIXED_WAIT_CYCLES_READ * GC_CLK_PERIOD;
  -- Read registers
  p_read_reg : process (sbi_cs, sbi_rd, sbi_addr)
  begin
    sbi_rdata_i <= (others => '0');
    if sbi_cs = '1' and sbi_rd = '1' then
       -- Decode read address
       case to_integer(sbi_addr) is
          when C_ADDR_REG_0 =>
             sbi_rdata_i <= reg_0;
          when C_ADDR_REG_1 =>
             sbi_rdata_i <= reg_1;
          when C_ADDR_REG_2 =>
             sbi_rdata_i <= reg_2;
          when C_ADDR_REG_3 =>
             sbi_rdata_i <= data_in;
          when others =>
             null;
       end case;
    end if;
  end process;


  -- Write registers
  p_write_reg : process (rst, clk)
  begin
    if rst = '1' then
      reg_0         <= (others=> '0');
      reg_1         <= (others=> '0');
      reg_2         <= (others=> '0');
      last_write    <= (others=> '0');
    elsif rising_edge(clk) then
       if sbi_cs = '1' and sbi_wr = '1' then
          -- Decode write address
          case to_integer(sbi_addr) is
             when C_ADDR_REG_0 =>
               reg_0 <= sbi_wdata;
               last_write <= sbi_wdata;
             when C_ADDR_REG_1 =>
               reg_1 <= sbi_wdata;
               last_write <= sbi_wdata;
             when C_ADDR_REG_2 =>
               reg_2 <= sbi_wdata;
               last_write <= sbi_wdata;
             when others =>
                assert false
                  report "SBI_SLAVE : Unknown register"; -- & to_string(sbi_addr, HEX);
          end case;
      end if;

    end if;
  end process;

end architecture rtl;
