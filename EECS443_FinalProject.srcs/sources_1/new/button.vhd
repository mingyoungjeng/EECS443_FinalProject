----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2021 03:13:17 PM
-- Design Name: 
-- Module Name: button - Behavioral
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

entity button is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           edge : out STD_LOGIC
           );
end button;

architecture Behavioral of button is

signal state: std_logic;

begin

process (clk, btn)
begin
    if (clk'event and clk = '1') then
        edge <= '0';
        if (state = '0' and btn = '1') then
            edge <= '1';
        end if;
        
        state <= btn;
    end if;
end process;

end Behavioral;
