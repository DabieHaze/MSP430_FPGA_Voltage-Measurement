
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
----------------------------------------------
ENTITY SEG_SEL IS
PORT( D_SEG:OUT std_logic_VECTOR(3 DOWNTO 0);
		D_POS:OUT std_logic_VECTOR(7 downto 0);
		CLK:IN BIT;
		DATA_IN:IN std_logic_VECTOR(9 DOWNTO 0);
		--sign1:in integer range 0 to 15;
		sign2:in integer range 0 to 15
		);
END SEG_SEL;

ARCHITECTURE behave OF SEG_SEL IS
CONSTANT TEMP:INTEGER:=1234;
SIGNAL A,B,C,D:STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
SIGNAL shiWei:std_logic_VECTOR(3 DOWNTO 0):= "0000";
SIGNAL CLK_1KHz:BIT;
BEGIN

--"1010" ELSE--表示字母A
--D_SEG="1011" ELSE--表示符号-
	PROCESS(DATA_IN,CLK)
	BEGIN
		IF(CLK'EVENT AND CLK='1')THEN
			--DATA_OUT(9 DOWNTO 0)<= "1011010011"; SIGN2 <= 12; -- A-13 
			--DATA_OUT(9 DOWNTO 0 <= "0110000100"; SIGN2 <= 15; -- 6 04
			shiWei(1 DOWNTO 0) <= DATA_IN(5 DOWNTO 4);
				A <= DATA_IN(9 DOWNTO 6); --B<=B;C<=C;D<=D;
				B <= CONV_STD_LOGIC_VECTOR(sign2,4);-- A<=A;C<=C;D<=D;
				C <= shiWei(3 DOWNTO 0); -- A<=A;B<=B;D<=D;
				D <= DATA_IN(3 DOWNTO 0);  --A<=A;B<=B;C<=C;
			
		END IF;
	END PROCESS;

	PROCESS(CLK)
	VARIABLE TMP:INTEGER RANGE 0 TO 5000;
	BEGIN
	IF (CLK'EVENT AND CLK = '1') THEN TMP:=TMP+1;
		IF (TMP < 2500) THEN CLK_1KHz <= '1';
		ELSIF (TMP = 5000) THEN TMP:= 0;
		ELSE CLK_1KHz <= '0';
		END IF;
	END IF;
	END PROCESS;
	
	
	PROCESS(CLK_1KHz)
	VARIABLE CNT:INTEGER RANGE 0 TO 3;
		BEGIN
			IF(CLK_1KHz'EVENT AND CLK_1KHz='1')THEN
				CNT:=CNT+1;
			END IF;
		
			case CNT is
				when 0 => D_SEG<=A;D_POS<="01111111";
				when 1 => D_SEG<=B;D_POS<="10111111";
				when 2 => D_SEG<=C;D_POS<="11011111";
				when 3 => D_SEG<=D;D_POS<="11101111";
		
				WHEN OTHERS => NULL;
			end case;
		END PROCESS;
	
END behave;
		