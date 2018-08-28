--========================================================================================================================
-- Copyright (c) 2016 by Bitvis AS.  All rights reserved.
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
-- 
-- Note : This is a simplified Avalon MM BFM.
--        - Burst read/write is not supported
--        - debugaccess is not supported
--        - Pipelined read/write not supported
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================

package avalon_mm_bfm_pkg is

  ----------------------------------------------------
  -- Types for Avalon BFM
  ----------------------------------------------------
  constant C_SCOPE : string := "AVALON MM BFM";

  -- Avalon Interface signals    
  type t_avalon_mm_if is record
    -- Avalon MM BFM to DUT signals
    reset             : std_logic;
    reset_n           : std_logic;
    address           : std_logic_vector;
    byte_enable       : std_logic_vector;
    chipselect        : std_logic;
    write             : std_logic;
    writedata         : std_logic_vector;
    read              : std_logic;
    
    -- Avalon MM DUT to BFM signals
    readdata          : std_logic_vector;
    response          : std_logic_vector(1 downto 0); -- Set use_response_signal to false if not in use
    waitrequest       : std_logic;
    readdatavalid     : std_logic;  -- might be used, might not.. If not used, fixed latency is a given 
                                    -- (same for read and write), unless waitrequest is used.
    irq               : std_logic;
  end record;

  
  -- Configuration record to be assigned in the test harness.
  type t_avalon_mm_bfm_config is
  record
    max_wait_cycles          : natural;         -- when using waitrequest - max time to wait
    max_wait_cycles_severity : t_alert_level;
    clock_period             : time;
    num_wait_states          : natural;         -- use_waitrequest = false -> this controls the (fixed) latency
    use_waitrequest          : boolean;         -- slave uses waitrequest
    use_readdatavalid        : boolean;         -- slave uses readdatavalid (variable latency)
    use_response_signal      : boolean;         -- Whether or not to check the response signal on read
    id_for_bfm               : t_msg_id;
    id_for_bfm_wait          : t_msg_id;
    id_for_bfm_poll          : t_msg_id;
  end record;

  constant C_AVALON_MM_BFM_CONFIG_DEFAULT : t_avalon_mm_bfm_config := (
    max_wait_cycles          => 10,
    max_wait_cycles_severity => TB_FAILURE,
    clock_period             => 10 ns,
    num_wait_states          => 0,
    use_waitrequest          => true,
    use_readdatavalid        => false,
    use_response_signal      => true,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL
    );
    
    type t_avalon_mm_response_status is (OKAY, RESERVED, SLAVEERROR, DECODEERROR);

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  function init_avalon_mm_if_signals(
    addr_width : natural;
    data_width : natural
    ) return t_avalon_mm_if;
  
  -- This procedure could be called from an a simple testbench or
  -- from an executor where there are concurrent BFMs - where
  -- all BFMs could have different configs and msg_id_panels
  -- From a simple testbench, just don't touch the defaults for
  -- the fields that are not needed. e.g.:
  -- avalon_mm_write(my_avalon_mm_if, addr, data);
  
  -- avalon_mm_write overload without byte_enable
  procedure avalon_mm_write (
    constant addr_value       : in  unsigned;
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;    
    signal avalon_mm_if       : inout t_avalon_mm_if;   
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );
  
  -- avalon_mm_write with byte_enable
  procedure avalon_mm_write (
    constant addr_value       : in  unsigned;
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant byte_enable      : in  std_logic_vector;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );
    
  procedure avalon_mm_read (
    constant addr_value       : in  unsigned;
    variable data_value       : out std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name        : in  string                    := "avalon_mm_read"  -- overwrite if called from other procedure like avalon_mm_check
    );

  procedure avalon_mm_check (
    constant addr_value       : in  unsigned;
    constant data_exp         : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant alert_level      : in  t_alert_level             := error;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );

  procedure avalon_mm_reset (
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant num_rst_cycles   : in  integer;
    constant msg              : in  string;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );

end package avalon_mm_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body avalon_mm_bfm_pkg is

  function init_avalon_mm_if_signals(
    addr_width : natural;
    data_width : natural
    ) return t_avalon_mm_if is
    variable result : t_avalon_mm_if(address(addr_width - 1 downto 0), 
                                         byte_enable((data_width/8) - 1 downto 0),
                                         writedata(data_width - 1 downto 0),
                                         readdata(data_width-1 downto 0));
  begin
    -- BFM to DUT signals
    result.reset            := '0';
    result.address          := (others => '0');
    result.byte_enable      := (others => '1');
    result.chipselect       := '0';
    result.write            := '0';
    result.writedata        := (others => '0');
    result.read             := '0';
    -- DUT to BFM signals
    result.readdata         := (others => 'Z');
    result.response         := (others => 'Z');
    result.waitrequest      := 'Z';
    result.readdatavalid    := 'Z';
    result.irq              := 'Z';

    return result;
  end function;
  
  
  function to_string(
    constant avalon_mm_response_status  : in t_avalon_mm_response_status
  ) return string is 
  begin 
    return to_upper(t_avalon_mm_response_status'image(avalon_mm_response_status));
  end function;
  
  
  function to_avalon_mm_response_status(
    constant response       : in std_logic_vector(1 downto 0);
    constant scope          : in  string           := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel   := shared_msg_id_panel
  ) return t_avalon_mm_response_status is
  begin
    case response is
      when "00" =>
        return OKAY;
      when "10" =>
        return RESERVED;
      when "11" => 
        return SLAVEERROR;
      when others =>
        return DECODEERROR;
    end case;
  end function;
    
    
  -- avalon_mm_write overload without byte_enable
  procedure avalon_mm_write (
    constant addr_value       : in  unsigned;
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "avalon_mm_write";
    constant proc_call : string := "avalon_mm_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(avalon_mm_if.address'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(addr_value), avalon_mm_if.address, ALLOW_NARROWER, "address", "avalon_mm_if.address", msg);
    variable v_normalized_data : std_logic_vector(avalon_mm_if.writedata'length-1 downto 0) :=
      normalize_and_check(data_value, avalon_mm_if.writedata, ALLOW_NARROWER, "data", "avalon_mm_if.writedata", msg);
    
    variable v_byte_enable : std_logic_vector((avalon_mm_if.writedata'length/8) - 1 downto 0) := (others => '1');
    
    variable timeout : boolean := false;
    
  begin
    avalon_mm_write(addr_value, data_value, msg, clk, avalon_mm_if, v_byte_enable, scope, msg_id_panel, config);
  end procedure;
   
   
  procedure avalon_mm_write (
    constant addr_value       : in  unsigned;
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant byte_enable      : in  std_logic_vector;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is    
    constant proc_name : string := "avalon_mm_write";
    constant proc_call : string := "avalon_mm_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(avalon_mm_if.address'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(addr_value), avalon_mm_if.address, ALLOW_NARROWER, "address", "avalon_mm_if.address", msg);
    variable v_normalized_data : std_logic_vector(avalon_mm_if.writedata'length-1 downto 0) :=
      normalize_and_check(data_value, avalon_mm_if.writedata, ALLOW_NARROWER, "data", "avalon_mm_if.writedata", msg);
    
    variable timeout : boolean := false;
  begin
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);

    avalon_mm_if.writedata    <= v_normalized_data;
    avalon_mm_if.byte_enable  <= byte_enable;
    avalon_mm_if.write        <= '1';
    avalon_mm_if.chipselect   <= '1';
    avalon_mm_if.address      <= v_normalized_addr;

    -- use wait request?
    if config.use_waitrequest then
      wait until falling_edge(clk);     -- wait for DUT update of signal
      for cycle in 1 to config.max_wait_cycles loop
        if avalon_mm_if.waitrequest = '1' then
          wait until falling_edge(clk);
        else
          exit;
        end if;
        if cycle = config.max_wait_cycles then
          timeout := true;
        end if;
      end loop;

      -- did we timeout?
      if timeout then
        alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for waitrequest " & add_msg_delimiter(msg), scope);
      else
        wait until rising_edge(clk);
        wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
      end if;
      
    else  -- not waitrequest. num_wait_states will be used as number of wait cycles in fixed wait-states
      for cycle in 0 to config.num_wait_states loop
        wait until rising_edge(clk);
        wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
      end loop;
    end if;
    
    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length);
    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
    
  end procedure avalon_mm_write;
  
  
  function is_readdatavalid_active(
    signal avalon_mm_if       : in t_avalon_mm_if;
    constant config           : in t_avalon_mm_bfm_config
  ) return boolean is 
  begin
    if (config.use_readdatavalid and avalon_mm_if.readdatavalid = '1') then
      return true;
    end if;
    return false;
  end function is_readdatavalid_active;
  
  function is_waitrequest_active(
    signal avalon_mm_if       : in t_avalon_mm_if;
    constant config           : in t_avalon_mm_bfm_config
  ) return boolean is 
  begin
    if (config.use_waitrequest and avalon_mm_if.waitrequest = '1') then
      return true;
    end if;
    return false;
  end function is_waitrequest_active;
  
  
  procedure avalon_mm_read (
    constant addr_value       : in  unsigned;
    variable data_value       : out std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name        : in  string                    := "avalon_mm_read"  -- overwrite if called from other procedure like avalon_mm_check
    ) is  
    constant proc_call : string := "avalon_mm_read(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";
    type t_read_signal_state is (READ_ACTIVE, TO_BE_DEACTIVATED, READ_DEACTIVATED);
    variable v_read_signal_state : t_read_signal_state := READ_ACTIVE;

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(avalon_mm_if.address'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(addr_value), avalon_mm_if.address, ALLOW_NARROWER, "addr", "avalon_mm_if.address", msg);
    variable v_normalized_data : std_logic_vector(avalon_mm_if.readdata'length-1 downto 0) :=
      normalize_and_check(data_value, avalon_mm_if.readdata, ALLOW_NARROWER, "data", "avalon_mm_if.readdata", msg);

    -- Helper variables
    variable timeout : boolean := false;
  begin
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    -- start the read
    avalon_mm_if.address <= v_normalized_addr;
    avalon_mm_if.read        <= '1';
    avalon_mm_if.byte_enable(avalon_mm_if.byte_enable'length - 1 downto 0) <= (others => '1');  -- always all bytes for reads
    v_read_signal_state := READ_ACTIVE;
    avalon_mm_if.chipselect <= '1';

    wait until falling_edge(clk);       -- wait for DUT update of signal
    
    -- Handle read with readdatavalid.
    if config.use_readdatavalid then
      for cycle in 1 to config.max_wait_cycles loop
        
        if v_read_signal_state = READ_ACTIVE then 
          if config.use_waitrequest and (not is_waitrequest_active(avalon_mm_if, config)) then
            v_read_signal_state := TO_BE_DEACTIVATED;
          end if;
        end if;
        
        -- Check for readdatavalid, and set read inactive if waitrequest is set inactive
        if is_readdatavalid_active(avalon_mm_if, config) then
          exit;
        elsif v_read_signal_state = TO_BE_DEACTIVATED then
           -- Reset the avalon read signals if waitrequest is in use but inactive
          wait until rising_edge(clk);
          wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
          avalon_mm_if.read         <= '0';
          v_read_signal_state := READ_DEACTIVATED;
          wait until falling_edge(clk);
        else
          wait until falling_edge(clk);
        end if;
        
        if cycle = config.max_wait_cycles then
          timeout := true;
        end if;
      end loop;

      -- did we timeout?
      if timeout then
        alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for readdatavalid " & add_msg_delimiter(msg), scope);
      else
        wait until rising_edge(clk);
        wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
      end if;
    
    -- Handle read with waitrequests
    elsif config.use_waitrequest then
      for cycle in 1 to config.max_wait_cycles loop
        if is_waitrequest_active(avalon_mm_if, config) then
          wait until falling_edge(clk);
        else
          exit;
        end if;
        if cycle = config.max_wait_cycles then
          timeout := true;
        end if;
      end loop;

      -- did we timeout?
      if timeout then
        alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for waitrequest " & add_msg_delimiter(msg), scope);
      else
        wait until rising_edge(clk);
        wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
      end if;

    else  -- not waitrequest or readdatavalid - issue read, wait num_wait_states before finishing the read
      for cycle in 0 to config.num_wait_states loop
        wait until rising_edge(clk);
        wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
      end loop;
    end if;
    
    if config.use_response_signal = true and to_avalon_mm_response_status(avalon_mm_if.response) /= OKAY then
      error("Avalon MM read response was nok OKAY, got " & to_string(avalon_mm_if.response), scope);
    end if;
    
    v_normalized_data := avalon_mm_if.readdata;
    data_value        := v_normalized_data(data_value'length-1 downto 0);

    if proc_name = "avalon_mm_read" then
      log(config.id_for_bfm, proc_call & "=> " & to_string(data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else

    end if;
    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length);
  end procedure avalon_mm_read;
  
  
  procedure avalon_mm_check (
    constant addr_value       : in  unsigned;
    constant data_exp         : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant alert_level      : in  t_alert_level             := error;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "avalon_mm_check";
    constant proc_call : string := "avalon_mm_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(avalon_mm_if.readdata'length-1 downto 0) :=
      normalize_and_check(data_exp, avalon_mm_if.readdata, ALLOW_NARROWER, "data", "avalon_mm_if.readdata", msg);

    -- Helper variables
    variable v_data_value : std_logic_vector(avalon_mm_if.readdata'length-1 downto 0) := (others => '0');
    variable v_check_ok   : boolean;
  begin
    avalon_mm_read(addr_value, v_data_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_name);

    v_check_ok := true;
    for i in 0 to (v_normalized_data'length)-1 loop
      if v_normalized_data(i) = '-' or v_normalized_data(i) = v_data_value(i) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      alert(alert_level, proc_call & "=> Failed. slv Was " & to_string(v_data_value, HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & "." & LF & msg, scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure avalon_mm_check;
  
  
  procedure avalon_mm_reset (
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant num_rst_cycles   : in  integer;
    constant msg              : in  string;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is 
    constant proc_call : string := "avalon_mm_reset(num_rst_cycles=" & to_string(num_rst_cycles) & ")";
  begin
    log(config.id_for_bfm, proc_call & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length);
    avalon_mm_if.reset <= '1';
    for i in 1 to num_rst_cycles loop
      wait until rising_edge(clk);
    end loop;

    avalon_mm_if.reset <= '0';

    wait until rising_edge(clk);
  end procedure avalon_mm_reset;

end package body avalon_mm_bfm_pkg;

