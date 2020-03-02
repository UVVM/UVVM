#================================================================================================================================
# Copyright 2020 Bitvis
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------
# Call compile scripts from dependent libraries
#-----------------------------------------------------------------------
set root_path "../.."
do $root_path/script/compile_src.do $root_path/uvvm_util $root_path/uvvm_util/sim
do $root_path/script/compile_src.do $root_path/uvvm_vvc_framework $root_path/uvvm_vvc_framework/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_scoreboard $root_path/bitvis_vip_scoreboard/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_sbi $root_path/bitvis_vip_sbi/sim
do $root_path/script/compile_src.do $root_path/bitvis_uart $root_path/bitvis_uart/sim
