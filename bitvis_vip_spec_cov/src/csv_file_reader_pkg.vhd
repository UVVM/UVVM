-- The CSV reader package was Retrieved from https://github.com/ricardo-jasinski/vhdl-csv-file-reader
-- The package has been modified for use with UVVM.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

-- Define operations to read formatted data from a comma-separated-values file
-- (CSV file). To use this package:
--    1. Create a csv_file_reader:      variable csv: csv_file_reader_type;
--    2. Open a csv file:               csv.initialize("c:\file.csv");
--    3. Read one line at a time:       csv.readline;
--    4. Start reading values:          my_integer := csv.read_integer;
--    5. To read more values in the same line, call any of the read_* functions
--    6. To move to the next line, call csv.readline() again
package csv_file_reader_pkg is

  type csv_file_reader_type is protected
    -- Open the CSV text file to be used for subsequent read operations
    impure function initialize(file_pathname : string; csv_delimiter : character := ',') return boolean;
    -- Release (close) the associated CSV file
    procedure dispose;
    -- Read one line from the csv file, and keep it in the cache
    procedure readline;
    -- Read a string from the csv file and convert it to an integer
    impure function read_integer return integer;
    -- Read a string from the csv file and convert it to real
    impure function read_real return real;
    -- Read a string from the csv file and convert it to boolean
    impure function read_boolean return boolean;
    -- Read a string with a numeric value from the csv file and convert it to a boolean
    impure function read_integer_as_boolean return boolean;
    -- Read a string from the csv file, until a separator character ',' is found
    impure function read_string return string;
    -- True when the end of the CSV file was reached
    impure function end_of_file return boolean;
  end protected csv_file_reader_type;

end package csv_file_reader_pkg;

package body csv_file_reader_pkg is

  type csv_file_reader_type is protected body

    constant C_CSV_READER_SCOPE       : string    := "CSV_READER";
    variable priv_csv_delimiter       : character := ';';
    file     priv_csv_file            : text;
    variable priv_current_line        : line;    -- cache one line at a time for read operations
    variable priv_end_of_file_reached : boolean; -- true when end of file was reached and there are no more lines to read

    -- True when the end of the CSV file was reached
    impure function end_of_file return boolean is
    begin
      return priv_end_of_file_reached;
    end function end_of_file;

    -- Open the CSV text file to be used for subsequent read operations
    impure function initialize(
      file_pathname : string;
      csv_delimiter : character := ','
    ) return boolean is
      variable v_file_open_status : FILE_OPEN_STATUS;
    begin
      priv_csv_delimiter := csv_delimiter;
      file_open(v_file_open_status, priv_csv_file, file_pathname, READ_MODE);
      check_file_open_status(v_file_open_status, file_pathname);

      priv_end_of_file_reached := false;

      -- Check that file is not empty
      if v_file_open_status = open_ok then
        if endfile(priv_csv_file) then
          alert(TB_ERROR, "CSV file is empty " & file_pathname);
          priv_end_of_file_reached := true;
          return false;
        end if;
      end if;

      if v_file_open_status = open_ok then
        return true;
      else
        return false;
      end if;
    end function initialize;

    -- Release (close) the associated CSV file
    procedure dispose is
    begin
      file_close(priv_csv_file);
    end procedure dispose;

    -- Read one line from the csv file, and keep it in the cache
    procedure readline is
    begin
      readline(priv_csv_file, priv_current_line);
      priv_end_of_file_reached := endfile(priv_csv_file);
    end procedure readline;

    -- Skip a separator (comma character) in the current line
    procedure skip_separator is
      variable v_dummy_string : string(1 to C_CSV_FILE_MAX_LINE_LENGTH);
    begin
      v_dummy_string := read_string;
    end procedure skip_separator;

    -- Read a string from the csv file and convert it to integer
    impure function read_integer return integer is
      variable v_read_value : integer;
    begin
      read(priv_current_line, v_read_value);
      skip_separator;
      return v_read_value;
    end function read_integer;

    -- Read a string from the csv file and convert it to real
    impure function read_real return real is
      variable v_read_value : real;
    begin
      read(priv_current_line, v_read_value);
      skip_separator;
      return v_read_value;
    end function read_real;

    -- Read a string from the csv file and convert it to boolean
    impure function read_boolean return boolean is
    begin
      return boolean'value(read_string);
    end function read_boolean;

    impure function read_integer_as_boolean return boolean is
    begin
      return (read_integer /= 0);
    end function read_integer_as_boolean;

    -- Read a string from the csv file, until a delimiter is found
    impure function read_string return string is
      variable v_return_string           : string(1 to C_CSV_FILE_MAX_LINE_LENGTH) := (others => NUL);
      variable v_read_char               : character;
      variable v_read_ok                 : boolean                                 := true;
      variable v_index                   : integer                                 := 1;
      variable v_skip_leading_whitespace : boolean                                 := true;
    begin
      read(priv_current_line, v_read_char, v_read_ok);
      l_read_char : while v_read_ok loop
        if v_read_char = ' ' and v_skip_leading_whitespace then
          null;
        elsif v_read_char = priv_csv_delimiter then
          exit l_read_char;
        elsif v_index <= C_CSV_FILE_MAX_LINE_LENGTH then
          v_return_string(v_index)  := v_read_char;
          v_index                   := v_index + 1;
          v_skip_leading_whitespace := false;
        else
          alert(FAILURE, "A line length in the CSV file is greater than C_CSV_FILE_MAX_LINE_LENGTH defined in adaptations_pkg.vhd", C_CSV_READER_SCOPE);
        end if;
        read(priv_current_line, v_read_char, v_read_ok);
      end loop l_read_char;
      return v_return_string;
    end function read_string;

  end protected body csv_file_reader_type;

end package body csv_file_reader_pkg;
