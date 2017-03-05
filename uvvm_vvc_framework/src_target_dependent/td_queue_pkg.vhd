--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

--===============================================================================================
-- td_cmd_queue_pkg
--  - Target dependent command queue package
--===============================================================================================

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_generic_queue_pkg;

use work.vvc_cmd_pkg.all;

package td_cmd_queue_pkg is new uvvm_vvc_framework.ti_generic_queue_pkg
  generic map (t_generic_element => t_vvc_cmd_record);
    
--===============================================================================================
-- td_result_queue_pkg
--  - Target dependent result queue package
--===============================================================================================
  
library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_generic_queue_pkg;

use work.vvc_cmd_pkg.all;

package td_result_queue_pkg is new uvvm_vvc_framework.ti_generic_queue_pkg
  generic map (t_generic_element => t_vvc_result_queue_element);
  
