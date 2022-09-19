
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity uart_test_top is
generic
(
    --COEFF_BAUDRATE : std_logic_vector(15 downto 0) := x"1388" -- 9600
    --COEFF_BAUDRATE : std_logic_vector(15 downto 0) := x"01A0" -- 115200
    COEFF_BAUDRATE : std_logic_vector(15 downto 0) := x"0034" -- 921600
);
port
(
    -- system signals
    system_clk    : in  std_logic;
    system_resetn : in  std_logic;
    -- uart interface
    uart_rx       : in  std_logic;
    uart_tx       : out std_logic
);
end uart_test_top;

architecture behavioral of uart_test_top is

    component pll
    port
    (
        clki  : in  std_logic;
        clkop : out std_logic;
        lock  : out std_logic
    );
    end component;

    component uart_test_tx_generator
    port
    (
        -- system signals
        clk_i        : in  std_logic;
        reset_i      : in  std_logic;
        -- axi-stream
        m_axis_valid : out std_logic;
        m_axis_data  : out std_logic_vector(7 downto 0);
        m_axis_ready : in  std_logic
    );
    end component;

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

    signal clk_48mhz      : std_logic;
    signal resetn         : std_logic;
    signal reset          : std_logic;

    signal s_axis_valid   : std_logic;
    signal s_axis_data    : std_logic_vector(7 downto 0);
    signal s_axis_ready   : std_logic;

    signal m_axis_valid   : std_logic;
    signal m_axis_data    : std_logic_vector(7 downto 0);

begin

    pll_inst: pll
    port map
    (
        CLKI  => system_clk,
        CLKOP => clk_48mhz,
        LOCK  => resetn
    );

    reset <= (not resetn) or (not system_resetn);

    uart_test_tx_generator_inst: uart_test_tx_generator
    port map
    (
        -- system signals
        clk_i        => clk_48mhz,
        reset_i      => reset,
        -- axi-stream
        m_axis_valid => s_axis_valid,
        m_axis_data  => s_axis_data,
        m_axis_ready => s_axis_ready
    );

    uart_core_top_inst: uart_core_top
    generic map
    (
        COEFF_BAUDRATE => COEFF_BAUDRATE
    )
    port map 
    (
        aclk         => clk_48mhz,
        areset       => reset,
        s_axis_valid => s_axis_valid,
        s_axis_data  => s_axis_data,
        s_axis_ready => s_axis_ready,
        m_axis_valid => m_axis_valid,
        m_axis_data  => m_axis_data,
        tx           => uart_tx,
        rx           => uart_rx
    );

end behavioral;