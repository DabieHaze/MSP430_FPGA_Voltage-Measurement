--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
entity HANDLE is--����uartʵ��
    port
	 (
	   clkin:in std_logic;--clkinΪ50M
		FLAG_IN:in std_logic;--��һ������Ľ�����־
		DATA_IN:IN STD_LOGIC_VECTOR(7 DOWNTO 0);--��һ����������ݴ�
		flag_out,clkout:OUT std_logic;
		DATA_OUT:OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		--SIGN1:out integer range 0 to 15;
		SIGN2:out integer range 0 to 15
	 );
end HANDLE;

architecture behave of HANDLE is
shared variable cnt:integer range 0 to 3:=0;
begin
	process(clkin)
	--variable cnt_bitch:integer range 0 to 60000:=0;
	begin
		if rising_edge(clkin) then
			case cnt is
				when 0 => 
							if (FLAG_IN = '0') then
								cnt:=0;
							elsif (FLAG_IN = '1') then
								cnt:=1;
							end if;

				when 1 =>
							if (FLAG_IN = '1') then
								cnt:=1;
							elsif (FLAG_IN = '0')then
								cnt:=2;
							end if;
				when 2 =>
							if(DATA_IN(7) = '0') then --��������
								DATA_OUT(9 DOWNTO 6) <= "1011"; -- ����ĸA
								DATA_OUT(5 DOWNTO 0) <= DATA_IN(5 DOWNTO 0); -- ������
								if (DATA_IN(6) = '0') then --����
									--SIGN1 <= 11;--CONV_INTEGER("1011"); -- ��ʾ����A
									SIGN2 <= 12;--CONV_INTEGER("1100"); -- ��ǣ���ʾ����-
							   elsif (DATA_IN(6) = '1') then -- ����
									--SIGN1 <= 11;--CONV_INTEGER("1011"); -- ��ʾ����A
									SIGN2 <= 15;--CONV_INTEGER("1111"); -- ��ǣ�����ʾ
								end if;
							elsif(DATA_IN(7) = '1') then -- ���Ӳ���
								DATA_OUT(9) <= '0';
								if(DATA_IN(6) = '0') then -- ��һ�飬��1-6��λ�ͷ��ű��
									DATA_OUT(8 DOWNTO 6) <= DATA_IN(5 DOWNTO 3);
									if(DATA_IN(0) = '0') then
										SIGN2 <= 12;--CONV_INTEGER("1100"); -- ��ǣ���ʾ����-
									elsif(DATA_IN(0) = '1') then
										SIGN2 <= 15;--CONV_INTEGER("1111"); -- ��ǣ�����ʾ
									end if;
								elsif(DATA_IN(6) = '1') then -- �ڶ��飬������
									DATA_OUT(5 DOWNTO 0) <= DATA_IN(5 DOWNTO 0);
								end if;
							end if;
							
							flag_out<='1';
							cnt:=3;
				when 3 =>
							flag_out<='0';
							cnt:=0;

			end case;
		end if;
		--DATA_OUT(9 DOWNTO 0)<= "1011010011"; SIGN2 <= 12; -- A-13 
	   --DATA_OUT(9 DOWNTO 0) <= "0110000100"; SIGN2 <= 15; -- 6 04
	end process;
	clkout<=not clkin;
	
end behave;