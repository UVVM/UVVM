--IP Functional Simulation Model
--VERSION_BEGIN 14.0 cbx_mgl 2014:06:05:10:17:12:SJ cbx_simgen 2014:06:05:09:45:41:SJ  VERSION_END


-- Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus II License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- You may only use these simulation model output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event Altera disclaims all warranties of any kind).


--synopsys translate_off

 LIBRARY altera_mf;
 USE altera_mf.altera_mf_components.all;

 LIBRARY sgate;
 USE sgate.sgate_pack.all;

--synthesis_resources = altsyncram 1 lut 34 mux21 19 oper_add 2 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

-- this is a fifo of 2048x8 bits
 
 ENTITY  sc_fifo IS 
	 PORT 
	 ( 
		 clk	:	IN  STD_LOGIC;
		 in_data	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 in_ready	:	OUT  STD_LOGIC;
		 in_valid	:	IN  STD_LOGIC;
		 out_data	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 out_ready	:	IN  STD_LOGIC;
		 out_valid	:	OUT  STD_LOGIC;
		 reset	:	IN  STD_LOGIC
	 ); 
 END sc_fifo;

 ARCHITECTURE RTL OF sc_fifo IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_address_a	:	STD_LOGIC_VECTOR (10 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_address_b	:	STD_LOGIC_VECTOR (10 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_data_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_121q	:	STD_LOGIC := '0';
	 SIGNAL  wire_ni_w112w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_129q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_139q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_120q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_10_95q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_104q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_103q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_102q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_101q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_100q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_6_99q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_7_98q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_8_97q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_9_96q	:	STD_LOGIC := '0';
	 SIGNAL  wire_nl_w1w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_0_180q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_1_147q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_2_146q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_3_145q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_4_144q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_5_143q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_6_142q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_7_141q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_140q	:	STD_LOGIC := '0';
	 SIGNAL  wire_nlO_w110w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_94q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_10_84q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_93q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_92q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_91q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_90q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_89q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_6_88q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_7_87q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_8_86q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_9_85q	:	STD_LOGIC := '0';
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_127m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_128m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_81m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_10_71m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_80m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_79m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_78m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_77m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_76m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_6_75m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_7_74m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_8_73m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_9_72m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_108m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_110m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_115m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_109m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_114m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_116m_dataout	:	STD_LOGIC;
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_a	:	STD_LOGIC_VECTOR (10 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_b	:	STD_LOGIC_VECTOR (10 DOWNTO 0);
	 SIGNAL  wire_gnd	:	STD_LOGIC;
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o	:	STD_LOGIC_VECTOR (10 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_a	:	STD_LOGIC_VECTOR (10 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_b	:	STD_LOGIC_VECTOR (10 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o	:	STD_LOGIC_VECTOR (10 DOWNTO 0);
	 SIGNAL  wire_w_lg_reset95w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w108w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w106w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_106_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_112_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_ready_124_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_0_334_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_0_346_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_46_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_vcc :	STD_LOGIC;
 BEGIN

	wire_gnd <= '0';
	wire_w_lg_reset95w(0) <= NOT reset;
	wire_w108w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout;
	wire_w106w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_46_dataout;
	in_ready <= wire_nl_w1w(0);
	out_data <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_7_141q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_6_142q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_5_143q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_4_144q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_3_145q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_2_146q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_1_147q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_0_180q);
	out_valid <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_140q;
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_106_dataout <= (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout AND wire_w106w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_112_dataout <= (wire_w108w(0) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_46_dataout);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_ready_124_dataout <= (out_ready OR wire_nlO_w110w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_0_334_dataout <= (((((((((((NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(0) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_94q)) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(1) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_93q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(2) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_92q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(3) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_91q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(4) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_90q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(5) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_89q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(6) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_6_88q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(7) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_7_87q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(8) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_8_86q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(9) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_9_85q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(10) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_10_84q)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_0_346_dataout <= (((((((((((NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(0) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_120q)) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(1) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_104q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(2) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_103q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(3) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_102q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(4) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_101q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(5) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_100q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(6) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_6_99q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(7) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_7_98q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(8) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_8_97q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(9) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_9_96q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(10) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_10_95q)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout <= (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_ready_124_dataout AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_139q);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_46_dataout <= (in_valid AND wire_nl_w1w(0));
	s_wire_vcc <= '1';
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_address_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_10_84q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_9_85q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_8_86q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_7_87q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_6_88q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_89q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_90q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_91q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_92q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_93q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_94q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_address_b <= ( wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_10_71m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_9_72m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_8_73m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_7_74m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_6_75m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_76m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_77m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_78m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_79m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_80m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_81m_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_data_a <= ( in_data(7 DOWNTO 0));
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422 :  altsyncram
	  GENERIC MAP (
		ADDRESS_ACLR_A => "NONE",
		ADDRESS_ACLR_B => "NONE",
		ADDRESS_REG_B => "CLOCK0",
		BYTE_SIZE => 8,
		BYTEENA_ACLR_A => "NONE",
		BYTEENA_ACLR_B => "NONE",
		BYTEENA_REG_B => "CLOCK1",
		CLOCK_ENABLE_CORE_A => "USE_INPUT_CLKEN",
		CLOCK_ENABLE_CORE_B => "USE_INPUT_CLKEN",
		CLOCK_ENABLE_INPUT_A => "NORMAL",
		CLOCK_ENABLE_INPUT_B => "NORMAL",
		CLOCK_ENABLE_OUTPUT_A => "NORMAL",
		CLOCK_ENABLE_OUTPUT_B => "NORMAL",
		ECC_PIPELINE_STAGE_ENABLED => "FALSE",
		ENABLE_ECC => "FALSE",
		INDATA_ACLR_A => "NONE",
		INDATA_ACLR_B => "NONE",
		INDATA_REG_B => "CLOCK1",
		INIT_FILE_LAYOUT => "PORT_A",
		INTENDED_DEVICE_FAMILY => "Cyclone IV GX",
		NUMWORDS_A => 2048,
		NUMWORDS_B => 2048,
		OPERATION_MODE => "DUAL_PORT",
		OUTDATA_ACLR_A => "NONE",
		OUTDATA_ACLR_B => "NONE",
		OUTDATA_REG_A => "UNREGISTERED",
		OUTDATA_REG_B => "UNREGISTERED",
		RAM_BLOCK_TYPE => "AUTO",
		RDCONTROL_ACLR_B => "NONE",
		RDCONTROL_REG_B => "CLOCK1",
		READ_DURING_WRITE_MODE_MIXED_PORTS => "OLD_DATA",
		READ_DURING_WRITE_MODE_PORT_A => "NEW_DATA_NO_NBE_READ",
		READ_DURING_WRITE_MODE_PORT_B => "NEW_DATA_NO_NBE_READ",
		WIDTH_A => 8,
		WIDTH_B => 8,
		WIDTH_BYTEENA_A => 1,
		WIDTH_BYTEENA_B => 1,
		WIDTH_ECCSTATUS => 3,
		WIDTHAD_A => 11,
		WIDTHAD_B => 11,
		WRCONTROL_ACLR_A => "NONE",
		WRCONTROL_ACLR_B => "NONE",
		WRCONTROL_WRADDRESS_REG_B => "CLOCK1",
		lpm_hint => "WIDTH_BYTEENA=1"
	  )
	  PORT MAP ( 
		address_a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_address_a,
		address_b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_address_b,
		clock0 => clk,
		data_a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_data_a,
		q_b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b,
		wren_a => s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_46_dataout
	  );
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_121q <= '1';
		ELSIF (clk = '1' AND clk'event) THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_121q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_115m_dataout;
		END IF;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_121q <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_ni_w112w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_121q;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_129q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_139q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_120q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_10_95q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_104q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_103q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_102q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_101q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_100q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_6_99q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_7_98q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_8_97q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_9_96q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_129q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_116m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_139q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_128m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_120q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_81m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_10_95q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_10_71m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_104q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_80m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_103q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_79m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_102q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_78m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_101q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_77m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_100q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_76m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_6_99q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_6_75m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_7_98q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_7_74m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_8_97q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_8_73m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_9_96q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_9_72m_dataout;
		END IF;
	END PROCESS;
	wire_nl_w1w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_129q;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_0_180q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_1_147q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_2_146q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_3_145q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_4_144q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_5_143q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_6_142q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_7_141q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_140q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
			IF (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_ready_124_dataout = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_0_180q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b(0);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_1_147q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b(1);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_2_146q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b(2);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_3_145q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b(3);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_4_144q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b(4);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_5_143q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b(5);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_6_142q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b(6);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_7_141q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_422_q_b(7);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_140q <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_139q;
			END IF;
		END IF;
	END PROCESS;
	wire_nlO_w110w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_140q;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_94q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_10_84q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_93q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_92q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_91q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_90q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_89q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_6_88q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_7_87q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_8_86q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_9_85q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
			IF (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_46_dataout = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_94q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(0);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_10_84q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(10);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_93q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(1);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_92q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(2);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_91q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(3);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_90q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(4);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_89q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(5);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_6_88q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(6);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_7_87q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(7);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_8_86q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(8);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_9_85q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o(9);
			END IF;
		END IF;
	END PROCESS;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_127m_dataout <= wire_ni_w112w(0) AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_0_334_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_128m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_127m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE wire_ni_w112w(0);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_81m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_120q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_10_71m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(10) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_10_95q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_80m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_104q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_79m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_103q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_78m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_102q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_77m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_101q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_76m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_100q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_6_75m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_6_99q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_7_74m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(7) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_7_98q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_8_73m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(8) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_8_97q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_9_72m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o(9) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_44_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_9_96q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_108m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_121q OR s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_0_334_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_110m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_108m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_106_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_121q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_115m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_110m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_112_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_109m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_129q AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_106_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_114m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_109m_dataout OR s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_0_346_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_116m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_114m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_112_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_109m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_10_84q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_9_85q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_8_86q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_7_87q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_6_88q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_89q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_90q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_91q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_92q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_93q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_94q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 11,
		width_b => 11,
		width_o => 11
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_47_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_10_95q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_9_96q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_8_97q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_7_98q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_6_99q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_100q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_101q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_102q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_103q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_104q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_120q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 11,
		width_b => 11,
		width_o => 11
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_48_o
	  );

 END RTL; --sc_fifo
--synopsys translate_on
--VALID FILE
