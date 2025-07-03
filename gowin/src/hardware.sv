module hardware (
    input         clk,
    input         rstn,
    input         rxd,
    output        txd,
    input         user_btn,
    output [ 5:0] leds,
    inout  [31:7] gpio
);

    logic clk_12mhz;
    PLL pll(clk_12mhz, clk);

    logic [31:0] gpio_out, gpio_in, gpio_en;

    top top (
        .clk      (clk_12mhz),
        .rstn     (rstn),
        .rxd      (rxd),
        .txd      (txd),
        .gpio_en  (gpio_en),
        .gpio_in  (gpio_in),
        .gpio_out (gpio_out)
    );


    generate
        // Outputs -- LEDs
        for (genvar i = 0; i < 6; i++) begin
            assign gpio_in[i] = gpio_out[i];
            assign leds[i] = !gpio_out[i];
        end

        // Inputs -- User Button
        assign gpio_in[6] = user_btn;

        // Inouts -- GPIOs
        for (genvar i = 7; i < 32; i++) begin
            assign gpio[i] = gpio_en[i] ? gpio_out[i] : 'z;
            assign gpio_in[i] = gpio[i];
        end
    endgenerate

endmodule
