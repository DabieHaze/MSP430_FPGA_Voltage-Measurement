--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
entity HANDLE is--定义uart实体
    port
	 (
	   clkin:in std_logic;--clkin为50M
		FLAG_IN:in std_logic;--上一级传入的结束标志
		DATA_IN:IN STD_LOGIC_VECTOR(7 DOWNTO 0);--上一级传入的数据串
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
							if(DATA_IN(7) = '0') then --基础部分
								DATA_OUT(9 DOWNTO 6) <= "1011"; -- 传字母A
								DATA_OUT(5 DOWNTO 0) <= DATA_IN(5 DOWNTO 0); -- 传增益
								if (DATA_IN(6) = '0') then --负数
									--SIGN1 <= 11;--CONV_INTEGER("1011"); -- 显示符号A
									SIGN2 <= 12;--CONV_INTEGER("1100"); -- 标记，显示符号-
							   elsif (DATA_IN(6) = '1') then -- 正数
									--SIGN1 <= 11;--CONV_INTEGER("1011"); -- 显示符号A
									SIGN2 <= 15;--CONV_INTEGER("1111"); -- 标记，不显示
								end if;
							elsif(DATA_IN(7) = '1') then -- 发挥部分
								DATA_OUT(9) <= '0';
								if(DATA_IN(6) = '0') then -- 第一组，传1-6档位和符号标记
									DATA_OUT(8 DOWNTO 6) <= DATA_IN(5 DOWNTO 3);
									if(DATA_IN(0) = '0') then
										SIGN2 <= 12;--CONV_INTEGER("1100"); -- 标记，显示符号-
									elsif(DATA_IN(0) = '1') then
										SIGN2 <= 15;--CONV_INTEGER("1111"); -- 标记，不显示
									end if;
								elsif(DATA_IN(6) = '1') then -- 第二组，传增益
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