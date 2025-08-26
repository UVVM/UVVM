library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

library qoneRandlib;
use qoneRandlib.questaFuncCovPkg.all;

package vendor_func_cov_extension_pkg is
    constant C_VENDOR_EXTENSION_IS_ENABLED : boolean := true;

	function vendor_create_coverpoint_var  return integer;
    procedure vendor_func_cov_set_sampling_var (id: integer; path: string);
    procedure vendor_func_cov_set_coverpoint_var (id: integer; path: string);
    procedure vendor_func_cov_sample_coverage (id: integer);
	procedure vendor_func_cov_add_bin (id: integer; name: string; kind: integer; isTran: integer; lval: integer; rval: integer);
    procedure vendor_func_cov_bin_add_value (id: integer; lval: integer; rval: integer);
	function vendor_func_cov_get_bin_hits (id: integer; name: string) return integer;
    procedure vendor_func_cov_clear_coverage (id: integer);
end package vendor_func_cov_extension_pkg;

package body vendor_func_cov_extension_pkg is
    function vendor_create_coverpoint_var  return integer is
        begin
            return questa_create_func_cov_var;
    end;

    procedure vendor_func_cov_set_sampling_var (id: integer; path: string) is 
        begin
           questa_func_cov_set_sampling_var(id, path);
    end;

    procedure vendor_func_cov_set_coverpoint_var (id: integer; path: string) is 
        begin
           questa_func_cov_set_coverpoint_var(id, path);
    end;

    procedure vendor_func_cov_sample_coverage (id: integer) is
        begin
           questa_func_cov_sample_coverage(id);
    end;

    procedure vendor_func_cov_add_bin (id: integer; name: string; kind: integer; isTran: integer; lval: integer; rval: integer) is
        begin
           questa_func_cov_add_bin(id, name, kind, isTran, lval, rval);
    end;

    procedure vendor_func_cov_bin_add_value (id: integer; lval: integer; rval: integer) is
        begin
           questa_func_cov_bin_add_value(id, lval, rval);
    end;

    function vendor_func_cov_get_bin_hits (id: integer; name: string)  return integer is
        begin
            return questa_func_cov_get_bin_hits(id, name);
    end;

    procedure vendor_func_cov_clear_coverage (id: integer) is
        begin
           questa_func_cov_clear_coverage(id);
    end;
end package body vendor_func_cov_extension_pkg;

