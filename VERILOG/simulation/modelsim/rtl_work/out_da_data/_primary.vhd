library verilog;
use verilog.vl_types.all;
entity out_da_data is
    port(
        clk_in          : in     vl_logic;
        rst_n           : in     vl_logic;
        key             : in     vl_logic_vector(2 downto 0);
        DA_value        : out    vl_logic_vector(13 downto 0);
        DA_clk          : out    vl_logic;
        DA_reset_n      : out    vl_logic
    );
end out_da_data;
