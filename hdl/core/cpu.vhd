--------------------------------------------------------------------------------
--                 ██████╗ ██╗   ██╗██████╗ ██████╗ ██╗                       --
--                 ██╔══██╗██║   ██║╚════██╗╚════██╗██║                       --
--                 ██████╔╝██║   ██║ █████╔╝ █████╔╝██║                       --
--                 ██╔══██╗╚██╗ ██╔╝ ╚═══██╗██╔═══╝ ██║                       --
--                 ██║  ██║ ╚████╔╝ ██████╔╝███████╗██║                       --
--                 ╚═╝  ╚═╝  ╚═══╝  ╚═════╝ ╚══════╝╚═╝                       --
--------------------------------------------------------------------------------
-- Written by: EPSILON0-dev
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
entity CPU is port
  (
    Clk          : in  std_logic;
    Reset        : in  std_logic;
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
  signal fsm_instruction_state : std_logic_vector (1 downto 0);
  -- Program Counter
  signal branch_taken        : std_logic;
  signal signed_comparator   : std_logic;
  signal unsigned_comparator : std_logic;
  signal equality_comparator : std_logic;
  signal combined_comparator : std_logic;
  signal branch_address      : unsigned (31 downto 0);
  signal program_counter_r   : unsigned (31 downto 0);
  -- Fetch Register
  signal fetch_data_r : std_logic_vector (31 downto 0);
  -- Instruction Decoder
  signal i_immediate  : std_logic_vector (11 downto 0);
  signal s_immediate  : std_logic_vector (11 downto 0);
  signal b_immediate  : std_logic_vector (12 downto 0);
  signal j_immediate  : std_logic_vector (20 downto 0);
  signal immediate_r  : std_logic_vector (31 downto 0);
  signal immediate_s  : std_logic_vector ( 3 downto 0);
  signal opcode_rs1_r : std_logic_vector ( 4 downto 0);
  signal opcode_rs2_r : std_logic_vector ( 4 downto 0);
  signal opcode_rd_r  : std_logic_vector ( 4 downto 0);
  signal funct3_r     : std_logic_vector ( 2 downto 0);
  signal funct7_r     : std_logic_vector ( 6 downto 0);
  signal format_r     : std_logic;
  signal format_i     : std_logic;
  signal format_s     : std_logic;
  signal format_b     : std_logic;
  signal format_u     : std_logic;
  signal format_j     : std_logic;
  signal jarl         : std_logic;
  signal auipc        : std_logic;
  signal valid_funct7 : std_logic;
  -- Register File
  type r_array is array (0 to 31) of std_logic_vector(31 downto 0);
  signal r_regs   : r_array;
  signal r_write  : std_logic;
  signal rd_data  : std_logic_vector(31 downto 0);
  signal rs1_data : std_logic_vector(31 downto 0);
  signal rs2_data : std_logic_vector(31 downto 0);
  -- Arythmetic and Logic Unit
  signal alu_output : std_logic_vector (31 downto 0);
  signal alu_input  : std_logic_vector (31 downto 0);
  signal alu_op     : std_logic;
  signal alu_sub    : std_logic;
  signal alu_add    : std_logic_vector (31 downto 0);
  signal alu_xor    : std_logic_vector (31 downto 0);
  signal alu_or     : std_logic_vector (31 downto 0);
  signal alu_and    : std_logic_vector (31 downto 0);
  signal alu_slti   : std_logic_vector (31 downto 0);
  signal alu_sltiu  : std_logic_vector (31 downto 0);
  -- Shifter
  signal shift_op           : std_logic;
  signal shift_done         : std_logic;
  signal shift_type         : std_logic_vector ( 1 downto 0);
  signal shift_amount_r     : unsigned         ( 4 downto 0);
  signal shifted_data       : std_logic_vector (31 downto 0);
  signal shift_right_r      : std_logic;
  signal shift_arythmetic_r : std_logic;
  signal shift_output_r     : std_logic_vector (31 downto 0);
  signal shift_fetch_r      : std_logic;
  -- Memory Access Logic
  signal memory_load             : std_logic;
  signal memory_store            : std_logic;
  signal memory_access           : std_logic;
  signal access_address          : std_logic_vector (31 downto 0);
  signal access_offset           : std_logic_vector ( 1 downto 0);
  signal ovb_access              : std_logic;
  signal access_width            : std_logic_vector ( 3 downto 0);
  signal ovb_access_phase        : std_logic;
  signal ovb_access_phase_done_r : std_logic;
  -- Store Logic
  signal store_write_enable    : std_logic_vector ( 7 downto 0);
  signal internal_store_data   : std_logic_vector (31 downto 0);
  signal internal_write_enable : std_logic_vector ( 3 downto 0);
  -- Load Logic
  signal load_reg_r         : std_logic_vector (31 downto 0);
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
  -- Address Driver
  signal internal_address : std_logic_vector (31 downto 0);
  signal ovb_offset       : std_logic_vector ( 2 downto 0);

begin
  ------------------------------------------------------------------------------
  -- INSTRUCTION_FSM : Instruction cycle finite state machine, next state gets
  --                   set if state_advance = '1'
  ------------------------------------------------------------------------------
  INSTRUCTION_FSM : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
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
  state_advance <= shift_done and (not shift_fetch_r) and
  ((not ovb_access_phase) or ovb_access_phase_done_r);


  ------------------------------------------------------------------------------
  -- PROGRAM_COUNTER : Handles the instuction counting, branches and jumps
  ------------------------------------------------------------------------------
  PROGRAM_COUNTER : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Reset = '1' then
        program_counter_r <= x"00000000";
      else
        if fetch_phase = '1' then
          program_counter_r <= program_counter_r + x"00000004";
        else
          if (execute_phase and branch_taken and format_b) = '1' then
            program_counter_r <= branch_address;
          else
            if (execute_phase and format_j) = '1' then
              program_counter_r <= branch_address;
            else
              if (execute_phase and jarl) = '1' then
                program_counter_r <= unsigned(alu_output);
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
  -- FETCH_REGISTER : Captures the input opcode on every fetch phase
  ------------------------------------------------------------------------------
  FETCH_REGISTER : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Reset = '1' then
        fetch_data_r <= x"00000000";
      else
        if fetch_phase = '1' then
          fetch_data_r <= Input_Data;
        end if;
      end if;
    end if;
  end process FETCH_REGISTER;


  ------------------------------------------------------------------------------
  -- INSTRUCTION_DECODE : Handles the decoding of the instruction
  ------------------------------------------------------------------------------
  INSTRUCTION_DECODE : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Reset = '1' then
        opcode_rs1_r <= b"00000";
        opcode_rs2_r <= b"00000";
        opcode_rd_r  <= b"00000";
        funct3_r     <= b"000";
        funct7_r     <= b"0000000";
        immediate_r  <= x"00000000";
      else
        if decode_phase = '1' then
          opcode_rd_r  <= fetch_data_r(11 downto  7);
          opcode_rs1_r <= fetch_data_r(19 downto 15);
          opcode_rs2_r <= fetch_data_r(24 downto 20);
          funct3_r     <= fetch_data_r(14 downto 12);
          funct7_r     <= fetch_data_r(31 downto 25);
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
              (fetch_data_r(31 downto 12) & x"000");
          end case;
        end if;
      end if;
    end if;
  end process INSTRUCTION_DECODE;
  ------------------------------------------------------------------------------
  -- Decoded immediates
  ------------------------------------------------------------------------------
  i_immediate <= fetch_data_r(31 downto 20);
  s_immediate <= (fetch_data_r(31 downto 25) & fetch_data_r(11 downto 7));
  b_immediate <= (fetch_data_r(31) & fetch_data_r(7) & fetch_data_r(30
                 downto 25) & fetch_data_r(11 downto 8) & b"0");
  j_immediate <= (fetch_data_r(31) & fetch_data_r(19 downto 12) &
                 fetch_data_r(20) & fetch_data_r(30 downto 25) &
                 fetch_data_r(24 downto 21) & b"0");
  ------------------------------------------------------------------------------
  -- Immediate select
  ------------------------------------------------------------------------------
  immediate_s <= (format_i & format_s & format_b & format_j);
  ------------------------------------------------------------------------------
  -- Format decode
  ------------------------------------------------------------------------------
  format_r <= '1' when fetch_data_r(6 downto 0) = b"0110011" else '0';
  format_i <= '1' when fetch_data_r(6 downto 0) = b"0000011" or
                       fetch_data_r(6 downto 0) = b"0010011" else '0' or jarl;
  format_s <= '1' when fetch_data_r(6 downto 0) = b"0100011" else '0';
  format_b <= '1' when fetch_data_r(6 downto 0) = b"1100011" else '0';
  format_u <= '1' when fetch_data_r(6 downto 0) = b"0010111" or
                       fetch_data_r(6 downto 0) = b"0110111" else '0';
  format_j <= '1' when fetch_data_r(6 downto 0) = b"1101111" else '0';
  ------------------------------------------------------------------------------
  -- Special opcodes decode
  ------------------------------------------------------------------------------
  jarl  <= '1' when fetch_data_r(6 downto 0) = b"1100111" else '0';
  auipc <= '1' when fetch_data_r(6 downto 0) = b"0010111" else '0';
  ------------------------------------------------------------------------------
  -- Funct7 field validator
  ------------------------------------------------------------------------------
  valid_funct7 <= '1' when funct7_r = b"0000000" or
                           funct7_r = b"0100000" else '0';

  ------------------------------------------------------------------------------
  -- REGISTER_FILE: 64 RAM32X1D LUTs are used
  ------------------------------------------------------------------------------
  REGISTER_FILE : process (Clk) begin
    if (Clk'event and Clk = '1') then
      if (r_write = '1' and opcode_rd_r /= b"00000") then
        r_regs(to_integer(unsigned(opcode_rd_r))) <= rd_data;
      end if;
    end if;
  end process;
  rs1_data <= r_regs(to_integer(unsigned(opcode_rs1_r)));
  rs2_data <= r_regs(to_integer(unsigned(opcode_rs2_r)));
  ------------------------------------------------------------------------------
  -- Register file write enable
  ------------------------------------------------------------------------------
  r_write <= (((format_i or (format_r and valid_funct7)) and shift_done and
             (not shift_fetch_r)) or
             -- ALU and Shifter operations
             (format_u or format_j or jarl or auipc or memory_load))
             -- Everything else
             when opcode_rd_r /= b"00000" and execute_phase = '1' else '0';
             -- Shared condition
  ------------------------------------------------------------------------------
  -- Register file priority input multiplexer
  ------------------------------------------------------------------------------
  rd_data <= std_logic_vector(branch_address) when auipc = '1' else
             extended_load_data when memory_load = '1' else
             immediate_r when format_u = '1' else
             std_logic_vector(program_counter_r) when (format_j or jarl) = '1'
             else alu_output when alu_op = '1' else shift_output_r;


  ------------------------------------------------------------------------------
  -- Arythmetic and Logic Unit
  ------------------------------------------------------------------------------
  alu_sub <= funct7_r(5) and format_r;
  alu_add <= std_logic_vector(unsigned(rs1_data) + unsigned(alu_input)) when
  alu_sub = '0' else std_logic_vector(unsigned(rs1_data) - unsigned(alu_input));
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
  alu_input <= immediate_r when (format_i or jarl) = '1' else rs2_data;


  ------------------------------------------------------------------------------
  -- SHIFTER : Logical and arythmetic shifter
  ------------------------------------------------------------------------------
  SHIFTER : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Reset = '1' then
        shift_amount_r <= b"00000";
        shift_right_r <= '0';
        shift_arythmetic_r <= '0';
        shift_output_r <= x"00000000";
        shift_fetch_r <= '0';
      else
        if (shift_op and decode_phase) = '1' then
          -- Shift fetch prepare phase
          shift_right_r <= fetch_data_r(14);
          shift_arythmetic_r <= fetch_data_r(30);
          shift_fetch_r <= '1';
        else
          if (shift_op and execute_phase) = '1' then
            if shift_fetch_r = '1' then
              -- Shift fetch phase
              shift_fetch_r <= '0';
              shift_output_r <= rs1_data;
              shift_amount_r <= unsigned(alu_input(4 downto 0));
            else
              -- Actual shift phase
              if shift_done = '0' then
                shift_amount_r <= shift_amount_r - 1;
              end if;
              shift_output_r <= shifted_data;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process SHIFTER;
  ------------------------------------------------------------------------------
  -- Combinational shfter signals
  ------------------------------------------------------------------------------
  shift_op <= (not fetch_data_r(13)) and fetch_data_r(12) and fetch_data_r(4)
              and (format_i or format_r);
  shift_done <= '1' when shift_amount_r = b"000000" else '0';
  shift_type <= (shift_right_r & shift_arythmetic_r);
  with shift_type select shifted_data <=
  (b"0" & shift_output_r(31 downto 1)) when b"10",               -- SRL
  (shift_output_r(31) & shift_output_r(31 downto 1)) when b"11", -- SRA
  (shift_output_r(30 downto 0) & b"0") when others;              -- SLL


  ------------------------------------------------------------------------------
  -- Memory access signals
  ------------------------------------------------------------------------------
  access_address <= std_logic_vector(unsigned(rs1_data)+unsigned(immediate_r));
  access_offset <= access_address(1 downto 0);
  memory_load <= execute_phase when
                 fetch_data_r(6 downto 0) = b"0000011" else '0';
  memory_store <= execute_phase when format_s = '1' else '0';
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
      if Reset = '1' then
        ovb_access_phase_done_r <= '0';
      else
        if ovb_access_phase = '1' then
          ovb_access_phase_done_r <= '1';
        else
          ovb_access_phase_done_r <= '0';
        end if;
      end if;
    end if;
  end process OVB_PHASE;


  ------------------------------------------------------------------------------
  -- Store logic signals
  ------------------------------------------------------------------------------
  store_write_enable <=
  (b"0"    & access_width & b"000") when access_offset = "11" else
  (b"00"   & access_width & b"00" ) when access_offset = "10" else
  (b"000"  & access_width & b"0"  ) when access_offset = "01" else
  (b"0000" & access_width         );
  internal_store_data <=
  (rs2_data( 7 downto 0 ) & rs2_data(31 downto 24) &
   rs2_data(23 downto 16) & rs2_data(15 downto 8 ))
   when access_offset = b"11" else
  (rs2_data(15 downto 8 ) & rs2_data( 7 downto 0 ) &
   rs2_data(31 downto 24) & rs2_data(23 downto 16))
   when access_offset = b"10" else
  (rs2_data(23 downto 16) & rs2_data(15 downto 8 ) &
   rs2_data( 7 downto 0 ) & rs2_data(31 downto 24))
   when access_offset = b"01" else
  (rs2_data(31 downto 24) & rs2_data(23 downto 16) &
   rs2_data(15 downto 8 ) & rs2_data( 7 downto 0 ));
  internal_write_enable <= store_write_enable(7 downto 4) when
  ovb_access_phase_done_r = '1' else store_write_enable(3 downto 0);


  ------------------------------------------------------------------------------
  -- LOAD_REG : Temporarily holds part of data during OVB access
  ------------------------------------------------------------------------------
  LOAD_REG : process (Clk) is
  begin
    if (Clk'event and Clk = '1') then
      if Reset = '1' then
        load_reg_r <= x"00000000";
      else
        if ovb_access_phase_done_r = '0' then
          load_reg_r <= internal_load_data;
        end if;
      end if;
    end if;
  end process LOAD_REG;
  ------------------------------------------------------------------------------
  -- Load logic signal shift
  ------------------------------------------------------------------------------
  internal_load_data <=
  (Input_Data(23 downto 16) & Input_Data(15 downto 8 ) &
   Input_Data( 7 downto 0 ) & Input_Data(31 downto 24))
   when access_offset = "11" else
  (Input_Data(15 downto 8 ) & Input_Data( 7 downto 0 ) &
   Input_Data(31 downto 24) & Input_Data(23 downto 16))
   when access_offset = "10" else
  (Input_Data( 7 downto 0 ) & Input_Data(31 downto 24) &
   Input_Data(23 downto 16) & Input_Data(15 downto 8 ))
   when access_offset = "01" else
  (Input_Data(31 downto 24) & Input_Data(23 downto 16) &
   Input_Data(15 downto 8 ) & Input_Data( 7 downto 0 ));
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
  ovb_offset <= (ovb_access_phase_done_r & b"00");
  internal_address <=
  std_logic_vector(program_counter_r) when memory_access = '0' else
  std_logic_vector(unsigned(access_address) + unsigned(ovb_offset));
  ------------------------------------------------------------------------------
  -- Output assignments
  ------------------------------------------------------------------------------
  Address <= internal_address;
  Output_Data <= internal_store_data when
  (memory_access and format_s) = '1' else x"00000000";
  Write_Enable <= internal_write_enable when
  (memory_access and format_s) = '1' else b"0000";

end Behavioral;
