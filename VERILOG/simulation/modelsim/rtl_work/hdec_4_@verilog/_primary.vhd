library verilog;
use verilog.vl_types.all;
entity hdec_4_Verilog is
    generic(
        word_size_in    : integer := 8;
        word_size_out   : integer := 20
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        X               : in     vl_logic_vector;
        Y               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of word_size_in : constant is 1;
    attribute mti_svvh_generic_type of word_size_out : constant is 1;
end hdec_4_Verilog;
