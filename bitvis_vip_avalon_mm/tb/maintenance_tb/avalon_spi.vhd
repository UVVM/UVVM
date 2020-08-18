--Legal Notice: (C)2014 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--Register map:
--addr      register      type
--0         read data     r
--1         write data    w
--2         status        r/w
--3         control       r/w
--4         reserved
--5         slave-enable  r/w
--6         end-of-packet-value r/w
--INPUT_CLOCK: 50000000
--ISMASTER: 1
--DATABITS: 8
--TARGETCLOCK: 5000000
--NUMSLAVES: 1
--CPOL: 0
--CPHA: 0
--LSBFIRST: 0
--EXTRADELAY: 0
--TARGETSSDELAY: 0

entity avalon_spi is 
        port (
              -- inputs:
                 signal MISO : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_from_cpu : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal mem_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal read_n : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal spi_select : IN STD_LOGIC;
                 signal write_n : IN STD_LOGIC;

              -- outputs:
                 signal MOSI : OUT STD_LOGIC;
                 signal SCLK : OUT STD_LOGIC;
                 signal SS_n : OUT STD_LOGIC;
                 signal data_to_cpu : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal dataavailable : OUT STD_LOGIC;
                 signal endofpacket : OUT STD_LOGIC;
                 signal irq : OUT STD_LOGIC;
                 signal readyfordata : OUT STD_LOGIC
              );
end entity avalon_spi;


architecture europa of avalon_spi is
                signal E :  STD_LOGIC;
                signal EOP :  STD_LOGIC;
                signal MISO_reg :  STD_LOGIC;
                signal ROE :  STD_LOGIC;
                signal RRDY :  STD_LOGIC;
                signal SCLK_reg :  STD_LOGIC;
                signal SSO_reg :  STD_LOGIC;
                signal TMT :  STD_LOGIC;
                signal TOE :  STD_LOGIC;
                signal TRDY :  STD_LOGIC;
                signal control_wr_strobe :  STD_LOGIC;
                signal data_rd_strobe :  STD_LOGIC;
                signal data_wr_strobe :  STD_LOGIC;
                signal ds_MISO :  STD_LOGIC;
                signal enableSS :  STD_LOGIC;
                signal endofpacketvalue_reg :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal endofpacketvalue_wr_strobe :  STD_LOGIC;
                signal iEOP_reg :  STD_LOGIC;
                signal iE_reg :  STD_LOGIC;
                signal iROE_reg :  STD_LOGIC;
                signal iRRDY_reg :  STD_LOGIC;
                signal iTMT_reg :  STD_LOGIC;
                signal iTOE_reg :  STD_LOGIC;
                signal iTRDY_reg :  STD_LOGIC;
                signal irq_reg :  STD_LOGIC;
                signal p1_data_rd_strobe :  STD_LOGIC;
                signal p1_data_to_cpu :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal p1_data_wr_strobe :  STD_LOGIC;
                signal p1_rd_strobe :  STD_LOGIC;
                signal p1_slowcount :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal p1_wr_strobe :  STD_LOGIC;
                signal rd_strobe :  STD_LOGIC;
                signal rx_holding_reg :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal shift_reg :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal slaveselect_wr_strobe :  STD_LOGIC;
                signal slowclock :  STD_LOGIC;
                signal slowcount :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal spi_control :  STD_LOGIC_VECTOR (10 DOWNTO 0);
                signal spi_slave_select_holding_reg :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal spi_slave_select_reg :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal spi_status :  STD_LOGIC_VECTOR (10 DOWNTO 0);
                signal state :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal stateZero :  STD_LOGIC;
                signal status_wr_strobe :  STD_LOGIC;
                signal transmitting :  STD_LOGIC;
                signal tx_holding_primed :  STD_LOGIC;
                signal tx_holding_reg :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal wr_strobe :  STD_LOGIC;
                signal write_shift_reg :  STD_LOGIC;
                signal write_tx_holding :  STD_LOGIC;

begin

  --spi_control_port, which is an e_avalon_slave
  p1_rd_strobe <= (NOT rd_strobe AND spi_select) AND NOT read_n;
  -- Read is a two-cycle event.
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      rd_strobe <= std_logic'('0');
    elsif clk'event and clk = '1' then
      rd_strobe <= p1_rd_strobe;
    end if;

  end process;

  p1_data_rd_strobe <= p1_rd_strobe AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000000"))));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_rd_strobe <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_rd_strobe <= p1_data_rd_strobe;
    end if;

  end process;

  p1_wr_strobe <= (NOT wr_strobe AND spi_select) AND NOT write_n;
  -- Write is a two-cycle event.
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      wr_strobe <= std_logic'('0');
    elsif clk'event and clk = '1' then
      wr_strobe <= p1_wr_strobe;
    end if;

  end process;

  p1_data_wr_strobe <= p1_wr_strobe AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000001"))));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_wr_strobe <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_wr_strobe <= p1_data_wr_strobe;
    end if;

  end process;

  control_wr_strobe <= wr_strobe AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000011"))));
  status_wr_strobe <= wr_strobe AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000010"))));
  slaveselect_wr_strobe <= wr_strobe AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000101"))));
  endofpacketvalue_wr_strobe <= wr_strobe AND to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000110"))));
  TMT <= NOT transmitting AND NOT tx_holding_primed;
  E <= ROE OR TOE;
  spi_status <= std_logic_vector'("0") & (Std_Logic_Vector'(A_ToStdLogicVector(EOP) & A_ToStdLogicVector(E) & A_ToStdLogicVector(RRDY) & A_ToStdLogicVector(TRDY) & A_ToStdLogicVector(TMT) & A_ToStdLogicVector(TOE) & A_ToStdLogicVector(ROE) & std_logic_vector'("000")));
  -- Streaming data ready for pickup.
  dataavailable <= RRDY;
  -- Ready to accept streaming data.
  readyfordata <= TRDY;
  -- Endofpacket condition detected.
  endofpacket <= EOP;
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      iEOP_reg <= std_logic'('0');
      iE_reg <= std_logic'('0');
      iRRDY_reg <= std_logic'('0');
      iTRDY_reg <= std_logic'('0');
      iTMT_reg <= std_logic'('0');
      iTOE_reg <= std_logic'('0');
      iROE_reg <= std_logic'('0');
      SSO_reg <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(control_wr_strobe) = '1' then 
        iEOP_reg <= data_from_cpu(9);
        iE_reg <= data_from_cpu(8);
        iRRDY_reg <= data_from_cpu(7);
        iTRDY_reg <= data_from_cpu(6);
        iTMT_reg <= data_from_cpu(5);
        iTOE_reg <= data_from_cpu(4);
        iROE_reg <= data_from_cpu(3);
        SSO_reg <= data_from_cpu(10);
      end if;
    end if;

  end process;

  spi_control <= Std_Logic_Vector'(A_ToStdLogicVector(SSO_reg) & A_ToStdLogicVector(iEOP_reg) & A_ToStdLogicVector(iE_reg) & A_ToStdLogicVector(iRRDY_reg) & A_ToStdLogicVector(iTRDY_reg) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(iTOE_reg) & A_ToStdLogicVector(iROE_reg) & std_logic_vector'("000"));
  -- IRQ output.
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      irq_reg <= std_logic'('0');
    elsif clk'event and clk = '1' then
      irq_reg <= ((((((EOP AND iEOP_reg)) OR ((((TOE OR ROE)) AND iE_reg))) OR ((RRDY AND iRRDY_reg))) OR ((TRDY AND iTRDY_reg))) OR ((TOE AND iTOE_reg))) OR ((ROE AND iROE_reg));
    end if;

  end process;

  irq <= irq_reg;
  -- Slave select register.
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_slave_select_reg <= std_logic_vector'("0000000000000001");
    elsif clk'event and clk = '1' then
      if std_logic'((write_shift_reg OR ((control_wr_strobe AND data_from_cpu(10)) AND NOT SSO_reg))) = '1' then 
        spi_slave_select_reg <= spi_slave_select_holding_reg;
      end if;
    end if;

  end process;

  -- Slave select holding register.
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_slave_select_holding_reg <= std_logic_vector'("0000000000000001");
    elsif clk'event and clk = '1' then
      if std_logic'(slaveselect_wr_strobe) = '1' then 
        spi_slave_select_holding_reg <= data_from_cpu;
      end if;
    end if;

  end process;

  -- slowclock is active once every 5 system clock pulses.
  slowclock <= to_std_logic((slowcount = std_logic_vector'("100")));
  p1_slowcount <= A_EXT (((((std_logic_vector'("000000000000000000000000000000") & (A_REP(((transmitting AND NOT(slowclock))) , 3))) AND (((std_logic_vector'("000000000000000000000000000000") & (slowcount)) + std_logic_vector'("000000000000000000000000000000001"))))) OR (std_logic_vector'("0") & ((((std_logic_vector'("00000000000000000000000000000") & (A_REP((NOT ((transmitting AND NOT(slowclock)))) , 3))) AND std_logic_vector'("00000000000000000000000000000000")))))), 3);
  -- Divide counter for SPI clock.
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      slowcount <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      slowcount <= p1_slowcount;
    end if;

  end process;

  -- End-of-packet value register.
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      endofpacketvalue_reg <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      if std_logic'(endofpacketvalue_wr_strobe) = '1' then 
        endofpacketvalue_reg <= data_from_cpu;
      end if;
    end if;

  end process;

  p1_data_to_cpu <= A_WE_StdLogicVector((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000010"))), (std_logic_vector'("00000") & (spi_status)), A_WE_StdLogicVector((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000011"))), (std_logic_vector'("00000") & (spi_control)), A_WE_StdLogicVector((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000110"))), endofpacketvalue_reg, A_WE_StdLogicVector((((std_logic_vector'("00000000000000000000000000000") & (mem_addr)) = std_logic_vector'("00000000000000000000000000000101"))), spi_slave_select_reg, (std_logic_vector'("00000000") & (rx_holding_reg))))));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_to_cpu <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      -- Data to cpu.
      data_to_cpu <= p1_data_to_cpu;
    end if;

  end process;

  -- 'state' counts from 0 to 17.
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      state <= std_logic_vector'("00000");
      stateZero <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((transmitting AND slowclock)) = '1' then 
        stateZero <= to_std_logic(((std_logic_vector'("000000000000000000000000000") & (state)) = std_logic_vector'("00000000000000000000000000010001")));
        if (std_logic_vector'("000000000000000000000000000") & (state)) = std_logic_vector'("00000000000000000000000000010001") then 
          state <= std_logic_vector'("00000");
        else
          state <= A_EXT (((std_logic_vector'("0000000000000000000000000000") & (state)) + std_logic_vector'("000000000000000000000000000000001")), 5);
        end if;
      end if;
    end if;

  end process;

  enableSS <= transmitting AND NOT stateZero;
  MOSI <= shift_reg(7);
  SS_n <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((enableSS OR SSO_reg))) = '1'), NOT spi_slave_select_reg, (std_logic_vector'("000000000000000") & (A_TOSTDLOGICVECTOR(std_logic'('1'))))));
  SCLK <= SCLK_reg;
  -- As long as there's an empty spot somewhere,
  --it's safe to write data.
  TRDY <= NOT ((transmitting AND tx_holding_primed));
  -- Enable write to tx_holding_register.
  write_tx_holding <= data_wr_strobe AND TRDY;
  -- Enable write to shift register.
  write_shift_reg <= tx_holding_primed AND NOT transmitting;
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      shift_reg <= std_logic_vector'("00000000");
      rx_holding_reg <= std_logic_vector'("00000000");
      EOP <= std_logic'('0');
      RRDY <= std_logic'('0');
      ROE <= std_logic'('0');
      TOE <= std_logic'('0');
      tx_holding_reg <= std_logic_vector'("00000000");
      tx_holding_primed <= std_logic'('0');
      transmitting <= std_logic'('0');
      SCLK_reg <= std_logic'('0');
      MISO_reg <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(write_tx_holding) = '1' then 
        tx_holding_reg <= data_from_cpu (7 DOWNTO 0);
        tx_holding_primed <= std_logic'('1');
      end if;
      if std_logic'((data_wr_strobe AND NOT TRDY)) = '1' then 
        -- You wrote when I wasn't ready.
        TOE <= std_logic'('1');
      end if;
      -- EOP must be updated by the last (2nd) cycle of access.
      if std_logic'((((p1_data_rd_strobe AND to_std_logic((((std_logic_vector'("00000000") & (rx_holding_reg)) = endofpacketvalue_reg))))) OR ((p1_data_wr_strobe AND to_std_logic((((std_logic_vector'("00000000") & (data_from_cpu(7 DOWNTO 0))) = endofpacketvalue_reg))))))) = '1' then 
        EOP <= std_logic'('1');
      end if;
      if std_logic'(write_shift_reg) = '1' then 
        shift_reg <= tx_holding_reg;
        transmitting <= std_logic'('1');
      end if;
      if std_logic'((write_shift_reg AND NOT write_tx_holding)) = '1' then 
        -- Clear tx_holding_primed
        tx_holding_primed <= std_logic'('0');
      end if;
      if std_logic'(data_rd_strobe) = '1' then 
        -- On data read, clear the RRDY bit.
        RRDY <= std_logic'('0');
      end if;
      if std_logic'(status_wr_strobe) = '1' then 
        -- On status write, clear all status bits (ignore the data).
        EOP <= std_logic'('0');
        RRDY <= std_logic'('0');
        ROE <= std_logic'('0');
        TOE <= std_logic'('0');
      end if;
      if std_logic'(slowclock) = '1' then 
        if (std_logic_vector'("000000000000000000000000000") & (state)) = std_logic_vector'("00000000000000000000000000010001") then 
          transmitting <= std_logic'('0');
          RRDY <= std_logic'('1');
          rx_holding_reg <= shift_reg;
          SCLK_reg <= std_logic'('0');
          if std_logic'(RRDY) = '1' then 
            ROE <= std_logic'('1');
          end if;
        elsif (std_logic_vector'("000000000000000000000000000") & (state)) /= std_logic_vector'("00000000000000000000000000000000") then 
          if std_logic'(transmitting) = '1' then 
            SCLK_reg <= NOT SCLK_reg;
          end if;
        end if;
        if ((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(SCLK_reg))) XOR std_logic_vector'("00000000000000000000000000000000")) XOR std_logic_vector'("00000000000000000000000000000000"))) /= std_logic_vector'("00000000000000000000000000000000") then 
          if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
            shift_reg <= Std_Logic_Vector'(shift_reg(6 DOWNTO 0) & A_ToStdLogicVector(MISO_reg));
          end if;
        else
          MISO_reg <= ds_MISO;
        end if;
      end if;
    end if;

  end process;

  ds_MISO <= MISO;

end europa;

