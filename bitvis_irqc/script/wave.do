#================================================================================================================================
# Copyright 2024 UVVM
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

# Detect simulator
if {[catch {eval "vsim -version"} message] == 0} {
  quietly set simulator_version [eval "vsim -version"]
  puts "Version is: $simulator_version"
  if {[regexp -nocase {modelsim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {questasim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {aldec} $simulator_version]} {
    quietly set simulator "rivierapro"
  } else {
    puts "Unknown simulator. Attempting to use Modelsim commands."
    quietly set simulator "modelsim"
  }
} else {
    puts "vsim -version failed with the following message:\n $message"
    abort all
}

onerror {resume}
if {$simulator == "modelsim"} {
  quietly WaveActivateNextPane {} 0
}
add wave -noupdate -radix hexadecimal /irqc_demo_tb/C_CLK_PERIOD
add wave -noupdate -radix hexadecimal /irqc_demo_tb/clock_ena
add wave -noupdate -divider Clock,Reset,SBI
add wave -noupdate -radix hexadecimal /irqc_demo_tb/clk
add wave -noupdate -radix hexadecimal /irqc_demo_tb/arst
add wave -noupdate -radix hexadecimal /irqc_demo_tb/sbi_if
add wave -noupdate -divider {C2P, P2C and Regs}
add wave -noupdate -radix hexadecimal -childformat {{/irqc_demo_tb/i_irqc/i_irqc_core/p2c.rw_ier -radix hexadecimal} {/irqc_demo_tb/i_irqc/i_irqc_core/p2c.awt_itr -radix hexadecimal} {/irqc_demo_tb/i_irqc/i_irqc_core/p2c.awt_icr -radix hexadecimal} {/irqc_demo_tb/i_irqc/i_irqc_core/p2c.awt_irq2cpu_ena -radix hexadecimal}} -expand -subitemconfig {/irqc_demo_tb/i_irqc/i_irqc_core/p2c.rw_ier {-radix hexadecimal} /irqc_demo_tb/i_irqc/i_irqc_core/p2c.awt_itr {-radix hexadecimal} /irqc_demo_tb/i_irqc/i_irqc_core/p2c.awt_icr {-radix hexadecimal} /irqc_demo_tb/i_irqc/i_irqc_core/p2c.awt_irq2cpu_ena {-radix hexadecimal}} /irqc_demo_tb/i_irqc/i_irqc_core/p2c
add wave -noupdate -radix hexadecimal -childformat {{/irqc_demo_tb/i_irqc/i_irqc_core/c2p.aro_irr -radix hexadecimal} {/irqc_demo_tb/i_irqc/i_irqc_core/c2p.aro_ipr -radix hexadecimal} {/irqc_demo_tb/i_irqc/i_irqc_core/c2p.aro_irq2cpu_allowed -radix hexadecimal}} -expand -subitemconfig {/irqc_demo_tb/i_irqc/i_irqc_core/c2p.aro_irr {-color White -radix hexadecimal} /irqc_demo_tb/i_irqc/i_irqc_core/c2p.aro_ipr {-radix hexadecimal} /irqc_demo_tb/i_irqc/i_irqc_core/c2p.aro_irq2cpu_allowed {-radix hexadecimal}} /irqc_demo_tb/i_irqc/i_irqc_core/c2p
add wave -noupdate -radix hexadecimal /irqc_demo_tb/i_irqc/i_irqc_core/igr
add wave -noupdate -divider {IRQ in and out}
add wave -noupdate -radix hexadecimal /irqc_demo_tb/irq2cpu
add wave -noupdate -radix hexadecimal /irqc_demo_tb/irq2cpu_ack
add wave -noupdate -color Cyan -radix hexadecimal /irqc_demo_tb/irq_source
if {$simulator == "modelsim"} {
  TreeUpdate [SetDefaultTree]
  WaveRestoreCursors {{Cursor 1} {193798 ps} 0}
  configure wave -namecolwidth 226
  configure wave -valuecolwidth 100
  configure wave -justifyvalue left
  configure wave -signalnamewidth 2
  configure wave -snapdistance 10
  configure wave -datasetprefix 0
  configure wave -rowmargin 4
  configure wave -childrowmargin 2
  configure wave -gridoffset 0
  configure wave -gridperiod 1
  configure wave -griddelta 40
  configure wave -timeline 0
  configure wave -timelineunits ps
  WaveRestoreZoom {0 ps} {270375 ps}
}
quietly wave cursor active 1
update
