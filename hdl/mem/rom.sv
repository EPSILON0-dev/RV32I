module rom_512x32 (
    input         clk,
    input  [ 8:0] addr,
    output [31:0] data
);

    logic [31:0] rom_array [0:511];

    // DO NOT EDIT - GENERATED AUTOMATICALLY
    // --- AUTOGEN ---
    assign rom_array[0] = 32'hAABBCCDD;
    assign rom_array[1] = 32'h12345678;
    // --/ AUTOGEN /--

    reg [31:0] data_r;
    always_ff @(posedge clk) begin
        data_r <= rom_array[addr];
    end
    assign data = data_r;

endmodule
