library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;
  use ieee.numeric_std.all;
  use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package uvvm_assertions_pkg is
  -- the " # region pragma is for editor purposes, and serves no purpose in the UVVM/VHDL context"
  -- most editors (Visual studio code etc) allows for "# region" for making collapsible blocks.
  -- #region assert_value
  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : boolean;

    constant exp_value     : boolean        := true; -- default value to check against
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : boolean;

    constant exp_value     : boolean        := true; -- default value to check against
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;

    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;

    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;

    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;

    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : t_slv_array;

    constant exp_value     : t_slv_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : t_slv_array;

    constant exp_value     : t_slv_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : t_unsigned_array;

    constant exp_value     : t_unsigned_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : t_unsigned_array;

    constant exp_value     : t_unsigned_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : t_signed_array;

    constant exp_value     : t_signed_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : t_signed_array;

    constant exp_value     : t_signed_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : unsigned;

    constant exp_value     : unsigned;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : unsigned;

    constant exp_value     : unsigned;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : signed;

    constant exp_value     : signed;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : signed;

    constant exp_value     : signed;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : integer;

    constant exp_value     : integer;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : integer;

    constant exp_value     : integer;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : real;

    constant exp_value     : real;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : real;

    constant exp_value     : real;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : time;

    constant exp_value     : time;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : time;

    constant exp_value     : time;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  -- #endregion assert_value

  -- #region ASSERT_ONE_OF
  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic_vector;

    constant allowed_values : t_slv_array;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic_vector;

    constant allowed_values : t_slv_array;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic;

    constant allowed_values : std_logic_vector; -- e.g "01" or "01X" or "01XL"
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic;

    constant allowed_values : std_logic_vector; -- e.g "01" or "01X" or "01XL"
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : unsigned;

    constant allowed_values : t_unsigned_array;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : unsigned;

    constant allowed_values : t_unsigned_array;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : signed;

    constant allowed_values : t_signed_array;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : signed;

    constant allowed_values : t_signed_array;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : integer;

    constant allowed_values : t_integer_array;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : integer;

    constant allowed_values : t_integer_array;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : real;

    constant allowed_values : real_vector;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : real;

    constant allowed_values : real_vector;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : time;

    constant allowed_values : time_vector;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : time;

    constant allowed_values : time_vector;
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  );
  -- #endregion ASSERT_ONE_OF

  -- #region ASSERT_ONE_HOT
  procedure assert_one_hot(
    signal   clk             : std_logic;
    signal   ena             : std_logic;
    signal   tracked_value   : std_logic_vector;

    constant msg             : string;
    constant alert_level     : t_alert_level      := ERROR;
    constant accept_all_zero : t_accept_all_zeros := ALL_ZERO_NOT_ALLOWED;
    constant scope           : string             := C_SCOPE;
    constant pos_ack_kind    : t_pos_ack_kind     := FIRST;
    constant msg_id          : t_msg_id           := ID_UVVM_ASSERTION;
    constant msg_id_panel    : t_msg_id_panel     := shared_msg_id_panel
  );
  procedure assert_one_hot(
    signal   ena             : std_logic;
    signal   tracked_value   : std_logic_vector;

    constant msg             : string;
    constant alert_level     : t_alert_level      := ERROR;
    constant accept_all_zero : t_accept_all_zeros := ALL_ZERO_NOT_ALLOWED;
    constant scope           : string             := C_SCOPE;
    constant pos_ack_kind    : t_pos_ack_kind     := FIRST;
    constant msg_id          : t_msg_id           := ID_UVVM_ASSERTION;
    constant msg_id_panel    : t_msg_id_panel     := shared_msg_id_panel
  );
  -- #endregion ASSERT_ONE_HOT

  -- #region ASSERT_VALUE_IN_RANGE
  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : unsigned;

    constant lower_limit   : unsigned;            -- inclusive
    constant upper_limit   : unsigned;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : unsigned;

    constant lower_limit   : unsigned;            -- inclusive
    constant upper_limit   : unsigned;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : signed;

    constant lower_limit   : signed;            -- inclusive
    constant upper_limit   : signed;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : signed;

    constant lower_limit   : signed;            -- inclusive
    constant upper_limit   : signed;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : integer;

    constant lower_limit   : integer;            -- inclusive
    constant upper_limit   : integer;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : integer;

    constant lower_limit   : integer;            -- inclusive
    constant upper_limit   : integer;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : real;

    constant lower_limit   : real;            -- inclusive
    constant upper_limit   : real;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : real;

    constant lower_limit   : real;            -- inclusive
    constant upper_limit   : real;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : time;

    constant lower_limit   : time;            -- inclusive
    constant upper_limit   : time;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : time;

    constant lower_limit   : time;            -- inclusive
    constant upper_limit   : time;            -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  -- #endregion ASSERT_VALUE_IN_RANGE

  -- #region ASSERT_SHIFT_ONE_FROM_LEFT
  procedure assert_shift_one_from_left(
    signal   clk                 : std_logic;
    signal   ena                 : std_logic;
    signal   tracked_value       : std_logic_vector;

    constant necessary_condition : t_shift_one_ness_cond;
    constant msg                 : string;
    constant alert_level         : t_alert_level          := ERROR;
    constant scope               : string                 := C_SCOPE;
    constant pos_ack_kind        : t_pos_ack_kind         := FIRST;
    constant msg_id              : t_msg_id               := ID_UVVM_ASSERTION;
    constant msg_id_panel        : t_msg_id_panel         := shared_msg_id_panel
  );
  procedure assert_shift_one_from_left(
    signal   clk                 : std_logic;
    signal   ena                 : std_logic;
    signal   tracked_value       : std_logic_vector;

    constant msg                 : string;
    constant alert_level         : t_alert_level          := ERROR;
    constant scope               : string                 := C_SCOPE;
    constant pos_ack_kind        : t_pos_ack_kind         := FIRST;
    constant msg_id              : t_msg_id               := ID_UVVM_ASSERTION;
    constant msg_id_panel        : t_msg_id_panel         := shared_msg_id_panel
  );
  -- #endregion ASSERT_SHIFT_ONE_FROM_LEFT

  -- #region WINDOW_ASSERTIONS
  -- internal types, used for window assertions core functions
  type t_min_to_max_cycles_after_trigger is (VALUE, CHANGE, CHANGE_TO_VALUE, STABLE);
  type t_from_start_to_end_trigger is (VALUE, CHANGE, CHANGE_TO_VALUE, STABLE);

  procedure assert_value_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   trigger       : std_logic;

    constant min_cycles    : integer;
    constant max_cycles    : integer;
    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_change_to_value_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   trigger       : std_logic;

    constant min_cycles    : integer;
    constant max_cycles    : integer;
    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_change_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   trigger       : std_logic;

    constant min_cycles    : integer;
    constant max_cycles    : integer;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_stable_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   trigger       : std_logic;

    constant min_cycles    : integer;
    constant max_cycles    : integer;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_change_to_value_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_change_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_stable_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );


  -- std_logic_vector overloads

  procedure assert_value_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   trigger       : std_logic;

    constant min_cycles    : integer;
    constant max_cycles    : integer;
    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_change_to_value_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   trigger       : std_logic;

    constant min_cycles    : integer;
    constant max_cycles    : integer;
    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_change_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   trigger       : std_logic;

    constant min_cycles    : integer;
    constant max_cycles    : integer;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_stable_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   trigger       : std_logic;

    constant min_cycles    : integer;
    constant max_cycles    : integer;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_value_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_change_to_value_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_change_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );
  procedure assert_stable_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  );

  -- #endregion WINDOW_ASSERTIONS

end package;
package body uvvm_assertions_pkg is

  -- #region ASSERT_VALUE

  -- assert_value (boolean):
  function f_assert_value_core (
  -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
  --       There is no way to overload the existing assert_value procedure to accept boolean
    tracked_value  : boolean;
    exp_value      : boolean;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if tracked_value /= exp_value then
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not " & to_string(exp_value) & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : boolean;
    constant exp_value     : boolean        := true; -- default value to check against
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : boolean;

    constant exp_value     : boolean        := true; -- default value to check against
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (std_logic_vector):
  function f_assert_value_core (
    tracked_value  : std_logic_vector;
    exp_value      : std_logic_vector;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if (tracked_value /= exp_value) then
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not " & to_string(exp_value) & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;

    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level    := ERROR;
    constant scope         : string           := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind   := FIRST;
    constant msg_id        : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel   := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then

      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;

    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level    := ERROR;
    constant scope         : string           := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind   := FIRST;
    constant msg_id        : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel   := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (std_logic):
  function f_assert_value_core (
    tracked_value  : std_logic;
    exp_value      : std_logic;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if (tracked_value /= exp_value) then
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not " & to_string(exp_value) & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;


  -- assert_value OVERLOAD (std_logic):
  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;

    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;

    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (t_slv_array):
  function f_assert_value_core (
    -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
    --       There is no way to overload the existing assert_value procedure to accept t_slv_array
    tracked_value  : t_slv_array;
    exp_value      : t_slv_array;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack        : boolean := first_ack;
    variable v_any_index_failed : boolean := false;
    variable v_index_failed     : integer;
  begin
    for i in tracked_value'range loop
      if (tracked_value(i) /= exp_value(i)) then
        v_any_index_failed := true;
        v_index_failed     := i;
      end if;
      if v_any_index_failed then
        alert(alert_level, procedure_name & " => Failed, tracked_value "& to_string(tracked_value) &" was not " & to_string(exp_value) & " (first mismatch at index: " & to_string(v_index_failed) & "). Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
        exit; -- exit the loop early.
      end if;
    end loop;
    if not v_any_index_failed then
      if pos_ack_kind = FIRST and v_first_ack then
        -- here we omit the full exp_value as it could be very long
        log(msg_id, procedure_name & " => OK (first), tracked_value was equal to exp_value. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        -- here we omit the full exp_value as it could be very long
        log(msg_id, procedure_name & " => OK, tracked_value was equal to exp_value. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : t_slv_array;

    constant exp_value     : t_slv_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : t_slv_array;

    constant exp_value     : t_slv_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (t_unsigned_array):
  function f_assert_value_core (
    -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
    --       There is no way to overload the existing assert_value procedure to accept t_unsigned_array
    tracked_value  : t_unsigned_array;
    exp_value      : t_unsigned_array;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack        : boolean := first_ack;
    variable v_any_index_failed : boolean := false;
    variable v_index_failed     : integer;
  begin
    for i in tracked_value'range loop
      if (tracked_value(i) /= exp_value(i)) then
        v_any_index_failed := true;
        v_index_failed     := i;
      end if;
      if v_any_index_failed then
        alert(alert_level, procedure_name & " => Failed, tracked_value "& to_string(tracked_value) &" was not " & to_string(exp_value) & " (first mismatch at index: " & to_string(v_index_failed) & "). Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
        exit; -- exit the loop early.
      end if;
    end loop;
    if not v_any_index_failed then
      if pos_ack_kind = FIRST and v_first_ack then
        -- here we omit the full exp_value as it could be very long
        log(msg_id, procedure_name & " => OK (first), tracked_value was equal to exp_value. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        -- here we omit the full exp_value as it could be very long
        log(msg_id, procedure_name & " => OK, tracked_value was equal to exp_value. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : t_unsigned_array;

    constant exp_value     : t_unsigned_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : t_unsigned_array;

    constant exp_value     : t_unsigned_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (t_signed_array):
  function f_assert_value_core (
    -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
    --       There is no way to overload the existing assert_value procedure to accept t_signed_array
    tracked_value  : t_signed_array;
    exp_value      : t_signed_array;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack        : boolean := first_ack;
    variable v_any_index_failed : boolean := false;
    variable v_index_failed     : integer;
  begin
    for i in tracked_value'range loop
      if (tracked_value(i) /= exp_value(i)) then
        v_any_index_failed := true;
        v_index_failed     := i;
      end if;
      if v_any_index_failed then
        alert(alert_level, procedure_name & " => Failed, tracked_value "& to_string(tracked_value) &" was not " & to_string(exp_value) & " (first mismatch at index: " & to_string(v_index_failed) & "). Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
        exit; -- exit the loop early.
      end if;
    end loop;
    if not v_any_index_failed then
      if pos_ack_kind = FIRST and v_first_ack then
        -- here we omit the full exp_value as it could be very long
        log(msg_id, procedure_name & " => OK (first), tracked_value was equal to exp_value. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        -- here we omit the full exp_value as it could be very long
        log(msg_id, procedure_name & " => OK, tracked_value was equal to exp_value. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : t_signed_array;

    constant exp_value     : t_signed_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : t_signed_array;

    constant exp_value     : t_signed_array;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (unsigned):
  function f_assert_value_core (
    -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
    --       There is no way to overload the existing assert_value procedure to accept unsigned
    tracked_value  : unsigned;
    exp_value      : unsigned;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if tracked_value /= exp_value then
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not " & to_string(exp_value) & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : unsigned;

    constant exp_value     : unsigned;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : unsigned;

    constant exp_value     : unsigned;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (signed):
  function f_assert_value_core (
    -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
    --       There is no way to overload the existing assert_value procedure to accept signed
    tracked_value  : signed;
    exp_value      : signed;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if tracked_value /= exp_value then
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not " & to_string(exp_value) & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : signed;

    constant exp_value     : signed;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : signed;

    constant exp_value     : signed;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (integer):
  function f_assert_value_core (
    -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
    --       There is no way to overload the existing assert_value procedure to accept integer
    tracked_value  : integer;
    exp_value      : integer;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if tracked_value /= exp_value then
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not " & to_string(exp_value) & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : integer;

    constant exp_value     : integer;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : integer;

    constant exp_value     : integer;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (real):
  function f_assert_value_core (
    -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
    --       There is no way to overload the existing assert_value procedure to accept real
    tracked_value  : real;
    exp_value      : real;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if tracked_value /= exp_value then
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not " & to_string(exp_value) & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(exp_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : real;

    constant exp_value     : real;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : real;

    constant exp_value     : real;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- assert_value (time):
  function f_assert_value_core (
    -- NOTE: VHDL-2008 does not allow type conversion in procedure call parameters, and so
    --       There is no way to overload the existing assert_value procedure to accept time
    tracked_value  : time;
    exp_value      : time;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if tracked_value /= exp_value then
      alert(alert_level, procedure_name & " => Failed, tracked_value (" & to_string(tracked_value, C_LOG_TIME_BASE) & ") was not " & to_string(exp_value, C_LOG_TIME_BASE) & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(exp_value, C_LOG_TIME_BASE) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(exp_value, C_LOG_TIME_BASE) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_core;

  procedure assert_value(
    signal   ena           : std_logic;
    signal   tracked_value : time;

    constant exp_value     : time;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  procedure assert_value(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : time;

    constant exp_value     : time;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_core(tracked_value, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value;

  -- #endregion

  -- #region ASSERT_ONE_OF

  -- assert_one_of (std_logic_vector):
  function f_assert_one_of_core(
    tracked_value  : std_logic_vector;
    allowed_values : t_slv_array;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;

    function one_of(slv : std_logic_vector; slv_array : t_slv_array) return boolean is
      variable v_found : boolean := false;
    begin
      for i in slv_array'range loop
        -- we check if the hex string is the same as the tracked value
        if slv = slv_array(i) then
          v_found := true;
          exit; -- we found a match, so we can exit the loop early
        end if;
      end loop;
      return v_found;
    end function one_of;

    variable v_print_line : line;
  begin
    if not one_of(tracked_value, allowed_values) then
      -- takes in an t_slv_array, e.g ("01", "10) or ("1X", "UU") and returns a string with each bit separated by a '/' and surrounded by "'" (e.g "'01'/'10'/'UU'")
      for i in allowed_values'range loop
        if i /= allowed_values'right then
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'" & "/");
        else
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'");
        end if;
      end loop;
      alert(alert_level, procedure_name & " => Failed, tracked_value (" & to_string(tracked_value) & ") was not one of " & v_print_line.all & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      DEALLOCATE(v_print_line);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_one_of_core;

  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic_vector;

    constant allowed_values : t_slv_array; -- e.g ("01", "11") or ("00", "11")
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_one_of()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic_vector;

    constant allowed_values : t_slv_array; -- e.g ("01", "11") or ("00", "11")
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_one_of()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  -- assert_one_of (std_logic):
  function f_assert_one_of_core(
    tracked_value  : std_logic;
    allowed_values : std_logic_vector;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;

    function one_of(sl : std_logic; slv : std_logic_vector) return boolean is
      variable v_found : boolean := false;
    begin

      for i in slv'range loop
        if sl = slv(i) then
          v_found := true;
          exit;
        end if;
      end loop;
      return v_found;
    end function one_of;

    variable v_print_line : line;
    
  begin
    if not one_of(tracked_value, allowed_values) then
      -- takes in an std_logic_vector (e.g "010" or "01X") and returns a string with each bit separated by a '/' and surrounded by "'" (e.g "'0'/'1'/'H'")
      for i in allowed_values'range loop
        if i /= allowed_values'right then
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'" & "/");
        else
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'");
        end if;
      end loop;
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not one of " & v_print_line.all & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      DEALLOCATE(v_print_line);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_one_of_core;

  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic;

    constant allowed_values : std_logic_vector; -- e.g "01" or "01X" or "01XL"
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_one_of()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic;

    constant allowed_values : std_logic_vector; -- e.g "01" or "01X" or "01XL"
    constant msg            : string;
    constant alert_level    : t_alert_level    := ERROR;
    constant scope          : string           := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind   := FIRST;
    constant msg_id         : t_msg_id         := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel   := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_one_of()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  -- assert_one_of (unsigned):
  function f_assert_one_of_core(
    tracked_value  : unsigned;
    allowed_values : t_unsigned_array;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;

    function one_of(u : unsigned; u_array : t_unsigned_array) return boolean is
      variable v_found : boolean := false;
    begin
      for i in u_array'range loop
        -- we check if the hex string is the same as the tracked value
        if u = u_array(i) then
          v_found := true;
          exit; -- we found a match, so we can exit the loop early
        end if;
      end loop;
      return v_found;
    end function one_of;

    variable v_print_line : line;
    
  begin
    if not one_of(tracked_value, allowed_values) then
      -- takes in an t_slv_array, e.g ("01", "10) or ("1X", "UU") and returns a string with each bit separated by a '/' and surrounded by "'" (e.g "'01'/'10'/'UU'")
      for i in allowed_values'range loop
        if i /= allowed_values'right then
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'" & "/");
        else
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'");
        end if;
      end loop;
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not one of " & v_print_line.all & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      DEALLOCATE(v_print_line);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_one_of_core;

  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : unsigned;

    constant allowed_values : t_unsigned_array; -- e.g ("01", "11") or ("00", "11")
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_one_of()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : unsigned;

    constant allowed_values : t_unsigned_array; -- e.g ("01", "11") or ("00", "11")
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_one_of()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  -- assert_one_of (signed):
  function f_assert_one_of_core(
    tracked_value  : signed;
    allowed_values : t_signed_array;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;

    function one_of(s : signed; s_array : t_signed_array) return boolean is
      variable v_found : boolean := false;
    begin
      for i in s_array'range loop
        -- we check if the hex string is the same as the tracked value
        if s = s_array(i) then
          v_found := true;
          exit; -- we found a match, so we can exit the loop early
        end if;
      end loop;
      return v_found;
    end function one_of;

    variable v_print_line : line;
    
  begin
    if not one_of(tracked_value, allowed_values) then
      -- takes in an t_slv_array, e.g ("01", "10) or ("1X", "UU") and returns a string with each bit separated by a '/' and surrounded by "'" (e.g "'01'/'10'/'UU'")
      for i in allowed_values'range loop
        if i /= allowed_values'right then
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'" & "/");
        else
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'");
        end if;
      end loop;
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not one of " & v_print_line.all & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      DEALLOCATE(v_print_line);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_one_of_core;

  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : signed;

    constant allowed_values : t_signed_array; -- e.g ("01", "11") or ("00", "11")
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_one_of()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : signed;

    constant allowed_values : t_signed_array; -- e.g ("01", "11") or ("00", "11")
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_one_of()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  -- assert_one_of (integer):
  function f_assert_one_of_core(
    tracked_value  : integer;
    allowed_values : t_integer_array;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;

    function one_of(int : integer; int_array : t_integer_array) return boolean is
      variable v_found : boolean := false;
    begin
      for i in int_array'range loop
        -- we check if the hex string is the same as the tracked value
        if int = int_array(i) then
          v_found := true;
          exit; -- we found a match, so we can exit the loop early
        end if;
      end loop;
      return v_found;
    end function one_of;

    variable v_print_line : line;
  begin
    if not one_of(tracked_value, allowed_values) then
      -- line to print out t_integer_array with variable length of entries
      for i in allowed_values'range loop
        if i /= allowed_values'right then
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'" & "/");
        else
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'");
        end if;
      end loop;
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not one of " & v_print_line.all & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      DEALLOCATE(v_print_line);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_one_of_core;

  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : integer;

    constant allowed_values : t_integer_array;
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_one_of()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : integer;

    constant allowed_values : t_integer_array;
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_one_of()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  -- assert_one_of (real):
  function f_assert_one_of_core(
    tracked_value  : real;
    allowed_values : real_vector;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;

    function one_of(r : real; r_array : real_vector) return boolean is
      variable v_found : boolean := false;
    begin
      for i in r_array'range loop
        -- we check if the hex string is the same as the tracked value
        if r = r_array(i) then
          v_found := true;
          exit; -- we found a match, so we can exit the loop early
        end if;
      end loop;
      return v_found;
    end function one_of;

    variable v_print_line : line;

  begin
    if not one_of(tracked_value, allowed_values) then
      for i in allowed_values'range loop
        if i /= allowed_values'right then
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'" & "/");
        else
          write(v_print_line, "'" & to_string(allowed_values(i)) & "'");
        end if;
      end loop;
      alert(alert_level, procedure_name & " => Failed, tracked_value ("& to_string(tracked_value) &") was not one of " & v_print_line.all & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      DEALLOCATE(v_print_line);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(tracked_value) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_one_of_core;

  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : real;

    constant allowed_values : real_vector;
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_one_of()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : real;

    constant allowed_values : real_vector;
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_one_of()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  -- assert_one_of (time):
  function f_assert_one_of_core(
    tracked_value  : time;
    allowed_values : time_vector;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;

    function one_of(t : time; t_array : time_vector) return boolean is
      variable v_found : boolean := false;
    begin
      for i in t_array'range loop
        -- we check if the hex string is the same as the tracked value
        if t = t_array(i) then
          v_found := true;
          exit; -- we found a match, so we can exit the loop early
        end if;
      end loop;
      return v_found;
    end function one_of;

    variable v_print_line : line;

  begin
    if not one_of(tracked_value, allowed_values) then
      for i in allowed_values'range loop
        if i /= allowed_values'right then
          write(v_print_line, "'" & to_string(allowed_values(i), C_LOG_TIME_BASE) & "'" & "/");
        else
          write(v_print_line, "'" & to_string(allowed_values(i), C_LOG_TIME_BASE) & "'");
        end if;
      end loop;
      alert(alert_level, procedure_name & " => Failed, tracked_value (" & to_string(tracked_value, C_LOG_TIME_BASE) & ") was not one of " & v_print_line.all & ". Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      DEALLOCATE(v_print_line);
    else
      if pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value was " & to_string(tracked_value, C_LOG_TIME_BASE) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value was " & to_string(tracked_value, C_LOG_TIME_BASE) & ". Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_one_of_core;

  procedure assert_one_of(
    signal   ena            : std_logic;
    signal   tracked_value  : time;

    constant allowed_values : time_vector;
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_one_of()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  procedure assert_one_of(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : time;

    constant allowed_values : time_vector;
    constant msg            : string;
    constant alert_level    : t_alert_level  := ERROR;
    constant scope          : string         := C_SCOPE;
    constant pos_ack_kind   : t_pos_ack_kind := FIRST;
    constant msg_id         : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel   : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_one_of()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_one_of_core(tracked_value, allowed_values, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_of;

  -- #endregion ASSERT_ONE_OF

  -- #region ASSERT_ONE_HOT

  function f_assert_one_hot_core(
    tracked_value  : std_logic_vector;
    alert_level    : t_alert_level;
    msg            : string;
    accept_all_zero: t_accept_all_zeros;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean   := first_ack;
    variable v_all_zeros_check : boolean := false;

    function f_is_one_hot(slv : std_logic_vector) return boolean is
      variable v_found_one : boolean := false;
    begin

      for i in slv'range loop
        if slv(i) = '1' then
          if v_found_one then
            return false;
          else
            v_found_one := true;
          end if;
        end if;
      end loop;
      return v_found_one;
    end function f_is_one_hot;

    function f_is_all_zeros(slv : std_logic_vector) return boolean is
    begin

      for i in slv'range loop
        if slv(i) = '1' then
          return false;
        end if;
      end loop;
      return true;
    end function f_is_all_zeros;

  begin
    v_all_zeros_check := (accept_all_zero = ALL_ZERO_ALLOWED and f_is_all_zeros(tracked_value));
    if not (v_all_zeros_check or f_is_one_hot(tracked_value)) then
      alert(alert_level, procedure_name & " => Failed, tracked_value (" & to_string(tracked_value) & ") was not one-hot. Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
    elsif pos_ack_kind = FIRST and v_first_ack then
      log(msg_id, procedure_name & " => OK (first), tracked_value (" & to_string(tracked_value) & ") was one-hot. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      v_first_ack := false;
    elsif pos_ack_kind = EVERY then
      log(msg_id, procedure_name & " => OK, tracked_value (" & to_string(tracked_value) & ") was one-hot. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
    return v_first_ack;
  end function f_assert_one_hot_core;

  procedure assert_one_hot(
    signal   ena            : std_logic;
    signal   tracked_value   : std_logic_vector;

    constant msg             : string;
    constant alert_level     : t_alert_level      := ERROR;
    constant accept_all_zero : t_accept_all_zeros := ALL_ZERO_NOT_ALLOWED;
    constant scope           : string             := C_SCOPE;
    constant pos_ack_kind    : t_pos_ack_kind     := FIRST;
    constant msg_id          : t_msg_id           := ID_UVVM_ASSERTION;
    constant msg_id_panel    : t_msg_id_panel     := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_one_hot()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_one_hot_core(tracked_value, alert_level, msg, accept_all_zero, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_hot;

  procedure assert_one_hot(
    signal   clk             : std_logic;
    signal   ena             : std_logic;
    signal   tracked_value   : std_logic_vector;

    constant msg             : string;
    constant alert_level     : t_alert_level      := ERROR;
    constant accept_all_zero : t_accept_all_zeros := ALL_ZERO_NOT_ALLOWED;
    constant scope           : string             := C_SCOPE;
    constant pos_ack_kind    : t_pos_ack_kind     := FIRST;
    constant msg_id          : t_msg_id           := ID_UVVM_ASSERTION;
    constant msg_id_panel    : t_msg_id_panel     := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_one_hot()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then
      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_one_hot_core(tracked_value, alert_level, msg, accept_all_zero, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_one_hot;

  -- #endregion ASSERT_ONE_HOT

  -- #region ASSERT_VALUE_IN_RANGE

  function f_assert_value_in_range_core(
    tracked_value  : integer;
    ena            : std_logic;
    lower_limit    : integer;
    upper_limit    : integer;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if ena = '1' then

      -- sanity check
      if (upper_limit < lower_limit) then
        alert(alert_level, procedure_name & " => Failed, upper limit (" & to_string(upper_limit) & ") is less than lower limit (" & to_string(lower_limit) & "). Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      end if;

      if not (tracked_value >= lower_limit and tracked_value <= upper_limit) then
        alert(alert_level, procedure_name & " => Failed, tracked_value (" & to_string(tracked_value) & ") was not in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      elsif pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value (" & to_string(tracked_value) & ") was in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value (" & to_string(tracked_value) & ") was in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_in_range_core;

  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : integer;

    constant lower_limit   : integer; -- inclusive
    constant upper_limit   : integer; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME       : string  := "assert_value_in_range()";
    variable v_first_ack  : boolean := true;
    variable v_start_time : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_first_ack := f_assert_value_in_range_core(tracked_value, ena, lower_limit, upper_limit, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : integer;

    constant lower_limit   : integer; -- inclusive
    constant upper_limit   : integer; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME         : string  := "assert_value_in_range()";
    variable v_first_ack    : boolean := true;
    variable v_start_time   : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then

      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_first_ack := f_assert_value_in_range_core(tracked_value, ena, lower_limit, upper_limit, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : unsigned;

    constant lower_limit   : unsigned; -- inclusive
    constant upper_limit   : unsigned; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME              : string  := "assert_value_in_range()";
    variable v_first_ack         : boolean := true;
    variable v_start_time        : time    := 0 ns;
    variable v_tracked_value_int : integer;
    variable v_lower_limit_int   : integer := to_integer(lower_limit);
    variable v_upper_limit_int   : integer := to_integer(upper_limit);
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_tracked_value_int := to_integer(tracked_value);
        v_lower_limit_int   := to_integer(lower_limit); v_upper_limit_int := to_integer(upper_limit);
        v_first_ack := f_assert_value_in_range_core(v_tracked_value_int, ena, v_lower_limit_int, v_upper_limit_int, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : unsigned;

    constant lower_limit   : unsigned; -- inclusive
    constant upper_limit   : unsigned; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME              : string  := "assert_value_in_range()";
    variable v_first_ack         : boolean := true;
    variable v_start_time        : time    := 0 ns;
    variable v_tracked_value_int : integer;    
    variable v_lower_limit_int   : integer := to_integer(lower_limit);
    variable v_upper_limit_int   : integer := to_integer(upper_limit);
  begin
    if ena = '1' or rising_edge(clk) then

      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_tracked_value_int := to_integer(tracked_value);
          v_lower_limit_int   := to_integer(lower_limit); v_upper_limit_int := to_integer(upper_limit);
          v_first_ack := f_assert_value_in_range_core(v_tracked_value_int, ena, v_lower_limit_int, v_upper_limit_int, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : signed;

    constant lower_limit   : signed; -- inclusive
    constant upper_limit   : signed; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME              : string  := "assert_value_in_range()";
    variable v_first_ack         : boolean := true;
    variable v_start_time        : time    := 0 ns;
    variable v_tracked_value_int : integer;
    variable v_lower_limit_int   : integer := to_integer(lower_limit);
    variable v_upper_limit_int   : integer := to_integer(upper_limit);
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;

        v_tracked_value_int := to_integer(tracked_value);
        v_lower_limit_int   := to_integer(lower_limit); v_upper_limit_int := to_integer(upper_limit);
        v_first_ack := f_assert_value_in_range_core(v_tracked_value_int, ena, v_lower_limit_int, v_upper_limit_int, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : signed;

    constant lower_limit   : signed; -- inclusive
    constant upper_limit   : signed; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME              : string  := "assert_value_in_range()";
    variable v_first_ack         : boolean := true;
    variable v_start_time        : time    := 0 ns;
    variable v_tracked_value_int : integer;    
    variable v_lower_limit_int   : integer := to_integer(lower_limit);
    variable v_upper_limit_int   : integer := to_integer(upper_limit);
  begin
    if ena = '1' or rising_edge(clk) then

      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;

          v_tracked_value_int := to_integer(tracked_value);
          v_lower_limit_int   := to_integer(lower_limit); v_upper_limit_int := to_integer(upper_limit);
          v_first_ack := f_assert_value_in_range_core(v_tracked_value_int, ena, v_lower_limit_int, v_upper_limit_int, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  function f_assert_value_in_range_core(
    tracked_value  : real;
    ena            : std_logic;
    lower_limit    : real;
    upper_limit    : real;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if ena = '1' then

      -- sanity check
      if (upper_limit < lower_limit) then
        alert(alert_level, procedure_name & " => Failed, upper limit (" & to_string(upper_limit) & ") is less than lower limit (" & to_string(lower_limit) & "). Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      end if;

      if not (tracked_value >= lower_limit and tracked_value <= upper_limit) then
        alert(alert_level, procedure_name & " => Failed, tracked_value (" & to_string(tracked_value) & ") was not in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      elsif pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value (" & to_string(tracked_value) & ") was in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value (" & to_string(tracked_value) & ") was in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_in_range_core;

  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : real;

    constant lower_limit   : real; -- inclusive
    constant upper_limit   : real; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME              : string  := "assert_value_in_range()";
    variable v_first_ack         : boolean := true;
    variable v_start_time        : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;
        v_first_ack := f_assert_value_in_range_core(tracked_value, ena, lower_limit, upper_limit, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : real;

    constant lower_limit   : real; -- inclusive
    constant upper_limit   : real; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME              : string  := "assert_value_in_range()";
    variable v_first_ack         : boolean := true;
    variable v_start_time        : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then

      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;
          v_first_ack := f_assert_value_in_range_core(tracked_value, ena, lower_limit, upper_limit, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  function f_assert_value_in_range_core(
    tracked_value  : time;
    ena            : std_logic;
    lower_limit    : time;
    upper_limit    : time;
    alert_level    : t_alert_level;
    msg            : string;
    scope          : string;
    pos_ack_kind   : t_pos_ack_kind;
    msg_id         : t_msg_id;
    msg_id_panel   : t_msg_id_panel;
    procedure_name : string;
    elapsed_time   : time;
    first_ack      : boolean
  ) return boolean is
    variable v_first_ack     : boolean := first_ack;
  begin
    if ena = '1' then

      -- sanity check
      if (upper_limit < lower_limit) then
        alert(alert_level, procedure_name & " => Failed, upper limit (" & to_string(upper_limit) & ") is less than lower limit (" & to_string(lower_limit) & "). Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      end if;

      if not (tracked_value >= lower_limit and tracked_value <= upper_limit) then
        alert(alert_level, procedure_name & " => Failed, tracked_value (" & to_string(tracked_value) & ") was not in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope);
      elsif pos_ack_kind = FIRST and v_first_ack then
        log(msg_id, procedure_name & " => OK (first), tracked_value (" & to_string(tracked_value) & ") was in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
        v_first_ack := false;
      elsif pos_ack_kind = EVERY then
        log(msg_id, procedure_name & " => OK, tracked_value (" & to_string(tracked_value) & ") was in range [" & to_string(lower_limit) & ".." & to_string(upper_limit) & "]. Condition occurred after " & to_string(elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end if;
    return v_first_ack;
  end function f_assert_value_in_range_core;

  procedure assert_value_in_range(
    signal   ena           : std_logic;
    signal   tracked_value : time;

    constant lower_limit   : time; -- inclusive
    constant upper_limit   : time; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME              : string  := "assert_value_in_range()";
    variable v_first_ack         : boolean := true;
    variable v_start_time        : time    := 0 ns;
  begin
    if ena = '1' then
      loop
        -- we save the first time we enter the loop
        v_start_time := now when v_start_time = 0 ns else v_start_time;
        v_first_ack := f_assert_value_in_range_core(tracked_value, ena, lower_limit, upper_limit, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        -- we wait for signal events to not run the loop too fast
        wait until tracked_value'event or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;

  procedure assert_value_in_range(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : time;

    constant lower_limit   : time; -- inclusive
    constant upper_limit   : time; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME              : string  := "assert_value_in_range()";
    variable v_first_ack         : boolean := true;
    variable v_start_time        : time    := 0 ns;
  begin
    if ena = '1' or rising_edge(clk) then

      loop
        if rising_edge(clk) and ena = '1' then
          -- we save the first time there was a rising edge with tot_ena
          v_start_time := now when v_start_time = 0 ns else v_start_time;
          v_first_ack := f_assert_value_in_range_core(tracked_value, ena, lower_limit, upper_limit, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, now-v_start_time, v_first_ack);

        end if;
        -- we wait for rising edge (as this is the clk'ed version), but still allow for async disable
        wait until rising_edge(clk) or ena'event;
        if ena = '0' then
          exit; -- to exit the loop if the enable is not active
        end if;
      end loop;
    end if;
  end procedure assert_value_in_range;
  -- #endregion ASSERT_VALUE_IN_RANGE

  -- #region ASSERT_SHIFT_ONE_FROM_LEFT

  procedure assert_shift_one_from_left(
    signal   clk                 : std_logic;
    signal   ena                 : std_logic;
    signal   tracked_value       : std_logic_vector;

    constant necessary_condition : t_shift_one_ness_cond;
    constant msg                 : string;
    constant alert_level         : t_alert_level          := ERROR;
    constant scope               : string                 := C_SCOPE;
    constant pos_ack_kind        : t_pos_ack_kind         := FIRST;
    constant msg_id              : t_msg_id               := ID_UVVM_ASSERTION;
    constant msg_id_panel        : t_msg_id_panel         := shared_msg_id_panel
  ) is
    -- used for logging:
    constant C_NAME              : string                                  := "assert_shift_one_from_left()";
    variable v_first_alert       : boolean                                 := true;
    -- used for logic:
    variable v_active_pipe_arr   : t_boolean_array(tracked_value'range)    := (others => false);
    variable v_cycle_count_arr   : t_integer_array(tracked_value'range)    := (others => tracked_value'high);
    variable v_active_pipe_idx   : integer range 0 to tracked_value'length := tracked_value'high;
    variable v_print_cycle_count : integer range 0 to tracked_value'high + 1;
    variable v_print_pipe_num    : integer range 0 to tracked_value'high + 1;

    impure function string_of_tracked_with_x_value (position : integer)
    return string is
      variable v_tracked_temp : std_logic_vector(tracked_value'high downto 0);
    begin
      -- Initialize all positions to 'X'
      for i in v_tracked_temp'range loop
        v_tracked_temp(i) := 'X'; -- NOTE: is 'Z' better, as this is a "don't care" value?
      end loop;
      -- Set the specific position to '1'
      v_tracked_temp(position) := '1';
      return to_string(v_tracked_temp);
    end function string_of_tracked_with_x_value;
  begin

    loop
      wait until rising_edge(clk) or ena'event;
      if ena = '0' then
        exit; -- to exit the loop
      elsif rising_edge(clk) then
        -- new pipeline starts (the index overflows back to start when it reaches the end)
        if tracked_value(tracked_value'high) = '1' then
          v_active_pipe_arr(v_active_pipe_idx) := true;
          -- if we allow multiple pipelines, we update the index for the next pipeline
          if (necessary_condition = ANY_BIT_ALERT or necessary_condition = LAST_BIT_ALERT) then
            if v_active_pipe_idx > 0 then
              v_active_pipe_idx := v_active_pipe_idx - 1;
            else
              v_active_pipe_idx := tracked_value'high;
            end if;
          end if;
        end if;

        -- pipeline continues
        for i in tracked_value'range loop
          -- logging variables
          v_print_cycle_count := tracked_value'high - v_cycle_count_arr(i) + 1;
          v_print_pipe_num    := tracked_value'high - i + 1;

          -- if the pipeline is active, and the cycle count index of tracked_value is not '1', then we give a (possible) alert
          if tracked_value(v_cycle_count_arr(i)) /= '1' and v_active_pipe_arr(i) then
            -- if necessary_condition = (LAST BIT) then only give alert when the last bit is not '1'

            -- Differentiate between the different necessary conditions for alerting
            if necessary_condition = LAST_BIT_ALERT and v_cycle_count_arr(i) = 0 then
              alert(alert_level, C_NAME & " => Failed (pipeline num:" & to_string(v_print_pipe_num) &"). Last cycle bit was not '1' at the " & to_string(v_print_cycle_count) & "-cycle (last cycle). " & msg, C_SCOPE);
            elsif necessary_condition = LAST_BIT_ALERT_NO_PIPE and v_cycle_count_arr(i) = 0 then
              alert(alert_level, C_NAME & " => Failed. Last cycle bit was not '1' at the " & to_string(v_print_cycle_count) & "-cycle (last cycle). " & msg, C_SCOPE);
            elsif necessary_condition = ANY_BIT_ALERT then
              alert(alert_level, C_NAME & " => Failed (pipeline num:" & to_string(v_print_pipe_num) &"). tracked_value '" & to_string(tracked_value) & "' was not "& string_of_tracked_with_x_value(v_cycle_count_arr(i)) & " at the " & to_string(v_print_cycle_count) & "-cycle. " & msg, C_SCOPE);
            elsif necessary_condition = ANY_BIT_ALERT_NO_PIPE then
              alert(alert_level, C_NAME & " => Failed. tracked_value '" & to_string(tracked_value) & "' was not "& string_of_tracked_with_x_value(v_cycle_count_arr(i)) & " at the " & to_string(v_print_cycle_count) & "-cycle. " & msg, C_SCOPE);
            end if;

            -- reset the cycle count and active pipe for the pipeline
            v_cycle_count_arr(i) := tracked_value'high;
            v_active_pipe_arr(i) := false;
          elsif v_cycle_count_arr(i) > 0 and v_active_pipe_arr(i) then
            v_cycle_count_arr(i) := v_cycle_count_arr(i) - 1;
          elsif v_cycle_count_arr(i) = 0 and v_active_pipe_arr(i) then

            -- pos ack
            if pos_ack_kind = FIRST and v_first_alert then
              log(msg_id, C_NAME & " => OK (first). tracked_value '" & to_string(tracked_value) & "' had a full ripple from left to right. " & add_msg_delimiter(msg), scope, msg_id_panel);
              v_first_alert := false;
            elsif pos_ack_kind = EVERY then
              log(msg_id, C_NAME & " => OK. tracked_value '" & to_string(tracked_value) & "' had a full ripple from left to right. " & add_msg_delimiter(msg), scope, msg_id_panel);
            end if;

            v_cycle_count_arr(i) := tracked_value'high;
            v_active_pipe_arr(i) := false;
          end if;
        end loop;
      end if;
    end loop;
  end procedure assert_shift_one_from_left;

  procedure assert_shift_one_from_left(
    signal   clk                 : std_logic;
    signal   ena                 : std_logic;
    signal   tracked_value       : std_logic_vector;

    constant msg                 : string;
    constant alert_level         : t_alert_level          := ERROR;
    constant scope               : string                 := C_SCOPE;
    constant pos_ack_kind        : t_pos_ack_kind         := FIRST;
    constant msg_id              : t_msg_id               := ID_UVVM_ASSERTION;
    constant msg_id_panel        : t_msg_id_panel         := shared_msg_id_panel
  ) is
    constant C_NECESSARY_CONDITION : t_shift_one_ness_cond := ANY_BIT_ALERT;
  begin
    assert_shift_one_from_left(clk, ena, tracked_value, C_NECESSARY_CONDITION, msg, alert_level, scope, pos_ack_kind, msg_id, msg_id_panel);
  end procedure assert_shift_one_from_left;

  -- #endregion ASSERT_SHIFT_ONE_FROM_LEFT

  -- #region WINDOW_ASSERTIONS

  -- does not have an async variant, since its based on num-cycles (clk)
  procedure assert_min_to_max_cycles_after_trigger_core(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic;
    signal   trigger        : std_logic;

    constant min_cycles     : integer; -- inclusive
    constant max_cycles     : integer; -- inclusive
    constant exp_value      : std_logic;
    constant alert_level    : t_alert_level;
    constant msg            : string;
    constant scope          : string;
    constant pos_ack_kind   : t_pos_ack_kind;
    constant msg_id         : t_msg_id;
    constant msg_id_panel   : t_msg_id_panel;
    constant procedure_name : string; -- not included in documentation (only for internal use)
    constant window_type    : t_min_to_max_cycles_after_trigger
  ) is
    variable v_first_alert  : boolean := true;
    variable v_elapsed_time : time;

    type     t_time_array is array(natural range <>) of time;
    variable v_cycle_count_arr  : t_integer_array(0 to max_cycles) := (others => 0);
    variable v_trigger_time_arr : t_time_array(0 to max_cycles)    := (others => now);
    variable v_active_pipe_arr  : t_boolean_array(0 to max_cycles) := (others => false);
    variable v_pipe_check_ok    : t_boolean_array(0 to max_cycles) := (others => false);

    variable v_prev_tracked_value_arr : std_logic_vector(0 to max_cycles) := (others => tracked_value);
    variable v_when_changed_cycle     : t_integer_array(0 to max_cycles)  := (others => 0);

    variable v_pipe_index : integer range -1 to max_cycles := -1; -- default to -1 to start at 0

  begin

    loop
      wait until rising_edge(clk) or ena'event or trigger'event;
      if ena = '0' then
        exit; -- to exit the loop
      elsif rising_edge(clk) then

        if trigger = '1' then
          v_pipe_index                           := v_pipe_index + 1 when v_pipe_index < max_cycles else 0;
          v_trigger_time_arr(v_pipe_index)       := now;
          v_cycle_count_arr(v_pipe_index)        := 0;
          v_active_pipe_arr(v_pipe_index)        := true;
          v_prev_tracked_value_arr(v_pipe_index) := tracked_value;
        end if;

        for i in 0 to max_cycles loop
          if v_active_pipe_arr(i) then
            v_elapsed_time := now - v_trigger_time_arr(i);

            -- main logic:
            -- we check that we are inside the window, then check the type of the assertion
            if min_cycles <= v_cycle_count_arr(i) and v_cycle_count_arr(i) <= max_cycles then
              case window_type is
                when VALUE =>
                  if tracked_value /= exp_value then
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") was not equal to "& to_string(exp_value) &" after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & "(" & to_string(v_cycle_count_arr(i)) & "-cycles). " & add_msg_delimiter(msg), scope);
                    v_active_pipe_arr(i) := false; -- can stop checking this pipe
                  end if;
                when CHANGE =>
                  -- we do not allow a change (e.g 0->1) on the first win-cycle to count, as the change must happen in the window
                  if v_prev_tracked_value_arr(i) /= tracked_value then
                    -- there was a change, so we set the pipe to OK
                    v_pipe_check_ok(i)      := true;
                    v_when_changed_cycle(i) := v_cycle_count_arr(i);
                  end if;
                when CHANGE_TO_VALUE =>
                  -- we do not allow a change (e.g 0->1) on the first win-cycle to count, as the change must happen in the window
                  if (v_prev_tracked_value_arr(i) /= tracked_value and tracked_value = exp_value) then
                    -- there was a change to exp_value, so we set the pipe to OK
                    v_pipe_check_ok(i)      := true;
                    v_when_changed_cycle(i) := v_cycle_count_arr(i);
                  end if;
                when STABLE =>
                  if min_cycles = max_cycles then
                    -- if the window is 0 cycles (only one rising edge). we just flag the pipe as OK, since there cannot be any change
                    v_pipe_check_ok(i) := true;
                  end if;
                  if v_prev_tracked_value_arr(i) /= tracked_value then
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") was not stable after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & " (" & to_string(v_cycle_count_arr(i)) & "-cycles). " & add_msg_delimiter(msg), scope);
                    v_active_pipe_arr(i) := false; -- can stop checking this pipe
                  end if;
              end case;
            end if;
            if v_cycle_count_arr(i) = max_cycles or v_pipe_check_ok(i) then
              case window_type is
                when VALUE =>
                  -- we have already checked the pipe, so we can log the OK
                  if pos_ack_kind = FIRST and v_first_alert then
                    log(msg_id, procedure_name & " => OK (first). tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                    v_first_alert := false;
                  elsif pos_ack_kind = EVERY then
                    if i > 0 then
                      log(msg_id, procedure_name & " => OK. tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                    else
                        -- for pipe 0 we do not log the pipe number
                      log(msg_id, procedure_name & " => OK. tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                    end if;
                  end if;
                when CHANGE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  else
                    -- if there was never any change we log an error
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") never changed in window. " & add_msg_delimiter(msg), scope);
                  end if;
                when CHANGE_TO_VALUE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  else
                    -- if there was never any change we log an error
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") never changed to " & to_string(exp_value) & " in window. " & add_msg_delimiter(msg), scope);
                  end if;
                when STABLE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  end if;
              end case;
              v_active_pipe_arr(i) := false; -- can stop checking this pipe
            end if;

            -- update the previous value and cycle count for next clk-cycle
            v_prev_tracked_value_arr(i) := tracked_value;
            v_cycle_count_arr(i)        := v_cycle_count_arr(i) + 1;
          end if;
        end loop;
      end if;
    end loop;
  end procedure assert_min_to_max_cycles_after_trigger_core;

  procedure assert_value_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   trigger       : std_logic;

    constant min_cycles    : integer; -- inclusive
    constant max_cycles    : integer; -- inclusive
    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME : string := "assert_value_from_min_to_max_cycles_after_trigger()";
  begin
    assert_min_to_max_cycles_after_trigger_core(clk, ena, tracked_value, trigger, min_cycles, max_cycles, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, VALUE);
  end procedure assert_value_from_min_to_max_cycles_after_trigger;

  procedure assert_change_to_value_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   trigger       : std_logic;

    constant min_cycles    : integer; -- inclusive
    constant max_cycles    : integer; -- inclusive
    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME : string := "assert_change_to_value_from_min_to_max_cycles_after_trigger()";
  begin
    assert_min_to_max_cycles_after_trigger_core(clk, ena, tracked_value, trigger, min_cycles, max_cycles, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, change_to_value);
  end procedure assert_change_to_value_from_min_to_max_cycles_after_trigger;

  procedure assert_change_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   trigger       : std_logic;

    constant min_cycles    : integer; -- inclusive
    constant max_cycles    : integer; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME      : string    := "assert_change_from_min_to_max_cycles_after_trigger()";
    constant C_EXP_VALUE : std_logic := '1'; -- only needed for port mapping to core
  begin
    assert_min_to_max_cycles_after_trigger_core(clk, ena, tracked_value, trigger, min_cycles, max_cycles, C_EXP_VALUE, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, CHANGE);
  end procedure assert_change_from_min_to_max_cycles_after_trigger;

  procedure assert_stable_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   trigger       : std_logic;

    constant min_cycles    : integer; -- inclusive
    constant max_cycles    : integer; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME      : string    := "assert_stable_from_min_to_max_cycles_after_trigger()";
    constant C_EXP_VALUE : std_logic := '1'; -- only needed for port mapping
  begin
    assert_min_to_max_cycles_after_trigger_core(clk, ena, tracked_value, trigger, min_cycles, max_cycles, C_EXP_VALUE, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, STABLE);
  end procedure assert_stable_from_min_to_max_cycles_after_trigger;

  procedure assert_from_start_to_end_trigger_core(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic;
    signal   start_trigger  : std_logic;
    signal   end_trigger    : std_logic;

    constant exp_value      : std_logic;
    constant alert_level    : t_alert_level;
    constant msg            : string;
    constant scope          : string;
    constant pos_ack_kind   : t_pos_ack_kind;
    constant msg_id         : t_msg_id;
    constant msg_id_panel   : t_msg_id_panel;
    constant procedure_name : string; -- not included in documentation (only for internal use)
    constant window_type    : t_min_to_max_cycles_after_trigger
  ) is
    constant C_MIN_CYCLES : integer := 0; -- used to ignore the v_prev_tracked_value_arr on the first cycle
    constant C_MAX_CYCLES : integer := 1000; -- used to set the max pipelines. NOTE: hardcoded

    variable v_first_alert  : boolean := true;
    variable v_elapsed_time : time;

    type     t_time_array is array(natural range <>) of time;
    variable v_cycle_count_arr  : t_integer_array(0 to C_MAX_CYCLES) := (others => 0);
    variable v_trigger_time_arr : t_time_array(0 to C_MAX_CYCLES)    := (others => now);
    variable v_active_pipe_arr  : t_boolean_array(0 to C_MAX_CYCLES) := (others => false);
    variable v_pipe_check_ok    : t_boolean_array(0 to C_MAX_CYCLES) := (others => false);

    variable v_prev_tracked_value_arr : std_logic_vector(0 to C_MAX_CYCLES) := (others => tracked_value);
    variable v_when_changed_cycle     : t_integer_array(0 to C_MAX_CYCLES)  := (others => 0);

    variable v_pipe_index : integer range -1 to C_MAX_CYCLES := -1; -- default to -1 to start at 0

  begin

    loop
      wait until rising_edge(clk) or ena'event or start_trigger'event or end_trigger'event;
      if ena = '0' then
        exit; -- to exit the loop
      elsif rising_edge(clk) then
        if start_trigger = '1' then
          v_pipe_index                           := v_pipe_index + 1 when v_pipe_index < C_MAX_CYCLES else 0;
          v_trigger_time_arr(v_pipe_index)       := now;
          v_cycle_count_arr(v_pipe_index)        := 0;
          v_active_pipe_arr(v_pipe_index)        := true;
          v_prev_tracked_value_arr(v_pipe_index) := tracked_value;
        end if;

        for i in 0 to C_MAX_CYCLES loop
          if v_active_pipe_arr(i) then
            v_elapsed_time := now - v_trigger_time_arr(i);
            -- main logic:
            -- we check that we are inside the window, then check the type of the assertion
            case window_type is
              when VALUE =>
                if tracked_value /= exp_value then
                  alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") was not equal to " & to_string(exp_value) & " after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & "(" & to_string(v_cycle_count_arr(i)) & "-cycles). " & add_msg_delimiter(msg), scope);
                  v_active_pipe_arr(i) := false; -- can stop checking this pipe
                end if;
              when CHANGE =>
                -- we do not allow a change (e.g 0->1) on the first win-cycle to count, as the change must happen in the window
                if v_prev_tracked_value_arr(i) /= tracked_value then
                  -- there was a change, so we set the pipe to OK
                  v_pipe_check_ok(i)      := true;
                  v_when_changed_cycle(i) := v_cycle_count_arr(i);
                end if;
              when CHANGE_TO_VALUE =>
                -- we do not allow a change (e.g 0->1) on the first win-cycle to count, as the change must happen in the window
                if (v_prev_tracked_value_arr(i) /= tracked_value and tracked_value = exp_value) then
                  -- there was a change to exp_value, so we set the pipe to OK
                  v_pipe_check_ok(i)      := true;
                  v_when_changed_cycle(i) := v_cycle_count_arr(i);
                end if;
              when STABLE =>
                if v_prev_tracked_value_arr(i) /= tracked_value then
                  alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") was not stable after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & "(" & to_string(v_cycle_count_arr(i)) & "-cycles). " & add_msg_delimiter(msg), scope);
                  v_active_pipe_arr(i) := false; -- can stop checking this pipe
                end if;
            end case;
            if end_trigger = '1' or v_pipe_check_ok(i) then
              case window_type is
                when VALUE =>
                  -- if active pipe was not set to 0, then the window finished OK
                  if v_active_pipe_arr(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        -- for pipe 0 we do not log the pipe number
                        log(msg_id, procedure_name & " => OK. tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  end if;
                when CHANGE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  else
                    -- if there was never any change we log an error
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") never changed in window. " & add_msg_delimiter(msg), scope);
                  end if;
                when CHANGE_TO_VALUE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  else
                    -- if there was never any change we log an error
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") never changed to " & to_string(exp_value) & " in window. " & add_msg_delimiter(msg), scope);
                  end if;
                when STABLE =>
                  -- if active pipe was not set to 0, then the window finished OK
                  if v_active_pipe_arr(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  end if;
              end case;
              v_active_pipe_arr(i) := false; -- can stop checking this pipe now
            end if;

            -- update the previous value and cycle count for next clk-cycle
            v_prev_tracked_value_arr(i) := tracked_value;
            v_cycle_count_arr(i)        := v_cycle_count_arr(i) + 1;
          end if;
        end loop;
      end if;
    end loop;
  end procedure assert_from_start_to_end_trigger_core;

  procedure assert_value_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME : string := "assert_value_from_start_to_end_trigger()";
  begin
    assert_from_start_to_end_trigger_core(clk, ena, tracked_value, start_trigger, end_trigger, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, VALUE);
  end procedure assert_value_from_start_to_end_trigger;

  procedure assert_change_to_value_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant exp_value     : std_logic;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME : string := "assert_change_to_value_from_start_to_end_trigger()";
  begin
    assert_from_start_to_end_trigger_core(clk, ena, tracked_value, start_trigger, end_trigger, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, change_to_value);
  end procedure assert_change_to_value_from_start_to_end_trigger;

  procedure assert_change_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME      : string    := "assert_change_from_start_to_end_trigger()";
    constant C_EXP_VALUE : std_logic := '1'; -- only needed for port mapping
  begin
    assert_from_start_to_end_trigger_core(clk, ena, tracked_value, start_trigger, end_trigger, C_EXP_VALUE, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, CHANGE);
  end procedure assert_change_from_start_to_end_trigger;

  procedure assert_stable_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME      : string    := "assert_stable_from_start_to_end_trigger()";
    constant C_EXP_VALUE : std_logic := '1'; -- only needed for port mapping
  begin
    assert_from_start_to_end_trigger_core(clk, ena, tracked_value, start_trigger, end_trigger, C_EXP_VALUE, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, STABLE);
  end procedure assert_stable_from_start_to_end_trigger;


  procedure assert_min_to_max_cycles_after_trigger_core(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic_vector;
    signal   trigger        : std_logic;

    constant min_cycles     : integer; -- inclusive
    constant max_cycles     : integer; -- inclusive
    constant exp_value      : std_logic_vector;
    constant alert_level    : t_alert_level;
    constant msg            : string;
    constant scope          : string;
    constant pos_ack_kind   : t_pos_ack_kind;
    constant msg_id         : t_msg_id;
    constant msg_id_panel   : t_msg_id_panel;
    constant procedure_name : string; -- not included in documentation (only for internal use)
    constant window_type    : t_min_to_max_cycles_after_trigger
  ) is
    variable v_first_alert  : boolean := true;
    variable v_elapsed_time : time;

    type     t_time_array is array(natural range <>) of time;
    variable v_cycle_count_arr  : t_integer_array(0 to max_cycles) := (others => 0);
    variable v_trigger_time_arr : t_time_array(0 to max_cycles)    := (others => now);
    variable v_active_pipe_arr  : t_boolean_array(0 to max_cycles) := (others => false);
    variable v_pipe_check_ok    : t_boolean_array(0 to max_cycles) := (others => false);

    variable v_prev_tracked_value_arr : t_slv_array(0 to max_cycles)(tracked_value'range) := (others => tracked_value);
    variable v_when_changed_cycle     : t_integer_array(0 to max_cycles)                  := (others => 0);

    variable v_pipe_index : integer range -1 to max_cycles := -1; -- default to -1 to start at 0

  begin

    loop
      wait until rising_edge(clk) or ena'event or trigger'event;
      if ena = '0' then
        exit; -- to exit the loop
      elsif rising_edge(clk) then

        if trigger = '1' then
          v_pipe_index                           := v_pipe_index + 1 when v_pipe_index < max_cycles else 0;
          v_trigger_time_arr(v_pipe_index)       := now;
          v_cycle_count_arr(v_pipe_index)        := 0;
          v_active_pipe_arr(v_pipe_index)        := true;
          v_prev_tracked_value_arr(v_pipe_index) := tracked_value;
        end if;

        for i in 0 to max_cycles loop
          if v_active_pipe_arr(i) then
            v_elapsed_time := now - v_trigger_time_arr(i);

            -- main logic:
            -- we check that we are inside the window, then check the type of the assertion
            if min_cycles <= v_cycle_count_arr(i) and v_cycle_count_arr(i) <= max_cycles then
              case window_type is
                when VALUE =>
                  if tracked_value /= exp_value then
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") was not equal to " & to_string(exp_value) & " after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & "(" & to_string(v_cycle_count_arr(i)) & "-cycles). " & add_msg_delimiter(msg), scope);
                    v_active_pipe_arr(i) := false; -- can stop checking this pipe
                  end if;
                when CHANGE =>
                  -- we do not allow a change (e.g 0->1) on the first win-cycle to count, as the change must happen in the window
                  if v_prev_tracked_value_arr(i) /= tracked_value then
                    -- there was a change, so we set the pipe to OK
                    v_pipe_check_ok(i)      := true;
                    v_when_changed_cycle(i) := v_cycle_count_arr(i);
                  end if;
                when CHANGE_TO_VALUE =>
                  -- we do not allow a change (e.g 0->1) on the first win-cycle to count, as the change must happen in the window
                  if (v_prev_tracked_value_arr(i) /= tracked_value and tracked_value = exp_value) then
                    -- there was a change to exp_value, so we set the pipe to OK
                    v_pipe_check_ok(i)      := true;
                    v_when_changed_cycle(i) := v_cycle_count_arr(i);
                  end if;
                when STABLE =>
                  -- in the case of min_cycles = max_cycles, we just flag the pipe as OK, since there cannot be any change
                  v_pipe_check_ok(i) := (v_prev_tracked_value_arr(i) = tracked_value) and (min_cycles = max_cycles);
                  if v_prev_tracked_value_arr(i) /= tracked_value then
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") was not stable after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & "(" & to_string(v_cycle_count_arr(i)) & "-cycles). " & add_msg_delimiter(msg), scope);
                    v_active_pipe_arr(i) := false; -- can stop checking this pipe
                  end if;
              end case;
            end if;
            if v_cycle_count_arr(i) = max_cycles or v_pipe_check_ok(i) then
              case window_type is
                when VALUE =>
                  -- we have already checked the pipe, so we can log the OK
                  if pos_ack_kind = FIRST and v_first_alert then
                    log(msg_id, procedure_name & " => OK (first). tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                    v_first_alert := false;
                  elsif pos_ack_kind = EVERY then
                    if i > 0 then
                      log(msg_id, procedure_name & " => OK. tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". pipe: (" & to_string(i) & ")." & add_msg_delimiter(msg), scope, msg_id_panel);
                    else
                      log(msg_id, procedure_name & " => OK. tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                    end if;
                  end if;
                when CHANGE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". pipe: (" & to_string(i) & ")." & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  else
                    -- if there was never any change we log an error
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") never changed in window. " & add_msg_delimiter(msg), scope);
                  end if;
                when CHANGE_TO_VALUE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". pipe: (" & to_string(i) & ")." & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  else
                    -- if there was never any change we log an error
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") never changed to " & to_string(exp_value) & " in window. " & add_msg_delimiter(msg), scope);
                  end if;
                when STABLE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". pipe: (" & to_string(i) & ")." & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  end if;
              end case;
              v_active_pipe_arr(i) := false; -- can stop checking this pipe
            end if;

            -- update the previous value and cycle count for next clk-cycle
            v_prev_tracked_value_arr(i) := tracked_value;
            
            -- if we reached the max cycles, we can log an error (this is a niche case, as the window should end with an end_trigger normally)
            if v_cycle_count_arr(i) = C_MAX_CYCLES then
              case window_type is
                when VALUE =>
                  alert(alert_level, procedure_name & " => Failed. (timeout) tracked_value ("& to_string(tracked_value) &") never equal to " & to_string(exp_value) & " in window. " & add_msg_delimiter(msg), scope);
                when CHANGE =>
                  alert(alert_level, procedure_name & " => Failed. (timeout) tracked_value ("& to_string(tracked_value) &") never changed in window. " & add_msg_delimiter(msg), scope);
                when CHANGE_TO_VALUE =>
                  alert(alert_level, procedure_name & " => Failed. (timeout) tracked_value ("& to_string(tracked_value) &") never changed to " & to_string(exp_value) & " in window. " & add_msg_delimiter(msg), scope);
                when STABLE =>
                  -- we have already checked the pipe, so we can log the OK
                  if pos_ack_kind = FIRST and v_first_alert then
                    log(msg_id, procedure_name & " => OK (first+timeout). tracked_value was stable in window (WINDOW TIMED OUT). OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                    v_first_alert := false;
                  elsif pos_ack_kind = EVERY then
                    log(msg_id, procedure_name & " => OK. (timeout) tracked_value was stable in window (WINDOW TIMED OUT). OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                  end if;  
              end case;
              alert(TB_ERROR, "The window reached the maximum number of cycles (without end_trigger). To increase the maximum number of cycles, set the constant C_MAX_CYCLES in adaptations_pkg higher (this will increase memory usage).", scope);
              v_active_pipe_arr(i) := false; -- can stop checking this pipe
              v_cycle_count_arr(i) := 0; -- reset the cycle count for this pipe
            else
              v_cycle_count_arr(i)        := v_cycle_count_arr(i) + 1;
            end if;
          end if;
        end loop;
      end if;
    end loop;
  end procedure assert_min_to_max_cycles_after_trigger_core;

  procedure assert_value_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   trigger       : std_logic;

    constant min_cycles    : integer; -- inclusive
    constant max_cycles    : integer; -- inclusive
    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME : string := "assert_value_from_min_to_max_cycles_after_trigger()";
  begin
    assert_min_to_max_cycles_after_trigger_core(clk, ena, tracked_value, trigger, min_cycles, max_cycles, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, VALUE);
  end procedure assert_value_from_min_to_max_cycles_after_trigger;

  procedure assert_change_to_value_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   trigger       : std_logic;

    constant min_cycles    : integer; -- inclusive
    constant max_cycles    : integer; -- inclusive
    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME : string := "assert_change_to_value_from_min_to_max_cycles_after_trigger()";
  begin
    assert_min_to_max_cycles_after_trigger_core(clk, ena, tracked_value, trigger, min_cycles, max_cycles, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, change_to_value);
  end procedure assert_change_to_value_from_min_to_max_cycles_after_trigger;

  procedure assert_change_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   trigger       : std_logic;

    constant min_cycles    : integer; -- inclusive
    constant max_cycles    : integer; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME      : string    := "assert_change_from_min_to_max_cycles_after_trigger()";
    constant C_EXP_VALUE : std_logic_vector(tracked_value'range) := (others => '1'); -- only needed for port mapping to core
  begin
    assert_min_to_max_cycles_after_trigger_core(clk, ena, tracked_value, trigger, min_cycles, max_cycles, C_EXP_VALUE, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, CHANGE);
  end procedure assert_change_from_min_to_max_cycles_after_trigger;

  procedure assert_stable_from_min_to_max_cycles_after_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   trigger       : std_logic;

    constant min_cycles    : integer; -- inclusive
    constant max_cycles    : integer; -- inclusive
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME      : string    := "assert_stable_from_min_to_max_cycles_after_trigger()";
    constant C_EXP_VALUE : std_logic_vector(tracked_value'range) := (others => '1'); -- only needed for port mapping
  begin
    assert_min_to_max_cycles_after_trigger_core(clk, ena, tracked_value, trigger, min_cycles, max_cycles, C_EXP_VALUE, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, STABLE);
  end procedure assert_stable_from_min_to_max_cycles_after_trigger;

  procedure assert_from_start_to_end_trigger_core(
    signal   clk            : std_logic;
    signal   ena            : std_logic;
    signal   tracked_value  : std_logic_vector;
    signal   start_trigger  : std_logic;
    signal   end_trigger    : std_logic;

    constant exp_value      : std_logic_vector;
    constant alert_level    : t_alert_level;
    constant msg            : string;
    constant scope          : string;
    constant pos_ack_kind   : t_pos_ack_kind;
    constant msg_id         : t_msg_id;
    constant msg_id_panel   : t_msg_id_panel;
    constant procedure_name : string; -- not included in documentation (only for internal use)
    constant window_type    : t_min_to_max_cycles_after_trigger
  ) is
    constant C_MIN_CYCLES : integer := 0; -- used to ignore the v_prev_tracked_value_arr on the first cycle
    variable v_first_alert  : boolean := true;
    variable v_elapsed_time : time;

    type     t_time_array is array(natural range <>) of time;
    variable v_cycle_count_arr  : t_integer_array(0 to C_MAX_CYCLES) := (others => 0);
    variable v_trigger_time_arr : t_time_array(0 to C_MAX_CYCLES)    := (others => now);
    variable v_active_pipe_arr  : t_boolean_array(0 to C_MAX_CYCLES) := (others => false);
    variable v_pipe_check_ok    : t_boolean_array(0 to C_MAX_CYCLES) := (others => false);

    variable v_prev_tracked_value_arr : t_slv_array(0 to C_MAX_CYCLES)(tracked_value'range) := (others => tracked_value);
    variable v_when_changed_cycle     : t_integer_array(0 to C_MAX_CYCLES)  := (others => 0);

    variable v_pipe_index : integer range -1 to C_MAX_CYCLES := -1; -- default to -1 to start at 0

  begin

    loop
      wait until rising_edge(clk) or ena'event or start_trigger'event or end_trigger'event;
      if ena = '0' then
        exit; -- to exit the loop
      elsif rising_edge(clk) then
        if start_trigger = '1' then
          v_pipe_index                           := v_pipe_index + 1 when v_pipe_index < C_MAX_CYCLES else 0;
          v_trigger_time_arr(v_pipe_index)       := now;
          v_cycle_count_arr(v_pipe_index)        := 0;
          v_active_pipe_arr(v_pipe_index)        := true;
          v_prev_tracked_value_arr(v_pipe_index) := tracked_value;
        end if;

        for i in 0 to C_MAX_CYCLES loop
          if v_active_pipe_arr(i) then
            v_elapsed_time := now - v_trigger_time_arr(i);
            -- main logic:
            -- we check that we are inside the window, then check the type of the assertion
            case window_type is
              when VALUE =>
                if tracked_value /= exp_value then
                  alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") was not equal to " & to_string(exp_value) & " after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & "(" & to_string(v_cycle_count_arr(i)) & "-cycles). " & add_msg_delimiter(msg), scope);
                  v_active_pipe_arr(i) := false; -- can stop checking this pipe
                end if;
              when CHANGE =>
                -- we do not allow a change (e.g 0->1) on the first win-cycle to count, as the change must happen in the window
                if v_prev_tracked_value_arr(i) /= tracked_value then
                  -- there was a change, so we set the pipe to OK
                  v_pipe_check_ok(i)      := true;
                  v_when_changed_cycle(i) := v_cycle_count_arr(i);
                end if;
              when change_to_value =>
                -- we do not allow a change (e.g 0->1) on the first win-cycle to count, as the change must happen in the window
                if (v_prev_tracked_value_arr(i) /= tracked_value and tracked_value = exp_value) then
                  -- there was a change to exp_value, so we set the pipe to OK
                  v_pipe_check_ok(i)      := true;
                  v_when_changed_cycle(i) := v_cycle_count_arr(i);
                end if;
              when STABLE =>
                if v_prev_tracked_value_arr(i) /= tracked_value then
                  alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") was not stable after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & "(" & to_string(v_cycle_count_arr(i)) & "-cycles). " & add_msg_delimiter(msg), scope);
                  v_active_pipe_arr(i) := false; -- can stop checking this pipe
                end if;
            end case;
            if end_trigger = '1' or v_pipe_check_ok(i) then
              case window_type is
                when VALUE =>
                  -- if active pipe was not set to 0, then the window finished OK
                  if v_active_pipe_arr(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value was equal to expected value in entire window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  end if;
                when CHANGE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value had a change in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  else
                    -- if there was never any change we log an error
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") never changed in window. " & add_msg_delimiter(msg), scope);
                  end if;
                when CHANGE_TO_VALUE =>
                  if v_pipe_check_ok(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value had a change to " & to_string(exp_value) & " in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". First change event happened in cycle-" & to_string(v_when_changed_cycle(i)) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  else
                    -- if there was never any change we log an error
                    alert(alert_level, procedure_name & " => Failed. tracked_value ("& to_string(tracked_value) &") never changed to " & to_string(exp_value) & " in window. " & add_msg_delimiter(msg), scope);
                  end if;
                when STABLE =>
                  -- if active pipe was not set to 0, then the window finished OK
                  if v_active_pipe_arr(i) then
                    -- we have already checked the pipe, so we can log the OK
                    if pos_ack_kind = FIRST and v_first_alert then
                      log(msg_id, procedure_name & " => OK (first). tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      v_first_alert := false;
                    elsif pos_ack_kind = EVERY then
                      if i > 0 then
                        log(msg_id, procedure_name & " => OK. tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". pipe: (" & to_string(i) & "). " & add_msg_delimiter(msg), scope, msg_id_panel);
                      else
                        log(msg_id, procedure_name & " => OK. tracked_value was stable in window. OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                      end if;
                    end if;
                  end if;
              end case;
              v_active_pipe_arr(i) := false; -- can stop checking this pipe now
            end if;

            -- update the previous value and cycle count for next clk-cycle
            v_prev_tracked_value_arr(i) := tracked_value;
            
            -- if we reached the max cycles, we can log an error (this is a niche case, as the window should end with an end_trigger normally)
            if v_cycle_count_arr(i) = C_MAX_CYCLES then
              case window_type is
                when VALUE =>
                  alert(alert_level, procedure_name & " => Failed. (timeout) tracked_value ("& to_string(tracked_value) &") never equal to " & to_string(exp_value) & " in window. " & add_msg_delimiter(msg), scope);
                when CHANGE =>
                  alert(alert_level, procedure_name & " => Failed. (timeout) tracked_value ("& to_string(tracked_value) &") never changed in window. " & add_msg_delimiter(msg), scope);
                when change_to_value =>
                  alert(alert_level, procedure_name & " => Failed. (timeout) tracked_value ("& to_string(tracked_value) &") never changed to " & to_string(exp_value) & " in window. " & add_msg_delimiter(msg), scope);
                when STABLE =>
                  -- we have already checked the pipe, so we can log the OK
                  if pos_ack_kind = FIRST and v_first_alert then
                    log(msg_id, procedure_name & " => OK (first+timeout). tracked_value was stable in window (WINDOW TIMED OUT). OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                    v_first_alert := false;
                  elsif pos_ack_kind = EVERY then
                    log(msg_id, procedure_name & " => OK. (timeout) tracked_value was stable in window (WINDOW TIMED OUT). OK after " & to_string(v_elapsed_time, C_LOG_TIME_BASE) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
                  end if;  
              end case;
              alert(TB_ERROR, "The window reached the maximum number of cycles (without end_trigger). To increase the maximum number of cycles, set the constant C_MAX_CYCLES in adaptations_pkg higher (this will increase memory usage).", scope);
              v_active_pipe_arr(i) := false; -- can stop checking this pipe
              v_cycle_count_arr(i) := 0; -- reset the cycle count for this pipe
            else
              v_cycle_count_arr(i)        := v_cycle_count_arr(i) + 1;
            end if;
          end if;
        end loop;
      end if;
    end loop;
  end procedure assert_from_start_to_end_trigger_core;

  procedure assert_value_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME : string := "assert_value_from_start_to_end_trigger()";
  begin
    assert_from_start_to_end_trigger_core(clk, ena, tracked_value, start_trigger, end_trigger, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, VALUE);
  end procedure assert_value_from_start_to_end_trigger;

  procedure assert_change_to_value_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant exp_value     : std_logic_vector;
    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME : string := "assert_change_to_value_from_start_to_end_trigger()";
  begin
    assert_from_start_to_end_trigger_core(clk, ena, tracked_value, start_trigger, end_trigger, exp_value, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, change_to_value);
  end procedure assert_change_to_value_from_start_to_end_trigger;

  procedure assert_change_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME      : string    := "assert_change_from_start_to_end_trigger()";
    constant C_EXP_VALUE : std_logic_vector(tracked_value'range) := (others => '1'); -- only needed for port mapping to core
  begin
    assert_from_start_to_end_trigger_core(clk, ena, tracked_value, start_trigger, end_trigger, C_EXP_VALUE, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, CHANGE);
  end procedure assert_change_from_start_to_end_trigger;

  procedure assert_stable_from_start_to_end_trigger(
    signal   clk           : std_logic;
    signal   ena           : std_logic;
    signal   tracked_value : std_logic_vector;
    signal   start_trigger : std_logic;
    signal   end_trigger   : std_logic;

    constant msg           : string;
    constant alert_level   : t_alert_level  := ERROR;
    constant scope         : string         := C_SCOPE;
    constant pos_ack_kind  : t_pos_ack_kind := FIRST;
    constant msg_id        : t_msg_id       := ID_UVVM_ASSERTION;
    constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_NAME      : string    := "assert_stable_from_start_to_end_trigger()";
    constant C_EXP_VALUE : std_logic_vector(tracked_value'range) := (others => '1'); -- only needed for port mapping to core
  begin
    assert_from_start_to_end_trigger_core(clk, ena, tracked_value, start_trigger, end_trigger, C_EXP_VALUE, alert_level, msg, scope, pos_ack_kind, msg_id, msg_id_panel, C_NAME, STABLE);
  end procedure assert_stable_from_start_to_end_trigger;
-- #endregion WINDOW_ASSERTIONS

end package body uvvm_assertions_pkg;

