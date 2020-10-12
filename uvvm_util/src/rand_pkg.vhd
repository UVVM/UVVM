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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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

  type t_set_type is (ONLY, INCL, EXCL, UNIQUE, NON_UNIQUE);

  type t_weight_int is record
    value  : integer;
    weight : natural;
  end record;

  type t_weight_real is record
    value  : real;
    weight : natural;
  end record;

  type t_weight_time is record
    value  : time;
    weight : natural;
  end record;

  type t_weight_int_vector is array (natural range <>) of t_weight_int;
  type t_weight_real_vector is array (natural range <>) of t_weight_real;
  type t_weight_time_vector is array (natural range <>) of t_weight_time;

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_rand is protected

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
    -- Randomization distribution
    ------------------------------------------------------------
    procedure set_rand_dist(
      constant rand_dist : in t_rand_dist);

    ------------------------------------------------------------
    -- Random integer
    ------------------------------------------------------------
    impure function rand(
      constant min_value : integer;
      constant max_value : integer)
    return integer;

    impure function rand(
      constant set_type   : t_set_type;
      constant set_values : integer_vector)
    return integer;

    impure function rand(
      constant min_value  : integer;
      constant max_value  : integer;
      constant set_type   : t_set_type;
      constant set_values : integer_vector)
    return integer;

    impure function rand(
      constant min_value   : integer;
      constant max_value   : integer;
      constant set_type1   : t_set_type;
      constant set_values1 : integer_vector;
      constant set_type2   : t_set_type;
      constant set_values2 : integer_vector)
    return integer;

    ------------------------------------------------------------
    -- Random real
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random time
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random integer_vector
    ------------------------------------------------------------
    impure function rand(
      constant size       : positive;
      constant min_value  : integer;
      constant max_value  : integer;
      constant uniqueness : t_set_type := NON_UNIQUE)
    return integer_vector;

    impure function rand(
      constant size       : positive;
      constant set_type   : t_set_type;
      constant set_values : integer_vector;
      constant uniqueness : t_set_type := NON_UNIQUE)
    return integer_vector;

    impure function rand(
      constant size       : positive;
      constant min_value  : integer;
      constant max_value  : integer;
      constant set_type   : t_set_type;
      constant set_values : integer_vector;
      constant uniqueness : t_set_type := NON_UNIQUE)
    return integer_vector;

    impure function rand(
      constant size        : positive;
      constant min_value   : integer;
      constant max_value   : integer;
      constant set_type1   : t_set_type;
      constant set_values1 : integer_vector;
      constant set_type2   : t_set_type;
      constant set_values2 : integer_vector;
      constant uniqueness  : t_set_type := NON_UNIQUE)
    return integer_vector;

    ------------------------------------------------------------
    -- Random real_vector
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random time_vector
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random unsigned
    ------------------------------------------------------------
    impure function rand(
      constant length : positive)
    return unsigned;

    impure function rand(
      constant length    : positive;
      constant min_value : natural;
      constant max_value : natural)
    return unsigned;

    impure function rand(
      constant length     : positive;
      constant set_type   : t_set_type;
      constant set_values : t_natural_vector)
    return unsigned;

    impure function rand(
      constant length     : positive;
      constant min_value  : natural;
      constant max_value  : natural;
      constant set_type   : t_set_type;
      constant set_values : t_natural_vector)
    return unsigned;

    impure function rand(
      constant length      : positive;
      constant min_value   : natural;
      constant max_value   : natural;
      constant set_type1   : t_set_type;
      constant set_values1 : t_natural_vector;
      constant set_type2   : t_set_type;
      constant set_values2 : t_natural_vector)
    return unsigned;

    ------------------------------------------------------------
    -- Random signed
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random std_logic_vector
    ------------------------------------------------------------
    impure function rand(
      constant length : positive)
    return std_logic_vector;

    ------------------------------------------------------------
    -- Random std_logic & boolean
    ------------------------------------------------------------
    impure function rand(
      constant VOID : t_void)
    return std_logic;

    impure function rand(
      constant VOID : t_void)
    return boolean;

  end protected t_rand;

end package rand_pkg;

package body rand_pkg is

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_rand is protected body
    variable v_seed1     : positive := C_INIT_SEED_1;
    variable v_seed2     : positive := C_INIT_SEED_2;
    variable v_rand_dist : t_rand_dist := UNIFORM;

    ------------------------------------------------------------
    -- Internal functions
    ------------------------------------------------------------
    -- Disable an enabled msg_id and return status
    procedure disable_msg_id(
      constant msg_id          : in    t_msg_id;
      variable msg_id_panel    : inout t_msg_id_panel;
      variable msg_id_disabled : out   boolean) is
    begin
      if msg_id_panel(msg_id) = ENABLED then
        msg_id_panel(msg_id) := DISABLED;
        msg_id_disabled := true;
      else
        msg_id_disabled := false;
      end if;
    end procedure;

    -- Enable a msg_id if it was previously disabled
    procedure re_enable_msg_id(
      constant msg_id          : in    t_msg_id;
      variable msg_id_panel    : inout t_msg_id_panel;
      constant msg_id_disabled : in    boolean) is
    begin
      if msg_id_disabled then
        msg_id_panel(msg_id) := ENABLED;
      end if;
    end procedure;

    -- Check if a value is contained in a vector
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

    function check_value_in_vector(
      constant value  : integer;
      constant vector : t_natural_vector)
    return boolean is
      variable v_found : boolean := false;
    begin
      return check_value_in_vector(value, integer_vector(vector));
    end function;

    ------------------------------------------------------------
    -- Randomization seeds
    ------------------------------------------------------------
    procedure set_rand_seeds(
      constant str : in string) is
    begin
      --TODO: implementation
    end procedure;

    procedure set_rand_seeds(
      constant seed1 : in positive; 
      constant seed2 : in positive) is
    begin
      v_seed1 := seed1;
      v_seed2 := seed2;
    end procedure;

    procedure set_rand_seeds(
      constant seeds : in t_positive_vector(0 to 1)) is
    begin
      v_seed1 := seeds(0);
      v_seed2 := seeds(1);
    end procedure;

    procedure get_rand_seeds(
      variable seed1 : out positive;
      variable seed2 : out positive) is
    begin
      seed1 := v_seed1;
      seed2 := v_seed2;
    end procedure;

    impure function get_rand_seeds(
      constant VOID : t_void)
    return t_positive_vector is
      variable v_ret : t_positive_vector(0 to 1);
    begin
      v_ret(0) := v_seed1;
      v_ret(1) := v_seed2;
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Randomization distribution
    ------------------------------------------------------------
    procedure set_rand_dist(
      constant rand_dist : in t_rand_dist) is
    begin
      v_rand_dist := rand_dist;
    end procedure;

    ------------------------------------------------------------
    -- Random integer
    ------------------------------------------------------------
    impure function rand(
      constant min_value : integer;
      constant max_value : integer)
    return integer is
      constant name : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ")";
      variable v_ret : integer;
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);

      case v_rand_dist is
        when UNIFORM =>
          random(min_value, max_value, v_seed1, v_seed2, v_ret); --Q: Call random() from methods_pkg or copy implementation?
        when GAUSSIAN =>
          --TODO: implementation
          alert(TB_ERROR, name & "=> Failed. Randomization distribution not supported: " & to_upper(to_string(v_rand_dist)), C_SCOPE);
      end case;

      return v_ret;
    end function;

    impure function rand(
      constant set_type   : t_set_type;
      constant set_values : integer_vector)
    return integer is
      constant name : string := "rand(" & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      alias normalized_set_values : integer_vector(0 to set_values'length-1) is set_values;
      variable v_msg_id_disabled  : boolean := false;
      variable v_ret              : integer;
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      if set_type /= ONLY then
        alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), C_SCOPE);
      end if;
      v_ret := rand(0, set_values'length-1);

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return normalized_set_values(v_ret);
    end function;

    --Q: IMPLEMENTATION OPTIONS:
    -- 1. make a new vector, add values min->max + set_values, use rand(set_values)
    -- 2. use rand(min,max+num_values), if rand>max replace for set_values(i) --> faster, but problem if max is close to integer'max
    impure function rand(
      constant min_value  : integer;
      constant max_value  : integer;
      constant set_type   : t_set_type;
      constant set_values : integer_vector)
    return integer is
      constant name : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      alias normalized_set_values : integer_vector(0 to set_values'length-1) is set_values;
      variable v_msg_id_disabled  : boolean := false;
      variable v_gen_new_random   : boolean := true;
      variable v_ret              : integer;
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      -- Add values to the range
      if set_type = INCL then
        v_ret := rand(min_value, max_value+set_values'length);
        if v_ret > max_value then
          v_ret := normalized_set_values(v_ret-max_value-1);
        end if;
      -- Remove values from the range
      elsif set_type = EXCL then
        while v_gen_new_random loop
          v_ret := rand(min_value, max_value);
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), C_SCOPE);
      end if;

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return v_ret;
    end function;

    impure function rand(
      constant min_value   : integer;
      constant max_value   : integer;
      constant set_type1   : t_set_type;
      constant set_values1 : integer_vector;
      constant set_type2   : t_set_type;
      constant set_values2 : integer_vector)
    return integer is
      constant name : string := "rand(MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ")";
      alias normalized_set_values1   : integer_vector(0 to set_values1'length-1) is set_values1;
      alias normalized_set_values2   : integer_vector(0 to set_values2'length-1) is set_values2;
      variable v_combined_set_values : integer_vector(0 to set_values1'length+set_values2'length-1);
      variable v_msg_id_disabled     : boolean := false;
      variable v_ret                 : integer;
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

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

      -- Add values to the range
      if set_type1 = INCL and set_type2 = INCL then
        v_ret := rand(min_value, max_value, INCL, v_combined_set_values);
      -- Remove values from the range
      elsif set_type1 = EXCL and set_type2 = EXCL then
        v_ret := rand(min_value, max_value, EXCL, v_combined_set_values);
      -- Add and remove values from the range
      elsif set_type1 = INCL and set_type2 = EXCL then
        v_ret := rand(min_value, max_value+set_values1'length, EXCL, set_values2);
        if v_ret > max_value then
          v_ret := normalized_set_values1(v_ret-max_value-1);
        end if;
      -- Add and remove values from the range
      elsif set_type1 = EXCL and set_type2 = INCL then
        v_ret := rand(min_value, max_value+set_values2'length, EXCL, set_values1);
        if v_ret > max_value then
          v_ret := normalized_set_values2(v_ret-max_value-1);
        end if;
      else
        if not(set_type1 = INCL or set_type1 = EXCL) then
          alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type1)), C_SCOPE);
        else
          alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type2)), C_SCOPE);
        end if;
      end if;

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random real
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random time
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random integer_vector
    ------------------------------------------------------------
    impure function rand(
      constant size       : positive;
      constant min_value  : integer;
      constant max_value  : integer;
      constant uniqueness : t_set_type := NON_UNIQUE)
    return integer_vector is
      constant name : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer_vector(0 to size-1);
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if vector size is enough to generate unique values
        if (max_value + 1 - min_value) < size then
          alert(TB_ERROR, name & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", C_SCOPE);
        else
          -- Generate a random value for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), C_SCOPE);
      end if;

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return v_ret;
    end function;

    impure function rand(
      constant size       : positive;
      constant set_type   : t_set_type;
      constant set_values : integer_vector;
      constant uniqueness : t_set_type := NON_UNIQUE)
    return integer_vector is
      constant name : string := "rand(SIZE:" & to_string(size) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) &
        ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer_vector(0 to size-1);
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(set_type, set_values);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if vector size is enough to generate unique values
        if (set_values'length) < size then
          alert(TB_ERROR, name & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", C_SCOPE);
        else
          -- Generate a random value for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(set_type, set_values);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), C_SCOPE);
      end if;

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return v_ret;
    end function;

    impure function rand(
      constant size       : positive;
      constant min_value  : integer;
      constant max_value  : integer;
      constant set_type   : t_set_type;
      constant set_values : integer_vector;
      constant uniqueness : t_set_type := NON_UNIQUE)
    return integer_vector is
      constant name : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type)) & ":" & to_string(set_values) & ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_set_values_len  : integer := 0;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer_vector(0 to size-1);
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type, set_values);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if vector size is enough to generate unique values
        v_set_values_len := (0-set_values'length) when set_type = EXCL else set_values'length;
        if (max_value + 1 - min_value + v_set_values_len) < size then
          alert(TB_ERROR, name & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", C_SCOPE);
        else
          -- Generate a random value for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type, set_values);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), C_SCOPE);
      end if;

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return v_ret;
    end function;

    impure function rand(
      constant size        : positive;
      constant min_value   : integer;
      constant max_value   : integer;
      constant set_type1   : t_set_type;
      constant set_values1 : integer_vector;
      constant set_type2   : t_set_type;
      constant set_values2 : integer_vector;
      constant uniqueness  : t_set_type := NON_UNIQUE)
    return integer_vector is
      constant name : string := "rand(SIZE:" & to_string(size) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ", " &
        to_upper(to_string(set_type1)) & ":" & to_string(set_values1) & ", " &
        to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ", " & to_upper(to_string(uniqueness)) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_set_values_len  : integer := 0;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer_vector(0 to size-1);
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      if uniqueness = NON_UNIQUE then
        -- Generate a random value for each element of the vector
        for i in 0 to size-1 loop
          v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2);
        end loop;
      elsif uniqueness = UNIQUE then
        -- Check if vector size is enough to generate unique values
        v_set_values_len := (0-set_values1'length) when set_type1 = EXCL else set_values1'length;
        v_set_values_len := (v_set_values_len-set_values2'length) when set_type2 = EXCL else v_set_values_len+set_values2'length;
        if (max_value + 1 - min_value + v_set_values_len) < size then
          alert(TB_ERROR, name & "=> Failed. Vector size is not big enough to generate unique values with the given constraints", C_SCOPE);
        else
          -- Generate a random value for each element of the vector
          for i in 0 to size-1 loop
            v_gen_new_random := true;
            while v_gen_new_random loop
              v_ret(i) := rand(min_value, max_value, set_type1, set_values1, set_type2, set_values2);
              if i > 0 then
                v_gen_new_random := check_value_in_vector(v_ret(i), v_ret(0 to i-1));
              else
                v_gen_new_random := false;
              end if;
            end loop;
          end loop;
        end if;
      else
        alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(uniqueness)), C_SCOPE);
      end if;

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Random real_vector
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random time_vector
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random unsigned
    ------------------------------------------------------------
    impure function rand(
      constant length : positive)
    return unsigned is
      constant name : string := "rand(LEN:" & to_string(length) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_ret             : unsigned(length-1 downto 0);
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      -- Iterate through each bit and randomly set to 0 or 1
      for i in 0 to length-1 loop
        v_ret(i downto i) := to_unsigned(rand(0, 1), 1);
      end loop;

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return v_ret;
    end function;

    impure function rand(
      constant length    : positive;
      constant min_value : natural;
      constant max_value : natural)
    return unsigned is
      constant name : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_ret             : integer;
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      v_ret := rand(min_value, max_value);

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return to_unsigned(v_ret,length);
    end function;

    impure function rand(
      constant length     : positive;
      constant set_type   : t_set_type;
      constant set_values : t_natural_vector)
    return unsigned is
      constant name : string := "rand(LEN:" & to_string(length) & ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_gen_new_random  : boolean := true;
      variable v_ret             : integer;
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      if set_type = ONLY then
        v_ret := rand(ONLY, integer_vector(set_values));
      elsif set_type = EXCL then
        while v_gen_new_random loop
          v_ret := to_integer(rand(length));
          v_gen_new_random := check_value_in_vector(v_ret, set_values);
        end loop;
      else
        alert(TB_ERROR, name & "=> Failed. Invalid parameter: " & to_upper(to_string(set_type)), C_SCOPE);
      end if;

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return to_unsigned(v_ret,length);
    end function;

    impure function rand(
      constant length     : positive;
      constant min_value  : natural;
      constant max_value  : natural;
      constant set_type   : t_set_type;
      constant set_values : t_natural_vector)
    return unsigned is
      constant name : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(set_type)) & ":" & to_string(set_values) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_ret             : integer;
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      v_ret := rand(min_value, max_value, set_type, integer_vector(set_values));

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return to_unsigned(v_ret,length);
    end function;

    impure function rand(
      constant length      : positive;
      constant min_value   : natural;
      constant max_value   : natural;
      constant set_type1   : t_set_type;
      constant set_values1 : t_natural_vector;
      constant set_type2   : t_set_type;
      constant set_values2 : t_natural_vector)
    return unsigned is
      constant name : string := "rand(LEN:" & to_string(length) & ", MIN:" & to_string(min_value) & ", MAX:" & to_string(max_value) &
        ", " & to_upper(to_string(set_type1)) & ":" & to_string(set_values1) &
        ", " & to_upper(to_string(set_type2)) & ":" & to_string(set_values2) & ")";
      variable v_msg_id_disabled : boolean := false;
      variable v_ret             : integer;
    begin
      log(ID_RAND_GEN, name, C_SCOPE, shared_msg_id_panel);
      disable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);

      v_ret := rand(min_value, max_value, set_type1, integer_vector(set_values1), set_type2, integer_vector(set_values2));

      re_enable_msg_id(ID_RAND_GEN, shared_msg_id_panel, v_msg_id_disabled);
      return to_unsigned(v_ret,length);
    end function;

    ------------------------------------------------------------
    -- Random signed
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Random std_logic_vector
    ------------------------------------------------------------
    impure function rand(
      constant length : positive)
    return std_logic_vector is
      variable v_ret : unsigned(length-1 downto 0);
    begin
      v_ret := rand(length);
      return std_logic_vector(v_ret);
    end function;

    ------------------------------------------------------------
    -- Random std_logic & boolean
    ------------------------------------------------------------
    impure function rand(
      constant VOID : t_void)
    return std_logic is
      variable v_ret : unsigned(0 downto 0);
    begin
      v_ret := rand(1); -- Randomly set bit to 0 or 1
      return v_ret(0);
    end function;

    impure function rand(
      constant VOID : t_void)
    return boolean is
      variable v_ret : unsigned(0 downto 0);
    begin
      v_ret := rand(1); -- Randomly set bit to 0 or 1
      return v_ret(0) = '1';
    end function;

  end protected body t_rand;

end package body rand_pkg;