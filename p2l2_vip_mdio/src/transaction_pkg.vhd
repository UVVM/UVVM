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

use work.mdio_bfm_pkg.all;

--==========================================================================================
--==========================================================================================
package transaction_pkg is

  --==========================================================================================
  -- t_operation
  -- - VVC and BFM operations
  --==========================================================================================
  type t_operation is (
    -- UVVM common
    NO_OPERATION,
    AWAIT_COMPLETION,
    AWAIT_ANY_COMPLETION,
    ENABLE_LOG_MSG,
    DISABLE_LOG_MSG,
    FLUSH_COMMAND_QUEUE,
    FETCH_RESULT,
    INSERT_DELAY,
    TERMINATE_CURRENT_COMMAND,
    -- VVC local
    PHY_C22_EXPECT_WRITE,
    PHY_C22_RECEIVE_WRITE,
    PHY_C22_REPLY_READ,
    PHY_C45_EXPECT_ADDRESS,
    PHY_C45_RECEIVE_ADDRESS,
    PHY_C45_EXPECT_WRITE,
    PHY_C45_RECEIVE_WRITE,
    PHY_C45_REPLY_READ,
    PHY_C45_REPLY_POST_READ_INCREMENT,
    -- STA (station / bus master) operations
    STA_C22_WRITE,
    STA_C22_READ,
    STA_C22_CHECK,
    STA_C45_ADDRESS,
    STA_C45_WRITE,
    STA_C45_READ,
    STA_C45_POST_READ_INCREMENT,
    STA_C45_CHECK,
    STA_C45_CHECK_POST_READ_INCREMENT,
    STA_C45_WRITE_REG,  -- address frame + write frame as one command
    STA_C45_READ_REG,   -- address frame + read frame as one command
    STA_C45_CHECK_REG   -- address frame + read frame + compare as one command
  );

  -- Operations the VVC executes as PHY (GC_STA_MODE = false) or as STA (GC_STA_MODE = true)
  function is_phy_operation(constant operation : t_operation) return boolean;
  function is_sta_operation(constant operation : t_operation) return boolean;
  -- STA operations that read a PHY register and store the data in the result queue (or the scoreboard)
  function is_sta_read_operation(constant operation : t_operation) return boolean;
  -- PHY operations that receive what the STA sends and store it in the result queue (or the scoreboard)
  function is_phy_receive_operation(constant operation : t_operation) return boolean;

  -- Fixed by the MDIO protocol (IEEE 802.3)
  constant C_VVC_CMD_PHY_ADDR_LENGTH : natural := C_MDIO_PHY_ADDR_WIDTH;     -- PHYAD / PRTAD
  constant C_VVC_CMD_DEV_ADDR_LENGTH : natural := C_MDIO_DEV_ADDR_WIDTH;     -- DEVAD
  constant C_VVC_CMD_REG_ADDR_LENGTH : natural := C_MDIO_REG_ADDR_WIDTH_C45; -- clause 45 register address, holds the clause 22 REGAD as well
  constant C_VVC_CMD_DATA_LENGTH     : natural := C_MDIO_DATA_WIDTH;

  -- Constants for the maximum sizes to use in this VVC. Can be modified in adaptations_pkg.
  alias C_VVC_CMD_STRING_MAX_LENGTH is C_MDIO_VVC_CMD_STRING_MAX_LENGTH;
  alias C_VVC_MAX_INSTANCE_NUM      is C_MDIO_VVC_MAX_INSTANCE_NUM;

  --==========================================================================================
  -- Transaction info types, constants and global signal
  --==========================================================================================

  -- VVC Meta
  type t_vvc_meta is record
    msg     : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    cmd_idx : integer;
  end record t_vvc_meta;

  constant C_VVC_META_DEFAULT : t_vvc_meta := (
    msg     => (others => ' '),
    cmd_idx => -1
  );

  -- NOTE:
  --   If compound transaction is needed see example usage in Bitvis VIP SBI.
  --   If sub transaction is needed see example usage in Bitvis VIP Avalon-MM.
  -- Base transaction
  type t_base_transaction is record
    operation           : t_operation;
    data                : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0); -- data written / expected / read
    dev_addr            : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0);     -- clause 45: target MMD within the PHY
    phy_addr            : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0);     -- STA: bus address of the target PHY (PHYAD / PRTAD)
    reg_addr            : unsigned(C_VVC_CMD_REG_ADDR_LENGTH-1 downto 0);     -- register address: REGAD (clause 22, zero-extended) or clause 45 register address
    vvc_meta            : t_vvc_meta;
    transaction_status  : t_transaction_status;
  end record t_base_transaction;

  constant C_BASE_TRANSACTION_SET_DEFAULT : t_base_transaction := (
    operation           => NO_OPERATION,
    data                => (others => '0'),
    dev_addr            => (others => '0'),
    phy_addr            => (others => '0'),
    reg_addr            => (others => '0'),
    vvc_meta            => C_VVC_META_DEFAULT,
    transaction_status  => INACTIVE
  );

  -- Transaction group
  type t_transaction_group is record
    bt : t_base_transaction;
  end record t_transaction_group;

  constant C_TRANSACTION_GROUP_DEFAULT : t_transaction_group := (
    bt => C_BASE_TRANSACTION_SET_DEFAULT
  );

  -- Global vvc_transaction_info trigger signal
  -- std_logic on purpose: the trigger is pulsed with UVVM's gen_pulse(), which has no std_ulogic overload
  type t_mdio_transaction_trigger_array is array (natural range <>) of std_logic;
  signal global_mdio_vvc_transaction_trigger : t_mdio_transaction_trigger_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => '0');

  -- Shared vvc_transaction_info info variable
  type t_mdio_transaction_group_array is array (natural range <>) of t_transaction_group;
  shared variable shared_mdio_vvc_transaction_info : t_mdio_transaction_group_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_TRANSACTION_GROUP_DEFAULT);

end package transaction_pkg;

package body transaction_pkg is

  function is_phy_operation(constant operation : t_operation) return boolean is
  begin
    case operation is
      when PHY_C22_EXPECT_WRITE | PHY_C22_RECEIVE_WRITE | PHY_C22_REPLY_READ |
           PHY_C45_EXPECT_ADDRESS | PHY_C45_RECEIVE_ADDRESS | PHY_C45_EXPECT_WRITE | PHY_C45_RECEIVE_WRITE |
           PHY_C45_REPLY_READ | PHY_C45_REPLY_POST_READ_INCREMENT =>
        return true;
      when others =>
        return false;
    end case;
  end function is_phy_operation;

  function is_sta_operation(constant operation : t_operation) return boolean is
  begin
    case operation is
      when STA_C22_WRITE | STA_C22_READ | STA_C22_CHECK |
           STA_C45_ADDRESS | STA_C45_WRITE | STA_C45_READ | STA_C45_POST_READ_INCREMENT | STA_C45_CHECK | STA_C45_CHECK_POST_READ_INCREMENT |
           STA_C45_WRITE_REG | STA_C45_READ_REG | STA_C45_CHECK_REG =>
        return true;
      when others =>
        return false;
    end case;
  end function is_sta_operation;

  function is_sta_read_operation(constant operation : t_operation) return boolean is
  begin
    case operation is
      when STA_C22_READ | STA_C45_READ | STA_C45_POST_READ_INCREMENT | STA_C45_READ_REG =>
        return true;
      when others =>
        return false;
    end case;
  end function is_sta_read_operation;

  function is_phy_receive_operation(constant operation : t_operation) return boolean is
  begin
    case operation is
      when PHY_C22_RECEIVE_WRITE | PHY_C45_RECEIVE_ADDRESS | PHY_C45_RECEIVE_WRITE =>
        return true;
      when others =>
        return false;
    end case;
  end function is_phy_receive_operation;

end package body transaction_pkg;
