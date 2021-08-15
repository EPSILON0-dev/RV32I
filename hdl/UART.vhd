--------------------------------------------------------------------------------
-- Written by: Łukasz Forenc
--------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk"
--      state machine state:                    "fsm_*"
--      register signals:                       "*_r"
--      internal version of output port         "*_i"
--      ports:                                  - Names begin with Uppercase
--      processes:                              - All capital letters
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;
--------------------------------------------------------------------------------
-- Definition of Ports :
--------------------------------------------------------------------------------
-- System Signals
--  Clk            --  Clock signal
--  Reset          --  Reset signal
-- Memory Interface Signals
--  Input_Data     --  Input from memory
--  Address        --  Address of accessed memory
--  Output_Data    --  Output to memory
--  Write_Enable   --  Write enable signals
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Entity Section
--------------------------------------------------------------------------------
entity UART is generic (
    g_CLKS_PER_BIT : integer := 868
  ); port (
    Clk          : in  std_logic;
    Reset        : in  std_logic;
    Rx_Serial    : in  std_logic;
    Write_Enable : in  std_logic;
    Input_Data   : in  std_logic_vector (7 downto 0);
    Address      : in  std_logic_vector (1 downto 0);
    Enable       : in  std_logic;
    Tx_Serial    : out std_logic;
    Output_Data  : out std_logic_vector (7 downto 0)
  );
end UART;

--------------------------------------------------------------------------------
-- Architecture Section
--------------------------------------------------------------------------------
architecture Behavioral of UART is
  -- FIFO signals
  signal tx_fifo_addr_r    : std_logic_vector (4 downto 0) := (others => '0');
  signal rx_fifo_addr_r    : std_logic_vector (4 downto 0) := (others => '0');
  signal tx_fifo_addr_nxt  : std_logic_vector (4 downto 0);
  signal rx_fifo_addr_nxt  : std_logic_vector (4 downto 0);
  signal tx_fifo_addr_inc  : std_logic_vector (4 downto 0);
  signal rx_fifo_addr_inc  : std_logic_vector (4 downto 0);
  signal tx_fifo_addr_dec  : std_logic_vector (4 downto 0);
  signal rx_fifo_addr_dec  : std_logic_vector (4 downto 0);
  signal tx_fifo_out       : std_logic_vector (7 downto 0);
  signal rx_fifo_out       : std_logic_vector (7 downto 0);
  signal fifo_status       : std_logic_vector (7 downto 0);
  signal tx_fifo_full      : std_logic;
  signal rx_fifo_full      : std_logic;
  signal tx_fifo_empty     : std_logic;
  signal rx_fifo_empty     : std_logic;
  signal tx_fifo_read      : std_logic;
  signal rx_fifo_read      : std_logic;
  signal tx_fifo_write     : std_logic;
  signal rx_fifo_write     : std_logic;
  signal tx_start          : std_logic;
  -- TX signals
  signal tx_active         : std_logic;
  signal tx_done           : std_logic;
  -- RX signals
  signal rx_byte           : std_logic_vector (7 downto 0);
  signal rx_done           : std_logic;
begin

  ------------------------------------------------------------------------------
  -- Buffer data detect signals
  ------------------------------------------------------------------------------
  tx_fifo_full  <= '1' when tx_fifo_addr_r = b"11111" else '0';
  tx_fifo_empty <= '1' when tx_fifo_addr_r = b"00000" else '0';
  rx_fifo_full  <= '1' when rx_fifo_addr_r = b"11111" else '0';
  rx_fifo_empty <= '1' when rx_fifo_addr_r = b"00000" else '0';

  ------------------------------------------------------------------------------
  -- TX_FIFO : Transmitter FIFO register
  ------------------------------------------------------------------------------
  TX_FIFO : for I in 0 to 7 generate
    TX_FIFO_I : SRLC32E generic map (
      INIT => x"00000000"
    ) port map (
      Clk => Clk,
      CE  => tx_fifo_write,
      D   => Input_Data(I),
      A   => tx_fifo_addr_dec,
      Q   => tx_fifo_out(I),
      Q31 => open
    );
  end generate TX_FIFO;

  ------------------------------------------------------------------------------
  -- RX_FIFO : Receiver FIFO register
  ------------------------------------------------------------------------------
  RX_FIFO : for I in 0 to 7 generate
    RX_FIFO_I : SRLC32E generic map (
      INIT => x"00000000"
    ) port map (
      Clk => Clk,
      CE  => rx_fifo_write,
      D   => rx_byte(I),
      A   => rx_fifo_addr_r,
      Q   => rx_fifo_out(I),
      Q31 => open
    );
  end generate RX_FIFO;
  rx_fifo_write <= rx_done and (not rx_fifo_full);

  ------------------------------------------------------------------------------
  -- TX_ADDR_CNT : Transmitter FIFO address counter
  ------------------------------------------------------------------------------
  TX_ADDR_CNT : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Reset = '1' then
        tx_fifo_addr_r <= (others => '0');
      else
        if (tx_fifo_read xor (tx_fifo_write and (not tx_fifo_full))) = '1' then
          tx_fifo_addr_r <= tx_fifo_addr_nxt;
        end if;
      end if;
    end if;
  end process TX_ADDR_CNT;
  tx_fifo_addr_nxt <= tx_fifo_addr_inc when tx_fifo_write = '1'
                      else tx_fifo_addr_dec;
  tx_fifo_addr_inc <= std_logic_vector(unsigned(tx_fifo_addr_r) + "1");
  tx_fifo_addr_dec <= std_logic_vector(unsigned(tx_fifo_addr_r) - "1");
  tx_fifo_read <= tx_done;
  tx_fifo_write <= (Write_Enable and Enable) when Address = b"00" else '0';

  ------------------------------------------------------------------------------
  -- RX_ADDR_CNT : Transmitter FIFO address counter
  ------------------------------------------------------------------------------
  RX_ADDR_CNT : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Reset = '1' then
        rx_fifo_addr_r <= (others => '0');
      else
        if ((rx_fifo_read and (not rx_fifo_empty)) xor
          (rx_fifo_write and (not rx_fifo_full))) = '1' then
          rx_fifo_addr_r <= rx_fifo_addr_nxt;
        end if;
      end if;
    end if;
  end process RX_ADDR_CNT;
  rx_fifo_addr_nxt <= rx_fifo_addr_inc when rx_done = '1'
                      else rx_fifo_addr_dec;
  rx_fifo_addr_inc <= std_logic_vector(unsigned(rx_fifo_addr_r) + "1");
  rx_fifo_addr_dec <= std_logic_vector(unsigned(rx_fifo_addr_r) - "1");
  rx_fifo_read <= Enable when Address = b"01" else '0';

  ------------------------------------------------------------------------------
  -- UART_TX : UART transmitter
  ------------------------------------------------------------------------------
  UART_TX : entity work.UART_TX generic map (
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
  ) port map (
    i_Clk => Clk,
    i_TX_DV => tx_start,
    i_TX_Byte => tx_fifo_out,
    o_TX_Active => tx_active,
    o_TX_Serial => Tx_Serial,
    o_TX_Done => tx_done
  );
  tx_start <= (not tx_fifo_empty) and (not tx_done);

  ------------------------------------------------------------------------------
  -- UART_RX : UART receiver
  ------------------------------------------------------------------------------
  UART_RX : entity work.UART_RX generic map (
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
  ) port map (
    i_Clk => Clk,
    i_RX_Serial => Rx_Serial,
    o_RX_DV => rx_done,
    o_RX_Byte => rx_byte
  );

  ------------------------------------------------------------------------------
  -- Status register
  ------------------------------------------------------------------------------
  fifo_status <= (b"000" & tx_active & tx_fifo_full & tx_fifo_empty &
                                       rx_fifo_full & rx_fifo_empty);
  ------------------------------------------------------------------------------
  -- Output assignement
  ------------------------------------------------------------------------------
  with Address select Output_Data <=
    rx_fifo_out when b"01", fifo_status when b"10", x"00" when others;

end Behavioral;
