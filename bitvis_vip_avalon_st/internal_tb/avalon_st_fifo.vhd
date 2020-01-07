library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity avalon_st_fifo is
   generic (
      GC_DATA_WIDTH    : natural := 8;
      GC_CHANNEL_WIDTH : natural := 1;
      GC_EMPTY_WIDTH   : natural := 1;
      GC_ERROR_WIDTH   : natural := 1;
      GC_FIFO_DEPTH    : natural := 256
   );
   port (
      clk_i            : in  std_logic;
      reset_i          : in  std_logic;
      -- Slave stream interface: data in
      slave_data_i     : in  std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      slave_channel_i  : in  std_logic_vector(GC_CHANNEL_WIDTH-1 downto 0);
      slave_empty_i    : in  std_logic_vector(GC_EMPTY_WIDTH-1 downto 0);
      slave_error_i    : in  std_logic_vector(GC_ERROR_WIDTH-1 downto 0);
      slave_valid_i    : in  std_logic;
      slave_sop_i      : in  std_logic; 
      slave_eop_i      : in  std_logic; 
      slave_ready_o    : out std_logic := '1';
      -- Master stream interface: data out
      master_data_o    : out std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      master_channel_o : out std_logic_vector(GC_CHANNEL_WIDTH-1 downto 0);
      master_empty_o   : out std_logic_vector(GC_EMPTY_WIDTH-1 downto 0);
      master_error_o   : out std_logic_vector(GC_ERROR_WIDTH-1 downto 0);
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
   p_main : process (clk_i)
      type t_data_mem is array (0 to GC_FIFO_DEPTH-1) of std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      variable v_data_mem : t_data_mem := (others => (others => '0'));

      type t_channel_mem is array (0 to GC_FIFO_DEPTH-1) of std_logic_vector(GC_CHANNEL_WIDTH-1 downto 0);
      variable v_channel_mem : t_channel_mem := (others => (others => '0'));

      type t_empty_mem is array (0 to GC_FIFO_DEPTH-1) of std_logic_vector(GC_EMPTY_WIDTH-1 downto 0);
      variable v_empty_mem : t_empty_mem := (others => (others => '0'));

      type t_error_mem is array (0 to GC_FIFO_DEPTH-1) of std_logic_vector(GC_ERROR_WIDTH-1 downto 0);
      variable v_error_mem : t_error_mem := (others => (others => '0'));

      type t_sop_mem is array (0 to GC_FIFO_DEPTH-1) of std_logic;
      variable v_sop_mem : t_sop_mem := (others => '0');

      type t_eop_mem is array (0 to GC_FIFO_DEPTH-1) of std_logic;
      variable v_eop_mem : t_eop_mem := (others => '0');

      variable v_WrPtr  : natural range 0 to GC_FIFO_DEPTH-1 := 0; -- Write pointer
      variable v_RdPtr  : natural range 0 to GC_FIFO_DEPTH-1 := 0; -- Read pointer
      variable v_looped : boolean := false;
   begin
      if rising_edge(clk_i) then
         if reset_i = '1' then
            v_WrPtr        := 0;
            v_RdPtr        := 0;
            v_looped       := false;
            master_valid_o <= '0';
            slave_ready_o  <= '1';
            empty_o        <= '1';
         else
            master_valid_o <= '0';

            -- When a word is read, update read pointer
            if (master_valid_o = '1' and master_ready_i = '1') then
               if (v_RdPtr = GC_FIFO_DEPTH-1) then
                  v_RdPtr  := 0;
                  v_looped := false;
               else
                  v_RdPtr  := v_RdPtr + 1;
               end if;
            end if;

            -- FIFO not empty
            if ((v_looped = true) or (v_WrPtr /= v_RdPtr)) then
               master_valid_o <= '1';
            end if;

            -- FIFO output 
            master_data_o    <= v_data_mem(v_RdPtr);
            master_channel_o <= v_channel_mem(v_RdPtr);
            master_empty_o   <= v_empty_mem(v_RdPtr);
            master_error_o   <= v_error_mem(v_RdPtr);
            master_sop_o     <= v_sop_mem(v_RdPtr);
            master_eop_o     <= v_eop_mem(v_RdPtr);

            -- Data In
            if (slave_valid_i = '1' and slave_ready_o = '1') then
               --report "tvalid and tready";
               if ((v_looped = false) or (v_WrPtr /= v_RdPtr)) then
                  -- Write Data to Memory
                  v_data_mem(v_WrPtr)    := slave_data_i;
                  v_channel_mem(v_WrPtr) := slave_channel_i;
                  v_empty_mem(v_WrPtr)   := slave_empty_i;
                  v_error_mem(v_WrPtr)   := slave_error_i;
                  v_sop_mem(v_WrPtr)     := slave_sop_i;
                  v_eop_mem(v_WrPtr)     := slave_eop_i;

                  -- Increment Head pointer as needed
                  if (v_WrPtr = GC_FIFO_DEPTH-1) then
                     v_WrPtr  := 0;
                     v_looped := true;
                  else
                     v_WrPtr  := v_WrPtr + 1;
                  end if;
               end if;
            end if;

            -- Update Empty and Full flags
            if (v_WrPtr = v_RdPtr) then
               if v_looped then
                  slave_ready_o <= '0';
               else
                  empty_o       <= '1';
               end if;
            else
               slave_ready_o <= '1';
               empty_o       <= '0';
            end if;
         end if;
      end if;
   end process p_main;

end Behavioral;