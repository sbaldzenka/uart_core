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

entity uart_core_rx_module is
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
end uart_core_rx_module;

architecture behavioral of uart_core_rx_module is

    signal counter     : std_logic_vector(15 downto 0) := (others => '0');
    signal time_ok     : std_logic                     := '0';
    signal get_value   : std_logic                     := '0';
    signal buffer_word : std_logic_vector(07 downto 0) := (others => '0');
    signal div_coff    : std_logic_vector(15 downto 0) := (others => '0');

    type states is
    (
        IDLE,
        START,
        TAKE_BIT0,
        TAKE_BIT1,
        TAKE_BIT2,
        TAKE_BIT3,
        TAKE_BIT4,
        TAKE_BIT5,
        TAKE_BIT6,
        TAKE_BIT7,
        STOP
    );

    signal state : states:= IDLE;

begin

    div_coff <= '0' & COEFF_BAUDRATE(15 downto 1);

    process(aclk, areset)
    begin
        if (areset = '1') then
            counter   <= x"0000";
            time_ok   <= '0';
            get_value <= '0';
        elsif rising_edge(aclk) then
            if (state /= IDLE) then
                
                counter <= counter + '1';
                
                if (counter = COEFF_BAUDRATE-1) then
                    counter <= x"0000";
                    time_ok <= '1';
                elsif (counter = div_coff) then 
                    get_value <= '1';
                else
                    time_ok   <= '0';
                    get_value <= '0';
                end if;
            else
                counter <= x"0000";
            end if;
        end if;
    end process;

    process(aclk, areset)
    begin
        if (areset = '1') then
            state     <= IDLE;
            valid_out <= '0';
            data_out  <= (others => '0');
        elsif rising_edge(aclk) then
            case state is
                when IDLE =>
                    if (rx_in = '0') then
                        state <= START;
                    end if;
                when START =>
                    if (time_ok = '1') then
                        state <= TAKE_BIT0;
                    end if;
                when TAKE_BIT0 =>
                    if (get_value = '1') then
                        buffer_word(0) <= rx_in;
                    end if;

                    if (time_ok = '1') then
                        state <= TAKE_BIT1;
                    end if;
                when TAKE_BIT1 =>
                    if (get_value = '1') then
                        buffer_word(1) <= rx_in;
                    end if;

                    if (time_ok = '1') then
                        state <= TAKE_BIT2;
                    end if;
                when TAKE_BIT2 =>
                    if (get_value = '1') then
                        buffer_word(2) <= rx_in;
                    end if;

                    if (time_ok = '1') then
                        state <= TAKE_BIT3;
                    end if;
                when TAKE_BIT3 =>
                    if (get_value = '1') then
                        buffer_word(3) <= rx_in;
                    end if;

                    if (time_ok = '1') then
                        state <= TAKE_BIT4;
                    end if;
                when TAKE_BIT4 =>
                    if (get_value = '1') then
                        buffer_word(4) <= rx_in;
                    end if;

                    if (time_ok = '1') then
                        state <= TAKE_BIT5;
                    end if;
                when TAKE_BIT5 =>
                    if (get_value = '1') then
                        buffer_word(5) <= rx_in;
                    end if;

                    if (time_ok = '1') then
                        state <= TAKE_BIT6;
                    end if;
                when TAKE_BIT6 =>
                    if (get_value = '1') then
                        buffer_word(6) <= rx_in;
                    end if;

                    if (time_ok = '1') then
                        state <= TAKE_BIT7;
                    end if; 
                when TAKE_BIT7 =>
                    if (get_value = '1') then
                        buffer_word(7) <= rx_in;
                    end if;

                    if (time_ok = '1') then
                        state <= STOP;
                    end if;
                when STOP =>
                    if (get_value = '1' and rx_in = '1') then
                        valid_out <= '1';
                        data_out  <= buffer_word;
                    else
                        valid_out <= '0';
                    end if;

                    if (time_ok = '1') then
                        state <= IDLE;
                    end if;
                when others => null;
            end case;
        end if;
    end process;

end behavioral;