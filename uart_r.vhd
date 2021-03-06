--串口接收模块
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_r is
	generic(framlen:integer:=8);--数据为framlen-1
	port
	(
		bclkr,resetr,rxdr:in std_logic;--rxdr数据输入脚
		r_ready :out std_logic;
		rbuf:out std_logic_vector(7 downto 0)
	);
end uart_r;

architecture behave of uart_r is
	type states is (r_idle,r_sample_start_bit,r_sample_data_bit,r_sample,r_stop);
	signal state:states:=r_idle;
	signal rxd_syn:std_logic;
	signal sim_rxdr:std_logic;
begin
pro1:	process(rxdr)--用DFF把数据输入脚整形下,防止干扰
		begin
			if rxdr='0' then 
				rxd_syn<='0';
			else 
				rxd_syn<='1';
			end if;
		end process;
pro2:	process(bclkr,resetr,rxd_syn)
			variable count :std_logic_vector(3 downto 0);
			variable rcnt:integer range 0 to framlen :=0;
			variable rbufs:std_logic_vector(7 downto 0);
		begin
			if resetr='1' then
				state<=r_idle;
				count:="0000";
				rcnt:=0;
				r_ready<='0';
			elsif rising_edge(bclkr) then
				case state is  --j检测是否是起始位
					when r_idle=>
						if rxd_syn='0' then
							state<=r_sample_start_bit;
							r_ready<='0';--检测到起始位后才复位r_ready
							rcnt:=0;
							count:="0000";--在这儿起始位为0已经有一个时钟时间了
						else
							state<=r_idle;
							
						end if;
		
					when r_sample_start_bit=>  --检测起始位是否够时间
						if rxd_syn='0' then
							if count<"0111" then--8个时钟后,再采样
								count:=count+1;
								state<=r_sample_start_bit;
							else  --起始位正确,开始采样数据位
								state<=r_sample_data_bit;
								count:="0000";
								rcnt:=0;--开始接收数据位
							end if;
						else
							state<=r_idle;
							count:="0000";
						end if;
						
					when r_sample_data_bit=>
						if count<="1110" then--16个时钟后再采样
							count:=count+1;
							state<=r_sample_data_bit;
						else
							if rcnt=framlen then
								state<=r_stop;
								count:="0000";
								rcnt:=0;
							else
								state<=r_sample_data_bit;
								count:="0000";
								rbufs(rcnt):=rxd_syn;--移入数据位
								rcnt:=rcnt+1;
							end if;
						end if;
					when r_stop=> ---省略了对停止位的检测
						r_ready<='1';--接受数据可读了
						rbuf<=rbufs;---更新输出数据
						state<=r_idle;
					when others=>
						state<=r_idle;
				end case;
			end if;
		
		end process;
end behave;
