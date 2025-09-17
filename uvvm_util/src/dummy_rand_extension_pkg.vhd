library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

package vendor_rand_extension_pkg is
  constant C_VENDOR_EXTENSION_IS_ENABLED : boolean := false;

  function vendor_create_rand_var  return integer;
  function vendor_randvar_get_value_int (id: integer) return integer;
  function vendor_randvar_get_value_real (id: integer) return real;
  function vendor_randvar_get_value_time (id: integer) return time;
  procedure vendor_randvar_get_value_int_array (id: integer; retval: out integer_vector);
  procedure vendor_randvar_get_value_real_array (id: integer; retval : out real_vector);
  procedure vendor_randvar_get_value_time_array (id: integer; retval: out time_vector);
  procedure vendor_randvar_get_value_signed (id: integer; retval: out signed);
  procedure vendor_randvar_get_value_unsigned (id: integer; retval: out unsigned);
  procedure vendor_randvar_get_value_slv (id: integer; retval: out std_logic_vector);
  procedure vendor_add_include_range_int (id: integer; min, max : integer; grp: integer);
  procedure vendor_add_include_vals_int (id: integer; vals : integer_vector);
  procedure vendor_add_exclude_range_int (id: integer; min, max : integer; grp: integer);
  procedure vendor_add_exclude_vals_int (id: integer; vals : integer_vector);
  procedure vendor_add_include_range_real (id: integer; min, max : real; grp: integer);
  procedure vendor_add_include_vals_real (id: integer; vals : real_vector);
  procedure vendor_add_exclude_range_real (id: integer; min, max : real; grp: integer);
  procedure vendor_add_exclude_vals_real (id: integer; vals : real_vector);
  procedure vendor_add_include_range_time (id: integer; min, max : time; grp: integer);
  procedure vendor_add_include_vals_time (id: integer; vals : time_vector);
  procedure vendor_add_exclude_range_time (id: integer; min, max : time; grp: integer);
  procedure vendor_add_exclude_vals_time (id: integer; vals : time_vector);
  procedure vendor_add_range_signed (id: integer; min, max : signed);
  procedure vendor_add_range_unsigned (id: integer; min, max : unsigned);
  procedure vendor_add_vector_sum_max (id: integer; max : integer);
  procedure vendor_add_vector_sum_min (id: integer; min : integer);
  function vendor_randomize_int (id: integer) return integer;
  function vendor_randomize_real (id: integer) return real;
  function vendor_randomize_time (id: integer) return time;
  procedure vendor_randomize_int_array (id: integer; size: integer; retval: out integer_vector);
  procedure vendor_randomize_real_array (id: integer; size: integer; retval: out real_vector);
  procedure vendor_randomize_time_array (id: integer; size: integer; retval: out time_vector);
  procedure vendor_randomize_signed (id: integer; size: integer; retval: out signed);
  procedure vendor_randomize_unsigned (id: integer; size: integer; retval: out unsigned);
  procedure vendor_randomize_slv (id: integer; size: integer; retval: out std_logic_vector);
  procedure vendor_clear_constraints (id: integer);
  procedure vendor_randvar_set_seed (id: integer; seed: string);
  procedure vendor_randvar_set_seed_ints (id: integer; seed1, seed2: integer);
  procedure vendor_randvar_get_seed_ints (id: integer; seed1, seed2: out integer);
  procedure vendor_randvar_add_range_weight_int (id: integer; min, max: integer; weight: natural);
  procedure vendor_randvar_add_range_weight_real (id: integer; min, max: real; weight: natural);
  procedure vendor_randvar_add_range_weight_time (id: integer; min, max: time; weight: natural);
  procedure vendor_randvar_add_link (id1, id2: integer; op: integer);
  procedure vendor_randvar_add_link2 (id1, id2: integer; op: integer; arith_op: integer; valOrId: integer; isVarId: integer);
  procedure vendor_randvar_delete_link (id1, id2: integer);
  procedure vendor_randvar_nonzero_bitwise_and (id: integer; mask: integer);
  procedure vendor_randvar_zero_bitwise_and (id: integer; mask: integer);
  procedure vendor_randvar_one_hot (id: integer);
  procedure vendor_randvar_force_bits_to (id: integer; bitmask: string);
end package vendor_rand_extension_pkg;

package body vendor_rand_extension_pkg is

  function vendor_create_rand_var  return integer is
  begin
    return 0;
  end;

  function vendor_randvar_get_value_int (id: integer) return integer is
  begin
    return 0;
  end;

  function vendor_randvar_get_value_real (id: integer) return real is
  begin
    return 0.0;
  end;

  function vendor_randvar_get_value_time (id: integer) return time is
  begin
    return 0 ns;
  end;

  procedure vendor_randvar_get_value_int_array (id: integer; retval: out integer_vector) is
  begin
  end;

  procedure vendor_randvar_get_value_real_array (id: integer; retval : out real_vector) is
  begin
  end;

  procedure vendor_randvar_get_value_time_array (id: integer; retval: out time_vector) is
  begin
  end;

  procedure vendor_randvar_get_value_signed (id: integer; retval: out signed) is
  begin
  end;

  procedure vendor_randvar_get_value_unsigned (id: integer; retval: out unsigned) is
  begin
  end;

  procedure vendor_randvar_get_value_slv (id: integer; retval: out std_logic_vector) is
  begin
  end;

  procedure vendor_add_include_range_int (id: integer; min, max : integer; grp: integer) is
  begin
  end;

  procedure vendor_add_include_vals_int (id: integer; vals : integer_vector) is
  begin
  end;

  procedure vendor_add_exclude_range_int (id: integer; min, max : integer; grp: integer) is
  begin
  end;

  procedure vendor_add_exclude_vals_int (id: integer; vals : integer_vector) is
  begin
  end;

  procedure vendor_add_include_range_real (id: integer; min, max : real; grp: integer) is
  begin
  end;

  procedure vendor_add_include_vals_real (id: integer; vals : real_vector) is
  begin
  end;

  procedure vendor_add_exclude_range_real (id: integer; min, max : real; grp: integer) is
  begin
  end;

  procedure vendor_add_exclude_vals_real (id: integer; vals : real_vector) is
  begin
  end;

  procedure vendor_add_include_range_time (id: integer; min, max : time; grp: integer) is
  begin
  end;

  procedure vendor_add_include_vals_time (id: integer; vals : time_vector) is
  begin
  end;

  procedure vendor_add_exclude_range_time (id: integer; min, max : time; grp: integer) is
  begin
  end;

  procedure vendor_add_exclude_vals_time (id: integer; vals : time_vector) is
  begin
  end;

  procedure vendor_add_range_signed (id: integer; min, max : signed) is
  begin
  end;

  procedure vendor_add_range_unsigned (id: integer; min, max : unsigned) is
  begin
  end;

  procedure vendor_add_vector_sum_max (id: integer; max : integer) is
  begin
  end;

  procedure vendor_add_vector_sum_min (id: integer; min : integer) is
  begin
  end;

  function vendor_randomize_int (id: integer) return integer is
  begin
    return 0;
  end;

  function vendor_randomize_real (id: integer) return real is
  begin
    return 0.0;
  end;

  function vendor_randomize_time (id: integer) return time is
  begin
    return 0 ns;
  end;

  procedure vendor_randomize_int_array (id: integer; size: integer; retval: out integer_vector) is
  begin
  end;

  procedure vendor_randomize_real_array (id: integer; size: integer; retval: out real_vector) is
  begin
  end;

  procedure vendor_randomize_time_array (id: integer; size: integer; retval: out time_vector) is
  begin
  end;

  procedure vendor_randomize_signed (id: integer; size: integer; retval: out signed) is
  begin
  end;

  procedure vendor_randomize_unsigned (id: integer; size: integer; retval: out unsigned) is
  begin
  end;

  procedure vendor_randomize_slv (id: integer; size: integer; retval: out std_logic_vector) is
  begin
  end;

  procedure vendor_clear_constraints (id: integer) is
  begin
  end;

  procedure vendor_randvar_set_seed (id: integer; seed: string) is
  begin
  end;

  procedure vendor_randvar_set_seed_ints (id: integer; seed1, seed2: integer) is
  begin
  end;

  procedure vendor_randvar_get_seed_ints (id: integer; seed1, seed2: out integer) is
  begin
  end;

  procedure vendor_randvar_add_range_weight_int (id: integer; min, max: integer; weight: natural) is
  begin
  end;

  procedure vendor_randvar_add_range_weight_real (id: integer; min, max: real; weight: natural) is
  begin
  end;

  procedure vendor_randvar_add_range_weight_time (id: integer; min, max: time; weight: natural) is
  begin
  end;

  procedure vendor_randvar_add_link (id1, id2: integer; op: integer) is
  begin
  end;

  procedure vendor_randvar_add_link2 (id1, id2: integer; op: integer; arith_op: integer; valOrId: integer; isVarId: integer) is
  begin
  end;

  procedure vendor_randvar_delete_link (id1, id2: integer) is
  begin
  end;

  procedure vendor_randvar_nonzero_bitwise_and (id: integer; mask: integer) is
  begin
  end;

  procedure vendor_randvar_zero_bitwise_and (id: integer; mask: integer) is
  begin
  end;

  procedure vendor_randvar_one_hot (id: integer) is
  begin
  end;

  procedure vendor_randvar_force_bits_to (id: integer; bitmask: string) is
  begin
  end;

end package body vendor_rand_extension_pkg;
