--串口发送模块
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_t is
	generic(framlen:integer:=7);--数据位为framlen+1位
	port
	(
		bclkt,resett,xmit_cmd_p:in std_logic;
		--bclk-发送时钟，reset-复位信号
		--xmit_cmd_p-新一轮发送启动信号
		txdbuf:in std_logic_vector(7 downto 0);
		--待发送数据寄存器
		txd:out std_logic;
		--串行数据输出
		txd_done:out std_logic
		--一帧数据(8bits)发送完毕标志
	);
end uart_t;

architecture behave of uart_t is
	type states is (x_idle,x_start_bit,x_data_bit,x_stop_bit);
	--状态机状态
	signal state:states:=x_idle;
	--初始状态为x_idle
begin
	process(bclkt,resett,xmit_cmd_p,txdbuf)
	variable xcnt16:std_logic_vector(4 downto 0):="00000";
	--发送1bit所要保持的时钟计数器
	--(因为现在的bclkt是baud频率的16倍)
	variable xbitcnt:integer range 0 to framlen :=0;
	--已经发送的数据位 计数器
	variable txds : std_logic;	
	--串行输出数据暂存变量
	begin
		if resett='1' then 
			state<=x_idle;
			txd_done<='0';
			txds:='1';
			xbitcnt:=0;
			xcnt16:="00000";
		elsif rising_edge(bclkt) then
			case state is
				when x_idle=>  
					if xmit_cmd_p='1' then ---判断是否启动新一轮发送
						state<=x_start_bit;--准备发送起始位
						txd_done<='0';--直到有这个发送脉冲后,txd_done才复位
									--从这儿开始,发送数据不能改变了
						txds:='0';
						xcnt16:="00000";
					else 
						state<=x_idle;
						txds:='1';
					end if;
				when x_start_bit=>   --发送起始位
					if xcnt16<="01110" then--需要保持16个时钟
						xcnt16:=xcnt16+1;
						txds:='0';
						state<=x_start_bit;--继续发送起始位	
					else
						state<=x_data_bit;--准备开始发送数据位
						xcnt16:="00000";--重置为0
						txds:=txdbuf(0);--发送第0位
						xbitcnt:=0;
					end if;
				when x_data_bit=>  --发送数据位
					if xcnt16<="01110" then
						xcnt16:=xcnt16+1;
						state<=x_data_bit;
					else
						if xbitcnt=framlen then --判断是否已经发送完一帧(8bits)数据
							state<=x_stop_bit;
							xbitcnt:=0;
							xcnt16:="00000";
							txds:='1';
						else
							xbitcnt:=xbitcnt+1;
							txds:=txdbuf(xbitcnt);
							state<=x_data_bit;
							xcnt16:="00000";---重新计数一bit所要保持的时间
						end if;
					end if;
				when x_stop_bit=> --停止位也是16位
					if xcnt16<="01110" then
						xcnt16:=xcnt16+1;
						txds:='1';
						state<=x_stop_bit;
					else 					
						state<=x_idle;
						xcnt16:="00000";
						txds:='1';
						txd_done<='1';
					end if;					
				when others=> --回到x_idle状态
					state<=x_idle;								
			end case;
		end if;
		txd<=txds;--当txds变化时,txd就立即变化,功能仿真时无延时
	end process;	
end behave;
