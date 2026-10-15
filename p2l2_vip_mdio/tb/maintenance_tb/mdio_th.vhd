--================================================================================================================================
-- Copyright 2026 UVVM
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

-- Include Verification IPs
library p2l2_vip_mdio;
use p2l2_vip_mdio.mdio_bfm_pkg.all;

--=================================================================================================
-- Test harness entity
-- No DUT: the VVCs (struct_vvc) or the BFM processes of the TB (struct_bfm) are connected to each other
-- through mdc and mdio. The bus is made of plain std_logic signals, so the TB can force them.
--=================================================================================================
entity mdio_th is
  generic(
    GC_STA_BFM_CONFIG : t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT;
    GC_PHY_BFM_CONFIG : t_mdio_bfm_config := C_MDIO_BFM_CONFIG_DEFAULT; -- phy.phy_address is set from GC_PHY_ADDRESSES
    -- One PHY VVC per element: instance 1 gets the first address, instance 2 the second, ...
    GC_PHY_ADDRESSES  : t_natural_array   := (1, 2, 3)
  );
  port(
    mdc  : inout std_logic;
    mdio : inout std_logic
  );
end entity mdio_th;

--=================================================================================================
-- Test harness architectures
--=================================================================================================
-- BFM TB: the processes of the TB drive the bus, the harness only adds the pull-up of MDIO
architecture struct_bfm of mdio_th is
begin

  mdio <= 'H';
  mdc  <= 'Z'; -- an inout port without a driver would contribute its default 'U' to the bus

end architecture struct_bfm;

-- VVC TB: one STA VVC (instance 0) and one PHY VVC per element of GC_PHY_ADDRESSES (instances 1, 2, ...).
-- The harness provides the pull-up of MDIO (GC_MDIO_PULLUP of the VVCs is false by default).
architecture struct_vvc of mdio_th is

  function phy_bfm_config(constant phy_address : natural) return t_mdio_bfm_config is
    variable v_config : t_mdio_bfm_config := GC_PHY_BFM_CONFIG;
  begin
    v_config.phy.phy_address := to_unsigned(phy_address, C_MDIO_PHY_ADDR_WIDTH);
    return v_config;
  end function phy_bfm_config;

begin

  mdio <= 'H';

  -----------------------------
  -- vvc/executors
  -----------------------------
  -- STA: drives MDC and the frames towards the PHYs
  i_sta_vvc : entity work.mdio_vvc
    generic map(
      GC_INSTANCE_IDX    => 0,
      GC_STA_MODE        => true,
      GC_MDIO_BFM_CONFIG => GC_STA_BFM_CONFIG
    )
    port map(
      mdio_vvc_if.mdc  => mdc,
      mdio_vvc_if.mdio => mdio
    );

  -- PHYs: answer the frames to their own address
  g_phy_vvc : for i in 1 to GC_PHY_ADDRESSES'length generate
    i_phy_vvc : entity work.mdio_vvc
      generic map(
        GC_INSTANCE_IDX    => i,
        GC_STA_MODE        => false,
        GC_MDIO_BFM_CONFIG => phy_bfm_config(GC_PHY_ADDRESSES(GC_PHY_ADDRESSES'low + i - 1))
      )
      port map(
        mdio_vvc_if.mdc  => mdc,
        mdio_vvc_if.mdio => mdio
      );
  end generate g_phy_vvc;

end architecture struct_vvc;
