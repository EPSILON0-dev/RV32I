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
--  Clk_Enable     --  Clock enable signal
--  Reset          --  Reset signal
--  Irq            --  Interrupt request signal
-- Memory Interface Signals
--  Input_Data     --  Input from memory
--  Address        --  Address of accessed memory
--  Output_Data    --  Output to memory
--  Write_Enable   --  Write enable signals
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Entity Section
--------------------------------------------------------------------------------
entity CPU is port
  (
    Clk          : in  std_logic;
    Clk_Enable   : in  std_logic;
    Reset        : in  std_logic;
    Irq          : in  std_logic;
    Input_Data   : in  std_logic_vector (31 downto 0);
    Address      : out std_logic_vector (31 downto 0);
    Output_Data  : out std_logic_vector (31 downto 0);
    Write_Enable : out std_logic_vector ( 3 downto 0)
  );
end CPU;

--------------------------------------------------------------------------------
-- Architecture Section
--------------------------------------------------------------------------------
architecture Behavioral of CPU is
  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  -- Instruction Cycle FSM
  signal fetch_phase   : std_logic;
  signal decode_phase  : std_logic;
  signal execute_phase : std_logic;
  signal state_advance : std_logic;
  signal fsm_instruction_state : std_logic_vector (1 downto 0) := (others=>'0');
  -- Program Counter
  signal branch_taken        : std_logic;
  signal signed_comparator   : std_logic;
  signal unsigned_comparator : std_logic;
  signal equality_comparator : std_logic;
  signal combined_comparator : std_logic;
  signal branch_address      : unsigned (31 downto 0);
  signal program_counter_r   : unsigned (31 downto 0) := (others => '0');
  -- Fetch register
  signal fetch_data_r : std_logic_vector (31 downto 0) := (others => '0');
  -- IRQ logic
  signal int_req_r    : std_logic := '0';
  signal int_req_serv : std_logic;
  -- Instruction Decoder
  signal i_immediate  : std_logic_vector (11 downto 0);
  signal s_immediate  : std_logic_vector (11 downto 0);
  signal b_immediate  : std_logic_vector (12 downto 0);
  signal j_immediate  : std_logic_vector (20 downto 0);
  signal immediate_r  : std_logic_vector (31 downto 0) := (others => '0');
  signal immediate_s  : std_logic_vector ( 3 downto 0);
  signal opcode_rs1_r : std_logic_vector ( 4 downto 0) := (others => '0');
  signal opcode_rs2_r : std_logic_vector ( 4 downto 0) := (others => '0');
  signal opcode_rd_r  : std_logic_vector ( 4 downto 0) := (others => '0');
  signal funct3_r     : std_logic_vector ( 2 downto 0) := (others => '0');
  signal funct7_r     : std_logic_vector ( 6 downto 0) := (others => '0');
  signal format_r     : std_logic;
  signal format_i     : std_logic;
  signal format_s     : std_logic;
  signal format_b     : std_logic;
  signal format_u     : std_logic;
  signal format_j     : std_logic;
  signal format_r_r   : std_logic := '0';
  signal format_i_r   : std_logic := '0';
  signal format_s_r   : std_logic := '0';
  signal format_b_r   : std_logic := '0';
  signal format_u_r   : std_logic := '0';
  signal format_j_r   : std_logic := '0';
  signal jarl         : std_logic;
  signal auipc        : std_logic;
  signal zicsr        : std_logic;
  signal uret         : std_logic;
  signal jarl_r       : std_logic := '0';
  signal auipc_r      : std_logic := '0';
  signal zicsr_r      : std_logic := '0';
  signal uret_r       : std_logic := '0';
  signal valid_funct7 : std_logic;
  -- Register File
  signal r_write  : std_logic;
  signal rd_data  : std_logic_vector(31 downto 0);
  signal rs1_data : std_logic_vector(31 downto 0);
  signal rs2_data : std_logic_vector(31 downto 0);
  -- Arythmetic and Logic Unit
  signal alu_output  : std_logic_vector (31 downto 0);
  signal alu_input   : std_logic_vector (31 downto 0);
  signal alu_op      : std_logic;
  signal alu_sub     : std_logic;
  signal alu_add     : std_logic_vector (31 downto 0);
  signal alu_xor     : std_logic_vector (31 downto 0);
  signal alu_or      : std_logic_vector (31 downto 0);
  signal alu_and     : std_logic_vector (31 downto 0);
  signal alu_slti    : std_logic_vector (31 downto 0);
  signal alu_sltiu   : std_logic_vector (31 downto 0);
  -- Shifter
  signal shift_op           : std_logic;
  signal shift_done         : std_logic;
  signal shift_type         : std_logic_vector ( 1 downto 0);
  signal shift_amount_r     : unsigned         ( 4 downto 0) := (others => '0');
  signal shifted_data       : std_logic_vector (31 downto 0);
  signal shift_right_r      : std_logic := '0';
  signal shift_arythmetic_r : std_logic := '0';
  signal shift_output_r     : std_logic_vector (31 downto 0) := (others => '0');
  signal shift_fetch_r      : std_logic := '0';
  signal shift_op_r         : std_logic := '0';
  -- Control and status registers
  signal csr_mask_imm     : std_logic_vector (31 downto 0);
  signal csr_mask         : std_logic_vector (31 downto 0);
  signal csr_write_enable : std_logic;
  signal csr_address      : std_logic_vector (11 downto 0);
  signal csr_data         : std_logic_vector (31 downto 0);
  signal csr_write_data   : std_logic_vector (31 downto 0);
  -- Counters/Timers
  signal csr_cycle        : std_logic_vector (63 downto 0) := (others => '0');
  -- Trap CSRs
  signal csr_utvec    : std_logic_vector (31 downto 0) := (others => '0');
  signal csr_ustatus  : std_logic_vector (31 downto 0);
  signal csr_uscratch : std_logic_vector (31 downto 0) := (others => '0');
  signal csr_ucause   : std_logic_vector (31 downto 0);
  signal csr_uepc     : std_logic_vector (31 downto 0) := (others => '0');
  signal csr_s_uie    : std_logic := '0';
  -- Memory Access Logic
  signal memory_load             : std_logic;
  signal memory_store            : std_logic;
  signal memory_access           : std_logic;
  signal access_address          : std_logic_vector (31 downto 0);
  signal ovb_access              : std_logic;
  signal access_width            : std_logic_vector ( 3 downto 0);
  signal ovb_access_phase        : std_logic;
  signal ovb_access_phase_done_r : std_logic := '0';
  -- Store Logic
  signal store_write_enable    : std_logic_vector ( 7 downto 0);
  signal internal_store_data   : std_logic_vector (31 downto 0);
  signal internal_write_enable : std_logic_vector ( 3 downto 0);
  -- Load Logic
  signal load_reg_r         : std_logic_vector (31 downto 0) := (others => '0');
  signal internal_load_data : std_logic_vector (31 downto 0);
  signal mux_load_data_3    : std_logic_vector ( 7 downto 0);
  signal mux_load_data_2    : std_logic_vector ( 7 downto 0);
  signal mux_load_data_1    : std_logic_vector ( 7 downto 0);
  signal mux_load_data_0    : std_logic_vector ( 7 downto 0);
  signal masked_load_data_3 : std_logic_vector ( 7 downto 0);
  signal masked_load_data_2 : std_logic_vector ( 7 downto 0);
  signal masked_load_data_1 : std_logic_vector ( 7 downto 0);
  signal masked_load_data_0 : std_logic_vector ( 7 downto 0);
  signal extended_load_data : std_logic_vector (31 downto 0);
  signal ext_byte           : std_logic_vector ( 7 downto 0);
  signal ext_half           : std_logic_vector ( 7 downto 0);
  signal load_phase_r       : std_logic := '0';
  -- Address Driver
  signal internal_address : std_logic_vector (31 downto 0);
  signal ovb_offset       : std_logic_vector ( 2 downto 0);
  signal ovb_offset_en    : std_logic;

begin
  ------------------------------------------------------------------------------
  -- INSTRUCTION_FSM : Instruction cycle finite state machine, next state gets
  --                   set if state_advance = '1'
  ------------------------------------------------------------------------------
  INSTRUCTION_FSM : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          fsm_instruction_state <= b"00";
        else
          if state_advance = '1' then
            case (fsm_instruction_state) is
              when b"00"  => fsm_instruction_state <= b"01";
              when b"01"  => fsm_instruction_state <= b"10";
              when others => fsm_instruction_state <= b"00";
            end case;
          end if;
        end if;
      end if;
    end if;
  end process INSTRUCTION_FSM;
  ------------------------------------------------------------------------------
  -- Instruction cycle signals
  ------------------------------------------------------------------------------
  fetch_phase   <= '1' when (fsm_instruction_state = b"00") else '0';
  decode_phase  <= '1' when (fsm_instruction_state = b"01") else '0';
  execute_phase <= '1' when (fsm_instruction_state = b"10") else '0';
  ------------------------------------------------------------------------------
  -- FSM state advance signals
  ------------------------------------------------------------------------------
  state_advance <= shift_done and (not shift_fetch_r) and ((not
  ovb_access_phase) or ovb_access_phase_done_r) and (not load_phase_r)
  and not int_req_serv;


  ------------------------------------------------------------------------------
  -- PROGRAM_COUNTER : Handles the instuction counting, branches and jumps
  ------------------------------------------------------------------------------
  PROGRAM_COUNTER : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          program_counter_r <= x"00000000";
        else
          -- Interrupt request
          if int_req_serv = '1' then
            program_counter_r <= unsigned(csr_utvec);
          else
            -- Post fetch increment
            if fetch_phase = '1' then
              program_counter_r <= program_counter_r + x"00000004";
            else
              -- Conditioned branch
              if (execute_phase and branch_taken and format_b_r) = '1' then
                program_counter_r <= branch_address;
              else
                -- Jump and link
                if (execute_phase and format_j_r) = '1' then
                  program_counter_r <= branch_address;
                else
                  -- Jump and link register
                  if (execute_phase and jarl_r) = '1' then
                    program_counter_r <= unsigned(alu_output);
                    else
                      -- Interrupt return
                      if (uret_r and execute_phase) = '1' then
                        program_counter_r <= unsigned(csr_uepc);
                      end if;
                    end if;
                  end if;
                end if;
              end if;
            end if;
          end if;
        end if;
    end if;
  end process PROGRAM_COUNTER;
  ------------------------------------------------------------------------------
  -- Branch address (signal of current opcode + immediate)
  ------------------------------------------------------------------------------
  branch_address <= program_counter_r + unsigned(immediate_r) - x"00000004";
  ------------------------------------------------------------------------------
  -- Branch condition signals
  ------------------------------------------------------------------------------
  signed_comparator   <= '1' when signed(rs1_data) <
                         signed(rs2_data) else '0';
  unsigned_comparator <= '1' when unsigned(rs1_data) <
                         unsigned(rs2_data) else '0';
  equality_comparator <= '1' when unsigned(rs1_data) =
                         unsigned(rs2_data) else '0';
  with funct3_r(2 downto 1) select combined_comparator <=
                         unsigned_comparator when b"11",
                         signed_comparator   when b"10",
                         equality_comparator when others;
  branch_taken <= combined_comparator xor funct3_r(0);


  ------------------------------------------------------------------------------
  -- FETCH_REGISTER : Captures the input opcode on decode phase
  ------------------------------------------------------------------------------
  FETCH_REGISTER : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          fetch_data_r <= x"00000000";
        else
          if decode_phase = '1' then
            fetch_data_r <= Input_Data;
          end if;
        end if;
      end if;
    end if;
  end process FETCH_REGISTER;


  ------------------------------------------------------------------------------
  -- IRQ_REGISTER : Captures the IRQ until it can be serviced
  ------------------------------------------------------------------------------
  IRQ_REGISTER : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          int_req_r <= '0';
        else
          if Irq = '1' then
            int_req_r <= '1';
          end if;
          if int_req_serv = '1' then
            int_req_r <= '0';
          end if;
        end if;
      end if;
    end if;
  end process IRQ_REGISTER;
  int_req_serv <= int_req_r and csr_s_uie and fetch_phase;


  ------------------------------------------------------------------------------
  -- INSTRUCTION_DECODE : Handles the decoding of the instruction
  ------------------------------------------------------------------------------
  INSTRUCTION_DECODE : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          opcode_rs1_r <= b"00000";
          opcode_rs2_r <= b"00000";
          opcode_rd_r  <= b"00000";
          funct3_r     <= b"000";
          funct7_r     <= b"0000000";
          immediate_r  <= x"00000000";
          format_r_r   <= '0';
          format_i_r   <= '0';
          format_s_r   <= '0';
          format_b_r   <= '0';
          format_u_r   <= '0';
          format_j_r   <= '0';
          jarl_r       <= '0';
          auipc_r      <= '0';
          zicsr_r      <= '0';
          uret_r       <= '0';
        else
          if decode_phase = '1' then
            opcode_rd_r  <= Input_Data(11 downto  7);
            opcode_rs1_r <= Input_Data(19 downto 15);
            opcode_rs2_r <= Input_Data(24 downto 20);
            funct3_r     <= Input_Data(14 downto 12);
            funct7_r     <= Input_Data(31 downto 25);
            format_r_r   <= format_r;
            format_i_r   <= format_i;
            format_s_r   <= format_s;
            format_b_r   <= format_b;
            format_u_r   <= format_u;
            format_j_r   <= format_j;
            jarl_r       <= jarl;
            auipc_r      <= auipc;
            zicsr_r      <= zicsr;
            uret_r       <= uret;
            case (immediate_s) is
              when b"1000" => immediate_r <=
                std_logic_vector(resize(signed(i_immediate), 32));
                when b"0100" => immediate_r <=
                std_logic_vector(resize(signed(s_immediate), 32));
                when b"0010" => immediate_r <=
                std_logic_vector(resize(signed(b_immediate), 32));
                when b"0001" => immediate_r <=
                std_logic_vector(resize(signed(j_immediate), 32));
                when others  => immediate_r <=
                (Input_Data(31 downto 12) & x"000");
            end case;
          end if;
        end if;
      end if;
    end if;
  end process INSTRUCTION_DECODE;
  ------------------------------------------------------------------------------
  -- Decoded immediates
  ------------------------------------------------------------------------------
  i_immediate <= Input_Data(31 downto 20);
  s_immediate <= (Input_Data(31 downto 25) & Input_Data(11 downto 7));
  b_immediate <= (Input_Data(31) & Input_Data(7) & Input_Data(30
                 downto 25) & Input_Data(11 downto 8) & b"0");
  j_immediate <= (Input_Data(31) & Input_Data(19 downto 12) &
                 Input_Data(20) & Input_Data(30 downto 25) &
                 Input_Data(24 downto 21) & b"0");
  ------------------------------------------------------------------------------
  -- Immediate select
  ------------------------------------------------------------------------------
  immediate_s <= (format_i & format_s & format_b & format_j);
  ------------------------------------------------------------------------------
  -- Format decode
  ------------------------------------------------------------------------------
  format_r <= '1' when Input_Data(6 downto 0) = b"0110011" else '0';
  format_i <= '1' when Input_Data(6 downto 0) = b"0000011" or
                       Input_Data(6 downto 0) = b"0010011" else '0' or jarl;
  format_s <= '1' when Input_Data(6 downto 0) = b"0100011" else '0';
  format_b <= '1' when Input_Data(6 downto 0) = b"1100011" else '0';
  format_u <= '1' when Input_Data(6 downto 0) = b"0010111" or
                       Input_Data(6 downto 0) = b"0110111" else '0';
  format_j <= '1' when Input_Data(6 downto 0) = b"1101111" else '0';
  ------------------------------------------------------------------------------
  -- Special opcodes decode
  ------------------------------------------------------------------------------
  jarl  <= '1' when Input_Data(6 downto 0) =  b"1100111" else '0';
  auipc <= '1' when Input_Data(6 downto 0) =  b"0010111" else '0';
  zicsr <= '1' when Input_Data(6 downto 0) =  b"1110011" else '0';
  uret  <= '1' when Input_Data             = x"00200073" else '0';
  ------------------------------------------------------------------------------
  -- Funct7 field validator
  ------------------------------------------------------------------------------
  valid_funct7 <= '1' when funct7_r = b"0000000" or
                           funct7_r = b"0100000" else '0';

  ------------------------------------------------------------------------------
  -- REGISTER_FILE: 64 RAM32X1D LUTs are used
  ------------------------------------------------------------------------------
  REGISTER_FILE : for I in 0 to 31 generate
    RAM32X1Q_H : RAM32X1D
    generic map (
      INIT => x"00000000")
    port map (
      DPO   => rs1_data(I),
      SPO   => open,
      A0    => opcode_rd_r(0),
      A1    => opcode_rd_r(1),
      A2    => opcode_rd_r(2),
      A3    => opcode_rd_r(3),
      A4    => opcode_rd_r(4),
      D     => rd_data(I),
      DPRA0 => opcode_rs1_r(0),
      DPRA1 => opcode_rs1_r(1),
      DPRA2 => opcode_rs1_r(2),
      DPRA3 => opcode_rs1_r(3),
      DPRA4 => opcode_rs1_r(4),
      WCLK  => Clk,
      WE    => r_write
    );
    RAM32X1Q_L : RAM32X1D
    generic map (
      INIT => x"00000000")
    port map (
      DPO   => rs2_data(I),
      SPO   => open,
      A0    => opcode_rd_r(0),
      A1    => opcode_rd_r(1),
      A2    => opcode_rd_r(2),
      A3    => opcode_rd_r(3),
      A4    => opcode_rd_r(4),
      D     => rd_data(I),
      DPRA0 => opcode_rs2_r(0),
      DPRA1 => opcode_rs2_r(1),
      DPRA2 => opcode_rs2_r(2),
      DPRA3 => opcode_rs2_r(3),
      DPRA4 => opcode_rs2_r(4),
      WCLK  => Clk,
      WE    => r_write
    );
  end generate REGISTER_FILE;
  ------------------------------------------------------------------------------
  -- Register file write enable
  ------------------------------------------------------------------------------
  r_write <= (((format_i_r or (format_r_r and valid_funct7)) and shift_done and
             (not shift_fetch_r)) or
             -- ALU and Shifter operations
             memory_load or
             -- Control and Status registers
             zicsr_r or
             -- Memory loads
             format_u_r or format_j_r or jarl_r or auipc_r)
             -- Everything else
             when state_advance = '1' and opcode_rd_r /= b"00000" and
             execute_phase = '1' and Clk_Enable = '1' else '0';
             -- Shared condition
  ------------------------------------------------------------------------------
  -- Register file priority input multiplexer
  ------------------------------------------------------------------------------
  rd_data <= std_logic_vector(branch_address) when auipc_r = '1' else
             csr_data when zicsr_r = '1' else
             extended_load_data when memory_load = '1' else
             immediate_r when format_u_r = '1' else
             std_logic_vector(program_counter_r) when (format_j_r or jarl_r) =
             '1' else alu_output when alu_op = '1' else shift_output_r;


  ------------------------------------------------------------------------------
  -- Arythmetic and Logic Unit
  ------------------------------------------------------------------------------
  alu_add <= std_logic_vector(unsigned(rs1_data) + unsigned(alu_input)) when
  alu_sub = '0' else std_logic_vector(unsigned(rs1_data) - unsigned(alu_input));
  alu_sub <= funct7_r(5) and format_r_r;
  alu_xor <= rs1_data xor alu_input;
  alu_and <= rs1_data and alu_input;
  alu_or  <= rs1_data  or alu_input;
  alu_slti  <= x"00000001" when signed(rs1_data) <
               signed(alu_input) else x"00000000";
  alu_sltiu <= x"00000001" when unsigned(rs1_data) <
               unsigned(alu_input) else x"00000000";
  with funct3_r select alu_output <=
  alu_add when b"000", alu_slti when b"010", alu_sltiu when b"011",
  alu_xor when b"100", alu_or   when b"110", alu_and   when b"111",
  x"00000000" when others;
  alu_op <= '0' when funct3_r(1 downto 0) = b"01" else '1';
  alu_input <= immediate_r when (format_i_r or jarl_r) = '1' else rs2_data;


  ------------------------------------------------------------------------------
  -- SHIFTER : Logical and arythmetic shifter
  ------------------------------------------------------------------------------
  SHIFTER : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          shift_amount_r <= b"00000";
          shift_right_r <= '0';
          shift_arythmetic_r <= '0';
          shift_output_r <= x"00000000";
          shift_fetch_r <= '0';
          shift_op_r <= '0';
        else
          if (shift_op and decode_phase) = '1' then
            -- Shift fetch prepare phase
            shift_right_r <= Input_Data(14);
            shift_arythmetic_r <= Input_Data(30);
            shift_fetch_r <= '1';
            shift_op_r <= '1';
          else
            if (shift_op_r and execute_phase) = '1' then
              if shift_fetch_r = '1' then
                -- Shift fetch phase
                shift_amount_r <= unsigned(alu_input(4 downto 0));
                shift_output_r <= rs1_data;
                shift_fetch_r <= '0';
              else
                -- Actual shift phase
                if shift_done = '0' then
                  shift_amount_r <= shift_amount_r - 1;
                else
                  shift_op_r <= '0';
                end if;
                shift_output_r <= shifted_data;
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process SHIFTER;
  ------------------------------------------------------------------------------
  -- Combinational shfter signals
  ------------------------------------------------------------------------------
  shift_op <= (not Input_Data(13)) and Input_Data(12) and Input_Data(4)
              and (format_i or format_r);
  shift_done <= '1' when shift_amount_r = b"000000" else '0';
  shift_type <= (shift_right_r & shift_arythmetic_r);
  with shift_type select shifted_data <=
  (b"0" & shift_output_r(31 downto 1)) when b"10",               -- SRL
  (shift_output_r(31) & shift_output_r(31 downto 1)) when b"11", -- SRA
  (shift_output_r(30 downto 0) & b"0") when others;              -- SLL


  ------------------------------------------------------------------------------
  -- CSR logic and signal
  ------------------------------------------------------------------------------
  csr_mask_imm <= (x"000000" & b"000" & opcode_rs1_r);
  csr_mask <= csr_mask_imm when funct3_r(2) = '1' else rs1_data;
  csr_address <= fetch_data_r(31 downto 20);
  with csr_address select csr_data <=
    csr_utvec               when x"005", -- User trap vector
    csr_ustatus             when x"000", -- User status
    csr_uscratch            when x"040", -- User scratch register
    csr_ucause              when x"042", -- User trap cause
    csr_uepc                when x"041", -- User return address
    csr_cycle(31 downto 0 ) when x"C00", -- Cycle
    csr_cycle(63 downto 32) when x"C80", -- Cycle high
    csr_cycle(31 downto 0 ) when x"C01", -- Cycle reused as Time
    csr_cycle(63 downto 32) when x"C81", -- Cycle high reused as Time high
    x"00000000"             when others;
  with funct3_r(1 downto 0) select csr_write_data <=
     csr_mask                     when b"01",
    (csr_data or csr_mask)        when b"10",
    (csr_data and (not csr_mask)) when b"11",
     csr_data                     when others;
  csr_ustatus <= (x"0000000" & b"000" & csr_s_uie);
  csr_ucause  <= x"00000008"; -- User external interrupt
  ------------------------------------------------------------------------------
  -- CSR : Control and status registers write control
  ------------------------------------------------------------------------------
  CSR : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          csr_utvec    <= (others => '0');
          csr_uscratch <= (others => '0');
        else
          if (zicsr_r and execute_phase and csr_write_enable) = '1' then
            if csr_address = x"005" then
              csr_utvec <= csr_write_data;
            end if;
            if csr_address = x"040" then
              csr_uscratch <= csr_write_data;
            end if;
            if csr_address = x"000" then
              csr_s_uie <= csr_write_data(0);
            end if;
          end if;
        end if;
      end if;
    end if;
  end process CSR;
  csr_write_enable <= '1' when opcode_rs1_r /= b"00000" else '0';
  ------------------------------------------------------------------------------
  -- CSR_UEPC_CNT : return address controller
  ------------------------------------------------------------------------------
  CSR_UEPC_CNT : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          csr_uepc <= (others => '0');
        else
          if int_req_serv = '1' then
            csr_uepc <= internal_address;
          else
            if (zicsr_r and execute_phase and csr_write_enable) = '1' and
            csr_address = x"041" then
              csr_uepc <= csr_write_data;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process CSR_UEPC_CNT;
  ------------------------------------------------------------------------------
  -- CSR_T_CNT : CSR attached counter and timer
  ------------------------------------------------------------------------------
  CSR_T_CNT : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if (Reset and Clk_Enable) = '1' then
        csr_cycle <= (others => '0');
      else
        csr_cycle <= std_logic_vector(unsigned(csr_cycle) + "1");
      end if;
    end if;
  end process CSR_T_CNT;


  ------------------------------------------------------------------------------
  -- Memory access signals
  ------------------------------------------------------------------------------
  access_address <= std_logic_vector(unsigned(rs1_data)+unsigned(immediate_r));
  memory_load <= execute_phase when
                 fetch_data_r(6 downto 0) = b"0000011" else '0';
  memory_store <= execute_phase when format_s_r = '1' else '0';
  memory_access <= memory_store or memory_load;
  ovb_access <= (access_address(0) or  access_address(1))
                when funct3_r(1 downto 0) = b"10" else
                (access_address(0) and access_address(1))
                when funct3_r(1 downto 0) = b"01" else '0';
  with funct3_r(1 downto 0) select access_width <=
    x"1" when b"00", x"3" when b"01", x"f" when b"10", x"0" when others;
  ovb_access_phase <= memory_access and ovb_access;
  ------------------------------------------------------------------------------
  -- OVB_PHASE : Over Boundries Access phase might be needed when the access
  --             isn't 4 alligned, in that case two accesses are needed, this
  --             phase stops the main FSM and allows for the access to happen
  ------------------------------------------------------------------------------
  OVB_PHASE : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          ovb_access_phase_done_r <= '0';
        else
          if (ovb_access_phase and (not load_phase_r)) = '1' then
            ovb_access_phase_done_r <= '1';
          else
            ovb_access_phase_done_r <= '0';
          end if;
        end if;
      end if;
    end if;
  end process OVB_PHASE;


  ------------------------------------------------------------------------------
  -- Store logic signals
  ------------------------------------------------------------------------------
  with access_address(1 downto 0) select store_write_enable <=
  (b"0"    & access_width & b"000") when b"11",
  (b"00"   & access_width & b"00" ) when b"10",
  (b"000"  & access_width & b"0"  ) when b"01",
  (b"0000" & access_width         ) when others;
  with access_address(1 downto 0) select internal_store_data <=
  (rs2_data( 7 downto 0 ) & rs2_data(31 downto 24) &
   rs2_data(23 downto 16) & rs2_data(15 downto 8 )) when b"11",
  (rs2_data(15 downto 8 ) & rs2_data( 7 downto 0 ) &
   rs2_data(31 downto 24) & rs2_data(23 downto 16)) when b"10",
  (rs2_data(23 downto 16) & rs2_data(15 downto 8 ) &
   rs2_data( 7 downto 0 ) & rs2_data(31 downto 24)) when b"01",
  (rs2_data(31 downto 24) & rs2_data(23 downto 16) &
   rs2_data(15 downto 8 ) & rs2_data( 7 downto 0 )) when others;
  internal_write_enable <= store_write_enable(7 downto 4) when
  ovb_access_phase_done_r = '1' else store_write_enable(3 downto 0);

  ------------------------------------------------------------------------------
  -- LOAD_REG : Temporarily holds part of data during OVB access
  ------------------------------------------------------------------------------
  LOAD_REG : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          load_reg_r <= x"00000000";
        else
          if ovb_access_phase_done_r = '0' then
            load_reg_r <= internal_load_data;
          end if;
        end if;
      end if;
    end if;
  end process LOAD_REG;
  ------------------------------------------------------------------------------
  -- LOAD_PHASE : Stops execution for one cycle to load the data
  ------------------------------------------------------------------------------
  LOAD_PHASE : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Clk_Enable = '1' then
        if Reset = '1' then
          load_phase_r <= '0';
        else
          if decode_phase = '1' and Input_Data(6 downto 0) = b"0000011" then
            load_phase_r <= '1';
          else
            load_phase_r <= '0';
          end if;
        end if;
      end if;
    end if;
  end process LOAD_PHASE;
  ------------------------------------------------------------------------------
  -- Load logic signal shift
  ------------------------------------------------------------------------------
  with access_address(1 downto 0) select internal_load_data <=
  (Input_Data(23 downto 16) & Input_Data(15 downto 8 ) &
   Input_Data( 7 downto 0 ) & Input_Data(31 downto 24)) when b"11",
  (Input_Data(15 downto 8 ) & Input_Data( 7 downto 0 ) &
   Input_Data(31 downto 24) & Input_Data(23 downto 16)) when b"10",
  (Input_Data( 7 downto 0 ) & Input_Data(31 downto 24) &
   Input_Data(23 downto 16) & Input_Data(15 downto 8 )) when b"01",
  (Input_Data(31 downto 24) & Input_Data(23 downto 16) &
   Input_Data(15 downto 8 ) & Input_Data( 7 downto 0 )) when others;
  ------------------------------------------------------------------------------
  -- Load logic signal multiplexer (LOAD_REG or direct from input)
  ------------------------------------------------------------------------------
  mux_load_data_3 <= load_reg_r(31 downto 24) when
  (store_write_enable(0) and ovb_access) = '1' else
  internal_load_data(31 downto 24);
  mux_load_data_2 <= load_reg_r(23 downto 16) when
  (store_write_enable(1) and ovb_access) = '1' else
  internal_load_data(23 downto 16);
  mux_load_data_1 <= load_reg_r(15 downto 8 ) when
  (store_write_enable(2) and ovb_access) = '1' else
  internal_load_data(15 downto 8 );
  mux_load_data_0 <= load_reg_r( 7 downto 0 ) when
  (store_write_enable(3) and ovb_access) = '1' else
  internal_load_data( 7 downto 0 );
  ------------------------------------------------------------------------------
  -- Load logic signal mask
  ------------------------------------------------------------------------------
  masked_load_data_3 <= mux_load_data_3 when access_width(3) = '1' else x"00";
  masked_load_data_2 <= mux_load_data_2 when access_width(2) = '1' else x"00";
  masked_load_data_1 <= mux_load_data_1 when access_width(1) = '1' else x"00";
  masked_load_data_0 <= mux_load_data_0 when access_width(0) = '1' else x"00";
  ------------------------------------------------------------------------------
  -- Load logic signal sign extension
  ------------------------------------------------------------------------------
  ext_byte <= x"ff" when (funct3_r = b"000" and
  internal_load_data(7) = '1') else x"00";
  ext_half <= x"ff" when ((funct3_r = b"001" and
  internal_load_data(15) = '1') or ext_byte(0) = '1') else x"00";
  extended_load_data <= (
  (masked_load_data_3 or ext_half(7 downto 0)) &
  (masked_load_data_2 or ext_half(7 downto 0)) &
  (masked_load_data_1 or ext_byte(7 downto 0)) &
  masked_load_data_0);


  ------------------------------------------------------------------------------
  -- Internal address logic
  ------------------------------------------------------------------------------
  ovb_offset <= (ovb_offset_en & b"00");
  ovb_offset_en <= (ovb_access_phase and (not load_phase_r)) when
  fetch_data_r(6 downto 0) = b"0000011" else ovb_access_phase_done_r;
  internal_address <=
  std_logic_vector(program_counter_r) when memory_access = '0' else
  std_logic_vector(unsigned(access_address) + unsigned(ovb_offset));
  ------------------------------------------------------------------------------
  -- Output assignments
  ------------------------------------------------------------------------------
  Address <= internal_address;
  Output_Data <= internal_store_data when
  (memory_access and format_s_r) = '1' else x"00000000";
  Write_Enable <= internal_write_enable when
  (memory_access and format_s_r) = '1' else b"0000";

end Behavioral;
