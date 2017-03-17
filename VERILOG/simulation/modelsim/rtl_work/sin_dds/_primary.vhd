library verilog;
use verilog.vl_types.all;
entity sin_dds is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        fword           : in     vl_logic_vector(9 downto 0);
        pword           : in     vl_logic_vector(9 downto 0);
        data_out        : out    vl_logic_vector(7 downto 0);
        data_change     : out    vl_logic
    );
end sin_dds;
