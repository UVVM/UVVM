------------------------------------------------------------------------------
--
--     Purpose : AXI Slave model - a simple memory for write/read access
-- 
--      Author : Dag Sverre Skjelbreid <dss@bitvis.no>
--
-- Description :
--
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axi_slave_model_pkg is

  -- AXI-Lite  Configuration
  type t_axi_slave_model_cfg is record
    wr_resp_delay : natural;
    rd_resp_delay : natural;
  end record;

  -- need for a config at all? Might be better to put this in the model itself
  constant C_AXI_SLAVE_MODEL_CFG_DEFAULT : t_axi_slave_model_cfg := (
    wr_resp_delay => 0,
    rd_resp_delay => 0
  );
  signal axi_slave_model_cfg             : t_axi_slave_model_cfg := C_AXI_SLAVE_MODEL_CFG_DEFAULT;

  -- AXI-Lite Interface signals
  type t_axi_wr_slave_in_if is record
    -- Write Address Channel
    awid     : std_logic_vector;
    awaddr   : std_logic_vector;
    awlen    : std_logic_vector(7 downto 0);
    awsize   : std_logic_vector(2 downto 0);
    awburst  : std_logic_vector(1 downto 0);
    awlock   : std_logic;
    awcache  : std_logic_vector(3 downto 0);
    awprot   : std_logic_vector(2 downto 0);
    awqos    : std_logic_vector(3 downto 0);
    awregion : std_logic_vector(3 downto 0);
    awuser   : std_logic_vector;
    awvalid  : std_logic;
    -- Write Data Channel
    wdata    : std_logic_vector;
    wstrb    : std_logic_vector;
    wlast    : std_logic;
    wuser    : std_logic_vector;
    wvalid   : std_logic;
    -- Write Response Channel
    bready   : std_logic;
  end record;

  type t_axi_wr_slave_out_if is record
    -- Write Address Channel
    awready : std_logic;
    -- Write Data Channel
    wready  : std_logic;
    -- Write Response Channel
    bid     : std_logic_vector;
    bresp   : std_logic_vector(1 downto 0);
    buser   : std_logic_vector;
    bvalid  : std_logic;
  end record;

  type t_axi_rd_slave_in_if is record
    -- Read Address Channel
    arid     : std_logic_vector;
    araddr   : std_logic_vector;
    arlen    : std_logic_vector(7 downto 0);
    arsize   : std_logic_vector(2 downto 0);
    arburst  : std_logic_vector(1 downto 0);
    arlock   : std_logic;
    arcache  : std_logic_vector(3 downto 0);
    arprot   : std_logic_vector(2 downto 0);
    arqos    : std_logic_vector(3 downto 0);
    arregion : std_logic_vector(3 downto 0);
    aruser   : std_logic_vector;
    arvalid  : std_logic;
    -- Read Data Channel
    rready   : std_logic;
  end record;

  type t_axi_rd_slave_out_if is record
    -- Read Address Channel
    arready : std_logic;
    -- Read Data Channel
    rid     : std_logic_vector;
    rdata   : std_logic_vector;
    rresp   : std_logic_vector(1 downto 0);
    rlast   : std_logic;
    ruser   : std_logic_vector;
    rvalid  : std_logic;
  end record;

end package axi_slave_model_pkg;

package body axi_slave_model_pkg is
end package body axi_slave_model_pkg;
