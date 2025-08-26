library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

package vendor_func_cov_extension_pkg is
    constant C_VENDOR_EXTENSION_IS_ENABLED : boolean := false;

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
            assert FALSE
            report "Missing vendor function: vendor_create_coverpoint_var"
            severity error;
            return 0;
    end;

    procedure vendor_func_cov_set_sampling_var (id: integer; path: string) is 
        begin
            assert FALSE
            report "Missing vendor function: vendor_func_cov_set_sampling_var"
            severity error;
    end;

    procedure vendor_func_cov_set_coverpoint_var (id: integer; path: string) is 
        begin
            assert FALSE
            report "Missing vendor function: vendor_func_cov_set_sampling_var"
            severity error;
    end;

    procedure vendor_func_cov_sample_coverage (id: integer) is 
        begin
            assert FALSE
            report "Missing vendor function: vendor_func_cov_sample_coverage"
            severity error;
    end;

    procedure vendor_func_cov_add_bin (id: integer; name: string; kind: integer; isTran: integer; lval: integer; rval: integer) is 
        begin
            assert FALSE
            report "Missing vendor function: vendor_func_cov_add_bin"
            severity error;
    end;

    procedure vendor_func_cov_bin_add_value (id: integer; lval: integer; rval: integer) is 
        begin
            assert FALSE
            report "Missing vendor function: vendor_func_cov_bin_add_value"
            severity error;
    end;

    function vendor_func_cov_get_bin_hits(id: integer; name: string)  return integer is
        begin
            assert FALSE
            report "Missing vendor function: vendor_func_cov_get_bin_hits"
            severity error;
            return 0;
    end;

    procedure vendor_func_cov_clear_coverage (id: integer) is 
        begin
            assert FALSE
            report "Missing vendor function: vendor_func_cov_clear_coverage"
            severity error;
    end;

end package body vendor_func_cov_extension_pkg;

