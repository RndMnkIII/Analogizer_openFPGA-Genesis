//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1 

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable, 

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,
 
///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus 

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,
    
output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
// 
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [15:0]  cont1_key,
input   wire    [15:0]  cont2_key,
input   wire    [15:0]  cont3_key,
input   wire    [15:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig
    
);

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
// assign cart_tran_bank3 = 8'hzz;
// assign cart_tran_bank3_dir = 1'b0;
// assign cart_tran_bank2 = 8'hzz;
// assign cart_tran_bank2_dir = 1'b0;
// assign cart_tran_bank1 = 8'hzz;
// assign cart_tran_bank1_dir = 1'b0;
// assign cart_tran_bank0 = 4'hf;
// assign cart_tran_bank0_dir = 1'b1;
// assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
// assign cart_tran_pin30_dir = 1'bz;
// assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
// assign cart_tran_pin31 = 1'bz;      // input
// assign cart_tran_pin31_dir = 1'b0;  // input

// link port is input only
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign sram_a = 'h0;
assign sram_dq = {16{1'bZ}};
assign sram_oe_n  = 1;
assign sram_we_n  = 1;
assign sram_ub_n  = 1;
assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;


// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
    default: begin
        bridge_rd_data <= 0;
    end
	32'h00E00000: begin
        bridge_rd_data <= region_req;
    end
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    32'hF7000000: begin 
        bridge_rd_data <= {18'h0,analogizer_settings};
      end
    endcase

	if (bridge_addr[31:28] == 4'h6) begin
      bridge_rd_data <= sd_read_data;
    end
end


//
// host/target command handler
//
    wire            reset_n;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;
    
// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked; 
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_allcomplete;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;
    
    wire            osnotify_inmenu;

// bridge target commands
// synchronous to clk_74a


// bridge data slot access

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),
    
    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),
    
    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q )

);

////////////////////////////////////////////////////////////////////////////////////////
// Core Settings
///////////////////////////////////////////////

// System
reg [11:0] reset_counter 		 = 0;
reg [15:0] reset_delay			 = 0;
reg [1:0] cs_cpu_turbo			 = 0;
reg cs_multitap_enable			 = 0;
reg cs_menu_pause_enable		 = 0;

// Video 
reg cs_obj_limit_high_enable  	 = 1;
reg cs_ar_correction_enable   	 = 0;
reg cs_composite_enable       	 = 0;
reg cs_auto_composite_enable  	 = 0;

// Audio
reg cs_fm_enable 			     = 1;
reg cs_psg_enable             	 = 1;
reg cs_hifi_pcm_enable	         = 1;
reg [1:0] cs_audio_filter	 	 = 0;
reg cs_fm_chip	 		 		 = 0;

// Input
reg cs_m30_map_enable            = 0;
reg lightgun_enabled             = 0;
reg show_crosshair               = 1;
reg [7:0] dpad_aim_speed         = 4;

always @(posedge clk_74a) begin
    reset_counter = reset_counter + 1;
    if (~osnotify_inmenu && reset_delay > 0) begin
      reset_delay <= reset_delay - 1;
    end

	if (bridge_wr) begin
      casex (bridge_addr)
        32'h00F00000: cs_audio_filter			<= bridge_wr_data[1:0];
        32'h00A00000: cs_fm_chip                <= bridge_wr_data[0];
        32'h00C00000: cs_cpu_turbo				<= bridge_wr_data[1:0];
        32'h00000000: cs_multitap_enable 	    <= bridge_wr_data[0];
        32'h00000010: cs_ar_correction_enable 	<= bridge_wr_data[0];
        32'h00000020: begin
          cs_composite_enable <= bridge_wr_data[0];
          cs_auto_composite_enable <= bridge_wr_data[1];
        end
        32'h00000030: cs_obj_limit_high_enable	<= bridge_wr_data[0];
        // 32'h00000040: cs_fm_enable 				<= bridge_wr_data[0];
        // 32'h00000050: cs_psg_enable 			<= bridge_wr_data[0];
        // 32'h00000060: cs_hifi_pcm_enable 		<= bridge_wr_data[0];
        32'h00000070: begin
            if (bridge_wr_data[31:0] > 0) reset_delay <= {reset_counter, 4'b1111};
          end
		32'h00000080: cs_m30_map_enable         <= bridge_wr_data[0];
		32'h00000090: cs_menu_pause_enable      <= bridge_wr_data[0];
        32'h00000100: lightgun_enabled          <= bridge_wr_data[0];
        32'h00000104: show_crosshair            <= bridge_wr_data[0];
        32'h00000108: dpad_aim_speed            <= bridge_wr_data[7:0];
        /*[ANALOGIZER_HOOK_START]*/
		32'hF7000000: analogizer_settings       <=  bridge_wr_data[13:0];
	    /*[ANALOGIZER_HOOK_END]*/
      endcase
    end
end

///////////////////////////////////////////////
// Save/Load
///////////////////////////////////////////////

wire [31:0] sd_read_data;

wire sd_rd;
wire sd_wr;

wire [16:0] sd_buff_addr_in;
wire [16:0] sd_buff_addr_out;

// Lowest bit is for byte addressing
wire [15:0] sd_buff_addr = sd_wr ? sd_buff_addr_in[16:1] : sd_buff_addr_out[16:1];

wire [15:0] sd_buff_din;
wire [15:0] sd_buff_dout;

reg [ 2:0] datatable_div = 0;
reg [31:0] rom_file_size = 0;

always @(posedge clk_74a or negedge pll_core_locked) begin
	if (~pll_core_locked) begin
		datatable_addr <= 0;
		datatable_data <= 0;
		datatable_wren <= 0;
	end else begin
		if (datatable_div > 4) begin
			// Write sram size half of the time
			datatable_wren <= 1;
			// sram_size is the size of the config value in the ROM. Convert to actual size
			datatable_data <= 32'd65536;
			// Data slot index 1, not id 1
			datatable_addr <= 1 * 2 + 1;
		end else begin
			datatable_wren <= 0;
			// Read ROM size rest of the time
			datatable_addr <= 1;

			if (datatable_div == 4) begin
				rom_file_size <= datatable_q;
			end
		end

		datatable_div <= datatable_div + 1;
	end
end

data_unloader #(
	.ADDRESS_MASK_UPPER_4(4'h6),
	.ADDRESS_SIZE(17),
	.READ_MEM_CLOCK_DELAY(7),
	.INPUT_WORD_SIZE(2)
) save_data_unloader (
	.clk_74a(clk_74a),
	.clk_memory(clk_sys),

	.bridge_rd(bridge_rd),
	.bridge_endian_little(bridge_endian_little),
	.bridge_addr(bridge_addr),
	.bridge_rd_data(sd_read_data),

	.read_en  (sd_rd),
	.read_addr(sd_buff_addr_out),
	.read_data(sd_buff_din)
);

data_loader #(
      .ADDRESS_MASK_UPPER_4(4'h6),
      .ADDRESS_SIZE(17),
      .WRITE_MEM_CLOCK_DELAY(7),
      .OUTPUT_WORD_SIZE(2)
) save_data_loader (
      .clk_74a(clk_74a),
      .clk_memory(clk_sys),

      .bridge_wr(bridge_wr),
      .bridge_endian_little(bridge_endian_little),
      .bridge_addr(bridge_addr),
      .bridge_wr_data(bridge_wr_data),

      .write_en  (sd_wr),
      .write_addr(sd_buff_addr_in),
      .write_data(sd_buff_dout)
);

///////////////////////////////////////////////
// ROM
///////////////////////////////////////////////

reg         ioctl_download = 0;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_data;
reg         ioctl_wait;

wire 		cart_download;

synch_3 cart_download_s (
	ioctl_download & bridge_addr[31:28] == 4'h1,
	cart_download,
	clk_sys
);

always @(posedge clk_74a) begin
    if (dataslot_requestwrite) ioctl_download <= 1;
    else if (dataslot_allcomplete) ioctl_download <= 0;
end

wire sdrom_wrack;
reg  [1:0] region_req;
reg        region_set = 0;
always @(posedge clk_sys) begin
	reg old_ready = 0;

	old_ready <= cart_hdr_ready;
	if(~old_ready & cart_hdr_ready) begin
			region_set <= 1;
			if(hdr_u) region_req <= 1;
			else if(hdr_e) region_req <= 2;
			else if(hdr_j) region_req <= 0;
			else region_req <= 1;
	end

	if(old_ready & ~cart_hdr_ready) region_set <= 0;
end

wire [3:0] hrgn = ioctl_data[3:0] - 4'd7;

reg cart_hdr_ready = 0;
reg hdr_j=0,hdr_u=0,hdr_e=0;
always @(posedge clk_sys) begin
	reg old_download;
	old_download <= cart_download;

	if(~old_download && cart_download) {hdr_j,hdr_u,hdr_e} <= 0;
	if(old_download && ~cart_download) cart_hdr_ready <= 0;

	if(ioctl_wr & cart_download) begin
		if(ioctl_addr == 'h1F0) begin
			if(ioctl_data[7:0] == "J") hdr_j <= 1;
			else if(ioctl_data[7:0] == "U") hdr_u <= 1;
			else if(ioctl_data[7:0] == "E") hdr_e <= 1;
			else if(ioctl_data[7:0] >= "0" && ioctl_data[7:0] <= "9") {hdr_e, hdr_u, hdr_j} <= {ioctl_data[3], ioctl_data[2], ioctl_data[0]};
			else if(ioctl_data[7:0] >= "A" && ioctl_data[7:0] <= "F") {hdr_e, hdr_u, hdr_j} <= {      hrgn[3],       hrgn[2],       hrgn[0]};
		end
		if(ioctl_addr == 'h1F2) begin
			if(ioctl_data[7:0] == "J") hdr_j <= 1;
			else if(ioctl_data[7:0] == "U") hdr_u <= 1;
			else if(ioctl_data[7:0] == "E") hdr_e <= 1;
		end
		if(ioctl_addr == 'h1F0) begin
			if(ioctl_data[15:8] == "J") hdr_j <= 1;
			else if(ioctl_data[15:8] == "U") hdr_u <= 1;
			else if(ioctl_data[15:8] == "E") hdr_e <= 1;
		end
		if(ioctl_addr == 'h200) cart_hdr_ready <= 1;
	end
end

data_loader #(
	.ADDRESS_MASK_UPPER_4(4'h1),
    .ADDRESS_SIZE(25),
	.WRITE_MEM_CLOCK_DELAY(12),
	.WRITE_MEM_EN_CYCLE_LENGTH(2),
	.OUTPUT_WORD_SIZE(2)
) rom_loader (
    .clk_74a(clk_74a),
    .clk_memory(clk_sys),

    .bridge_wr(bridge_wr),
    .bridge_endian_little(bridge_endian_little),
    .bridge_addr(bridge_addr),
    .bridge_wr_data(bridge_wr_data),

    .write_en(ioctl_wr),
    .write_addr(ioctl_addr),
    .write_data(ioctl_data)
);

///////////////////////////////////////////////
// Audio
///////////////////////////////////////////////

wire [15:0] AUDIO_L, AUDIO_R;

sound_i2s #(
    .CHANNEL_WIDTH(16),
    .SIGNED_INPUT (1)
) sound_i2s (
    .clk_74a(clk_74a),
    .clk_audio(clk_sys),
    
    .audio_l(AUDIO_L),
    .audio_r(AUDIO_R),

    .audio_mclk(audio_mclk),
    .audio_lrck(audio_lrck),
    .audio_dac(audio_dac)
);

///////////////////////////////////////////////
// Video
///////////////////////////////////////////////

wire [7:0] color_lut[16] = '{
	8'd0,   8'd27,  8'd49,  8'd71,
	8'd87,  8'd103, 8'd119, 8'd130,
	8'd146, 8'd157, 8'd174, 8'd190,
	8'd206, 8'd228, 8'd255, 8'd255
};

wire [3:0] r, g, b;
wire vs, hs;
wire ce_pix;
wire hblank, vblank_sys;

reg video_de_reg;
reg video_hs_reg;
reg video_vs_reg;
reg [23:0] video_rgb_reg;

reg current_pix_clk;
reg current_pix_clk_90;

always @(*) begin
    if(resolution == 2'b00) begin
        current_pix_clk <= clk_vid_256;
        current_pix_clk_90 <= clk_vid_256_90deg;
    end else begin
        current_pix_clk <= clk_vid_320;
        current_pix_clk_90 <= clk_vid_320_90deg;
    end
end

assign video_rgb_clock = current_pix_clk;
assign video_rgb_clock_90 = current_pix_clk_90;

assign video_de = video_de_reg;
assign video_hs = video_hs_reg;
assign video_vs = video_vs_reg;
// assign video_rgb = video_rgb_reg;
assign video_skip = 0;

reg hs_prev;
reg vs_prev;

reg         field;
wire        field_s;

reg         interlaced;
wire        interlaced_s;

reg   [1:0] resolution;
wire  [1:0] resolution_s;

synch_3 #(.WIDTH(2)) sv2(resolution, resolution_s, current_pix_clk);
synch_3 sv3(interlaced, interlaced_s, current_pix_clk);
synch_3 sv4(field, field_s, current_pix_clk);

always @(posedge current_pix_clk) begin
    reg vblank_line = 0;
    video_de_reg <= 0;

	if (vs_c) begin
		video_rgb_reg[23:3] <= 'd0;
		video_rgb_reg[3] <= ~field_s;
		video_rgb_reg[2] <= field_s;
		video_rgb_reg[1] <= interlaced_s;
		video_rgb_reg[0] <= 0;
	end

    // Set Video Mode by Index
    case(resolution_s)
        2'b00: begin video_rgb_reg <= 24'h0;                end              							// [0] 256 x 224
        2'b01: begin video_rgb_reg <= {cs_ar_correction_enable ? 11'd4 : 11'd1, 10'b0, 3'b0}; end		// [1] 320 x 224
        2'b10: begin video_rgb_reg <= {11'd2, 10'b0, 3'b0}; end               							// [2] 256 x 240
        2'b11: begin video_rgb_reg <= {cs_ar_correction_enable ? 11'd5 : 11'd3, 10'b0, 3'b0}; end     // [3] 320 x 240
    endcase


    if (~(vblank_line || hblank_c)) begin
        video_de_reg <= 1;
        video_rgb_reg[23:16] <= (lg_target && lightgun_enabled && show_crosshair) ? {8{lg_target[0]}} : red;
        video_rgb_reg[15:8]  <= (lg_target && lightgun_enabled && show_crosshair) ? {8{lg_target[1]}} : green;
        video_rgb_reg[7:0]   <= (lg_target && lightgun_enabled && show_crosshair) ? {8{lg_target[2]}} : blue;
    end

    video_hs_reg <= ~hs_prev && hs_c;
    video_vs_reg <= ~vs_prev && vs_c;
    hs_prev <= hs_c;
    vs_prev <= vs_c;

    // the vblank signal starts and stops a bit before the end of the visible
    // portion of the line. if used to gate pixel output, this means the last
    // visible line gets truncated and the last blank line is partially shown,
    // producing garbage on the screen. capture and use vblank's value at hsync
    // to avoid this; hsync starts a line so that's when we care whether or not
    // the line is visible.
    if (~hs_prev && hs_c) begin
        vblank_line <= vblank_c;
    end
end

wire TRANSP_DETECT;
wire cofi_enable = cs_composite_enable || (cs_auto_composite_enable && TRANSP_DETECT);
wire hs_c, vs_c, hblank_c, vblank_c;
wire [7:0] red, green, blue;

cofi coffee (
	.clk(clk_sys),
	.pix_ce(ce_pix),
	.enable(cofi_enable),

	.hblank(hblank),
	.vblank(vblank_sys),
	.hs(hs),
	.vs(vs),
	.red(color_lut[r]),
	.green(color_lut[g]),
	.blue(color_lut[b]),

	.hblank_out(hblank_c),
	.vblank_out(vblank_c),
	.hs_out(hs_c),
	.vs_out(vs_c),
	.red_out(red),
	.green_out(green),
	.blue_out(blue)
);

///////////////////////////////////////////////
// RAM
///////////////////////////////////////////////

sdram sdram
(
	.init(~pll_core_locked),
	.clk(clk_ram),

	.addr0(ioctl_addr[24:1]),
	.din0({ioctl_data[7:0], ioctl_data[15:8]}),
	.dout0(),
	.wrl0(1),
	.wrh0(1),
	.req0(ioctl_wr),
	.ack0(sdrom_wrack),

	.addr1(rom_addr),
	.din1(rom_wdata),
	.dout1(sdrom_data),
	.wrl1(rom_we & rom_be[0]),
	.wrh1(rom_we & rom_be[1]),
	.req1(rom_req),
	.ack1(sdrom_rdack),

	// .addr2(rom_addr2),
	// .din2(rom_wdata),
	// .dout2(rom_data2),
	// .wrl2(0),
	// .wrh2(0),
	// .rd2(rom_rd2),
	// .busy2(rom_rdack2),

	.SDRAM_DQ(dram_dq),         // 16 bit bidirectional data bus
	.SDRAM_A(dram_a),           // 13 bit multiplexed address bus
	.SDRAM_DQML(dram_dqm[0]),   // byte mask
	.SDRAM_DQMH(dram_dqm[1]),   // byte mask
    .SDRAM_BA(dram_ba),         // two banks
	.SDRAM_nCS(1'b0),           // a single chip select
	.SDRAM_nWE(dram_we_n),      // write enable
	.SDRAM_nRAS(dram_ras_n),    // row address select
	.SDRAM_nCAS(dram_cas_n),    // columns address select
	.SDRAM_CLK(dram_clk),
	.SDRAM_CKE(dram_cke)
);

wire [24:1] rom_addr, rom_addr2;
wire [15:0] sdrom_data, ddrom_data, rom_data2, rom_wdata;
wire  [1:0] rom_be;
wire rom_req, sdrom_rdack, ddrom_rdack, rom_rd2, rom_rdack2, rom_we;

reg sram_quirk = 0;
reg sram00_quirk = 0;
reg eeprom_quirk = 0;
reg fifo_quirk = 0;
reg noram_quirk = 0;
reg pier_quirk = 0;
reg svp_quirk = 0;
reg fmbusy_quirk = 0;
reg schan_quirk = 0;
reg lightgun_type = 0;
reg [7:0] lightgun_sensor_delay = 8'd44;

always @(posedge clk_sys) begin
	reg [63:0] cart_id;
	
	if(cart_download) begin
		{
			fifo_quirk,
			eeprom_quirk,
			sram_quirk,
			sram00_quirk,
			noram_quirk,
			pier_quirk,
			svp_quirk,
			fmbusy_quirk,
			schan_quirk
		} <= 0;
	end

	if(ioctl_wr & cart_download) begin
		if(ioctl_addr == 'h182) cart_id[63:56] <= ioctl_data[15:8];
		if(ioctl_addr == 'h184) cart_id[55:40] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h186) cart_id[39:24] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h188) cart_id[23:08] <= {ioctl_data[7:0],ioctl_data[15:8]};
		if(ioctl_addr == 'h18A) cart_id[07:00] <= ioctl_data[7:0];
		if(ioctl_addr == 'h18C) begin
			if(cart_id == "T-081276") sram_quirk   		<= 1; // NFL Quarterback Club
			else if(cart_id == "T-81406 ") sram_quirk   <= 1; // NBA Jam TE
			else if(cart_id == "T-081586") sram_quirk   <= 1; // NFL Quarterback Club '96
			else if(cart_id == "T-81576 ") sram_quirk   <= 1; // College Slam
			else if(cart_id == "T-81476 ") sram_quirk   <= 1; // Frank Thomas Big Hurt Baseball
			else if(cart_id == "MK-1215 ") eeprom_quirk <= 1; // Evander Real Deal Holyfield's Boxing
			else if(cart_id == "G-4060  ") eeprom_quirk <= 1; // Wonder Boy
			else if(cart_id == "00001211") eeprom_quirk <= 1; // Sports Talk Baseball
			else if(cart_id == "MK-1228 ") eeprom_quirk <= 1; // Greatest Heavyweights
			else if(cart_id == "G-5538  ") eeprom_quirk <= 1; // Greatest Heavyweights JP
			else if(cart_id == "00004076") eeprom_quirk <= 1; // Honoo no Toukyuuji Dodge Danpei
			else if(cart_id == "T-12046 ") eeprom_quirk <= 1; // Mega Man - The Wily Wars
			else if(cart_id == "T-12053 ") eeprom_quirk <= 1; // Rockman Mega World
			else if(cart_id == "G-4524  ") eeprom_quirk <= 1; // Ninja Burai Densetsu
			else if(cart_id == "T-113016") noram_quirk  <= 1; // Puggsy fake ram check
			else if(cart_id == "T-89016 ") fifo_quirk   <= 1; // Clue
			else if(cart_id == "T-574023") pier_quirk   <= 1; // Pier Solar Reprint
			else if(cart_id == "T-574013") pier_quirk   <= 1; // Pier Solar 1st Edition
			else if(cart_id == "MK-1229 ") svp_quirk    <= 1; // Virtua Racing EU/US
			else if(cart_id == "G-7001  ") svp_quirk    <= 1; // Virtua Racing JP
			else if(cart_id == "T-35036 ") fmbusy_quirk <= 1; // Hellfire US
			else if(cart_id == "T-25073 ") fmbusy_quirk <= 1; // Hellfire JP
			else if(cart_id == "MK-1137-") fmbusy_quirk <= 1; // Hellfire EU
			else if(cart_id == "T-68???-") schan_quirk  <= 1; // Game no Kanzume Otokuyou
			else if(cart_id == " GM 0000") sram00_quirk <= 1; // Sonic 1 Remastered

			// Lightgun device and timing offsets
			if(cart_id == "MK-1533 ") begin						  // Body Count
				lightgun_type  <= 0;
				lightgun_sensor_delay <= 8'd100;
			end
			else if(cart_id == "T-95096-") begin				  // Lethal Enforcers
				lightgun_type  <= 1;
				lightgun_sensor_delay <= 8'd52;
			end
			else if(cart_id == "T-95136-") begin				  // Lethal Enforcers II
				lightgun_type  <= 1;
				lightgun_sensor_delay <= 8'd30;
			end
			else if(cart_id == "MK-1658 ") begin				  // Menacer 6-in-1
				lightgun_type  <= 0;
				lightgun_sensor_delay <= 8'd120;
			end
			else if(cart_id == "T-081156") begin				  // T2: The Arcade Game
				lightgun_type  <= 0;
				lightgun_sensor_delay <= 8'd126;
			end
			else begin
				lightgun_type  <= 0;
				lightgun_sensor_delay <= 8'd44;
			end
		end
	end
end

///////////////////////////////////////////////
// Controls
///////////////////////////////////////////////

wire [15:0] joystick_0, joystick_1, joystick_2, joystick_3;

wire [31:0] cont1_key_s;
wire [31:0] cont2_key_s;
wire [31:0] cont3_key_s;
wire [31:0] cont4_key_s;
wire [31:0] cont1_joy_s;

synch_3 #(
    .WIDTH(32)
) cont1_s (
    cont1_key,
    cont1_key_s,
    clk_sys
);

synch_3 #(
    .WIDTH(32)
) cont2_s (
    cont2_key,
    cont2_key_s,
    clk_sys
);

synch_3 #(
    .WIDTH(32)
) cont3_s (
    cont3_key,
    cont3_key_s,
    clk_sys
);

synch_3 #(
    .WIDTH(32)
) cont4_s (
    cont4_key,
    cont4_key_s,
    clk_sys
);

synch_3 #(
    .WIDTH(32)
) joy1_s (
    cont1_joy,
    cont1_joy_s,
    clk_sys
);

assign joystick_0 = {
    p1_controls[9],  // Z
    p1_controls[6],  // Y
    p1_controls[8],  // X
    p1_controls[14], // mode
    lightgun_enabled  ? 1'b0 : p1_controls[15], // start
    p1_controls[4],  // B
    p1_controls[5],  // C
    p1_controls[7],  // A
    p1_controls[0],                                        // up
    p1_controls[1],                                        // down
    p1_controls[2],                                        // left
    p1_controls[3],                                        // right
};

assign joystick_1 = {
    p2_controls[9],  // Z
    p2_controls[6],  // Y
    p2_controls[8],  // X
    p2_controls[14], // mode
    p2_controls[15], // start
    p2_controls[4],  // B
    p2_controls[5],  // C
    p2_controls[7],  // A
    p2_controls[0],  // up
    p2_controls[1],  // down
    p2_controls[2],  // left
    p2_controls[3],  // right
};

assign joystick_2 = {
    p3_controls[9],  // Z
    p3_controls[6],  // Y
    p3_controls[8],  // X
    p3_controls[14], // mode
    p3_controls[15], // start
    p3_controls[4],  // B
    p3_controls[5],  // C
    p3_controls[7],  // A
    p3_controls[0],  // up
    p3_controls[1],  // down
    p3_controls[2],  // left
    p3_controls[3],  // right
};

assign joystick_3 = {
    p4_controls[9],  // Z
    p4_controls[6],  // Y
    p4_controls[8],  // X
    p4_controls[14], // mode
    p4_controls[15], // start
    p4_controls[4],  // B
    p4_controls[5],  // C
    p4_controls[7],  // A
    p4_controls[0],  // up
    p4_controls[1],  // down
    p4_controls[2],  // left
    p4_controls[3],  // right
};

///////////////////////////////////////////////
// Lightguns
///////////////////////////////////////////////
wire [2:0] lg_target;
wire       lg_sensor;
wire       lg_a;
wire       lg_b;
wire       lg_c;
wire       lg_start;

lightgun lightgun
(
    .CLK(clk_sys),
    .RESET(reset),

    // .MOUSE(ps2_mouse),
    // .MOUSE_XY(&gun_mode),

    .JOY_X(p1_stick_x),
    .JOY_Y(p1_stick_y),
    .JOY(p1_controls),

    .UP(p1_controls[0]),
    .DOWN(p1_controls[1]),
    .LEFT(p1_controls[2]),
    .RIGHT(p1_controls[3]),
    .DPAD_AIM_SPEED(dpad_aim_speed),

    .RELOAD(lightgun_type),

    .HDE(~hblank_c),
    .VDE(~vblank_c),
    .CE_PIX(ce_pix),
    .H40(resolution[0]),

    .BTN_MODE(0),
    // .SIZE(0),
    .SENSOR_DELAY(lightgun_sensor_delay),

    .TARGET(lg_target),
    .SENSOR(lg_sensor),
    .BTN_A(lg_a),
    .BTN_B(lg_b),
    .BTN_C(lg_c),
    .BTN_START(lg_start)
);

///////////////////////////////////////////////
// Instance
///////////////////////////////////////////////

wire osnotify_inmenu_s;
synch_3 pause_s (
	osnotify_inmenu, 
	osnotify_inmenu_s, 
	clk_sys
);

wire reset = ~reset_n | cart_download | region_set;

system system
(
	.RESET_N(~reset && !reset_delay),
	.MCLK(clk_sys),

	.LOADING(cart_download),
	.EXPORT(|region_req),
	.PAL(0),
	.SRAM_QUIRK(sram_quirk),
	.SRAM00_QUIRK(sram00_quirk),
	.EEPROM_QUIRK(eeprom_quirk),
	.NORAM_QUIRK(noram_quirk),
	.PIER_QUIRK(pier_quirk),
	.FMBUSY_QUIRK(fmbusy_quirk),

	.DAC_LDATA(AUDIO_L),
	.DAC_RDATA(AUDIO_R),

	.TURBO(cs_cpu_turbo),

	.RED(r),
	.GREEN(g),
	.BLUE(b),
	.VS(vs),
	.HS(hs),
	.HBL(hblank),
	.VBL(vblank_sys),
	.BORDER(0),
	.CRAM_DOTS(0),
	.CE_PIX(ce_pix),
	.FIELD(field),
	.INTERLACE(interlaced),
	.RESOLUTION(resolution),
	.FAST_FIFO(fifo_quirk),
	.SVP_QUIRK(svp_quirk),
	.SCHAN_QUIRK(schan_quirk),

	// .J3BUT(0),
	.JOY_1(joystick_0),
	.JOY_2(joystick_1),
	.JOY_3(joystick_2),
	.JOY_4(joystick_3),
	// .JOY_5(joystick_4),
	.MULTITAP(cs_multitap_enable),

	// .MOUSE(),
	// .MOUSE_OPT(0),

    .GUN_OPT(lightgun_enabled),
    .GUN_TYPE(lightgun_type),
    .GUN_SENSOR(lg_sensor),
    .GUN_A(lg_a),
    .GUN_B(lg_b),
    .GUN_C(lg_c),
    .GUN_START(lg_start),

	// .SERJOYSTICK_IN(),
	// .SERJOYSTICK_OUT(),
	// .SER_OPT(0),

	// .ENABLE_FM(cs_fm_enable),
	// .ENABLE_PSG(cs_psg_enable),
	// .EN_HIFI_PCM(cs_hifi_pcm_enable),
    .ENABLE_FM(1'b1),
	.ENABLE_PSG(1'b1),
	.EN_HIFI_PCM(1'b1),
	.LADDER(~cs_fm_chip),
	.LPF_MODE(cs_audio_filter),

	.OBJ_LIMIT_HIGH(cs_obj_limit_high_enable),

	.BRAM_A(sd_buff_addr),
	.BRAM_DI(sd_buff_dout),
	.BRAM_DO(sd_buff_din),
	.BRAM_WE(sd_wr),
	.BRAM_CHANGE(),

	.ROMSZ(rom_file_size[24:1]),
	.ROM_ADDR(rom_addr),
	.ROM_DATA(sdrom_data),
	.ROM_WDATA(rom_wdata),
	.ROM_WE(rom_we),
	.ROM_BE(rom_be),
	.ROM_REQ(rom_req),
	.ROM_ACK(sdrom_rdack),

	.ROM_ADDR2(rom_addr2),
	.ROM_DATA2(rom_data2),
	.ROM_REQ2(rom_rd2),
	.ROM_ACK2(rom_rdack2),

	.TRANSP_DETECT(TRANSP_DETECT),

	.PAUSE_EN(cs_menu_pause_enable ? osnotify_inmenu_s : 0),
	.BGA_EN(1),
	.BGB_EN(1),
	.SPR_EN(1)
);

///////////////////////////////////////////////

    wire    clk_sys;
    wire    clk_ram;
    wire    clk_vid_320;
    wire    clk_vid_320_90deg;
    wire    clk_vid_256;
    wire    clk_vid_256_90deg;
    wire    clk_vid_448i;
    wire    clk_vid_448i_90deg;

    wire    pll_core_locked;

    mf_pllbase
        mp1 (
            .refclk   ( clk_74a            ),
            .rst      ( 0                  ),

            .outclk_0 ( clk_sys            ), //53.693181 MHz
            .outclk_1 ( clk_ram            ), //107.38635 MHz
            .outclk_2 ( clk_vid_320        ),
            .outclk_3 ( clk_vid_320_90deg  ),
            .outclk_4 ( clk_vid_256        ),
            .outclk_5 ( clk_vid_256_90deg  ),

            .locked   ( pll_core_locked    )
        );


///////////////////////////////////////////////////
// wire clk_sys, clk_ram, locked;

// pll pll
// (
// 	.refclk(CLK_50M),
// 	.rst(0),
// 	.outclk_0(clk_sys),
// 	.outclk_1(clk_ram),
// 	.reconfig_to_pll(reconfig_to_pll),
// 	.reconfig_from_pll(reconfig_from_pll),
// 	.locked(locked)
// );

// wire [63:0] reconfig_to_pll;
// wire [63:0] reconfig_from_pll;
// wire        cfg_waitrequest;
// reg         cfg_write;
// reg   [5:0] cfg_address;
// reg  [31:0] cfg_data;

// pll_cfg pll_cfg
// (
// 	.mgmt_clk(CLK_50M),
// 	.mgmt_reset(0),
// 	.mgmt_waitrequest(cfg_waitrequest),
// 	.mgmt_read(0),
// 	.mgmt_readdata(),
// 	.mgmt_write(cfg_write),
// 	.mgmt_address(cfg_address),
// 	.mgmt_writedata(cfg_data),
// 	.reconfig_to_pll(reconfig_to_pll),
// 	.reconfig_from_pll(reconfig_from_pll)
// );

// always @(posedge CLK_50M) begin
// 	reg pald = 0, pald2 = 0;
// 	reg [2:0] state = 0;
// 	reg pal_r;

// 	pald <= PAL;
// 	pald2 <= pald;

// 	cfg_write <= 0;
// 	if(pald2 == pald && pald2 != pal_r) begin
// 		state <= 1;
// 		pal_r <= pald2;
// 	end

// 	if(!cfg_waitrequest) begin
// 		if(state) state<=state+1'd1;
// 		case(state)
// 			1: begin
// 					cfg_address <= 0;
// 					cfg_data <= 0;
// 					cfg_write <= 1;
// 				end
// 			5: begin
// 					cfg_address <= 7;
// 					cfg_data <= pal_r ? 2201376125 : 2537930535;
// 					cfg_write <= 1;
// 				end
// 			7: begin
// 					cfg_address <= 2;
// 					cfg_data <= 0;
// 					cfg_write <= 1;
// 				end
// 		endcase
// 	end
// end


//*** Analogizer Interface V1.2 ***
//Pocket Menu settings
reg [13:0] analogizer_settings = 0;
wire [13:0] analogizer_settings_s;

reg analogizer_ena;
reg [3:0] analogizer_video_type;
reg [4:0] snac_game_cont_type /* synthesis keep */;
reg [3:0] snac_cont_assignment /* synthesis keep */;


synch_3 #(.WIDTH(14)) sync_analogizer(analogizer_settings, analogizer_settings_s, clk_sys);


wire clk_vid = clk_sys; //video_rgb_clock; //Fixed one bit shift error on RGB channels.

  //create aditional switch to blank Pocket screen.
  assign video_rgb = (analogizer_video_type[3]) ? 24'h000000: video_rgb_reg;

always @(*) begin
  snac_game_cont_type   = analogizer_settings_s[4:0];
  snac_cont_assignment  = analogizer_settings_s[9:6];
  analogizer_video_type = analogizer_settings_s[13:10];
end 
//use PSX Dual Shock style left analog stick as directional pad
wire is_analog_input = (snac_game_cont_type == 5'h13);

//! Player 1 ---------------------------------------------------------------------------
reg p1_up, p1_down, p1_left, p1_right;
wire p1_up_analog, p1_down_analog, p1_left_analog, p1_right_analog;
//using left analog joypad
assign p1_up_analog    = (p1_stick[15:8] < 8'h40) ? 1'b1 : 1'b0; //analog range UP 0x00 Idle 0x7F DOWN 0xFF, DEADZONE +- 0x15
assign p1_down_analog  = (p1_stick[15:8] > 8'hC0) ? 1'b1 : 1'b0; 
assign p1_left_analog  = (p1_stick[7:0]  < 8'h40) ? 1'b1 : 1'b0; //analog range LEFT 0x00 Idle 0x7F RIGHT 0xFF, DEADZONE +- 0x15
assign p1_right_analog = (p1_stick[7:0]  > 8'hC0) ? 1'b1 : 1'b0;

always @(posedge clk_sys) begin
    p1_up    <= (is_analog_input) ? p1_up_analog    : p1_btn[0];
    p1_down  <= (is_analog_input) ? p1_down_analog  : p1_btn[1];
    p1_left  <= (is_analog_input) ? p1_left_analog  : p1_btn[2];
    p1_right <= (is_analog_input) ? p1_right_analog : p1_btn[3];
end

//! Player 2 ---------------------------------------------------------------------------
reg p2_up, p2_down, p2_left, p2_right;
wire p2_up_analog, p2_down_analog, p2_left_analog, p2_right_analog;
//using left analog joypad
assign p2_up_analog    = (p2_stick[15:8] < 8'h40) ? 1'b1 : 1'b0; //analog range UP 0x00 Idle 0x7F DOWN 0xFF, DEADZONE +- 0x15
assign p2_down_analog  = (p2_stick[15:8] > 8'hC0) ? 1'b1 : 1'b0; 
assign p2_left_analog  = (p2_stick[7:0]  < 8'h40) ? 1'b1 : 1'b0; //analog range LEFT 0x00 Idle 0x7F RIGHT 0xFF, DEADZONE +- 0x15
assign p2_right_analog = (p2_stick[7:0]  > 8'hC0) ? 1'b1 : 1'b0;

always @(posedge clk_sys) begin
    p2_up    <= (is_analog_input) ? p2_up_analog    : p2_btn[0];
    p2_down  <= (is_analog_input) ? p2_down_analog  : p2_btn[1];
    p2_left  <= (is_analog_input) ? p2_left_analog  : p2_btn[2];
    p2_right <= (is_analog_input) ? p2_right_analog : p2_btn[3];
end


//switch between Analogizer SNAC and Pocket Controls for P1-P4 (P3,P4 when uses PCEngine Multitap)
wire [15:0] p1_btn, p2_btn, p3_btn, p4_btn;
wire [31:0] p1_stick;
wire [31:0] p2_stick;   
reg [15:0] p1_controls, p2_controls, p3_controls, p4_controls;
reg [7:0] p1_stick_x, p1_stick_y;

always @(posedge clk_sys) begin
    if(snac_game_cont_type == 5'h0) begin //SNAC is disabled
                    p1_controls <= cont1_key_s;
                    p1_stick_x  <= cont1_joy_s[7:0];
                    p1_stick_y  <= cont1_joy_s[15:8];
                    p2_controls <= cont2_key_s;
                    p3_controls <= cont3_key_s;
                    p4_controls <= cont4_key_s;
    end
    else begin
        case(snac_cont_assignment)
        4'h0:    begin 
                    p1_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                    p1_stick_x  <= p1_stick[7:0];
                    p1_stick_y  <= p1_stick[15:8];
                    p2_controls <= cont2_key_s;
                    p3_controls <= cont3_key_s;
                    p4_controls <= cont4_key_s;
                end
        4'h1:    begin 
                    p1_controls <= cont1_key_s;
                    p1_stick_x  <= cont1_joy_s[7:0];
                    p1_stick_y  <= cont1_joy_s[15:8];
                    p2_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                    p3_controls <= cont3_key_s;
                    p4_controls <= cont4_key_s;
                end
        4'h2:    begin
                    p1_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                    p1_stick_x  <= p1_stick[7:0];
                    p1_stick_y  <= p1_stick[15:8];
                    p2_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
                    p3_controls <= cont3_key_s;
                    p4_controls <= cont4_key_s;
                end
        4'h3:    begin
                    p1_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
                    p1_stick_x  <= p2_stick[7:0];
                    p1_stick_y  <= p2_stick[15:8];
                    p2_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                    p3_controls <= cont3_key_s;
                    p4_controls <= cont4_key_s;
                end
        4'h4:    begin
                    p1_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                    p1_stick_x  <= p1_stick[7:0];
                    p1_stick_y  <= p1_stick[15:8]; 
                    p2_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
                    p3_controls <= p3_btn;
                    p4_controls <= p4_btn;
                end
        4'h5:    begin
                    p1_controls <= p4_btn;
                    p1_stick_x  <= 8'd0;
                    p1_stick_y  <= 8'd0;
                    p2_controls <= p3_btn;
                    p3_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
                    p4_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                end
        4'h6:    begin
                    p1_controls <= cont1_key_s;
                    p1_stick_x  <= cont1_joy_s[7:0];
                    p1_stick_y  <= cont1_joy_s[15:8];
                    p2_controls <= cont2_key_s;
                    p3_controls <= {p1_btn[15:4],p1_right,p1_left,p1_down,p1_up};
                    p4_controls <= {p2_btn[15:4],p2_right,p2_left,p2_down,p2_up};
                end
        default: begin
                    p1_controls <= cont1_key_s;
                    p1_stick_x  <= cont1_joy_s[7:0];
                    p1_stick_y  <= cont1_joy_s[15:8];
                    p2_controls <= cont2_key_s;
                    p3_controls <= cont3_key_s;
                    p4_controls <= cont4_key_s;
                end
        endcase
    end
end

// Video Y/C Encoder settings
// Follows the Mike Simone Y/C encoder settings:
// https://github.com/MikeS11/MiSTerFPGA_YC_Encoder
// SET PAL and NTSC TIMING and pass through status bits. ** YC must be enabled in the qsf file **
wire [39:0] CHROMA_PHASE_INC;
wire [26:0] COLORBURST_RANGE;
wire [4:0] CHROMA_ADD;
wire [4:0] CHROMA_MULT;
wire PALFLAG;

parameter NTSC_REF = 3.579545;   
parameter PAL_REF = 4.43361875;
// Colorburst Lenth Calculation to send to Y/C Module, based on the CLK_VIDEO of the core
localparam [6:0] COLORBURST_START = (3.7 * (CLK_VIDEO_NTSC/NTSC_REF));
localparam [9:0] COLORBURST_NTSC_END = (9 * (CLK_VIDEO_NTSC/NTSC_REF)) + COLORBURST_START;
localparam [9:0] COLORBURST_PAL_END = (10 * (CLK_VIDEO_PAL/PAL_REF)) + COLORBURST_START;

// Parameters to be modifed
parameter CLK_VIDEO_NTSC = 53.693181; //Pocket HACK, 107.38635MHz
parameter CLK_VIDEO_PAL  = 53.693181; //Pocket HACK, should be 106.406846MHz, using dinamic reconfig pll

localparam [39:0] NTSC_PHASE_INC = 40'd73300766994; 
localparam [39:0] PAL_PHASE_INC =  40'd90790213542; 

assign CHROMA_PHASE_INC = ((analogizer_video_type == 4'h4)|| (analogizer_video_type == 4'hC)) ? PAL_PHASE_INC : NTSC_PHASE_INC; 
assign PALFLAG = (analogizer_video_type == 4'h4) || (analogizer_video_type == 4'hC); 
assign CHROMA_ADD = 5'd0;
assign CHROMA_MULT = 5'd0;
//assign CHROMA_ADD = 5'd0;
//assign CHROMA_MULT = 5'd0;
assign COLORBURST_RANGE = {COLORBURST_START, COLORBURST_NTSC_END, COLORBURST_PAL_END}; // Pass colorburst length

parameter MASTER_CLK_FREQ = 53_693_181;

// reg old_ce_pix;
// always @(posedge clk_ram) old_ce_pix <= ce_pix;

// wire SYNC = ~^{hs_c, vs_c};
// wire  ANALOGIZER_DE = ~(hblank_c || vblank_c); //vblank_line

reg [2:0] fx /* synthesis preserve */;
reg sd_ena;
always @(posedge clk_sys) begin
    case (analogizer_video_type)
        4'd5, 4'd13:    begin sd_ena <= 1'b1; fx <= 3'd0; end //SC  0%     1 SC 25%
        4'd6, 4'd14:    begin sd_ena <= 1'b1; fx <= 3'd2; end //SC  50%    3 SC 75%
        4'd7, 4'd15:    begin sd_ena <= 1'b1; fx <= 3'd4; end //hq2x
        default:        begin sd_ena <= 1'b0; fx <= 3'd0; end
    endcase
end

reg old_ce_pix;
always @(posedge clk_sys) old_ce_pix <= ce_pix;


//Fix Vsync
reg hs_prev2;
reg vblank_line2;
reg [7:0] RGIZER, GGIZER, BGIZER;

// wire SYNC = ~^{hs_c, vs_c};
// wire  ANALOGIZER_DE = ~(hblank_c || vblank_line2); //vblank_line
reg SYNC, ANALOGIZER_DE;
reg hblank2;
reg hs2, vs2;

always @(posedge clk_vid) begin
    if (ce_pix) begin
        ANALOGIZER_DE <= 1'b0;
        SYNC <= ~^{hs_c, vs_c};

        hblank2 <= hblank_c;
        hs2 <= hs_c;
        vs2 <= vs_c;
        hs_prev2 <= hs_c;

        if (~(vblank_line2 || hblank_c)) begin
            //ANALOGIZER_DE <= ~(hblank_c || vblank_line2); //vblank_line
            ANALOGIZER_DE <= 1'b1;
            RGIZER <= (lg_target && lightgun_enabled && show_crosshair) ? {8{lg_target[0]}} : red;
            GGIZER <= (lg_target && lightgun_enabled && show_crosshair) ? {8{lg_target[1]}} : green;
            BGIZER <= (lg_target && lightgun_enabled && show_crosshair) ? {8{lg_target[2]}} : blue;
        end
        //vs_prev2 <= vs_c;

        // the vblank signal starts and stops a bit before the end of the visible
        // portion of the line. if used to gate pixel output, this means the last
        // visible line gets truncated and the last blank line is partially shown,
        // producing garbage on the screen. capture and use vblank's value at hsync
        // to avoid this; hsync starts a line so that's when we care whether or not
        // the line is visible.
        if (~hs_prev2 && hs_c) begin
            vblank_line2 <= vblank_c;
        end
    end
end

openFPGA_Pocket_Analogizer #(.MASTER_CLK_FREQ(MASTER_CLK_FREQ), .LINE_LENGTH(320)) analogizer (
    .i_clk(clk_sys),
    .i_rst(~(~reset && !reset_delay)), //i_rst is active high
    .i_ena(1'b1),
    //Video interface
    .analog_video_type(analogizer_video_type),
    //.analog_video_type(4'd0),
    .R(RGIZER),
    .G(GGIZER),
    .B(BGIZER),
    .Hblank(hblank2),
    .Vblank(vblank_line2),
    .BLANKn(ANALOGIZER_DE),
    .Csync(SYNC),
    .Hsync(hs2),
    .Vsync(vs2),
    .video_clk(clk_vid),
    //Video Y/C Encoder interface
    .PALFLAG(PALFLAG),
    .CHROMA_PHASE_INC(CHROMA_PHASE_INC),
    //Video SVGA Scandoubler interface
    .scandoubler(!interlaced && (sd_ena == 1'b1)), //logic to enable/disable scandoubler
    .ce_pix(~old_ce_pix & ce_pix),
	.fx(fx), //0 disable, 1 scanlines 25%, 2 scanlines 50%, 3 scanlines 75%, 4 hq2x
	//SNAC interface
	.conf_AB((snac_game_cont_type >= 5'd16)),              //0 conf. A(default), 1 conf. B (see graph above)
	.game_cont_type(snac_game_cont_type), //0-15 Conf. A, 16-31 Conf. B
	.p1_btn_state(p1_btn),
    .p1_joy_state(p1_stick),
	.p2_btn_state(p2_btn),  
    .p2_joy_state(p2_stick),
    .p3_btn_state(p3_btn),
	.p4_btn_state(p4_btn),  
	//Pocket Analogizer IO interface to the Pocket cartridge port
	.cart_tran_bank2(cart_tran_bank2),
	.cart_tran_bank2_dir(cart_tran_bank2_dir),
	.cart_tran_bank3(cart_tran_bank3),
	.cart_tran_bank3_dir(cart_tran_bank3_dir),
	.cart_tran_bank1(cart_tran_bank1),
	.cart_tran_bank1_dir(cart_tran_bank1_dir),
	.cart_tran_bank0(cart_tran_bank0),
	.cart_tran_bank0_dir(cart_tran_bank0_dir),
	.cart_tran_pin30(cart_tran_pin30),
	.cart_tran_pin30_dir(cart_tran_pin30_dir),
	.cart_pin30_pwroff_reset(cart_pin30_pwroff_reset),
	.cart_tran_pin31(cart_tran_pin31),
	.cart_tran_pin31_dir(cart_tran_pin31_dir),
	//debug
	.o_stb()
);
/*[ANALOGIZER_HOOK_END]*/
endmodule
