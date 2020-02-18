--================================================================================================================================
-- Copyright (c) 2019 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--================================================================================================================================

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

context vvc_context is
  library bitvis_vip_rgmii;
  use bitvis_vip_rgmii.transaction_pkg.all;
  use bitvis_vip_rgmii.vvc_methods_pkg.all;
  use bitvis_vip_rgmii.td_vvc_framework_common_methods_pkg.all;
  use bitvis_vip_rgmii.rgmii_bfm_pkg.t_rgmii_tx_if;
  use bitvis_vip_rgmii.rgmii_bfm_pkg.t_rgmii_rx_if;
  use bitvis_vip_rgmii.rgmii_bfm_pkg.t_rgmii_bfm_config;
  use bitvis_vip_rgmii.rgmii_bfm_pkg.C_RGMII_BFM_CONFIG_DEFAULT;
end context;
