library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity dummy_counter is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    count     : out std_logic_vector(7 downto 0);
    count_vld : out std_logic
  );
end entity dummy_counter;

architecture rtl of dummy_counter is
  signal count_int : unsigned(7 downto 0) := (others => '0');
  signal vld_int   : std_logic := '0';
begin
  process(clk, rst)
  begin
    if rst = '1' then
      count_int <= (others => '0');
      vld_int   <= '0';
    elsif rising_edge(clk) then
      vld_int <= '1';
      count_int <= count_int + 1;
    end if;
  end process;
  count     <= std_logic_vector(count_int);
  count_vld <= vld_int;
end architecture rtl;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity one_hot_in_range_generator is
  generic(
    -- If not one-hot, will be the next number up (which is one-hot)
    GC_ONE_HOT_LOWER_LIMIT  : integer range 1 to 2147483647 := 1; 
    -- If not one-hot, will be the next number down (which is one-hot)
    GC_ONE_HOT_UPPER_LIMIT  : integer range 1 to 2147483647 := 16
  );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    one_hot   : out unsigned(31 downto 0)
  );
end entity one_hot_in_range_generator;

architecture rtl of one_hot_in_range_generator is
    function f_is_one_hot(number : unsigned) return boolean is
      variable v_num_ones : integer := 0;
    begin
      for i in number'range loop
        if number(i) = '1' then
          v_num_ones := v_num_ones + 1;
        end if;
      end loop;
      return (v_num_ones = 1);  -- Return true if there is exactly one '1' in the number
    end function f_is_one_hot;

    function f_find_leftmost_high_pos(number : unsigned) return integer is
    begin
      for i in number'range loop
        if number(i) = '1' then
          return i;  -- Return the position of the first '1'
        end if;
      end loop;
      return 0;  -- If no '1' found
    end function f_find_leftmost_high_pos;

begin
  process(clk, rst)
    variable v_current_pos      : integer := 0;
    variable v_one_hot_internal : unsigned(one_hot'range) := (others => '0');
    variable v_lower_limit      : unsigned(31 downto 0) := to_unsigned(GC_ONE_HOT_LOWER_LIMIT, 32);
    variable v_upper_limit      : unsigned(31 downto 0) := to_unsigned(GC_ONE_HOT_UPPER_LIMIT, 32);
  begin

    if not f_is_one_hot(v_lower_limit) then
      v_current_pos := f_find_leftmost_high_pos(v_lower_limit);
      v_lower_limit := (others => '0');
      v_lower_limit(v_current_pos+1) := '1'; -- Set to the next one-hot value
    end if;

    if not f_is_one_hot(v_upper_limit) then
      v_current_pos := f_find_leftmost_high_pos(v_upper_limit);
      v_upper_limit := (others => '0');
      v_upper_limit(v_current_pos) := '1'; -- Set to the previous one-hot value
    end if;

    assert (v_lower_limit <= v_upper_limit)
      report "GC_ONE_HOT_LOWER_LIMIT must be less than GC_ONE_HOT_UPPER_LIMIT. If one is NOT one-hot the next one-hot up (for LOWER) or down (for UPPER) will be used."
      severity FAILURE;

    if rst = '1' then
      v_one_hot_internal := (others => '0');
    elsif rising_edge(clk) then  
      if v_one_hot_internal < v_lower_limit then
        v_one_hot_internal := v_lower_limit;  -- Set to the lower limit if below it
      else
        v_current_pos := f_find_leftmost_high_pos(v_one_hot_internal);
        v_one_hot_internal := (others => '0');
        v_one_hot_internal(v_current_pos+1) := '1';  -- Reset to the current one-hot position
        if v_one_hot_internal > v_upper_limit then
          v_one_hot_internal := v_lower_limit;  -- Wrap around to the lower limit if exceeded the upper limit
        end if;
      end if;
      one_hot <= v_one_hot_internal;
    end if;
  end process;
end architecture rtl;