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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package local_adaptations_pkg is

    -- Max length of line read from CSV file, used in csv_file_reader_pkg.vhd
    constant C_CSV_FILE_MAX_LINE_LENGTH     : positive := 256;
    -- Delimiter when reading and writing CSV files.
    constant C_CSV_DELIMITER                : character := ',';

    

   -------------------------------------------------------------------------------
    -- VIP configuration record
    -------------------------------------------------------------------------------
    type t_spec_cov_config is record
      missing_req_label_severity  : t_alert_level;  -- Alert level used when the log_req_cov() procedure does not find the specified
                                                    -- requirement label in the requirement list.
      csv_delimiter               : character;      -- Character used as delimiter in the CSV files. Default is ",".
      max_requirements            : natural;        -- Maximum number of requirements in the req_map file used in initialized_req_cov().
      max_testcases_per_req       : natural;        -- Max number of testcases allowed per requirement. 
      csv_max_line_length         : positive;       -- Max length of each line in any CSV file.
    end record;                                       


    constant C_SPEC_COV_CONFIG_DEFAULT : t_spec_cov_config := (
        missing_req_label_severity  => TB_WARNING,
        csv_delimiter               => C_CSV_DELIMITER,
        max_requirements            => 1000,
        max_testcases_per_req       => 20,
        csv_max_line_length         => 256
    );

    -- Shared variable for configuring the Spec Cov VIP from the testbench sequencer.
    shared variable shared_spec_cov_config  : t_spec_cov_config := C_SPEC_COV_CONFIG_DEFAULT;


end package local_adaptations_pkg;



package body local_adaptations_pkg is
end package body local_adaptations_pkg;