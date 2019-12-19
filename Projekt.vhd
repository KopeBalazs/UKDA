----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2019 02:08:40 PM
-- Design Name: 
-- Module Name: Projekt - Behavioral
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
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Projekt is
    Port ( 
           SDATA : in STD_LOGIC;
           SCLK : out  STD_LOGIC;
           CS: out STD_LOGIC;
           
           RESET: in STD_LOGIC;
           ZYBO_CLK: in STD_LOGIC;
           ROLI_START : in STD_LOGIC;
           X_VALUE_REG : out STD_LOGIC_VECTOR (11 downto 0));
end Projekt;

architecture Behavioral of Projekt is

    type cases is (RDY, INITA, INITB, CLKL, READ, CLKH, CLKHINIT, QUIETINIT, QUIET);
    signal actual_case: cases;
    signal next_case: cases;
    
    signal i_counter: STD_LOGIC_VECTOR(4 downto 0);
    signal j_counter: STD_LOGIC_VECTOR(6 downto 0);
    signal i_counter_next: STD_LOGIC_VECTOR(4 downto 0);
    signal j_counter_next: STD_LOGIC_VECTOR(6 downto 0);
        
    signal sdata_local : STD_LOGIC;
    signal sclk_local : STD_LOGIC;
    signal sclk_local_next : STD_LOGIC;
    signal cs_local : STD_LOGIC;
    signal cs_local_next : STD_LOGIC;
    signal reset_local : STD_LOGIC;
    signal zybo_clk_local : STD_LOGIC;
    signal roli_start_local : STD_LOGIC;
    signal x_value_r_local : STD_LOGIC_VECTOR(11 downto 0);
    signal x_value_r_local_next : STD_LOGIC_VECTOR(11 downto 0);
    
begin

State_R:process(zybo_clk_local, reset_local)
begin
    if reset_local='1' then
        actual_case <=RDY;
        i_counter <= (others => '0');
        j_counter <= (others => '0');
    elsif zybo_clk_local'event and zybo_clk_local='1' then
        actual_case <= next_case;
    end if;
end process State_R;
    
next_case_log: process(actual_case, roli_start_local, i_counter, j_counter)
begin
    case(actual_case) is
        when RDY =>
            if roli_start_local='1'
                then
                    next_case <= INITA;
                else
                    next_case <= RDY;
            end if;
            
        when INITA =>
            next_case <= INITB;
        
        when INITB =>
            next_case <= CLKL;
            
        when CLKL =>
            if i_counter > 0 then
                next_case <= CLKL;
            else
                next_case <= READ;
            end if;
            
        when READ =>
            next_case <= CLKH;
            
        when CLKH =>
            if i_counter >0 then
                next_case <= CLKH;
            else
                next_case <= CLKHINIT;
            end if;
            
         when CLKHINIT =>
            if j_counter >0 then
                next_case <= CLKL;
            else
                next_case <= QUIETINIT;
            end if;
            
         when QUIETINIT =>
            next_case <= QUIET;
        
         when QUIET =>
            if i_counter>0 then
                next_case <= QUIET;
            else
                next_case <= RDY;
            end if;
    end case;
end process next_case_log;

WITH actual_case SELECT
    cs_local_next <= '1' WHEN RDY,
                     '1' WHEN QUIET,
                     '0' WHEN others;
                
WITH actual_case SELECT
    sclk_local_next <= '0' WHEN CLKL,
                       '0' WHEN QUIETINIT,
                       '1' WHEN others;
                  
WITH actual_case SELECT
    x_value_r_local_next <= (others => '0') WHEN RDY,
                            (others => '0') WHEN INITA,
                            (others => '0') WHEN INITB,
                            x_value_r_local WHEN CLKL,
                            x_value_r_local WHEN CLKH,
                            x_value_r_local WHEN CLKHINIT,
                            x_value_r_local WHEN QUIETINIT,
                            x_value_r_local WHEN QUIET,
                            x_value_r_local(14 downto 0) & sdata_local  WHEN READ;
                            
WITH actual_case SELECT
    i_counter_next <= (others => '0') WHEN RDY,
                      (others => '0') WHEN INITA,
                      "00101" WHEN INITB,
                      "00101" WHEN CLKHINIT,
                      "00101" WHEN QUIETINIT,
                      i_counter - 1 WHEN CLKL,
                      i_counter - 1 WHEN CLKH,
                      i_counter - 1 WHEN QUIET,
                      "00011" WHEN READ;
                      
WITH actual_case SELECT
    j_counter_next <= (others => '0') WHEN RDY,
                      (others => '0') WHEN INITA,
                      "01111" WHEN INITB,
                      "01111" WHEN QUIETINIT,
                      j_counter-1 WHEN CLKHINIT,
                      j_counter WHEN others;
                      















end Behavioral;
