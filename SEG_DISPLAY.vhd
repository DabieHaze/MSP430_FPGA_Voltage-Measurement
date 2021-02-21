library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
ENTITY SEG_DISPLAY IS
PORT( DATA_OUT:OUT std_logic_VECTOR(7 downto 0);
		 CS1:OUT BIT;
		 CS2:OUT BIT;
   CLK_OUT:OUT BIT;
		 CLK:IN BIT;
		D_SEG:IN std_logic_VECTOR(3 downto 0);
		D_POS:IN std_logic_VECTOR(7 downto 0));
END SEG_DISPLAY;

ARCHITECTURE behave OF SEG_DISPLAY IS
CONSTANT TEMP_SEG:INTEGER:=5;
CONSTANT TEMP_POS:BIT_VECTOR(7 downto 0):="10111111";
SIGNAL SEG:std_logic_VECTOR(7 downto 0);
SIGNAL DPOS:BIT_VECTOR(7 downto 0);
BEGIN

	 SEG<="11000000" WHEN D_SEG="0000" ELSE 
			"11111001" WHEN D_SEG="0001" ELSE
			"10100100" WHEN D_SEG="0010" ELSE
			"10110000" WHEN D_SEG="0011" ELSE
			"10011001" WHEN D_SEG="0100" ELSE
			"10010010" WHEN D_SEG="0101" ELSE
			"10000010" WHEN D_SEG="0110" ELSE
			"11111000" WHEN D_SEG="0111" ELSE
			"10000000" WHEN D_SEG="1000" ELSE
			"10010000" WHEN D_SEG="1001" ELSE
			"10001000" WHEN D_SEG="1011" ELSE--表示字母A
			"10111111" WHEN D_SEG="1100" ELSE--表示符号-
			"00000000";

	PROCESS(D_SEG,D_POS,CLK)
	VARIABLE CNT:INTEGER RANGE 0 TO 3;
		BEGIN
			IF(CLK'EVENT AND CLK='1')THEN
				CNT:=CNT+1;
			END IF;
		
		case CNT is
			when 0 => DATA_OUT<=D_POS;CS1<='0'; CS2<='1'; 
			when 1 => CS1<='1'; CS2<='1';
			when 2 => DATA_OUT<=SEG;CS1<='1'; CS2<='0';
			when 3 => CS1<='1'; CS2<='1';
			when others => NULL;
		end case;


		END PROCESS;
	
	
	CLK_OUT<=NOT CLK;
END behave;
		