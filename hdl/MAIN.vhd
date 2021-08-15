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
entity MAIN is port
  (
    Clk        : in  std_logic;
    Rx         : in  std_logic;
    Tx         : out std_logic;
    Reset      : in  std_logic;
    Irq        : in  std_logic;
    DP_Switch  : in  std_logic;
    LED        : out std_logic_vector (7 downto 0)
  );
end MAIN;

--------------------------------------------------------------------------------
-- Architecture Section
--------------------------------------------------------------------------------
architecture Behavioral of MAIN is
  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  constant g_CLKS_PER_BIT : integer := 868;
  -- Clocks
  signal clk_cpu : std_logic;
  signal clk_ram : std_logic;
  signal clk_fb  : std_logic;
  signal clk_en  : std_logic;
  -- Reset, ce and irq
  signal reset_n : std_logic;
  signal irq_n   : std_logic;
  -- CPU signals
  signal address : std_logic_vector (31 downto 0);
  signal cpu_in  : std_logic_vector (31 downto 0);
  signal cpu_out : std_logic_vector (31 downto 0);
  signal we      : std_logic_vector ( 3 downto 0);
  -- RAM signals
  signal mem_dat : std_logic_vector (31 downto 0);
  signal mem_we  : std_logic_vector ( 3 downto 0);
  signal mem_acc : std_logic;
  -- DP switch signals
  signal dp_sw_ext : std_logic_vector (31 downto 0);
  -- UART signals
  signal uart_en : std_logic;
  signal uart_data : std_logic_vector (7 downto 0);
  signal uart_data_ext : std_logic_vector (31 downto 0);
begin

  ------------------------------------------------------------------------------
  -- CPU : Main RV32I processor
  ------------------------------------------------------------------------------
  CPU : entity work.CPU port map (
    Clk => clk_cpu,
    Clk_Enable => '1',
    Reset => reset_n,
    Irq => irq_n,
    Input_Data => cpu_in,
    Address => address,
    Output_Data => cpu_out,
    Write_Enable => we
  );
  reset_n <= (not Reset) or (not DP_Switch);
  irq_n <= not Irq;

  ------------------------------------------------------------------------------
  -- MEMCTL : Main memory controller and programmer
  ------------------------------------------------------------------------------
  MEMCTL : entity work.MEMCTL generic map (
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
  ) port map (
    Clk => Clk,
    Clk_Bram => clk_cpu,
    Reset => reset_n,
    Rx_Serial => Rx,
    Input_Data => cpu_out,
    Address => address,
    Output_Data => mem_dat,
    Write_Enable => mem_we
  );

  ------------------------------------------------------------------------------
  -- Memory access signals
  ------------------------------------------------------------------------------
  mem_acc <= '1' when address(31 downto 16) = b"0000000000000000" else '0';
  mem_we <= we when mem_acc = '1' else x"0";
  cpu_in <= mem_dat when mem_acc = '1' else
            uart_data_ext when uart_en = '1' else x"00000000";

  ------------------------------------------------------------------------------
  -- CLKGEN : Min clock PLL generating 16MHz clocks for CPU and RAM
  ------------------------------------------------------------------------------
  CLKGEN : PLL_BASE generic map (
    BANDWIDTH => "OPTIMIZED",
    CLKFBOUT_MULT => 5,
    CLKFBOUT_PHASE => 0.0,
    CLKIN_PERIOD => 10.0,
    CLKOUT0_DIVIDE => 5,
    CLKOUT1_DIVIDE => 5,
    CLKOUT0_DUTY_CYCLE => 0.5,
    CLKOUT1_DUTY_CYCLE => 0.5,
    CLKOUT0_PHASE => 0.0,
    CLKOUT1_PHASE => 180.0,
    CLK_FEEDBACK => "CLKFBOUT",
    COMPENSATION => "SYSTEM_SYNCHRONOUS",
    DIVCLK_DIVIDE => 1,
    REF_JITTER => 0.010
  ) port map (
    CLKFBOUT => clk_fb,
    CLKOUT0 => clk_cpu,
    CLKOUT1 => clk_ram,
    LOCKED => open,
    CLKFBIN => clk_fb,
    CLKIN => Clk,
    RST => '0'
  );

  ------------------------------------------------------------------------------
  -- Peripheral controllers
  ------------------------------------------------------------------------------
  LED_BLINK : process (clk_cpu) is
  begin
    if (clk_cpu'event and clk_cpu = '1') then
      if reset_n = '1' then
        LED <= x"00";
      else
        if (we /= x"0" and address = x"00010000") then
          LED <= cpu_out(7 downto 0);
        end if;
      end if;
    end if;
  end process LED_BLINK;

  ------------------------------------------------------------------------------
  -- UART : UART controller
  ------------------------------------------------------------------------------
  UART : entity work.UART generic map (
    g_CLKS_PER_BIT => g_CLKS_PER_BIT
  ) port map (
    Clk => clk_cpu,
    Reset => reset_n,
    Rx_Serial => Rx,
    Write_Enable => we(0),
    Input_Data => cpu_out(7 downto 0),
    Address => address(3 downto 2),
    Enable => uart_en,
    Tx_Serial => Tx,
    Output_Data => uart_data
  );
  uart_en <= '1' when (address(31 downto 4) = x"0001001") and
                      (address(1 downto 0) = b"00") else '0';
  uart_data_ext <= (x"000000" & uart_data);

end Behavioral;
