----------------------------------------------------------------------------------
-- Students: Andrea Pérez and Léa Scheer 
-- 
-- Create Date: 25.11.2021 11:21:10
-- Module Name: ethernet - Behavioral
-- Project Name: TP Module Ethernet 
-- Design Name : Component Ethernet Module
-- Target Devices: BASYS 3
-- Description: VHDL code for Ethernet module. Transmission and reception are implemented. 
----------------------------------------------------------------------------------

-- Dependencies
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ethernet is
    Port ( RBYTEP : out STD_LOGIC;
           RCLEANP : out STD_LOGIC;
           RCVNGP : out STD_LOGIC;
           RDATAO : out STD_LOGIC_VECTOR (7 downto 0);
           RDONEP : out STD_LOGIC;
           RENABP : in STD_LOGIC;
           RSMATIP : out STD_LOGIC;
           RSTARTP : out STD_LOGIC;
           RDATAI : in STD_LOGIC_VECTOR (7 downto 0);
           

           TABORTP : in STD_LOGIC;
           TAVAILP : in STD_LOGIC;
           TDONEP :out STD_LOGIC;
           TFINISHP : in STD_LOGIC;
           TREADDP : out STD_LOGIC;
           TRNSMTP : out STD_LOGIC;
           TSTARTP : out STD_LOGIC;
           TDATAI : in STD_LOGIC_VECTOR (7 downto 0);
           TSOCOLP : out STD_LOGIC;
           TDATAO : out STD_LOGIC_VECTOR (7 downto 0);
           
           RESET : in STD_LOGIC;
           CLK10I : in STD_LOGIC);
           
           
end ethernet;



architecture Behavioral of ethernet is

constant mac_address : std_logic_vector(47 downto 0) := X"AAAAAAAAAAAA";
signal compteur, compteurtr : std_logic_vector(2 downto 0) := "000";
signal i, t : integer:= 0;
signal etat, tcolision, tabort, etatt : std_logic := '0';
signal nb_essais : std_logic_vector(3 downto 0) := (others => '0');

begin

--Compteur de clock reception
process
begin
    wait until CLK10I'event and CLK10I = '1';
    if RESET = '1' then
        if etat = '0'and RENABP = '1' then
            etat <= '1';
        elsif RENABP = '0' then
            etat <= '0';
            compteur <= "000";
        else 
            if compteur /= "111" and etat = '1' then
                compteur <= compteur + '1';
            else
                compteur <= "000";        
            end if;
        end if;
    else
        etat <= '0';
    end if;
end process;

--Reception
process
begin
    --attend clock
    wait until CLK10I'event and CLK10I = '1';
    RSTARTP <= '0';
    RBYTEP <= '0';
    RDONEP <= '0';
    RCLEANP <= '0';
    RSMATIP <= '0';
    if RESET = '1' then
        if RENABP = '1' then
            if compteur ="111" then 
                --SFD Check
                if RDATAI = "10101011" and i=0 then
                    RSTARTP <= '1';
                    i <= i+1;
                --Check address
                elsif  i < 7 and i> 0 and  RDATAI = mac_address(7+8*(i-1) downto 8*(i-1)) then
                    RBYTEP <= '1';
                    --Correct address check
                        if i = 6 then
                        RSMATIP <= '1';
                        end if;
                    i <= i+1;
                    
                -- Get data
                elsif RDATAI /= "10101011" and i >= 7 then
                    RDATAO <= RDATAI;
                    RBYTEP <= '1';
                    i <= i+1;
                --End of frame + 64 bytes min length (Succesfull read)
                elsif RDATAI = "10101011" and i>64 then
                    RDONEP <= '1';
                    i <= 0;
                    RDATAO <= (others => '0');
                -- Unsuccesfull read
                else
                    RCLEANP <= '1';
                    i <= 0; --reset to 0 for new reception
                    RDATAO <= (others => '0');
                end if;
            end if;
        else 
            RBYTEP <= '0';
            RCLEANP <= '0';
            RCVNGP <= '0';
            RDONEP <= '0';
            RSMATIP <= '0';
            RSTARTP <= '0';
            RDATAO <= (others => '0');
            i <= 0;
        end if;
    else
       RBYTEP <= '0';
       RCLEANP <= '0';
       RCVNGP <= '0';
       RDONEP <= '0';
       RSMATIP <= '0';
       RSTARTP <= '0';
       RDATAO <= (others => '0');
       i <= 0;
    end if;
end process;

--process check collision
process
begin
    wait until CLK10I'event and CLK10I = '1';
    if RESET = '1' then
        if RENABP = '1' and TAVAILP = '1' then
            tcolision <= '1';
            --signal intermediaire aussi
        else 
            tcolision <= '0';
        end if;
        TSOCOLP <= tcolision;
    else 
        TSOCOLP <= '0';
    end if;
end process;

--compteur transmission
process
begin
    wait until CLK10I'event and CLK10I = '1';
    if RESET = '1' then
        if etatt = '0'and TAVAILP = '1' then
            etatt <= '1';
        elsif TAVAILP = '0' then
            etatt <= '0';
            compteurtr <= "000";
        else 
            if compteurtr /= "111" and etatt = '1' then
                compteurtr <= compteurtr + '1';
            else
                compteurtr <= "000";        
            end if;
        end if;
    else
        etatt <= '0';
    end if;
end process;

-- Transmission
process
begin
    --attend clock
    wait until CLK10I'event and CLK10I = '1';    
    TSTARTP <= '0';
    TREADDP <= '0';
    TDONEP <= '0';
    if RESET = '1' then
        if TAVAILP = '1' then 
        
            if compteurtr = "110" then 
                if t = 0 then 
                    TSTARTP <= '1';
                    TRNSMTP <= '1';
                    t <= 1; -- signal dÃ©but transmission
                end if;
                -- Succesful transmission
                if nb_essais < 15 and TABORTP = '0' and tcolision = '0' and TFINISHP = '0' then
                    TREADDP <= '1';
                    TDATAO <= TDATAI;
                    nb_essais <= (others => '0');
                -- Stop to collision (counter for retries) 
                elsif  nb_essais < 15 and TABORTP = '0' and TFINISHP = '0'then
                    nb_essais <= nb_essais + 1; 
                    TDATAO <= (others => '0');
                else
                    -- Transmission ended due to errors
                    TDONEP <= '1';
                    TRNSMTP <= '0';
                    nb_essais <= (others => '0');
                    TDATAO <= (others => '0');
                    t <= 0;
                end if;
            end if; 
        else
        -- Transmission Done Succesfully
            if t = 1 then
                TDONEP <= '1';
                TRNSMTP <= '0';
                TDATAO <= (others => '0');
                t <= 0; --end transmission OR no transmission
                nb_essais <= (others => '0');
        end if;
            
        end if;
        
    -- Reset values    
    else
        TDONEP <= '0';
        TREADDP <= '0';
        TRNSMTP <= '0';
        TSTARTP <= '0';
        TDATAO <= (others => '0');
        nb_essais <= (others => '0');
    end if;
end process;

end Behavioral;
