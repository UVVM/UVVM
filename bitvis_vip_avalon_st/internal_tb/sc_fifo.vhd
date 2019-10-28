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

--synthesis_resources = altsyncram 1 lut 167 mux21 510 oper_add 10 oper_less_than 1 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  sc_fifo IS 
	 PORT 
	 ( 
		 clk	:	IN  STD_LOGIC;
		 csr_address	:	IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
		 csr_read	:	IN  STD_LOGIC;
		 csr_readdata	:	OUT  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 csr_write	:	IN  STD_LOGIC;
		 csr_writedata	:	IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 in_data	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 in_endofpacket	:	IN  STD_LOGIC;
		 in_ready	:	OUT  STD_LOGIC;
		 in_startofpacket	:	IN  STD_LOGIC;
		 in_valid	:	IN  STD_LOGIC;
		 out_data	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 out_endofpacket	:	OUT  STD_LOGIC;
		 out_ready	:	IN  STD_LOGIC;
		 out_startofpacket	:	OUT  STD_LOGIC;
		 out_valid	:	OUT  STD_LOGIC;
		 reset	:	IN  STD_LOGIC
	 ); 
 END sc_fifo;

 ARCHITECTURE RTL OF sc_fifo IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_address_a	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_address_b	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_data_a	:	STD_LOGIC_VECTOR (9 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b	:	STD_LOGIC_VECTOR (9 DOWNTO 0);
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_0_1001q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_1_1000q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_2_999q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_3_998q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_4_997q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_5_996q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_0_221q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_1_205q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_2_204q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_3_203q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_4_202q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_5_201q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_6_200q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_7_199q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_8_198q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_9_197q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_196q	:	STD_LOGIC := '0';
	 SIGNAL  wire_ni_w116w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_893q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_10_883q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_11_882q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_12_881q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_13_880q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_14_879q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_15_878q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_16_877q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_17_876q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_18_875q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_19_874q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_892q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_20_873q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_21_872q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_22_871q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_23_870q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_891q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_890q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_889q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_5_888q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_6_887q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_7_886q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_8_885q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_9_884q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_836q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_10_826q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_11_825q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_12_824q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_13_823q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_14_822q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_15_821q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_16_820q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_17_819q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_18_818q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_19_817q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_1_835q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_20_816q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_21_815q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_22_814q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_23_813q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_2_834q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_3_833q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_4_832q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_5_831q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_6_830q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_7_829q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_8_828q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_9_827q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_860q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_10_850q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_11_849q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_12_848q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_13_847q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_14_846q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_15_845q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_16_844q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_17_843q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_18_842q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_19_841q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_1_859q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_20_840q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_21_839q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_22_838q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_23_837q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_2_858q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_3_857q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_4_856q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_5_855q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_6_854q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_7_853q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_8_852q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_9_851q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_861q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_173q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_lt_cut_through_threshold_995q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_983q	:	STD_LOGIC := '0';
	 SIGNAL  wire_nl_w_lg_w118w119w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w118w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_0_267q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_1_227q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_2_226q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_3_225q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_4_224q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_5_223q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_6_222q	:	STD_LOGIC := '0';
	 SIGNAL  wire_nlO_w175w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w177w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w179w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w181w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w183w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w185w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w187w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_error_in_pkt_387q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_too_small_r_982q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_182q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_195q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_0_979q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_10_969q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_11_968q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_12_967q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_13_966q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_14_965q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_15_964q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_1_978q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_2_977q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_3_976q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_4_975q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_5_974q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_6_973q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_7_972q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_8_971q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_9_970q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_984q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_980q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_172q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_149q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_148q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_147q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_146q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_145q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_981q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q	:	STD_LOGIC := '0';
	 SIGNAL	sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q	:	STD_LOGIC := '0';
	 SIGNAL  wire_nO_w_lg_w_lg_w740w742w748w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w740w742w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w740w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w_lg_w_lg_w_lg_w_lg_w728w730w732w734w736w738w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w_lg_w_lg_w_lg_w728w730w732w734w736w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w_lg_w_lg_w728w730w732w734w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w_lg_w728w730w732w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w728w730w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w728w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w_lg_w_lg_w_lg_w_lg_w716w718w720w722w724w726w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w_lg_w_lg_w_lg_w716w718w720w722w724w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w_lg_w_lg_w716w718w720w722w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w_lg_w716w718w720w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w_lg_w716w718w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w579w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w42w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w745w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w725w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w723w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w721w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w719w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w717w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w716w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w743w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w741w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w739w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w737w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w735w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w733w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w731w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w729w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w727w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w359w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nO_w578w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_413m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_414m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_415m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_416m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_417m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_418m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_419m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_420m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_421m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_422m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_423m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_424m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_425m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_426m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_427m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_428m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_429m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_430m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_431m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_432m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_433m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_434m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_435m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_436m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_486m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_487m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_488m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_489m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_490m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_491m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_492m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_493m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_494m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_495m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_496m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_497m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_498m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_499m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_500m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_501m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_502m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_503m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_504m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_505m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_506m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_507m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_508m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_509m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_560m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_561m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_562m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_563m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_564m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_565m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_566m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_567m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_568m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_569m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_570m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_571m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_572m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_573m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_574m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_575m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_576m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_577m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_578m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_579m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_580m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_581m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_582m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_583m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_634m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_635m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_636m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_637m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_638m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_639m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_640m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_641m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_642m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_643m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_644m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_645m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_646m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_647m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_648m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_649m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_650m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_651m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_652m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_653m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_654m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_655m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_656m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_657m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_389m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_390m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_391m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_392m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_393m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_394m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_395m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_396m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_397m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_398m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_399m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_400m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_401m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_402m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_403m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_404m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_405m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_406m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_407m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_408m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_409m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_410m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_411m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_412m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_437m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_438m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_439m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_440m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_441m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_442m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_443m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_444m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_445m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_446m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_447m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_448m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_449m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_450m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_451m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_452m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_453m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_454m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_455m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_456m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_457m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_458m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_459m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_460m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_510m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_511m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_512m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_513m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_514m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_515m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_516m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_517m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_518m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_519m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_520m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_521m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_522m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_523m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_524m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_525m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_526m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_527m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_528m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_529m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_530m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_531m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_532m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_533m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_584m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_585m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_586m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_587m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_588m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_589m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_590m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_591m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_592m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_593m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_594m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_595m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_596m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_597m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_598m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_599m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_600m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_601m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_602m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_603m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_604m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_605m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_606m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_607m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_658m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_659m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_660m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_661m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_662m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_663m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_664m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_665m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_666m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_667m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_668m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_669m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_670m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_671m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_672m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_673m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_674m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_675m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_676m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_677m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_678m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_679m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_680m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_681m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_280m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_281m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_282m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_283m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_284m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_285m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_286m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_287m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_288m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_289m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_290m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_291m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_292m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_293m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_294m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_295m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_296m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_297m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_298m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_299m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_300m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_301m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_302m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_303m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_304m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_305m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_306m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_307m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_308m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_309m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_310m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_311m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_312m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_313m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_314m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_315m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_316m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_317m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_318m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_319m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_320m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_321m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_322m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_323m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_324m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_325m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_326m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_327m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_328m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_329m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_330m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_331m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_332m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_333m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_334m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_335m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_336m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_337m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_338m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_339m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_340m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_341m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_342m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_343m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_344m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_345m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_346m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_347m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_348m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_349m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_350m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_351m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_352m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_353m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_354m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_355m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_356m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_357m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_358m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_359m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_360m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_361m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_362m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_363m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_364m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_365m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_366m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_367m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_368m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_369m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_370m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_371m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_372m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_373m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_374m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_375m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_376m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_377m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_378m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_379m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_380m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_381m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_382m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_207m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_208m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_209m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_210m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_211m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_212m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_213m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_0_1017m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1_1016m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_2_1015m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_3_1014m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_4_1013m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_5_1012m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_461m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_462m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_463m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_464m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_465m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_466m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_467m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_468m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_469m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_470m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_471m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_472m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_473m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_474m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_475m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_476m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_477m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_478m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_479m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_480m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_481m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_482m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_483m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_484m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_535m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_536m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_537m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_538m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_539m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_540m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_541m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_542m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_543m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_544m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_545m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_546m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_547m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_548m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_549m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_550m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_551m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_552m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_553m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_554m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_555m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_556m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_557m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_558m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_609m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_610m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_611m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_612m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_613m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_614m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_615m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_616m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_617m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_618m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_619m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_620m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_621m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_622m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_623m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_624m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_625m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_626m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_627m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_628m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_629m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_630m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_631m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_632m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_534m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_608m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_error_in_pkt_994m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_237m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_238m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_239m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_240m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_241m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_242m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_243m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_246m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_247m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_248m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_249m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_250m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_251m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_252m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_253m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_254m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_255m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_256m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_257m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_258m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_259m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_260m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_261m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_262m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_263m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_264m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_265m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_266m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_too_small_908m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_180m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_181m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_136m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_135m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_134m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_133m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_132m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_131m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_153m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_155m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_159m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_160m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_165m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_170m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_171m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_154m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_164m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_166m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_0_130m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_119m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_120m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_121m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_122m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_123m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_124m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_1_129m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_2_128m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_3_127m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_4_126m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_5_125m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_ok_to_forward_901m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_925m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_926m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_927m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_928m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_929m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_930m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_931m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_932m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_933m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_934m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_935m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_936m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_937m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_938m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_939m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_940m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_943m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_944m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_945m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_946m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_947m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_948m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_949m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_950m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_951m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_952m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_953m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_954m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_955m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_956m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_957m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_958m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_942m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_960m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_941m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_959m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_961m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_962m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_485m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_559m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_633m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_912m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_913m_dataout	:	STD_LOGIC;
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_a	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_b	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_gnd	:	STD_LOGIC;
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_a	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_b	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_a	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_b	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_a	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_b	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_a	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_b	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_a	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_b	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_a	:	STD_LOGIC_VECTOR (16 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_b	:	STD_LOGIC_VECTOR (16 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o	:	STD_LOGIC_VECTOR (16 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_a	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_b	:	STD_LOGIC_VECTOR (23 DOWNTO 0);
	 SIGNAL  wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_o	:	STD_LOGIC;
	 SIGNAL  wire_w580w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w433w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_csr_address_range654w657w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_csr_read353w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_reset107w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w582w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w112w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w485w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w432w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w110w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w358w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w357w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w108w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_csr_address_range655w656w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  s_wire_gnd :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_0_1152_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1011_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1007_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_eop_arrive_903_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_start_1010_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_ready_176_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_179_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_0_1138_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_1_1145_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_2_1159_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_ok_to_forward_902_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_906_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_907_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_0_1406_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_1_1472_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_0_1439_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_0_1365_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_pkt_896_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_threshold_894_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_vcc :	STD_LOGIC;
	 SIGNAL  wire_w_csr_address_range654w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_csr_address_range655w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
 BEGIN

	wire_gnd <= '0';
	wire_w580w(0) <= s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_eop_arrive_903_dataout AND wire_nO_w579w(0);
	wire_w433w(0) <= s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_eop_arrive_903_dataout AND wire_w432w(0);
	wire_w_lg_w_csr_address_range654w657w(0) <= wire_w_csr_address_range654w(0) AND wire_w_lg_w_csr_address_range655w656w(0);
	wire_w_lg_csr_read353w(0) <= NOT csr_read;
	wire_w_lg_reset107w(0) <= NOT reset;
	wire_w582w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1007_dataout;
	wire_w112w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout;
	wire_w485w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_eop_arrive_903_dataout;
	wire_w432w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_907_dataout;
	wire_w110w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout;
	wire_w358w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_pkt_896_dataout;
	wire_w357w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_threshold_894_dataout;
	wire_w108w(0) <= NOT s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout;
	wire_w_lg_w_csr_address_range655w656w(0) <= NOT wire_w_csr_address_range655w(0);
	csr_readdata <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_23_870q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_22_871q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_21_872q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_20_873q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_19_874q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_18_875q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_17_876q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_16_877q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_15_878q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_14_879q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_13_880q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_12_881q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_11_882q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_10_883q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_9_884q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_8_885q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_7_886q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_6_887q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_5_888q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_889q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_890q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_891q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_892q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_893q);
	in_ready <= wire_nO_w42w(0);
	out_data <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_7_199q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_6_200q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_5_201q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_4_202q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_3_203q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_2_204q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_1_205q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_0_221q);
	out_endofpacket <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_8_198q;
	out_startofpacket <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_9_197q;
	out_valid <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_196q;
	s_wire_gnd <= '0';
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout <= ((csr_address(0) AND csr_address(1)) AND (NOT csr_address(2)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout <= (((NOT csr_address(0)) AND csr_address(1)) AND (NOT csr_address(2)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout <= (wire_w433w(0) AND wire_w112w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout <= (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_907_dataout AND (wire_w485w(0) OR s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_0_1152_dataout <= ((((((NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(0) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_172q)) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(1) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_149q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(2) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_148q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(3) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_147q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(4) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_146q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(5) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_145q)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout <= (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout AND wire_w108w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout <= (wire_w110w(0) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout <= (wire_w_lg_w_csr_address_range654w657w(0) AND csr_address(2));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout <= (((NOT csr_address(0)) AND wire_w_lg_w_csr_address_range655w656w(0)) AND csr_address(2));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout <= ((csr_address(0) AND csr_address(1)) AND (NOT csr_address(2)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout <= (((NOT csr_address(0)) AND csr_address(1)) AND (NOT csr_address(2)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout <= (((NOT csr_address(0)) AND wire_w_lg_w_csr_address_range655w656w(0)) AND (NOT csr_address(2)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1011_dataout <= (in_endofpacket AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_start_1010_dataout);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout <= (((NOT csr_address(0)) AND wire_w_lg_w_csr_address_range655w656w(0)) AND csr_address(2));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1007_dataout <= ((sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_9_197q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_906_dataout) AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_983q);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout <= ((wire_nO_w578w(0) AND wire_w580w(0)) AND wire_w582w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout <= (wire_w_lg_w_csr_address_range654w657w(0) AND csr_address(2));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_eop_arrive_903_dataout <= (in_endofpacket AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_start_1010_dataout <= (in_startofpacket AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_ready_176_dataout <= (out_ready OR wire_ni_w116w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_179_dataout <= (wire_nl_w_lg_w118w119w(0) AND wire_w112w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_0_1138_dataout <= ((((((NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(0) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q)) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(1) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(2) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(3) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(4) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(5) XOR sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_1_1145_dataout <= ((((((NOT (sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_172q XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_0_1017m_dataout)) AND (NOT (sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_149q XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1_1016m_dataout))) AND (NOT (sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_148q XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_2_1015m_dataout))) AND (NOT (sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_147q XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_3_1014m_dataout))) AND (NOT (sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_146q XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_4_1013m_dataout))) AND (NOT (sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_145q XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_5_1012m_dataout)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_2_1159_dataout <= ((((((NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_136m_dataout XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_0_1017m_dataout)) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_135m_dataout XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1_1016m_dataout))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_134m_dataout XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_2_1015m_dataout))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_133m_dataout XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_3_1014m_dataout))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_132m_dataout XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_4_1013m_dataout))) AND (NOT (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_131m_dataout XOR wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_5_1012m_dataout)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_ok_to_forward_902_dataout <= (wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_ok_to_forward_901m_dataout OR sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_too_small_r_982q);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_906_dataout <= (out_ready AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_196q);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_907_dataout <= (sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_8_198q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_906_dataout);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_0_1406_dataout <= ((wire_nO_w_lg_w740w742w(0) AND wire_nO_w743w(0)) AND wire_nO_w745w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_1_1472_dataout <= (wire_nO_w_lg_w_lg_w740w742w748w(0) AND wire_nO_w745w(0));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_0_1439_dataout <= ((wire_nO_w_lg_w740w742w(0) AND wire_nO_w743w(0)) AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_0_979q);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_0_1365_dataout <= ((((((((((((((((((((((((NOT csr_writedata(0)) AND (NOT csr_writedata(1))) AND (NOT csr_writedata(2))) AND (NOT csr_writedata(3))) AND (NOT csr_writedata(4))) AND (NOT csr_writedata(5))) AND (NOT csr_writedata(6))) AND (NOT csr_writedata(7))) AND (NOT csr_writedata(8))) AND (NOT csr_writedata(9))) AND (NOT csr_writedata(10))) AND (NOT csr_writedata(11))) AND (NOT csr_writedata(12))) AND (NOT csr_writedata(13))) AND (NOT csr_writedata(14))) AND (NOT csr_writedata(15))) AND (NOT csr_writedata(16))) AND (NOT csr_writedata(17))) AND (NOT csr_writedata(18))) AND (NOT csr_writedata(19))) AND (NOT csr_writedata(20))) AND (NOT csr_writedata(21))) AND (NOT csr_writedata(22))) AND (NOT csr_writedata(23)));
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout <= ((s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_ready_176_dataout AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_195q) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_ok_to_forward_902_dataout);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_pkt_896_dataout <= ((s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_pkt_leave_907_dataout AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_984q) OR sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_983q);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_threshold_894_dataout <= (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_pkt_896_dataout AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_lt_cut_through_threshold_995q);
	s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout <= (in_valid AND wire_nO_w42w(0));
	s_wire_vcc <= '1';
	wire_w_csr_address_range654w(0) <= csr_address(0);
	wire_w_csr_address_range655w(0) <= csr_address(1);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_address_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_address_b <= ( wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_131m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_132m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_133m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_134m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_135m_dataout & wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_136m_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_data_a <= ( in_startofpacket & in_endofpacket & in_data(7 DOWNTO 0));
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546 :  altsyncram
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
		NUMWORDS_A => 64,
		NUMWORDS_B => 64,
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
		WIDTH_A => 10,
		WIDTH_B => 10,
		WIDTH_BYTEENA_A => 1,
		WIDTH_BYTEENA_B => 1,
		WIDTH_ECCSTATUS => 3,
		WIDTHAD_A => 6,
		WIDTHAD_B => 6,
		WRCONTROL_ACLR_A => "NONE",
		WRCONTROL_ACLR_B => "NONE",
		WRCONTROL_WRADDRESS_REG_B => "CLOCK1",
		lpm_hint => "WIDTH_BYTEENA=1"
	  )
	  PORT MAP ( 
		address_a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_address_a,
		address_b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_address_b,
		clock0 => clk,
		data_a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_data_a,
		q_b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b,
		wren_a => s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout
	  );
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_0_1001q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_1_1000q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_2_999q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_3_998q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_4_997q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_5_996q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
			IF (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_start_1010_dataout = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_0_1001q <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_1_1000q <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_2_999q <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_3_998q <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_4_997q <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_5_996q <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q;
			END IF;
		END IF;
	END PROCESS;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_0_221q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_1_205q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_2_204q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_3_203q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_4_202q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_5_201q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_6_200q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_7_199q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_8_198q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_9_197q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_196q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
			IF (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_ready_176_dataout = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_0_221q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(0);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_1_205q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(1);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_2_204q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(2);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_3_203q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(3);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_4_202q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(4);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_5_201q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(5);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_6_200q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(6);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_7_199q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(7);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_8_198q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(8);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_payload_9_197q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_altsyncram_mem_1546_q_b(9);
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_196q <= (sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_195q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_ok_to_forward_902_dataout);
			END IF;
		END IF;
	END PROCESS;
	wire_ni_w116w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_196q;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q <= '1';
		ELSIF (clk = '1' AND clk'event) THEN
			IF (csr_read = '0') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_633m_dataout;
			END IF;
		END IF;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_893q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_10_883q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_11_882q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_12_881q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_13_880q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_14_879q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_15_878q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_16_877q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_17_876q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_18_875q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_19_874q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_892q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_20_873q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_21_872q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_22_871q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_23_870q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_891q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_890q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_889q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_5_888q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_6_887q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_7_886q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_8_885q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_9_884q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
			IF (csr_read = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_893q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_382m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_10_883q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_372m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_11_882q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_371m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_12_881q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_370m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_13_880q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_369m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_14_879q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_368m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_15_878q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_367m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_16_877q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_366m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_17_876q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_365m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_18_875q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_364m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_19_874q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_363m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_892q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_381m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_20_873q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_362m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_21_872q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_361m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_22_871q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_360m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_23_870q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_359m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_891q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_380m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_890q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_379m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_889q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_378m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_5_888q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_377m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_6_887q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_376m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_7_886q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_375m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_8_885q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_374m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_9_884q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_373m_dataout;
			END IF;
		END IF;
	END PROCESS;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_836q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_10_826q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_11_825q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_12_824q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_13_823q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_14_822q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_15_821q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_16_820q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_17_819q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_18_818q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_19_817q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_1_835q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_20_816q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_21_815q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_22_814q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_23_813q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_2_834q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_3_833q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_4_832q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_5_831q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_6_830q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_7_829q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_8_828q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_9_827q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_860q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_10_850q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_11_849q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_12_848q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_13_847q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_14_846q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_15_845q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_16_844q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_17_843q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_18_842q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_19_841q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_1_859q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_20_840q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_21_839q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_22_838q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_23_837q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_2_858q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_3_857q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_4_856q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_5_855q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_6_854q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_7_853q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_8_852q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_9_851q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_861q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
			IF (csr_read = '0') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_836q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_657m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_10_826q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_647m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_11_825q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_646m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_12_824q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_645m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_13_823q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_644m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_14_822q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_643m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_15_821q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_642m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_16_820q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_641m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_17_819q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_640m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_18_818q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_639m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_19_817q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_638m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_1_835q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_656m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_20_816q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_637m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_21_815q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_636m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_22_814q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_635m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_23_813q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_634m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_2_834q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_655m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_3_833q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_654m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_4_832q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_653m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_5_831q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_652m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_6_830q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_651m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_7_829q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_650m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_8_828q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_649m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_9_827q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_648m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_860q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_632m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_10_850q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_622m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_11_849q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_621m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_12_848q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_620m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_13_847q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_619m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_14_846q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_618m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_15_845q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_617m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_16_844q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_616m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_17_843q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_615m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_18_842q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_614m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_19_841q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_613m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_1_859q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_631m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_20_840q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_612m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_21_839q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_611m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_22_838q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_610m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_23_837q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_609m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_2_858q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_630m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_3_857q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_629m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_4_856q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_628m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_5_855q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_627m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_6_854q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_626m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_7_853q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_625m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_8_852q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_624m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_9_851q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_623m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_861q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_608m_dataout;
			END IF;
		END IF;
	END PROCESS;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_173q <= '1';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_lt_cut_through_threshold_995q <= '1';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_983q <= '1';
		ELSIF (clk = '1' AND clk'event) THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_173q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_171m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_lt_cut_through_threshold_995q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_o;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_983q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_959m_dataout;
		END IF;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_173q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_lt_cut_through_threshold_995q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_983q <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_nl_w_lg_w118w119w(0) <= wire_nl_w118w(0) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_ok_to_forward_902_dataout;
	wire_nl_w118w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_173q;
	PROCESS (clk, reset, s_wire_vcc)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q <= s_wire_vcc;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q <= s_wire_vcc;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q <= s_wire_vcc;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q <= s_wire_vcc;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q <= s_wire_vcc;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q <= s_wire_vcc;
		ELSIF (clk = '1' AND clk'event) THEN
			IF (csr_read = '0') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_681m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_680m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_679m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_678m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_677m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_676m_dataout;
			END IF;
		END IF;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q <= '1' after 1 ps;
		end if;
	END PROCESS;
	PROCESS (clk, reset, s_wire_gnd)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q <= s_wire_gnd;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q <= s_wire_gnd;
		ELSIF (clk = '1' AND clk'event) THEN
			IF (csr_read = '0') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_671m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_670m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_669m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_668m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_667m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_666m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_665m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_664m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_663m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_662m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_661m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_660m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_659m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_658m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_675m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_674m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_673m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_672m_dataout;
			END IF;
		END IF;
	END PROCESS;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_0_267q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_1_227q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_2_226q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_3_225q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_4_224q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_5_223q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_6_222q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
			IF (s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_0_267q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_213m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_1_227q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_212m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_2_226q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_211m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_3_225q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_210m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_4_224q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_209m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_5_223q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_208m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_6_222q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_207m_dataout;
			END IF;
		END IF;
	END PROCESS;
	wire_nlO_w175w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_0_267q;
	wire_nlO_w177w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_1_227q;
	wire_nlO_w179w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_2_226q;
	wire_nlO_w181w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_3_225q;
	wire_nlO_w183w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_4_224q;
	wire_nlO_w185w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_5_223q;
	wire_nlO_w187w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_6_222q;
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_error_in_pkt_387q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_too_small_r_982q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_182q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_195q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_0_979q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_10_969q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_11_968q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_12_967q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_13_966q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_14_965q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_15_964q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_1_978q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_2_977q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_3_976q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_4_975q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_5_974q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_6_973q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_7_972q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_8_971q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_9_970q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_984q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_980q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_172q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_149q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_148q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_147q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_146q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_145q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_981q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q <= '0';
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q <= '0';
		ELSIF (clk = '1' AND clk'event) THEN
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_error_in_pkt_387q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_error_in_pkt_994m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_266m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_265m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_264m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_263m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_262m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_261m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_260m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_too_small_r_982q <= (out_ready AND (sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_182q AND wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_too_small_908m_dataout));
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_182q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_166m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_195q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_181m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_0_979q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_958m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_10_969q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_948m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_11_968q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_947m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_12_967q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_946m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_13_966q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_945m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_14_965q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_944m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_15_964q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_943m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_1_978q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_957m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_2_977q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_956m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_3_976q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_955m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_4_975q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_954m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_5_974q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_953m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_6_973q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_952m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_7_972q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_951m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_8_971q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_950m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_9_970q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_949m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_984q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_960m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_980q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_962m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_172q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_136m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_149q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_135m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_148q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_134m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_147q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_133m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_146q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_132m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_145q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_131m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_981q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_913m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_0_130m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_1_129m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_2_128m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_3_127m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_4_126m_dataout;
				sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_5_125m_dataout;
		END IF;
	END PROCESS;
	wire_nO_w_lg_w_lg_w740w742w748w(0) <= wire_nO_w_lg_w740w742w(0) AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_1_978q;
	wire_nO_w_lg_w740w742w(0) <= wire_nO_w740w(0) AND wire_nO_w741w(0);
	wire_nO_w740w(0) <= wire_nO_w_lg_w_lg_w_lg_w_lg_w_lg_w728w730w732w734w736w738w(0) AND wire_nO_w739w(0);
	wire_nO_w_lg_w_lg_w_lg_w_lg_w_lg_w728w730w732w734w736w738w(0) <= wire_nO_w_lg_w_lg_w_lg_w_lg_w728w730w732w734w736w(0) AND wire_nO_w737w(0);
	wire_nO_w_lg_w_lg_w_lg_w_lg_w728w730w732w734w736w(0) <= wire_nO_w_lg_w_lg_w_lg_w728w730w732w734w(0) AND wire_nO_w735w(0);
	wire_nO_w_lg_w_lg_w_lg_w728w730w732w734w(0) <= wire_nO_w_lg_w_lg_w728w730w732w(0) AND wire_nO_w733w(0);
	wire_nO_w_lg_w_lg_w728w730w732w(0) <= wire_nO_w_lg_w728w730w(0) AND wire_nO_w731w(0);
	wire_nO_w_lg_w728w730w(0) <= wire_nO_w728w(0) AND wire_nO_w729w(0);
	wire_nO_w728w(0) <= wire_nO_w_lg_w_lg_w_lg_w_lg_w_lg_w716w718w720w722w724w726w(0) AND wire_nO_w727w(0);
	wire_nO_w_lg_w_lg_w_lg_w_lg_w_lg_w716w718w720w722w724w726w(0) <= wire_nO_w_lg_w_lg_w_lg_w_lg_w716w718w720w722w724w(0) AND wire_nO_w725w(0);
	wire_nO_w_lg_w_lg_w_lg_w_lg_w716w718w720w722w724w(0) <= wire_nO_w_lg_w_lg_w_lg_w716w718w720w722w(0) AND wire_nO_w723w(0);
	wire_nO_w_lg_w_lg_w_lg_w716w718w720w722w(0) <= wire_nO_w_lg_w_lg_w716w718w720w(0) AND wire_nO_w721w(0);
	wire_nO_w_lg_w_lg_w716w718w720w(0) <= wire_nO_w_lg_w716w718w(0) AND wire_nO_w719w(0);
	wire_nO_w_lg_w716w718w(0) <= wire_nO_w716w(0) AND wire_nO_w717w(0);
	wire_nO_w579w(0) <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_error_in_pkt_387q AND sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_861q;
	wire_nO_w42w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_182q;
	wire_nO_w745w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_0_979q;
	wire_nO_w725w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_10_969q;
	wire_nO_w723w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_11_968q;
	wire_nO_w721w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_12_967q;
	wire_nO_w719w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_13_966q;
	wire_nO_w717w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_14_965q;
	wire_nO_w716w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_15_964q;
	wire_nO_w743w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_1_978q;
	wire_nO_w741w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_2_977q;
	wire_nO_w739w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_3_976q;
	wire_nO_w737w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_4_975q;
	wire_nO_w735w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_5_974q;
	wire_nO_w733w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_6_973q;
	wire_nO_w731w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_7_972q;
	wire_nO_w729w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_8_971q;
	wire_nO_w727w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_9_970q;
	wire_nO_w359w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_980q;
	wire_nO_w578w(0) <= NOT sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_981q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_413m_dataout <= csr_writedata(23) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_23_813q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_414m_dataout <= csr_writedata(22) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_22_814q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_415m_dataout <= csr_writedata(21) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_21_815q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_416m_dataout <= csr_writedata(20) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_20_816q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_417m_dataout <= csr_writedata(19) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_19_817q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_418m_dataout <= csr_writedata(18) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_18_818q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_419m_dataout <= csr_writedata(17) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_17_819q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_420m_dataout <= csr_writedata(16) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_16_820q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_421m_dataout <= csr_writedata(15) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_15_821q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_422m_dataout <= csr_writedata(14) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_14_822q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_423m_dataout <= csr_writedata(13) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_13_823q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_424m_dataout <= csr_writedata(12) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_12_824q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_425m_dataout <= csr_writedata(11) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_11_825q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_426m_dataout <= csr_writedata(10) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_10_826q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_427m_dataout <= csr_writedata(9) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_9_827q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_428m_dataout <= csr_writedata(8) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_8_828q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_429m_dataout <= csr_writedata(7) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_7_829q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_430m_dataout <= csr_writedata(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_6_830q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_431m_dataout <= csr_writedata(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_5_831q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_432m_dataout <= csr_writedata(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_4_832q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_433m_dataout <= csr_writedata(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_3_833q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_434m_dataout <= csr_writedata(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_2_834q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_435m_dataout <= csr_writedata(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_1_835q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_436m_dataout <= csr_writedata(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_836q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_486m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_23_813q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_413m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_487m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_22_814q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_414m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_488m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_21_815q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_415m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_489m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_20_816q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_416m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_490m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_19_817q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_417m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_491m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_18_818q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_418m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_492m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_17_819q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_419m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_493m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_16_820q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_420m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_494m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_15_821q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_421m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_495m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_14_822q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_422m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_496m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_13_823q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_423m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_497m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_12_824q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_424m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_498m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_11_825q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_425m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_499m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_10_826q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_426m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_500m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_9_827q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_427m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_501m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_8_828q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_428m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_502m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_7_829q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_429m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_503m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_6_830q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_430m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_504m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_5_831q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_431m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_505m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_4_832q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_432m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_506m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_3_833q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_433m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_507m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_2_834q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_434m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_508m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_1_835q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_435m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_509m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_836q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_436m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_560m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_23_813q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_486m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_561m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_22_814q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_487m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_562m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_21_815q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_488m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_563m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_20_816q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_489m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_564m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_19_817q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_490m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_565m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_18_818q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_491m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_566m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_17_819q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_492m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_567m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_16_820q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_493m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_568m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_15_821q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_494m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_569m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_14_822q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_495m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_570m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_13_823q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_496m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_571m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_12_824q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_497m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_572m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_11_825q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_498m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_573m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_10_826q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_499m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_574m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_9_827q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_500m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_575m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_8_828q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_501m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_576m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_7_829q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_502m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_577m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_6_830q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_503m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_578m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_5_831q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_504m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_579m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_4_832q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_505m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_580m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_3_833q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_506m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_581m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_2_834q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_507m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_582m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_1_835q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_508m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_583m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_836q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_509m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_634m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_560m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_23_813q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_635m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_561m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_22_814q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_636m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_562m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_21_815q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_637m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_563m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_20_816q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_638m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_564m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_19_817q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_639m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_565m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_18_818q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_640m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_566m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_17_819q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_641m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_567m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_16_820q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_642m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_568m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_15_821q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_643m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_569m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_14_822q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_644m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_570m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_13_823q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_645m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_571m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_12_824q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_646m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_572m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_11_825q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_647m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_573m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_10_826q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_648m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_574m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_9_827q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_649m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_575m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_8_828q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_650m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_576m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_7_829q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_651m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_577m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_6_830q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_652m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_578m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_5_831q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_653m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_579m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_4_832q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_654m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_580m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_3_833q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_655m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_581m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_2_834q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_656m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_582m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_1_835q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_657m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_583m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_836q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_389m_dataout <= csr_writedata(23) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_390m_dataout <= csr_writedata(22) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_391m_dataout <= csr_writedata(21) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_392m_dataout <= csr_writedata(20) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_393m_dataout <= csr_writedata(19) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_394m_dataout <= csr_writedata(18) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_395m_dataout <= csr_writedata(17) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_396m_dataout <= csr_writedata(16) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_397m_dataout <= csr_writedata(15) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_398m_dataout <= csr_writedata(14) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_399m_dataout <= csr_writedata(13) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_400m_dataout <= csr_writedata(12) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_401m_dataout <= csr_writedata(11) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_402m_dataout <= csr_writedata(10) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_403m_dataout <= csr_writedata(9) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_404m_dataout <= csr_writedata(8) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_405m_dataout <= csr_writedata(7) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_406m_dataout <= csr_writedata(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_407m_dataout <= csr_writedata(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_408m_dataout <= csr_writedata(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_409m_dataout <= csr_writedata(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_410m_dataout <= csr_writedata(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_411m_dataout <= csr_writedata(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_412m_dataout <= csr_writedata(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_1373_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_437m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_389m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_438m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_390m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_439m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_391m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_440m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_392m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_441m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_393m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_442m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_394m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_443m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_395m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_444m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_396m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_445m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_397m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_446m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_398m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_447m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_399m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_448m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_400m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_449m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_401m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_450m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_402m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_451m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_403m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_452m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_404m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_453m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_405m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_454m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_406m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_455m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_407m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_456m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_408m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_457m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_409m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_458m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_410m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_459m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_411m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_460m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_1369_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_412m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_510m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_437m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_511m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_438m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_512m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_439m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_513m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_440m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_514m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_441m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_515m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_442m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_516m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_443m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_517m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_444m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_518m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_445m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_519m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_446m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_520m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_447m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_521m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_448m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_522m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_449m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_523m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_450m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_524m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_451m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_525m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_452m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_526m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_453m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_527m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_454m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_528m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_455m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_529m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_456m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_530m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_457m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_531m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_458m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_532m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_459m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_533m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_460m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_584m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_510m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_585m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_511m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_586m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_512m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_587m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_513m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_588m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_514m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_589m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_515m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_590m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_516m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_591m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_517m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_592m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_518m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_593m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_519m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_594m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_520m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_595m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_521m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_596m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_522m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_597m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_523m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_598m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_524m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_599m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_525m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_600m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_526m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_601m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_527m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_602m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_528m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_603m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_529m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_604m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_530m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_605m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_531m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_606m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_532m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_607m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_533m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_658m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_584m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_659m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_585m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_660m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_586m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_661m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_587m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_662m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_588m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_663m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_589m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_664m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_590m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_665m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_591m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_666m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_592m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_667m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_593m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_668m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_594m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_669m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_595m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_670m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_596m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_671m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_597m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_672m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_598m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_673m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_599m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_674m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_600m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_675m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_601m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_676m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_602m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_677m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_603m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_678m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_604m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_679m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_605m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_680m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_606m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_681m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_607m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_280m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o(6) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_281m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o(5) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_282m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o(4) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_283m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o(3) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_284m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o(2) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_285m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o(1) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_286m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o(0) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_4_1324_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_287m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_23_789q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_288m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_22_790q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_289m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_21_791q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_290m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_20_792q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_291m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_19_793q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_292m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_18_794q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_293m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_17_795q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_294m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_16_796q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_295m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_15_797q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_296m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_14_798q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_297m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_13_799q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_298m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_12_800q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_299m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_11_801q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_300m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_10_802q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_301m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_9_803q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_302m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_8_804q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_303m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_7_805q AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_304m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_6_806q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_280m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_305m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_5_807q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_281m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_306m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_4_808q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_282m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_307m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_3_809q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_283m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_308m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_2_810q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_284m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_309m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_1_811q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_285m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_310m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_full_threshold_0_812q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_3_1291_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_286m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_311m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_23_813q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_287m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_312m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_22_814q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_288m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_313m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_21_815q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_289m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_314m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_20_816q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_290m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_315m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_19_817q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_291m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_316m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_18_818q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_292m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_317m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_17_819q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_293m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_318m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_16_820q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_294m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_319m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_15_821q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_295m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_320m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_14_822q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_296m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_321m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_13_823q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_297m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_322m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_12_824q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_298m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_323m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_11_825q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_299m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_324m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_10_826q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_300m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_325m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_9_827q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_301m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_326m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_8_828q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_302m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_327m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_7_829q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_303m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_328m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_6_830q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_304m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_329m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_5_831q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_305m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_330m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_4_832q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_306m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_331m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_3_833q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_307m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_332m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_2_834q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_308m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_333m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_1_835q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_309m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_334m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_almost_empty_threshold_0_836q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_2_1258_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_310m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_335m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_23_837q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_311m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_336m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_22_838q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_312m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_337m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_21_839q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_313m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_338m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_20_840q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_314m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_339m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_19_841q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_315m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_340m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_18_842q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_316m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_341m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_17_843q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_317m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_342m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_16_844q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_318m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_343m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_15_845q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_319m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_344m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_14_846q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_320m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_345m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_13_847q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_321m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_346m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_12_848q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_322m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_347m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_11_849q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_323m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_348m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_10_850q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_324m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_349m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_9_851q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_325m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_350m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_8_852q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_326m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_351m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_7_853q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_327m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_352m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_6_854q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_328m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_353m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_5_855q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_329m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_354m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_4_856q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_330m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_355m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_3_857q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_331m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_356m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_2_858q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_332m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_357m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_1_859q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_333m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_358m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_860q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_1_1225_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_334m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_359m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_335m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_360m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_336m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_361m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_337m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_362m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_338m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_363m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_339m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_364m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_340m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_365m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_341m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_366m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_342m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_367m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_343m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_368m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_344m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_369m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_345m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_370m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_346m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_371m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_347m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_372m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_348m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_373m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_349m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_374m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_350m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_375m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_351m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_376m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_352m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_377m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_353m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_378m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_354m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_379m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_355m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_380m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_356m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_381m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_357m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_382m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_861q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_0_1192_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_csr_readdata_358m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_207m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o(6) AND NOT(in_endofpacket);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_208m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o(5) AND NOT(in_endofpacket);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_209m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o(4) AND NOT(in_endofpacket);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_210m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o(3) AND NOT(in_endofpacket);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_211m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o(2) AND NOT(in_endofpacket);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_212m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o(1) AND NOT(in_endofpacket);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_packet_len_less_one_213m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o(0) AND NOT(in_endofpacket);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_0_1017m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1011_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_0_1001q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1_1016m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1011_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_1_1000q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_2_1015m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1011_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_2_999q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_3_1014m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1011_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_3_998q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_4_1013m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1011_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_4_997q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_5_1012m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1011_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_ptr_5_996q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_461m_dataout <= csr_writedata(23) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_23_837q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_462m_dataout <= csr_writedata(22) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_22_838q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_463m_dataout <= csr_writedata(21) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_21_839q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_464m_dataout <= csr_writedata(20) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_20_840q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_465m_dataout <= csr_writedata(19) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_19_841q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_466m_dataout <= csr_writedata(18) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_18_842q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_467m_dataout <= csr_writedata(17) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_17_843q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_468m_dataout <= csr_writedata(16) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_16_844q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_469m_dataout <= csr_writedata(15) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_15_845q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_470m_dataout <= csr_writedata(14) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_14_846q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_471m_dataout <= csr_writedata(13) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_13_847q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_472m_dataout <= csr_writedata(12) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_12_848q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_473m_dataout <= csr_writedata(11) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_11_849q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_474m_dataout <= csr_writedata(10) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_10_850q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_475m_dataout <= csr_writedata(9) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_9_851q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_476m_dataout <= csr_writedata(8) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_8_852q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_477m_dataout <= csr_writedata(7) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_7_853q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_478m_dataout <= csr_writedata(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_6_854q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_479m_dataout <= csr_writedata(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_5_855q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_480m_dataout <= csr_writedata(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_4_856q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_481m_dataout <= csr_writedata(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_3_857q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_482m_dataout <= csr_writedata(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_2_858q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_483m_dataout <= csr_writedata(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_1_859q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_484m_dataout <= csr_writedata(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_860q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_535m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_23_837q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_461m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_536m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_22_838q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_462m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_537m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_21_839q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_463m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_538m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_20_840q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_464m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_539m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_19_841q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_465m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_540m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_18_842q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_466m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_541m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_17_843q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_467m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_542m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_16_844q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_468m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_543m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_15_845q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_469m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_544m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_14_846q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_470m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_545m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_13_847q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_471m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_546m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_12_848q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_472m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_547m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_11_849q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_473m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_548m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_10_850q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_474m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_549m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_9_851q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_475m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_550m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_8_852q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_476m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_551m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_7_853q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_477m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_552m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_6_854q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_478m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_553m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_5_855q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_479m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_554m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_4_856q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_480m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_555m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_3_857q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_481m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_556m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_2_858q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_482m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_557m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_1_859q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_483m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_558m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_860q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_484m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_609m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_535m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_23_837q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_610m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_536m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_22_838q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_611m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_537m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_21_839q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_612m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_538m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_20_840q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_613m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_539m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_19_841q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_614m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_540m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_18_842q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_615m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_541m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_17_843q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_616m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_542m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_16_844q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_617m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_543m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_15_845q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_618m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_544m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_14_846q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_619m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_545m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_13_847q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_620m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_546m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_12_848q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_621m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_547m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_11_849q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_622m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_548m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_10_850q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_623m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_549m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_9_851q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_624m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_550m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_8_852q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_625m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_551m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_7_853q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_626m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_552m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_6_854q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_627m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_553m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_5_855q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_628m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_554m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_4_856q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_629m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_555m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_3_857q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_630m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_556m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_2_858q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_631m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_557m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_1_859q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_632m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_558m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_860q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_534m_dataout <= csr_writedata(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_861q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_608m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_534m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_861q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_error_in_pkt_994m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_error_in_pkt_387q AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_eop_arrive_903_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_237m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o(7) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o(7);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_238m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o(6);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_239m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o(5);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_240m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o(4);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_241m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o(3);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_242m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o(2);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_243m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o(1);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_246m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o(7) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_247m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_248m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_249m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_250m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_251m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_252m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_253m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_246m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_254m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_247m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_255m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_248m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_256m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_249m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_257m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_250m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_258m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_251m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_259m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_252m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_260m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_237m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_253m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_261m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_238m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_254m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_262m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_239m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_255m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_263m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_240m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_256m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_264m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_241m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_257m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_265m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_242m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_258m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_266m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_243m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_259m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_too_small_908m_dataout <= s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_pkt_896_dataout WHEN sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q = '1'  ELSE s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_wait_for_threshold_894_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_180m_dataout <= s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_179_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_0_1138_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_181m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_180m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_internal_out_valid_179_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_0_136m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_172q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_1_135m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_149q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_2_134m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_148q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_3_133m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_147q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_4_132m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_146q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_mem_rd_ptr_5_131m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_145q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_153m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_173q OR s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_0_1138_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_155m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_153m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_empty_173q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_159m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_155m_dataout OR s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_1_1145_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_160m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_159m_dataout AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_165m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_160m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_155m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_170m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_165m_dataout OR s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_2_1159_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_171m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_170m_dataout WHEN ((s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_read_115_dataout AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout) = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_empty_165m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_154m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_full_182q AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_151_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_164m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_154m_dataout OR (wire_w112w(0) AND s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_0_1152_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_166m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_164m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always2_157_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_full_154m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_0_130m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_0_1017m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_124m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_119m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_120m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_121m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_122m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_123m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_124m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_write_116_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_1_129m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_1_1016m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_123m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_2_128m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_2_1015m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_122m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_3_127m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_3_1014m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_121m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_4_126m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_4_1013m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_120m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_5_125m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_curr_sop_ptr_5_1012m_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1009_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_next_wr_ptr_119m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_ok_to_forward_901m_dataout <= (wire_w358w(0) OR wire_nO_w359w(0)) WHEN sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q = '1'  ELSE wire_w357w(0);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_925m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(16) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_15_964q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_926m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(15) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_14_965q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_927m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(14) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_13_966q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_928m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(13) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_12_967q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_929m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(12) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_11_968q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_930m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(11) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_10_969q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_931m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(10) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_9_970q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_932m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(9) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_8_971q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_933m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(8) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_7_972q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_934m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(7) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_6_973q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_935m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_5_974q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_936m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_4_975q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_937m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_3_976q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_938m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_2_977q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_939m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_1_978q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_940m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_0_979q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_943m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(15) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_925m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_944m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(14) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_926m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_945m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(13) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_927m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_946m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(12) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_928m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_947m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(11) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_929m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_948m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(10) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_930m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_949m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(9) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_931m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_950m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(8) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_932m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_951m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(7) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_933m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_952m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(6) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_934m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_953m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(5) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_935m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_954m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(4) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_936m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_955m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(3) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_937m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_956m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(2) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_938m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_957m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(1) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_939m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_958m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o(0) WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_940m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_942m_dataout <= s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_1_1472_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_984q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_960m_dataout <= s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_0_1406_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_one_942m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_941m_dataout <= s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_0_1439_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_921_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_983q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_959m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_eq_zero_941m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_always10_916_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_961m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_980q AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_eop_arrive_903_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_962m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_has_started_961m_dataout OR s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_start_1010_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_485m_dataout <= s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_0_1365_dataout WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_1332_dataout = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_559m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q WHEN s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_en_0_1328_dataout = '1'  ELSE wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_485m_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_633m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_559m_dataout WHEN csr_write = '1'  ELSE sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_mode_963q;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_912m_dataout <= sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_981q OR s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_drop_on_error_1007_dataout;
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_913m_dataout <= wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_sop_has_left_fifo_912m_dataout AND NOT(s_wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_in_pkt_eop_arrive_903_dataout);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_5_139q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_4_140q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_3_141q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_2_142q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_1_143q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_wr_ptr_0_144q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_b <= ( "0" & "0" & "0" & "0" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 6,
		width_b => 6,
		width_o => 6
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add0_117_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_5_145q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_4_146q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_3_147q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_2_148q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_1_149q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_rd_ptr_0_172q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_b <= ( "0" & "0" & "0" & "0" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 6,
		width_b => 6,
		width_o => 6
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add1_118_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_6_222q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_5_223q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_4_224q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_3_225q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_2_226q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_1_227q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_gen_blk16_curr_packet_len_less_one_0_267q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 7,
		width_b => 7,
		width_o => 7
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add2_206_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q & "1");
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_b <= ( wire_nlO_w187w & wire_nlO_w185w & wire_nlO_w183w & wire_nlO_w181w & wire_nlO_w179w & wire_nlO_w177w & wire_nlO_w175w & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8,
		width_o => 8
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_a <= ( wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add3_235_o(7 DOWNTO 1) & "1");
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_b <= ( "1" & "1" & "1" & "1" & "1" & "1" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8,
		width_o => 8
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add4_236_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 7,
		width_b => 7,
		width_o => 7
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add5_244_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q & "1");
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_b <= ( "1" & "1" & "1" & "1" & "1" & "1" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8,
		width_o => 8
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add6_245_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & sc_fifo_altera_avalon_sc_fifo_sc_fifo_out_valid_196q);
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 7,
		width_b => 7,
		width_o => 7
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add7_274_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_15_964q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_14_965q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_13_966q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_12_967q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_11_968q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_10_969q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_9_970q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_8_971q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_7_972q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_6_973q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_5_974q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_4_975q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_3_976q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_2_977q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_1_978q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_0_979q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 16,
		width_b => 16,
		width_o => 16
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add8_917_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_a <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_15_964q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_14_965q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_13_966q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_12_967q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_11_968q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_10_969q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_9_970q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_8_971q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_7_972q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_6_973q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_5_974q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_4_975q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_3_976q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_2_977q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_1_978q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_pkt_cnt_0_979q & "1");
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_b <= ( "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "0" & "1");
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 17,
		width_b => 17,
		width_o => 17
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_add9_922_o
	  );
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_a <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_6_268q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_5_269q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_4_270q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_3_271q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_2_272q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_1_273q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_fifo_fill_level_0_788q);
	wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_b <= ( sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_23_837q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_22_838q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_21_839q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_20_840q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_19_841q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_18_842q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_17_843q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_16_844q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_15_845q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_14_846q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_13_847q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_12_848q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_11_849q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_10_850q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_9_851q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_8_852q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_7_853q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_6_854q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_5_855q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_4_856q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_3_857q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_2_858q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_1_859q & sc_fifo_altera_avalon_sc_fifo_sc_fifo_cut_through_threshold_0_860q);
	sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911 :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 24,
		width_b => 24
	  )
	  PORT MAP ( 
		a => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_a,
		b => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_b,
		cin => wire_gnd,
		o => wire_sc_fifo_altera_avalon_sc_fifo_sc_fifo_lessthan0_911_o
	  );

 END RTL; --sc_fifo
--synopsys translate_on
--VALID FILE
