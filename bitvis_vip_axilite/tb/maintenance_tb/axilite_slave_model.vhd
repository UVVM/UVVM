------------------------------------------------------------------------------
--
--     Purpose : AXI-Lite Slave model - a simple memory for write/read access
-- 
--      Author : Dag Sverre Skjelbreid <dss@bitvis.no>
--
-- Description :
--
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_vip_axilite;
use bitvis_vip_axilite.axilite_slave_model_pkg.all;
 
entity axilite_slave_model is
  generic(
    C_AXI_DATA_WIDTH : integer  := 64;
    C_AXI_ADDR_WIDTH : integer  := 32;
    C_MEMORY_SIZE    : integer := 4096; -- size in bytes
    C_MEMORY_START   : unsigned(31 downto 0) := x"00000000"  -- address offset to start on
    );
  port (
    aclk           : in std_logic;
    aresetn        : in std_logic;
    wr_port_in     : in  t_axilite_wr_slave_in_if(  awaddr( C_AXI_ADDR_WIDTH   - 1 downto 0),
                                                    wdata(  C_AXI_DATA_WIDTH   - 1 downto 0),
                                                    wstrb(  C_AXI_DATA_WIDTH/8 - 1 downto 0));
    wr_port_out    : out t_axilite_wr_slave_out_if;
    rd_port_in     : in  t_axilite_rd_slave_in_if(  araddr( C_AXI_ADDR_WIDTH   - 1 downto 0));
    rd_port_out    : out t_axilite_rd_slave_out_if( rdata(  C_AXI_DATA_WIDTH   - 1 downto 0))
    );
end entity axilite_slave_model;

architecture behav of axilite_slave_model is

  type   t_read_state is (addr_wait, rd_wait_rdy);
  type   t_write_state is (addr_wait, wr_wait_valid, wr_wait_awvalid, wr_wait_response);

  type   memory is array (INTEGER range <>) of std_logic_vector(7 downto 0);

  signal wr_state   : t_write_state;
  signal rd_state   : t_read_state;
  signal wdata      : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
  signal wstrb      : std_logic_vector(C_AXI_DATA_WIDTH/8-1 downto 0);
  signal rdata      : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
  signal mem_model  : memory(0 to C_MEMORY_SIZE);
  signal wr_address : unsigned(31 downto 0);
  signal rd_address : unsigned(31 downto 0);
  
begin

  -- axi-lite slave state machine
  axi_write_states : process (aclk, aresetn)
    variable i : integer;
    variable mem_addr : unsigned(31 downto 0);
  begin
    if aresetn = '0' then -- slave reset state
      wr_port_out.bvalid  <= '0';
      wr_port_out.awready <= '1';
      wr_port_out.wready  <= '1';
      wr_port_out.bresp   <= (others => '0');
      wr_state <= addr_wait;
      wr_address <= x"00000000";
    elsif rising_edge(aclk) then
      case wr_state is
        when addr_wait => 
          if ((wr_port_in.wvalid = '1') and
              (wr_port_in.awvalid = '1') ) then -- write
            -- are we writing immediately?
            --  check that address is in valid region (within memory model)   
            mem_addr := unsigned(wr_port_in.awaddr);
            -- shift by offset
            mem_addr := mem_addr - C_MEMORY_START;
            if (to_integer(mem_addr) > C_MEMORY_SIZE) then
              report "Axilite slave model got write address outside of allowed region - stopping"
                severity failure;
            end if;
            
            wr_port_out.wready  <= '0';
            wr_port_out.awready <= '0';
            wr_port_out.bvalid  <= '1';
            for i in 0 to (C_AXI_DATA_WIDTH/8)-1 loop
              if (wr_port_in.wstrb(i) = '1') then
                mem_model(to_integer(mem_addr)+i) <= wr_port_in.wdata((i+1)*8-1 downto i*8);
              end if;
            end loop;
            wr_state <= wr_wait_response;
            
          elsif (wr_port_in.wvalid = '1') then -- go to wait for awvalid state
            wdata <= wr_port_in.wdata;
            wstrb <= wr_port_in.wstrb;
            wr_port_out.wready  <= '0';
            wr_port_out.awready <= '1';
            wr_port_out.bvalid  <= '0';
            wr_state <= wr_wait_awvalid;
            
          elsif (wr_port_in.awvalid = '1') then -- go to write state
            wr_state <= wr_wait_valid;
            wr_port_out.wready  <= '1';
            wr_port_out.awready <= '0';
            wr_port_out.bvalid  <= '0';
            -- check that address is in valid region (within memory model)   
            mem_addr := unsigned(wr_port_in.awaddr);
            -- shift by offset
            mem_addr := mem_addr - C_MEMORY_START;
            if (to_integer(mem_addr) > C_MEMORY_SIZE) then
              report "Axilite slave model got write address outside of allowed region - stopping"
                severity failure;
            end if;
            wr_address <= mem_addr;
          else
            wr_state <= addr_wait;
            wr_port_out.bvalid  <= '0';
            wr_port_out.wready  <= '1';
            wr_port_out.awready <= '1';
          end if;

        when wr_wait_awvalid =>
          if (wr_port_in.awvalid = '1') then
            wr_port_out.awready <= '0';
            wr_port_out.bvalid  <= '1';
            -- check that address is in valid region (within memory model)   
            mem_addr := unsigned(wr_port_in.awaddr);
            -- shift by offset
            mem_addr := mem_addr - C_MEMORY_START;
            if (to_integer(mem_addr) > C_MEMORY_SIZE) then
              report "Axilite slave model got write address outside of allowed region - stopping"
                severity failure;
            end if;
            for i in 0 to (C_AXI_DATA_WIDTH/8)-1 loop
              if (wstrb(i) = '1') then
                mem_model(to_integer(mem_addr)+i) <= wdata((i+1)*8-1 downto i*8);
              end if;
            end loop;
            wr_state <= wr_wait_response;
          end if;
          
        when wr_wait_valid =>          
          if (wr_port_in.wvalid = '1') then
            wr_port_out.wready  <= '0';
            wr_port_out.bvalid  <= '1';
            for i in 0 to (C_AXI_DATA_WIDTH/8)-1 loop
              if (wr_port_in.wstrb(i) = '1') then
                mem_model(to_integer(wr_address)+i) <= wr_port_in.wdata((i+1)*8-1 downto i*8);
              end if;
            end loop;
            wr_state <= wr_wait_response;
          end if;

        when wr_wait_response =>
          if (wr_port_in.bready = '1') then
            wr_port_out.wready  <= '1';
            wr_port_out.awready <= '1';
            wr_port_out.bvalid  <= '0';
            wr_state <= addr_wait;
          end if;

      end case;

    end if;
  end process;


  axi_read_states : process (aclk, aresetn)
    variable i : integer;
    variable mem_addr : unsigned(31 downto 0);
  begin
    if aresetn = '0' then -- slave reset state
      rd_port_out.rvalid  <= '0';
      rd_port_out.arready <= '1';
      rd_port_out.rdata   <= (others => '0');
      rd_port_out.rresp   <= (others => '0');
      rd_state <= addr_wait;
      rd_address <= x"00000000";
    elsif rising_edge(aclk) then
      case rd_state is
        when addr_wait => 
          rd_port_out.arready <= '1';
          -- read going on ?
          -- immediate read
          if rd_port_in.arvalid = '1' then
            rd_port_out.rvalid <= '1';
            -- check that address is in valid region (within memory model)
            mem_addr := unsigned(rd_port_in.araddr);
            -- shift by offset
            mem_addr := mem_addr - C_MEMORY_START;
            if (to_integer(mem_addr) > C_MEMORY_SIZE) then
              report "Axilite slave model got read address outside of allowed region - stopping"
                severity failure;
            end if;
            for i in 0 to (C_AXI_DATA_WIDTH/8)-1 loop
              rd_port_out.rdata((i+1)*8-1 downto i*8) <= mem_model(to_integer(mem_addr)+i);
            end loop;
            if rd_port_in.rready = '0' then
              rd_state <= rd_wait_rdy;
            end if;
          else
            rd_port_out.rvalid  <= '0';
            rd_state <= addr_wait;
          end if;

        when rd_wait_rdy =>
          rd_port_out.arready <= '0';
          if (rd_port_in.rready = '1') then
            rd_port_out.rvalid <= '1';
            rd_port_out.arready <= '1';
            for i in 0 to (C_AXI_DATA_WIDTH/8)-1 loop
              rd_port_out.rdata((i+1)*8-1 downto i*8) <= mem_model(to_integer(rd_address)+i);
            end loop;
            rd_state <= addr_wait;
          end if;

      end case;

    end if;
  end process;
  
end behav;

