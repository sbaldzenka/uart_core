
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity uart_test_tx_generator is
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
end uart_test_tx_generator;

architecture behavioral of uart_test_tx_generator is

    type states is
    (
        S_IDLE,
        S_WAIT,
        S_PAUSE,
        S_TX
    );

    signal wait_counter : std_logic_vector(15 downto 0);
    signal state        : states;

begin

    process(clk_i, reset_i)
    begin
        if (reset_i = '1') then
            wait_counter <= (others => '0');
            m_axis_valid <= '0';
            m_axis_data  <= (others => '0');
            state        <= S_WAIT;
        elsif rising_edge(clk_i) then
            case state is
                when S_WAIT =>
                    wait_counter <= wait_counter + '1';

                    if (wait_counter = x"FFFF") then
                        state <= S_IDLE;
                    end if;
                when S_IDLE =>
                    if (m_axis_ready = '1') then
                        m_axis_valid <= '1';
                        m_axis_data  <= x"52";
                        state        <= S_PAUSE;
                    end if;
                when S_PAUSE =>
                    m_axis_valid <= '0';
                    m_axis_data  <= x"00";
                    state        <= S_TX;
                when S_TX =>
                    if (m_axis_ready = '1') then
                        state <= S_IDLE;
                    end if;
                when others => null;
            end case;
        end if;
    end process;

end behavioral;