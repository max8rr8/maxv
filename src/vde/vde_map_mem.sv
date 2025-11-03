`default_nettype none

module vde_map_mem #(
    parameter logic [55299:0] INIT_MAP = 0
) (
    input clk_i,
    input rstn_i,

    input  logic [ 7:0] pixel_mem_addr_i,
    output logic [23:0] pixel_mem_data_o,

    input logic [12:0] map_mem_addr_i,
    input logic map_mem_fetch_i,
    output logic [8:0] map_mem_data_o,
    output logic map_mem_done_o,

    input logic [7:0] update_color_idx_i,
    input logic [23:0] update_color_val_i,
    input logic update_color_upd_i,

    input logic [6:0] update_map_x_i,
    input logic [5:0] update_map_y_i,
    input logic [8:0] update_map_val_i,
    input logic update_map_upd_i
);

  logic [10:0] map_mem_ad[0:5];
  logic [8:0] map_mem_out[0:5];
  logic [8:0] map_mem_in[0:2];
  logic map_mem_write[0:2];

  genvar i;
  generate
    for (i = 0; i < 3; i = i + 1) begin
      logic [17:0] gen_mem_ina_full;
      logic [17:0] gen_mem_inb_full;
      logic [17:0] gen_mem_outa_full;
      logic [17:0] gen_mem_outb_full;
      logic [13:0] gen_mem_ada;
      logic [13:0] gen_mem_adb;
      logic gen_mem_wra;

      assign gen_mem_ada = {map_mem_ad[i], 3'b000};
      assign gen_mem_adb = {map_mem_ad[i+3], 3'b000};
      assign gen_mem_ina_full = {9'b0, map_mem_in[i]};
      assign gen_mem_inb_full = 18'b0;
      assign map_mem_out[i] = gen_mem_outa_full[8:0];
      assign map_mem_out[i+3] = gen_mem_outb_full[8:0];
      assign gen_mem_wra = map_mem_write[i];

      DPX9B #(
          .BIT_WIDTH_0(9),
          .BIT_WIDTH_1(9),
          .INIT_RAM_00(INIT_MAP[i*18432+287:i*18432+0]),
          .INIT_RAM_01(INIT_MAP[i*18432+575:i*18432+288]),
          .INIT_RAM_02(INIT_MAP[i*18432+863:i*18432+576]),
          .INIT_RAM_03(INIT_MAP[i*18432+1151:i*18432+864]),
          .INIT_RAM_04(INIT_MAP[i*18432+1439:i*18432+1152]),
          .INIT_RAM_05(INIT_MAP[i*18432+1727:i*18432+1440]),
          .INIT_RAM_06(INIT_MAP[i*18432+2015:i*18432+1728]),
          .INIT_RAM_07(INIT_MAP[i*18432+2303:i*18432+2016]),
          .INIT_RAM_08(INIT_MAP[i*18432+2591:i*18432+2304]),
          .INIT_RAM_09(INIT_MAP[i*18432+2879:i*18432+2592]),
          .INIT_RAM_0A(INIT_MAP[i*18432+3167:i*18432+2880]),
          .INIT_RAM_0B(INIT_MAP[i*18432+3455:i*18432+3168]),
          .INIT_RAM_0C(INIT_MAP[i*18432+3743:i*18432+3456]),
          .INIT_RAM_0D(INIT_MAP[i*18432+4031:i*18432+3744]),
          .INIT_RAM_0E(INIT_MAP[i*18432+4319:i*18432+4032]),
          .INIT_RAM_0F(INIT_MAP[i*18432+4607:i*18432+4320]),
          .INIT_RAM_10(INIT_MAP[i*18432+4895:i*18432+4608]),
          .INIT_RAM_11(INIT_MAP[i*18432+5183:i*18432+4896]),
          .INIT_RAM_12(INIT_MAP[i*18432+5471:i*18432+5184]),
          .INIT_RAM_13(INIT_MAP[i*18432+5759:i*18432+5472]),
          .INIT_RAM_14(INIT_MAP[i*18432+6047:i*18432+5760]),
          .INIT_RAM_15(INIT_MAP[i*18432+6335:i*18432+6048]),
          .INIT_RAM_16(INIT_MAP[i*18432+6623:i*18432+6336]),
          .INIT_RAM_17(INIT_MAP[i*18432+6911:i*18432+6624]),
          .INIT_RAM_18(INIT_MAP[i*18432+7199:i*18432+6912]),
          .INIT_RAM_19(INIT_MAP[i*18432+7487:i*18432+7200]),
          .INIT_RAM_1A(INIT_MAP[i*18432+7775:i*18432+7488]),
          .INIT_RAM_1B(INIT_MAP[i*18432+8063:i*18432+7776]),
          .INIT_RAM_1C(INIT_MAP[i*18432+8351:i*18432+8064]),
          .INIT_RAM_1D(INIT_MAP[i*18432+8639:i*18432+8352]),
          .INIT_RAM_1E(INIT_MAP[i*18432+8927:i*18432+8640]),
          .INIT_RAM_1F(INIT_MAP[i*18432+9215:i*18432+8928]),
          .INIT_RAM_20(INIT_MAP[i*18432+9503:i*18432+9216]),
          .INIT_RAM_21(INIT_MAP[i*18432+9791:i*18432+9504]),
          .INIT_RAM_22(INIT_MAP[i*18432+10079:i*18432+9792]),
          .INIT_RAM_23(INIT_MAP[i*18432+10367:i*18432+10080]),
          .INIT_RAM_24(INIT_MAP[i*18432+10655:i*18432+10368]),
          .INIT_RAM_25(INIT_MAP[i*18432+10943:i*18432+10656]),
          .INIT_RAM_26(INIT_MAP[i*18432+11231:i*18432+10944]),
          .INIT_RAM_27(INIT_MAP[i*18432+11519:i*18432+11232]),
          .INIT_RAM_28(INIT_MAP[i*18432+11807:i*18432+11520]),
          .INIT_RAM_29(INIT_MAP[i*18432+12095:i*18432+11808]),
          .INIT_RAM_2A(INIT_MAP[i*18432+12383:i*18432+12096]),
          .INIT_RAM_2B(INIT_MAP[i*18432+12671:i*18432+12384]),
          .INIT_RAM_2C(INIT_MAP[i*18432+12959:i*18432+12672]),
          .INIT_RAM_2D(INIT_MAP[i*18432+13247:i*18432+12960]),
          .INIT_RAM_2E(INIT_MAP[i*18432+13535:i*18432+13248]),
          .INIT_RAM_2F(INIT_MAP[i*18432+13823:i*18432+13536]),
          .INIT_RAM_30(INIT_MAP[i*18432+14111:i*18432+13824]),
          .INIT_RAM_31(INIT_MAP[i*18432+14399:i*18432+14112]),
          .INIT_RAM_32(INIT_MAP[i*18432+14687:i*18432+14400]),
          .INIT_RAM_33(INIT_MAP[i*18432+14975:i*18432+14688]),
          .INIT_RAM_34(INIT_MAP[i*18432+15263:i*18432+14976]),
          .INIT_RAM_35(INIT_MAP[i*18432+15551:i*18432+15264]),
          .INIT_RAM_36(INIT_MAP[i*18432+15839:i*18432+15552]),
          .INIT_RAM_37(INIT_MAP[i*18432+16127:i*18432+15840]),
          .INIT_RAM_38(INIT_MAP[i*18432+16415:i*18432+16128]),
          .INIT_RAM_39(INIT_MAP[i*18432+16703:i*18432+16416]),
          .INIT_RAM_3A(INIT_MAP[i*18432+16991:i*18432+16704]),
          .INIT_RAM_3B(INIT_MAP[i*18432+17279:i*18432+16992]),
          .INIT_RAM_3C(INIT_MAP[i*18432+17567:i*18432+17280]),
          .INIT_RAM_3D(INIT_MAP[i*18432+17855:i*18432+17568]),
          .INIT_RAM_3E(INIT_MAP[i*18432+18143:i*18432+17856]),
          .INIT_RAM_3F(INIT_MAP[i*18432+18431:i*18432+18144]),

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
          .DIB(18'b0),
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

  assign map_mem_ad[3] = {3'b111, pixel_mem_addr_i};
  assign map_mem_ad[4] = {3'b110, pixel_mem_addr_i};
  assign map_mem_ad[5] = {3'b101, pixel_mem_addr_i};
  assign pixel_mem_data_o = {map_mem_out[3][7:0], map_mem_out[4][7:0], map_mem_out[5][7:0]};

  logic [4:0] map_mem_bank_selector;
  always_ff @(posedge clk_i) begin
    if (update_color_upd_i | update_map_upd_i) begin
      map_mem_done_o <= 0;
    end else begin
      map_mem_done_o <= map_mem_fetch_i;
      map_mem_bank_selector <= map_mem_addr_i[12:8];
    end
  end

  logic [1:0] select_val;
  always_comb begin
    case (map_mem_bank_selector)
      5'b00000, 5'b00001, 5'b00010, 5'b00011, 5'b00100, 5'b00101, 5'b00110: select_val = 2'b00;
      5'b00111, 5'b01000, 5'b01001, 5'b01010, 5'b01011, 5'b01100, 5'b01101: select_val = 2'b01;
      5'b01110, 5'b01111, 5'b10000, 5'b10001, 5'b10010, 5'b10011, 5'b10100: select_val = 2'b10;
      default: select_val = 2'b11;
    endcase
  end

  assign map_mem_data_o = 
    select_val == 2'b00 ? map_mem_out[0] :
    select_val == 2'b01 ? map_mem_out[1] :
    select_val == 2'b10 ? map_mem_out[2] :
    '0
  ;


  always_comb begin
    map_mem_write[0] = 0;
    map_mem_write[1] = 0;
    map_mem_write[2] = 0;

    if (update_color_upd_i) begin
      map_mem_ad[0] = {3'b111, update_color_idx_i};
      map_mem_ad[1] = {3'b110, update_color_idx_i};
      map_mem_ad[2] = {3'b101, update_color_idx_i};

      map_mem_write[0] = 1;
      map_mem_write[1] = 1;
      map_mem_write[2] = 1;
    end else if (update_map_upd_i) begin
      map_mem_ad[0] = {update_map_x_i[4:0], update_map_y_i};
      map_mem_ad[1] = {update_map_x_i[4:0], update_map_y_i};
      map_mem_ad[2] = {update_map_x_i[4:0], update_map_y_i};

      case (update_map_x_i[6:2])
        5'b00000, 5'b00001, 5'b00010, 5'b00011, 5'b00100, 5'b00101, 5'b00110: map_mem_write[0] = 1;
        5'b00111, 5'b01000, 5'b01001, 5'b01010, 5'b01011, 5'b01100, 5'b01101: map_mem_write[1] = 1;
        5'b01110, 5'b01111, 5'b10000, 5'b10001, 5'b10010, 5'b10011, 5'b10100: map_mem_write[2] = 1;
        default: begin
        end
      endcase
    end else begin
      map_mem_ad[0] = map_mem_addr_i[10:0];
      map_mem_ad[1] = map_mem_addr_i[10:0];
      map_mem_ad[2] = map_mem_addr_i[10:0];

    end
  end


  assign map_mem_in[0] = update_map_upd_i ? update_map_val_i : {1'b0, update_color_val_i[23:16]};
  assign map_mem_in[1] = update_map_upd_i ? update_map_val_i : {1'b0, update_color_val_i[15:8]};
  assign map_mem_in[2] = update_map_upd_i ? update_map_val_i : {1'b0, update_color_val_i[7:0]};
endmodule
