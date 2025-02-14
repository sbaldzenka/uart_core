-------------------------------------------
-- data:   16.01.2020
-- author: sbaldzenka
-- e-mail: venera.electronica@gmail.com
-- others: COEFF_BAUDRATE = Faclk/Fuart
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity uart_core_top is
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
end uart_core_top;

architecture behavioral of uart_core_top is

    component uart_core_tx_module is
    generic
    (
        COEFF_BAUDRATE : std_logic_vector(15 downto 0)
    );
    port
    (
        aclk     : in  std_logic;
        areset   : in  std_logic;
        valid_in : in  std_logic;
        data_in  : in  std_logic_vector(7 downto 0);
        ready    : out std_logic;
        tx_out   : out std_logic
    );
    end component;

    component uart_core_rx_module is
    generic
    (
        COEFF_BAUDRATE : std_logic_vector(15 downto 0)
    );
    port
    (
        aclk      : in  std_logic;
        areset    : in  std_logic;
        valid_out : out std_logic;
        data_out  : out std_logic_vector(7 downto 0);
        rx_in     : in  std_logic
    );
    end component;

begin

    uart_core_tx_module_inst: uart_core_tx_module
    generic map
    (
        COEFF_BAUDRATE => COEFF_BAUDRATE
    )
    port map
    (
        aclk     => aclk,
        areset   => areset,
        valid_in => s_axis_valid,
        data_in  => s_axis_data,
        ready    => s_axis_ready,
        tx_out   => tx
    );

    uart_core_rx_module_inst: uart_core_rx_module
    generic map
    (
        COEFF_BAUDRATE => COEFF_BAUDRATE
    )
    port map
    (
        aclk      => aclk,
        areset    => areset,
        valid_out => m_axis_valid,
        data_out  => m_axis_data,
        rx_in     => rx
    );

end behavioral;