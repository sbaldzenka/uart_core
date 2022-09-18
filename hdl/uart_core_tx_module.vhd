-------------------------------------------
-- data:   16.01.2020
-- author: sboldenko
--
-- others: COEFF_BAUDRATE = Faclk/Fuart
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity uart_core_tx_module is
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
end uart_core_tx_module;

architecture behavioral of uart_core_tx_module is
    
    signal buffer_word : std_logic_vector(07 downto 0) := (others => '0');
    signal counter     : std_logic_vector(15 downto 0) := (others => '0');
    signal time_ok     : std_logic                     := '0';
    
    type states is
    (
        IDLE,
        START,
        SEND_BIT0,
        SEND_BIT1,
        SEND_BIT2,
        SEND_BIT3,
        SEND_BIT4,
        SEND_BIT5,
        SEND_BIT6,
        SEND_BIT7,
        STOP
    );

    signal state : states := IDLE;

begin

    process(aclk, areset)
    begin
        if (areset = '1') then
            buffer_word <= x"00";
        elsif rising_edge(aclk) then
            if (valid_in = '1') then
                buffer_word <= data_in;
            end if;
        end if;
    end process;

    process(aclk, areset)
    begin
        if (areset = '1') then
            counter <= x"0000";
            time_ok <= '0';
        elsif rising_edge(aclk) then
            if (state /= IDLE) then
                counter <= counter + '1';

                if (counter = COEFF_BAUDRATE-1) then
                    counter <= x"0000";
                    time_ok <= '1';
                else
                    time_ok <= '0';
                end if; 
            else
                counter <= x"0000";
            end if;
        end if;
    end process;

    process(aclk, areset)
    begin
        if (areset = '1') then
            ready <= '1';
            state <= IDLE;
        elsif rising_edge(aclk) then
            case state is
                when IDLE =>
                    if (valid_in = '0') then
                        ready <= '1';
                        tx_out <= '1';
                    else
                        ready <= '0';
                        state <= START;
                    end if;
                when START =>
                    if (time_ok = '0') then
                        tx_out <= '0';
                    else
                        state <= SEND_BIT0;
                    end if; 
                when SEND_BIT0 =>
                    if (time_ok = '0') then
                        tx_out <= buffer_word(0);
                    else
                        state <= SEND_BIT1;
                    end if; 
                when SEND_BIT1 =>
                    if (time_ok = '0') then
                        tx_out <= buffer_word(1);
                    else
                        state <= SEND_BIT2;
                    end if; 
                when SEND_BIT2 =>
                    if (time_ok = '0') then
                        tx_out <= buffer_word(2);
                    else
                        state <= SEND_BIT3;
                    end if;
                when SEND_BIT3 =>
                    if (time_ok = '0') then
                        tx_out <= buffer_word(3);
                    else
                        state <= SEND_BIT4;
                    end if;
                when SEND_BIT4 =>
                    if (time_ok = '0') then
                        tx_out <= buffer_word(4);
                    else
                        state <= SEND_BIT5;
                    end if; 
                when SEND_BIT5 =>
                    if (time_ok = '0') then
                        tx_out <= buffer_word(5);
                    else
                        state <= SEND_BIT6;
                    end if; 
                when SEND_BIT6 =>
                    if (time_ok = '0') then
                        tx_out <= buffer_word(6);
                    else
                        state <= SEND_BIT7;
                    end if;
                when SEND_BIT7 =>
                    if (time_ok = '0') then
                        tx_out <= buffer_word(7);
                    else
                        state <= STOP;
                    end if;
                when STOP =>
                    if (time_ok = '0') then
                        tx_out <= '1';
                    else
                        state <= IDLE;
                    end if;
                when others => null;
            end case;
        end if;
    end process;
    
end behavioral;