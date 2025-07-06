module spi(
    input wire [7:0] data_in,
    input wire clock,
    input wire reset,
    input wire load_data,
    output wire spi_clock,
    output reg done_send,
    output reg spi_data
);

reg [2:0] counter;
reg clock_enable;
reg clock_10;

assign spi_clock=(clock_enable)?clock_10:1'b0;


typedef enum logic [1:0] {
    IDLE = 2'd0,
    SEND = 2'd1,
    DONE = 2'd2
} state_t;

state_t state;

reg [7:0] shiftreg;
reg [2:0] bitcount;

always@(posedge clock) begin
    if(reset) begin
        counter<=0;
        clock_10<=0;
    end
    else begin
        if(counter<4) 
            counter<=counter+1;
        else begin
            counter=0;
            clock_10=~clock_10;
        end
    end
end

always@(negedge clock_10 or posedge reset)begin
    if (reset) begin
        state <= IDLE;
        done_send <= 0;
        clock_enable <= 0;
        spi_data <= 1'b1;
        shiftreg <= 0;
        bitcount <= 0;
    end
    else begin
         case (state)
            IDLE: begin
                done_send <= 0;
                clock_enable<= 0;
                if (load_data) begin
                    shiftreg <= data_in;
                    bitcount <= 0;
                    state <= SEND;
                end
            end

            SEND: begin
                clock_enable<= 1;
                spi_data <= shiftreg[7];
                shiftreg <= {shiftreg[6:0], 1'b0};
                if (bitcount < 7) begin
                    bitcount <= bitcount + 1;
                    state <= SEND;
                end
                else
                    state <= DONE;
            end

            DONE: begin
                clock_enable <= 0;
                done_send <= 1;
                if (!load_data) begin
                    done_send <= 1;
                    clock_enable<=0;
                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end
endmodule
