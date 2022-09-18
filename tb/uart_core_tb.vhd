---------------------------------------------
-- data        : 16.01.2020
-- author      : sboldenko
--
-- description : COEFF_BAUDRATE = Faclk/Fuart
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity uart_core_tb is
generic
(
    COEFF_BAUDRATE : std_logic_vector(15 downto 0):= x"0036"
);
end uart_core_tb;

architecture behavioral of uart_core_tb is

    constant aclk_period : time := 20 ns; --50 MHz

    component uart_core_top
    generic
    (
        COEFF_BAUDRATE : std_logic_vector(15 downto 0)
    );
    port
    (
        aclk         : in  std_logic;
        areset       : in  std_logic;

        s_axis_valid : in  std_logic;
        s_axis_data  : in  std_logic_vector(7 downto 0);
        s_axis_ready : out std_logic;

        m_axis_valid : out std_logic;
        m_axis_data  : out std_logic_vector(7 downto 0);

        tx           : out std_logic;
        rx           : in  std_logic
    );
    end component;

    signal aclk           : std_logic                    := '0';
    signal areset         : std_logic                    := '0';

    signal s_axis_valid   : std_logic;
    signal s_axis_data    : std_logic_vector(7 downto 0);
    signal s_axis_ready   : std_logic;

    signal m_axis_valid   : std_logic;
    signal m_axis_data    : std_logic_vector(7 downto 0);

    signal tx             : std_logic;
    signal rx             : std_logic;

    signal word_gen_pulse : std_logic                    := '0';
    signal word_gen       : std_logic_vector(7 downto 0) := (others => '0'); 

begin

    DUT_inst: uart_core_top
    generic map
    (
        COEFF_BAUDRATE => COEFF_BAUDRATE
    )
    port map 
    (
        aclk         => aclk,
        areset       => areset,
        s_axis_valid => s_axis_valid,
        s_axis_data  => s_axis_data,
        s_axis_ready => s_axis_ready,
        m_axis_valid => m_axis_valid,
        m_axis_data  => m_axis_data,
        tx           => tx,
        rx           => rx
    );

    CLK_GENERATE: process
    begin
        aclk <= '0';
        wait for aclk_period/2;
        aclk <= '1';
        wait for aclk_period/2;
    end process;

    RESET_GENERATE: process
    begin
        areset <= '0';
        wait for 100 us;
        areset <= '1';
        wait for 1 us;
        areset <= '0';
        wait;
    end process;

    WORD_GENERATE: process(aclk)
    begin
        if rising_edge(aclk) then
            if (s_axis_ready = '1') then
                word_gen       <= word_gen + '1';
                word_gen_pulse <= '1';
                s_axis_data    <= word_gen;
            else
                word_gen_pulse <= '0';
            end if;

            if (word_gen_pulse = '1' and s_axis_ready = '0') then
                word_gen <= word_gen - '1';
            end if;
        end if;
    end process;

    rx           <= tx;
    s_axis_valid <= s_axis_ready and word_gen_pulse;

end behavioral;