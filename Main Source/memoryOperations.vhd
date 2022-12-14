
--components : contain  data memory and pipeline4(mem_wb) used for memory operations
--read/ write in DM in Lc or Sc instruction .


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memoryOperations is
port(
    clk              : in std_logic;
    resetPipeline4   : in std_logic;
    memToRegIn4      : in std_logic;
    regWriteIn4      : in std_logic;
    branchIn4        : in std_logic;        
    memReadIn4       : in std_logic;
    memWriteIn4      : in std_logic;
    branchAddrIn4    : in std_logic_vector(31 downto 0);
    zeroFlagIn4      : in std_logic;
    aluResultIn4     : in std_logic_vector(31 downto 0);
    readData2In4     : in std_logic_vector(31 downto 0);
    registerIn4      : in std_logic_vector(4 downto 0);
	 registerIn4_temp     : inout std_logic_vector(4 downto 0);
    --OUTPUTs
    memToRegOut4     : out std_logic;
    regWriteOut4     : out std_logic;
    branchOut4       : out std_logic;
    branchAddrOut4   : out std_logic_vector(31 downto 0);
    aluResultOut4    : out std_logic_vector(31 downto 0);
    readDataMemOut4  : out std_logic_vector(31 downto 0);
    registerOut4     : out std_logic_vector(4 downto 0)
  );
end memoryOperations;

architecture behavioral of memoryOperations is
  
  component MEM_WB is
    port (
      clk               : in std_logic;
      resetPL          : in std_logic;
      --Store control unit signal
      --USED for WB:
      storedMemToReg    : in std_logic;
      storedRegWrite    : in std_logic;
      --Store data read from memory
      storedReadDataMem : in std_logic_vector(31 downto 0);
      --ALU
      storedAluResult   : in std_logic_vector(31 downto 0);
      --Stored write registers
      storedWriteReg    : in std_logic_vector(4 downto 0);
      --OUTPUTs
      getMemToReg       : out std_logic;
      getRegWrite       : out std_logic;
      getReadDataMem    : out std_logic_vector(31 downto 0);
      getAluResult      : out std_logic_vector(31 downto 0);
      getWriteReg       : out std_logic_vector(4 downto 0)
      
    );
  end component;
  
  component dataMemory is
    port(
      memWriteFlag  : in std_logic; --sc instrution
      memReadFlag   : in std_logic; --lc instrution
      address       : in std_logic_vector(31 downto 0); --EA for access to DM for read or write
      writeData     : in std_logic_vector(31 downto 0);
      readData      : out std_logic_vector(31 downto 0)
    );
  end component;
  
  signal sDataFromMem : std_logic_vector(31 downto 0);
  signal sregisterIn4_temp   :  std_logic_vector(4 downto 0); --to create feedback from registerIn4 input to use in forwarder unit

  
  begin
    
    branchOut4      <= branchIn4 and zeroFlagIn4; --if not_zero flag and branch control signal are active _> branch taken
    branchAddrOut4  <= branchAddrIn4; --pass branch address to use in pc
	 sregisterIn4_temp <= registerIn4 ;
	 registerIn4_temp <=sregisterIn4_temp; --to create feedback from registerIn4 input to use forwarder
    
    dataMemoryOp : dataMemory
      port map (memWriteFlag  => memWriteIn4, memReadFlag => memReadIn4, address => aluResultIn4, writeData => readData2In4, readData => sDataFromMem);
    
    pipeline : mem_wb
      port map (clk => clk, resetPL => resetPipeline4, storedMemToReg => memToRegIn4, storedRegWrite => regWriteIn4, storedReadDataMem => sDataFromMem,
        storedAluResult => aluResultIn4, storedWriteReg => registerIn4, getMemToReg => memToRegOut4, getRegWrite => regWriteOut4, getReadDataMem => readDataMemOut4, getAluResult => aluResultOut4, getWriteReg => registerOut4);
        
end behavioral;
