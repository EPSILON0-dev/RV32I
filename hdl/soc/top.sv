// Memory map
// 0x00000 - 0x00200 - Bootloader area
// 0x08000 - 0x10000 - User code
// 0x20000 - (RW) GPIO direction reg (gpio_en)
// 0x20004 - (R-) GPIO in reg (gpio_in)
// 0x20008 - (RW) GPIO out reg (gpio_out)
// 0x20010 - (RW) UART div reg
// 0x20014 - (RW) UART data reg
// 0x20018 - (R-) UART wait reg
// 0x20020 - (R-) Timer reg

`define BLD_START_ADDR 32'h00000
`define BLD_END_ADDR   32'h00200
`define CCM_START_ADDR 32'h08000
`define CCM_END_ADDR   32'h10000
`define GPIO_DIR_ADDR  32'h20000
`define GPIO_IN_ADDR   32'h20004
`define GPIO_OUT_ADDR  32'h20008
`define UART_DIV_ADDR  32'h20010
`define UART_DAT_ADDR  32'h20014
`define UART_WAIT_ADDR 32'h20018
`define TIMER_ADDR     32'h20020

// verilator lint_off ALL
module top (
    input         clk,
    input         rstn,
    input         rxd,
    output        txd,
    input  [15:0] gpio_in,
    output [15:0] gpio_out,
    output [15:0] gpio_en
);

    // CPU Module
    logic [31:0] cpu_addr;
    logic [31:0] cpu_data_i;
    logic [31:0] cpu_data_o;
    logic [ 3:0] cpu_we;
    CPU cpu (
        .Clk          (clk),
        .Reset        (!rstn),
        .Address      (cpu_addr),
        .Input_Data   (cpu_data_i),
        .Output_Data  (cpu_data_o),
        .Write_Enable (cpu_we)
    );

    // Bootloader module
    logic [31:0] bld_dat_o;
    logic [ 8:0] bld_addr;
    rom_512x32 bld_rom (
        .clk  (!clk),
        .addr (bld_addr),
        .data (bld_dat_o)
    );
    assign bld_addr = cpu_addr[10:2];

    // Closely Coupled Memory Module
    logic [ 3:0] ccm_we;
    logic [12:0] ccm_addr;
    reg   [31:0] ccm_dat_o;
    reg   [ 7:0] ccm_arr_3 [0:8191];
    reg   [ 7:0] ccm_arr_2 [0:8191];
    reg   [ 7:0] ccm_arr_1 [0:8191];
    reg   [ 7:0] ccm_arr_0 [0:8191];
    always @(negedge clk) begin
        if (ccm_we[3]) ccm_arr_3[ccm_addr] <= cpu_data_o[31:24];
        if (ccm_we[2]) ccm_arr_2[ccm_addr] <= cpu_data_o[23:16];
        if (ccm_we[1]) ccm_arr_1[ccm_addr] <= cpu_data_o[15: 8];
        if (ccm_we[0]) ccm_arr_0[ccm_addr] <= cpu_data_o[ 7: 0];
        ccm_dat_o <= { ccm_arr_3[ccm_addr], ccm_arr_2[ccm_addr],
            ccm_arr_1[ccm_addr], ccm_arr_0[ccm_addr] };
    end
    assign ccm_addr = cpu_addr[14:2];

    // UART module
    logic [ 3:0] uart_div_we;
    logic [31:0] uart_div_o;
    logic        uart_dat_we;
    logic        uart_dat_re;
    logic [31:0] uart_dat_o;
    logic        uart_dat_wait;
    simpleuart uart (
	    .clk          (!clk),
	    .resetn       (rstn),
	    .ser_tx       (txd),
	    .ser_rx       (rxd),
	    .reg_div_we   (uart_div_we),
	    .reg_div_di   (cpu_data_o),
	    .reg_div_do   (uart_div_o),
	    .reg_dat_we   (uart_dat_we),
	    .reg_dat_re   (uart_dat_re),
	    .reg_dat_di   (cpu_data_o),
	    .reg_dat_do   (uart_dat_o),
	    .reg_dat_wait (uart_dat_wait)
    );

    // Timer module
    reg [31:0] timer_r;
    always @(posedge clk) begin
        if (!rstn) begin
            timer_r <= 0;
        end else begin
            timer_r <= timer_r + 32'd1;
        end
    end

    // GPIO module
    reg [15:0] gpio_en_r;
    reg [15:0] gpio_out_r;
    logic gpio_en_we;
    logic gpio_out_we;
    always @(negedge clk) begin
        if (!rstn) begin
            gpio_en_r <= 0;
            gpio_out_r <= 0;
        end else begin
            if (gpio_en_we) gpio_en_r <= cpu_data_o[15:0];
            if (gpio_out_we) gpio_out_r <= cpu_data_o[15:0];
        end
    end

    // Memory signal generator
    logic gpio_en_re;
    logic gpio_in_re;
    logic gpio_out_re;
    logic uart_div_re;
    logic uart_wait_re;
    logic timer_re;
    logic ccm_re;
    logic bld_re;

    assign gpio_en_re   = (cpu_addr == `GPIO_DIR_ADDR);
    assign gpio_in_re   = (cpu_addr == `GPIO_IN_ADDR);
    assign gpio_out_re  = (cpu_addr == `GPIO_OUT_ADDR);
    assign uart_div_re  = (cpu_addr == `UART_DIV_ADDR);
    assign uart_wait_re = (cpu_addr == `UART_WAIT_ADDR);
    assign timer_re     = (cpu_addr == `TIMER_ADDR);
    assign ccm_re       = (cpu_addr >= `CCM_START_ADDR) &&
        (cpu_addr < `CCM_END_ADDR);
    assign bld_re       = (cpu_addr >= `BLD_START_ADDR) &&
        (cpu_addr < `BLD_END_ADDR);

    assign gpio_en_we  = gpio_en_re && (cpu_we == 4'hf);
    assign gpio_out_we = gpio_out_re && (cpu_we == 4'hf);
    assign uart_div_we = {4{uart_div_re}} & cpu_we;
    assign uart_dat_we = (cpu_addr == `UART_DAT_ADDR) && (cpu_we == 4'hf);
    assign ccm_we      = {4{ccm_re}} & cpu_we;

    // Very special read signal generator
    reg [31:0] prev_addr_r;
    always @(negedge clk) begin
        if (!rstn) begin
            prev_addr_r <= 0;
        end else begin
            prev_addr_r <= cpu_addr;
        end
    end
    assign uart_dat_re = (prev_addr_r == `UART_DAT_ADDR) &&
        (cpu_addr != `UART_DAT_ADDR);

    // CPU Read Data Selector
    assign cpu_data_i =
        gpio_en_re   ? { 16'd0, gpio_en_r }     :
        gpio_in_re   ? { 16'd0, gpio_in }       :
        gpio_out_re  ? { 16'd0, gpio_out_r }    :
        uart_div_re  ? uart_div_o               :
        uart_wait_re ? { 31'd0, uart_dat_wait } :
        timer_re     ? timer_r                  :
        ccm_re       ? ccm_dat_o                :
        bld_re       ? bld_dat_o                :
        0;

    // Output assignments
    assign gpio_en = gpio_en_r;
    assign gpio_out = gpio_out_r;

endmodule
