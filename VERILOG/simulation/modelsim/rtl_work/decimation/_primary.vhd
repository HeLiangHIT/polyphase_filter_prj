library verilog;
use verilog.vl_types.all;
entity decimation is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        data_out        : out    vl_logic_vector(7 downto 0);
        clk_data        : out    vl_logic;
        fir_out         : out    vl_logic_vector(7 downto 0);
        clk_fir         : out    vl_logic
    );
end decimation;
