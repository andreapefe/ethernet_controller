----------------------------------------------------------------------------------
-- Students: Andrea Pérez and Léa Scheer 
-- 
-- Create Date: 25.11.2021 11:21:10
-- Module Name: ethernet - Behavioral
-- Project Name: TP Module Ethernet 
-- Design Name : Simulation file for the ethernet module
-- Target Devices: BASYS 3
-- Description: VHDL code simulating recepetion valid and non valid Ethernet frames 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_reception is

end test_reception;

architecture Behavioral of test_reception is
component ethernet 
    Port (      RBYTEP : out STD_LOGIC;
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
 end component;
           
for all : ethernet use entity work.ethernet(Behavioral);
           
signal reset : std_logic := '0';
signal clk: std_logic := '1';
signal rbytep, rcleanp, rcvngp, rdonep,renabp, rsmatip, rstartp: std_logic := '0';
signal tabortp, tavailp, tdonep, tfinishp, treaddp, trnsmtp, tstartp, tsocolp : std_logic := '0';
signal tdatai, tdatao : std_logic_vector(7 downto 0) := (others => '0'); 
signal rdatai, rdatao : std_logic_vector(7 downto 0) := (others => '0');
--signal vecteur_test_valide : std_logic_vector(123 downto 0) := X"AB11AA22BB33CC123456789ABCDEFAB";
--signal vecteur_test_fausse_adresse : std_logic_vector(123 downto 0) := X"AB11FA22BB33CC123456789ABCDEFAB";
--signal non_debut : std_logic_vector(123 downto 0) := X"BB11FA22BB33CC123456789ABCDEFAB";
--signal non_fin : std_logic_vector(123 downto 0) := X"BB11FA22BB33CC123456789ABCDEFAB";

begin

U1 : ethernet port map(rbytep, rcleanp, rcvngp, rdatao, rdonep,renabp, rsmatip, rstartp, rdatai,tabortp, tavailp, tdonep, tfinishp, treaddp, trnsmtp, tstartp, tdatai, tsocolp, tdatao, reset, clk);

clk <= not clk after 50 ns;  
reset <= '1' after 200 ns;
-- Reception
renabp <= '1' after 200 ns, '0' after 69990 ns, --'0' after 15000 ns, '1' after 57000 ns, to test initial reading values
          -- for collision in transmission
          '1' after 82000 ns, '0' after 84000 ns, '1' after 90000ns, '0' after 103000 ns; 
rdatai <= X"AB", X"AA" after 1100 ns, X"11" after 5900 ns, X"AB" after 57100 ns, -- bonne addresse
          X"00" after 60100 ns, --Mauvaise addresse et mauvaise trame début
          X"AB" after 62000 ns, X"AA" after 62800 ns, X"12" after 67600 ns, X"AB" after 69200 ns; --mauvaise longueur

-- Transmission
-- Transmission
tavailp <= '1' after 70200ns; --'0' after 127600 ns;
-- Trame valide normal
tdatai <= X"AB", X"AA" after 71100 ns, X"11" after 75900 ns, X"AB" after 127100 ns, X"00" after 130100 ns;
-- Avec finish et abort
tfinishp <= '1' after 75000ns, '0' after 76000ns;
tabortp <= '1' after 79000 ns, '0' after 80000 ns;        

end Behavioral;
