--================================================================================================================================
-- Copyright 2025 UVVM
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

context uvvm_all_context is
  library uvvm_context;
  context uvvm_context.uvvm_support_context;
  library uvvm_vvc_framework;
  context uvvm_vvc_framework.vvc_framework_context;
  library bitvis_vip_avalon_mm;
  context bitvis_vip_avalon_mm.vvc_context;
  library bitvis_vip_avalon_st;
  context bitvis_vip_avalon_st.vvc_context;
  library bitvis_vip_axi;
  context bitvis_vip_axi.vvc_context;
  library bitvis_vip_axilite;
  context bitvis_vip_axilite.vvc_context;
  library bitvis_vip_axistream;
  context bitvis_vip_axistream.vvc_context;
  library bitvis_vip_clock_generator;
  context bitvis_vip_clock_generator.vvc_context;
  library bitvis_vip_error_injection;
  use bitvis_vip_error_injection.error_injection_pkg.all;
  library bitvis_vip_ethernet;
  context bitvis_vip_ethernet.vvc_context;
  library bitvis_vip_gmii;
  context bitvis_vip_gmii.vvc_context;
  library bitvis_vip_gpio;
  context bitvis_vip_gpio.vvc_context;
  library bitvis_vip_hvvc_to_vvc_bridge;
  use bitvis_vip_hvvc_to_vvc_bridge.support_pkg.all;
  library bitvis_vip_i2c;
  context bitvis_vip_i2c.vvc_context;
  library bitvis_vip_rgmii;
  context bitvis_vip_rgmii.vvc_context;
  library bitvis_vip_sbi;
  context bitvis_vip_sbi.vvc_context;
  library bitvis_vip_spi;
  context bitvis_vip_spi.vvc_context;
  library bitvis_vip_uart;
  context bitvis_vip_uart.vvc_context;
  library bitvis_vip_wishbone;
  context bitvis_vip_wishbone.vvc_context;
end context;
