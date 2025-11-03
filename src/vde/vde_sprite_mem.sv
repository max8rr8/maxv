`default_nettype none

module vde_sprite_mem #(
    parameter logic [65535:0] INIT_SPRITE = 0
) (
    input clk_i,
    input rstn_i,

    input  logic [10:0] sprite_mem_addr_i,
    output logic [31:0] sprite_mem_data_o,

    input  logic bus_mem_enable_i, 
    input  logic [ 3:0] bus_mem_wstrb_i,
    input  logic [10:0] bus_mem_addr_i,
    input  logic [31:0] bus_mem_wvalue_i,
    output logic [31:0] bus_mem_rvalue_o
);

  logic [10:0] map_mem_ad[0:7];
  logic [7:0] map_mem_out[0:7];
  logic [7:0] map_mem_in[0:3];
  logic map_mem_write[0:3];

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin
      logic [15:0] gen_mem_ina_full;
      logic [15:0] gen_mem_inb_full;
      logic [15:0] gen_mem_outa_full;
      logic [15:0] gen_mem_outb_full;
      logic [13:0] gen_mem_ada;
      logic [13:0] gen_mem_adb;
      logic gen_mem_wra;

      assign gen_mem_ada = {map_mem_ad[i], 3'b000};
      assign gen_mem_adb = {map_mem_ad[i+4], 3'b000};
      assign gen_mem_ina_full = {8'b0, map_mem_in[i]};
      assign gen_mem_inb_full = 16'b0;
      assign map_mem_out[i] = gen_mem_outa_full[7:0];
      assign map_mem_out[i+4] = gen_mem_outb_full[7:0];
      assign gen_mem_wra = map_mem_write[i];

      DPB #(
          .BIT_WIDTH_0(8),
          .BIT_WIDTH_1(8),
          .INIT_RAM_00(INIT_SPRITE[i*16384+255:i*16384+0]),
          .INIT_RAM_01(INIT_SPRITE[i*16384+511:i*16384+256]),
          .INIT_RAM_02(INIT_SPRITE[i*16384+767:i*16384+512]),
          .INIT_RAM_03(INIT_SPRITE[i*16384+1023:i*16384+768]),
          .INIT_RAM_04(INIT_SPRITE[i*16384+1279:i*16384+1024]),
          .INIT_RAM_05(INIT_SPRITE[i*16384+1535:i*16384+1280]),
          .INIT_RAM_06(INIT_SPRITE[i*16384+1791:i*16384+1536]),
          .INIT_RAM_07(INIT_SPRITE[i*16384+2047:i*16384+1792]),
          .INIT_RAM_08(INIT_SPRITE[i*16384+2303:i*16384+2048]),
          .INIT_RAM_09(INIT_SPRITE[i*16384+2559:i*16384+2304]),
          .INIT_RAM_0A(INIT_SPRITE[i*16384+2815:i*16384+2560]),
          .INIT_RAM_0B(INIT_SPRITE[i*16384+3071:i*16384+2816]),
          .INIT_RAM_0C(INIT_SPRITE[i*16384+3327:i*16384+3072]),
          .INIT_RAM_0D(INIT_SPRITE[i*16384+3583:i*16384+3328]),
          .INIT_RAM_0E(INIT_SPRITE[i*16384+3839:i*16384+3584]),
          .INIT_RAM_0F(INIT_SPRITE[i*16384+4095:i*16384+3840]),
          .INIT_RAM_10(INIT_SPRITE[i*16384+4351:i*16384+4096]),
          .INIT_RAM_11(INIT_SPRITE[i*16384+4607:i*16384+4352]),
          .INIT_RAM_12(INIT_SPRITE[i*16384+4863:i*16384+4608]),
          .INIT_RAM_13(INIT_SPRITE[i*16384+5119:i*16384+4864]),
          .INIT_RAM_14(INIT_SPRITE[i*16384+5375:i*16384+5120]),
          .INIT_RAM_15(INIT_SPRITE[i*16384+5631:i*16384+5376]),
          .INIT_RAM_16(INIT_SPRITE[i*16384+5887:i*16384+5632]),
          .INIT_RAM_17(INIT_SPRITE[i*16384+6143:i*16384+5888]),
          .INIT_RAM_18(INIT_SPRITE[i*16384+6399:i*16384+6144]),
          .INIT_RAM_19(INIT_SPRITE[i*16384+6655:i*16384+6400]),
          .INIT_RAM_1A(INIT_SPRITE[i*16384+6911:i*16384+6656]),
          .INIT_RAM_1B(INIT_SPRITE[i*16384+7167:i*16384+6912]),
          .INIT_RAM_1C(INIT_SPRITE[i*16384+7423:i*16384+7168]),
          .INIT_RAM_1D(INIT_SPRITE[i*16384+7679:i*16384+7424]),
          .INIT_RAM_1E(INIT_SPRITE[i*16384+7935:i*16384+7680]),
          .INIT_RAM_1F(INIT_SPRITE[i*16384+8191:i*16384+7936]),
          .INIT_RAM_20(INIT_SPRITE[i*16384+8447:i*16384+8192]),
          .INIT_RAM_21(INIT_SPRITE[i*16384+8703:i*16384+8448]),
          .INIT_RAM_22(INIT_SPRITE[i*16384+8959:i*16384+8704]),
          .INIT_RAM_23(INIT_SPRITE[i*16384+9215:i*16384+8960]),
          .INIT_RAM_24(INIT_SPRITE[i*16384+9471:i*16384+9216]),
          .INIT_RAM_25(INIT_SPRITE[i*16384+9727:i*16384+9472]),
          .INIT_RAM_26(INIT_SPRITE[i*16384+9983:i*16384+9728]),
          .INIT_RAM_27(INIT_SPRITE[i*16384+10239:i*16384+9984]),
          .INIT_RAM_28(INIT_SPRITE[i*16384+10495:i*16384+10240]),
          .INIT_RAM_29(INIT_SPRITE[i*16384+10751:i*16384+10496]),
          .INIT_RAM_2A(INIT_SPRITE[i*16384+11007:i*16384+10752]),
          .INIT_RAM_2B(INIT_SPRITE[i*16384+11263:i*16384+11008]),
          .INIT_RAM_2C(INIT_SPRITE[i*16384+11519:i*16384+11264]),
          .INIT_RAM_2D(INIT_SPRITE[i*16384+11775:i*16384+11520]),
          .INIT_RAM_2E(INIT_SPRITE[i*16384+12031:i*16384+11776]),
          .INIT_RAM_2F(INIT_SPRITE[i*16384+12287:i*16384+12032]),
          .INIT_RAM_30(INIT_SPRITE[i*16384+12543:i*16384+12288]),
          .INIT_RAM_31(INIT_SPRITE[i*16384+12799:i*16384+12544]),
          .INIT_RAM_32(INIT_SPRITE[i*16384+13055:i*16384+12800]),
          .INIT_RAM_33(INIT_SPRITE[i*16384+13311:i*16384+13056]),
          .INIT_RAM_34(INIT_SPRITE[i*16384+13567:i*16384+13312]),
          .INIT_RAM_35(INIT_SPRITE[i*16384+13823:i*16384+13568]),
          .INIT_RAM_36(INIT_SPRITE[i*16384+14079:i*16384+13824]),
          .INIT_RAM_37(INIT_SPRITE[i*16384+14335:i*16384+14080]),
          .INIT_RAM_38(INIT_SPRITE[i*16384+14591:i*16384+14336]),
          .INIT_RAM_39(INIT_SPRITE[i*16384+14847:i*16384+14592]),
          .INIT_RAM_3A(INIT_SPRITE[i*16384+15103:i*16384+14848]),
          .INIT_RAM_3B(INIT_SPRITE[i*16384+15359:i*16384+15104]),
          .INIT_RAM_3C(INIT_SPRITE[i*16384+15615:i*16384+15360]),
          .INIT_RAM_3D(INIT_SPRITE[i*16384+15871:i*16384+15616]),
          .INIT_RAM_3E(INIT_SPRITE[i*16384+16127:i*16384+15872]),
          .INIT_RAM_3F(INIT_SPRITE[i*16384+16383:i*16384+16128]),

          .BLK_SEL_0  (3'b000),
          .BLK_SEL_1  (3'b000),
          .READ_MODE0 (1'b0),
          .READ_MODE1 (1'b0),
          .RESET_MODE ("SYNC"),
          .WRITE_MODE0(2'b00),
          .WRITE_MODE1(2'b00)
      ) dpx9b_inst (
          .ADA(gen_mem_ada),
          .ADB(gen_mem_adb),
          .BLKSELA(3'b000),
          .BLKSELB(3'b000),
          .CEA(1'b1),
          .CEB(1'b1),
          .CLKA(clk_i),
          .CLKB(clk_i),
          .DIA(gen_mem_ina_full),
          .DIB(16'b0),
          .DOA(gen_mem_outa_full),
          .DOB(gen_mem_outb_full),
          .OCEA(1'b1),
          .OCEB(1'b1),
          .RESETA(~rstn_i),
          .RESETB(~rstn_i),
          .WREA(gen_mem_wra),
          .WREB(1'b0)
      );
    end
  endgenerate

  assign map_mem_ad[4] = sprite_mem_addr_i;
  assign map_mem_ad[5] = sprite_mem_addr_i;
  assign map_mem_ad[6] = sprite_mem_addr_i;
  assign map_mem_ad[7] = sprite_mem_addr_i;
  assign sprite_mem_data_o = {
    map_mem_out[4], 
    map_mem_out[5], 
    map_mem_out[6], 
    map_mem_out[7]
  };

  assign map_mem_ad[0] = bus_mem_addr_i;
  assign map_mem_ad[1] = bus_mem_addr_i;
  assign map_mem_ad[2] = bus_mem_addr_i;
  assign map_mem_ad[3] = bus_mem_addr_i;
  assign bus_mem_rvalue_o = {
    map_mem_out[0], 
    map_mem_out[1], 
    map_mem_out[2], 
    map_mem_out[3]
  };
  assign map_mem_write[0] = bus_mem_enable_i & bus_mem_wstrb_i[0];
  assign map_mem_write[1] = bus_mem_enable_i & bus_mem_wstrb_i[1];
  assign map_mem_write[2] = bus_mem_enable_i & bus_mem_wstrb_i[2];
  assign map_mem_write[3] = bus_mem_enable_i & bus_mem_wstrb_i[3];
  assign map_mem_in[0] = bus_mem_wvalue_i[31:24];
  assign map_mem_in[1] = bus_mem_wvalue_i[23:16];
  assign map_mem_in[2] = bus_mem_wvalue_i[15:8];
  assign map_mem_in[3] = bus_mem_wvalue_i[7:0];
endmodule
