--================================================================================================================================
-- Copyright 2020 Bitvis
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package local_adaptations_pkg is

  -- Max length of line read from CSV file, used in csv_file_reader_pkg.vhd
  constant C_CSV_FILE_MAX_LINE_LENGTH : positive  := 256;
  -- Delimiter when reading and writing CSV files.
  constant C_CSV_DELIMITER            : character := ',';

  -------------------------------------------------------------------------------
  -- VIP configuration record
  -------------------------------------------------------------------------------
  type t_spec_cov_config is record
    missing_req_label_severity : t_alert_level; -- Alert level used when the tick_off_req_cov() procedure does not find the specified
                                                -- requirement label in the requirement list.
    csv_delimiter              : character; -- Character used as delimiter in the CSV files. Default is ",".
    max_requirements           : natural; -- Maximum number of requirements in the req_map file used in initialize_req_cov().
    max_testcases_per_req      : natural; -- Max number of testcases allowed per requirement. 
    csv_max_line_length        : positive; -- Max length of each line in any CSV file.
  end record;

  constant C_SPEC_COV_CONFIG_DEFAULT : t_spec_cov_config := (
    missing_req_label_severity => TB_WARNING,
    csv_delimiter              => C_CSV_DELIMITER,
    max_requirements           => 1000,
    max_testcases_per_req      => 20,
    csv_max_line_length        => C_CSV_FILE_MAX_LINE_LENGTH
  );

  -- Shared variable for configuring the Spec Cov VIP from the testbench sequencer.
  shared variable shared_spec_cov_config : t_spec_cov_config := C_SPEC_COV_CONFIG_DEFAULT;

end package local_adaptations_pkg;

package body local_adaptations_pkg is
end package body local_adaptations_pkg;
