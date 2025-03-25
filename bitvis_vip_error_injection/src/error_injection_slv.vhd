--================================================================================================================================
-- Copyright 2024 UVVM
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
-- VHDL unit     : Bitvis VIP Error Injection Library : error_injection_pkg
--
-- Description   : See library quick reference (under 'doc') and README-file(s).
--

library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_error_injection;
use bitvis_vip_error_injection.error_injection_pkg.all;

entity error_injection_slv is
  generic(
    GC_START_TIME   : time    := 0 ns;
    GC_INSTANCE_IDX : natural := 1
  );
  port(
    ei_in  : in  std_logic_vector;
    ei_out : out std_logic_vector
  );
end entity error_injection_slv;

architecture behave of error_injection_slv is
begin

  p_error_injection : process
    constant C_INITIAL_VALUE_DONT_CARE : std_logic_vector(ei_in'length - 1 downto 0) := (others => '-');
    constant C_IS_VECTOR               : boolean                                     := (ei_in'length > 1);
    -- helper variables
    variable v_initial_delay           : time                                        := 0 ns;
    variable v_return_delay            : time                                        := 0 ns;
    variable v_width                   : time                                        := 0 ns;
    variable v_interval_counter        : natural                                     := 0;
    variable v_last_ei_in              : std_logic_vector(ei_in'length - 1 downto 0) := (others => '0');
    variable v_config_copy             : t_error_injection_config                    := shared_ei_config(GC_INSTANCE_IDX);
    variable v_timestamp               : time;
    variable v_seeds                   : t_positive_vector(0 to 1)                   := (1, 2);

    alias ei_config is shared_ei_config(GC_INSTANCE_IDX);
    alias base_value is ei_config.base_value;
    alias error_type is ei_config.error_type;

    -- Return random time within specified range if requested.
    impure function get_error_injection_timing(start_time : time; end_time : time) return time is
      variable v_rand : time := 0 ns;
    begin
      if end_time = 0 ns then
        return start_time;
      else
        random(start_time, end_time, v_seeds(0), v_seeds(1), v_rand);
        return v_rand;
      end if;
    end function get_error_injection_timing;

    -- Computes if input interval number is a error inject interval
    impure function is_valid_interval(counter : natural; error_type : t_error_injection_types) return boolean is
    begin
      if (counter mod ei_config.interval) = 0 then
        return true;
      elsif error_type = BYPASS then
        return true;
      else
        return false;
      end if;
    end function is_valid_interval;

  begin
    -- Use the instance_name attribute and instance index to generate seeds for randomized timing parameters
    set_rand_seeds(v_seeds'instance_name & to_string(GC_INSTANCE_IDX), v_seeds(0), v_seeds(1));

    -- Wait before monitoring signal
    v_timestamp := now;
    while (now - v_timestamp) < GC_START_TIME loop
      ei_out <= ei_in;
      wait on ei_in;
    end loop;

    ei_out <= ei_in;

    -- Error injection process loop
    while true loop

      ---------------------------------------------------
      -- Start of error injection. Find initial edge
      --
      -- BYPASS : don't care about edges
      -- SLV    : all edges are initial
      -- SL     : find initial edge
      ---------------------------------------------------
      if C_IS_VECTOR or (error_type = BYPASS) then
        v_last_ei_in := ei_in;
        wait on ei_in;
      else
        if (base_value = '-') then      -- don't care
          wait on ei_in;
        else
          wait until ei_in'event and ei_in(0) /= base_value;
        end if;
      end if;

      -- Update the interval counter
      v_interval_counter := v_interval_counter + 1;

      -- Reset interval counter when we receive a new config
      if ei_config /= v_config_copy then
        v_config_copy      := ei_config;
        v_interval_counter := 0;
      end if;

      -- Inject error if correct interval (SL: and if not the return edge).
      if is_valid_interval(v_interval_counter, ei_config.error_type) then

        -- Decode error type.
        case error_type is

          ------------------------------------------------------
          when BYPASS =>
            ei_out <= ei_in;

          ------------------------------------------------------
          when DELAY | JITTER =>
            v_initial_delay := get_error_injection_timing(ei_config.initial_delay_min, ei_config.initial_delay_max);
            v_return_delay  := get_error_injection_timing(ei_config.return_delay_min, ei_config.return_delay_max);

            ei_out <= transport ei_in after v_initial_delay;

            -- Wait on return edge for SL
            if not (C_IS_VECTOR) then
              wait on ei_in;
            end if;

            -- This will be overwritten by next event for SLV
            if ei_config.error_type = JITTER then
              ei_out <= transport ei_in after v_return_delay;
            else
              ei_out <= transport ei_in after v_initial_delay;
            end if;

          ------------------------------------------------------
          when INVERT =>
            ei_out <= not (ei_in);
            -- Wait on return edge for SL
            if not (C_IS_VECTOR) then
              wait on ei_in;
              ei_out <= not (ei_in);
            end if;

          ------------------------------------------------------
          when PULSE =>
            v_initial_delay := get_error_injection_timing(ei_config.initial_delay_min, ei_config.initial_delay_max);
            v_width         := get_error_injection_timing(ei_config.width_min, ei_config.width_max);

            -- Set output
            ei_out <= ei_in;
            -- Set pulse
            ei_out <= transport v_last_ei_in after v_initial_delay;
            -- Set output
            ei_out <= transport ei_in after (v_initial_delay + v_width);

            if not (C_IS_VECTOR) then   -- return edge
              wait on ei_in;
              ei_out <= ei_in;
            end if;

          ------------------------------------------------------
          when STUCK_AT_OLD =>
            v_width := get_error_injection_timing(ei_config.width_min, ei_config.width_max);

            ei_out <= v_last_ei_in;

            -- Release after stuck width
            wait for v_width;
            ei_out <= ei_in;

            if not (C_IS_VECTOR) then
              wait on ei_in;
              ei_out <= ei_in;
            end if;

          ------------------------------------------------------
          when STUCK_AT_NEW =>
            v_width := get_error_injection_timing(ei_config.width_min, ei_config.width_max);

            ei_out <= ei_in;

            -- Release after stuck width
            wait for v_width;
            ei_out <= ei_in;

            if not (C_IS_VECTOR) and (ei_in'last_event > v_width) then
              wait on ei_in;
              ei_out <= ei_in;
            end if;

        end case;

      -- Not correct interval, bypass signal
      else
        -- Set initial edge
        ei_out <= ei_in;

        -- SL: set return edge
        if not (C_IS_VECTOR) then
          if (base_value /= '-') then
            wait until ei_in'event and ei_in(0) = base_value;
          else
            wait on ei_in;
          end if;
          ei_out <= ei_in;
        end if;

      end if;

      -- Reset interval counter.
      if v_interval_counter >= ei_config.interval then
        v_interval_counter := 0;
      end if;

    end loop;

    wait;
  end process p_error_injection;

end architecture behave;
