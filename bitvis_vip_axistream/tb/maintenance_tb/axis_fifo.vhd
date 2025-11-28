library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity axis_fifo is
  generic(
    constant GC_DATA_WIDTH : natural := 8;
    constant GC_USER_WIDTH : natural := 1;
    constant GC_FIFO_DEPTH : natural := 256
  );
  port(
    clk           : in  STD_LOGIC;
    rst           : in  STD_LOGIC;
    -- slave stream interface: data in
    s_axis_tready : out STD_LOGIC;
    s_axis_tvalid : in  STD_LOGIC;
    s_axis_tdata  : in  STD_LOGIC_VECTOR(GC_DATA_WIDTH - 1 downto 0);
    s_axis_tuser  : in  STD_LOGIC_VECTOR(GC_USER_WIDTH - 1 downto 0);
    s_axis_tkeep  : in  STD_LOGIC_VECTOR(GC_DATA_WIDTH / 8 - 1 downto 0);
    s_axis_tlast  : in  STD_LOGIC;
    -- master stream interface: data out
    m_axis_tready : in  STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tdata  : out STD_LOGIC_VECTOR(GC_DATA_WIDTH - 1 downto 0);
    m_axis_tuser  : out STD_LOGIC_VECTOR(GC_USER_WIDTH - 1 downto 0);
    m_axis_tkeep  : out STD_LOGIC_VECTOR(GC_DATA_WIDTH / 8 - 1 downto 0);
    m_axis_tlast  : out STD_LOGIC;
    empty         : out STD_LOGIC := '1'
  );
end axis_fifo;

architecture Behavioral of axis_fifo is
  signal m_axis_tvalid_i : std_logic := '0';
  signal s_axis_tready_i : std_logic := '1';

begin
  m_axis_tvalid <= m_axis_tvalid_i;
  s_axis_tready <= s_axis_tready_i;

  -- Memory Pointer Process
  fifo_proc : process(clk)
    type t_data_mem is array (0 to GC_FIFO_DEPTH - 1) of STD_LOGIC_VECTOR(GC_DATA_WIDTH - 1 downto 0);
    variable v_data_mem : t_data_mem;

    type t_user_mem is array (0 to GC_FIFO_DEPTH - 1) of STD_LOGIC_VECTOR(GC_USER_WIDTH - 1 downto 0);
    variable v_user_mem : t_user_mem;

    type t_keep_mem is array (0 to GC_FIFO_DEPTH - 1) of STD_LOGIC_VECTOR(GC_DATA_WIDTH / 8 - 1 downto 0);
    variable v_keep_mem : t_keep_mem;

    type t_last_mem is array (0 to GC_FIFO_DEPTH - 1) of STD_LOGIC;
    variable v_last_mem : t_last_mem;

    variable v_WrPtr : natural range 0 to GC_FIFO_DEPTH - 1 := 0; -- Write pointer
    variable v_RdPtr : natural range 0 to GC_FIFO_DEPTH - 1 := 0; -- Read pointer

    variable v_looped : boolean := false;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        v_WrPtr := 0;
        v_RdPtr := 0;

        v_looped := false;

        m_axis_tvalid_i <= '0';
        s_axis_tready_i <= '1';
        empty           <= '1';
      else
        m_axis_tvalid_i <= '0';

        -- When a word is read, update read pointer
        if (m_axis_tvalid_i = '1' and m_axis_tready = '1') then
          if (v_RdPtr = GC_FIFO_DEPTH - 1) then
            v_RdPtr := 0;

            v_looped := false;
          else
            v_RdPtr := v_RdPtr + 1;
          end if;
        end if;

        if ((v_looped = true) or (v_WrPtr /= v_RdPtr)) then
          -- FIFO not empty
          m_axis_tvalid_i <= '1';
        end if;

        -- FIFO output 
        m_axis_tdata <= v_data_mem(v_RdPtr);
        m_axis_tuser <= v_user_mem(v_RdPtr);
        m_axis_tkeep <= v_keep_mem(v_RdPtr);
        m_axis_tlast <= v_last_mem(v_RdPtr);

        -- Data In
        if (s_axis_tvalid = '1' and s_axis_tready_i = '1') then
          --report "tvalid and tready";
          if ((v_looped = false) or (v_WrPtr /= v_RdPtr)) then
            -- Write Data to Memory
            v_data_mem(v_WrPtr) := s_axis_tdata;
            v_user_mem(v_WrPtr) := s_axis_tuser;
            v_keep_mem(v_WrPtr) := s_axis_tkeep;
            v_last_mem(v_WrPtr) := s_axis_tlast;

            -- Increment Head pointer as needed
            if (v_WrPtr = GC_FIFO_DEPTH - 1) then
              v_WrPtr := 0;

              v_looped := true;
            else
              v_WrPtr := v_WrPtr + 1;
            end if;
          end if;
        end if;

        -- Update Empty and Full flags
        if (v_WrPtr = v_RdPtr) then
          if v_looped then
            s_axis_tready_i <= '0';
          -- if s_axis_tready_i = '1' then 
          --   report "setting tready=0";
          -- end if; 
          else
            empty <= '1';
          end if;
        else
          empty           <= '0';
          s_axis_tready_i <= '1';
          -- if s_axis_tready_i = '0' then 
          --   report "setting tready=1";
          -- end if; 
        end if;
      end if;
    end if;
  end process;

end Behavioral;

