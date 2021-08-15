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
entity MEMCTL is generic (
    g_CLKS_PER_BIT : integer := 868
  ); port (
    Clk          : in  std_logic;
    Clk_Bram     : in  std_logic;
    Reset        : in  std_logic;
    Rx_Serial    : in  std_logic;
    Input_Data   : in  std_logic_vector (31 downto 0);
    Address      : in  std_logic_vector (31 downto 0);
    Write_Enable : in  std_logic_vector ( 3 downto 0);
    Output_Data  : out std_logic_vector (31 downto 0)
  );
end MEMCTL;

--------------------------------------------------------------------------------
-- Architecture Section
--------------------------------------------------------------------------------
architecture Behavioral of MEMCTL is
  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  signal rx_done         : std_logic;
  signal rx_byte         : std_logic_vector (7 downto 0);
  signal write_request_r : std_logic                     := '0';
  signal write_request   : std_logic_vector (3 downto 0);
  signal fsm_state_r     : std_logic_vector (1 downto 0) := b"00";
  signal fsm_state_nxt   : std_logic_vector (1 downto 0);
  signal address_low_r   : std_logic_vector (7 downto 0);
  signal address_high_r  : std_logic_vector (7 downto 0);
  signal write_data_r    : std_logic_vector (7 downto 0);
  signal sequence_start  : std_logic;
  signal addra_i         : std_logic_vector (13 downto 0);
  signal ram_clk         : std_logic;
begin

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
  -- UART_MEM_FSM : FSM used for decoding transmission and requesting write
  ------------------------------------------------------------------------------
  UART_MEM_FSM : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if rx_done = '1' then
        if (fsm_state_r /= b"00" or sequence_start = '1') then
          fsm_state_r <= fsm_state_nxt;
          write_request_r <= '0';
        end if;
        if (fsm_state_r = b"01") then
          address_low_r <= rx_byte;
          write_request_r <= '0';
        end if;
        if (fsm_state_r = b"10") then
          address_high_r <= rx_byte;
          write_request_r <= '0';
        end if;
        if (fsm_state_r = b"11") then
          write_data_r <= rx_byte;
          write_request_r <= Reset;
        end if;
      end if;
    end if;
  end process UART_MEM_FSM;
  with fsm_state_r select fsm_state_nxt <=
    "01" when b"00",
    "10" when b"01",
    "11" when b"10",
    "00" when others;

  ------------------------------------------------------------------------------
  -- Write sequence start detect signal
  ------------------------------------------------------------------------------
  sequence_start <= '1' when rx_byte = x"21" else '0';

  ------------------------------------------------------------------------------
  -- UART_BRAM : Main memory array 32x2KB = 64KB
  ------------------------------------------------------------------------------
  UART_BRAM : for I in 0 to 31 generate
    UART_BRAM_I : BRAM_TDP_MACRO generic map (
      BRAM_SIZE => "18Kb",
      DEVICE => "SPARTAN6",
      DOA_REG => 0,
      DOB_REG => 0,
      WRITE_WIDTH_A => 1,
      READ_WIDTH_A => 1,
      WRITE_WIDTH_B => 1,
      READ_WIDTH_B => 1,
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST"
    ) port map (
      DOA => open,
      DOB => Output_Data(I downto I),
      ADDRA => addra_i,
      ADDRB => Address(15 downto 2),
      CLKA => Clk,
      CLKB => ram_clk,
      DIA => write_data_r((I mod 8) downto (I mod 8)),
      DIB => Input_Data(I downto I),
      ENA => '1',
      ENB => '1',
      REGCEA => '1',
      REGCEB => '1',
      RSTA => '0',
      RSTB => '0',
      WEA => (write_request(I/8 downto I/8)),
      WEB => Write_Enable((I/8) downto (I/8))
    );
  end generate UART_BRAM;
  addra_i <= (address_high_r(7 downto 0) & address_low_r(7 downto 2));

  ------------------------------------------------------------------------------
  -- Port A (UART receiver) write enable decode signal
  ------------------------------------------------------------------------------
  write_request <= (
    (write_request_r and     address_low_r(1) and     address_low_r(0)) &
    (write_request_r and     address_low_r(1) and not address_low_r(0)) &
    (write_request_r and not address_low_r(1) and     address_low_r(0)) &
    (write_request_r and not address_low_r(1) and not address_low_r(0)));

  ------------------------------------------------------------------------------
  -- Global clock buffer used to distribute BRAM clock accross whole FPGA
  ------------------------------------------------------------------------------
  RAM_BUFG : BUFG port map (
    O => ram_clk,
    I => Clk_Bram
  );

end Behavioral;
