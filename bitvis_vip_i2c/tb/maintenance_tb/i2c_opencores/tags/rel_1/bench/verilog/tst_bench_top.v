/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE rev.B2 compliant I2C Master controller Testbench  ////
////                                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/projects/i2c/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: tst_bench_top.v,v 1.3 2002-10-30 18:11:06 rherveille Exp $
//
//  $Date: 2002-10-30 18:11:06 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/03/17 10:26:38  rherveille
//               Fixed some race conditions in the i2c-slave model.
//               Added debug information.
//               Added headers.
//

`include "timescale.v"

module tst_bench_top();

	//
	// wires && regs
	//
	reg  clk;
	reg  rstn;

	wire [31:0] adr;
	wire [ 7:0] dat_i, dat_o;
	wire we;
	wire stb;
	wire cyc;
	wire ack;
	wire inta;

	reg [7:0] q, qq;

	wire scl, scl_o, scl_oen;
	wire sda, sda_o, sda_oen;

	parameter PRER_LO = 3'b000;
	parameter PRER_HI = 3'b001;
	parameter CTR     = 3'b010;
	parameter RXR     = 3'b011;
	parameter TXR     = 3'b011;
	parameter CR      = 3'b100;
	parameter SR      = 3'b100;

	parameter TXR_R   = 3'b101; // undocumented / reserved output
	parameter CR_R    = 3'b110; // undocumented / reserved output

	//
	// Module body
	//

	// generate clock
	always #5 clk = ~clk;

	// hookup wishbone master model
	wb_master_model #(8, 32) u0 (
		.clk(clk),
		.rst(rstn),
		.adr(adr),
		.din(dat_i),
		.dout(dat_o),
		.cyc(cyc),
		.stb(stb),
		.we(we),
		.sel(),
		.ack(ack),
		.err(1'b0),
		.rty(1'b0)
	);

	// hookup wishbone_i2c_master core
	i2c_master_top i2c_top (

		// wishbone interface
		.wb_clk_i(clk), 
		.wb_rst_i(1'b0), 
		.arst_i(rstn), 
		.wb_adr_i(adr[2:0]), 
		.wb_dat_i(dat_o), 
		.wb_dat_o(dat_i), 
		.wb_we_i(we), 
		.wb_stb_i(stb), 
		.wb_cyc_i(cyc), 
		.wb_ack_o(ack), 
		.wb_inta_o(inta),

		// i2c signals
		.scl_pad_i(scl), 
		.scl_pad_o(scl_o), 
		.scl_padoen_o(scl_oen), 
		.sda_pad_i(sda), 
		.sda_pad_o(sda_o), 
		.sda_padoen_o(sda_oen)
	);

	// hookup i2c slave model
	i2c_slave_model #(7'b1010_000) i2c_slave (
		.scl(scl),
		.sda(sda)
	);

	// create i2c lines
	assign scl = scl_oen ? 1'bz : scl_o; // create tri-state buffer for i2c_master scl line
	assign sda = sda_oen ? 1'bz : sda_o; // create tri-state buffer for i2c_master sda line

	pullup p1(scl); // pullup scl line
	pullup p2(sda); // pullup sda line

	initial
	  begin
	      `ifdef WAVES
	         $shm_open("waves");
	         $shm_probe("AS",tst_bench_top,"AS");
	         $display("INFO: Signal dump enabled ...\n\n");
	      `endif

//	      force i2c_slave.debug = 1'b1; // enable i2c_slave debug information
	      force i2c_slave.debug = 1'b0; // disable i2c_slave debug information

	      $display("\nstatus: %t Testbench started\n\n", $time);

//	      $dumpfile("bench.vcd");
//	      $dumpvars(1, tst_bench_top);
//	      $dumpvars(1, tst_bench_top.i2c_slave);

	      // initially values
	      clk = 0;

	      // reset system
	      rstn = 1'b1; // negate reset
	      #2;
	      rstn = 1'b0; // assert reset
	      repeat(20) @(posedge clk);
	      rstn = 1'b1; // negate reset

	      $display("status: %t done reset", $time);

	      @(posedge clk);

	      //
	      // program core
	      //

	      // program internal registers
//	      u0.wb_write(1, PRER_LO, 8'hfa); // load prescaler lo-byte
	      u0.wb_write(1, PRER_LO, 8'hc8); // load prescaler lo-byte
	      u0.wb_write(1, PRER_HI, 8'h00); // load prescaler hi-byte
	      $display("status: %t programmed registers", $time);

	      u0.wb_cmp(0, PRER_LO, 8'hc8); // verify prescaler lo-byte
	      u0.wb_cmp(0, PRER_HI, 8'h00); // verify prescaler hi-byte
	      $display("status: %t verified registers", $time);

	      u0.wb_write(1, CTR,     8'h80); // enable core
	      $display("status: %t core enabled", $time);

	      //
	      // access slave (write)
	      //

	      // drive slave address
	      u0.wb_write(1, TXR,     8'ha0); // present slave address, set write-bit (== !read)
	      u0.wb_write(0, CR,      8'h90); // set command (start, write)
	      $display("status: %t generate 'start', write cmd a0 (slave address+write)", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(0, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     8'h01); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave memory address 01", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(0, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory contents
	      u0.wb_write(1, TXR,     8'ha5); // present data
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write data a5", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory contents for next memory address (auto_inc)
	      u0.wb_write(1, TXR,     8'h5a); // present data
	      u0.wb_write(0, CR,      8'h50); // set command (stop, write)
	      $display("status: %t write next data 5a, generate 'stop'", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      //
	      // delay
	      //
//	      #100000; // wait for 100us.
//	      $display("status: %t wait 100us", $time);

	      //
	      // access slave (read)
	      //

	      // drive slave address
	      u0.wb_write(1, TXR,     8'ha0); // present slave address, set write-bit (== !read)
	      u0.wb_write(0, CR,      8'h90); // set command (start, write)
	      $display("status: %t generate 'start', write cmd a0 (slave address+write)", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     8'h01); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave address 01", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // drive slave address
	      u0.wb_write(1, TXR,     8'ha1); // present slave's address, set read-bit
	      u0.wb_write(0, CR,      8'h90); // set command (start, write)
	      $display("status: %t generate 'repeated start', write cmd a1 (slave address+read)", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h20); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, qq);
	      if(qq !== 8'ha5)
	        $display("\nERROR: Expected a5, received %x at time %t", qq, $time);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h20); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, qq);
	      if(qq !== 8'h5a)
	        $display("\nERROR: Expected 5a, received %x at time %t", qq, $time);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h20); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, qq);
	      $display("status: %t received %x from 3rd read address", $time, qq);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h28); // set command (read, nack_read)
	      $display("status: %t read + nack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, qq);
	      $display("status: %t received %x from 4th read address", $time, qq);

	      //
	      // check invalid slave memory address
	      //

	      // drive slave address
	      u0.wb_write(1, TXR,     8'ha0); // present slave address, set write-bit (== !read)
	      u0.wb_write(0, CR,      8'h90); // set command (start, write)
	      $display("status: %t generate 'start', write cmd a0 (slave address+write). Check invalid address", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     8'h10); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave memory address 10", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // slave should have send NACK
	      $display("status: %t Check for nack", $time);
	      if(!q[7])
	        $display("\nERROR: Expected NACK, received ACK\n");

	      // read data from slave
	      u0.wb_write(1, CR,      8'h40); // set command (stop)
	      $display("status: %t generate 'stop'", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	      u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      #25000; // wait 25us
	      $display("\n\nstatus: %t Testbench done", $time);
	      $finish;
	  end

endmodule


