library verilog;
use verilog.vl_types.all;
entity wave_add is
    generic(
        fword1          : vl_logic_vector(0 to 9) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        fword2          : vl_logic_vector(0 to 9) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi1, Hi0, Hi0);
        pword1          : vl_logic_vector(0 to 9) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        pword2          : vl_logic_vector(0 to 9) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        aword1          : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        aword2          : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        data_out        : out    vl_logic_vector(7 downto 0);
        data_change     : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of fword1 : constant is 1;
    attribute mti_svvh_generic_type of fword2 : constant is 1;
    attribute mti_svvh_generic_type of pword1 : constant is 1;
    attribute mti_svvh_generic_type of pword2 : constant is 1;
    attribute mti_svvh_generic_type of aword1 : constant is 1;
    attribute mti_svvh_generic_type of aword2 : constant is 1;
end wave_add;
