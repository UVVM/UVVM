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

package axilite_slave_model_pkg is

  -- AXI-Lite  Configuration
  type t_axilite_slave_model_cfg is record
    wr_resp_delay : natural;
    rd_resp_delay : natural;
  end record;

  -- need for a config at all? Might be better to put this in the model itself
  constant C_AXILITE_SLAVE_MODEL_CFG_DEFAULT : t_axilite_slave_model_cfg := (
    wr_resp_delay => 0,
    rd_resp_delay => 0
  );
  signal axilite_slave_model_cfg             : t_axilite_slave_model_cfg := C_AXILITE_SLAVE_MODEL_CFG_DEFAULT;

  -- AXI-Lite Interface signals
  type t_axilite_wr_slave_in_if is record
    -- Write Address Channel
    awaddr  : std_logic_vector;
    awvalid : std_logic;
    -- Write Data Channel
    wdata   : std_logic_vector;
    wstrb   : std_logic_vector;
    wvalid  : std_logic;
    -- Write Response Channel
    bready  : std_logic;
  end record;

  type t_axilite_wr_slave_out_if is record
    -- Write Address Channel
    awready : std_logic;
    -- Write Data Channel
    wready  : std_logic;
    -- Write Response Channel
    bresp   : std_logic_vector(1 downto 0);
    bvalid  : std_logic;
  end record;

  type t_axilite_rd_slave_in_if is record
    -- Read Address Channel
    araddr  : std_logic_vector;
    arvalid : std_logic;
    -- Read Data Channel
    rready  : std_logic;
  end record;

  type t_axilite_rd_slave_out_if is record
    -- Read Address Channel
    arready : std_logic;
    -- Read Data Channel
    rdata   : std_logic_vector;
    rresp   : std_logic_vector(1 downto 0);
    rvalid  : std_logic;
  end record;

end package axilite_slave_model_pkg;

package body axilite_slave_model_pkg is
end package body axilite_slave_model_pkg;
