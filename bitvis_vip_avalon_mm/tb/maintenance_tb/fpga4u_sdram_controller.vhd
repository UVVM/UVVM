-- DUT from https://fpga4u.epfl.ch/wiki/VHDL_modules

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpga4u_sdram_controller is
  port(
    --Avalon slave interface (pipelined, variable latency)
    signal clk, reset          : in    std_logic;
    signal as_address          : in    std_logic_vector(22 downto 0);
    signal as_read, as_write   : in    std_logic;
    signal as_byteenable       : in    std_logic_vector(3 downto 0);
    signal as_readdata         : out   std_logic_vector(31 downto 0);
    signal as_writedata        : in    std_logic_vector(31 downto 0);
    signal as_waitrequest      : out   std_logic;
    signal as_readdatavalid    : out   std_logic;
    --SDRAM interface to FPGA4U SDRAM
    signal ram_addr            : out   std_logic_vector(11 downto 0);
    signal ram_ba              : out   std_logic_vector(1 downto 0);
    signal ram_cas_n           : out   std_logic;
    signal ram_cke             : out   std_logic;
    signal ram_cs_n            : out   std_logic;
    signal ram_dq              : inout std_logic_vector(31 downto 0);
    signal ram_dqm             : out   std_logic_vector(3 downto 0);
    signal ram_ras_n           : out   std_logic;
    signal ram_we_n            : out   std_logic;
    -- DEBUG PORTS (By Bitvis)
    signal debug_received_data : out   std_logic_vector(31 downto 0); -- Data received from last Avalon-MM write
    signal debug_data_to_send  : in    std_logic_vector(31 downto 0) -- Data to send when data is requested from Avalon-MM IF
  );
end entity;

architecture arch of fpga4u_sdram_controller is
  --Initialisation signals
  type init_state_t is (init_reset, init_pre, init_wait_pre, init_ref, init_wait_ref, init_mode, init_wait_mode, init_done);
  signal init_state        : init_state_t := init_reset;
  signal init_wait_counter : unsigned(15 downto 0);
  signal init_ref_counter  : unsigned(3 downto 0);

  --Main state machine
  type state_t is (idle, ref, wait_ref, act, wait_act, read, spin_read, write, spin_write, precharge_all, wait_precharge);
  signal state        : state_t := idle;
  signal ref_counter  : unsigned(10 downto 0);
  signal ref_req      : std_logic;
  signal wait_counter : unsigned(2 downto 0);

  --Active transaction signals
  signal int_address    : std_logic_vector(22 downto 0);
  signal int_readdata   : std_logic_vector(31 downto 0);
  signal int_writedata  : std_logic_vector(31 downto 0);
  signal int_byteenable : std_logic_vector(3 downto 0);
  signal int_writeop    : std_logic;

  --open bank and row
  signal open_bank : std_logic_vector(1 downto 0);
  signal open_row  : std_logic_vector(11 downto 0);

  --readdata ready pipeline
  signal readdata_ready : std_logic_vector(4 downto 0);

  signal ram_cmd : std_logic_vector(3 downto 0);
begin
  --State machine to handle SDRAM initialization
  INITSTATE : process(clk, reset)
  begin
    if reset = '1' then
      init_state        <= init_reset;
      --power up delay
      init_wait_counter <= to_unsigned(24000, init_wait_counter'length);
      --number refresh cycles before mode register write
      init_ref_counter  <= to_unsigned(2, init_ref_counter'length);
    elsif rising_edge(clk) then
      --count down when not 0
      if init_wait_counter /= 0 then
        init_wait_counter <= init_wait_counter - 1;
      end if;
      case init_state is
        when init_reset =>
          if init_wait_counter = 0 then
            init_state <= init_pre;
          end if;
        --do a precharge
        when init_pre =>
          init_wait_counter <= to_unsigned(3, init_wait_counter'length);
          init_state        <= init_wait_pre;
        when init_wait_pre =>
          if init_wait_counter = 0 then
            init_state <= init_ref;
          end if;
        --do a refresh
        when init_ref =>
          init_wait_counter <= to_unsigned(8, init_wait_counter'length);
          init_ref_counter  <= init_ref_counter - 1;
          init_state        <= init_wait_ref;
        when init_wait_ref =>
          if init_wait_counter = 0 then
            if init_ref_counter = 0 then
              init_state <= init_mode;
            else
              init_state <= init_ref;
            end if;
          end if;
        --set the mode register
        when init_mode =>
          init_wait_counter <= to_unsigned(2, init_wait_counter'length);
          init_state        <= init_wait_mode;
        when init_wait_mode =>
          if init_wait_counter = 0 then
            init_state <= init_done;
          end if;
        when others =>
          null;
      end case;
    end if;
  end process;

  --Asynchronous waitrequest to allow one transfer per cycle (critical path)
  as_waitrequest <= '0' when (state = idle and ref_req = '0' and (as_read = '1' or as_write = '1')) or ((state = read or state = spin_read) and ref_req = '0' and as_read = '1' and as_address(22 downto 11) = open_row and as_address(10 downto 9) = open_bank) or ((state = write or state = spin_write) and ref_req = '0' and as_write = '1' and as_address(22 downto 11) = open_row and as_address(10 downto 9) = open_bank) else
                    '1';

  --Main state machine
  make_state : process(clk, reset)
  begin
    if reset = '1' then
      state          <= idle;
      ref_counter    <= (others => '0');
      ref_req        <= '1';            --begin with a refresh
      wait_counter   <= (others => '0');
      readdata_ready <= (others => '0');
    elsif rising_edge(clk) then
      --counters for delays and refresh generation
      if wait_counter /= 0 then
        wait_counter <= wait_counter - 1;
      end if;
      if ref_counter /= 0 then
        ref_counter <= ref_counter - 1;
      else
        ref_req     <= '1';
        ref_counter <= to_unsigned(1800, ref_counter'length);
      end if;
      --main state machine runs when the initialization is done
      if init_state = init_done then
        case state is
          when idle =>
            if ref_req = '1' then       --go do a refresh
              ref_req <= '0';
              state   <= ref;
            elsif as_write = '1' or as_read = '1' then --accept the request and go to open the row
              int_address    <= as_address;
              int_writedata  <= as_writedata;
              int_byteenable <= as_byteenable;
              int_writeop    <= as_write;
              state          <= act;
            end if;
          when ref =>
            wait_counter <= to_unsigned(5, wait_counter'length);
            state        <= wait_ref;
          when wait_ref =>
            if wait_counter = 0 then
              state <= idle;
            end if;
          when act =>                   --save the open bank and row
            open_bank    <= int_address(10 downto 9);
            open_row     <= int_address(22 downto 11);
            wait_counter <= to_unsigned(1, wait_counter'length);
            state        <= wait_act;
          when wait_act =>
            if wait_counter = 0 then
              if int_writeop = '0' then
                state <= read;
              else
                state <= write;
              end if;
            end if;
          when read =>                  --issue a read command, feed a one in the readdata_ready pipeline, when it exits data is ready for the master
            as_readdata      <= debug_data_to_send; --int_readdata;
            as_readdatavalid <= readdata_ready(4);
            readdata_ready   <= readdata_ready(3 downto 0) & '1';
            if ref_req = '0' and as_read = '1' and as_address(22 downto 11) = open_row and as_address(10 downto 9) = open_bank then
              int_address <= as_address;
              state       <= read;
            else
              state <= spin_read;
            end if;
          when spin_read =>             --wait for reads to complete and eventually issue more compatible reads
            as_readdata      <= debug_data_to_send; --int_readdata;
            as_readdatavalid <= readdata_ready(4);
            readdata_ready   <= readdata_ready(3 downto 0) & '0';
            if readdata_ready = "00000" and (ref_req = '1' or as_write = '1') then
              state <= precharge_all;
            elsif ref_req = '0' and as_read = '1' and as_address(22 downto 11) = open_row and as_address(10 downto 9) = open_bank then
              int_address <= as_address;
              state       <= read;
            elsif readdata_ready = "00000" and as_read = '1' then
              state <= precharge_all;
            end if;
          when write =>                 --the same as read, except there is no pipeline as data is presented to the SDRAM on the same cycle as the command
            wait_counter <= to_unsigned(1, wait_counter'length);
            if ref_req = '0' and as_write = '1' and as_address(22 downto 11) = open_row and as_address(10 downto 9) = open_bank then
              int_address    <= as_address;
              int_writedata  <= as_writedata;
              int_byteenable <= as_byteenable;
              state          <= write;
            else
              state <= spin_write;
            end if;
          when spin_write =>            --same as for read
            if wait_counter = 0 and (ref_req = '1' or as_read = '1') then
              state <= precharge_all;
            elsif ref_req = '0' and as_write = '1' and as_address(22 downto 11) = open_row and as_address(10 downto 9) = open_bank then
              int_address    <= as_address;
              int_writedata  <= as_writedata;
              int_byteenable <= as_byteenable;
              state          <= write;
            elsif wait_counter = 0 and as_write = '1' then
              state <= precharge_all;
            end if;
          when precharge_all =>
            state <= wait_precharge;
          when wait_precharge =>
            state <= idle;
          when others =>
            null;
        end case;
      end if;
    end if;
  end process;

  --data from the ram needs to be sampled on the falling edge of the controller clock for proper operation
  process(clk)
  begin
    if falling_edge(clk) then
      int_readdata <= ram_dq;

    end if;
  end process;

  --process generating the command sequence for the SDRAM
  ram_cke   <= '1';
  ram_cs_n  <= ram_cmd(3);
  ram_ras_n <= ram_cmd(2);
  ram_cas_n <= ram_cmd(1);
  ram_we_n  <= ram_cmd(0);
  OUTPUTS : process(clk, reset)
  begin
    if reset = '1' then
      ram_addr <= (others => '0');
      ram_cmd  <= "1111";
      ram_ba   <= (others => '0');
      ram_dq   <= (others => 'Z');
      ram_dqm  <= (others => '1');
    elsif rising_edge(clk) then
      if init_state = init_pre then
        ram_cmd  <= "0010";             --precharge
        ram_addr <= (10 => '1', others => '0');
      elsif init_state = init_ref then
        ram_cmd <= "0001";              --refresh
      elsif init_state = init_mode then
        ram_cmd  <= "0000";             --mode set
        ram_addr <= "000000110000";     --no burst, three cycles latency
      elsif init_state = init_done then
        if state = ref then
          ram_cmd <= "0001";            --refresh
        elsif state = act then
          ram_cmd  <= "0011";           --activate
          ram_addr <= int_address(22 downto 11);
          ram_ba   <= int_address(10 downto 9);
        elsif state = read then
          ram_cmd  <= "0101";           --read
          ram_addr <= "000" & int_address(8 downto 0);
          ram_dqm  <= "0000";
        elsif state = write then
          ram_cmd             <= "0100"; --write
          ram_addr            <= "000" & int_address(8 downto 0);
          ram_dq              <= int_writedata;
          debug_received_data <= int_writedata;
          ram_dqm             <= not int_byteenable;
        elsif state = precharge_all then
          ram_cmd  <= "0010";           --precharge
          ram_addr <= "010" & int_address(8 downto 0);
          ram_dqm  <= "1111";
        else
          ram_cmd <= "1111";            --nop
          ram_dq  <= (others => 'Z');
        end if;
      else
        ram_cmd <= "1111";              --nop
      end if;
    end if;
  end process;
end arch;
