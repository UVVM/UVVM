library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.txt_util.all;
------------------------------------------------------------
entity I2C_slave is
  generic (
    SLAVE_ADDR : std_logic_vector(6 downto 0));
  port (
    scl              : inout std_logic;
    sda              : inout std_logic;
    clk              : in    std_logic;
    rst              : in    std_logic;
    -- User interface
    read_req         : out   std_logic;
    data_to_master   : in    std_logic_vector(7 downto 0);
    data_valid       : out   std_logic;
    data_from_master : out   std_logic_vector(7 downto 0));
end entity I2C_slave;
------------------------------------------------------------
architecture arch of I2C_slave is
  type state_t is (i2c_idle, i2c_get_address_and_cmd,
                   i2c_answer_ack_start, i2c_write,
                   i2c_read, i2c_read_ack_start,
                   i2c_read_ack_got_rising, i2c_read_stop);
  -- I2C state management
  signal state_reg          : state_t              := i2c_idle;
  signal cmd_reg            : std_logic            := '0';
  signal bits_processed_reg : integer range 0 to 8 := 0;
  signal continue_reg       : std_logic            := '0';

  -- Helpers to figure out next state
  signal start_reg       : std_logic := '0';
  signal stop_reg        : std_logic := '0';
  signal scl_rising_reg  : std_logic := '0';
  signal scl_falling_reg : std_logic := '0';

  -- Address and data received from master
  signal addr_reg : std_logic_vector(6 downto 0) := (others => '0');
  signal data_reg : std_logic_vector(7 downto 0) := (others => '0');

  -- Delayed SCL (by 1 clock cycle, and by 2 clock cycles)
  signal scl_reg      : std_logic := '1';
  signal scl_prev_reg : std_logic := '1';
  -- Slave writes on scl
  signal scl_wen_reg  : std_logic := '0';
  signal scl_o_reg    : std_logic := '0';
  -- Delayed SDA (1 clock cycle, and 2 clock cycles)
  signal sda_reg      : std_logic := '1';
  signal sda_prev_reg : std_logic := '1';
  -- Slave writes on sda
  signal sda_wen_reg  : std_logic := '0';
  signal sda_o_reg    : std_logic := '0';

  -- User interface
  signal data_valid_reg     : std_logic                    := '0';
  signal read_req_reg       : std_logic                    := '0';
  signal data_to_master_reg : std_logic_vector(7 downto 0) := (others => '0');
begin
  process (clk) is
  begin
    if rising_edge(clk) then
      -- Delay SCL by 1 and 2 clock cycles
      scl_reg        <= to_x01(scl);
      scl_prev_reg   <= scl_reg;
      -- Delay SDA by 1 and 2 clock cycles
      sda_reg        <= to_x01(sda);
      sda_prev_reg   <= sda_reg;
      -- Detect rising and falling SCL
      scl_rising_reg <= '0';
      if scl_prev_reg = '0' and scl_reg = '1' then
        scl_rising_reg <= '1';
      end if;
      scl_falling_reg <= '0';
      if scl_prev_reg = '1' and scl_reg = '0' then
        scl_falling_reg <= '1';
      end if;

      -- Detect I2C START condition
      start_reg <= '0';
      stop_reg  <= '0';
      if scl_reg = '1' and scl_prev_reg = '1' and
        sda_prev_reg = '1' and sda_reg = '0' then
        start_reg <= '1';
        stop_reg  <= '0';
      end if;

      -- Detect I2C STOP condition
      if scl_prev_reg = '1' and scl_reg = '1' and
        sda_prev_reg = '0' and sda_reg = '1' then
        start_reg <= '0';
        stop_reg  <= '1';
      end if;

    end if;
  end process;

  ----------------------------------------------------------
  -- I2C state machine
  ----------------------------------------------------------
  process (clk) is
  begin
    if rising_edge(clk) then
      -- Default assignments
      sda_o_reg      <= '0';
      sda_wen_reg    <= '0';
      -- User interface
      data_valid_reg <= '0';
      read_req_reg   <= '0';

      case state_reg is

        when i2c_idle =>
          if start_reg = '1' then
            state_reg          <= i2c_get_address_and_cmd;
            bits_processed_reg <= 0;
          end if;

        when i2c_get_address_and_cmd =>
          if scl_rising_reg = '1' then
            if bits_processed_reg < 7 then
              bits_processed_reg             <= bits_processed_reg + 1;
              addr_reg(6-bits_processed_reg) <= sda_reg;
            elsif bits_processed_reg = 7 then
              bits_processed_reg <= bits_processed_reg + 1;
              cmd_reg            <= sda_reg;
            end if;
          end if;

          if bits_processed_reg = 8 and scl_falling_reg = '1' then
            bits_processed_reg <= 0;
            if addr_reg = SLAVE_ADDR then  -- check req address
              state_reg <= i2c_answer_ack_start;
              if cmd_reg = '1' then  -- issue read request 
                read_req_reg       <= '1';
                data_to_master_reg <= data_to_master;
              end if;
            else
              assert false
                report ("I2C: slave address: " & str(SLAVE_ADDR) &
                        ", requested address: " & str(addr_reg))
                severity note;
              state_reg <= i2c_idle;
            end if;
          end if;

        ----------------------------------------------------
        -- I2C acknowledge to master
        ----------------------------------------------------
        when i2c_answer_ack_start =>
          sda_wen_reg <= '1';
          sda_o_reg   <= '0';
          if scl_falling_reg = '1' then
            if cmd_reg = '0' then
              state_reg <= i2c_write;
            else
              state_reg <= i2c_read;
            end if;
          end if;

        ----------------------------------------------------
        -- WRITE
        ----------------------------------------------------
        when i2c_write =>
          if scl_rising_reg = '1' then
            if bits_processed_reg <= 7 then
              data_reg(7-bits_processed_reg) <= sda_reg;
              bits_processed_reg             <= bits_processed_reg + 1;
            end if;
            if bits_processed_reg = 7 then
              data_valid_reg <= '1';
            end if;
          end if;

          if scl_falling_reg = '1' and bits_processed_reg = 8 then
            state_reg          <= i2c_answer_ack_start;
            bits_processed_reg <= 0;
          end if;

        ----------------------------------------------------
        -- READ: send data to master
        ----------------------------------------------------
        when i2c_read =>
          sda_wen_reg <= '1';
          sda_o_reg   <= data_to_master_reg(7-bits_processed_reg);
          if scl_falling_reg = '1' then
            if bits_processed_reg < 7 then
              bits_processed_reg <= bits_processed_reg + 1;
            elsif bits_processed_reg = 7 then
              state_reg          <= i2c_read_ack_start;
              bits_processed_reg <= 0;
            end if;
          end if;

        ----------------------------------------------------
        -- I2C read master acknowledge
        ----------------------------------------------------
        when i2c_read_ack_start =>
          if scl_rising_reg = '1' then
            state_reg <= i2c_read_ack_got_rising;
            if sda_reg = '1' then       -- nack = stop read
              continue_reg <= '0';
            else                   -- ack = continue read
              continue_reg       <= '1';
              read_req_reg       <= '1';  -- request reg byte
              data_to_master_reg <= data_to_master;
            end if;
          end if;

        when i2c_read_ack_got_rising =>
          if scl_falling_reg = '1' then
            if continue_reg = '1' then
              if cmd_reg = '0' then
                state_reg <= i2c_write;
              else
                state_reg <= i2c_read;
              end if;
            else
              state_reg <= i2c_read_stop;
            end if;
          end if;

        -- Wait for START or STOP to get out of this state
        when i2c_read_stop =>
          null;

        -- Wait for START or STOP to get out of this state
        when others =>
          assert false
            report ("I2C: slave address: " & str(SLAVE_ADDR) &
                    "ended up in an impossible state.")
            severity note;
          null;
      end case;

      --------------------------------------------------------
      -- Reset counter and state on start/stop
      --------------------------------------------------------
      if start_reg = '1' then
        state_reg          <= i2c_get_address_and_cmd;
        bits_processed_reg <= 0;
      end if;

      if stop_reg = '1' then
        state_reg          <= i2c_idle;
        bits_processed_reg <= 0;
      end if;

      if rst = '1' then
        state_reg <= i2c_idle;
      end if;
    end if;
  end process;

  ----------------------------------------------------------
  -- I2C interface
  ----------------------------------------------------------
  sda <= sda_o_reg when sda_wen_reg = '1' else
         'Z';
  scl <= scl_o_reg when scl_wen_reg = '1' else
         'Z';
  ----------------------------------------------------------
  -- User interface
  ----------------------------------------------------------
  -- Master writes
  data_valid       <= data_valid_reg;
  data_from_master <= data_reg;
  -- Master reads
  read_req         <= read_req_reg;
end architecture arch;
