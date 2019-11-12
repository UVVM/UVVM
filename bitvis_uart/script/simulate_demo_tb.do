#========================================================================================================================
# Copyright (c) 2019 by Bitvis AS.  All rights reserved.
# You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
# contact Bitvis AS <support@bitvis.no>.
#
# UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR
# OTHER DEALINGS IN UVVM.
#========================================================================================================================

#-----------------------------------------------------------------------
# Run simulation
#-----------------------------------------------------------------------
<<<<<<< HEAD
<<<<<<< HEAD:bitvis_uart/script/simulate_demo_tb.do
vsim bitvis_uart.uart_vvc_demo_tb
=======
vsim bitvis_irqc.irqc_demo_tb
>>>>>>> public:bitvis_irqc/script/simulate_demo_tb.do
=======
vsim bitvis_uart.uart_vvc_demo_tb
>>>>>>> public
do wave.do
run -all