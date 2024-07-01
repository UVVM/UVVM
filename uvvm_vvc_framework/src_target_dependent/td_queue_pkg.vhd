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

--===============================================================================================
-- td_cmd_queue_pkg
--  - Target dependent command queue package
--===============================================================================================

library uvvm_util;
use uvvm_util.generic_queue_pkg;

use work.vvc_cmd_pkg.all;

package td_cmd_queue_pkg is new uvvm_util.generic_queue_pkg
  generic map(t_generic_element => t_vvc_cmd_record);

--===============================================================================================
-- td_result_queue_pkg
--  - Target dependent result queue package
--===============================================================================================

library uvvm_util;
use uvvm_util.generic_queue_pkg;

use work.vvc_cmd_pkg.all;

package td_result_queue_pkg is new uvvm_util.generic_queue_pkg
  generic map(t_generic_element => t_vvc_result_queue_element);

