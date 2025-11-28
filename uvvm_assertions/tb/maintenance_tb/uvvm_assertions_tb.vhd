library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_assertions;
use uvvm_assertions.uvvm_assertions_pkg.all;

--hdlregression:tb
entity uvvm_assertions_tb is
  generic(
      GC_TESTCASE : string := "UVVM"
    );
end entity uvvm_assertions_tb;

architecture func of uvvm_assertions_tb is

  -- Constants
  constant C_CLK_PERIOD  : time    := 10 ns;
  constant C_MAX_NUM_CKS : integer := 100;

  -- Type declarations
  type t_sequence is array (0 to 3) of std_logic_vector(3 downto 0);
  type t_clock_mode is (CLOCKED, NON_CLOCKED);
  type t_out_of_range is (ABOVE, BELOW);
  type t_select_ena is (SLV_OVERLOAD_ENA, SL_OVERLOAD_ENA);

  signal clk                            : std_logic                            := '0';
  signal clk_ena                        : boolean                              := false;                       -- Enable signal for the clock process

  signal ena                            : std_logic                            := '0';                         -- Enable signal
  signal bool_ena                       : std_logic                            := '0';                         -- Enable signal for assertions overloads (boolean)
  signal slv_ena                        : std_logic                            := '0';                         -- Enable signal for assertions overloads (std_logic_vector)
  signal sl_ena                         : std_logic                            := '0';                         -- Enable signal for assertions overloads (std_logic)
  signal slv_array_ena                  : std_logic                            := '0';                         -- Enable signal for assertions overloads (t_slv_array)
  signal unsigned_array_ena             : std_logic                            := '0';                         -- Enable signal for assertions overloads (t_unsigned_array)
  signal signed_array_ena               : std_logic                            := '0';                         -- Enable signal for assertions overloads (t_signed_array)
  signal unsigned_ena                   : std_logic                            := '0';                         -- Enable signal for assertions overloads (unsigned)
  signal signed_ena                     : std_logic                            := '0';                         -- Enable signal for assertions overloads (signed)
  signal int_ena                        : std_logic                            := '0';                         -- Enable signal for assertions overloads (integer)
  signal real_ena                       : std_logic                            := '0';                         -- Enable signal for assertions overloads (real)
  signal time_ena                       : std_logic                            := '0';                         -- Enable signal for assertions overloads (time)

  signal bool_non_clocked_ena           : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (boolean)
  signal slv_non_clocked_ena            : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (std_logic_vector)
  signal sl_non_clocked_ena             : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (std_logic)
  signal slv_array_non_clocked_ena      : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (t_slv_array)
  signal unsigned_array_non_clocked_ena : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (t_unsigned_array)
  signal signed_array_non_clocked_ena   : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (t_signed_array)
  signal unsigned_non_clocked_ena       : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (unsigned)
  signal signed_non_clocked_ena         : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (signed)
  signal int_non_clocked_ena            : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (integer)
  signal real_non_clocked_ena           : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (real)
  signal time_non_clocked_ena           : std_logic                            := '0';                         -- Enable signal for non-clocked assertions overloads (time)

  signal tracked_value_bool             : boolean                              := false;                       -- Test expression value (boolean)
  signal tracked_value_slv              : std_logic_vector(3 downto 0)         := (others => '0');             -- Test expression value (std_logic_vector)
  signal tracked_value_sl               : std_logic                            := '0';                         -- Test expression value (std_logic)
  signal tracked_value_slv_array        : t_slv_array(0 to 1)(3 downto 0)      := (others => (others => '0')); -- Test expression value (t_slv_array)
  signal tracked_value_unsigned_array   : t_unsigned_array(0 to 1)(3 downto 0) := (others => (others => '0')); -- Test expression value (t_unsigned_array)
  signal tracked_value_signed_array     : t_signed_array(0 to 1)(3 downto 0)   := (others => (others => '0')); -- Test expression value (t_signed_array)
  signal tracked_value_unsigned         : unsigned(3 downto 0)                 := (others => '0');             -- Test expression value (unsigned)
  signal tracked_value_signed           : signed(3 downto 0)                   := (others => '0');             -- Test expression value (signed)
  signal tracked_value_int              : integer                              := 0;                           -- Test expression value (integer)
  signal tracked_value_real             : real                                 := 0.0;                         -- Test expression value (real)
  signal tracked_value_time             : time                                 := 0 ns;                        -- Test expression value (time)

  signal exp_value_bool                 : boolean                              := false;                       -- Expected value for the tracked_value (boolean)
  signal exp_value_slv                  : std_logic_vector(3 downto 0)         := (others => '0');             -- Expected value for the tracked_value (std_logic_vector)
  signal exp_value_sl                   : std_logic                            := '0';                         -- Expected value for the tracked_value (std_logic)
  signal exp_value_slv_array            : t_slv_array(0 to 1)(3 downto 0)      := (others => (others => '0')); -- Expected value for the tracked_value (t_slv_array)
  signal exp_value_unsigned_array       : t_unsigned_array(0 to 1)(3 downto 0) := (others => (others => '0')); -- Expected value for the tracked_value (t_unsigned_array)
  signal exp_value_signed_array         : t_signed_array(0 to 1)(3 downto 0)   := (others => (others => '0')); -- Expected value for the tracked_value (t_signed_array)
  signal exp_value_unsigned             : unsigned(3 downto 0)                 := (others => '0');             -- Expected value for the tracked_value (unsigned)
  signal exp_value_signed               : signed(3 downto 0)                   := (others => '0');             -- Expected value for the tracked_value (signed)
  signal exp_value_int                  : integer                              := 0;                           -- Expected value for the tracked_value (integer)
  signal exp_value_real                 : real                                 := 0.0;                         -- Expected value for the tracked_value (real)
  signal exp_value_time                 : time                                 := 0 ns;                        -- Expected value for the tracked_value (time)

  signal allowed_values_slv             : std_logic_vector(1 downto 0)         := (others => '0');             -- Set of allowed values in assert_one_of (std_logic)
  signal allowed_values_slv_array       : t_slv_array(0 to 1)(3 downto 0)      := (others => (others => '0')); -- Set of allowed values in assert_one_of (std_logic_vector)
  signal allowed_values_unsigned_array  : t_unsigned_array(0 to 1)(3 downto 0) := (others => (others => '0')); -- Set of allowed values in assert_one_of (unsigned)
  signal allowed_values_signed_array    : t_signed_array(0 to 1)(3 downto 0)   := (others => (others => '0')); -- Set of allowed values in assert_one_of (signed)
  signal allowed_values_int_array       : t_integer_array(0 to 1)              := (0, 0);                      -- Set of allowed values in assert_one_of (integer)
  signal allowed_values_real_array      : real_vector(0 to 1)                  := (0.0, 0.0);                  -- Set of allowed values in assert_one_of (real)
  signal allowed_values_time_array      : time_vector(0 to 1)                  := (0 ns, 0 ns);                -- Set of allowed values in assert_one_of (time)

  signal accept_all_zeros               : t_accept_all_zeros                   := ALL_ZERO_NOT_ALLOWED;        -- Enable signal that allows accepting all zeros in assert_one_hot

  signal lower_limit_unsigned           : unsigned(3 downto 0)                 := (others => '0');             -- Lower bound (inclusive) for assert_value_in_range (unsigned)
  signal upper_limit_unsigned           : unsigned(3 downto 0)                 := (others => '0');             -- Upper bound (inclusive) for assert_value_in_range (unsigned)
  signal lower_limit_signed             : signed(3 downto 0)                   := (others => '0');             -- Lower bound (inclusive) for assert_value_in_range (signed)
  signal upper_limit_signed             : signed(3 downto 0)                   := (others => '0');             -- Upper bound (inclusive) for assert_value_in_range (signed)
  signal lower_limit_int                : integer                              := 0;                           -- Lower bound (inclusive) for assert_value_in_range (integer)
  signal upper_limit_int                : integer                              := 0;                           -- Upper bound (inclusive) for assert_value_in_range (integer)
  signal lower_limit_real               : real                                 := 0.0;                         -- Lower bound (inclusive) for assert_value_in_range (real)
  signal upper_limit_real               : real                                 := 0.0;                         -- Upper bound (inclusive) for assert_value_in_range (real)
  signal lower_limit_time               : time                                 := 0 ns;                        -- Lower bound (inclusive) for assert_value_in_range (time)
  signal upper_limit_time               : time                                 := 0 ns;                        -- Upper bound (inclusive) for assert_value_in_range (time)

  signal necessary_condition            : t_shift_one_ness_cond                := ANY_BIT_ALERT;               -- assert_shift_one_from_left necessary_condition

  signal trigger                        : std_logic                            := '0';                         -- Start event signal for the cycle bound window assertions

  signal min_cycles                     : integer range 0 to C_MAX_NUM_CKS     := 0;                           -- Lower bound (inclusive) for the cycle bound window assertions
  signal max_cycles                     : integer range 0 to C_MAX_NUM_CKS     := 0;                           -- Upper bound (inclusive) for the cycle bound window assertions

  signal start_trigger                  : std_logic                            := '0';                         -- Start event signal for the end-trigger bound window assertions
  signal end_trigger                    : std_logic                            := '0';                         -- End event signal for the end-trigger bound window assertions

  signal alert_level                    : t_alert_level                        := TB_ERROR;                    -- Sets the severity level for the alert

  signal pos_ack_kind                   : t_pos_ack_kind                       := FIRST;                       -- Sets how often the pos_ack should be issued

begin

  --------------------------------------------------------------------------------
  -- Clock Generator
  --------------------------------------------------------------------------------
  clock_generator(clk, clk_ena, C_CLK_PERIOD, "system_clock");

  --------------------------------------------------------------------------------
  -- Procedure Call for UVVM Assertions
  --------------------------------------------------------------------------------
  -------------------------------------
  -- #region assert_value
  -------------------------------------
  -- boolean
  g_value_bool : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => bool_ena,
      tracked_value       => tracked_value_bool,
      exp_value           => exp_value_bool,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_bool;

  -- boolean non-clocked
  g_value_bool_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => bool_non_clocked_ena,
      tracked_value       => tracked_value_bool,
      exp_value           => exp_value_bool,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_bool_non_clocked;

  -- std_logic_vector
  g_value_slv : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      exp_value           => exp_value_slv,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_slv;

  -- std_logic_vector non-clocked
  g_value_slv_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => slv_non_clocked_ena,
      tracked_value       => tracked_value_slv,
      exp_value           => exp_value_slv,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_slv_non_clocked;

  -- std_logic
  g_value_sl : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      exp_value           => exp_value_sl,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_sl;

  -- std_logic non-clocked
  g_value_sl_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => sl_non_clocked_ena,
      tracked_value       => tracked_value_sl,
      exp_value           => exp_value_sl,
      alert_level         => alert_level,
      msg                 => "",
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_sl_non_clocked;

  -- t_slv_array
  g_value_slv_array : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => slv_array_ena,
      tracked_value       => tracked_value_slv_array,
      exp_value           => exp_value_slv_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_slv_array;

  -- t_slv_array non-clocked
  g_value_slv_array_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => slv_array_non_clocked_ena,
      tracked_value       => tracked_value_slv_array,
      exp_value           => exp_value_slv_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_slv_array_non_clocked;

  -- t_unsigned_array
  g_value_unsigned_array : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => unsigned_array_ena,
      tracked_value       => tracked_value_unsigned_array,
      exp_value           => exp_value_unsigned_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_unsigned_array;

  -- t_unsigned_array non-clocked
  g_value_unsigned_array_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => unsigned_array_non_clocked_ena,
      tracked_value       => tracked_value_unsigned_array,
      exp_value           => exp_value_unsigned_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_unsigned_array_non_clocked;

  -- t_signed_array
  g_value_signed_array : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => signed_array_ena,
      tracked_value       => tracked_value_signed_array,
      exp_value           => exp_value_signed_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_signed_array;

  -- t_signed_array non-clocked
  g_value_signed_array_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => signed_array_non_clocked_ena,
      tracked_value       => tracked_value_signed_array,
      exp_value           => exp_value_signed_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_signed_array_non_clocked;

  -- unsigned
  g_value_unsigned : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => unsigned_ena,
      tracked_value       => tracked_value_unsigned,
      exp_value           => exp_value_unsigned,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_unsigned;

  -- unsigned non-clocked
  g_value_unsigned_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => unsigned_non_clocked_ena,
      tracked_value       => tracked_value_unsigned,
      exp_value           => exp_value_unsigned,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_unsigned_non_clocked;

  -- signed
  g_value_signed : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => signed_ena,
      tracked_value       => tracked_value_signed,
      exp_value           => exp_value_signed,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_signed;

  -- signed non-clocked
  g_value_signed_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => signed_non_clocked_ena,
      tracked_value       => tracked_value_signed,
      exp_value           => exp_value_signed,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_signed_non_clocked;

  -- integer
  g_value_int : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => int_ena,
      tracked_value       => tracked_value_int,
      exp_value           => exp_value_int,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_int;

  -- integer non-clocked
  g_value_int_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => int_non_clocked_ena,
      tracked_value       => tracked_value_int,
      exp_value           => exp_value_int,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_int_non_clocked;

  -- real
  g_value_real : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => real_ena,
      tracked_value       => tracked_value_real,
      exp_value           => exp_value_real,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_real;

  -- real non-clocked
  g_value_real_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => real_non_clocked_ena,
      tracked_value       => tracked_value_real,
      exp_value           => exp_value_real,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_real_non_clocked;

  -- time
  g_value_time : if GC_TESTCASE = "assert_value" generate
    assert_value(
      clk                 => clk,
      ena                 => time_ena,
      tracked_value       => tracked_value_time,
      exp_value           => exp_value_time,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_time;

  -- time non-clocked
  g_value_time_non_clocked : if GC_TESTCASE = "assert_value" generate
    assert_value(
      ena                 => time_non_clocked_ena,
      tracked_value       => tracked_value_time,
      exp_value           => exp_value_time,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_time_non_clocked;
  -------------------------------------
  -- #endregion assert_value
  -------------------------------------
  -------------------------------------
  -- #region assert_one_of
  -------------------------------------
  -- std_logic_vector
  g_one_of_slv : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      allowed_values      => allowed_values_slv_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_slv;

  -- std_logic_vector non-clocked
  g_one_of_slv_non_clocked : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      ena                 => slv_non_clocked_ena,
      tracked_value       => tracked_value_slv,
      allowed_values      => allowed_values_slv_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_slv_non_clocked;

  -- std_logic
  g_one_of_sl : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      allowed_values      => allowed_values_slv,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_sl;

  -- std_logic non-clocked
  g_one_of_sl_non_clocked : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      ena                 => sl_non_clocked_ena,
      tracked_value       => tracked_value_sl,
      allowed_values      => allowed_values_slv,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_sl_non_clocked;

  -- unsigned
  g_one_of_unsigned : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      clk                 => clk,
      ena                 => unsigned_ena,
      tracked_value       => tracked_value_unsigned,
      allowed_values      => allowed_values_unsigned_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_unsigned;

  -- unsigned non-clocked
  g_one_of_unsigned_non_clocked : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      ena                 => unsigned_non_clocked_ena,
      tracked_value       => tracked_value_unsigned,
      allowed_values      => allowed_values_unsigned_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_unsigned_non_clocked;

  -- signed
  g_one_of_signed : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      clk                 => clk,
      ena                 => signed_ena,
      tracked_value       => tracked_value_signed,
      allowed_values      => allowed_values_signed_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_signed;

  -- signed non-clocked
  g_one_of_signed_non_clocked : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      ena                 => signed_non_clocked_ena,
      tracked_value       => tracked_value_signed,
      allowed_values      => allowed_values_signed_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_signed_non_clocked;

  -- integer
  g_one_of_int : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      clk                 => clk,
      ena                 => int_ena,
      tracked_value       => tracked_value_int,
      allowed_values      => allowed_values_int_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_int;

  -- integer non-clocked
  g_one_of_int_non_clocked : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      ena                 => int_non_clocked_ena,
      tracked_value       => tracked_value_int,
      allowed_values      => allowed_values_int_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_int_non_clocked;

  -- real
  g_one_of_real : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      clk                 => clk,
      ena                 => real_ena,
      tracked_value       => tracked_value_real,
      allowed_values      => allowed_values_real_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_real;

  -- real non-clocked
  g_one_of_real_non_clocked : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      ena                 => real_non_clocked_ena,
      tracked_value       => tracked_value_real,
      allowed_values      => allowed_values_real_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_real_non_clocked;

  -- time
  g_one_of_time : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      clk                 => clk,
      ena                 => time_ena,
      tracked_value       => tracked_value_time,
      allowed_values      => allowed_values_time_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_time;

  -- time non-clocked
  g_one_of_time_non_clocked : if GC_TESTCASE = "assert_one_of" generate
    assert_one_of(
      ena                 => time_non_clocked_ena,
      tracked_value       => tracked_value_time,
      allowed_values      => allowed_values_time_array,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_of_time_non_clocked;
  -------------------------------------
  -- #endregion assert_one_of
  -------------------------------------
  -------------------------------------
  -- #region assert_one_hot
  -------------------------------------
  g_one_hot : if GC_TESTCASE = "assert_one_hot" generate
    assert_one_hot(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      msg                 => "",
      alert_level         => alert_level,
      accept_all_zero     => accept_all_zeros,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_hot;

  -- non-clocked
  g_one_hot_non_clocked : if GC_TESTCASE = "assert_one_hot" generate
    assert_one_hot(
      ena                 => slv_non_clocked_ena,
      tracked_value       => tracked_value_slv,
      msg                 => "",
      alert_level         => alert_level,
      accept_all_zero     => accept_all_zeros,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_one_hot_non_clocked;
  -------------------------------------
  -- #endregion assert_one_hot
  -------------------------------------
  -------------------------------------
  -- #region assert_value_in_range
  -------------------------------------
  -- unsigned
  g_value_in_range_unsigned : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      clk                 => clk,
      ena                 => unsigned_ena,
      tracked_value       => tracked_value_unsigned,
      lower_limit         => lower_limit_unsigned,
      upper_limit         => upper_limit_unsigned,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_unsigned;

  -- unsigned non-clocked
  g_value_in_range_unsigned_non_clocked : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      ena                 => unsigned_non_clocked_ena,
      tracked_value       => tracked_value_unsigned,
      lower_limit         => lower_limit_unsigned,
      upper_limit         => upper_limit_unsigned,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_unsigned_non_clocked;

  -- signed
  g_value_in_range_signed : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      clk                 => clk,
      ena                 => signed_ena,
      tracked_value       => tracked_value_signed,
      lower_limit         => lower_limit_signed,
      upper_limit         => upper_limit_signed,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_signed;

  -- signed non-clocked
  g_value_in_range_signed_non_clocked : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      ena                 => signed_non_clocked_ena,
      tracked_value       => tracked_value_signed,
      lower_limit         => lower_limit_signed,
      upper_limit         => upper_limit_signed,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_signed_non_clocked;

  -- integer
  g_value_in_range_int : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      clk                 => clk,
      ena                 => int_ena,
      tracked_value       => tracked_value_int,
      lower_limit         => lower_limit_int,
      upper_limit         => upper_limit_int,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_int;

  -- integer non-clocked
  g_value_in_range_int_non_clocked : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      ena                 => int_non_clocked_ena,
      tracked_value       => tracked_value_int,
      lower_limit         => lower_limit_int,
      upper_limit         => upper_limit_int,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_int_non_clocked;

  -- real
  g_value_in_range_real : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      clk                 => clk,
      ena                 => real_ena,
      tracked_value       => tracked_value_real,
      lower_limit         => lower_limit_real,
      upper_limit         => upper_limit_real,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_real;

  -- real non-clocked
  g_value_in_range_real_non_clocked : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      ena                 => real_non_clocked_ena,
      tracked_value       => tracked_value_real,
      lower_limit         => lower_limit_real,
      upper_limit         => upper_limit_real,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_real_non_clocked;

  -- time
  g_value_in_range_time : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      clk                 => clk,
      ena                 => time_ena,
      tracked_value       => tracked_value_time,
      lower_limit         => lower_limit_time,
      upper_limit         => upper_limit_time,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_time;

  -- time non-clocked
  g_value_in_range_time_non_clocked : if GC_TESTCASE = "assert_value_in_range" generate
    assert_value_in_range(
      ena                 => time_non_clocked_ena,
      tracked_value       => tracked_value_time,
      lower_limit         => lower_limit_time,
      upper_limit         => upper_limit_time,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_in_range_time_non_clocked;
  -------------------------------------
  -- #endregion assert_value_in_range
  -------------------------------------

  g_shift_one_from_left : if GC_TESTCASE = "assert_shift_one_from_left" generate
    assert_shift_one_from_left(
      clk                 => clk,
      ena                 => ena,
      tracked_value       => tracked_value_slv,
      necessary_condition => necessary_condition,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_shift_one_from_left;

  -------------------------------------
  -- #region window_assertions
  -------------------------------------
  -------------------------------------
  -- #region assert_value_from_min_to_max_cycles_after_trigger
  -------------------------------------
  -- std_logic
  g_value_from_min_to_max_cycles_after_trigger_sl : if GC_TESTCASE = "assert_value_from_min_to_max_cycles_after_trigger" generate
    assert_value_from_min_to_max_cycles_after_trigger(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      trigger             => trigger,
      min_cycles          => min_cycles,
      max_cycles          => max_cycles,
      exp_value           => exp_value_sl,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_from_min_to_max_cycles_after_trigger_sl;

  -- std_logic_vector
  g_value_from_min_to_max_cycles_after_trigger_slv : if GC_TESTCASE = "assert_value_from_min_to_max_cycles_after_trigger" generate
    assert_value_from_min_to_max_cycles_after_trigger(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      trigger             => trigger,
      min_cycles          => min_cycles,
      max_cycles          => max_cycles,
      exp_value           => exp_value_slv,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_from_min_to_max_cycles_after_trigger_slv;
  -------------------------------------
  -- #endregion assert_value_from_min_to_max_cycles_after_trigger
  -------------------------------------
  -------------------------------------
  -- #region assert_change_to_value_from_min_to_max_cycles_after_trigger
  -------------------------------------
  -- std_logic
  g_change_to_value_from_min_to_max_cycles_after_trigger_sl : if GC_TESTCASE = "assert_change_to_value_from_min_to_max_cycles_after_trigger" generate
    assert_change_to_value_from_min_to_max_cycles_after_trigger(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      trigger             => trigger,
      min_cycles          => min_cycles,
      max_cycles          => max_cycles,
      exp_value           => exp_value_sl,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_change_to_value_from_min_to_max_cycles_after_trigger_sl;

  -- std_logic_vector
  g_change_to_value_from_min_to_max_cycles_after_trigger_slv : if GC_TESTCASE = "assert_change_to_value_from_min_to_max_cycles_after_trigger" generate
    assert_change_to_value_from_min_to_max_cycles_after_trigger(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      trigger             => trigger,
      min_cycles          => min_cycles,
      max_cycles          => max_cycles,
      exp_value           => exp_value_slv,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_change_to_value_from_min_to_max_cycles_after_trigger_slv;
  -------------------------------------
  -- #endregion assert_change_to_value_from_min_to_max_cycles_after_trigger
  -------------------------------------
  -------------------------------------
  -- #region assert_change_from_min_to_max_cycles_after_trigger
  -------------------------------------
  -- std_logic
  g_change_from_min_to_max_cycles_after_trigger_sl : if GC_TESTCASE = "assert_change_from_min_to_max_cycles_after_trigger" generate
    assert_change_from_min_to_max_cycles_after_trigger(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      trigger             => trigger,
      min_cycles          => min_cycles,
      max_cycles          => max_cycles,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_change_from_min_to_max_cycles_after_trigger_sl;

  -- std_logic_vector
  g_change_from_min_to_max_cycles_after_trigger_slv : if GC_TESTCASE = "assert_change_from_min_to_max_cycles_after_trigger" generate
    assert_change_from_min_to_max_cycles_after_trigger(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      trigger             => trigger,
      min_cycles          => min_cycles,
      max_cycles          => max_cycles,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_change_from_min_to_max_cycles_after_trigger_slv;
  -------------------------------------
  -- #endregion assert_change_from_min_to_max_cycles_after_trigger
  -------------------------------------
  -------------------------------------
  -- #region assert_stable_from_min_to_max_cycles_after_trigger
  -------------------------------------
  -- std_logic
  g_stable_from_min_to_max_cycles_after_trigger_sl : if GC_TESTCASE = "assert_stable_from_min_to_max_cycles_after_trigger" generate
    assert_stable_from_min_to_max_cycles_after_trigger(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      trigger             => trigger,
      min_cycles          => min_cycles,
      max_cycles          => max_cycles,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_stable_from_min_to_max_cycles_after_trigger_sl;

  -- std_logic_vector
  g_stable_from_min_to_max_cycles_after_trigger_slv : if GC_TESTCASE = "assert_stable_from_min_to_max_cycles_after_trigger" generate
    assert_stable_from_min_to_max_cycles_after_trigger(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      trigger             => trigger,
      min_cycles          => min_cycles,
      max_cycles          => max_cycles,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_stable_from_min_to_max_cycles_after_trigger_slv;
  -------------------------------------
  -- #endregion assert_stable_from_min_to_max_cycles_after_trigger
  -------------------------------------
  -------------------------------------
  -- #region assert_value_from_start_to_end_trigger
  -------------------------------------
  -- std_logic
  g_value_from_start_to_end_trigger_sl : if GC_TESTCASE = "assert_value_from_start_to_end_trigger" generate
    assert_value_from_start_to_end_trigger(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      start_trigger       => start_trigger,
      end_trigger         => end_trigger,
      exp_value           => exp_value_sl,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_from_start_to_end_trigger_sl;

  -- std_logic_vector
  g_value_from_start_to_end_trigger_slv : if GC_TESTCASE = "assert_value_from_start_to_end_trigger" generate
    assert_value_from_start_to_end_trigger(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      start_trigger       => start_trigger,
      end_trigger         => end_trigger,
      exp_value           => exp_value_slv,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_value_from_start_to_end_trigger_slv;
  -------------------------------------
  -- #endregion assert_value_from_start_to_end_trigger
  -------------------------------------
  -------------------------------------
  -- #region assert_change_to_value_from_start_to_end_trigger
  -------------------------------------
  -- std_logic
  g_change_to_value_from_start_to_end_trigger_sl : if GC_TESTCASE = "assert_change_to_value_from_start_to_end_trigger" generate
    assert_change_to_value_from_start_to_end_trigger(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      start_trigger       => start_trigger,
      end_trigger         => end_trigger,
      exp_value           => exp_value_sl,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_change_to_value_from_start_to_end_trigger_sl;

  -- std_logic_vector
  g_change_to_value_from_start_to_end_trigger_slv : if GC_TESTCASE = "assert_change_to_value_from_start_to_end_trigger" generate
    assert_change_to_value_from_start_to_end_trigger(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      start_trigger       => start_trigger,
      end_trigger         => end_trigger,
      exp_value           => exp_value_slv,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_change_to_value_from_start_to_end_trigger_slv;
  -------------------------------------
  -- #endregion assert_change_to_value_from_start_to_end_trigger
  -------------------------------------
  -------------------------------------
  -- #region assert_change_from_start_to_end_trigger
  -------------------------------------
  -- std_logic
  g_change_from_start_to_end_trigger_sl : if GC_TESTCASE = "assert_change_from_start_to_end_trigger" generate
    assert_change_from_start_to_end_trigger(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      start_trigger       => start_trigger,
      end_trigger         => end_trigger,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_change_from_start_to_end_trigger_sl;

  -- std_logic_vector
  g_change_from_start_to_end_trigger_slv : if GC_TESTCASE = "assert_change_from_start_to_end_trigger" generate
    assert_change_from_start_to_end_trigger(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      start_trigger       => start_trigger,
      end_trigger         => end_trigger,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_change_from_start_to_end_trigger_slv;
  -------------------------------------
  -- #endregion assert_change_from_start_to_end_trigger
  -------------------------------------
  -------------------------------------
  -- #region assert_change_from_start_to_end_trigger
  -------------------------------------
  -- std_logic
  g_stable_from_start_to_end_trigger_sl : if GC_TESTCASE = "assert_stable_from_start_to_end_trigger" generate
    assert_stable_from_start_to_end_trigger(
      clk                 => clk,
      ena                 => sl_ena,
      tracked_value       => tracked_value_sl,
      start_trigger       => start_trigger,
      end_trigger         => end_trigger,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_stable_from_start_to_end_trigger_sl;

  -- std_logic_vector
  g_stable_from_start_to_end_trigger_slv : if GC_TESTCASE = "assert_stable_from_start_to_end_trigger" generate
    assert_stable_from_start_to_end_trigger(
      clk                 => clk,
      ena                 => slv_ena,
      tracked_value       => tracked_value_slv,
      start_trigger       => start_trigger,
      end_trigger         => end_trigger,
      msg                 => "",
      alert_level         => alert_level,
      pos_ack_kind        => pos_ack_kind
    );
  end generate g_stable_from_start_to_end_trigger_slv;
  -------------------------------------
  -- #endregion assert_change_from_start_to_end_trigger
  -------------------------------------
  -------------------------------------
  -- #endregion window_assertions
  -------------------------------------
  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_rand                      : t_rand;
    variable v_time_vector               : time_vector(3 downto 0)         := (6 ns, 7 ns, 8 ns, 9 ns);
    variable v_std_logic_sequence        : std_logic_vector(7 downto 0)    := ('H', 'L', 'W', 'Z', '0', '1', 'X', 'U');
    variable v_std_logic_vector_sequence : t_slv_array(0 to 7)(3 downto 0) := ("HHHH", "LLLL", "WWWW", "ZZZZ", "0000", "1111", "XXXX", "UUUU");
    variable v_hold_time                 : integer;
    variable v_change_time               : integer;

    ------------------------------------------------------------------------------
    -- Procedures
    ------------------------------------------------------------------------------

    --============================================================================
    -- test_one_of
    --============================================================================
    procedure test_triggering_assert_one_of(
      constant clock_mode : t_clock_mode := CLOCKED
    ) is
      variable v_is_allowed_values  : boolean := false;
    begin
      -- Check which values in v_std_logic_sequence that are included in allowed_value
      for i in 0 to v_std_logic_sequence'length - 1 loop
        for j in 0 to allowed_values_slv'length - 1 loop
          if v_std_logic_sequence(i) = allowed_values_slv(j) then
            v_is_allowed_values := true;
          end if;
        end loop;

        -- Testing triggering assert for values that are not included in allowed_values
        if not v_is_allowed_values then
          log(ID_SEQUENCER, "tracked_value = '" & to_string(v_std_logic_sequence(i)) & "', expecting alert");
          increment_expected_alerts_and_stop_limit(TB_ERROR);
          tracked_value_sl <= v_std_logic_sequence(i);
          -- assert_one_of
          if clock_mode = CLOCKED then
            wait for C_CLK_PERIOD;
            tracked_value_sl <= '0';
            wait for 4 * C_CLK_PERIOD;
          -- assert_one_of non-clocked
          else
            wait for 2 * v_rand.rand(ONLY, v_time_vector); -- waits for a random time
            tracked_value_sl <= '0';
            wait for 4 * v_rand.rand(ONLY, v_time_vector); -- waits for a random time
          end if;
        end if;

        -- Set back to the initial value
        v_is_allowed_values := false;
      end loop;
    end procedure;

    --============================================================================
    -- test_one_hot
    --============================================================================
    procedure test_normal_operation_one_hot(
      constant clock_mode : t_clock_mode := CLOCKED
    ) is
      variable v_expression : std_logic_vector(3 downto 0) := "1000";
    begin
      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation with accept_all_zeros: " & to_upper(to_string(accept_all_zeros)));
      ------------------------------------------------------------------------
      -- Testing all legal expressions
      for i in 0 to 4 loop
        if accept_all_zeros = ALL_ZERO_ALLOWED or i < 4 then
          v_expression := "1000" srl i;
          log(ID_SEQUENCER, "Testing the expression: " & to_string(v_expression));
          tracked_value_slv <= "1000" srl i;
        else
          tracked_value_slv <= "1000"; -- Set back to the initial value to prevent an alert on each rising clock edge in assert_one_hot
        end if;
        -- assert_one_hot
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_one_hot non-clocked
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
    end procedure;

    procedure test_triggering_assert_one_hot(
      constant clock_mode : t_clock_mode := CLOCKED
    ) is
    begin
      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion with accept_all_zeros: " & to_upper(to_string(accept_all_zeros)));
      ------------------------------------------------------------------------
      -- Number of total expected alerts: number of 4-bit combinations - number of legal 4-bit one-hot or zero-one-hot combinations
      if accept_all_zeros = ALL_ZERO_NOT_ALLOWED then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 12);
      elsif accept_all_zeros = ALL_ZERO_ALLOWED then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 11);
      else
        report "Unknown accept_all_zeros enum literal" severity ERROR;
      end if;

      -- Testing all 4-bit combinations
      for i in 0 to 15 loop
        log(ID_SEQUENCER, "Testing the expression: " & to_string(std_logic_vector(to_unsigned(i, 4))));
        tracked_value_slv <= std_logic_vector(to_unsigned(i, 4));
        -- assert_one_hot
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_one_hot non-clocked
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;

      -- Set back to the initial value to prevent an alert on each rising clock edge
      tracked_value_slv <= "1000";
    end procedure;

    --============================================================================
    -- test_value_in_range
    --============================================================================
    -------------------------------------
    -- test_normal_operation_value_in_range
    -------------------------------------
    -- unsigned version
    procedure test_normal_operation_value_in_range(
      constant lower_limit : unsigned; -- Lower bound
      constant upper_limit : unsigned; -- Upper bound
      constant clock_mode  : t_clock_mode := CLOCKED
    ) is
    begin
      -- Testing all values within the range
      for i in to_integer(lower_limit) to to_integer(upper_limit) loop
        log("tracked_value = " & to_string(i));
        tracked_value_unsigned <= to_unsigned(i, tracked_value_unsigned'length);
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clocked
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
    end procedure;

    -- signed version
    procedure test_normal_operation_value_in_range(
      constant lower_limit : signed; -- Lower bound
      constant upper_limit : signed; -- Upper bound
      constant clock_mode  : t_clock_mode := CLOCKED
    ) is
    begin
      -- Testing all values within the range
      for i in to_integer(lower_limit) to to_integer(upper_limit) loop
        log("tracked_value = " & to_string(i));
        tracked_value_signed <= to_signed(i, tracked_value_signed'length);
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clocked
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
    end procedure;

    -- integer version
    procedure test_normal_operation_value_in_range(
      constant lower_limit : integer; -- Lower bound
      constant upper_limit : integer; -- Upper bound
      constant clock_mode  : t_clock_mode := CLOCKED
    ) is
    begin
      -- Testing all values within the range
      for i in lower_limit to upper_limit loop
        log("tracked_value = " & to_string(i));
        tracked_value_int <= i;
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clocked
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
    end procedure;

    -- real version
    procedure test_normal_operation_value_in_range(
      constant lower_limit : real; -- Lower bound
      constant upper_limit : real; -- Upper bound
      constant clock_mode  : t_clock_mode := CLOCKED
    ) is
    begin
      -- Testing all values within the range
      for i in integer(lower_limit) to integer(upper_limit) loop
        log("tracked_value = " & to_string(real(i)));
        tracked_value_real <= real(i);
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clocked
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
    end procedure;

    -- time version
    procedure test_normal_operation_value_in_range(
      constant lower_limit : time; -- Lower bound
      constant upper_limit : time; -- Upper bound
      constant clock_mode  : t_clock_mode := CLOCKED
    ) is
    begin
      -- Testing all values within the range
      for i in integer(lower_limit / 1 ns) to integer(upper_limit / 1 ns) loop
        log("tracked_value = " & to_string(i * 1 ns));
        tracked_value_time <= i * 1 ns;
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clocked
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
    end procedure;

    -------------------------------------
    -- test_triggering_assert_value_in_range
    -------------------------------------
    -- unsigned version
    procedure test_triggering_assert_value_in_range(
      constant lower_limit  : unsigned; -- Lower bound
      constant upper_limit  : unsigned; -- Upper bound
      constant clock_mode   : t_clock_mode   := CLOCKED;
      constant out_of_range : t_out_of_range := ABOVE
    ) is
    begin
      -- Testing above or below the range
      for i in 1 to to_integer(upper_limit) - to_integer(lower_limit) loop
        increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
        if out_of_range = ABOVE then
          log("tracked_value = " & to_string(to_integer(upper_limit) + i));
          tracked_value_unsigned <= upper_limit + to_unsigned(i, tracked_value_unsigned'length);
        else
          log("tracked_value = " & to_string(to_integer(lower_limit) - i));
          tracked_value_unsigned <= lower_limit - to_unsigned(i, tracked_value_unsigned'length);
        end if;
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clock
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
      tracked_value_unsigned <= lower_limit; -- Set back to the lower bound to prevent an alert
    end procedure;

    -- signed version
    procedure test_triggering_assert_value_in_range(
      constant lower_limit  : signed; -- Lower bound
      constant upper_limit  : signed; -- Upper bound
      constant clock_mode   : t_clock_mode   := CLOCKED;
      constant out_of_range : t_out_of_range := ABOVE
    ) is
    begin
      -- Testing above or below the range
      for i in 1 to to_integer(upper_limit) - to_integer(lower_limit) loop
        increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
        if out_of_range = ABOVE then
          log("tracked_value = " & to_string(to_integer(upper_limit) + i));
          tracked_value_signed <= upper_limit + to_signed(i, tracked_value_signed'length);
        else
          log("tracked_value = " & to_string(to_integer(lower_limit) - i));
          tracked_value_signed <= lower_limit - to_signed(i, tracked_value_signed'length);
        end if;
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clock
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
      tracked_value_signed <= lower_limit; -- Set back to the lower bound to prevent an alert
    end procedure;

    -- integer version
    procedure test_triggering_assert_value_in_range(
      constant lower_limit  : integer; -- Lower bound
      constant upper_limit  : integer; -- Upper bound
      constant clock_mode   : t_clock_mode   := CLOCKED;
      constant out_of_range : t_out_of_range := ABOVE
    ) is
    begin
      -- Testing above or below the range
      for i in 1 to upper_limit - lower_limit loop
        increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
        if out_of_range = ABOVE then
          log("tracked_value = " & to_string(upper_limit + i));
          tracked_value_int <= upper_limit + i;
        else
          log("tracked_value = " & to_string(lower_limit - i));
          tracked_value_int <= lower_limit - i;
        end if;
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clock
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
      tracked_value_int <= lower_limit; -- Set back to the lower bound to prevent an alert
    end procedure;

    -- real version
    procedure test_triggering_assert_value_in_range(
      constant lower_limit  : real; -- Lower bound
      constant upper_limit  : real; -- Upper bound
      constant clock_mode   : t_clock_mode   := CLOCKED;
      constant out_of_range : t_out_of_range := ABOVE
    ) is
    begin
      -- Testing above or below the range
      for i in 1 to integer(upper_limit) - integer(lower_limit) loop
        increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
        if out_of_range = ABOVE then
          log("tracked_value = " & to_string(upper_limit + real(i)));
          tracked_value_real <= upper_limit + real(i);
        else
          log("tracked_value = " & to_string(lower_limit - real(i)));
          tracked_value_real <= lower_limit - real(i);
        end if;
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clock
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
      tracked_value_real <= lower_limit; -- Set back to the lower bound to prevent an alert
    end procedure;

    -- time version
    procedure test_triggering_assert_value_in_range(
      constant lower_limit  : time; -- Lower bound
      constant upper_limit  : time; -- Upper bound
      constant clock_mode   : t_clock_mode   := CLOCKED;
      constant out_of_range : t_out_of_range := ABOVE
    ) is
    begin
      -- Testing above or below the range
      for i in 1 to integer(upper_limit / 1 ns) - integer(lower_limit / 1 ns) loop
        increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
        if out_of_range = ABOVE then
          log("tracked_value = " & to_string(upper_limit + (i * 1 ns)));
          tracked_value_time <= upper_limit + (i * 1 ns);
        else
          log("tracked_value = " & to_string(lower_limit - (i * 1 ns)));
          tracked_value_time <= lower_limit - (i * 1 ns);
        end if;
        -- assert_value_in_range
        if clock_mode = CLOCKED then
          wait for C_CLK_PERIOD;
        -- assert_value_in_range non-clock
        else
          wait for v_rand.rand(ONLY, v_time_vector); -- waits for a random time
        end if;
      end loop;
      tracked_value_time <= lower_limit; -- Set back to the lower bound to prevent an alert
    end procedure;

    --============================================================================
    -- test_shift_one_from_left
    --============================================================================
    procedure test_normal_operation_shift_one_from_left(
      signal necessary_condition : t_shift_one_ness_cond
    ) is
    begin
      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation with necessary_condition: " & to_upper(to_string(necessary_condition)));
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing single sequence: 1000 -> 0100 -> 0010 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing two consecutive sequences: 1000 -> 0100 -> 0010 -> 0001 -> 1000 -> 0100 -> 0010 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing pipeline 2 sequences: 1000 -> 1100 -> 0110 -> 0011 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0110";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0011";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing pipeline 3 sequences: 1000 -> 1100 -> 1110 -> 0111 -> 0011 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1110";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0111";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0011";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing pipeline 4 sequences: 1000 -> 1100 -> 1110 -> 1111-> 0111 -> 0011 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1110";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1111";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0111";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0011";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing pipeline 2 sequences /w 1-bit gap: 1000 -> 0100 -> 1010 -> 0101 -> 0010 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0101";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing pipeline 2 sequences /w 2-bit gap: 1000 -> 0100 -> 0010 -> 1001 -> 0100 -> 0010 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1001";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing pipeline 3 sequences /w 1-bit gap between sequence 1 and 2:\n1000 -> 0100 -> 1010 -> 1101 -> 0110 -> 0011 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1101";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0110";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0011";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing pipeline 3 sequences /w 1-bit gap between sequence 2 and 3:\n1000 -> 1100 -> 0110 -> 1011 -> 0101 -> 0010 -> 0001");
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0110";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1011";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0101";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0010";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for 4 * C_CLK_PERIOD;
    end procedure;

    procedure test_triggering_assert_shift_one_from_left(
      signal shift_one_ness_cond : t_shift_one_ness_cond
    ) is
      variable v_sequence : t_sequence := (others => "1000");
    begin
      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion with necessary_condition: " & to_upper(to_string(shift_one_ness_cond)));
      ------------------------------------------------------------------------

      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Triggering Assertion: Single sequence\nTesting all combinations of 4-bit sequence starting with 1000\n");
      ------------------------------------------------------------------------
      if shift_one_ness_cond = ANY_BIT_ALERT then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 199); -- number of alerts = number of all tested invalid sequences
      elsif shift_one_ness_cond = ANY_BIT_ALERT_NO_PIPE then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 164); -- number of alerts = number of all tested invalid sequences - number of alerts detected in the pipelines
      elsif shift_one_ness_cond = LAST_BIT_ALERT then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 5);   -- number of alerts = number of alerts detected in the last bit of the test sequences
      elsif shift_one_ness_cond = LAST_BIT_ALERT_NO_PIPE then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 4);   -- number of alerts = number of alerts detected in the last bit of the test sequences - number of alerts detected in the last bit of the pipelines
      else
        report "Unknown necessary_condition" severity ERROR;
      end if;

      -- Testing all combinations of 4-bit sequence starting with 1000
      for i in 0 to 4 loop
        v_sequence(1) := "1000" srl i;
        for j in 0 to 4 loop
          v_sequence(2) := "1000" srl j;
          for k in 0 to 4 loop
            v_sequence(3) := "1000" srl k;
            log("Testing the sequence: " & to_string(v_sequence(0)) & " -> " & to_string(v_sequence(1)) & " -> " & to_string(v_sequence(2)) & " -> " & to_string(v_sequence(3)));
            tracked_value_slv <= "1000";
            wait for C_CLK_PERIOD;
            tracked_value_slv <= "1000" srl i;
            wait for C_CLK_PERIOD;
            tracked_value_slv <= "1000" srl j;
            wait for C_CLK_PERIOD;
            if k = 0 then
              tracked_value_slv <= "1000" srl k, "0000" after C_CLK_PERIOD; -- Set back to the initial value to prevent an alert on each rising clock edge
            else
              tracked_value_slv <= "1000" srl k;
            end if;
            wait for 4 * C_CLK_PERIOD;
          end loop;
        end loop;
      end loop;

      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Triggering Assertion: Pipeline\nTesting 4 pipelines with all combinations in cycle 3 and 4\nTwo combinations (0110 and 0111) are tested in cycle 5\n");
      ------------------------------------------------------------------------
      if shift_one_ness_cond = ANY_BIT_ALERT then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 960); -- number of alerts = number of all tested invalid sequences
      elsif shift_one_ness_cond = ANY_BIT_ALERT_NO_PIPE then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 384); -- number of alerts = number of all tested invalid sequences - number of alerts detected in the pipelines
      elsif shift_one_ness_cond = LAST_BIT_ALERT then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 192); -- number of alerts = number of alerts detected in the last bit of the test sequences
      elsif shift_one_ness_cond = LAST_BIT_ALERT_NO_PIPE then
        increment_expected_alerts_and_stop_limit(TB_ERROR, 128); -- number of alerts = number of alerts detected in the last bit of the test sequences - number of alerts detected in the last bit of the pipelines
      else
        report "Unknown necessary_condition" severity ERROR;
      end if;

      -- Testing 4 pipelines with all combinations in cycle 3 and 4
      -- Two combinations ("0110" and "0111") are tested in cycle 5
      for i in 0 to 15 loop
        for j in 0 to 15 loop
          for k in 6 to 7 loop
            log("Testing the sequence: 1000 -> 1100 -> " & to_string(std_logic_vector(to_unsigned(i, 4))) & " -> " & to_string(std_logic_vector(to_unsigned(j, 4))) & " -> " & to_string(std_logic_vector(to_unsigned(k, 4))) & " -> 0011 -> 0001" );
            tracked_value_slv <= "1000";
            wait for C_CLK_PERIOD;
            tracked_value_slv <= "1100";
            wait for C_CLK_PERIOD;
            tracked_value_slv <= std_logic_vector(to_unsigned(i, 4));
            wait for C_CLK_PERIOD;
            tracked_value_slv <= std_logic_vector(to_unsigned(j, 4));
            wait for C_CLK_PERIOD;
            tracked_value_slv <= std_logic_vector(to_unsigned(k, 4));
            wait for C_CLK_PERIOD;
            tracked_value_slv <= "0011";
            wait for C_CLK_PERIOD;
            tracked_value_slv <= "0001";
            wait for 4 * C_CLK_PERIOD;
          end loop;
        end loop;
      end loop;
    end procedure;

    --============================================================================
    -- set_exp_value
    --============================================================================
    -- std_logic version
    procedure set_exp_value(
      constant value : std_logic -- Value to be set to exp_value
    ) is
    begin
      log(ID_SEQUENCER, "Setting exp_value = '" & to_string(value) & "'");
      sl_ena <= '0';
      exp_value_sl <= value;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
    end procedure;

    -- std_logic_vector version
    procedure set_exp_value(
      constant value : std_logic_vector -- Value to be set to exp_value
    ) is
    begin
      log(ID_SEQUENCER, "Setting exp_value = """ & to_string(value) & """");
      slv_ena <= '0';
      exp_value_slv <= value;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
    end procedure;

    --============================================================================
    -- Cycle bound window assertions procedures
    --============================================================================
    -------------------------------------
    -- set_min_max_cycles
    -------------------------------------
    procedure set_min_max_cycles(
      constant select_ena : t_select_ena; -- Select enable for assertions overloads
      constant min_cycles_val : integer;  -- Value to be set to min_cycles
      constant max_cycles_val : integer   -- Value to be set to max_cycles
    ) is
    begin
      log(ID_SEQUENCER, "Setting min_cycles = " & to_string(min_cycles_val) & ", max_cycles = " & to_string(max_cycles_val));
      -- Disables selected assertion overload
      if select_ena = SL_OVERLOAD_ENA then
        sl_ena <= '0';
      elsif select_ena = SLV_OVERLOAD_ENA then
        slv_ena <= '0';
      end if;
      -- Sets min and max cycles
      min_cycles <= min_cycles_val;
      max_cycles <= max_cycles_val;
      wait for C_CLK_PERIOD;
      -- Enables selected assertion overload
      if select_ena = SL_OVERLOAD_ENA then
        sl_ena <= '1';
      elsif select_ena = SLV_OVERLOAD_ENA then
        slv_ena <= '1';
      end if;
      wait for 4 * C_CLK_PERIOD;
    end procedure;

    -------------------------------------
    -- hold_min_to_max_cycles
    -------------------------------------
    -- std_logic version
    procedure hold_min_to_max_cycles(
      constant hold_value : std_logic -- Value to be held within the window
    ) is
    begin
      log(ID_SEQUENCER, "Hold '" & to_string(hold_value) & "' from " &  to_string(min_cycles) & "-cycles to " & to_string(max_cycles) & "-cycles");
      trigger <= '1', '0' after C_CLK_PERIOD;
      -- Waits for the minimum number of clock cycles only if it is higher than 0
      if min_cycles /= 0 then
        wait for (min_cycles - 1) * C_CLK_PERIOD;
      end if;
      tracked_value_sl <= hold_value;
      -- Waits for the window only if max_cycles /= min_cycles
      if max_cycles /= min_cycles then
        wait for (max_cycles - min_cycles + 2) * C_CLK_PERIOD; -- Waits for the inclusive window (max_cycles - min_cycles + 2)
      else
        wait for C_CLK_PERIOD;
      end if;
      tracked_value_sl <= '0'; -- Set back to the initial value
    end procedure;

    -- std_logic_vector version
    procedure hold_min_to_max_cycles(
      constant hold_value : std_logic_vector -- Value to be held within the window
    ) is
    begin
      log(ID_SEQUENCER, "Hold """ & to_string(hold_value) & """ from " &  to_string(min_cycles) & "-cycles to " & to_string(max_cycles) & "-cycles");
      trigger <= '1', '0' after C_CLK_PERIOD;
      -- Waits for the minimum number of clock cycles only if it is higher than 0
      if min_cycles /= 0 then
        wait for (min_cycles - 1) * C_CLK_PERIOD;
      end if;
      tracked_value_slv <= hold_value;
      -- Waits for the window only if max_cycles /= min_cycles
      if max_cycles /= min_cycles then
        wait for (max_cycles - min_cycles + 2) * C_CLK_PERIOD; -- Waits for the inclusive window (max_cycles - min_cycles + 2)
      else
        wait for C_CLK_PERIOD;
      end if;
      tracked_value_slv <= "0000"; -- Set back to the initial value
    end procedure;

    procedure hold_min_to_max_cycles_all_values is
    begin
      -- Tests all values stored in the test sequence
      for i in 0 to 7 loop
        -- Holds a value in the test sequence based on the active enable signal
        if sl_ena = '1' then
          hold_min_to_max_cycles(v_std_logic_sequence(i));
        elsif slv_ena = '1' then
          hold_min_to_max_cycles(v_std_logic_vector_sequence(i));
        end if;
        wait for 4 * C_CLK_PERIOD;
      end loop;
    end procedure;

    -------------------------------------
    -- test_triggering_assert_value_min_to_max_cycles
    -------------------------------------
    -- stc_logic version
    procedure test_triggering_assert_value_min_to_max_cycles is
      variable v_window   : integer := max_cycles - min_cycles + 1; -- test window
      variable v_sequence : std_logic_vector(v_window - 1 downto 0) := (others => '0'); -- test sequence
    begin
      log(ID_SEQUENCER, "Testing the window, " & to_string(min_cycles) & "-cycles to " & to_string(max_cycles) & "-cycles");

      -- Testing all bit patterns within the window
      for i in 0 to 2 ** v_window - 2 loop -- range = number of all bit patterns - number of legal bit pattern (all 1's)
        log(ID_SEQUENCER, "Bit pattern: " & to_string(std_logic_vector(to_unsigned(i, v_window))));
        trigger <= '1', '0' after C_CLK_PERIOD;
        -- Waits for the minimum number of clock cycles only if it is higher than 0
        if min_cycles /= 0 then
          wait for min_cycles * C_CLK_PERIOD;
        end if;

        -- Creates the test sequence
        v_sequence := std_logic_vector(to_unsigned(i, v_window));

        -- Assigns the test sequence to tracked_value, bit by bit
        for j in 1 to v_window loop
          tracked_value_sl <= v_sequence(v_window - j);
          wait for C_CLK_PERIOD;
        end loop;
        tracked_value_sl <= '0'; -- Set back to the initial value
        wait for 4 * C_CLK_PERIOD;
      end loop;
    end procedure;

    -- std_logic_vector version
    procedure test_triggering_assert_value_min_to_max_cycles(
      constant triggering_value : std_logic_vector; -- Value that triggers assertion
      constant exp_value        : std_logic_vector  -- Value to be expected
    ) is
      variable v_sequence : t_sequence := (others => exp_value); -- test sequence
    begin
      -- Testing triggering assert in each cycle
      for i in 0 to max_cycles - min_cycles loop
        trigger <= '1', '0' after C_CLK_PERIOD;
        -- Waits for the minimum number of clock cycles only if it is higher than 0
        if min_cycles /= 0 then
          wait for min_cycles * C_CLK_PERIOD;
        end if;

        -- Sets triggering_value to the test sequence
        v_sequence(i) := triggering_value;

        -- Assigns the test sequence to tracked_value, std_logic_vector by std_logic_vector
        for j in 0 to max_cycles - min_cycles loop
          tracked_value_slv <= v_sequence(j);
          wait for C_CLK_PERIOD;
        end loop;
        v_sequence(i) := exp_value;  -- Set back the test sequence to the expected value
        tracked_value_slv <= "0000"; -- Set back tracked_value to the initial value
        wait for 4 * C_CLK_PERIOD;
      end loop;
    end procedure;

    -------------------------------------
    -- change_value_min_to_max_cycles
    -------------------------------------
    -- std_logic version
    procedure change_value_min_to_max_cycles(
      constant change_from_value : std_logic; -- Value to be changed from
      constant change_to_value   : std_logic  -- Value to be changed to
    ) is
    begin
      log(ID_SEQUENCER, "Change the value from '" & to_string(change_from_value) & "' to '" & to_string(change_to_value) & "', window (" & to_string(min_cycles) & "-cycles to " & to_string(max_cycles) & "-cycles)");
      trigger <= '1', '0' after C_CLK_PERIOD;
      if min_cycles /= 0 then
        wait for (min_cycles - 1) * C_CLK_PERIOD; -- Waits for the minimum number of clock cycles - 1 to test inclusive window
      end if;
      tracked_value_sl <= change_from_value;
      wait for (max_cycles - min_cycles) * C_CLK_PERIOD; -- Waits until reaching the last bit within the window (max_cycles - min_cycles)
      tracked_value_sl <= change_to_value;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0'; -- Set back to the initial value
    end procedure;

    -- std_logic_vector version
    procedure change_value_min_to_max_cycles(
      constant change_from_value : std_logic_vector; -- Value to be changed from
      constant change_to_value   : std_logic_vector  -- Value to be changed to
    ) is
    begin
      log(ID_SEQUENCER, "Change the value from """ & to_string(change_from_value) & """ to """ & to_string(change_to_value) & """, window (" & to_string(min_cycles) & "-cycles to " & to_string(max_cycles) & "-cycles)");
      trigger <= '1', '0' after C_CLK_PERIOD;
      if min_cycles /= 0 then
        wait for (min_cycles - 1) * C_CLK_PERIOD; -- Waits for the minimum number of clock cycles - 1 to test inclusive window
      end if;
      tracked_value_slv <= change_from_value;
      wait for (max_cycles - min_cycles) * C_CLK_PERIOD; -- Waits until reaching the last value within the window (max_cycles - min_cycles)
      tracked_value_slv <= change_to_value;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000"; -- Set back to the initial value
    end procedure;

    -------------------------------------
    -- change_value_to_expect_min_to_max_cycles
    -------------------------------------
    -- std_logic version
    procedure change_value_to_expect_min_to_max_cycles(
      constant change_to_value : std_logic -- Value to be changed within the window
    ) is
    begin
      -- Tests all std_logic transitions to change_to_value
      for i in 0 to 7 loop
        if v_std_logic_sequence(i) /= change_to_value then
          change_value_min_to_max_cycles(v_std_logic_sequence(i), change_to_value);
          wait for 4 * C_CLK_PERIOD;
        end if;
      end loop;
    end procedure;

    -- std_logic_vector version
    procedure change_value_to_expect_min_to_max_cycles(
      constant change_to_value : std_logic_vector -- Value to be changed within the window
    ) is
    begin
      -- Tests std_logic_vector transitions to change_to_value
      for i in 0 to 7 loop
        if v_std_logic_vector_sequence(i) /= change_to_value then
          change_value_min_to_max_cycles(v_std_logic_vector_sequence(i), change_to_value);
          wait for 4 * C_CLK_PERIOD;
        end if;
      end loop;
    end procedure;

    -------------------------------------
    -- change_value_to_not_expect_min_to_max_cycles
    -------------------------------------
    -- std_logic version
    procedure change_value_to_not_expect_min_to_max_cycles(
      constant exp_value : std_logic -- Value to be expected
    ) is
    begin
      -- Tests all std_logic transitions, excluding to exp_value
      for i in 0 to 7 loop
        if v_std_logic_sequence(i) /= exp_value then
          change_value_to_expect_min_to_max_cycles(v_std_logic_sequence(i));
        end if;
      end loop;
    end procedure;

    -- std_logic_vector version
    procedure change_value_to_not_expect_min_to_max_cycles(
      constant exp_value : std_logic_vector -- Value to be expected
    ) is
    begin
      -- Tests std_logic_vector transitions, excluding to exp_value
      for i in 0 to 7 loop
        if v_std_logic_vector_sequence(i) /= exp_value then
          change_value_to_expect_min_to_max_cycles(v_std_logic_vector_sequence(i));
        end if;
      end loop;
    end procedure;

    -------------------------------------
    -- change_value_to_all_min_to_max_cycles
    -------------------------------------
    procedure change_value_to_all_min_to_max_cycles is
    begin
      -- Tests all transitions between the elements in the test sequence
      for i in 0 to 7 loop
        for j in 0 to 7 loop
          if i /= j then
            -- Performs signal transitions based on the active enable signal
            if sl_ena = '1' then
              change_value_min_to_max_cycles(v_std_logic_sequence(i), v_std_logic_sequence(j));
            elsif slv_ena = '1' then
              change_value_min_to_max_cycles(v_std_logic_vector_sequence(i), v_std_logic_vector_sequence(j));
            end if;
            wait for 4 * C_CLK_PERIOD;
          end if;
        end loop;
      end loop;
    end procedure;

    --============================================================================
    -- End-trigger bound window assertions procedures
    --============================================================================
    -------------------------------------
    -- hold_start_to_end_trigger
    -------------------------------------
    -- std_logic version
    procedure hold_start_to_end_trigger(
      constant hold_value : std_logic; -- Value to be held between start trigger and end trigger
      constant hold_time  : integer    -- Hold time in the number of clock cycles
    ) is
    begin
      log(ID_SEQUENCER, "Hold '" & to_string(hold_value) & "' from 0-cycle to " & to_string(hold_time) & "-cycles");
      start_trigger <= '1', '0' after C_CLK_PERIOD;
      tracked_value_sl <= hold_value;
      -- Waits for the hold time if it is higher than 0
      if hold_time /= 0 then
        wait for hold_time * C_CLK_PERIOD;
      end if;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0'; -- Set back to the initial value
    end procedure;

    -- std_logic_vector version
    procedure hold_start_to_end_trigger(
      constant hold_value : std_logic_vector; -- Value to be held between start trigger and end trigger
      constant hold_time  : integer           -- Hold time in the number of clock cycles
    ) is
    begin
      log(ID_SEQUENCER, "Hold """ & to_string(hold_value) & """ from 0-cycle to " & to_string(hold_time) & "-cycles");
      start_trigger <= '1', '0' after C_CLK_PERIOD;
      tracked_value_slv <= hold_value;
      -- Waits for the hold time if it is higher than 0
      if hold_time /= 0 then
        wait for hold_time * C_CLK_PERIOD;
      end if;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000"; -- Set back to the initial value
    end procedure;

    procedure hold_start_to_end_trigger_all_values(
      constant hold_time  : integer -- Hold time in the number of clock cycles
    ) is
    begin
      -- Tests all values stored in the test sequence
      for i in 0 to 7 loop
        -- Holds a value in the test sequence based on the active enable signal
        if sl_ena = '1' then
          hold_start_to_end_trigger(v_std_logic_sequence(i), hold_time);
        elsif slv_ena = '1' then
          hold_start_to_end_trigger(v_std_logic_vector_sequence(i), hold_time);
        end if;
        wait for 4 * C_CLK_PERIOD;
      end loop;
    end procedure;

    -------------------------------------
    -- test_triggering_assert_value_from_start_to_end_trigger
    -------------------------------------
    -- std_logic version
    procedure test_triggering_assert_value_from_start_to_end_trigger(
      constant bit_width : integer
    ) is
      variable v_window   : integer := bit_width + 1; -- test window
      variable v_sequence : std_logic_vector(bit_width downto 0) := (others => '0'); -- test sequence
    begin
      log(ID_SEQUENCER, "Testing the window, 0-cycle to " & to_string(bit_width) & "-cycles");

      -- Testing all bit patterns within the window
      for i in 0 to 2 ** v_window - 2 loop -- range = number of all bit patterns - number of legal bit pattern (all 1's)
        log(ID_SEQUENCER, "Bit pattern: " & to_string(std_logic_vector(to_unsigned(i, v_window))));
        start_trigger <= '1', '0' after C_CLK_PERIOD;

        -- Creates the test sequence
        v_sequence := std_logic_vector(to_unsigned(i, v_window));

        -- Assigns the test sequence to tracked_value, bit by bit
        for j in 1 to v_window loop
          tracked_value_sl <= v_sequence(v_window - j);
          -- Sets end_trigger at the last bit of the test sequence
          if j = v_window then
            end_trigger <= '1', '0' after C_CLK_PERIOD;
          end if;
          wait for C_CLK_PERIOD;
        end loop;
        tracked_value_sl <= '0'; -- Set back to the initial value
        wait for 4 * C_CLK_PERIOD;
      end loop;
    end procedure;

    -- std_logic_vector version
    procedure test_triggering_assert_value_from_start_to_end_trigger(
      constant triggering_value : std_logic_vector; -- Value that triggers assertion
      constant exp_value        : std_logic_vector  -- Value to be expected
    ) is
      variable v_sequence : t_sequence := (others => exp_value); -- test sequence
    begin
      -- Testing triggering assert in each cycle
      for i in 0 to v_sequence'length - 1 loop
        start_trigger <= '1', '0' after C_CLK_PERIOD;

        -- Sets triggering_value to the test sequence
        v_sequence(i) := triggering_value;

        -- Assigns the test sequence to tracked_value, std_logic_vector by std_logic_vector
        for j in 0 to v_sequence'length - 1 loop
          tracked_value_slv <= v_sequence(j);
          -- Sets end_trigger at the last std_logic_vector of the test sequence
          if j = v_sequence'length - 1 then
            end_trigger <= '1', '0' after C_CLK_PERIOD;
          end if;
          wait for C_CLK_PERIOD;
        end loop;
        v_sequence(i) := exp_value;  -- Set back the test sequence to the expected value
        tracked_value_slv <= "0000"; -- Set back tracked_value to the initial value
        wait for 4 * C_CLK_PERIOD;
      end loop;
    end procedure;

    -------------------------------------
    -- change_value_start_end_trigger
    -------------------------------------
    -- std_logic version
    procedure change_value_start_end_trigger(
      constant change_from_value : std_logic; -- Value to be changed from
      constant change_to_value   : std_logic; -- Value to be changed to
      constant change_time       : integer    -- Time (in clock cycles) at which tracked_value changes after start_trigger
    ) is
    begin
      log(ID_SEQUENCER, "Change the value from '" & to_string(change_from_value) & "' to '" & to_string(change_to_value) & "', window (0-cycle to " & to_string(change_time) & "-cycles)");
      start_trigger <= '1', '0' after C_CLK_PERIOD;
      tracked_value_sl <= change_from_value;
      wait for change_time * C_CLK_PERIOD; -- Waits for change_time
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      tracked_value_sl <= change_to_value; -- Change the value at the last bit of the sequence
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0'; -- Set back to the initial value
    end procedure;

    -- std_logic_vector version
    procedure change_value_start_end_trigger(
      constant change_from_value : std_logic_vector; -- Value to be changed from
      constant change_to_value   : std_logic_vector; -- Value to be changed to
      constant change_time       : integer           -- Time (in clock cycles) at which tracked_value changes after start_trigger
    ) is
    begin
      log(ID_SEQUENCER, "Change the value from """ & to_string(change_from_value) & """ to """ & to_string(change_to_value) & """, window (0-cycle to " & to_string(change_time) & "-cycles)");
      start_trigger <= '1', '0' after C_CLK_PERIOD;
      tracked_value_slv <= change_from_value;
      wait for change_time * C_CLK_PERIOD; -- Waits for change_time
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      tracked_value_slv <= change_to_value; -- Change the value at the last std_logic_vector of the sequence
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000"; -- Set back to the initial value
    end procedure;

    -------------------------------------
    -- change_value_to_expect_start_end_trigger
    -------------------------------------
    -- std_logic version
    procedure change_value_to_expect_start_end_trigger(
      constant change_to_value : std_logic; -- Value to be changed within the window
      constant change_time     : integer    -- Time (in clock cycles) at which tracked_value changes after start_trigger
    ) is
    begin
      -- Tests all std_logic transitions to change_to_value
      for i in 0 to 7 loop
        if v_std_logic_sequence(i) /= change_to_value then
          change_value_start_end_trigger(v_std_logic_sequence(i), change_to_value, change_time);
          wait for 4 * C_CLK_PERIOD;
        end if;
      end loop;
    end procedure;

    -- std_logic_vector version
    procedure change_value_to_expect_start_end_trigger(
      constant change_to_value : std_logic_vector; -- Value to be changed within the window
      constant change_time     : integer           -- Time (in clock cycles) at which tracked_value changes after start_trigger
    ) is
    begin
      -- Tests std_logic_vector transitions to change_to_value
      for i in 0 to 7 loop
        if v_std_logic_vector_sequence(i) /= change_to_value then
          change_value_start_end_trigger(v_std_logic_vector_sequence(i), change_to_value, change_time);
          wait for 4 * C_CLK_PERIOD;
        end if;
      end loop;
    end procedure;

    -------------------------------------
    -- change_value_to_not_expect_start_end_trigger
    -------------------------------------
    -- std_logic version
    procedure change_value_to_not_expect_start_end_trigger(
      constant exp_value   : std_logic; -- Value to be expected
      constant change_time : integer    -- Time (in clock cycles) at which tracked_value changes after start_trigger
    ) is
    begin
      -- Tests all std_logic transitions, excluding to exp_value
      for i in 0 to 7 loop
        if v_std_logic_sequence(i) /= exp_value then
          change_value_to_expect_start_end_trigger(v_std_logic_sequence(i), change_time);
        end if;
      end loop;
    end procedure;

    -- std_logic_vector version
    procedure change_value_to_not_expect_start_end_trigger(
      constant exp_value   : std_logic_vector; -- Value to be expected
      constant change_time : integer           -- Time (in clock cycles) at which tracked_value changes after start_trigger
    ) is
    begin
      -- Tests std_logic_vector transitions, excluding to exp_value
      for i in 0 to 7 loop
        if v_std_logic_vector_sequence(i) /= exp_value then
          change_value_to_expect_start_end_trigger(v_std_logic_vector_sequence(i), change_time);
        end if;
      end loop;
    end procedure;

    -------------------------------------
    -- change_value_to_all_start_end_trigger
    -------------------------------------
    procedure change_value_to_all_start_end_trigger(
      constant change_time : integer -- Time (in clock cycles) at which tracked_value changes after start_trigger
    ) is
    begin
      -- Tests all transitions between the elements in the test sequence
      for i in 0 to 7 loop
        for j in 0 to 7 loop
          if i /= j then
            -- Performs signal transitions based on the active enable signal
            if sl_ena = '1' then
              change_value_start_end_trigger(v_std_logic_sequence(i), v_std_logic_sequence(j), change_time);
            elsif slv_ena = '1' then
              change_value_start_end_trigger(v_std_logic_vector_sequence(i), v_std_logic_vector_sequence(j), change_time);
            end if;
            wait for 4 * C_CLK_PERIOD;
          end if;
        end loop;
      end loop;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR_LARGE);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_UVVM_ASSERTION);

    -- start clock
    clk_ena <= true;
    wait for 10 * C_CLK_PERIOD;
    wait until rising_edge(clk);

    log(ID_LOG_HDR_LARGE, "Testing the assertion: " & GC_TESTCASE, C_SCOPE);
    --============================================================================================================================
    if GC_TESTCASE = "assert_value" then
    --============================================================================================================================
      -------------------------------------
      -- #region assert_value testcases
      -------------------------------------
      -------------------------------------
      -- assert_value (boolean)
      -------------------------------------
      bool_ena <= '0';
      tracked_value_bool <= false;
      exp_value_bool <= false;
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (boolean)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = true, exp_value = true");
      tracked_value_bool <= true;
      exp_value_bool <= true;
      wait for C_CLK_PERIOD;
      bool_ena <= '1';
      wait for C_CLK_PERIOD;
      bool_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = false, exp_value = false");
      tracked_value_bool <= false;
      exp_value_bool <= false;
      wait for C_CLK_PERIOD;
      bool_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (boolean)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = true, exp_value = false, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_bool <= not exp_value_bool;
      wait for C_CLK_PERIOD;
      tracked_value_bool <= exp_value_bool;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = false, exp_value = true, expecting alert");
      bool_ena <= '0';
      exp_value_bool <= not tracked_value_bool;
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      bool_ena <= '1';
      wait for C_CLK_PERIOD;
      bool_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (boolean)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      bool_ena <= '0';
      tracked_value_bool <= exp_value_bool;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      bool_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      bool_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      exp_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""1111""");
      tracked_value_slv <= "1111";
      exp_value_slv <= "1111";
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for C_CLK_PERIOD;
      slv_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""LHXZ"", exp_value = ""LHXZ""");
      tracked_value_slv <= "LHXZ";
      exp_value_slv <= "LHXZ";
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for C_CLK_PERIOD;
      slv_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""0000""");
      tracked_value_slv <= "0000";
      exp_value_slv <= "0000";
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= not exp_value_slv;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= exp_value_slv;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""1111"", expecting alert");
      slv_ena <= '0';
      exp_value_slv <= not tracked_value_slv;
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      slv_ena <= '1';
      wait for C_CLK_PERIOD;
      slv_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      slv_ena <= '0';
      tracked_value_slv <= exp_value_slv;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (t_slv_array)
      -------------------------------------
      slv_array_ena <= '0';
      tracked_value_slv_array <= (others => (others => '0'));
      exp_value_slv_array <= (others => (others => '0'));
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (t_slv_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""1111"", ""1111"")");
      tracked_value_slv_array <= (others => (others => '1'));
      exp_value_slv_array <= (others => (others => '1'));
      wait for C_CLK_PERIOD;
      slv_array_ena <= '1';
      wait for C_CLK_PERIOD;
      slv_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""UX01"", ""ZWLH""), exp_value = (""UX01"", ""ZWLH"")");
      tracked_value_slv_array <= ("UX01", "ZWLH");
      exp_value_slv_array <= ("UX01", "ZWLH");
      wait for C_CLK_PERIOD;
      slv_array_ena <= '1';
      wait for C_CLK_PERIOD;
      slv_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""0000"", ""0000"")");
      tracked_value_slv_array <= (others => (others => '0'));
      exp_value_slv_array <= (others => (others => '0'));
      wait for C_CLK_PERIOD;
      slv_array_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (t_slv_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""0000"", ""0000"")");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv_array <= (others => (others => '1'));
      wait for C_CLK_PERIOD;
      tracked_value_slv_array <= (others => (others => '0'));
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""1111"", ""1111"")");
      slv_array_ena <= '0';
      exp_value_slv_array <= (others => (others => '1'));
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      slv_array_ena <= '1';
      wait for C_CLK_PERIOD;
      slv_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (t_slv_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      slv_array_ena <= '0';
      tracked_value_slv_array <= (others => (others => '1'));
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      slv_array_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      slv_array_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (t_unsigned_array)
      -------------------------------------
      unsigned_array_ena <= '0';
      tracked_value_unsigned_array <= (others => (others => '0'));
      exp_value_unsigned_array <= (others => (others => '0'));
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (t_unsigned_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""1111"", ""1111"")");
      tracked_value_unsigned_array <= ("1111", "1111");
      exp_value_unsigned_array <= ("1111", "1111");
      wait for C_CLK_PERIOD;
      unsigned_array_ena <= '1';
      wait for C_CLK_PERIOD;
      unsigned_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""1010"", ""1010""), exp_value = (""1010"", ""1010"")");
      tracked_value_unsigned_array <= ("1010", "1010");
      exp_value_unsigned_array <= ("1010", "1010");
      wait for C_CLK_PERIOD;
      unsigned_array_ena <= '1';
      wait for C_CLK_PERIOD;
      unsigned_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""0000"", ""0000"")");
      tracked_value_unsigned_array <= (others => (others => '0'));
      exp_value_unsigned_array <= (others => (others => '0'));
      wait for C_CLK_PERIOD;
      unsigned_array_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (t_unsigned_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""0000"", ""0000"")");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned_array <= (others => (others => '1'));
      wait for C_CLK_PERIOD;
      tracked_value_unsigned_array <= (others => (others => '0'));
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""1111"", ""1111"")");
      unsigned_array_ena <= '0';
      exp_value_unsigned_array <= (others => (others => '1'));
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      unsigned_array_ena <= '1';
      wait for C_CLK_PERIOD;
      unsigned_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (t_unsigned_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      unsigned_array_ena <= '0';
      tracked_value_unsigned_array <= (others => (others => '1'));
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      unsigned_array_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      unsigned_array_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (t_signed_array)
      -------------------------------------
      signed_array_ena <= '0';
      tracked_value_signed_array <= (others => (others => '0'));
      exp_value_signed_array <= (others => (others => '0'));
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (t_signed_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""1111"", ""1111"")");
      tracked_value_signed_array <= ("1111", "1111");
      exp_value_signed_array <= ("1111", "1111");
      wait for C_CLK_PERIOD;
      signed_array_ena <= '1';
      wait for C_CLK_PERIOD;
      signed_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""1101"", ""0011""), exp_value = (""1101"", ""0011"")");
      tracked_value_signed_array <= ("1101", "0011");
      exp_value_signed_array <= ("1101", "0011");
      wait for C_CLK_PERIOD;
      signed_array_ena <= '1';
      wait for C_CLK_PERIOD;
      signed_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""0000"", ""0000"")");
      tracked_value_signed_array <= (others => (others => '0'));
      exp_value_signed_array <= (others => (others => '0'));
      wait for C_CLK_PERIOD;
      signed_array_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (t_signed_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""0000"", ""0000"")");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed_array <= (others => (others => '1'));
      wait for C_CLK_PERIOD;
      tracked_value_signed_array <= (others => (others => '0'));
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""1111"", ""1111"")");
      signed_array_ena <= '0';
      exp_value_signed_array <= (others => (others => '1'));
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      signed_array_ena <= '1';
      wait for C_CLK_PERIOD;
      signed_array_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (t_signed_array)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      signed_array_ena <= '0';
      tracked_value_signed_array <= (others => (others => '1'));
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      signed_array_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      signed_array_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (unsigned)
      -------------------------------------
      unsigned_ena <= '0';
      tracked_value_unsigned <= "0000";
      exp_value_unsigned <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (unsigned)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""1111""");
      tracked_value_unsigned <= "1111";
      exp_value_unsigned <= "1111";
      wait for C_CLK_PERIOD;
      unsigned_ena <= '1';
      wait for C_CLK_PERIOD;
      unsigned_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1010"", exp_value = ""1010""");
      tracked_value_unsigned <= "1010";
      exp_value_unsigned <= "1010";
      wait for C_CLK_PERIOD;
      unsigned_ena <= '1';
      wait for C_CLK_PERIOD;
      unsigned_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""0000""");
      tracked_value_unsigned <= "0000";
      exp_value_unsigned <= "0000";
      wait for C_CLK_PERIOD;
      unsigned_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (unsigned)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= not exp_value_unsigned;
      wait for C_CLK_PERIOD;
      tracked_value_unsigned <= exp_value_unsigned;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""1111"", expecting alert");
      unsigned_ena <= '0';
      exp_value_unsigned <= not tracked_value_unsigned;
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      unsigned_ena <= '1';
      wait for C_CLK_PERIOD;
      unsigned_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (unsigned)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      unsigned_ena <= '0';
      tracked_value_unsigned <= exp_value_unsigned;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      unsigned_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      unsigned_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (signed)
      -------------------------------------
      signed_ena <= '0';
      tracked_value_signed <= "0000";
      exp_value_signed <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (signed)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""1111""");
      tracked_value_signed <= "1111";
      exp_value_signed <= "1111";
      wait for C_CLK_PERIOD;
      signed_ena <= '1';
      wait for C_CLK_PERIOD;
      signed_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0011"", exp_value = ""0011""");
      tracked_value_signed <= "0011";
      exp_value_signed <= "0011";
      wait for C_CLK_PERIOD;
      signed_ena <= '1';
      wait for C_CLK_PERIOD;
      signed_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""0000""");
      tracked_value_signed <= "0000";
      exp_value_signed <= "0000";
      wait for C_CLK_PERIOD;
      signed_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (signed)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= not exp_value_signed;
      wait for C_CLK_PERIOD;
      tracked_value_signed <= exp_value_signed;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""1111"", expecting alert");
      signed_ena <= '0';
      exp_value_signed <= not tracked_value_signed;
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      signed_ena <= '1';
      wait for C_CLK_PERIOD;
      signed_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (signed)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      signed_ena <= '0';
      tracked_value_signed <= exp_value_signed;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      signed_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      signed_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (integer)
      -------------------------------------
      int_ena <= '0';
      tracked_value_int <= 0;
      exp_value_int <= 0;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1, exp_value = 1");
      tracked_value_int <= 1;
      exp_value_int <= 1;
      wait for C_CLK_PERIOD;
      int_ena <= '1';
      wait for C_CLK_PERIOD;
      int_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 1234, exp_value = 1234");
      tracked_value_int <= 1234;
      exp_value_int <= 1234;
      wait for C_CLK_PERIOD;
      int_ena <= '1';
      wait for C_CLK_PERIOD;
      int_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = '0', exp_value = '0'");
      tracked_value_int <= 0;
      exp_value_int <= 0;
      wait for C_CLK_PERIOD;
      int_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1, exp_value = 0, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= 1;
      wait for C_CLK_PERIOD;
      tracked_value_int <= 0;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 0, exp_value = 1, expecting alert");
      int_ena <= '0';
      exp_value_int <= 1;
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      int_ena <= '1';
      wait for C_CLK_PERIOD;
      int_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      int_ena <= '0';
      tracked_value_int <= 1;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      int_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      int_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (real)
      -------------------------------------
      real_ena <= '0';
      tracked_value_real <= 0.0;
      exp_value_real <= 0.0;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (real)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1.0, exp_value = 1.0");
      tracked_value_real <= 1.0;
      exp_value_real <= 1.0;
      wait for C_CLK_PERIOD;
      real_ena <= '1';
      wait for C_CLK_PERIOD;
      real_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 1.01, exp_value = 1.01");
      tracked_value_real <= 1.01;
      exp_value_real <= 1.01;
      wait for C_CLK_PERIOD;
      real_ena <= '1';
      wait for C_CLK_PERIOD;
      real_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = '0.0', exp_value = '0.0'");
      tracked_value_real <= 0.0;
      exp_value_real <= 0.0;
      wait for C_CLK_PERIOD;
      real_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (real)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1.0, exp_value = 0.0, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= 1.0;
      wait for C_CLK_PERIOD;
      tracked_value_real <= 0.0;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 0.0, exp_value = 1.0, expecting alert");
      real_ena <= '0';
      exp_value_real <= 1.0;
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      real_ena <= '1';
      wait for C_CLK_PERIOD;
      real_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (real)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      real_ena <= '0';
      tracked_value_real <= 1.0;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      real_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      real_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (time)
      -------------------------------------
      time_ena <= '0';
      tracked_value_time <= 0 ns;
      exp_value_time <= 0 ns;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (time)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1 ns, exp_value = 1 ns");
      tracked_value_time <= 1 ns;
      exp_value_time <= 1 ns;
      wait for C_CLK_PERIOD;
      time_ena <= '1';
      wait for C_CLK_PERIOD;
      time_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 1 us, exp_value = 1 us");
      tracked_value_time <= 1 us;
      exp_value_time <= 1 us;
      wait for C_CLK_PERIOD;
      time_ena <= '1';
      wait for C_CLK_PERIOD;
      time_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 0 ns, exp_value = 0 ns");
      tracked_value_time <= 0 ns;
      exp_value_time <= 0 ns;
      wait for C_CLK_PERIOD;
      time_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (time)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1 ns, exp_value = 0 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= 1 ns;
      wait for C_CLK_PERIOD;
      tracked_value_time <= 0 ns;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 0 ns, exp_value = 1 ns, expecting alert");
      time_ena <= '0';
      exp_value_time <= 1 ns;
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      time_ena <= '1';
      wait for C_CLK_PERIOD;
      time_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (time)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      time_ena <= '0';
      tracked_value_time <= 1 ns;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      time_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      time_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      exp_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = '1', exp_value = '1'");
      tracked_value_sl <= '1';
      exp_value_sl <= '1';
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 'X', exp_value = 'X'");
      tracked_value_sl <= 'X';
      exp_value_sl <= 'X';
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = '0', exp_value = '0'");
      tracked_value_sl <= '0';
      exp_value_sl <= '0';
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = '1', exp_value = '0', expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_sl <= not exp_value_sl;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= exp_value_sl;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = '0', exp_value = '1', expecting alert");
      sl_ena <= '0';
      exp_value_sl <= not tracked_value_sl;
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      sl_ena <= '1';
      wait for C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      sl_ena <= '0';
      tracked_value_sl <= exp_value_sl;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as tracked_value and exp_value are assigned, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      sl_ena <= '1';
      tracked_value_sl <= '0';
      exp_value_sl <= '0';
      wait for C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to tracked_value and exp_value, expecting alert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_sl <= '1';
      exp_value_sl <= '1';
      wait for C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_sl <= not exp_value_sl;
      wait for 4 * C_CLK_PERIOD;
      -------------------------------------
      -- #endregion assert_value testcases
      -------------------------------------

      -------------------------------------
      -- #region assert_value non-clocked testcases
      -------------------------------------
      -------------------------------------
      -- assert_value (boolean non-clocked)
      -------------------------------------
      bool_non_clocked_ena <= '0';
      tracked_value_bool <= false;
      exp_value_bool <= false;
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (boolean non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = true, exp_value = true");
      tracked_value_bool <= true;
      exp_value_bool <= true;
      wait for v_rand.rand(ONLY, v_time_vector);
      bool_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      bool_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = false, exp_value = false");
      tracked_value_bool <= false;
      exp_value_bool <= false;
      wait for v_rand.rand(ONLY, v_time_vector);
      bool_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (boolean non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = true, exp_value = false, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_bool <= not exp_value_bool;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_bool <= exp_value_bool;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = false, exp_value = true, expecting alert");
      bool_non_clocked_ena <= '0';
      exp_value_bool <= not tracked_value_bool;
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      bool_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      bool_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (boolean non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      bool_non_clocked_ena <= '0';
      tracked_value_bool <= exp_value_bool;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      bool_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_bool <= not tracked_value_bool;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_bool <= not tracked_value_bool;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      bool_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (std_logic_vector non-clocked)
      -------------------------------------
      slv_non_clocked_ena <= '0';
      tracked_value_slv <= "0000";
      exp_value_slv <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector non-clocked )");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""1111""");
      tracked_value_slv <= "1111";
      exp_value_slv <= "1111";
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""LHXZ"", exp_value = ""LHXZ""");
      tracked_value_slv <= "LHXZ";
      exp_value_slv <= "LHXZ";
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""0000""");
      tracked_value_slv <= "0000";
      exp_value_slv <= "0000";
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector non-clocked )");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= not exp_value_slv;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_slv <= exp_value_slv;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""1111"", expecting alert");
      slv_non_clocked_ena <= '0';
      exp_value_slv <= not tracked_value_slv;
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      slv_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      slv_non_clocked_ena <= '0';
      tracked_value_slv <= exp_value_slv;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_slv <= not tracked_value_slv;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_slv <= not tracked_value_slv;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      slv_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (t_slv_array non-clocked )
      -------------------------------------
      slv_array_non_clocked_ena <= '0';
      tracked_value_slv_array <= (others => (others => '0'));
      exp_value_slv_array <= (others => (others => '0'));
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (t_slv_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""1111"", ""1111"")");
      tracked_value_slv_array <= (others => (others => '1'));
      exp_value_slv_array <= (others => (others => '1'));
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""UX01"", ""ZWLH""), exp_value = (""UX01"", ""ZWLH"")");
      tracked_value_slv_array <= ("UX01", "ZWLH");
      exp_value_slv_array <= ("UX01", "ZWLH");
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""0000"", ""0000"")");
      tracked_value_slv_array <= (others => (others => '0'));
      exp_value_slv_array <= (others => (others => '0'));
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_array_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (t_slv_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""0000"", ""0000"")");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv_array <= (others => (others => '1'));
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_slv_array <= (others => (others => '0'));
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""1111"", ""1111"")");
      slv_array_non_clocked_ena <= '0';
      exp_value_slv_array <= (others => (others => '1'));
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      slv_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (t_slv_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      slv_array_non_clocked_ena <= '0';
      tracked_value_slv_array <= (others => (others => '1'));
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_array_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_slv_array <= (others => (others => '0'));
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_slv_array <= (others => (others => '1'));
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      slv_array_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (t_unsigned_array non-clocked)
      -------------------------------------
      unsigned_array_non_clocked_ena <= '0';
      tracked_value_unsigned_array <= (others => (others => '0'));
      exp_value_unsigned_array <= (others => (others => '0'));
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (t_unsigned_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""1111"", ""1111"")");
      tracked_value_unsigned_array <= ("1111", "1111");
      exp_value_unsigned_array <= ("1111", "1111");
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""1010"", ""1010""), exp_value = (""1010"", ""1010"")");
      tracked_value_unsigned_array <= ("1010", "1010");
      exp_value_unsigned_array <= ("1010", "1010");
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""0000"", ""0000"")");
      tracked_value_unsigned_array <= (others => (others => '0'));
      exp_value_unsigned_array <= (others => (others => '0'));
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_array_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (t_unsigned_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""0000"", ""0000"")");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned_array <= (others => (others => '1'));
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_unsigned_array <= (others => (others => '0'));
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""1111"", ""1111"")");
      unsigned_array_non_clocked_ena <= '0';
      exp_value_unsigned_array <= (others => (others => '1'));
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      unsigned_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (t_unsigned_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      unsigned_array_non_clocked_ena <= '0';
      tracked_value_unsigned_array <= (others => (others => '1'));
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_array_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_unsigned_array <= (others => (others => '0'));
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_unsigned_array <= (others => (others => '1'));
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      unsigned_array_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (t_signed_array non-clocked)
      -------------------------------------
      signed_array_non_clocked_ena <= '0';
      tracked_value_signed_array <= (others => (others => '0'));
      exp_value_signed_array <= (others => (others => '0'));
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (t_signed_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""1111"", ""1111"")");
      tracked_value_signed_array <= ("1111", "1111");
      exp_value_signed_array <= ("1111", "1111");
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""1101"", ""0011""), exp_value = (""1101"", ""0011"")");
      tracked_value_signed_array <= ("1101", "0011");
      exp_value_signed_array <= ("1101", "0011");
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""0000"", ""0000"")");
      tracked_value_signed_array <= (others => (others => '0'));
      exp_value_signed_array <= (others => (others => '0'));
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_array_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (t_signed_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = (""1111"", ""1111""), exp_value = (""0000"", ""0000"")");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed_array <= (others => (others => '1'));
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_signed_array <= (others => (others => '0'));
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = (""0000"", ""0000""), exp_value = (""1111"", ""1111"")");
      signed_array_non_clocked_ena <= '0';
      exp_value_signed_array <= (others => (others => '1'));
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      signed_array_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_array_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (t_signed_array non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      signed_array_non_clocked_ena <= '0';
      tracked_value_signed_array <= (others => (others => '1'));
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_array_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_signed_array <= (others => (others => '0'));
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_signed_array <= (others => (others => '1'));
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      signed_array_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (unsigned non-clocked)
      -------------------------------------
      unsigned_non_clocked_ena <= '0';
      tracked_value_unsigned <= "0000";
      exp_value_unsigned <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (unsigned non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""1111""");
      tracked_value_unsigned <= "1111";
      exp_value_unsigned <= "1111";
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1010"", exp_value = ""1010""");
      tracked_value_unsigned <= "1010";
      exp_value_unsigned <= "1010";
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""0000""");
      tracked_value_unsigned <= "0000";
      exp_value_unsigned <= "0000";
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (unsigned non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= not exp_value_unsigned;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_unsigned <= exp_value_unsigned;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""1111"", expecting alert");
      unsigned_non_clocked_ena <= '0';
      exp_value_unsigned <= not tracked_value_unsigned;
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      unsigned_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (unsigned non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      unsigned_non_clocked_ena <= '0';
      tracked_value_unsigned <= exp_value_unsigned;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_unsigned <= not tracked_value_unsigned;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_unsigned <= not tracked_value_unsigned;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      unsigned_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (signed non-clocked)
      -------------------------------------
      signed_non_clocked_ena <= '0';
      tracked_value_signed <= "0000";
      exp_value_signed <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (signed non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""1111""");
      tracked_value_signed <= "1111";
      exp_value_signed <= "1111";
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0011"", exp_value = ""0011""");
      tracked_value_signed <= "0011";
      exp_value_signed <= "0011";
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""0000""");
      tracked_value_signed <= "0000";
      exp_value_signed <= "0000";
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (signed non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""1111"", exp_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= not exp_value_signed;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_signed <= exp_value_signed;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0000"", exp_value = ""1111"", expecting alert");
      signed_non_clocked_ena <= '0';
      exp_value_signed <= not tracked_value_signed;
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      signed_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (signed non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      signed_non_clocked_ena <= '0';
      tracked_value_signed <= exp_value_signed;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_signed <= not tracked_value_signed;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_signed <= not tracked_value_signed;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      signed_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (integer non-clocked)
      -------------------------------------
      int_non_clocked_ena <= '0';
      tracked_value_int <= 0;
      exp_value_int <= 0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1, exp_value = 1");
      tracked_value_int <= 1;
      exp_value_int <= 1;
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 1234, exp_value = 1234");
      tracked_value_int <= 1234;
      exp_value_int <= 1234;
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = '0', exp_value = '0'");
      tracked_value_int <= 0;
      exp_value_int <= 0;
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1, exp_value = 0, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= 1;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_int <= 0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 0, exp_value = 1, expecting alert");
      int_non_clocked_ena <= '0';
      exp_value_int <= 1;
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      int_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      int_non_clocked_ena <= '0';
      tracked_value_int <= 1;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_int <= 0;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_int <= 1;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      int_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (real non-clocked)
      -------------------------------------
      real_non_clocked_ena <= '0';
      tracked_value_real <= 0.0;
      exp_value_real <= 0.0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (real non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1.0, exp_value = 1.0");
      tracked_value_real <= 1.0;
      exp_value_real <= 1.0;
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 1.01, exp_value = 1.01");
      tracked_value_real <= 1.01;
      exp_value_real <= 1.01;
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = '0.0', exp_value = '0.0'");
      tracked_value_real <= 0.0;
      exp_value_real <= 0.0;
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (real non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1.0, exp_value = 0.0, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= 1.0;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_real <= 0.0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 0.0, exp_value = 1.0, expecting alert");
      real_non_clocked_ena <= '0';
      exp_value_real <= 1.0;
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      real_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (real non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      real_non_clocked_ena <= '0';
      tracked_value_real <= 1.0;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_real <= 0.0;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_real <= 1.0;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      real_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (time non-clocked)
      -------------------------------------
      time_non_clocked_ena <= '0';
      tracked_value_time <= 0 ns;
      exp_value_time <= 0 ns;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (time non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1 ns, exp_value = 1 ns");
      tracked_value_time <= 1 ns;
      exp_value_time <= 1 ns;
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 1 us, exp_value = 1 us");
      tracked_value_time <= 1 us;
      exp_value_time <= 1 us;
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 0 ns, exp_value = 0 ns");
      tracked_value_time <= 0 ns;
      exp_value_time <= 0 ns;
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (time non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1 ns, exp_value = 0 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= 1 ns;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_time <= 0 ns;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 0 ns, exp_value = 1 ns, expecting alert");
      time_non_clocked_ena <= '0';
      exp_value_time <= 1 ns;
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      time_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (time non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      time_non_clocked_ena <= '0';
      tracked_value_time <= 1 ns;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_time <= 0 ns;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_time <= 1 ns;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      time_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value (std_logic non-clocked)
      -------------------------------------
      sl_non_clocked_ena <= '0';
      tracked_value_sl <= '0';
      exp_value_sl <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = '1', exp_value = '1'");
      tracked_value_sl <= '1';
      exp_value_sl <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 'X', exp_value = 'X'");
      tracked_value_sl <= 'X';
      exp_value_sl <= 'X';
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = '0', exp_value = '0'");
      tracked_value_sl <= '0';
      exp_value_sl <= '0';
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = '1', exp_value = '0', expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_sl <= not exp_value_sl;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_sl <= exp_value_sl;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = '0', exp_value = '1', expecting alert");
      sl_non_clocked_ena <= '0';
      exp_value_sl <= not tracked_value_sl;
      wait for v_rand.rand(ONLY, v_time_vector);
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      sl_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to exp_value");
      sl_non_clocked_ena <= '0';
      tracked_value_sl <= exp_value_sl;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        tracked_value_sl <= not tracked_value_sl;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_sl <= not tracked_value_sl;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      sl_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as tracked_value and exp_value are assigned, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      sl_non_clocked_ena <= '1';
      tracked_value_sl <= '1';
      exp_value_sl <= '0';
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);
      -------------------------------------
      -- #endregion assert_value non-clocked testcases
      -------------------------------------
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_one_of" then
    --============================================================================================================================
      -------------------------------------
      -- #region assert_one_of testcases
      -------------------------------------
      -------------------------------------
      -- assert_one_of (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      allowed_values_slv_array <= ("0000", "1111");
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (""0000"", ""1111"")");
      log(ID_SEQUENCER, "tracked_value = ""0000""");
      slv_ena <= '1';
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1111""");
      tracked_value_slv <= "1111";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""0001"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "0001";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1110"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "1110";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1111";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "allowed_values = (""LLLL"", ""HHHH"")");
      slv_ena <= '0';
      tracked_value_slv <= "LLLL";
      allowed_values_slv_array <= ("LLLL", "HHHH");
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""LLLH"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "LLLH";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "LLLL";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""HHHL"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "HHHL";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "HHHH";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      allowed_values_slv_array <= ("0000", "1111");
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_one_of (unsigned)
      -------------------------------------
      unsigned_ena <= '0';
      tracked_value_unsigned <= "0000";
      allowed_values_unsigned_array <= ("0000", "1111");
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (unsigned)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (""0000"", ""1111"")");
      log(ID_SEQUENCER, "tracked_value = ""0000""");
      unsigned_ena <= '1';
      tracked_value_unsigned <= "0000";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1111""");
      tracked_value_unsigned <= "1111";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (unsigned)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""0001"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= "0001";
      wait for C_CLK_PERIOD;
      tracked_value_unsigned <= "0000";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1110"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= "1110";
      wait for C_CLK_PERIOD;
      tracked_value_unsigned <= "1111";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "allowed_values = (""0101"", ""1010"")");
      unsigned_ena <= '0';
      tracked_value_unsigned <= "0101";
      allowed_values_unsigned_array <= ("0101", "1010");
      wait for C_CLK_PERIOD;
      unsigned_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= "0000";
      wait for C_CLK_PERIOD;
      tracked_value_unsigned <= "0101";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1111"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= "1111";
      wait for C_CLK_PERIOD;
      tracked_value_unsigned <= "1010";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (unsigned)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      unsigned_ena <= '0';
      tracked_value_unsigned <= "0000";
      allowed_values_unsigned_array <= ("0000", "1111");
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      unsigned_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      unsigned_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_one_of (signed)
      -------------------------------------
      signed_ena <= '0';
      tracked_value_signed <= "0000";
      allowed_values_signed_array <= ("0000", "1111");
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (signed)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (""0000"", ""1111"")");
      log(ID_SEQUENCER, "tracked_value = ""0000""");
      signed_ena <= '1';
      tracked_value_signed <= "0000";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1111""");
      tracked_value_signed <= "1111";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (signed)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""0001"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= "0001";
      wait for C_CLK_PERIOD;
      tracked_value_signed <= "0000";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1110"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= "1110";
      wait for C_CLK_PERIOD;
      tracked_value_signed <= "1111";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "allowed_values = (""0101"", ""1010"")");
      signed_ena <= '0';
      tracked_value_signed <= "0101";
      allowed_values_signed_array <= ("0101", "1010");
      wait for C_CLK_PERIOD;
      signed_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= "0000";
      wait for C_CLK_PERIOD;
      tracked_value_signed <= "0101";
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = ""1111"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= "1111";
      wait for C_CLK_PERIOD;
      tracked_value_signed <= "1010";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (signed)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      signed_ena <= '0';
      tracked_value_signed <= "0000";
      allowed_values_signed_array <= ("0000", "1111");
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      signed_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      signed_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_one_of (integer)
      -------------------------------------
      int_ena <= '0';
      tracked_value_int <= 0;
      allowed_values_int_array <= (0, 1);
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (0, 1)");
      log(ID_SEQUENCER, "tracked_value = 0");
      int_ena <= '1';
      tracked_value_int <= 0;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 1");
      tracked_value_int <= 1;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 10, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= 10;
      wait for C_CLK_PERIOD;
      tracked_value_int <= 0;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = -10, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= -10;
      wait for C_CLK_PERIOD;
      tracked_value_int <= 0;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "allowed_values = (-2147483647, 2147483647)");
      int_ena <= '0';
      tracked_value_int <= -2147483647;
      allowed_values_int_array <= (-2147483647, 2147483647);
      wait for C_CLK_PERIOD;
      int_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = -2147483646, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= -2147483646;
      wait for C_CLK_PERIOD;
      tracked_value_int <= -2147483647;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 2147483646, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= 2147483646;
      wait for C_CLK_PERIOD;
      tracked_value_int <= 2147483647;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      int_ena <= '0';
      tracked_value_int <= 0;
      allowed_values_int_array <= (0, 1);
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      int_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      int_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_one_of (real)
      -------------------------------------
      real_ena <= '0';
      tracked_value_real <= 0.0;
      allowed_values_real_array <= (0.0, 1.0);
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (real)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (0.0, 1.0)");
      log(ID_SEQUENCER, "tracked_value = 0.0");
      real_ena <= '1';
      tracked_value_real <= 0.0;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 1.0");
      tracked_value_real <= 1.0;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (real)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1.1, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= 1.1;
      wait for C_CLK_PERIOD;
      tracked_value_real <= 0.0;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = -1.1, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= -1.1;
      wait for C_CLK_PERIOD;
      tracked_value_real <= 0.0;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "allowed_values = (-1.7976931348623157e307, 1.7976931348623157e307)");
      real_ena <= '0';
      tracked_value_real <= -1.7976931348623157e307;
      allowed_values_real_array <= (-1.7976931348623157e307, 1.7976931348623157e307);
      wait for C_CLK_PERIOD;
      real_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = -1.7976931348623157e306, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= -1.7976931348623157e306;
      wait for C_CLK_PERIOD;
      tracked_value_real <= -1.7976931348623157e307;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 1.7976931348623157e306, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= 1.7976931348623157e306;
      wait for C_CLK_PERIOD;
      tracked_value_real <= 1.7976931348623157e307;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (real)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      real_ena <= '0';
      tracked_value_real <= 0.0;
      allowed_values_real_array <= (0.0, 1.0);
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      real_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      real_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_one_of (time)
      -------------------------------------
      time_ena <= '0';
      tracked_value_time <= 0 ns;
      allowed_values_time_array <= (0 ns, 1 ns);
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (time)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (0 ns, 1 ns)");
      log(ID_SEQUENCER, "tracked_value = 0 ns");
      time_ena <= '1';
      tracked_value_time <= 0 ns;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 1 ns");
      tracked_value_time <= 1 ns;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (time)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 2 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= 2 ns;
      wait for C_CLK_PERIOD;
      tracked_value_time <= 0 ns;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = -2 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= -2 ns;
      wait for C_CLK_PERIOD;
      tracked_value_time <= 0 ns;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "allowed_values = (-2147483647 ns, 2147483647 ns)");
      time_ena <= '0';
      tracked_value_time <= -2147483647 ns;
      allowed_values_time_array <= (-2147483647 ns, 2147483647 ns);
      wait for C_CLK_PERIOD;
      time_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = -2147483646 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= -2147483646 ns;
      wait for C_CLK_PERIOD;
      tracked_value_time <= -2147483647 ns;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = 2147483646 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= 2147483646 ns;
      wait for C_CLK_PERIOD;
      tracked_value_time <= 2147483647 ns;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (time)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      time_ena <= '0';
      tracked_value_time <= 0 ns;
      allowed_values_time_array <= (0 ns, 1 ns);
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      time_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      time_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_one_of (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      allowed_values_slv <= "01";
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = ('0', '1')");
      log(ID_SEQUENCER, "tracked_value = '0'");
      sl_ena <= '1';
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "tracked_value = '1'");
      tracked_value_sl <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      test_triggering_assert_one_of(CLOCKED);

      log(ID_SEQUENCER, "allowed_values = ('0', 'L')");
      sl_ena <= '0';
      allowed_values_slv <= "0L";
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      test_triggering_assert_one_of(CLOCKED);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      sl_ena <= '0';
      allowed_values_slv <= "01";
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as tracked_value is assigned, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      sl_ena <= '1';
      tracked_value_sl <= 'X';
      wait for C_CLK_PERIOD;
      sl_ena <= '0';
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to tracked_value, expecting alert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_sl <= 'X';
      wait for C_CLK_PERIOD;
      sl_ena <= '0';
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_sl <= 'X';
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;
      -------------------------------------
      -- #endregion assert_one_of testcases
      -------------------------------------

      -------------------------------------
      -- #region assert_one_of non-clocked testcases
      -------------------------------------
      -------------------------------------
      -- assert_one_of (std_logic_vector non-clocked)
      -------------------------------------
      slv_non_clocked_ena <= '0';
      tracked_value_slv <= "0000";
      allowed_values_slv_array <= ("0000", "1111");
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (""0000"", ""1111"")");
      log(ID_SEQUENCER, "tracked_value = ""0000""");
      slv_non_clocked_ena <= '1';
      tracked_value_slv <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1111""");
      tracked_value_slv <= "1111";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""0001"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "0001";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_slv <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1110"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "1110";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_slv <= "1111";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "allowed_values = (""LLLL"", ""HHHH"")");
      slv_non_clocked_ena <= '0';
      tracked_value_slv <= "LLLL";
      allowed_values_slv_array <= ("LLLL", "HHHH");
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""LLLH"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "LLLH";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_slv <= "LLLL";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""HHHL"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "HHHL";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_slv <= "HHHH";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each legal signal change");
      slv_non_clocked_ena <= '0';
      tracked_value_slv <= "0000";
      allowed_values_slv_array <= ("0000", "1111");
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        tracked_value_slv <= not tracked_value_slv;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      slv_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_one_of (unsigned non-clocked)
      -------------------------------------
      unsigned_non_clocked_ena <= '0';
      tracked_value_unsigned <= "0000";
      allowed_values_unsigned_array <= ("0000", "1111");
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (unsigned non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (""0000"", ""1111"")");
      log(ID_SEQUENCER, "tracked_value = ""0000""");
      unsigned_non_clocked_ena <= '1';
      tracked_value_unsigned <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1111""");
      tracked_value_unsigned <= "1111";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (unsigned non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""0001"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= "0001";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_unsigned <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1110"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= "1110";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_unsigned <= "1111";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "allowed_values = (""0101"", ""1010"")");
      unsigned_non_clocked_ena <= '0';
      tracked_value_unsigned <= "0101";
      allowed_values_unsigned_array <= ("0101", "1010");
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= "0000";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_unsigned <= "0101";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1111"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_unsigned <= "1111";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_unsigned <= "1010";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (unsigned non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each legal signal change");
      unsigned_non_clocked_ena <= '0';
      tracked_value_unsigned <= "0000";
      allowed_values_unsigned_array <= ("0000", "1111");
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        tracked_value_unsigned <= not tracked_value_unsigned;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      unsigned_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_one_of (signed non-clocked)
      -------------------------------------
      signed_non_clocked_ena <= '0';
      tracked_value_signed <= "0000";
      allowed_values_signed_array <= ("0000", "1111");
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (signed non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (""0000"", ""1111"")");
      log(ID_SEQUENCER, "tracked_value = ""0000""");
      signed_non_clocked_ena <= '1';
      tracked_value_signed <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1111""");
      tracked_value_signed <= "1111";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (signed non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = ""0001"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= "0001";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_signed <= "0000";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1110"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= "1110";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_signed <= "1111";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "allowed_values = (""0101"", ""1010"")");
      signed_non_clocked_ena <= '0';
      tracked_value_signed <= "0101";
      allowed_values_signed_array <= ("0101", "1010");
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""0000"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= "0000";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_signed <= "0101";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = ""1111"", expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_signed <= "1111";
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_signed <= "1010";
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (signed non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each legal signal change");
      signed_non_clocked_ena <= '0';
      tracked_value_signed <= "0000";
      allowed_values_signed_array <= ("0000", "1111");
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        tracked_value_signed <= not tracked_value_signed;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      signed_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_one_of (integer non-clocked)
      -------------------------------------
      int_non_clocked_ena <= '0';
      tracked_value_int <= 0;
      allowed_values_int_array <= (0, 1);
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (0, 1)");
      log(ID_SEQUENCER, "tracked_value = 0");
      int_non_clocked_ena <= '1';
      tracked_value_int <= 0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 1");
      tracked_value_int <= 1;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 10, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= 10;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_int <= 0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = -10, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= -10;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_int <= 0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "allowed_values = (-2147483647, 2147483647)");
      int_non_clocked_ena <= '0';
      tracked_value_int <= -2147483647;
      allowed_values_int_array <= (-2147483647, 2147483647);
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = -2147483646, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= -2147483646;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_int <= -2147483647;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 2147483646, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= 2147483646;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_int <= 2147483647;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each legal signal change");
      int_non_clocked_ena <= '0';
      tracked_value_int <= 0;
      allowed_values_int_array <= (0, 1);
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 1 loop
        tracked_value_int <= 1;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_int <= 0;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      int_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_one_of (real non-clocked)
      -------------------------------------
      real_non_clocked_ena <= '0';
      tracked_value_real <= 0.0;
      allowed_values_real_array <= (0.0, 1.0);
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (real non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (0.0, 1.0)");
      log(ID_SEQUENCER, "tracked_value = 0.0");
      real_non_clocked_ena <= '1';
      tracked_value_real <= 0.0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 1.0");
      tracked_value_real <= 1.0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (real non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 1.1, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= 1.1;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_real <= 0.0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = -1.1, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= -1.1;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_real <= 0.0;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "allowed_values = (-1.7976931348623157e307, 1.7976931348623157e307)");
      real_non_clocked_ena <= '0';
      tracked_value_real <= -1.7976931348623157e307;
      allowed_values_real_array <= (-1.7976931348623157e307, 1.7976931348623157e307);
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = -1.7976931348623157e306, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= -1.7976931348623157e306;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_real <= -1.7976931348623157e307;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 1.7976931348623157e306, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_real <= 1.7976931348623157e306;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_real <= 1.7976931348623157e307;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (real non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each legal signal change");
      real_non_clocked_ena <= '0';
      tracked_value_real <= 0.0;
      allowed_values_real_array <= (0.0, 1.0);
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 1 loop
        tracked_value_real <= 1.0;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_real <= 0.0;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      real_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_one_of (time non-clocked)
      -------------------------------------
      time_non_clocked_ena <= '0';
      tracked_value_time <= 0 ns;
      allowed_values_time_array <= (0 ns, 1 ns);
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (time non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = (0 ns, 1 ns)");
      log(ID_SEQUENCER, "tracked_value = 0 ns");
      time_non_clocked_ena <= '1';
      tracked_value_time <= 0 ns;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 1 ns");
      tracked_value_time <= 1 ns;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (time non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "tracked_value = 2 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= 2 ns;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_time <= 0 ns;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = -2 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= -2 ns;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_time <= 0 ns;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "allowed_values = (-2147483647 ns, 2147483647 ns)");
      time_non_clocked_ena <= '0';
      tracked_value_time <= -2147483647 ns;
      allowed_values_time_array <= (-2147483647 ns, 2147483647 ns);
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = -2147483646 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= -2147483646 ns;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_time <= -2147483647 ns;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = 2147483646 ns, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_time <= 2147483646 ns;
      wait for v_rand.rand(ONLY, v_time_vector);
      tracked_value_time <= 2147483647 ns;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (time non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each legal signal change");
      time_non_clocked_ena <= '0';
      tracked_value_time <= 0 ns;
      allowed_values_time_array <= (0 ns, 1 ns);
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 1 loop
        tracked_value_time <= 1 ns;
        wait for v_rand.rand(ONLY, v_time_vector);
        tracked_value_time <= 0 ns;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      time_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_one_of (std_logic non-clocked)
      -------------------------------------
      sl_non_clocked_ena <= '0';
      tracked_value_sl <= '0';
      allowed_values_slv <= "01";
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "allowed_values = ('0', '1')");
      log(ID_SEQUENCER, "tracked_value = '0'");
      sl_non_clocked_ena <= '1';
      tracked_value_sl <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "tracked_value = '1'");
      tracked_value_sl <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic non-clocked)");
      ------------------------------------------------------------------------
      test_triggering_assert_one_of(NON_CLOCKED);

      log(ID_SEQUENCER, "allowed_values = ('0', 'L')");
      sl_non_clocked_ena <= '0';
      allowed_values_slv <= "0L";
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '1';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);
      test_triggering_assert_one_of(CLOCKED);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each legal signal change");
      sl_non_clocked_ena <= '0';
      allowed_values_slv <= "01";
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '1';
      -- Toggles tracked_value
      for i in 0 to 3 loop
        tracked_value_sl <= not tracked_value_sl;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      sl_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as tracked_value is assigned, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      sl_non_clocked_ena <= '1';
      tracked_value_sl <= 'X';
      wait for v_rand.rand(ONLY, v_time_vector);
      sl_non_clocked_ena <= '0';
      tracked_value_sl <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);
      -------------------------------------
      -- #endregion assert_one_of non-clocked testcases
      -------------------------------------
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_one_hot" then
    --============================================================================================================================
      -------------------------------------
      -- assert_one_hot
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= (others => '0');
      accept_all_zeros <= ALL_ZERO_NOT_ALLOWED;
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ALL_ZERO_NOT_ALLOWED");
      ------------------------------------------------------------------------
      slv_ena <= '1';
      test_normal_operation_one_hot(CLOCKED);
      wait for 4 * C_CLK_PERIOD;
      test_triggering_assert_one_hot(CLOCKED);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ALL_ZERO_ALLOWED");
      ------------------------------------------------------------------------
      slv_ena <= '0';
      accept_all_zeros <= ALL_ZERO_ALLOWED;
      wait for 4 * C_CLK_PERIOD;

      slv_ena <= '1';
      test_normal_operation_one_hot(CLOCKED);
      wait for 4 * C_CLK_PERIOD;
      test_triggering_assert_one_hot(CLOCKED);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      slv_ena <= '0';
      accept_all_zeros <= ALL_ZERO_NOT_ALLOWED;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as tracked_value is assigned, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      slv_ena <= '1';
      tracked_value_slv <= "1111";
      wait for C_CLK_PERIOD;
      slv_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to tracked_value, expecting alert");
      slv_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "1111";
      wait for C_CLK_PERIOD;
      slv_ena <= '0';
      tracked_value_slv <= "1000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_slv <= "1111";
      wait for C_CLK_PERIOD;
      slv_ena <= '0';
      tracked_value_slv <= "1000";
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_one_hot (non-clocked)
      -------------------------------------
      slv_non_clocked_ena <= '0';
      tracked_value_slv <= (others => '0');
      accept_all_zeros <= ALL_ZERO_NOT_ALLOWED;
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ALL_ZERO_NOT_ALLOWED (non-clocked)");
      ------------------------------------------------------------------------
      slv_non_clocked_ena <= '1';
      test_normal_operation_one_hot(NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);
      test_triggering_assert_one_hot(NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ALL_ZERO_ALLOWED (non-clocked)");
      ------------------------------------------------------------------------
      slv_non_clocked_ena <= '0';
      accept_all_zeros <= ALL_ZERO_ALLOWED;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      slv_non_clocked_ena <= '1';
      test_normal_operation_one_hot(NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);
      test_triggering_assert_one_hot(NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledge is expected each time tracked_value changes to a one-hot signal");
      slv_non_clocked_ena <= '0';
      accept_all_zeros <= ALL_ZERO_NOT_ALLOWED;
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '1';
      -- Changes tracked_value to different one-hot signals over time
      for i in 0 to 3 loop
        tracked_value_slv <= tracked_value_slv ror 1;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      slv_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as tracked_value is assigned, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      slv_non_clocked_ena <= '1';
      tracked_value_slv <= "1111";
      wait for v_rand.rand(ONLY, v_time_vector);
      slv_non_clocked_ena <= '0';
      wait for 4 * v_rand.rand(ONLY, v_time_vector);
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_value_in_range" then
    --============================================================================================================================
      -------------------------------------
      -- #region assert_value_in_range testcases
      -------------------------------------
      -------------------------------------
      -- assert_value_in_range (unsigned)
      -------------------------------------
      unsigned_ena <= '0';
      tracked_value_unsigned <= "0101";
      lower_limit_unsigned <= "0101";
      upper_limit_unsigned <= "1010";
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (unsigned)");
      ------------------------------------------------------------------------
      unsigned_ena <= '1';
      wait for C_CLK_PERIOD;
      test_normal_operation_value_in_range(lower_limit_unsigned, upper_limit_unsigned, CLOCKED);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (unsigned)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_unsigned, upper_limit_unsigned, CLOCKED, ABOVE);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_unsigned, upper_limit_unsigned, CLOCKED, BELOW);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (unsigned)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      unsigned_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      unsigned_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      unsigned_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value_in_range (signed)
      -------------------------------------
      signed_ena <= '0';
      tracked_value_signed <= "0000";
      lower_limit_signed <= "0000";
      upper_limit_signed <= "0101";
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (signed)");
      ------------------------------------------------------------------------
      signed_ena <= '1';
      wait for C_CLK_PERIOD;
      test_normal_operation_value_in_range(lower_limit_signed, upper_limit_signed, CLOCKED);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (signed)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_signed, upper_limit_signed, CLOCKED, ABOVE);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_signed, upper_limit_signed, CLOCKED, BELOW);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (signed)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      signed_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      signed_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      signed_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value_in_range (real)
      -------------------------------------
      real_ena <= '0';
      tracked_value_real <= 0.0;
      lower_limit_real <= 0.0;
      upper_limit_real <= 10.0;
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (real)");
      ------------------------------------------------------------------------
      real_ena <= '1';
      wait for C_CLK_PERIOD;
      test_normal_operation_value_in_range(lower_limit_real, upper_limit_real, CLOCKED);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (real)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_real, upper_limit_real, CLOCKED, ABOVE);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_real, upper_limit_real, CLOCKED, BELOW);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (real)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      real_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      real_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      real_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value_in_range (time)
      -------------------------------------
      time_ena <= '0';
      tracked_value_time <= 0 ns;
      lower_limit_time <= 0 ns;
      upper_limit_time <= 10 ns;
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (time)");
      ------------------------------------------------------------------------
      time_ena <= '1';
      wait for C_CLK_PERIOD;
      test_normal_operation_value_in_range(lower_limit_time, upper_limit_time, CLOCKED);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (time)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_time, upper_limit_time, CLOCKED, ABOVE);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_time, upper_limit_time, CLOCKED, BELOW);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (time)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      time_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      time_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      time_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value_in_range (integer)
      -------------------------------------
      int_ena <= '0';
      tracked_value_int <= 0;
      lower_limit_int <= 0;
      upper_limit_int <= 10;
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (integer)");
      ------------------------------------------------------------------------
      int_ena <= '1';
      wait for C_CLK_PERIOD;
      test_normal_operation_value_in_range(lower_limit_int, upper_limit_int, CLOCKED);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_int, upper_limit_int, CLOCKED, ABOVE);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_int, upper_limit_int, CLOCKED, BELOW);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each rising clock edge");
      int_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      int_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      int_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (integer)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as tracked_value is assigned, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      int_ena <= '1';
      tracked_value_int <= lower_limit_int - 1;
      wait for C_CLK_PERIOD;
      int_ena <= '0';
      tracked_value_int <= lower_limit_int;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to tracked_value, expecting alert");
      int_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_int <= lower_limit_int - 1;
      wait for C_CLK_PERIOD;
      int_ena <= '0';
      tracked_value_int <= lower_limit_int;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      int_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_int <= lower_limit_int - 1;
      wait for C_CLK_PERIOD;
      tracked_value_int <= lower_limit_int;
      wait for 4 * C_CLK_PERIOD;
      -------------------------------------
      -- #endregion assert_value_in_range testcases
      -------------------------------------

      -------------------------------------
      -- #region assert_value_in_range non-clocked testcases
      -------------------------------------
      -------------------------------------
      -- assert_value_in_range (unsigned non-clocked)
      -------------------------------------
      unsigned_non_clocked_ena <= '0';
      tracked_value_unsigned <= "0101";
      lower_limit_unsigned <= "0101";
      upper_limit_unsigned <= "1010";
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (unsigned non-clocked)");
      ------------------------------------------------------------------------
      unsigned_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      test_normal_operation_value_in_range(lower_limit_unsigned, upper_limit_unsigned, NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (unsigned non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_unsigned, upper_limit_unsigned, NON_CLOCKED, ABOVE);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_unsigned, upper_limit_unsigned, NON_CLOCKED, BELOW);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (unsigned non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledgment is expected each time tracked_value changes to a value within the range");
      unsigned_non_clocked_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      unsigned_non_clocked_ena <= '1';
      -- increments tracked_value
      for i in 0 to 3 loop
        tracked_value_unsigned <= tracked_value_unsigned + to_unsigned(1, tracked_value_unsigned'length);
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      unsigned_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value_in_range (signed non-clocked)
      -------------------------------------
      signed_non_clocked_ena <= '0';
      tracked_value_signed <= "0000";
      lower_limit_signed <= "0000";
      upper_limit_signed <= "0101";
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (signed non-clocked)");
      ------------------------------------------------------------------------
      signed_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      test_normal_operation_value_in_range(lower_limit_signed, upper_limit_signed, NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (signed non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_signed, upper_limit_signed, NON_CLOCKED, ABOVE);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_signed, upper_limit_signed, NON_CLOCKED, BELOW);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (signed non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledgment is expected each time tracked_value changes to a value within the range");
      signed_non_clocked_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      signed_non_clocked_ena <= '1';
      -- increments tracked_value
      for i in 0 to 3 loop
        tracked_value_signed <= tracked_value_signed + to_signed(1, tracked_value_signed'length);
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      signed_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value_in_range (real non-clocked)
      -------------------------------------
      real_non_clocked_ena <= '0';
      tracked_value_real <= 0.0;
      lower_limit_real <= 0.0;
      upper_limit_real <= 10.0;
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (real non-clocked)");
      ------------------------------------------------------------------------
      real_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      test_normal_operation_value_in_range(lower_limit_real, upper_limit_real, NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (real non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_real, upper_limit_real, NON_CLOCKED, ABOVE);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_real, upper_limit_real, NON_CLOCKED, BELOW);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (real non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledgment is expected each time tracked_value changes to a value within the range");
      real_non_clocked_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      real_non_clocked_ena <= '1';
      -- increments tracked_value
      for i in 0 to 3 loop
        tracked_value_real <= tracked_value_real + 1.0;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      real_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value_in_range (time non-clocked)
      -------------------------------------
      time_non_clocked_ena <= '0';
      tracked_value_time <= 0 ns;
      lower_limit_time <= 0 ns;
      upper_limit_time <= 10 ns;
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (time non-clocked)");
      ------------------------------------------------------------------------
      time_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      test_normal_operation_value_in_range(lower_limit_time, upper_limit_time, NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (time non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_time, upper_limit_time, NON_CLOCKED, ABOVE);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_time, upper_limit_time, NON_CLOCKED, BELOW);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (time non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledgment is expected each time tracked_value changes to a value within the range");
      time_non_clocked_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      time_non_clocked_ena <= '1';
      -- increments tracked_value
      for i in 0 to 3 loop
        tracked_value_time <= tracked_value_time + 1 ns;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      time_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      -------------------------------------
      -- assert_value_in_range (integer non-clocked)
      -------------------------------------
      int_non_clocked_ena <= '0';
      tracked_value_int <= 0;
      lower_limit_int <= 0;
      upper_limit_int <= 10;
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (integer non-clocked)");
      ------------------------------------------------------------------------
      int_non_clocked_ena <= '1';
      wait for v_rand.rand(ONLY, v_time_vector);
      test_normal_operation_value_in_range(lower_limit_int, upper_limit_int, NON_CLOCKED);
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing above the range");
      test_triggering_assert_value_in_range(lower_limit_int, upper_limit_int, NON_CLOCKED, ABOVE);

      log(ID_SEQUENCER, "Testing below the range");
      test_triggering_assert_value_in_range(lower_limit_int, upper_limit_int, NON_CLOCKED, BELOW);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "A positive acknowledgment is expected each time tracked_value changes to a value within the range");
      int_non_clocked_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '1';
      -- increments tracked_value
      for i in 0 to 3 loop
        tracked_value_int <= tracked_value_int + 1;
        wait for v_rand.rand(ONLY, v_time_vector);
      end loop;
      int_non_clocked_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (integer non-clocked)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as tracked_value is assigned, expecting alert");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      int_non_clocked_ena <= '1';
      tracked_value_int <= lower_limit_int - 1;
      wait for v_rand.rand(ONLY, v_time_vector);
      int_non_clocked_ena <= '0';
      tracked_value_int <= lower_limit_int;
      wait for 4 * v_rand.rand(ONLY, v_time_vector);
      -------------------------------------
      -- #endregion assert_value_in_range non-clocked testcases
      -------------------------------------
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_shift_one_from_left" then
    --============================================================================================================================
      -------------------------------------
      -- Testing ANY_BIT_ALERT
      -------------------------------------
      ena <= '0';
      tracked_value_slv <= (others => '0');
      necessary_condition <= ANY_BIT_ALERT;
      pos_ack_kind <= FIRST;
      wait for C_CLK_PERIOD;
      ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      test_normal_operation_shift_one_from_left(necessary_condition);
      test_triggering_assert_shift_one_from_left(necessary_condition);

      -------------------------------------
      -- Testing LAST_BIT_ALERT
      -------------------------------------
      ena <= '0';
      tracked_value_slv <= (others => '0');
      necessary_condition <= LAST_BIT_ALERT;
      wait for C_CLK_PERIOD;
      ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      test_normal_operation_shift_one_from_left(necessary_condition);
      test_triggering_assert_shift_one_from_left(necessary_condition);

      -------------------------------------
      -- Testing ANY_BIT_ALERT_NO_PIPE
      -------------------------------------
      ena <= '0';
      tracked_value_slv <= (others => '0');
      necessary_condition <= ANY_BIT_ALERT_NO_PIPE;
      wait for C_CLK_PERIOD;
      ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      test_normal_operation_shift_one_from_left(necessary_condition);
      test_triggering_assert_shift_one_from_left(necessary_condition);

      -------------------------------------
      -- Testing LAST_BIT_ALERT_NO_PIPE
      -------------------------------------
      ena <= '0';
      tracked_value_slv <= (others => '0');
      necessary_condition <= LAST_BIT_ALERT_NO_PIPE;
      wait for C_CLK_PERIOD;
      ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      test_normal_operation_shift_one_from_left(necessary_condition);
      test_triggering_assert_shift_one_from_left(necessary_condition);

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful cycle sequence");
      ena <= '0';
      necessary_condition <= ANY_BIT_ALERT;
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1100";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1110";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1111";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0111";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0011";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0001";
      wait for C_CLK_PERIOD;

      ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as cycle sequence is started, expecting alert");
      ena <= '1';
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "0000";
      wait for C_CLK_PERIOD;
      ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to cycle sequence, expecting alert");
      ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      tracked_value_slv <= "0000";
      wait for C_CLK_PERIOD;
      ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_slv <= "1000";
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_value_from_min_to_max_cycles_after_trigger" then
    --============================================================================================================================
      -------------------------------------
      -- assert_value_from_min_to_max_cycles_after_trigger (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      trigger <= '0';
      exp_value_slv <= "1111";
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = ""1111"" within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 7, 10);
      hold_min_to_max_cycles("1111");
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = ""0000"" within the window");
      set_exp_value("0000");
      hold_min_to_max_cycles("0000");
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = ""1111"" within the window /w min_cycles = 0");
      set_exp_value("1111");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 0, 4);
      hold_min_to_max_cycles("1111");
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = ""1111"" within the window /w min_cycles = max_cycles");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 0, 0);
      hold_min_to_max_cycles("1111");
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_slv <= "1111";
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing triggering assert in each cycle within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 7, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 4); -- number of alerts = number of std_logic_vector transitions within the window
      test_triggering_assert_value_min_to_max_cycles("1110", exp_value_slv);

      log(ID_SEQUENCER, "Testing invalid values within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 7); -- number of alerts = number of sequences with no std_logic_vector transitions - number of valid sequences (all "1111"s)
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      tracked_value_slv <= "1111", "0000" after C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      tracked_value_slv <= "1111", "0000" after C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      pos_ack_kind <= EVERY;

      -- Testing with different windows
      for i in 1 to 4 loop
        set_min_max_cycles(SLV_OVERLOAD_ENA, 10 * i, 10 + 10 * i);
        hold_min_to_max_cycles("1111");
        wait for 4 * C_CLK_PERIOD;
      end loop;

      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value_from_min_to_max_cycles_after_trigger (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      trigger <= '0';
      exp_value_sl <= '1';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = '1' within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 7, 10);
      hold_min_to_max_cycles('1');
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = '0' within the window");
      set_exp_value('0');
      hold_min_to_max_cycles('0');
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = '1' within the window /w min_cycles = 0");
      set_exp_value('1');
      set_min_max_cycles(SL_OVERLOAD_ENA, 0, 4);
      hold_min_to_max_cycles('1');
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = '1' within the window /w min_cycles = max_cycles");
      set_min_max_cycles(SL_OVERLOAD_ENA, 0, 0);
      hold_min_to_max_cycles('1');
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_sl <= '1';
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all invalid bit patterns (containing at least one '0') within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 7, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 15); -- number of alerts = number of all bit patterns within the window - number of legal bit patterns (all 1's)
      test_triggering_assert_value_min_to_max_cycles;

      log(ID_SEQUENCER, "Testing all invalid values within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 7); -- number of alerts = number of sequences with no std_logic transitions - number of legal bit patterns (all '1's)
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      tracked_value_sl <= '1', '0' after C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      tracked_value_sl <= '1', '0' after C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      pos_ack_kind <= EVERY;

      -- Testing with different windows
      for i in 1 to 4 loop
        set_min_max_cycles(SL_OVERLOAD_ENA, 10 * i, 10 + 10 * i);
        hold_min_to_max_cycles('1');
        wait for 4 * C_CLK_PERIOD;
      end loop;

      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as trigger is assigned, expecting alert when triggering assert");
      sl_ena <= '1';
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      hold_min_to_max_cycles('0');
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to trigger, expecting alert when triggering assert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      hold_min_to_max_cycles('0');
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      hold_min_to_max_cycles('0');
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_change_to_value_from_min_to_max_cycles_after_trigger" then
    --============================================================================================================================
      -------------------------------------
      -- assert_change_to_value_from_min_to_max_cycles_after_trigger (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      trigger <= '0';
      exp_value_slv <= "1111";
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing std_logic_vector transitions to exp_value = ""1111"" within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 7, 10);
      change_value_to_expect_min_to_max_cycles(exp_value_slv);

      log(ID_SEQUENCER, "Testing std_logic_vector transitions to exp_value = ""0000"" within the window");
      set_exp_value("0000");
      change_value_to_expect_min_to_max_cycles(exp_value_slv);

      log(ID_SEQUENCER, "Testing std_logic_vector transitions to exp_value = ""1111"" within the window /w min_cycles = 0, max_cycles = 1");
      set_exp_value("1111");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 0, 1);
      change_value_to_expect_min_to_max_cycles(exp_value_slv);

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_slv <= "0000", "1111" after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_slv <= "0000", "1111" after C_CLK_PERIOD;
      wait for 4 * C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing invalid sequences (change to exp_value /= ""1111"") within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 7, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 49); -- number of alerts = number of sequences with std_logic_vector transitions - number of sequences with std_logic_vector transitions to exp_value
      change_value_to_not_expect_min_to_max_cycles(exp_value_slv);

      log(ID_SEQUENCER, "Testing invalid sequences (no std_logic_vector transitions) within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8); -- number of alerts = number of sequences with no std_logic_vector transitions
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_slv <= "0000";
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_slv <= "0000";
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      pos_ack_kind <= EVERY;

      -- Testing with different windows
      for i in 1 to 4 loop
        set_min_max_cycles(SLV_OVERLOAD_ENA, 10 * i, 10 + 10 * i);
        change_value_min_to_max_cycles("0000", "1111");
        wait for 4 * C_CLK_PERIOD;
      end loop;

      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_change_to_value_from_min_to_max_cycles_after_trigger (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      trigger <= '0';
      exp_value_sl <= '1';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all std_logic transitions to exp_value = '1' within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 7, 10);
      change_value_to_expect_min_to_max_cycles(exp_value_sl);

      log(ID_SEQUENCER, "Testing all std_logic transitions to exp_value = '0' within the window");
      set_exp_value('0');
      change_value_to_expect_min_to_max_cycles(exp_value_sl);

      log(ID_SEQUENCER, "Testing all std_logic transitions to exp_value = '1' within the window /w min_cycles = 0, max_cycles = 1");
      set_exp_value('1');
      set_min_max_cycles(SL_OVERLOAD_ENA, 0, 1);
      change_value_to_expect_min_to_max_cycles(exp_value_sl);

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_sl <= '0', '1' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_sl <= '0', '1' after C_CLK_PERIOD;
      wait for 4 * C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing invalid sequences (change to exp_value /= '1') within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 7, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 49); -- number of alerts = number of all std_logic transitions - all std_logic transitions to exp_value
      change_value_to_not_expect_min_to_max_cycles(exp_value_sl);

      log(ID_SEQUENCER, "Testing invalid sequences (no std_logic transitions) within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8); -- number of alerts = number of sequences with no std_logic transitions
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_sl <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_sl <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      pos_ack_kind <= EVERY;

      -- Testing with different windows
      for i in 1 to 4 loop
        set_min_max_cycles(SL_OVERLOAD_ENA, 10 * i, 10 + 10 * i);
        change_value_min_to_max_cycles('0', '1');
        wait for 4 * C_CLK_PERIOD;
      end loop;

      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as trigger is assigned, expecting alert when triggering assert");
      sl_ena <= '1';
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      hold_min_to_max_cycles('1');
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to trigger, expecting alert when triggering assert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      hold_min_to_max_cycles('1');
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      hold_min_to_max_cycles('1');
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_change_from_min_to_max_cycles_after_trigger" then
    --============================================================================================================================
      -------------------------------------
      -- assert_change_from_min_to_max_cycles_after_trigger (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      trigger <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing std_logic_vector transitions within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 7, 10);
      change_value_to_all_min_to_max_cycles;

      log(ID_SEQUENCER, "Testing std_logic_vector transitions within the window /w min_cycles = 0, max_cycles = 1");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 0, 1);
      change_value_to_all_min_to_max_cycles;

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_slv <= "UUUU", "1111" after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_slv <= "UUUU", "1111" after C_CLK_PERIOD;
      wait for 4 * C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing invalid sequences (no std_logic_vector transitions) within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 7, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8); -- number of alerts = number of sequences with no std_logic_vector transitions
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      tracked_value_slv <= "UUUU";
      wait for C_CLK_PERIOD;
      trigger <= '0';
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for 4 * C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      pos_ack_kind <= EVERY;

      -- Testing with different windows
      for i in 1 to 4 loop
        set_min_max_cycles(SLV_OVERLOAD_ENA, 10 * i, 10 + 10 * i);
        change_value_min_to_max_cycles("UUUU", "1111");
        wait for 4 * C_CLK_PERIOD;
      end loop;

      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_change_from_min_to_max_cycles_after_trigger (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      trigger <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all std_logic transitions within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 7, 10);
      change_value_to_all_min_to_max_cycles;

      log(ID_SEQUENCER, "Testing all std_logic transitions within the window /w min_cycles = 0, max_cycles = 1");
      set_min_max_cycles(SL_OVERLOAD_ENA, 0, 1);
      change_value_to_all_min_to_max_cycles;

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_sl <= 'U', '1' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_sl <= 'U', '1' after C_CLK_PERIOD;
      wait for 4 * C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all invalid sequences (no std_logic transitions) within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 7, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8); -- number of alerts = number of sequences with no std_logic transitions
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      tracked_value_sl <= 'U';
      wait for C_CLK_PERIOD;
      trigger <= '0';
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for 4 * C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      pos_ack_kind <= EVERY;

      -- Testing with different windows
      for i in 1 to 4 loop
        set_min_max_cycles(SL_OVERLOAD_ENA, 10 * i, 10 + 10 * i);
        change_value_min_to_max_cycles('U', '1');
        wait for 4 * C_CLK_PERIOD;
      end loop;

      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as trigger is assigned, expecting alert when triggering assert");
      sl_ena <= '1';
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      hold_min_to_max_cycles('U');
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to trigger, expecting alert when triggering assert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      hold_min_to_max_cycles('U');
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      hold_min_to_max_cycles('U');
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_stable_from_min_to_max_cycles_after_trigger" then
    --============================================================================================================================
      -------------------------------------
      -- assert_stable_from_min_to_max_cycles_after_trigger (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      trigger <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing legal sequences (no std_logic_vector transitions) within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 7, 10);
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing legal sequences (no std_logic_vector transitions) within the window /w min_cycles = 0");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 0, 5);
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing legal sequences (no std_logic_vector transitions) within the window /w min_cycles = max_cycles");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 0, 0);
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_slv <= "0000";
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing invalid sequences (std_logic_vector transitions) within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 7, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 56); -- number of alerts = number of sequences with std_logic_vector transitions
      change_value_to_all_min_to_max_cycles;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      set_min_max_cycles(SLV_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      tracked_value_slv <= "UUUU", "1111" after C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      tracked_value_slv <= "UUUU", "1111" after C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      pos_ack_kind <= EVERY;

      -- Testing with different windows
      for i in 0 to 3 loop
        set_min_max_cycles(SLV_OVERLOAD_ENA, 10 * i, 10 + 10 * i);
        hold_min_to_max_cycles("1111");
        wait for 4 * C_CLK_PERIOD;
      end loop;

      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_stable_from_min_to_max_cycles_after_trigger (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      trigger <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all legal sequences (no std_logic transitions) within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 7, 10);
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing all legal sequences (no std_logic transitions) within the window /w min_cycles = 0");
      set_min_max_cycles(SL_OVERLOAD_ENA, 0, 5);
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing all legal sequences (no std_logic transitions) within the window /w min_cycles = max_cycles");
      set_min_max_cycles(SL_OVERLOAD_ENA, 0, 0);
      hold_min_to_max_cycles_all_values;

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      tracked_value_sl <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all invalid sequences (std_logic transitions) within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 7, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 56); -- number of alerts = number of all std_logic transitions
      change_value_to_all_min_to_max_cycles;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      set_min_max_cycles(SL_OVERLOAD_ENA, 1, 4);
      trigger <= '1'; -- first trigger
      tracked_value_sl <= 'U', '1' after C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for C_CLK_PERIOD;
      trigger <= '1'; -- second trigger
      tracked_value_sl <= 'U', '1' after C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for C_CLK_PERIOD;
      trigger <= '0';
      wait for 4 * C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      pos_ack_kind <= EVERY;

      -- Testing with different windows
      for i in 0 to 3 loop
        set_min_max_cycles(SL_OVERLOAD_ENA, 10 * i, 10 + 10 * i);
        hold_min_to_max_cycles('1');
        wait for 4 * C_CLK_PERIOD;
      end loop;

      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as trigger is assigned, expecting alert when triggering assert");
      sl_ena <= '1';
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      change_value_min_to_max_cycles('U', '1');
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to trigger, expecting alert when triggering assert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      change_value_min_to_max_cycles('U', '1');
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      change_value_min_to_max_cycles('U', '1');
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_value_from_start_to_end_trigger" then
    --============================================================================================================================
      -------------------------------------
      -- assert_value_from_start_to_end_trigger (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      start_trigger <= '0';
      end_trigger <= '0';
      exp_value_slv <= "1111";
      pos_ack_kind <= FIRST;
      v_hold_time := 10;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = ""1111"" within the window");
      hold_start_to_end_trigger("1111", v_hold_time);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = ""0000"" within the window");
      set_exp_value("0000");
      hold_start_to_end_trigger("0000", v_hold_time);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = ""1111"" within the window /w start_trigger = end_trigger");
      v_hold_time := 0;
      set_exp_value("1111");
      hold_start_to_end_trigger("1111", v_hold_time); -- activate start_trigger and end_trigger at the same clock cycle
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      slv_ena <= '0';
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      tracked_value_slv <= "1111";
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing triggering assert in each cycle within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 4); -- number of alerts = number of std_logic_vector transitions within the window
      test_triggering_assert_value_from_start_to_end_trigger("1110", exp_value_slv);

      log(ID_SEQUENCER, "Testing invalid values within the window");
      v_hold_time := 5;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 7); -- number of alerts = number of sequences with no std_logic_vector transitions - number of valid sequences (all "1111"s)
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_slv <= "1111", "0000" after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_slv <= "1111", "0000" after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      slv_ena <= '0';
      pos_ack_kind <= EVERY;
      v_hold_time := 5;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      -- Tests with different windows
      for i in 1 to 4 loop
        hold_start_to_end_trigger("1111", v_hold_time * i);
        wait for 4 * C_CLK_PERIOD;
      end loop;

      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_value_from_start_to_end_trigger (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      start_trigger <= '0';
      end_trigger <= '0';
      exp_value_sl <= '1';
      pos_ack_kind <= FIRST;
      v_hold_time := 10;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = '1' within the window");
      hold_start_to_end_trigger('1', v_hold_time);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = '0' within the window");
      set_exp_value('0');
      hold_start_to_end_trigger('0', v_hold_time);
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing tracked_value equal to exp_value = '1' within the window /w start_trigger = end_trigger");
      v_hold_time := 0;
      set_exp_value('1');
      hold_start_to_end_trigger('1', v_hold_time); -- activate start_trigger and end_trigger at the same clock cycle
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      sl_ena <= '0';
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      tracked_value_sl <= '1';
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all invalid bit patterns (containing at least one '0') within the window");
      for bit_width in 2 to 4 loop
        increment_expected_alerts_and_stop_limit(TB_ERROR, 2 ** (bit_width + 1) - 1); -- number of alerts = number of all bit patterns within the window - number of legal bit pattern (all 1's)
        test_triggering_assert_value_from_start_to_end_trigger(bit_width);
      end loop;

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_sl <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_sl <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      sl_ena <= '0';
      pos_ack_kind <= EVERY;
      v_hold_time := 5;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      -- Tests with different windows
      for i in 1 to 4 loop
        hold_start_to_end_trigger('1', v_hold_time * i);
        wait for 4 * C_CLK_PERIOD;
      end loop;

      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as trigger is assigned, expecting alert when triggering assert");
      sl_ena <= '1';
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      hold_start_to_end_trigger('0', v_hold_time);
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to trigger, expecting alert when triggering assert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      hold_start_to_end_trigger('0', v_hold_time);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      hold_start_to_end_trigger('0', v_hold_time);
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_change_to_value_from_start_to_end_trigger" then
    --============================================================================================================================
      -------------------------------------
      -- assert_change_to_value_from_start_to_end_trigger (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      start_trigger <= '0';
      end_trigger <= '0';
      exp_value_slv <= "1111";
      pos_ack_kind <= FIRST;
      v_change_time := 5;
      v_hold_time := 5;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing std_logic_vector transitions to exp_value = ""1111"" within the window");
      change_value_to_expect_start_end_trigger(exp_value_slv, v_change_time);

      log(ID_SEQUENCER, "Testing std_logic_vector transitions to exp_value = ""0000"" within the window");
      set_exp_value("0000");
      change_value_to_expect_start_end_trigger(exp_value_slv, v_change_time);

      log(ID_SEQUENCER, "Testing std_logic_vector transitions to exp_value = ""1111"" within the window /w transition at cycle-1");
      v_change_time := 1;
      set_exp_value("1111");
      change_value_to_expect_start_end_trigger(exp_value_slv, v_change_time);

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      slv_ena <= '0';
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      tracked_value_slv <= "0000", "1111" after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      tracked_value_slv <= "0000", "1111" after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing invalid sequences (change to exp_value /= ""1111"") within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 49); -- number of alerts = number of sequences with std_logic_vector transitions - number of sequences with std_logic_vector transitions to exp_value
      change_value_to_not_expect_start_end_trigger(exp_value_slv, v_change_time);

      log(ID_SEQUENCER, "Testing invalid sequences (no std_logic_vector transitions) within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8); -- number of alerts = number of sequences with no std_logic_vector transitions
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_slv <= "0000";
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      slv_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      -- Tests with different windows
      for i in 1 to 4 loop
        change_value_start_end_trigger("UUUU","1111", v_change_time * i);
        wait for 4 * C_CLK_PERIOD;
      end loop;

      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_change_to_value_from_start_to_end_trigger (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      start_trigger <= '0';
      end_trigger <= '0';
      exp_value_sl <= '1';
      pos_ack_kind <= FIRST;
      v_change_time := 5;
      v_hold_time := 5;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all std_logic transitions to exp_value = '1' within the window");
      change_value_to_expect_start_end_trigger(exp_value_sl, v_change_time);

      log(ID_SEQUENCER, "Testing all std_logic transitions to exp_value = '0' within the window");
      set_exp_value('0');
      change_value_to_expect_start_end_trigger(exp_value_sl, v_change_time);

      log(ID_SEQUENCER, "Testing all std_logic transitions to exp_value = '1' within the window /w transition at cycle-1");
      v_change_time := 1;
      set_exp_value('1');
      change_value_to_expect_start_end_trigger(exp_value_sl, v_change_time);

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      sl_ena <= '0';
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      tracked_value_sl <= '0', '1' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      tracked_value_sl <= '0', '1' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing invalid sequences (change to exp_value /= '1') within the window");
      set_exp_value('1');
      increment_expected_alerts_and_stop_limit(TB_ERROR, 49); -- number of alerts = number of all std_logic transitions - all std_logic transitions to exp_value
      change_value_to_not_expect_start_end_trigger(exp_value_sl, v_change_time);

      log(ID_SEQUENCER, "Testing invalid sequences (no std_logic transitions) within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8); -- number of alerts = number of no std_logic transitions
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_sl <= '0';
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      sl_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      -- Tests with different windows
      for i in 1 to 4 loop
        change_value_start_end_trigger('U','1', v_change_time * i);
        wait for 4 * C_CLK_PERIOD;
      end loop;

      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as trigger is assigned, expecting alert when triggering assert");
      sl_ena <= '1';
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      hold_start_to_end_trigger('1', v_hold_time);
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to trigger, expecting alert when triggering assert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      hold_start_to_end_trigger('1', v_hold_time);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      hold_start_to_end_trigger('1', v_hold_time);
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_change_from_start_to_end_trigger" then
    --============================================================================================================================
      -------------------------------------
      -- assert_change_from_start_to_end_trigger (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      start_trigger <= '0';
      end_trigger <= '0';
      pos_ack_kind <= FIRST;
      v_change_time := 5;
      v_hold_time := 5;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing std_logic_vector transitions within the window");
      change_value_to_all_start_end_trigger(v_change_time);

      log(ID_SEQUENCER, "Testing std_logic_vector transitions at cycle-1");
      v_change_time := 1;
      change_value_to_all_start_end_trigger(v_change_time);

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      slv_ena <= '0';
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      tracked_value_slv <= "UUUU", "1111" after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      tracked_value_slv <= "UUUU", "1111" after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing invalid sequences (no std_logic_vector transitions) within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8); -- number of alerts = number of sequences with no std_logic_vector transitions
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_slv <= "UUUU";
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      slv_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      -- Testing with different windows
      for i in 1 to 4 loop
        change_value_start_end_trigger("UUUU", "1111", v_change_time * i);
        wait for 4 * C_CLK_PERIOD;
      end loop;

      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_change_from_start_to_end_trigger (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      start_trigger <= '0';
      end_trigger <= '0';
      pos_ack_kind <= FIRST;
      v_change_time := 5;
      v_hold_time := 5;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all std_logic transitions within the window");
      change_value_to_all_start_end_trigger(v_change_time);

      log(ID_SEQUENCER, "Testing all std_logic transitions at cycle-1");
      v_change_time := 1;
      change_value_to_all_start_end_trigger(v_change_time);

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      sl_ena <= '0';
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      tracked_value_sl <= 'U', '1' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      tracked_value_sl <= 'U', '1' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all invalid sequences (no std_logic transitions) within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8); -- number of alerts = number of sequences with no std_logic transitions
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_sl <= 'U';
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      sl_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      -- Testing with different windows
      for i in 1 to 4 loop
        change_value_start_end_trigger('U', '1', v_change_time * i);
        wait for 4 * C_CLK_PERIOD;
      end loop;

      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as trigger is assigned, expecting alert when triggering assert");
      sl_ena <= '1';
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      hold_start_to_end_trigger('U', v_hold_time);
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to trigger, expecting alert when triggering assert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      hold_start_to_end_trigger('U', v_hold_time);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      hold_start_to_end_trigger('U', v_hold_time);
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "assert_stable_from_start_to_end_trigger" then
    --============================================================================================================================
      -------------------------------------
      -- assert_stable_from_start_to_end_trigger (std_logic_vector)
      -------------------------------------
      slv_ena <= '0';
      tracked_value_slv <= "0000";
      start_trigger <= '0';
      end_trigger <= '0';
      pos_ack_kind <= FIRST;
      v_change_time := 5;
      v_hold_time := 5;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing legal sequences (no std_logic_vector transitions) within the window");
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing legal sequences (no std_logic_vector transitions) within the window /w start_trigger = end_trigger");
      v_hold_time := 0;
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      slv_ena <= '0';
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      tracked_value_slv <= "0000";
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing invalid sequences (std_logic_vector transitions) within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 56); -- number of alerts = number of sequences with std_logic_vector transitions
      change_value_to_all_start_end_trigger(v_change_time);

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_slv <= "UUUU", "1111" after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_slv <= "UUUU", "1111" after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_slv <= "0000";
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic_vector)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      slv_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      slv_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      -- Testing with different windows
      for i in 1 to 4 loop
        hold_start_to_end_trigger("1111", 5 * i);
        wait for 4 * C_CLK_PERIOD;
      end loop;

      slv_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      -------------------------------------
      -- assert_stable_from_start_to_end_trigger (std_logic)
      -------------------------------------
      sl_ena <= '0';
      tracked_value_sl <= '0';
      start_trigger <= '0';
      end_trigger <= '0';
      pos_ack_kind <= FIRST;
      v_change_time := 5;
      v_hold_time := 5;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Normal Operation (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all legal sequences (no std_logic transitions) within the window");
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing all legal sequences (no std_logic transitions) within the window /w start_trigger = end_trigger");
      v_hold_time := 0;
      hold_start_to_end_trigger_all_values(v_hold_time);

      log(ID_SEQUENCER, "Testing multiple triggers within the window");
      sl_ena <= '0';
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      tracked_value_sl <= '0';
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Triggering Assertion (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Testing all invalid sequences (std_logic transitions) within the window");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 56); -- number of alerts = number of all std_logic transitions
      change_value_to_all_start_end_trigger(v_change_time);

      log(ID_SEQUENCER, "Testing triggering assert /w multiple triggers within the window");
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- first trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_sl <= 'U', '1' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      start_trigger <= '1', '0' after C_CLK_PERIOD; -- second trigger
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      tracked_value_sl <= 'U', '1' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for 2 * C_CLK_PERIOD;
      end_trigger <= '1', '0' after C_CLK_PERIOD;
      wait for C_CLK_PERIOD;
      tracked_value_sl <= '0';
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing pos_ack_kind: EVERY (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Expecting a positive acknowledge on each successful window sequence");
      sl_ena <= '0';
      pos_ack_kind <= EVERY;
      wait for C_CLK_PERIOD;
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;

      -- Testing with different windows
      for i in 1 to 4 loop
        hold_start_to_end_trigger('1', 5 * i);
        wait for 4 * C_CLK_PERIOD;
      end loop;

      sl_ena <= '0';
      pos_ack_kind <= FIRST;
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Assertion Enable (std_logic)");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Assertion enabled as trigger is assigned, expecting alert when triggering assert");
      sl_ena <= '1';
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      change_value_start_end_trigger('U', '1', v_change_time);
      wait for 4 * C_CLK_PERIOD;
      sl_ena <= '0';
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Assertion enabled prior to trigger, expecting alert when triggering assert");
      sl_ena <= '1' after v_rand.rand(ONLY, v_time_vector); -- enable assertion after a random time
      wait for C_CLK_PERIOD;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      change_value_start_end_trigger('U', '1', v_change_time);
      wait for 4 * C_CLK_PERIOD;

      ------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing CLK Disabled");
      ------------------------------------------------------------------------
      log(ID_SEQUENCER, "Clock deactivated");
      clk_ena <= false;
      wait for 4 * C_CLK_PERIOD;

      log(ID_SEQUENCER, "Triggering assertion while clk is disabled, expecting no behavior");
      sl_ena <= '1';
      wait for 4 * C_CLK_PERIOD;
      change_value_start_end_trigger('U', '1', v_change_time);
      wait for 4 * C_CLK_PERIOD;
      ------------------------------------------------------------------------

    else
      log(ID_LOG_HDR, "Unknown test case", C_SCOPE);
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 10 ns;                -- to allow some time for completion
    report_alert_counters(FINAL);  -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait; -- to stop completely

  end process p_main;

end architecture func;