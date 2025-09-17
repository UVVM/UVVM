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

context uvvm_support_context is
  library uvvm_util;
  context uvvm_util.uvvm_util_context;
  library bitvis_vip_scoreboard;
  use bitvis_vip_scoreboard.generic_sb_support_pkg.all;
  library bitvis_vip_spec_cov;
  context bitvis_vip_spec_cov.spec_cov_context;
  library uvvm_assertions;
  use uvvm_assertions.uvvm_assertions_pkg.all;
end context;
