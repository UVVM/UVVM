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

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.string_methods_pkg.all;
use work.global_signals_and_shared_variables_pkg.all;
use work.methods_pkg.all;

package rand_pkg is

  --Q: move to adaptations_pkg?
  constant C_INIT_SEED_1 : positive := 10;
  constant C_INIT_SEED_2 : positive := 100;

  ------------------------------------------------------------
  -- Types
  ------------------------------------------------------------
  type t_rand_dist is (UNIFORM, GAUSSIAN);
  type t_set_type is (ONLY, INCL, EXCL);
  type t_uniqueness is (UNIQUE, NON_UNIQUE);
  type t_weight_mode is (NA, COMBINED_WEIGHT, INDIVIDUAL_WEIGHT);
  type t_cyclic is (CYCLIC, NON_CYCLIC);
  type t_cyclic_list is array (integer range <>) of std_logic;
  type t_cyclic_list_ptr is access t_cyclic_list;

  type t_val_weight_int is record
    value     : integer;
    weight    : natural;
  end record;
  type t_range_weight_int is record
    min_value : integer;
    max_value : integer;
    weight    : natural;
  end record;
  type t_range_weight_mode_int is record
    min_value : integer;
    max_value : integer;
    weight    : natural;
    mode      : t_weight_mode;
  end record;

  type t_val_weight_real is record
    value     : real;
    weight    : natural;
  end record;
  type t_range_weight_real is record
    min_value : real;
    max_value : real;
    weight    : natural;
  end record;
  type t_range_weight_mode_real is record
    min_value : real;
    max_value : real;
    weight    : natural;
    mode      : t_weight_mode;
  end record;

  type t_val_weight_time is record
    value     : time;
    weight    : natural;
  end record;
  type t_range_weight_time is record
    min_value : time;
    max_value : time;
    weight    : natural;
  end record;
  type t_range_weight_mode_time is record
    min_value : time;
    max_value : time;
    weight    : natural;
    mode      : t_weight_mode;
  end record;

  type t_val_weight_int_vec         is array (natural range <>) of t_val_weight_int;
  type t_range_weight_int_vec       is array (natural range <>) of t_range_weight_int;
  type t_range_weight_mode_int_vec  is array (natural range <>) of t_range_weight_mode_int;

  type t_val_weight_real_vec         is array (natural range <>) of t_val_weight_real;
  type t_range_weight_real_vec       is array (natural range <>) of t_range_weight_real;
  type t_range_weight_mode_real_vec  is array (natural range <>) of t_range_weight_mode_real;

  type t_val_weight_time_vec         is array (natural range <>) of t_val_weight_time;
  type t_range_weight_time_vec       is array (natural range <>) of t_range_weight_time;
  type t_range_weight_mode_time_vec  is array (natural range <>) of t_range_weight_mode_time;

  ------------------------------------------------------------
  -- Base procedures
  ------------------------------------------------------------
  alias random_uniform is random[integer, integer, positive, positive, integer];
  alias random_uniform is random[real, real, positive, positive, real];
  alias random_uniform is random[time, time, positive, positive, time];

  -- Returns a real pseudo-random number with Gaussian distribution.
  -- It uses the Marsaglia polar method to generate a normally distributed
  -- random number from uniformly distributed random numbers.
  procedure gaussian(
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real);

  -- Returns an integer pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in    integer;
    constant max_value     : in    integer;
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout integer);

  -- Returns a real pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in    real;
    constant max_value     : in    real;
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real);

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_rand is protected

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_rand_dist(
      constant rand_dist : in t_rand_dist);

    impure function get_rand_dist(
      constant VOID : t_void)
    return t_rand_dist;

    procedure set_range_weight_default_mode(
      constant mode : in t_weight_mode);

    impure function get_range_weight_default_mode(
      constant VOID : t_void)
    return t_weight_mode;

    procedure set_scope(
      constant scope : in string);

    impure function get_scope(
      constant VOID : t_void)
    return string;

    procedure clear_rand_cyclic(
      constant VOID : t_void);

    ------------------------------------------------------------
    -- Randomization seeds
    ------------------------------------------------------------
    procedure set_rand_seeds(
      constant str : in string);
    
    procedure set_rand_seeds(
      constant seed1 : in positive;
      constant seed2 : in positive);

    procedure set_rand_seeds(
      constant seeds : in t_positive_vector(0 to 1));

    procedure get_rand_seeds(
      variable seed1 : out positive;
      variable seed2 : out positive);

    impure function get_rand_seeds(
      constant VOID : t_void)
    return t_positive_vector;

    ------------------------------------------------------------
    -- Random integer
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    ------------------------------------------------------------
    -- Random real
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_value     : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_value2    : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_values1   : real_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    ------------------------------------------------------------
    -- Random time
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_value     : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_value2    : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_values1   : time_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    ------------------------------------------------------------
    -- Random integer_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector;

    ------------------------------------------------------------
    -- Random real_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_value     : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_value2    : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_values1   : real_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector;

    ------------------------------------------------------------
    -- Random time_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_value     : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_value2    : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_values1   : time_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector;

    ------------------------------------------------------------
    -- Random unsigned
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_value2    : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_values1   : t_natural_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    ------------------------------------------------------------
    -- Random signed
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    ------------------------------------------------------------
    -- Random std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_value2    : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_values1   : t_natural_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    ------------------------------------------------------------
    -- Random std_logic & boolean
    ------------------------------------------------------------
    impure function rand(
      constant VOID          : t_void;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic;

    impure function rand(
      constant VOID          : t_void;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return boolean;

    ------------------------------------------------------------
    -- Random weighted integer
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weight_vector : t_val_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand_range_weight(
      constant weight_vector : t_range_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    impure function rand_range_weight_mode(
      constant weight_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer;

    ------------------------------------------------------------
    -- Random weighted real
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weight_vector : t_val_weight_real_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand_range_weight(
      constant weight_vector : t_range_weight_real_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    impure function rand_range_weight_mode(
      constant weight_vector : t_range_weight_mode_real_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real;

    ------------------------------------------------------------
    -- Random weighted time
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weight_vector : t_val_weight_time_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand_range_weight(
      constant weight_vector : t_range_weight_time_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    impure function rand_range_weight_mode(
      constant weight_vector : t_range_weight_mode_time_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time;

    ------------------------------------------------------------
    -- Random weighted unsigned
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length        : positive;
      constant weight_vector : t_val_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand_range_weight(
      constant length        : positive;
      constant weight_vector : t_range_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    impure function rand_range_weight_mode(
      constant length        : positive;
      constant weight_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned;

    ------------------------------------------------------------
    -- Random weighted signed
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length        : positive;
      constant weight_vector : t_val_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand_range_weight(
      constant length        : positive;
      constant weight_vector : t_range_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    impure function rand_range_weight_mode(
      constant length        : positive;
      constant weight_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed;

    ------------------------------------------------------------
    -- Random weighted std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length        : positive;
      constant weight_vector : t_val_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand_range_weight(
      constant length        : positive;
      constant weight_vector : t_range_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

    impure function rand_range_weight_mode(
      constant length        : positive;
      constant weight_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector;

  end protected t_rand;

end package rand_pkg;

package body rand_pkg is

  ------------------------------------------------------------
  -- Base procedures
  ------------------------------------------------------------
  -- Returns a real pseudo-random number with Gaussian distribution.
  -- It uses the Marsaglia polar method to generate a normally distributed
  -- random number from uniformly distributed random numbers.
  procedure gaussian(
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real) is
    variable v_u     : real;
    variable v_v     : real;
    variable v_s     : real;
    variable v_valid : boolean := false;
  begin
    while not(v_valid) loop
      random_uniform(-1.0, 1.0, seed1, seed2, v_u);
      random_uniform(-1.0, 1.0, seed1, seed2, v_v);
      v_s     := v_u*v_u + v_v*v_v;
      v_valid := v_s > 0.0 and v_s < 1.0;
    end loop;
    target := mean + std_deviation * v_u * sqrt((-2.0 * log(v_s))/v_s);
  end procedure;

  -- Returns an integer pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in    integer;
    constant max_value     : in    integer;
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout integer) is
    variable v_rand  : real;
    variable v_valid : boolean := false;
  begin
    while not(v_valid) loop
      gaussian(mean, std_deviation, seed1, seed2, v_rand);
      target  := integer(round(v_rand));
      v_valid := target >= min_value and target <= max_value;
    end loop;
  end procedure;

  -- Returns a real pseudo-random number with Gaussian distribution within a specified range.
  procedure random_gaussian(
    constant min_value     : in    real;
    constant max_value     : in    real;
    constant mean          : in    real;
    constant std_deviation : in    real;
    variable seed1         : inout positive;
    variable seed2         : inout positive;
    variable target        : inout real) is
    variable v_valid : boolean := false;
  begin
    while not(v_valid) loop
      gaussian(mean, std_deviation, seed1, seed2, target);
      v_valid := target >= min_value and target <= max_value;
    end loop;
  end procedure;

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_rand is protected body
    variable priv_scope                   : line              := new string'(C_SCOPE);
    variable priv_seed1                   : positive          := C_INIT_SEED_1;
    variable priv_seed2                   : positive          := C_INIT_SEED_2;
    variable priv_rand_dist               : t_rand_dist       := UNIFORM;
    variable priv_weight_mode             : t_weight_mode     := COMBINED_WEIGHT;
    variable priv_warned_same_set_type    : boolean           := false;
    variable priv_cyclic_current_function : line              := new string'("");
    variable priv_cyclic_list             : t_cyclic_list_ptr;
    variable priv_cyclic_list_num_items   : natural           := 0;

    ------------------------------------------------------------
    -- Internal functions and procedures
    ------------------------------------------------------------
    -- Returns the string representation of the weight vector, e.g.
    --   (10,30),([20:30],30,COMBINED),(40,50)
    impure function to_string(
      constant weight_vector : t_range_weight_mode_int_vec)
    return string is
      alias normalized_weight_vector : t_range_weight_mode_int_vec(0 to weight_vector'length-1) is weight_vector;
      variable v_line    : line;
      variable v_str     : string(1 to 500);
      variable v_str_len : natural;
    begin
      for i in normalized_weight_vector'range loop
        if normalized_weight_vector(i).min_value = normalized_weight_vector(i).max_value then
          write(v_line, '(');
          write(v_line, to_string(normalized_weight_vector(i).min_value));
          write(v_line, ',');
          write(v_line, to_string(normalized_weight_vector(i).weight));
          write(v_line, ')');
        else
          write(v_line, string'("(["));
          write(v_line, to_string(normalized_weight_vector(i).min_value));
          write(v_line, ':');
          write(v_line, to_string(normalized_weight_vector(i).max_value));
          write(v_line, string'("],"));
          write(v_line, to_string(normalized_weight_vector(i).weight));
          if normalized_weight_vector(i).mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif normalized_weight_vector(i).mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          elsif priv_weight_mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif priv_weight_mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          end if;
          write(v_line, ')');
        end if;
        if i < normalized_weight_vector'length-1 then
          write(v_line, ',');
        end if;
      end loop;

      v_str_len := v_line.all'length;
      v_str(1 to v_str_len) := v_line.all;
      DEALLOCATE(v_line);
      return v_str(1 to v_str_len);
    end function;

    -- Overload
    impure function to_string(
      constant weight_vector : t_range_weight_mode_real_vec)
    return string is
      alias normalized_weight_vector : t_range_weight_mode_real_vec(0 to weight_vector'length-1) is weight_vector;
      variable v_line    : line;
      variable v_str     : string(1 to 500);
      variable v_str_len : natural;
    begin
      for i in normalized_weight_vector'range loop
        if normalized_weight_vector(i).min_value = normalized_weight_vector(i).max_value then
          write(v_line, '(');
          write(v_line, to_string(normalized_weight_vector(i).min_value));
          write(v_line, ',');
          write(v_line, to_string(normalized_weight_vector(i).weight));
          write(v_line, ')');
        else
          write(v_line, string'("(["));
          write(v_line, to_string(normalized_weight_vector(i).min_value));
          write(v_line, ':');
          write(v_line, to_string(normalized_weight_vector(i).max_value));
          write(v_line, string'("],"));
          write(v_line, to_string(normalized_weight_vector(i).weight));
          if normalized_weight_vector(i).mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif normalized_weight_vector(i).mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          elsif priv_weight_mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif priv_weight_mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          end if;
          write(v_line, ')');
        end if;
        if i < normalized_weight_vector'length-1 then
          write(v_line, ',');
        end if;
      end loop;

      v_str_len := v_line.all'length;
      v_str(1 to v_str_len) := v_line.all;
      DEALLOCATE(v_line);
      return v_str(1 to v_str_len);
    end function;

    -- Overload
    impure function to_string(
      constant weight_vector : t_range_weight_mode_time_vec)
    return string is
      alias normalized_weight_vector : t_range_weight_mode_time_vec(0 to weight_vector'length-1) is weight_vector;
      variable v_line    : line;
      variable v_str     : string(1 to 500);
      variable v_str_len : natural;
    begin
      for i in normalized_weight_vector'range loop
        if normalized_weight_vector(i).min_value = normalized_weight_vector(i).max_value then
          write(v_line, '(');
          write(v_line, to_string(normalized_weight_vector(i).min_value));
          write(v_line, ',');
          write(v_line, to_string(normalized_weight_vector(i).weight));
          write(v_line, ')');
        else
          write(v_line, string'("(["));
          write(v_line, to_string(normalized_weight_vector(i).min_value));
          write(v_line, ':');
          write(v_line, to_string(normalized_weight_vector(i).max_value));
          write(v_line, string'("],"));
          write(v_line, to_string(normalized_weight_vector(i).weight));
          if normalized_weight_vector(i).mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif normalized_weight_vector(i).mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          elsif priv_weight_mode = INDIVIDUAL_WEIGHT then
            write(v_line, string'(",INDIVIDUAL"));
          elsif priv_weight_mode = COMBINED_WEIGHT then
            write(v_line, string'(",COMBINED"));
          end if;
          write(v_line, ')');
        end if;
        if i < normalized_weight_vector'length-1 then
          write(v_line, ',');
        end if;
      end loop;

      v_str_len := v_line.all'length;
      v_str(1 to v_str_len) := v_line.all;
      DEALLOCATE(v_line);
      return v_str(1 to v_str_len);
    end function;

    -- Returns true if a value is contained in a vector
    function check_value_in_vector(
      constant value  : integer;
      constant vector : integer_vector)
    return boolean is
      variable v_found : boolean := false;
    begin
      for i in vector'range loop
        if value = vector(i) then
          v_found := true;
          exit;
        end if;
      end loop;
      return v_found;
    end function;

    -- Overload
    function check_value_in_vector(
      constant value  : real;
      constant vector : real_vector)
    return boolean is
      variable v_found : boolean := false;
    begin
      for i in vector'range loop
        if value = vector(i) then
          v_found := true;
          exit;
        end if;
      end loop;
      return v_found;
    end function;

    -- Overload
    function check_value_in_vector(
      constant value  : time;
      constant vector : time_vector)
    return boolean is
      variable v_found : boolean := false;
    begin
      for i in vector'range loop
        if value = vector(i) then
          v_found := true;
          exit;
        end if;
      end loop;
      return v_found;
    end function;

    -- Logs the procedure call unless it is called from another
    -- procedure to avoid duplicate logs. It also generates the
    -- correct procedure call to be used for logging or alerts.
    procedure log_proc_call(
      constant msg_id          : in    t_msg_id;
      constant proc_call       : in    string;
      constant ext_proc_call   : in    string;
      variable new_proc_call   : inout line;
      constant msg_id_panel    : in    t_msg_id_panel;
      constant print_log       : in    boolean := true) is
    begin
      -- Called directly from sequencer/VVC
      if ext_proc_call = "" then
        log(msg_id, proc_call, priv_scope.all, msg_id_panel);
        write(new_proc_call, proc_call);
      -- Called from another procedure
      else
        write(new_proc_call, ext_proc_call);
      end if;
    end procedure;

    -- Generates the correct procedure call to be used for logging or alerts
    procedure create_proc_call(
      constant proc_call       : in    string;
      constant ext_proc_call   : in    string;
      variable new_proc_call   : inout line) is
    begin
      log_proc_call(ID_NEVER, proc_call, ext_proc_call, new_proc_call, shared_msg_id_panel, false);
    end procedure;

    -- Checks that the parameters are within a valid range
    -- for the given length
    procedure check_parameters_within_range(
      constant length        : in natural;
      constant min_value     : in integer;
      constant max_value     : in integer;
      constant msg_id_panel  : in t_msg_id_panel;
      constant signed_values : in boolean) is
      constant C_PROC_NAME : string := "check_parameters_within_range";
      variable v_len : natural;
    begin
      v_len := length when length < 32 else
               31 when not(signed_values) else 32; -- Length is limited by integer size
      if signed_values then
        check_value_in_range(min_value, -2**(v_len-1), 2**(v_len-1)-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope.all, ID_NEVER, msg_id_panel, C_PROC_NAME);
        check_value_in_range(max_value, -2**(v_len-1), 2**(v_len-1)-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope.all, ID_NEVER, msg_id_panel, C_PROC_NAME);
      else
        check_value_in_range(min_value, 0, 2**v_len-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope.all, ID_NEVER, msg_id_panel, C_PROC_NAME);
        check_value_in_range(max_value, 0, 2**v_len-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope.all, ID_NEVER, msg_id_panel, C_PROC_NAME);
      end if;
    end procedure;

    -- Overload
    procedure check_parameters_within_range(
      constant length        : in natural;
      constant set_values    : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel;
      constant signed_values : in boolean) is
      constant C_PROC_NAME : string := "check_parameters_within_range";
      variable v_len : natural;
    begin
      v_len := length when length < 32 else
               31 when not(signed_values) else 32; -- Length is limited by integer size
      for i in set_values'range loop
        if signed_values then
          check_value_in_range(set_values(i), -2**(v_len-1), 2**(v_len-1)-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope.all, ID_NEVER, msg_id_panel, C_PROC_NAME);
        else
          check_value_in_range(set_values(i), 0, 2**v_len-1, TB_WARNING, "length is only " & to_string(v_len) & " bits.", priv_scope.all, ID_NEVER, msg_id_panel, C_PROC_NAME);
        end if;
      end loop;
    end procedure;

    -- Generates an alert (only once)
    procedure alert_same_set_type(
      constant set_type  : in t_set_type;
      constant proc_call : in string) is
    begin
      if not(priv_warned_same_set_type) then
        alert(TB_WARNING, proc_call & "=> Used same type for both set of values: " & to_upper(to_string(set_type)), priv_scope.all);
        priv_warned_same_set_type := true;
      end if;
    end procedure;

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_rand_dist(
      constant rand_dist : in t_rand_dist) is
    begin
      priv_rand_dist := rand_dist;
    end procedure;

    impure function get_rand_dist(
      constant VOID : t_void)
    return t_rand_dist is
    begin
      return priv_rand_dist;
    end function;

    procedure set_range_weight_default_mode(
      constant mode : in t_weight_mode) is
    begin
      if mode = COMBINED_WEIGHT or mode = INDIVIDUAL_WEIGHT then
        priv_weight_mode := mode;
      else
        alert(TB_ERROR, "set_range_weight_default_mode(" & to_upper(to_string(mode)) & ")=> Failed. Mode not supported", priv_scope.all);
      end if;
    end procedure;

    impure function get_range_weight_default_mode(
      constant VOID : t_void)
    return t_weight_mode is
    begin
      return priv_weight_mode;
    end function;

    procedure set_scope(
      constant scope : in string) is
    begin
      DEALLOCATE(priv_scope);
      priv_scope := new string'(scope);
    end procedure;

    impure function get_scope(
      constant VOID : t_void)
    return string is
    begin
      return priv_scope.all;
    end function;

    procedure clear_rand_cyclic(
      constant VOID : t_void) is
    begin
      DEALLOCATE(priv_cyclic_current_function);
      priv_cyclic_current_function := new string'("");
    end procedure;

    ------------------------------------------------------------
    -- Randomization seeds
    ------------------------------------------------------------
    procedure set_rand_seeds(
      constant str : in string) is
      constant C_STR_LEN : natural := str'length;
      constant C_MAX_POS : natural := integer'right;
    begin
      -- Create the seeds by accumulating the ASCII values of the string,
      -- multiplied by a factor so they are widely spread, and making sure
      -- they don't overflow the positive range.
      for i in 1 to C_STR_LEN/2 loop
        priv_seed1 := (priv_seed1 + char_to_ascii(str(i))*128) mod C_MAX_POS;
      end loop;
      priv_seed2 := (priv_seed2 + priv_seed1) mod C_MAX_POS;
      for i in C_STR_LEN/2+1 to C_STR_LEN loop
        priv_seed2 := (priv_seed2 + char_to_ascii(str(i))*128) mod C_MAX_POS;
      end loop;
    end procedure;

    procedure set_rand_seeds(
      constant seed1 : in positive; 
      constant seed2 : in positive) is
    begin
      priv_seed1 := seed1;
      priv_seed2 := seed2;
    end procedure;

    procedure set_rand_seeds(
      constant seeds : in t_positive_vector(0 to 1)) is
    begin
      priv_seed1 := seeds(0);
      priv_seed2 := seeds(1);
    end procedure;

    procedure get_rand_seeds(
      variable seed1 : out positive;
      variable seed2 : out positive) is
    begin
      seed1 := priv_seed1;
      seed2 := priv_seed2;
    end procedure;

    impure function get_rand_seeds(
      constant VOID : t_void)
    return t_positive_vector is
      variable v_ret : t_positive_vector(0 to 1);
    begin
      v_ret(0) := priv_seed1;
      v_ret(1) := priv_seed2;
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random integer
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call : line;
      variable v_ret       : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- If a different function in cyclic mode is called, regenerate the list
      if cyclic_mode = CYCLIC and v_proc_call.all /= priv_cyclic_current_function.all then
        DEALLOCATE(priv_cyclic_current_function);
        DEALLOCATE(priv_cyclic_list);
        priv_cyclic_current_function := new string'(v_proc_call.all);
        priv_cyclic_list             := new t_cyclic_list(min_value to max_value);
        priv_cyclic_list_num_items   := 0;
      end if;

      -- Generate a random value in the range [min_value:max_value]
      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> Failed. min_value must be less than max_value", priv_scope.all);
        return 0;
      end if;
      case priv_rand_dist is
        when UNIFORM =>
          random(min_value, max_value, priv_seed1, priv_seed2, v_ret);
          -- Generate unique values within the constraints before repeating
          if cyclic_mode = CYCLIC then
            while priv_cyclic_list(v_ret) = '1' loop
              random(min_value, max_value, priv_seed1, priv_seed2, v_ret);
            end loop;
            priv_cyclic_list(v_ret)    := '1';
            priv_cyclic_list_num_items := priv_cyclic_list_num_items + 1;
            if priv_cyclic_list_num_items >= priv_cyclic_list'length then
              priv_cyclic_list.all       := (priv_cyclic_list'range => '0');
              priv_cyclic_list_num_items := 0;
            end if;
          end if;
        when GAUSSIAN =>
          --TODO: implementation
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope.all);
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL : string := "rand(" & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ", " &
        to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call        : line;
      alias normalized_set_values : integer_vector(0 to set_values'length-1) is set_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value within the set of values
      if set_type /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), priv_scope.all);
      end if;
      v_ret := rand(0, set_values'length-1, cyclic_mode, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      variable v_set_values : integer_vector(0 to 0) := (0 => set_value);
    begin
      return rand(min_value, max_value, set_type, v_set_values, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call        : line;
      alias normalized_set_values : integer_vector(0 to set_values'length-1) is set_values;
      variable v_gen_new_random   : boolean := true;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      if set_type = INCL then
        -- Avoid an integer overflow by adding the set_values to the max_value or subtracting them from the min_value
        if max_value <= integer'right-set_values'length then
          v_ret := rand(min_value, max_value+set_values'length, cyclic_mode, msg_id_panel, v_proc_call.all);
          if v_ret > max_value then
            v_ret := normalized_set_values(v_ret-max_value-1);
          end if;
        else
          v_ret := rand(min_value-set_values'length, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
          if v_ret < min_value then
            v_ret := normalized_set_values(min_value-v_ret-1);
          end if;
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif set_type = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call           : line;
      alias normalized_set_values1   : integer_vector(0 to set_values1'length-1) is set_values1;
      alias normalized_set_values2   : integer_vector(0 to set_values2'length-1) is set_values2;
      variable v_combined_set_values : integer_vector(0 to set_values1'length+set_values2'length-1);
      variable v_ret                 : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Create a new set of values in case both are the same type
      if (set_type1 = INCL and set_type2 = INCL) or (set_type1 = EXCL and set_type2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_values1'length then
            v_combined_set_values(i) := set_values1(i);
          else
            v_combined_set_values(i) := set_values2(i-set_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if set_type1 = INCL and set_type2 = INCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, INCL, v_combined_set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif set_type1 = EXCL and set_type2 = EXCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif set_type1 = INCL and set_type2 = EXCL then
        v_ret := rand(min_value, max_value+set_values1'length, EXCL, set_values2, cyclic_mode, msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values1(v_ret-max_value-1);
        end if;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif set_type1 = EXCL and set_type2 = INCL then
        v_ret := rand(min_value, max_value+set_values2'length, EXCL, set_values1, cyclic_mode, msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values2(v_ret-max_value-1);
        end if;
      else
        if not(set_type1 = INCL or set_type1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type1)), priv_scope.all);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type2)), priv_scope.all);
        end if;
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random real
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ")";
      variable v_proc_call : line;
      variable v_ret       : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value]
      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> Failed. min_value must be less than max_value", priv_scope.all);
        return 0.0;
      end if;
      case priv_rand_dist is
        when UNIFORM =>
          random(min_value, max_value, priv_seed1, priv_seed2, v_ret);
        when GAUSSIAN =>
          --TODO: implementation
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope.all);
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand(" & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      variable v_proc_call        : line;
      alias normalized_set_values : real_vector(0 to set_values'length-1) is set_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value within the set of values
      if set_type /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), priv_scope.all);
      end if;
      v_ret := rand(0, set_values'length-1, NON_CYCLIC, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_value     : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      variable v_set_values : real_vector(0 to 0) := (0 => set_value);
    begin
      return rand(min_value, max_value, set_type, v_set_values, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      variable v_proc_call        : line;
      alias normalized_set_values : real_vector(0 to set_values'length-1) is set_values;
      variable v_gen_new_random   : boolean := true;
      variable v_ret              : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      if set_type = INCL then
        v_ret := rand(min_value, max_value+real(set_values'length), msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values(integer(ceil(v_ret-max_value)-1.0));
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif set_type = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_value2    : real;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      variable v_set_values1 : real_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : real_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      variable v_set_values1 : real_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_values1   : real_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ")";
      variable v_proc_call           : line;
      alias normalized_set_values1   : real_vector(0 to set_values1'length-1) is set_values1;
      alias normalized_set_values2   : real_vector(0 to set_values2'length-1) is set_values2;
      variable v_combined_set_values : real_vector(0 to set_values1'length+set_values2'length-1);
      variable v_ret                 : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Create a new set of values in case both are the same type
      if (set_type1 = INCL and set_type2 = INCL) or (set_type1 = EXCL and set_type2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_values1'length then
            v_combined_set_values(i) := set_values1(i);
          else
            v_combined_set_values(i) := set_values2(i-set_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if set_type1 = INCL and set_type2 = INCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, INCL, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif set_type1 = EXCL and set_type2 = EXCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif set_type1 = INCL and set_type2 = EXCL then
        v_ret := rand(min_value, max_value+real(set_values1'length), EXCL, set_values2, msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values1(integer(ceil(v_ret-max_value)-1.0));
        end if;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif set_type1 = EXCL and set_type2 = INCL then
        v_ret := rand(min_value, max_value+real(set_values2'length), EXCL, set_values1, msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values2(integer(ceil(v_ret-max_value)-1.0));
        end if;
      else
        if not(set_type1 = INCL or set_type1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type1)), priv_scope.all);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type2)), priv_scope.all);
        end if;
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random time
    ------------------------------------------------------------
    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ")";
      variable v_proc_call : line;
      variable v_ret       : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value]
      if min_value > max_value then
        alert(TB_ERROR, v_proc_call.all & "=> Failed. min_value must be less than max_value", priv_scope.all);
        return 0 ns;
      end if;
      case priv_rand_dist is
        when UNIFORM =>
          random(min_value, max_value, priv_seed1, priv_seed2, v_ret);
        when GAUSSIAN =>
          --TODO: implementation
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Randomization distribution not supported: " & to_upper(to_string(priv_rand_dist)), priv_scope.all);
      end case;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand(" & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      variable v_proc_call        : line;
      alias normalized_set_values : time_vector(0 to set_values'length-1) is set_values;
      variable v_ret              : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value within the set of values
      if set_type /= ONLY then
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), priv_scope.all);
      end if;
      v_ret := rand(0, set_values'length-1, NON_CYCLIC, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(normalized_set_values(v_ret)), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return normalized_set_values(v_ret);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_value     : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      variable v_set_values : time_vector(0 to 0) := (0 => set_value);
    begin
      return rand(min_value, max_value, set_type, v_set_values, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_proc_call        : line;
      alias normalized_set_values : time_vector(0 to set_values'length-1) is set_values;
      variable v_gen_new_random   : boolean := true;
      variable v_ret              : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value] plus the set of values
      if set_type = INCL then
        v_ret := rand(min_value, max_value+(set_values'length*C_TIME_UNIT), msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values((v_ret-max_value)/C_TIME_UNIT-1);
        end if;
      -- Generate a random value in the range [min_value:max_value] minus the set of values
      elsif set_type = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_value2    : time;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      variable v_set_values1 : time_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : time_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      variable v_set_values1 : time_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_values1   : time_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_proc_call           : line;
      alias normalized_set_values1   : time_vector(0 to set_values1'length-1) is set_values1;
      alias normalized_set_values2   : time_vector(0 to set_values2'length-1) is set_values2;
      variable v_combined_set_values : time_vector(0 to set_values1'length+set_values2'length-1);
      variable v_ret                 : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Create a new set of values in case both are the same type
      if (set_type1 = INCL and set_type2 = INCL) or (set_type1 = EXCL and set_type2 = EXCL) then
        for i in v_combined_set_values'range loop
          if i < set_values1'length then
            v_combined_set_values(i) := set_values1(i);
          else
            v_combined_set_values(i) := set_values2(i-set_values1'length);
          end if;
        end loop;
      end if;

      -- Generate a random value in the range [min_value:max_value] plus both sets of values
      if set_type1 = INCL and set_type2 = INCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, INCL, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] minus both sets of values
      elsif set_type1 = EXCL and set_type2 = EXCL then
        alert_same_set_type(set_type1, v_proc_call.all);
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the range [min_value:max_value] plus the set of values 1 minus the set of values 2
      elsif set_type1 = INCL and set_type2 = EXCL then
        v_ret := rand(min_value, max_value+(set_values1'length*C_TIME_UNIT), EXCL, set_values2, msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values1((v_ret-max_value)/C_TIME_UNIT-1);
        end if;
      -- Generate a random value in the range [min_value:max_value] plus the set of values 2 minus the set of values 1
      elsif set_type1 = EXCL and set_type2 = INCL then
        v_ret := rand(min_value, max_value+(set_values2'length*C_TIME_UNIT), EXCL, set_values1, msg_id_panel, v_proc_call.all);
        if v_ret > max_value then
          v_ret := normalized_set_values2((v_ret-max_value)/C_TIME_UNIT-1);
        end if;
      else
        if not(set_type1 = INCL or set_type1 = EXCL) then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type1)), priv_scope.all);
        else
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type2)), priv_scope.all);
        end if;
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random integer_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(uniqueness)) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        if (max_value - min_value + 1) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        ", " & to_upper(to_string(uniqueness)) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value within the set of values for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(set_type, set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        if (set_values'length) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value within the set of values for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(set_type, set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector is
      variable v_set_values : integer_vector(0 to 0) := (0 => set_value);
    begin
      return rand(size, min_value, max_value, set_type, v_set_values, uniqueness, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ", " & to_upper(to_string(uniqueness)) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call       : line;
      variable v_set_values_len  : integer := 0;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type, set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        v_set_values_len := (0-set_values'length) when set_type = EXCL else set_values'length;
        if (max_value - min_value + 1 + v_set_values_len) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type, set_values, cyclic_mode, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, uniqueness, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, uniqueness, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " & to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ", " &
        to_upper(to_string(uniqueness)) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call       : line;
      variable v_set_values_len  : integer := 0;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        v_set_values_len := (0-set_values1'length) when set_type1 = EXCL else set_values1'length;
        v_set_values_len := (v_set_values_len-set_values2'length) when set_type2 = EXCL else v_set_values_len+set_values2'length;
        if (max_value - min_value + 1 + v_set_values_len) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random real_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : real_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to size-1 loop
          v_gen_new_random := true;
          while v_gen_new_random loop
            v_ret(i) := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
            if i > 0 then
              v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
            else
              v_gen_new_random := false;
            end if;
          end loop;
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : real_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value within the set of values for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(set_type, set_values, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        if (set_values'length) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value within the set of values for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(set_type, set_values, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_value     : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector is
      variable v_set_values : real_vector(0 to 0) := (0 => set_value);
    begin
      return rand(size, min_value, max_value, set_type, v_set_values, uniqueness, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type      : t_set_type;
      constant set_values    : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : real_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type, set_values, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to size-1 loop
          v_gen_new_random := true;
          while v_gen_new_random loop
            v_ret(i) := rand(min_value, max_value, set_type, set_values, msg_id_panel, v_proc_call.all);
            if i > 0 then
              v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
            else
              v_gen_new_random := false;
            end if;
          end loop;
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_value2    : real;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector is
      variable v_set_values1 : real_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : real_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, uniqueness, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_value1    : real;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector is
      variable v_set_values1 : real_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, uniqueness, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : real;
      constant max_value     : real;
      constant set_type1     : t_set_type;
      constant set_values1   : real_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : real_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : real_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to size-1 loop
          v_gen_new_random := true;
          while v_gen_new_random loop
            v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, msg_id_panel, v_proc_call.all);
            if i > 0 then
              v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
            else
              v_gen_new_random := false;
            end if;
          end loop;
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random time_vector
    ------------------------------------------------------------
    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(uniqueness)) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : time_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value] for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        if ((max_value - min_value)/C_TIME_UNIT + 1) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value in the range [min_value:max_value] for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : time_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value within the set of values for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(set_type, set_values, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        if (set_values'length) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value within the set of values for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(set_type, set_values, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_value     : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector is
      variable v_set_values : time_vector(0 to 0) := (0 => set_value);
    begin
      return rand(size, min_value, max_value, set_type, v_set_values, uniqueness, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type      : t_set_type;
      constant set_values    : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ", " & to_upper(to_string(uniqueness)) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_proc_call       : line;
      variable v_set_values_len  : integer := 0;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : time_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type, set_values, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        v_set_values_len := (0-set_values'length) when set_type = EXCL else set_values'length;
        if ((max_value - min_value)/C_TIME_UNIT + 1 + v_set_values_len) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value in the range [min_value:max_value], plus or minus the set of values, for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type, set_values, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_value2    : time;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector is
      variable v_set_values1 : time_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : time_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, uniqueness, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_value1    : time;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector is
      variable v_set_values1 : time_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(size, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, uniqueness, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant size          : positive;
      constant min_value     : time;
      constant max_value     : time;
      constant set_type1     : t_set_type;
      constant set_values1   : time_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : time_vector;
      constant uniqueness    : t_uniqueness   := NON_UNIQUE;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time_vector is
      constant C_LOCAL_CALL : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ", " & to_upper(to_string(uniqueness)) & ")";
      constant C_TIME_UNIT  : time := std.env.resolution_limit;
      variable v_proc_call       : line;
      variable v_set_values_len  : integer := 0;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : time_vector(0 to size-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, msg_id_panel, v_proc_call.all);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if it is possible to generate unique values for the complete vector
        v_set_values_len := (0-set_values1'length) when set_type1 = EXCL else set_values1'length;
        v_set_values_len := (v_set_values_len-set_values2'length) when set_type2 = EXCL else v_set_values_len+set_values2'length;
        if ((max_value - min_value)/C_TIME_UNIT + 1 + v_set_values_len) < size then
          alert(TB_ERROR, v_proc_call.all & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", priv_scope.all);
        else
          -- Generate an unique random value in the range [min_value:max_value], plus or minus the sets of values, for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2, msg_id_panel, v_proc_call.all);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random unsigned
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ")";
      variable v_proc_call : line;
      variable v_ret       : unsigned(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value for each bit of the vector
      for i in 0 to length-1 loop
        v_ret(i downto i) := to_unsigned(rand(0, 1, NON_CYCLIC, msg_id_panel, v_proc_call.all), 1);
      end loop;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call : line;
      variable v_ret_int   : integer;
      variable v_ret       : unsigned(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value]
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => false);
      v_ret_int := rand(min_value, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);
      v_ret     := to_unsigned(v_ret_int,length);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_unsigned        : unsigned(length-1 downto 0);
      variable v_ret_int         : integer;
      variable v_ret             : unsigned(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      check_parameters_within_range(length, integer_vector(set_values), msg_id_panel, signed_values => false);
      -- Generate a random value within the set of values
      if set_type = ONLY then
        v_ret_int := rand(ONLY, integer_vector(set_values), cyclic_mode, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the vector's range minus the set of values
      elsif set_type = EXCL then
        check_value(cyclic_mode = NON_CYCLIC, TB_WARNING, "Cyclic mode won't have any effect in this function", priv_scope.all, ID_NEVER, msg_id_panel, v_proc_call.all);
        while v_gen_new_random loop
          v_unsigned := rand(length, msg_id_panel, v_proc_call.all);
          v_ret_int  := to_integer(v_unsigned);
          v_gen_new_random := check_value_in_vector(v_ret_int, integer_vector(set_values));
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), priv_scope.all);
      end if;
      v_ret := to_unsigned(v_ret_int,length);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      variable v_set_values : t_natural_vector(0 to 0) := (0 => set_value);
    begin
      return rand(length, min_value, max_value, set_type, v_set_values, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call : line;
      variable v_ret_int   : integer;
      variable v_ret       : unsigned(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value], plus or minus the set of values
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => false);
      check_parameters_within_range(length, integer_vector(set_values), msg_id_panel, signed_values => false);
      v_ret_int := rand(min_value, max_value, set_type, integer_vector(set_values), cyclic_mode, msg_id_panel, v_proc_call.all);
      v_ret     := to_unsigned(v_ret_int,length);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_value2    : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : t_natural_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_values1   : t_natural_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(set_type1)) & ":" & to_string(set_values1) &
        ", " & to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call : line;
      variable v_ret_int   : integer;
      variable v_ret       : unsigned(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => false);
      check_parameters_within_range(length, integer_vector(set_values1), msg_id_panel, signed_values => false);
      check_parameters_within_range(length, integer_vector(set_values2), msg_id_panel, signed_values => false);
      v_ret_int := rand(min_value, max_value, set_type1, integer_vector(set_values1), set_type2, integer_vector(set_values2), cyclic_mode, msg_id_panel, v_proc_call.all);
      v_ret     := to_unsigned(v_ret_int,length);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random signed
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ")";
      variable v_proc_call : line;
      variable v_ret       : signed(length-1 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value for each bit of the vector
      for i in 0 to length-1 loop
        v_ret(i downto i) := signed(to_unsigned(rand(0, 1, NON_CYCLIC, msg_id_panel, v_proc_call.all), 1));
      end loop;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret, HEX, KEEP_LEADING_0, INCL_RADIX), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call : line;
      variable v_ret       : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value]
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => true);
      v_ret := rand(min_value, max_value, cyclic_mode, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return to_signed(v_ret,length);
    end function;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call       : line;
      variable v_gen_new_random  : boolean := true;
      variable v_signed          : signed(length-1 downto 0);
      variable v_ret             : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      check_parameters_within_range(length, set_values, msg_id_panel, signed_values => true);
      -- Generate a random value within the set of values
      if set_type = ONLY then
        v_ret := rand(ONLY, integer_vector(set_values), cyclic_mode, msg_id_panel, v_proc_call.all);
      -- Generate a random value in the vector's range minus the set of values
      elsif set_type = EXCL then
        check_value(cyclic_mode = NON_CYCLIC, TB_WARNING, "Cyclic mode won't have any effect in this function", priv_scope.all, ID_NEVER, msg_id_panel, v_proc_call.all);
        while v_gen_new_random loop
          v_signed := rand(length, msg_id_panel, v_proc_call.all);
          v_ret := to_integer(v_signed);
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, v_proc_call.all & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), priv_scope.all);
      end if;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return to_signed(v_ret,length);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_value     : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      variable v_set_values : integer_vector(0 to 0) := (0 => set_value);
    begin
      return rand(length, min_value, max_value, set_type, v_set_values, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type      : t_set_type;
      constant set_values    : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call : line;
      variable v_ret       : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value], plus or minus the set of values
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => true);
      check_parameters_within_range(length, set_values, msg_id_panel, signed_values => true);
      v_ret := rand(min_value, max_value, set_type, integer_vector(set_values), cyclic_mode, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return to_signed(v_ret,length);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_value2    : integer;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : integer_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_value1    : integer;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      variable v_set_values1 : integer_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : integer;
      constant max_value     : integer;
      constant set_type1     : t_set_type;
      constant set_values1   : integer_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : integer_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      constant C_LOCAL_CALL : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(set_type1)) & ":" & to_string(set_values1) &
        ", " & to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ", " & to_upper(to_string(cyclic_mode)) & ")";
      variable v_proc_call : line;
      variable v_ret       : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random value in the range [min_value:max_value], plus or minus the sets of values
      check_parameters_within_range(length, min_value, max_value, msg_id_panel, signed_values => true);
      check_parameters_within_range(length, set_values1, msg_id_panel, signed_values => true);
      check_parameters_within_range(length, set_values2, msg_id_panel, signed_values => true);
      v_ret := rand(min_value, max_value, set_type1, integer_vector(set_values1), set_type2, integer_vector(set_values2), cyclic_mode, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return to_signed(v_ret,length);
    end function;

    ------------------------------------------------------------
    -- Random std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand(
      constant length        : positive;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, set_type, set_values, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_value     : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_set_values : t_natural_vector(0 to 0) := (0 => set_value);
    begin
      return rand(length, min_value, max_value, set_type, v_set_values, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type      : t_set_type;
      constant set_values    : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, set_type, set_values, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_value2    : natural;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => set_value1);
      variable v_set_values2 : t_natural_vector(0 to 0) := (0 => set_value2);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, v_set_values2, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_value1    : natural;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_set_values1 : t_natural_vector(0 to 0) := (0 => set_value1);
    begin
      return rand(length, min_value, max_value, set_type1, v_set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel, ext_proc_call);
    end function;

    impure function rand(
      constant length        : positive;
      constant min_value     : natural;
      constant max_value     : natural;
      constant set_type1     : t_set_type;
      constant set_values1   : t_natural_vector;
      constant set_type2     : t_set_type;
      constant set_values2   : t_natural_vector;
      constant cyclic_mode   : t_cyclic       := NON_CYCLIC;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length, min_value, max_value, set_type1, set_values1, set_type2, set_values2, cyclic_mode, msg_id_panel);
      return std_logic_vector(v_ret);
    end function;

    ------------------------------------------------------------
    -- Random std_logic & boolean
    ------------------------------------------------------------
    impure function rand(
      constant VOID          : t_void;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic is
      constant C_LOCAL_CALL : string := "rand(STD_LOGIC)";
      variable v_proc_call : line;
      variable v_ret       : unsigned(0 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random bit
      v_ret := rand(1, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret(0);
    end function;

    impure function rand(
      constant VOID          : t_void;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return boolean is
      constant C_LOCAL_CALL : string := "rand(BOOL)";
      variable v_proc_call : line;
      variable v_ret       : unsigned(0 downto 0);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Generate a random bit
      v_ret := rand(1, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret(0) = '1';
    end function;

    ------------------------------------------------------------
    -- Random weighted integer
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weight_vector : t_val_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      variable v_local_call    : line;
      variable v_proc_call     : line;
      variable v_weight_vector : t_range_weight_mode_int_vec(weight_vector'range);
      variable v_ret           : integer;
    begin
      -- Convert the weight vector to base type
      for i in weight_vector'range loop
        v_weight_vector(i) := (weight_vector(i).value, weight_vector(i).value, weight_vector(i).weight, NA);
      end loop;
      v_local_call := new string'("rand_val_weight(" & to_string(v_weight_vector) & ")");
      create_proc_call(v_local_call.all, ext_proc_call, v_proc_call);

      v_ret := rand_range_weight_mode(v_weight_vector, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_local_call);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant weight_vector : t_range_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      variable v_local_call    : line;
      variable v_proc_call     : line;
      variable v_weight_vector : t_range_weight_mode_int_vec(weight_vector'range);
      variable v_ret           : integer;
    begin
      -- Convert the weight vector to base type
      for i in weight_vector'range loop
        v_weight_vector(i) := (weight_vector(i).min_value, weight_vector(i).max_value, weight_vector(i).weight, priv_weight_mode);
      end loop;
      v_local_call := new string'("rand_range_weight(" & to_string(v_weight_vector) & ")");
      create_proc_call(v_local_call.all, ext_proc_call, v_proc_call);

      v_ret := rand_range_weight_mode(v_weight_vector, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_local_call);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant weight_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer is
      constant C_LOCAL_CALL : string := "rand_range_weight_mode(" & to_string(weight_vector) & ")";
      variable v_proc_call         : line;
      variable v_mode              : t_weight_mode;
      variable v_acc_weight        : natural := 0;
      variable v_acc_weight_vector : t_natural_vector(0 to weight_vector'length-1);
      variable v_weight_idx        : natural := 0;
      variable v_values_in_range   : natural := 0;
      variable v_previous_dist     : t_rand_dist := priv_rand_dist;
      variable v_ret               : integer;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Create a new vector with the accumulated weights
      for i in weight_vector'range loop
        if weight_vector(i).min_value > weight_vector(i).max_value then
          alert(TB_ERROR, v_proc_call.all & "=> The min_value parameter must be less or equal than max_value", priv_scope.all);
          return 0;
        end if;
        v_mode := weight_vector(i).mode when weight_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weight_vector(i).weight;
        -- Use the same weight for each value in the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          v_values_in_range := weight_vector(i).max_value - weight_vector(i).min_value + 1;
          v_acc_weight := v_acc_weight + weight_vector(i).weight*v_values_in_range;
        end if;
        v_acc_weight_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope.all);
        return 0;
      end if;

      -- Change distribution to UNIFORM
      priv_rand_dist := UNIFORM;
      -- Generate a random value between 1 and the total accumulated weight
      v_weight_idx := rand(1, v_acc_weight, NON_CYCLIC, msg_id_panel, v_proc_call.all);
      -- Associate the random value to the original value in the vector based on the weight
      for i in v_acc_weight_vector'range loop
        if v_weight_idx <= v_acc_weight_vector(i) then
          v_ret := rand(weight_vector(i).min_value, weight_vector(i).max_value, NON_CYCLIC, msg_id_panel, v_proc_call.all);
          exit;
        end if;
      end loop;
      -- Restore previous distribution
      priv_rand_dist := v_previous_dist;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted real
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weight_vector : t_val_weight_real_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      variable v_local_call    : line;
      variable v_proc_call     : line;
      variable v_weight_vector : t_range_weight_mode_real_vec(weight_vector'range);
      variable v_ret           : real;
    begin
      -- Convert the weight vector to base type
      for i in weight_vector'range loop
        v_weight_vector(i) := (weight_vector(i).value, weight_vector(i).value, weight_vector(i).weight, NA);
      end loop;
      v_local_call := new string'("rand_val_weight(" & to_string(v_weight_vector) & ")");
      create_proc_call(v_local_call.all, ext_proc_call, v_proc_call);

      v_ret := rand_range_weight_mode(v_weight_vector, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_local_call);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant weight_vector : t_range_weight_real_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      variable v_local_call    : line;
      variable v_proc_call     : line;
      variable v_weight_vector : t_range_weight_mode_real_vec(weight_vector'range);
      variable v_ret           : real;
    begin
      -- Convert the weight vector to base type
      for i in weight_vector'range loop
        v_weight_vector(i) := (weight_vector(i).min_value, weight_vector(i).max_value, weight_vector(i).weight, priv_weight_mode);
      end loop;
      v_local_call := new string'("rand_range_weight(" & to_string(v_weight_vector) & ")");
      create_proc_call(v_local_call.all, ext_proc_call, v_proc_call);

      v_ret := rand_range_weight_mode(v_weight_vector, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_local_call);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant weight_vector : t_range_weight_mode_real_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return real is
      constant C_LOCAL_CALL : string := "rand_range_weight_mode(" & to_string(weight_vector) & ")";
      variable v_proc_call         : line;
      variable v_mode              : t_weight_mode;
      variable v_acc_weight        : natural := 0;
      variable v_acc_weight_vector : t_natural_vector(0 to weight_vector'length-1);
      variable v_weight_idx        : natural := 0;
      variable v_values_in_range   : natural := 0;
      variable v_previous_dist     : t_rand_dist := priv_rand_dist;
      variable v_ret               : real;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Create a new vector with the accumulated weights
      for i in weight_vector'range loop
        if weight_vector(i).min_value > weight_vector(i).max_value then
          alert(TB_ERROR, v_proc_call.all & "=> The min_value parameter must be less or equal than max_value", priv_scope.all);
          return 0.0;
        end if;
        v_mode := weight_vector(i).mode when weight_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weight_vector(i).weight;
        -- Use the same weight for each value in the range -> Not possible to know every value within the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          alert(TB_ERROR, v_proc_call.all & "=> INDIVIDUAL_WEIGHT not supported for real type", priv_scope.all);
          return 0.0;
        end if;
        v_acc_weight_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope.all);
        return 0.0;
      end if;

      -- Change distribution to UNIFORM
      priv_rand_dist := UNIFORM;
      -- Generate a random value between 1 and the total accumulated weight
      v_weight_idx := rand(1, v_acc_weight, NON_CYCLIC, msg_id_panel, v_proc_call.all);
      -- Associate the random value to the original value in the vector based on the weight
      for i in v_acc_weight_vector'range loop
        if v_weight_idx <= v_acc_weight_vector(i) then
          v_ret := rand(weight_vector(i).min_value, weight_vector(i).max_value, msg_id_panel, v_proc_call.all);
          exit;
        end if;
      end loop;
      -- Restore previous distribution
      priv_rand_dist := v_previous_dist;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted time
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant weight_vector : t_val_weight_time_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      variable v_local_call    : line;
      variable v_proc_call     : line;
      variable v_weight_vector : t_range_weight_mode_time_vec(weight_vector'range);
      variable v_ret           : time;
    begin
      -- Convert the weight vector to base type
      for i in weight_vector'range loop
        v_weight_vector(i) := (weight_vector(i).value, weight_vector(i).value, weight_vector(i).weight, NA);
      end loop;
      v_local_call := new string'("rand_val_weight(" & to_string(v_weight_vector) & ")");
      create_proc_call(v_local_call.all, ext_proc_call, v_proc_call);

      v_ret := rand_range_weight_mode(v_weight_vector, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_local_call);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant weight_vector : t_range_weight_time_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      variable v_local_call    : line;
      variable v_proc_call     : line;
      variable v_weight_vector : t_range_weight_mode_time_vec(weight_vector'range);
      variable v_ret           : time;
    begin
      -- Convert the weight vector to base type
      for i in weight_vector'range loop
        v_weight_vector(i) := (weight_vector(i).min_value, weight_vector(i).max_value, weight_vector(i).weight, priv_weight_mode);
      end loop;
      v_local_call := new string'("rand_range_weight(" & to_string(v_weight_vector) & ")");
      create_proc_call(v_local_call.all, ext_proc_call, v_proc_call);

      v_ret := rand_range_weight_mode(v_weight_vector, msg_id_panel, v_proc_call.all);

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_local_call);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant weight_vector : t_range_weight_mode_time_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return time is
      constant C_LOCAL_CALL : string := "rand_range_weight_mode(" & to_string(weight_vector) & ")";
      variable v_proc_call         : line;
      variable v_mode              : t_weight_mode;
      variable v_acc_weight        : natural := 0;
      variable v_acc_weight_vector : t_natural_vector(0 to weight_vector'length-1);
      variable v_weight_idx        : natural := 0;
      variable v_values_in_range   : natural := 0;
      variable v_previous_dist     : t_rand_dist := priv_rand_dist;
      variable v_ret               : time;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

      -- Create a new vector with the accumulated weights
      for i in weight_vector'range loop
        if weight_vector(i).min_value > weight_vector(i).max_value then
          alert(TB_ERROR, v_proc_call.all & "=> The min_value parameter must be less or equal than max_value", priv_scope.all);
          return std.env.resolution_limit;
        end if;
        v_mode := weight_vector(i).mode when weight_vector(i).mode /= NA else COMBINED_WEIGHT;
        -- Divide the weight between the number of values in the range
        if v_mode = COMBINED_WEIGHT then
          v_acc_weight := v_acc_weight + weight_vector(i).weight;
        -- Use the same weight for each value in the range -> Not possible to know every value within the range
        elsif v_mode = INDIVIDUAL_WEIGHT then
          alert(TB_ERROR, v_proc_call.all & "=> INDIVIDUAL_WEIGHT not supported for time type", priv_scope.all);
          return std.env.resolution_limit;
        end if;
        v_acc_weight_vector(i) := v_acc_weight;
      end loop;
      if v_acc_weight = 0 then
        alert(TB_ERROR, v_proc_call.all & "=> The total weight of the values must be greater than 0", priv_scope.all);
        return std.env.resolution_limit;
      end if;

      -- Change distribution to UNIFORM
      priv_rand_dist := UNIFORM;
      -- Generate a random value between 1 and the total accumulated weight
      v_weight_idx := rand(1, v_acc_weight, NON_CYCLIC, msg_id_panel, v_proc_call.all);
      -- Associate the random value to the original value in the vector based on the weight
      for i in v_acc_weight_vector'range loop
        if v_weight_idx <= v_acc_weight_vector(i) then
          v_ret := rand(weight_vector(i).min_value, weight_vector(i).max_value, msg_id_panel, v_proc_call.all);
          exit;
        end if;
      end loop;
      -- Restore previous distribution
      priv_rand_dist := v_previous_dist;

      log_proc_call(ID_RAND_GEN, v_proc_call.all & "=> " & to_string(v_ret), ext_proc_call, v_proc_call, msg_id_panel);
      DEALLOCATE(v_proc_call);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted unsigned
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length        : positive;
      constant weight_vector : t_val_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_val_weight(weight_vector, msg_id_panel, ext_proc_call), length);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant length        : positive;
      constant weight_vector : t_range_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_range_weight(weight_vector, msg_id_panel, ext_proc_call), length);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant length        : positive;
      constant weight_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return unsigned is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_range_weight_mode(weight_vector, msg_id_panel, ext_proc_call), length);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted signed
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length        : positive;
      constant weight_vector : t_val_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      variable v_ret : signed(0 to length-1);
    begin
      v_ret := to_signed(rand_val_weight(weight_vector, msg_id_panel, ext_proc_call), length);
      return v_ret;
    end function;

    impure function rand_range_weight(
      constant length        : positive;
      constant weight_vector : t_range_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      variable v_ret : signed(0 to length-1);
    begin
      v_ret := to_signed(rand_range_weight(weight_vector, msg_id_panel, ext_proc_call), length);
      return v_ret;
    end function;

    impure function rand_range_weight_mode(
      constant length        : positive;
      constant weight_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return signed is
      variable v_ret : signed(0 to length-1);
    begin
      v_ret := to_signed(rand_range_weight_mode(weight_vector, msg_id_panel, ext_proc_call), length);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random weighted std_logic_vector
    -- The std_logic_vector values are interpreted as unsigned.
    ------------------------------------------------------------
    impure function rand_val_weight(
      constant length        : positive;
      constant weight_vector : t_val_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_val_weight(weight_vector, msg_id_panel, ext_proc_call), length);
      return std_logic_vector(v_ret);
    end function;

    impure function rand_range_weight(
      constant length        : positive;
      constant weight_vector : t_range_weight_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_range_weight(weight_vector, msg_id_panel, ext_proc_call), length);
      return std_logic_vector(v_ret);
    end function;

    impure function rand_range_weight_mode(
      constant length        : positive;
      constant weight_vector : t_range_weight_mode_int_vec;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return std_logic_vector is
      variable v_ret : unsigned(0 to length-1);
    begin
      v_ret := to_unsigned(rand_range_weight_mode(weight_vector, msg_id_panel, ext_proc_call), length);
      return std_logic_vector(v_ret);
    end function;

  end protected body t_rand;

end package body rand_pkg;