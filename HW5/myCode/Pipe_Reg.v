module Pipe_Reg( clk_i, rst_n, data_i, data_o );

    parameter size = 0;

    input clk_i, rst_n;
    input [size-1:0] data_i;
    output reg [size-1:0] data_o;

    always @ (posedge clk_i or posedge rst_n) begin
        if (rst_n == 0) begin
            data_o <= 1'd0;
        end
        else begin
            data_o <= data_i;
        end
    end

endmodule     





                    
                    
