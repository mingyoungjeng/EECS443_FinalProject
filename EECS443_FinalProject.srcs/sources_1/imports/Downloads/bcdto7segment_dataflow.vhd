----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2021 09:59:12 AM
-- Design Name: 
-- Module Name: bcdto7segment_dataflow - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcdto7segment_dataflow is
    Port ( x : in STD_LOGIC_VECTOR (3 downto 0);
           AN : out STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end bcdto7segment_dataflow;

architecture Behavioral of bcdto7segment_dataflow is
signal data: std_logic_vector(6 downto 0) := (others => '0');

begin
AN(0) <= '0';
AN(1) <= '1';
AN(2) <= '1';
AN(3) <= '1';
AN(4) <= '1';
AN(5) <= '1';
AN(6) <= '1';
AN(7) <= '1';

seg <= data;

p0: process (x)
begin
    case (x) is
        when "0000" => data <= "1000000";
        when "0001" => data <= "1111001";
        when "0010" => data <= "0100100";
        when "0011" => data <= "0110000";
        when "0100" => data <= "0011001";
        when "0101" => data <= "0010010";
        when "0110" => data <= "0000010";
        when "0111" => data <= "1111000";
        when "1000" => data <= "0000000";
        when "1001" => data <= "0010000";
        when "1010" => data <= "0001000";
        when "1011" => data <= "0000011";
        when "1100" => data <= "1000110";
        when "1101" => data <= "0100001";
        when "1110" => data <= "0000110";
        when "1111" => data <= "0001110";
        
    end case;
end process;



end Behavioral;
