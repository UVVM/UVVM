-------------------------------------------------------------------------------
--
-- Fifo Generator - VHDL Behavioral Model Component Declaration
--
-------------------------------------------------------------------------------
-- (c) Copyright 1995 - 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Filename: fifo_generator_v9_3_comp.vhd
--
-- Description:
--  The behavioral model for the FIFO Generator core.
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE fifo_generator_v9_3_xst_comp IS

 COMPONENT fifo_generator_v9_3_xst
  GENERIC (
    -------------------------------------------------------------------------
    -- Generic Declarations
    -------------------------------------------------------------------------
    C_COMMON_CLOCK                          : integer := 0;
    C_COUNT_TYPE                            : integer := 0;
    C_DATA_COUNT_WIDTH                      : integer := 2;
    C_DEFAULT_VALUE                         : string  := "";
    C_DIN_WIDTH                             : integer := 8;
    C_DOUT_RST_VAL                          : string  := "";
    C_DOUT_WIDTH                            : integer := 8;
    C_ENABLE_RLOCS                          : integer := 0;
    C_FAMILY                                : string  := "";
    C_FULL_FLAGS_RST_VAL                    : integer := 1;
    C_HAS_ALMOST_EMPTY                      : integer := 0;
    C_HAS_ALMOST_FULL                       : integer := 0;
    C_HAS_BACKUP                            : integer := 0;
    C_HAS_DATA_COUNT                        : integer := 0;
    C_HAS_INT_CLK                           : integer := 0;
    C_HAS_MEMINIT_FILE                      : integer := 0;
    C_HAS_OVERFLOW                          : integer := 0;
    C_HAS_RD_DATA_COUNT                     : integer := 0;
    C_HAS_RD_RST                            : integer := 0;
    C_HAS_RST                               : integer := 1;
    C_HAS_SRST                              : integer := 0;
    C_HAS_UNDERFLOW                         : integer := 0;
    C_HAS_VALID                             : integer := 0;
    C_HAS_WR_ACK                            : integer := 0;
    C_HAS_WR_DATA_COUNT                     : integer := 0;
    C_HAS_WR_RST                            : integer := 0;
    C_IMPLEMENTATION_TYPE                   : integer := 0;
    C_INIT_WR_PNTR_VAL                      : integer := 0;
    C_MEMORY_TYPE                           : integer := 1;
    C_MIF_FILE_NAME                         : string  := "";
    C_OPTIMIZATION_MODE                     : integer := 0;
    C_OVERFLOW_LOW                          : integer := 0;
    C_PRELOAD_LATENCY                       : integer := 1;
    C_PRELOAD_REGS                          : integer := 0;
    C_PRIM_FIFO_TYPE                        : string  := "4kx4";
    C_PROG_EMPTY_THRESH_ASSERT_VAL          : integer := 0;
    C_PROG_EMPTY_THRESH_NEGATE_VAL          : integer := 0;
    C_PROG_EMPTY_TYPE                       : integer := 0;
    C_PROG_FULL_THRESH_ASSERT_VAL           : integer := 0;
    C_PROG_FULL_THRESH_NEGATE_VAL           : integer := 0;
    C_PROG_FULL_TYPE                        : integer := 0;
    C_RD_DATA_COUNT_WIDTH                   : integer := 2;
    C_RD_DEPTH                              : integer := 256;
    C_RD_FREQ                               : integer := 1;
    C_RD_PNTR_WIDTH                         : integer := 8;
    C_UNDERFLOW_LOW                         : integer := 0;
    C_USE_DOUT_RST                          : integer := 0;
    C_USE_ECC                               : integer := 0;
    C_USE_EMBEDDED_REG                      : integer := 0;
    C_USE_FIFO16_FLAGS                      : integer := 0;
    C_USE_FWFT_DATA_COUNT                   : integer := 0;
    C_VALID_LOW                             : integer := 0;
    C_WR_ACK_LOW                            : integer := 0;
    C_WR_DATA_COUNT_WIDTH                   : integer := 2;
    C_WR_DEPTH                              : integer := 256;
    C_WR_FREQ                               : integer := 1;
    C_WR_PNTR_WIDTH                         : integer := 8;
    C_WR_RESPONSE_LATENCY                   : integer := 1;
    C_MSGON_VAL                             : integer := 1;
    C_ENABLE_RST_SYNC                       : integer := 1;
    C_ERROR_INJECTION_TYPE                  : integer := 0;
    C_SYNCHRONIZER_STAGE                    : integer := 2;

    -- AXI Interface related parameters start here
    C_INTERFACE_TYPE                        : integer := 0; -- 0: Native Interface; 1: AXI Interface
    C_AXI_TYPE                              : integer := 0; -- 0: AXI Stream; 1: AXI Full; 2: AXI Lite
    C_HAS_AXI_WR_CHANNEL                    : integer := 0;
    C_HAS_AXI_RD_CHANNEL                    : integer := 0;
    C_HAS_SLAVE_CE                          : integer := 0;
    C_HAS_MASTER_CE                         : integer := 0;
    C_ADD_NGC_CONSTRAINT                    : integer := 0;
    C_USE_COMMON_OVERFLOW                   : integer := 0;
    C_USE_COMMON_UNDERFLOW                  : integer := 0;
    C_USE_DEFAULT_SETTINGS                  : integer := 0;

    -- AXI Full/Lite
    C_AXI_ID_WIDTH                          : integer := 0;
    C_AXI_ADDR_WIDTH                        : integer := 0;
    C_AXI_DATA_WIDTH                        : integer := 0;
    C_HAS_AXI_AWUSER                        : integer := 0;
    C_HAS_AXI_WUSER                         : integer := 0;
    C_HAS_AXI_BUSER                         : integer := 0;
    C_HAS_AXI_ARUSER                        : integer := 0;
    C_HAS_AXI_RUSER                         : integer := 0;
    C_AXI_ARUSER_WIDTH                      : integer := 0;
    C_AXI_AWUSER_WIDTH                      : integer := 0;
    C_AXI_WUSER_WIDTH                       : integer := 0;
    C_AXI_BUSER_WIDTH                       : integer := 0;
    C_AXI_RUSER_WIDTH                       : integer := 0;
                                       
    -- AXI Streaming
    C_HAS_AXIS_TDATA                        : integer := 0;
    C_HAS_AXIS_TID                          : integer := 0;
    C_HAS_AXIS_TDEST                        : integer := 0;
    C_HAS_AXIS_TUSER                        : integer := 0;
    C_HAS_AXIS_TREADY                       : integer := 0;
    C_HAS_AXIS_TLAST                        : integer := 0;
    C_HAS_AXIS_TSTRB                        : integer := 0;
    C_HAS_AXIS_TKEEP                        : integer := 0;
    C_AXIS_TDATA_WIDTH                      : integer := 1;
    C_AXIS_TID_WIDTH                        : integer := 1;
    C_AXIS_TDEST_WIDTH                      : integer := 1;
    C_AXIS_TUSER_WIDTH                      : integer := 1;
    C_AXIS_TSTRB_WIDTH                      : integer := 1;
    C_AXIS_TKEEP_WIDTH                      : integer := 1;

    -- AXI Channel Type
    -- WACH --> Write Address Channel
    -- WDCH --> Write Data Channel
    -- WRCH --> Write Response Channel
    -- RACH --> Read Address Channel
    -- RDCH --> Read Data Channel
    -- AXIS --> AXI Streaming
    C_WACH_TYPE                             : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logic
    C_WDCH_TYPE                             : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie
    C_WRCH_TYPE                             : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie
    C_RACH_TYPE                             : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie
    C_RDCH_TYPE                             : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie
    C_AXIS_TYPE                             : integer := 0; -- 0 = FIFO; 1 = Register Slice; 2 = Pass Through Logie

    -- AXI Implementation Type
    -- 1 = Common Clock Block RAM FIFO
    -- 2 = Common Clock Distributed RAM FIFO
    -- 11 = Independent Clock Block RAM FIFO
    -- 12 = Independent Clock Distributed RAM FIFO
    C_IMPLEMENTATION_TYPE_WACH              : integer := 0;
    C_IMPLEMENTATION_TYPE_WDCH              : integer := 0;
    C_IMPLEMENTATION_TYPE_WRCH              : integer := 0;
    C_IMPLEMENTATION_TYPE_RACH              : integer := 0;
    C_IMPLEMENTATION_TYPE_RDCH              : integer := 0;
    C_IMPLEMENTATION_TYPE_AXIS              : integer := 0;

    -- AXI FIFO Type
    -- 0 = Data FIFO
    -- 1 = Packet FIFO
    -- 2 = Low Latency Data FIFO
    C_APPLICATION_TYPE_WACH                 : integer := 0;
    C_APPLICATION_TYPE_WDCH                 : integer := 0;
    C_APPLICATION_TYPE_WRCH                 : integer := 0;
    C_APPLICATION_TYPE_RACH                 : integer := 0;
    C_APPLICATION_TYPE_RDCH                 : integer := 0;
    C_APPLICATION_TYPE_AXIS                 : integer := 0;

    -- Enable ECC
    -- 0 = ECC disabled
    -- 1 = ECC enabled
    C_USE_ECC_WACH                          : integer := 0;
    C_USE_ECC_WDCH                          : integer := 0;
    C_USE_ECC_WRCH                          : integer := 0;
    C_USE_ECC_RACH                          : integer := 0;
    C_USE_ECC_RDCH                          : integer := 0;
    C_USE_ECC_AXIS                          : integer := 0;

    -- ECC Error Injection Type
    -- 0 = No Error Injection
    -- 1 = Single Bit Error Injection
    -- 2 = Double Bit Error Injection
    -- 3 = Single Bit and Double Bit Error Injection
    C_ERROR_INJECTION_TYPE_WACH             : integer := 0;
    C_ERROR_INJECTION_TYPE_WDCH             : integer := 0;
    C_ERROR_INJECTION_TYPE_WRCH             : integer := 0;
    C_ERROR_INJECTION_TYPE_RACH             : integer := 0;
    C_ERROR_INJECTION_TYPE_RDCH             : integer := 0;
    C_ERROR_INJECTION_TYPE_AXIS             : integer := 0;

    -- Input Data Width
    -- Accumulation of all AXI input signal's width
    C_DIN_WIDTH_WACH                        : integer := 1;
    C_DIN_WIDTH_WDCH                        : integer := 1;
    C_DIN_WIDTH_WRCH                        : integer := 1;
    C_DIN_WIDTH_RACH                        : integer := 1;
    C_DIN_WIDTH_RDCH                        : integer := 1;
    C_DIN_WIDTH_AXIS                        : integer := 1;

    C_WR_DEPTH_WACH                         : integer := 16;
    C_WR_DEPTH_WDCH                         : integer := 16;
    C_WR_DEPTH_WRCH                         : integer := 16;
    C_WR_DEPTH_RACH                         : integer := 16;
    C_WR_DEPTH_RDCH                         : integer := 16;
    C_WR_DEPTH_AXIS                         : integer := 16;

    C_WR_PNTR_WIDTH_WACH                    : integer := 4;
    C_WR_PNTR_WIDTH_WDCH                    : integer := 4;
    C_WR_PNTR_WIDTH_WRCH                    : integer := 4;
    C_WR_PNTR_WIDTH_RACH                    : integer := 4;
    C_WR_PNTR_WIDTH_RDCH                    : integer := 4;
    C_WR_PNTR_WIDTH_AXIS                    : integer := 4;

    C_HAS_DATA_COUNTS_WACH                  : integer := 0;
    C_HAS_DATA_COUNTS_WDCH                  : integer := 0;
    C_HAS_DATA_COUNTS_WRCH                  : integer := 0;
    C_HAS_DATA_COUNTS_RACH                  : integer := 0;
    C_HAS_DATA_COUNTS_RDCH                  : integer := 0;
    C_HAS_DATA_COUNTS_AXIS                  : integer := 0;

    C_HAS_PROG_FLAGS_WACH                   : integer := 0;
    C_HAS_PROG_FLAGS_WDCH                   : integer := 0;
    C_HAS_PROG_FLAGS_WRCH                   : integer := 0;
    C_HAS_PROG_FLAGS_RACH                   : integer := 0;
    C_HAS_PROG_FLAGS_RDCH                   : integer := 0;
    C_HAS_PROG_FLAGS_AXIS                   : integer := 0;

    C_PROG_FULL_TYPE_WACH                   : integer := 0;
    C_PROG_FULL_TYPE_WDCH                   : integer := 0;
    C_PROG_FULL_TYPE_WRCH                   : integer := 0;
    C_PROG_FULL_TYPE_RACH                   : integer := 0;
    C_PROG_FULL_TYPE_RDCH                   : integer := 0;
    C_PROG_FULL_TYPE_AXIS                   : integer := 0;
    C_PROG_FULL_THRESH_ASSERT_VAL_WACH      : integer := 0;
    C_PROG_FULL_THRESH_ASSERT_VAL_WDCH      : integer := 0;
    C_PROG_FULL_THRESH_ASSERT_VAL_WRCH      : integer := 0;
    C_PROG_FULL_THRESH_ASSERT_VAL_RACH      : integer := 0;
    C_PROG_FULL_THRESH_ASSERT_VAL_RDCH      : integer := 0;
    C_PROG_FULL_THRESH_ASSERT_VAL_AXIS      : integer := 0;

    C_PROG_EMPTY_TYPE_WACH                  : integer := 0;
    C_PROG_EMPTY_TYPE_WDCH                  : integer := 0;
    C_PROG_EMPTY_TYPE_WRCH                  : integer := 0;
    C_PROG_EMPTY_TYPE_RACH                  : integer := 0;
    C_PROG_EMPTY_TYPE_RDCH                  : integer := 0;
    C_PROG_EMPTY_TYPE_AXIS                  : integer := 0;
    C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH     : integer := 0;
    C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH     : integer := 0;
    C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH     : integer := 0;
    C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH     : integer := 0;
    C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH     : integer := 0;
    C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS     : integer := 0;

    C_REG_SLICE_MODE_WACH                   : integer := 0;
    C_REG_SLICE_MODE_WDCH                   : integer := 0;
    C_REG_SLICE_MODE_WRCH                   : integer := 0;
    C_REG_SLICE_MODE_RACH                   : integer := 0;
    C_REG_SLICE_MODE_RDCH                   : integer := 0;
    C_REG_SLICE_MODE_AXIS                   : integer := 0

    );


  PORT(
    ------------------------------------------------------------------------------
    -- Input and Output Declarations
    ------------------------------------------------------------------------------

    -- Conventional FIFO Interface Signals
    BACKUP                         : IN  std_logic := '0';
    BACKUP_MARKER                  : IN  std_logic := '0';
    CLK                            : IN  std_logic := '0';
    RST                            : IN  std_logic := '0';
    SRST                           : IN  std_logic := '0';
    WR_CLK                         : IN  std_logic := '0';
    WR_RST                         : IN  std_logic := '0';
    RD_CLK                         : IN  std_logic := '0';
    RD_RST                         : IN  std_logic := '0';
    DIN                            : IN  std_logic_vector(C_DIN_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    WR_EN                          : IN  std_logic := '0';
    RD_EN                          : IN  std_logic := '0';

    -- Optional inputs
    PROG_EMPTY_THRESH              : IN  std_logic_vector(C_RD_PNTR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    PROG_EMPTY_THRESH_ASSERT       : IN  std_logic_vector(C_RD_PNTR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    PROG_EMPTY_THRESH_NEGATE       : IN  std_logic_vector(C_RD_PNTR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    PROG_FULL_THRESH               : IN  std_logic_vector(C_WR_PNTR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    PROG_FULL_THRESH_ASSERT        : IN  std_logic_vector(C_WR_PNTR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    PROG_FULL_THRESH_NEGATE        : IN  std_logic_vector(C_WR_PNTR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    INT_CLK                        : IN  std_logic := '0';
    INJECTDBITERR                  : IN  std_logic := '0';
    INJECTSBITERR                  : IN  std_logic := '0';

    DOUT                           : OUT std_logic_vector(C_DOUT_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    FULL                           : OUT std_logic := '0';
    ALMOST_FULL                    : OUT std_logic := '0';
    WR_ACK                         : OUT std_logic := '0';
    OVERFLOW                       : OUT std_logic := '0';
    EMPTY                          : OUT std_logic := '1';
    ALMOST_EMPTY                   : OUT std_logic := '1';
    VALID                          : OUT std_logic := '0';
    UNDERFLOW                      : OUT std_logic := '0';
    DATA_COUNT                     : OUT std_logic_vector(C_DATA_COUNT_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    RD_DATA_COUNT                  : OUT std_logic_vector(C_RD_DATA_COUNT_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    WR_DATA_COUNT                  : OUT std_logic_vector(C_WR_DATA_COUNT_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    PROG_FULL                      : OUT std_logic := '0';
    PROG_EMPTY                     : OUT std_logic := '1';
    SBITERR                        : OUT std_logic := '0';
    DBITERR                        : OUT std_logic := '0';

    -- AXI Global Signal
    M_ACLK                         : IN  std_logic := '0';
    S_ACLK                         : IN  std_logic := '0';
    S_ARESETN                      : IN  std_logic := '1'; -- Active low reset, default value set to 1
    M_ACLK_EN                      : IN  std_logic := '0';
    S_ACLK_EN                      : IN  std_logic := '0';

    -- AXI Full/Lite Slave Write Channel (write side)
    S_AXI_AWID                     : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWADDR                   : IN  std_logic_vector(C_AXI_ADDR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWLEN                    : IN  std_logic_vector(8-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWSIZE                   : IN  std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWBURST                  : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWLOCK                   : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWCACHE                  : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWPROT                   : IN  std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWQOS                    : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWREGION                 : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWUSER                   : IN  std_logic_vector(C_AXI_AWUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_AWVALID                  : IN  std_logic := '0';
    S_AXI_AWREADY                  : OUT std_logic := '0';
    S_AXI_WID                      : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0)     := (OTHERS => '0');
    S_AXI_WDATA                    : IN  std_logic_vector(C_AXI_DATA_WIDTH-1 DOWNTO 0)   := (OTHERS => '0');
    S_AXI_WSTRB                    : IN  std_logic_vector(C_AXI_DATA_WIDTH/8-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_WLAST                    : IN  std_logic := '0';
    S_AXI_WUSER                    : IN  std_logic_vector(C_AXI_WUSER_WIDTH-1 DOWNTO 0)  := (OTHERS => '0');
    S_AXI_WVALID                   : IN  std_logic := '0';
    S_AXI_WREADY                   : OUT std_logic := '0';
    S_AXI_BID                      : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0)     := (OTHERS => '0');
    S_AXI_BRESP                    : OUT std_logic_vector(2-1 DOWNTO 0)                  := (OTHERS => '0');
    S_AXI_BUSER                    : OUT std_logic_vector(C_AXI_BUSER_WIDTH-1 DOWNTO 0)  := (OTHERS => '0');
    S_AXI_BVALID                   : OUT std_logic := '0';
    S_AXI_BREADY                   : IN  std_logic := '0';

    -- AXI Full/Lite Master Write Channel (Read side)
    M_AXI_AWID                     : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0)   := (OTHERS => '0');
    M_AXI_AWADDR                   : OUT std_logic_vector(C_AXI_ADDR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWLEN                    : OUT std_logic_vector(8-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWSIZE                   : OUT std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWBURST                  : OUT std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWLOCK                   : OUT std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWCACHE                  : OUT std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWPROT                   : OUT std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWQOS                    : OUT std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWREGION                 : OUT std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWUSER                   : OUT std_logic_vector(C_AXI_AWUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_AWVALID                  : OUT std_logic := '0';
    M_AXI_AWREADY                  : IN  std_logic := '0';
    M_AXI_WID                      : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0)     := (OTHERS => '0');
    M_AXI_WDATA                    : OUT std_logic_vector(C_AXI_DATA_WIDTH-1 DOWNTO 0)   := (OTHERS => '0');
    M_AXI_WSTRB                    : OUT std_logic_vector(C_AXI_DATA_WIDTH/8-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_WLAST                    : OUT std_logic := '0';
    M_AXI_WUSER                    : OUT std_logic_vector(C_AXI_WUSER_WIDTH-1 DOWNTO 0)  := (OTHERS => '0');
    M_AXI_WVALID                   : OUT std_logic := '0';
    M_AXI_WREADY                   : IN  std_logic := '0';
    M_AXI_BID                      : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0)    := (OTHERS => '0');
    M_AXI_BRESP                    : IN  std_logic_vector(2-1 DOWNTO 0)                 := (OTHERS => '0');
    M_AXI_BUSER                    : IN  std_logic_vector(C_AXI_BUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_BVALID                   : IN  std_logic := '0';
    M_AXI_BREADY                   : OUT std_logic := '0';

    -- AXI Full/Lite Slave Read Channel (Write side)
    S_AXI_ARID                     : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0)   := (OTHERS => '0');
    S_AXI_ARADDR                   : IN  std_logic_vector(C_AXI_ADDR_WIDTH-1 DOWNTO 0) := (OTHERS => '0'); 
    S_AXI_ARLEN                    : IN  std_logic_vector(8-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARSIZE                   : IN  std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARBURST                  : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARLOCK                   : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARCACHE                  : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARPROT                   : IN  std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARQOS                    : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARREGION                 : IN  std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARUSER                   : IN  std_logic_vector(C_AXI_ARUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_ARVALID                  : IN  std_logic := '0';
    S_AXI_ARREADY                  : OUT std_logic := '0';
    S_AXI_RID                      : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0)   := (OTHERS => '0');       
    S_AXI_RDATA                    : OUT std_logic_vector(C_AXI_DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0'); 
    S_AXI_RRESP                    : OUT std_logic_vector(2-1 DOWNTO 0)                := (OTHERS => '0');
    S_AXI_RLAST                    : OUT std_logic := '0';
    S_AXI_RUSER                    : OUT std_logic_vector(C_AXI_RUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXI_RVALID                   : OUT std_logic := '0';
    S_AXI_RREADY                   : IN  std_logic := '0';

    -- AXI Full/Lite Master Read Channel (Read side)
    M_AXI_ARID                     : OUT std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0)   := (OTHERS => '0');        
    M_AXI_ARADDR                   : OUT std_logic_vector(C_AXI_ADDR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');  
    M_AXI_ARLEN                    : OUT std_logic_vector(8-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARSIZE                   : OUT std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARBURST                  : OUT std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARLOCK                   : OUT std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARCACHE                  : OUT std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARPROT                   : OUT std_logic_vector(3-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARQOS                    : OUT std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARREGION                 : OUT std_logic_vector(4-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARUSER                   : OUT std_logic_vector(C_AXI_ARUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_ARVALID                  : OUT std_logic := '0';
    M_AXI_ARREADY                  : IN  std_logic := '0';
    M_AXI_RID                      : IN  std_logic_vector(C_AXI_ID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');        
    M_AXI_RDATA                    : IN  std_logic_vector(C_AXI_DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');  
    M_AXI_RRESP                    : IN  std_logic_vector(2-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_RLAST                    : IN  std_logic := '0';
    M_AXI_RUSER                    : IN  std_logic_vector(C_AXI_RUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXI_RVALID                   : IN  std_logic := '0';
    M_AXI_RREADY                   : OUT std_logic := '0';

    -- AXI Streaming Slave Signals (Write side)
    S_AXIS_TVALID                  : IN  std_logic := '0';
    S_AXIS_TREADY                  : OUT std_logic := '0';
    S_AXIS_TDATA                   : IN  std_logic_vector(C_AXIS_TDATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXIS_TSTRB                   : IN  std_logic_vector(C_AXIS_TSTRB_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXIS_TKEEP                   : IN  std_logic_vector(C_AXIS_TKEEP_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXIS_TLAST                   : IN  std_logic := '0';
    S_AXIS_TID                     : IN  std_logic_vector(C_AXIS_TID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXIS_TDEST                   : IN  std_logic_vector(C_AXIS_TDEST_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    S_AXIS_TUSER                   : IN  std_logic_vector(C_AXIS_TUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');

    -- AXI Streaming Master Signals (Read side)
    M_AXIS_TVALID                  : OUT std_logic := '0';
    M_AXIS_TREADY                  : IN  std_logic := '0';
    M_AXIS_TDATA                   : OUT std_logic_vector(C_AXIS_TDATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXIS_TSTRB                   : OUT std_logic_vector(C_AXIS_TSTRB_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXIS_TKEEP                   : OUT std_logic_vector(C_AXIS_TKEEP_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXIS_TLAST                   : OUT std_logic := '0';
    M_AXIS_TID                     : OUT std_logic_vector(C_AXIS_TID_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXIS_TDEST                   : OUT std_logic_vector(C_AXIS_TDEST_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    M_AXIS_TUSER                   : OUT std_logic_vector(C_AXIS_TUSER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');

    -- AXI Full/Lite Write Address Channel Signals
    AXI_AW_INJECTSBITERR           : IN  std_logic := '0';
    AXI_AW_INJECTDBITERR           : IN  std_logic := '0';
    AXI_AW_PROG_FULL_THRESH        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WACH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_AW_PROG_EMPTY_THRESH       : IN  std_logic_vector(C_WR_PNTR_WIDTH_WACH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_AW_DATA_COUNT              : OUT std_logic_vector(C_WR_PNTR_WIDTH_WACH DOWNTO 0) := (OTHERS => '0');
    AXI_AW_WR_DATA_COUNT           : OUT std_logic_vector(C_WR_PNTR_WIDTH_WACH DOWNTO 0) := (OTHERS => '0');
    AXI_AW_RD_DATA_COUNT           : OUT std_logic_vector(C_WR_PNTR_WIDTH_WACH DOWNTO 0) := (OTHERS => '0');
    AXI_AW_SBITERR                 : OUT std_logic := '0';
    AXI_AW_DBITERR                 : OUT std_logic := '0';
    AXI_AW_OVERFLOW                : OUT std_logic := '0';
    AXI_AW_UNDERFLOW               : OUT std_logic := '0';
    AXI_AW_PROG_FULL               : OUT STD_LOGIC := '0';
    AXI_AW_PROG_EMPTY              : OUT STD_LOGIC := '1';

    -- AXI Full/Lite Write Data Channel Signals
    AXI_W_INJECTSBITERR            : IN  std_logic := '0';
    AXI_W_INJECTDBITERR            : IN  std_logic := '0';
    AXI_W_PROG_FULL_THRESH         : IN  std_logic_vector(C_WR_PNTR_WIDTH_WDCH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_W_PROG_EMPTY_THRESH        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WDCH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_W_DATA_COUNT               : OUT std_logic_vector(C_WR_PNTR_WIDTH_WDCH DOWNTO 0) := (OTHERS => '0');
    AXI_W_WR_DATA_COUNT            : OUT std_logic_vector(C_WR_PNTR_WIDTH_WDCH DOWNTO 0) := (OTHERS => '0');
    AXI_W_RD_DATA_COUNT            : OUT std_logic_vector(C_WR_PNTR_WIDTH_WDCH DOWNTO 0) := (OTHERS => '0');
    AXI_W_SBITERR                  : OUT std_logic := '0';
    AXI_W_DBITERR                  : OUT std_logic := '0';
    AXI_W_OVERFLOW                 : OUT std_logic := '0';
    AXI_W_UNDERFLOW                : OUT std_logic := '0';
    AXI_W_PROG_FULL                : OUT STD_LOGIC := '0';
    AXI_W_PROG_EMPTY               : OUT STD_LOGIC := '1';

    -- AXI Full/Lite Write Response Channel Signals
    AXI_B_INJECTSBITERR            : IN  std_logic := '0';
    AXI_B_INJECTDBITERR            : IN  std_logic := '0';
    AXI_B_PROG_FULL_THRESH         : IN  std_logic_vector(C_WR_PNTR_WIDTH_WRCH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_B_PROG_EMPTY_THRESH        : IN  std_logic_vector(C_WR_PNTR_WIDTH_WRCH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_B_DATA_COUNT               : OUT std_logic_vector(C_WR_PNTR_WIDTH_WRCH DOWNTO 0) := (OTHERS => '0');
    AXI_B_WR_DATA_COUNT            : OUT std_logic_vector(C_WR_PNTR_WIDTH_WRCH DOWNTO 0) := (OTHERS => '0');
    AXI_B_RD_DATA_COUNT            : OUT std_logic_vector(C_WR_PNTR_WIDTH_WRCH DOWNTO 0) := (OTHERS => '0');
    AXI_B_SBITERR                  : OUT std_logic := '0';
    AXI_B_DBITERR                  : OUT std_logic := '0';
    AXI_B_OVERFLOW                 : OUT std_logic := '0';
    AXI_B_UNDERFLOW                : OUT std_logic := '0';
    AXI_B_PROG_FULL                : OUT STD_LOGIC := '0';
    AXI_B_PROG_EMPTY               : OUT STD_LOGIC := '1';

    -- AXI Full/Lite Read Address Channel Signals
    AXI_AR_INJECTSBITERR           : IN  std_logic := '0';
    AXI_AR_INJECTDBITERR           : IN  std_logic := '0';
    AXI_AR_PROG_FULL_THRESH        : IN  std_logic_vector(C_WR_PNTR_WIDTH_RACH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_AR_PROG_EMPTY_THRESH       : IN  std_logic_vector(C_WR_PNTR_WIDTH_RACH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_AR_DATA_COUNT              : OUT std_logic_vector(C_WR_PNTR_WIDTH_RACH DOWNTO 0) := (OTHERS => '0');
    AXI_AR_WR_DATA_COUNT           : OUT std_logic_vector(C_WR_PNTR_WIDTH_RACH DOWNTO 0) := (OTHERS => '0');
    AXI_AR_RD_DATA_COUNT           : OUT std_logic_vector(C_WR_PNTR_WIDTH_RACH DOWNTO 0) := (OTHERS => '0');
    AXI_AR_SBITERR                 : OUT std_logic := '0';
    AXI_AR_DBITERR                 : OUT std_logic := '0';
    AXI_AR_OVERFLOW                : OUT std_logic := '0';
    AXI_AR_UNDERFLOW               : OUT std_logic := '0';
    AXI_AR_PROG_FULL               : OUT STD_LOGIC := '0';
    AXI_AR_PROG_EMPTY              : OUT STD_LOGIC := '1';

    -- AXI Full/Lite Read Data Channel Signals
    AXI_R_INJECTSBITERR            : IN  std_logic := '0';
    AXI_R_INJECTDBITERR            : IN  std_logic := '0';
    AXI_R_PROG_FULL_THRESH         : IN  std_logic_vector(C_WR_PNTR_WIDTH_RDCH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_R_PROG_EMPTY_THRESH        : IN  std_logic_vector(C_WR_PNTR_WIDTH_RDCH-1 DOWNTO 0) := (OTHERS => '0');
    AXI_R_DATA_COUNT               : OUT std_logic_vector(C_WR_PNTR_WIDTH_RDCH DOWNTO 0) := (OTHERS => '0');
    AXI_R_WR_DATA_COUNT            : OUT std_logic_vector(C_WR_PNTR_WIDTH_RDCH DOWNTO 0) := (OTHERS => '0');
    AXI_R_RD_DATA_COUNT            : OUT std_logic_vector(C_WR_PNTR_WIDTH_RDCH DOWNTO 0) := (OTHERS => '0');
    AXI_R_SBITERR                  : OUT std_logic := '0';
    AXI_R_DBITERR                  : OUT std_logic := '0';
    AXI_R_OVERFLOW                 : OUT std_logic := '0';
    AXI_R_UNDERFLOW                : OUT std_logic := '0';
    AXI_R_PROG_FULL                : OUT STD_LOGIC := '0';
    AXI_R_PROG_EMPTY               : OUT STD_LOGIC := '1';

    -- AXI Streaming FIFO Related Signals
    AXIS_INJECTSBITERR             : IN  std_logic := '0';
    AXIS_INJECTDBITERR             : IN  std_logic := '0';
    AXIS_PROG_FULL_THRESH          : IN  std_logic_vector(C_WR_PNTR_WIDTH_AXIS-1 DOWNTO 0) := (OTHERS => '0');
    AXIS_PROG_EMPTY_THRESH         : IN  std_logic_vector(C_WR_PNTR_WIDTH_AXIS-1 DOWNTO 0) := (OTHERS => '0');
    AXIS_DATA_COUNT                : OUT std_logic_vector(C_WR_PNTR_WIDTH_AXIS DOWNTO 0) := (OTHERS => '0');
    AXIS_WR_DATA_COUNT             : OUT std_logic_vector(C_WR_PNTR_WIDTH_AXIS DOWNTO 0) := (OTHERS => '0');
    AXIS_RD_DATA_COUNT             : OUT std_logic_vector(C_WR_PNTR_WIDTH_AXIS DOWNTO 0) := (OTHERS => '0');
    AXIS_SBITERR                   : OUT std_logic := '0';
    AXIS_DBITERR                   : OUT std_logic := '0';
    AXIS_OVERFLOW                  : OUT std_logic := '0';
    AXIS_UNDERFLOW                 : OUT std_logic := '0';
    AXIS_PROG_FULL                 : OUT STD_LOGIC := '0';
    AXIS_PROG_EMPTY                : OUT STD_LOGIC := '1'

    );
 END COMPONENT;

END fifo_generator_v9_3_xst_comp;
