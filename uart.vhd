
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
----------------------------------------------
entity uart is--����uartʵ��
    port
	 (
	   clkin,resetin:in std_logic;--clkinΪ50M
		rxd:in std_logic;--������������
		led:out std_logic_vector(5 downto 0);--ledָʾ
		txd:out std_logic;--�����������
		DATA_F:OUT std_logic;
		clk_out:OUT std_logic;
		DATA_OUT:OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	 );
end uart;
---------------------------------------
architecture behave of uart is
---------------------------------------
    component gen_div is--��ƵԪ����������
	 generic(div_param:integer:=163); --326��Ƶ��326 * 16 * ��9600��= 50M   --������Ϊ9600. 
	 port
	 (
	   clk:in std_logic;
		bclk:out std_logic;
		resetb:in std_logic
	 );
	 end component;
	 ---------------------------------------------------
	 component uart_t is--���ڷ���Ԫ����������
	 port
	 (
	   bclkt,resett,xmit_cmd_p:in std_logic;
		txdbuf:in std_logic_vector(7 downto 0);
		txd:out std_logic;
		txd_done:out std_logic
	 );
	 end component;
	 ----------------------------------------------------
	 component uart_r is--���ڽ���Ԫ����������
	 port
	 (
	   bclkr,resetr,rxdr:in std_logic;
		r_ready:out std_logic;
		rbuf:out std_logic_vector(7 downto 0)
	 );
	 end component;
	 -----------------------------------------------------
	 component narr_sig is--�ź�խ��Ԫ����������
	 port
	 (
	   sig_in:in std_logic;
		clk:in std_logic;
		resetb:in std_logic;
		narr_prd:in std_logic_vector(7 downto 0);
		narr_sig_out:out std_logic
	 );
	 end component;
	 -------------------------------------------------
	 signal clk_b:std_logic;--������ʱ��
	 signal clk1:std_logic;--�����ʱ��
	 ---------------------------------------------------
	 signal xmit_p:std_logic;--��һ�ַ��������ź�
	 signal xbuf:std_logic_vector(7 downto 0);--���������ݻ�����
	 signal txd_done_iner:std_logic;--֡���ݷ������־
	 -----------------------------------------------------
	 signal rev_buf:std_logic_vector(7 downto 0);--�������ݻ�����
	 signal rev_ready:std_logic;--֡���ݽ������־
	 -------------------------------------------------
	 signal led_tmp:std_logic_vector(5 downto 0);--led����
	 -------------------------------------------------
	 signal flag:std_logic:='0';--������־
	 ------------------------------
	 begin 
	 --------��Ƶģ������--------------
	      uart_baud:gen_div
			generic map(163) --326��Ƶ��326 * 16 * ��9600��= 50M   --������Ϊ9600. 
			port map
			(
			  clk=>clkin,
			  resetb=>not resetin,
			  bclk=>clk_b
			);
	 --------��Ƶģ������--------------
	      seg_clk:gen_div
			generic map(10) --20��Ƶ
			port map
			(
			  clk=>clkin,
			  resetb=>not resetin,
			  bclk=>clk1
			);
			-------���ڷ���ģ������------------
			uart_transfer:uart_t
			port map
			(
			  bclkt=>clk_b,
			  resett=>not resetin,
			  xmit_cmd_p=>xmit_p,
			  txdbuf=>xbuf,
			  txd=>txd,
			  txd_done=>txd_done_iner
			);
			-------���ڽ���Ԫ������-------------
			uart_receive:uart_r
			port map
			(
				bclkr=>clk_b,
				resetr=>not resetin,
				rxdr=>rxd,
				r_ready=>rev_ready,
				rbuf=>rev_buf
			);
			--------�ź�խ��ģ������-------------
			narr_rev_ready:narr_sig--խ��rev_ready�źź��xmit_p
			port map
			(
				sig_in=>rev_ready,--������խ���ź�
				clk=>clk_b,
				resetb=>not resetin,
				narr_prd=>X"03",--narr�źŸߵ�ƽ������������(��clkΪ����)
				narr_sig_out=>xmit_p--���խ�����ź�
			);
			------------------------------------
			led<=led_tmp;
			-----------------------------
			process(rev_ready,resetin,rev_buf,led_tmp,clk_b)
			begin
				   if rising_edge(rev_ready) then--�������
					 xbuf<=rev_buf;--װ������		 
					end if;
			end process;
			---------------------------------------
		display:process(clk1,rev_ready,rev_buf,clkin)
			variable cnt:integer range 0 to 2:=0;
			begin
				if rising_edge(clkin)then
					if (rev_ready='0') then--�������
							DATA_OUT<=rev_buf;
							cnt:=1;
					end if;
					if(cnt=1)then
						flag<='1';
						cnt:=cnt+1;
					elsif(cnt=2)then
						flag<='0';
						cnt:=cnt+1;
					end if;
				 end if;
				
			end process;
			---------------------------------------
DATA_F<=flag;
clk_out<=clk_b;

end behave;
-------------------------------	 
	 
	 