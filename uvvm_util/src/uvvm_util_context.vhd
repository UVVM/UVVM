--================================================================================================================================
-- Copyright 2024 UVVM
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

context uvvm_util_context is
  library uvvm_util;
  use uvvm_util.types_pkg.all;
  use uvvm_util.global_signals_and_shared_variables_pkg.all;
  use uvvm_util.hierarchy_linked_list_pkg.all;
  use uvvm_util.string_methods_pkg.all;
  use uvvm_util.adaptations_pkg.all;
  use uvvm_util.methods_pkg.all;
  use uvvm_util.bfm_common_pkg.all;
  use uvvm_util.alert_hierarchy_pkg.all;
  use uvvm_util.license_pkg.all;
  use uvvm_util.protected_types_pkg.all;
  use uvvm_util.vendor_rand_extension_pkg.all;
  use uvvm_util.rand_pkg.all;
  use uvvm_util.func_cov_pkg.all;
end context;
