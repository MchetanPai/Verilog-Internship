module tb_spi;

reg clock;
reg reset;
reg [7:0] data_in;
reg load_data;
wire done_send;
wire spi_clock;
wire spi_data;

spi uut (
    .clock(clock),
    .reset(reset),
    .data_in(data_in),
    .load_data(load_data),
    .done_send(done_send),
    .spi_clock(spi_clock),
    .spi_data(spi_data)
);

always #5 clock = ~clock; 

initial begin
    clock = 0;
    reset = 1;
    data_in = 8'b0;
    load_data =0;

    #20;
    reset = 0;

    #50;
    data_in = 8'b11000110;
    load_data = 1;

    #100;
    load_data = 0;

    wait(done_send == 1);
    $display("Data sent at time %t", $time);

    #200;

    $finish;
end

endmodule