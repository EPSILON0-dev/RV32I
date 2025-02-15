module hardware (
    input        clk,
    input        rstn,
    input        rxd,
    output       txd,
    inout [15:0] gpio
);

    /*
    reg [31:0] div_r = 0;
    reg clk_2hz = 0;
    always @(posedge clk) begin
        if (div_r >= 32'd6250000) begin
            clk_2hz <= !clk_2hz;
            div_r <= 0;
        end else begin
            div_r <= div_r + 32'd1;
        end
    end
    */

    logic [15:0] gpio_out, gpio_en;
    top top (
        .clk      (clk),
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
