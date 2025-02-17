module hardware (
    input        clk,
    input        rstn,
    input        rxd,
    output       txd,
    inout [15:0] gpio
);

    logic clk_12mhz;
    PLL pll(clk_12mhz, clk);

    logic [15:0] gpio_out, gpio_en;
    top top (
        .clk      (clk_12mhz),
        .rstn     (rstn),
        .rxd      (rxd),
        .txd      (txd),
        .gpio_en  (gpio_en),
        .gpio_in  (gpio),
        .gpio_out (gpio_out)
    );

    generate
        for (genvar i = 0; i < 16; i++) begin
            assign gpio[i] = gpio_en[i] ? gpio_out[i] : 'z;
        end
    endgenerate

endmodule
