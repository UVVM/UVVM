library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity avalon_st_fifo is
  generic(
    GC_DATA_WIDTH    : natural := 8;
    GC_CHANNEL_WIDTH : natural := 1;
    GC_EMPTY_WIDTH   : natural := 1;
    GC_ERROR_WIDTH   : natural := 1;
    GC_FIFO_DEPTH    : natural := 256;
    GC_READY_LATENCY : natural := 0
  );
  port(
    clk_i            : in  std_logic;
    reset_i          : in  std_logic;
    -- Slave stream interface: data in
    slave_data_i     : in  std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    slave_channel_i  : in  std_logic_vector(GC_CHANNEL_WIDTH - 1 downto 0);
    slave_empty_i    : in  std_logic_vector(GC_EMPTY_WIDTH - 1 downto 0);
    slave_error_i    : in  std_logic_vector(GC_ERROR_WIDTH - 1 downto 0);
    slave_valid_i    : in  std_logic;
    slave_sop_i      : in  std_logic;
    slave_eop_i      : in  std_logic;
    slave_ready_o    : out std_logic := '0';
    -- Master stream interface: data out
    master_data_o    : out std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    master_channel_o : out std_logic_vector(GC_CHANNEL_WIDTH - 1 downto 0);
    master_empty_o   : out std_logic_vector(GC_EMPTY_WIDTH - 1 downto 0);
    master_error_o   : out std_logic_vector(GC_ERROR_WIDTH - 1 downto 0);
    master_valid_o   : out std_logic := '0';
    master_sop_o     : out std_logic;
    master_eop_o     : out std_logic;
    master_ready_i   : in  std_logic;
    -- FIFO empty
    empty_o          : out std_logic := '1'
  );
end avalon_st_fifo;

architecture Behavioral of avalon_st_fifo is

begin

  -- Memory Pointer Process
  p_main : process(clk_i)
    type t_data_mem is array (0 to GC_FIFO_DEPTH - 1) of std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable v_data_mem : t_data_mem := (others => (others => '0'));

    type t_channel_mem is array (0 to GC_FIFO_DEPTH - 1) of std_logic_vector(GC_CHANNEL_WIDTH - 1 downto 0);
    variable v_channel_mem : t_channel_mem := (others => (others => '0'));

    type t_empty_mem is array (0 to GC_FIFO_DEPTH - 1) of std_logic_vector(GC_EMPTY_WIDTH - 1 downto 0);
    variable v_empty_mem : t_empty_mem := (others => (others => '0'));

    type t_error_mem is array (0 to GC_FIFO_DEPTH - 1) of std_logic_vector(GC_ERROR_WIDTH - 1 downto 0);
    variable v_error_mem : t_error_mem := (others => (others => '0'));

    type t_sop_mem is array (0 to GC_FIFO_DEPTH - 1) of std_logic;
    variable v_sop_mem : t_sop_mem := (others => '0');

    type t_eop_mem is array (0 to GC_FIFO_DEPTH - 1) of std_logic;
    variable v_eop_mem : t_eop_mem := (others => '0');

    variable v_WrPtr  : natural range 0 to GC_FIFO_DEPTH - 1 := 0; -- Write pointer
    variable v_RdPtr  : natural range 0 to GC_FIFO_DEPTH - 1 := 0; -- Read pointer
    variable v_count  : natural range 0 to GC_FIFO_DEPTH     := 0; -- Number of words currently stored

    -- Ready history. Before the shift at a rising edge, index i holds the ready value of the
    -- cycle i+1 cycles back, i.e. index GC_READY_LATENCY - 1 is the ready that qualifies the current cycle.
    type t_ready_pipeline is array (0 to GC_READY_LATENCY) of std_logic;
    variable v_slave_ready_pipeline  : t_ready_pipeline := (others => '0');
    variable v_master_ready_pipeline : t_ready_pipeline := (others => '0');

    variable v_slave_transfer_ready  : std_logic := '0';
    variable v_master_transfer_ready : std_logic := '0';
    variable v_do_write              : boolean   := false;
    variable v_do_read               : boolean   := false;
    variable v_pending_ready         : natural   := 0;
  begin
    if rising_edge(clk_i) then
      if reset_i = '1' then
        v_WrPtr                 := 0;
        v_RdPtr                 := 0;
        v_count                 := 0;
        v_slave_ready_pipeline  := (others => '0');
        v_master_ready_pipeline := (others => '0');
        master_valid_o          <= '0';
        slave_ready_o           <= '0'; -- Keep ready low in reset so it matches the ready pipeline
        empty_o                 <= '1';
      else
        -- Ready that qualifies a transfer in the current cycle: ready(current cycle - GC_READY_LATENCY)
        if GC_READY_LATENCY = 0 then
          v_slave_transfer_ready  := slave_ready_o;
          v_master_transfer_ready := master_ready_i;
        else
          v_slave_transfer_ready  := v_slave_ready_pipeline(GC_READY_LATENCY - 1);
          v_master_transfer_ready := v_master_ready_pipeline(GC_READY_LATENCY - 1);
        end if;

        -- When a word is read, update read pointer
        v_do_read := (master_valid_o = '1' and v_master_transfer_ready = '1');
        if v_do_read then
          if (v_RdPtr = GC_FIFO_DEPTH - 1) then
            v_RdPtr := 0;
          else
            v_RdPtr := v_RdPtr + 1;
          end if;
        end if;

        -- Data In
        v_do_write := (slave_valid_i = '1' and v_slave_transfer_ready = '1' and (v_count < GC_FIFO_DEPTH or v_do_read));
        -- A beat in a ready cycle must be accepted, so a full FIFO here means the ready accounting is broken
        assert not (slave_valid_i = '1' and v_slave_transfer_ready = '1' and not v_do_write)
          report "avalon_st_fifo: FIFO overflow, data transferred in a ready cycle was dropped"
          severity error;
        if v_do_write then
          -- Write Data to Memory
          v_data_mem(v_WrPtr)    := slave_data_i;
          v_channel_mem(v_WrPtr) := slave_channel_i;
          v_empty_mem(v_WrPtr)   := slave_empty_i;
          v_error_mem(v_WrPtr)   := slave_error_i;
          v_sop_mem(v_WrPtr)     := slave_sop_i;
          v_eop_mem(v_WrPtr)     := slave_eop_i;

          -- Increment Head pointer as needed
          if (v_WrPtr = GC_FIFO_DEPTH - 1) then
            v_WrPtr := 0;
          else
            v_WrPtr := v_WrPtr + 1;
          end if;
        end if;

        if v_do_write and not v_do_read then
          v_count := v_count + 1;
        elsif v_do_read and not v_do_write then
          v_count := v_count - 1;
        end if;

        -- FIFO output
        master_data_o    <= v_data_mem(v_RdPtr);
        master_channel_o <= v_channel_mem(v_RdPtr);
        master_empty_o   <= v_empty_mem(v_RdPtr);
        master_error_o   <= v_error_mem(v_RdPtr);
        master_sop_o     <= v_sop_mem(v_RdPtr);
        master_eop_o     <= v_eop_mem(v_RdPtr);

        -- Shift in the ready values of the current cycle. After the shift, index i holds the ready
        -- value of the cycle i cycles back, i.e. index GC_READY_LATENCY - 1 qualifies the next cycle.
        if GC_READY_LATENCY > 0 then
          for i in GC_READY_LATENCY downto 1 loop
            v_slave_ready_pipeline(i)  := v_slave_ready_pipeline(i - 1);
            v_master_ready_pipeline(i) := v_master_ready_pipeline(i - 1);
          end loop;
          v_slave_ready_pipeline(0)  := slave_ready_o;
          v_master_ready_pipeline(0) := master_ready_i;
        end if;

        -- Set valid_o. With ready latency, valid may only be asserted in ready cycles.
        if GC_READY_LATENCY > 0 then
          if (v_count > 0) and v_master_ready_pipeline(GC_READY_LATENCY - 1) = '1' then
            master_valid_o <= '1';
          else
            master_valid_o <= '0';
          end if;
        else
          if (v_count > 0) then
            master_valid_o <= '1';
          else
            master_valid_o <= '0';
          end if;
        end if;

        -- Set empty_o
        empty_o <= '0' when v_count > 0 else '1';

        -- Account for ready-latency data which may still arrive: every ready cycle in the last
        -- GC_READY_LATENCY cycles (including the current one) can still result in a transfer.
        v_pending_ready := 0;
        for i in 0 to GC_READY_LATENCY - 1 loop
          if v_slave_ready_pipeline(i) = '1' then
            v_pending_ready := v_pending_ready + 1;
          end if;
        end loop;

        if (GC_FIFO_DEPTH - v_count > v_pending_ready) then
          slave_ready_o <= '1';
        else
          slave_ready_o <= '0';
        end if;
      end if;
    end if;
  end process p_main;

end Behavioral;
