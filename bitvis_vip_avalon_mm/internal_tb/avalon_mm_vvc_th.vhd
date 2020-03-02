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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

-- Using the instantiated pkg
library bitvis_vip_avalon_mm;
use bitvis_vip_avalon_mm.avalon_mm_bfm_pkg.all;


entity test_harness is
  generic(
    GC_CLK_PERIOD : time
  );
end entity test_harness;

-- Test case architecture
architecture func of test_harness is

  constant C_ADDR_WIDTH   : integer := 32;
  constant C_DATA_WIDTH   : integer := 32;

  signal clk : std_logic;

  signal avalon_mm_if_1     : t_avalon_mm_if(address(C_ADDR_WIDTH-1 downto 0), byte_enable((C_DATA_WIDTH/8)-1 downto 0), 
                                           writedata(C_DATA_WIDTH-1 downto 0), readdata(C_DATA_WIDTH-1 downto 0));
                                           
  signal avalon_mm_if_2     : t_avalon_mm_if(address(C_ADDR_WIDTH-1 downto 0), byte_enable((C_DATA_WIDTH/8)-1 downto 0), 
                                           writedata(C_DATA_WIDTH-1 downto 0), readdata(C_DATA_WIDTH-1 downto 0));                                            

  -- FIFO signals
  signal empty_1 : std_logic;
  signal full_1  : std_logic;
  signal usedw_1 : std_logic_vector (3 downto 0);
  
  signal empty_2 : std_logic;
  signal full_2  : std_logic;
  signal usedw_2 : std_logic_vector (3 downto 0);

  component avalon_fifo_single_clock_fifo
    port (
      signal aclr  : in  std_logic;
      signal clock : in  std_logic;
      signal data  : in  std_logic_vector (C_DATA_WIDTH-1 downto 0);
      signal rdreq : in  std_logic;
      signal wrreq : in  std_logic;
      signal empty : out std_logic;
      signal full  : out std_logic;
      signal q     : out std_logic_vector (C_ADDR_WIDTH-1 downto 0);
      signal usedw : out std_logic_vector ((C_DATA_WIDTH/8)-1 downto 0));
  end component;
begin

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  avalon_fifo_single_clock_fifo_1 : avalon_fifo_single_clock_fifo
    port map (
      aclr  => avalon_mm_if_1.reset,
      clock => clk,
      data  => avalon_mm_if_1.writedata,
      rdreq => avalon_mm_if_1.read,
      wrreq => avalon_mm_if_1.write,
      empty => empty_1,
      full  => full_1,
      q     => avalon_mm_if_1.readdata,
      usedw => usedw_1
    );
    
  avalon_fifo_single_clock_fifo_2 : avalon_fifo_single_clock_fifo
    port map (
      aclr  => avalon_mm_if_2.reset,
      clock => clk,
      data  => avalon_mm_if_2.writedata,
      rdreq => avalon_mm_if_2.read,
      wrreq => avalon_mm_if_2.write,
      empty => empty_2,
      full  => full_2,
      q     => avalon_mm_if_2.readdata,
      usedw => usedw_2
    );
  
  -- Set default to unused interface signals
  avalon_mm_if_1.response <= (others => '0');
  avalon_mm_if_1.irq <= '0';
  avalon_mm_if_1.readdatavalid <= '0';
  
  -- Set default to unused interface signals
  avalon_mm_if_2.response <= (others => '0');
  avalon_mm_if_2.irq <= '0';
  avalon_mm_if_2.readdatavalid <= '0';

  p_waitrequest_1 : process (avalon_mm_if_1, full_1, empty_1)
  begin
    if avalon_mm_if_1.write and full_1 then
      avalon_mm_if_1.waitrequest <= '1';
    elsif avalon_mm_if_1.read and empty_1 then
      avalon_mm_if_1.waitrequest <= '1';
    else
      avalon_mm_if_1.waitrequest <= '0';
    end if;
  end process p_waitrequest_1;
  
  p_waitrequest_2 : process (avalon_mm_if_2, full_2, empty_2)
  begin
    if avalon_mm_if_2.write and full_2 then
      avalon_mm_if_2.waitrequest <= '1';
    elsif avalon_mm_if_2.read and empty_2 then
      avalon_mm_if_2.waitrequest <= '1';
    else
      avalon_mm_if_2.waitrequest <= '0';
    end if;
  end process p_waitrequest_2;

  
  -----------------------------
  -- vvc/executors
  -----------------------------
  i1_avalon_mm_vvc : entity work.avalon_mm_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH,
      GC_DATA_WIDTH   => C_DATA_WIDTH,
      GC_INSTANCE_IDX => 1
    )
    port map(
      clk                         => clk,
      avalon_mm_vvc_master_if     => avalon_mm_if_1
    );
    
    
  i2_avalon_mm_vvc : entity work.avalon_mm_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH,
      GC_DATA_WIDTH   => C_DATA_WIDTH,
      GC_INSTANCE_IDX => 2
    )
    port map(
      clk                         => clk,
      avalon_mm_vvc_master_if     => avalon_mm_if_2
    );
    
    p_clk : clock_generator(clk, GC_CLK_PERIOD);


end func;
