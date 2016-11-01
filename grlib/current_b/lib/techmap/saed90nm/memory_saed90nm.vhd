--- This is a test implementation styled after the saed32 nm library .
library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library saed90nm;
use saed90nm.SRAM46x128_1rw;
use saed90nm.SRAM32x64_1rw;
use saed90nm.SRAM8x1024_1rw;
-- pragma translate_on
entity saed90nm_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
  ); 
end;    

architecture behavioral of saed90nm_syncram is

    component SRAM46x128_1rw is
      port (
        A   : in  std_logic_vector( 6  downto 0 );
        O   : out std_logic_vector( 45  downto 0 );
        I   : in  std_logic_vector( 45  downto 0 );
        WEB  : in  std_logic;
        CSB  : in  std_logic;
        OEB  : in  std_logic;
        CE  : in  std_logic
      );
    end component;

    component SRAM32x64_1rw
      port (
        A   : in  std_logic_vector( 5  downto 0 );
        O   : out std_logic_vector( 31  downto 0 );
        I   : in  std_logic_vector( 31  downto 0 );
        WEB  : in  std_logic;
        CSB  : in  std_logic;
        OEB  : in  std_logic;
        CE  : in  std_logic
      );
    end component;

    component SRAM8x1024_1rw is
      port (
        CE      : in std_ulogic;
        A       : in std_logic_vector(9 downto 0);
        I       : in std_logic_vector(7 downto 0);
        O       : out std_logic_vector(7 downto 0);
        CSB     : in std_ulogic;
        WEB     : in std_ulogic;
        OEB     : in std_ulogic
      );
    end component;

    --component SRAM32x256_1rw
    --  port (
    --    CE      : in std_ulogic;
    --    A       : in std_logic_vector(7 downto 0);
    --    I       : in std_logic_vector(31 downto 0);
    --    O       : out std_logic_vector(31 downto 0);
    --    CSB     : in std_ulogic;
    --    WEB     : in std_ulogic;
    --    OEB     : in std_ulogic
    --  );
    --end component;

    --component SRAM32x16
    --  port (
    --    A1, A2   : in  std_logic_vector( 3 downto 0 );
    --    O1, O2   : out std_logic_vector( 31 downto 0 );
    --    I1, I2   : in  std_logic_vector( 31 downto 0 );
    --    WEB1, WEB2 : in  std_logic;
    --    CSB1, CSB2 : in  std_logic;
    --    OEB1, OEB2 : in  std_logic;
    --    CE1, CE2 : in  std_logic
    --  );
    --end component;  


  signal en1N : std_ulogic;
  signal wr1N : std_ulogic;


  --signal ahelp1 : std_logic_vector(3 downto abits) := (others => '0');
  signal ahelp2 : std_logic_vector(10 downto 0);
  signal outhelp : std_logic_vector(45 downto 0);
  --signal inhelp1: std_logic_vector(31 downto (dbits)) := (others => '0');
  signal inhelp2: std_logic_vector(45 downto 0);


  signal c0  : std_ulogic;
  signal c1  : std_ulogic;

begin
  c0 <= '0';
  c1 <= '1';
  ahelp2(10 downto abits) <= (others => '0');
  ahelp2((abits-1) downto 0) <= address;
  inhelp2(45 downto dbits) <= (others => '0');
  inhelp2((dbits-1) downto 0) <= datain;

  en1N <= not enable;
  wr1N <= not write;

  --a4b32: if (abits<=4) AND (dbits <=32) generate
  --begin

  --  t0: SRAM32x16
  --       port map(CE1 => clk, CSB1 => en1N, WEB1 => wr1N,
  --                A1 => ahelp2((abits-1) downto 0 ), I1 => inhelp2((dbits-1) downto 0), O1 => outhelp((dbits - 1) downto 0);,
  --                OEB1 => c0,
  --                CE2 => clk, CSB2 => en1N, WEB2 => wr1N,
  --                A2 => ahelp2((abits-1) downto 0 ), I2 => inhelp2((dbits-1) downto 0), O2 => open,
  --                OEB2 => c1 );
  --end generate a4b32;

  a10 : if (abits >= 8 and abits <= 10) AND (dbits <= 32) generate
  begin
    x : for i in 0 to ((dbits-1)/8) generate
      t0 : SRAM8x1024_1rw
           port map(CE => clk, CSB => en1N, WEB => wr1N,
                    A => ahelp2(9 downto 0), I => inhelp2(((i+1)*8)-1 downto i*8),
                    O => outhelp(((i+1)*8)-1 downto i*8),
                    OEB => c0 );
    end generate;     
  end generate a10;

  --a8b32 : if (abits = 8) AND (dbits <= 32) generate
  --begin
  --  t0 : SRAM32x256_1rw
  --       port map(CE => clk, CSB => en1N, WEB => wr1N,
  --                A => ahelp2((abits-1) downto 0), I => inhelp2((dbits-1) downto 0),
  --                O => outhelp((dbits - 1) downto 0);,
  --                OEB => c0 );
  --end generate a8b32;

  a6b32 : if (abits <= 6) AND (dbits <= 32) generate
  begin
    t0 : SRAM32x64_1rw
         port map(CE => clk, CSB => en1N, WEB => wr1N,
                  A => ahelp2(5 downto 0), I => inhelp2(31 downto 0),
                  O => outhelp(31 downto 0),
                  OEB => c0 );
  end generate a6b32;

  -- map this to the 32X39 DUAL port memory.
  a7b46 : if ((abits <= 7) AND (dbits > 32)) or (abits=7 AND dbits <= 46) generate
  begin
    t0 : SRAM46x128_1rw
         port map(CE => clk, CSB => en1N, WEB => wr1N,
                  A => ahelp2(6 downto 0), I => inhelp2(45 downto 0),
                  O => outhelp(45 downto 0),
                  OEB => c0 );
  end generate a7b46;

  --gener : if not ( ((abits = 10) AND (dbits = 8))
  --              or ((abits = 8) AND (dbits = 32)) 
  --              or ((abits = 6) AND (dbits = 32))
  --              or ((abits = 5) AND (dbits = 39)) ) generate
  --begin
  --  t0 : generic_syncram generic map (abits, dbits)
  --       port map (clk, address, datain, dataout, write);
  --end generate gener;
  dataout <= outhelp((dbits - 1) downto 0);
end;


library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library saed90nm;
use saed90nm.SRAM32x64;
use saed90nm.SRAM39x32;
-- pragma translate_on
entity saed90nm_syncram_dp is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk1      : in std_ulogic;
    address1  : in std_logic_vector((abits -1) downto 0);
    datain1   : in std_logic_vector((dbits -1) downto 0);
    dataout1  : out std_logic_vector((dbits -1) downto 0);
    enable1   : in std_ulogic;
    write1    : in std_ulogic;
    clk2      : in std_ulogic;
    address2  : in std_logic_vector((abits -1) downto 0);
    datain2   : in std_logic_vector((dbits -1) downto 0);
    dataout2  : out std_logic_vector((dbits -1) downto 0);
    enable2   : in std_ulogic;
    write2    : in std_ulogic
  ); 
end;  

architecture behavioral of saed90nm_syncram_dp is   
  component SRAM32x64 is
    port (
      CE1       : in std_ulogic;
      CSB1      : in std_ulogic;
      OEB1      : in std_ulogic;
      WEB1      : in std_ulogic;
      A1        : in std_logic_vector(5 downto 0);
      I1        : in std_logic_vector(31 downto 0);
      O1        : out std_logic_vector(31 downto 0);
      CE2       : in std_ulogic;
      CSB2      : in std_ulogic;
      OEB2      : in std_ulogic;
      WEB2      : in std_ulogic;
      A2        : in std_logic_vector(5 downto 0);
      I2        : in std_logic_vector(31 downto 0);
      O2        : out std_logic_vector(31 downto 0)
    );
  end component;

  component SRAM39x32 is
    port (
      CE1       : in std_ulogic;
      CSB1      : in std_ulogic;
      OEB1      : in std_ulogic;
      WEB1      : in std_ulogic;
      A1        : in std_logic_vector(4 downto 0);
      I1        : in std_logic_vector(38 downto 0);
      O1        : out std_logic_vector(38 downto 0);
      CE2       : in std_ulogic;
      CSB2      : in std_ulogic;
      OEB2      : in std_ulogic;
      WEB2      : in std_ulogic;
      A2        : in std_logic_vector(4 downto 0);
      I2        : in std_logic_vector(38 downto 0);
      O2        : out std_logic_vector(38 downto 0)
    );
  end component;
  signal en1N : std_ulogic;
  signal wr1N : std_ulogic;
  signal en2N : std_ulogic;
  signal wr2N : std_ulogic;


  signal ahelp1 : std_logic_vector(10 downto 0);
  signal outhelp1 : std_logic_vector(45 downto 0);
  signal inhelp1: std_logic_vector(45 downto 0);


  signal ahelp2 : std_logic_vector(10 downto 0);
  signal outhelp2 : std_logic_vector(45 downto 0);
  signal inhelp2: std_logic_vector(45 downto 0);

  signal c0  : std_ulogic;
  signal c1  : std_ulogic;

begin
  c0 <= '0';
  c1 <= '1';
  ahelp1(10 downto abits) <= (others => '0');
  ahelp1((abits-1) downto 0) <= address1;
  inhelp1(45 downto dbits) <= (others => '0');
  inhelp1((dbits-1) downto 0) <= datain1;

  ahelp2(10 downto abits) <= (others => '0');
  ahelp2((abits-1) downto 0) <= address1;
  inhelp2(45 downto dbits) <= (others => '0');
  inhelp2((dbits-1) downto 0) <= datain1;

  en1N <= not enable1;
  wr1N <= not write1;
  en2N <= not enable2;
  wr2N <= not write2;

  a6b32 : if (abits <= 6) AND (dbits <= 32) generate
  begin

  t0 : SRAM32x64
         port map(CE1 => clk1, CSB1 => en1N, WEB1 => wr1N,
                  A1 => ahelp1(5 downto 0), I1 => inhelp1(31 downto 0), O1 => outhelp1(31 downto 0),
                  OEB1 => c0,
                  CE2 => clk2, CSB2 => en2N, WEB2 => wr2N,
                  A2 => ahelp2(5 downto 0), I2 => inhelp2(31 downto 0), O2 => outhelp2(31 downto 0),
                  OEB2 => c0 );
  end generate a6b32;

  a5b39 : if (abits <= 5) AND ((dbits > 32) AND (dbits <= 39)) generate
  begin
    t0 : SRAM39x32
         port map(CE1 => clk1, CSB1 => en1N, WEB1 => wr1N,
                  A1 => ahelp1(4 downto 0), I1 => inhelp1(38 downto 0), O1 => outhelp1(38 downto 0),
                  OEB1 => c0,
                  CE2 => clk2, CSB2 => en2N, WEB2 => wr2N,
                  A2 => ahelp2(4 downto 0), I2 => inhelp2(38 downto 0), O2 => outhelp2(38 downto 0),
                  OEB2 => c0 );
  end generate a5b39;
  dataout1 <= outhelp1((dbits - 1) downto 0);
  dataout2 <= outhelp2((dbits - 1) downto 0);

end;


library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library saed90nm;
use saed90nm.SRAM32x128;
-- pragma translate_on

entity saed90nm_regfile_3p is
  generic ( abits : integer := 8; dbits : integer := 32 );
  port (
    wclk   : in  std_ulogic;
    waddr  : in  std_logic_vector((abits -1) downto 0);
    wdata  : in  std_logic_vector((dbits -1) downto 0);
    we     : in  std_ulogic;
    rclk   : in  std_ulogic;
    raddr1 : in  std_logic_vector((abits -1) downto 0);
    re1    : in  std_ulogic;
    rdata1 : out std_logic_vector((dbits -1) downto 0);
    raddr2 : in  std_logic_vector((abits -1) downto 0);
    re2    : in  std_ulogic;
    rdata2 : out std_logic_vector((dbits -1) downto 0)
  );
end;

architecture behavioral of saed90nm_regfile_3p is

  component SRAM32x128
    port (
      CE1       : in std_ulogic;
      CSB1      : in std_ulogic;
      OEB1      : in std_ulogic;
      WEB1      : in std_ulogic;
      A1        : in std_logic_vector(6 downto 0);
      I1        : in std_logic_vector(31 downto 0);
      O1        : out std_logic_vector(31 downto 0);
      CE2       : in std_ulogic;
      CSB2      : in std_ulogic;
      OEB2      : in std_ulogic;
      WEB2      : in std_ulogic;
      A2        : in std_logic_vector(6 downto 0);
      I2        : in std_logic_vector(31 downto 0);
      O2        : out std_logic_vector(31 downto 0)
    );
  end component;

  -- decoded chip selects
  signal cs_wr_aN  : std_ulogic;
  signal cs_r1_aN  : std_ulogic;
  signal cs_r2_aN  : std_ulogic;
  signal cs_wr_bN  : std_ulogic;
  signal cs_r1_bN  : std_ulogic;
  signal cs_r2_bN  : std_ulogic;

  -- addresses to the RAMs
  signal a_w  : std_logic_vector((abits - 2) downto 0);
  signal a_r1 : std_logic_vector((abits - 2) downto 0);
  signal a_r2 : std_logic_vector((abits - 2) downto 0);

  -- output enables
  signal oe1_aN : std_logic;
  signal oe1_bN : std_logic;
  signal oe2_aN : std_logic;
  signal oe2_bN : std_logic;

  signal wrN  : std_ulogic;


  --For testing purposes:
  signal r11 : std_logic_vector((dbits -1) downto 0);
  signal r12 : std_logic_vector((dbits -1) downto 0);
  signal r21 : std_logic_vector((dbits -1) downto 0);
  signal r22 : std_logic_vector((dbits -1) downto 0);

  --signal asdfclock : std_ulogic;

  signal c1  : std_ulogic;
  signal c0  : std_ulogic;
  signal dbits0  : std_logic_vector((dbits - 1) downto 0);

begin
  c1 <= '1';
  c0 <= '0';
  dbits0((dbits - 1) downto 0) <= (others => '0');

  a8b32: if (abits=8) AND (dbits=32) generate
  begin

  --CHIP select READ:
  cs_r1_aN <= NOT (NOT raddr1(7) AND re1);
  cs_r1_bN <= NOT (raddr1(7) AND re1);
  cs_r2_aN <= NOT (NOT raddr2(7) AND re2);
  cs_r2_bN <= NOT (raddr2(7) AND re2);

  --CHIP select WRITE:
  cs_wr_aN <= NOT (NOT waddr(7) AND we);
  cs_wr_bN <= NOT (waddr(7) AND we);

  --OUTPUT ENABLE
  oe1_aN <= NOT (re1 AND NOT raddr1(7));
  oe1_bN <= NOT (re1 AND raddr1(7));
  oe2_aN <= NOT (re2 AND NOT raddr2(7));
  oe2_bN <= NOT (re2 AND raddr2(7));

  --oe1_aN <= c0;
  --oe1_bN <= c0;
  --oe2_aN <= c0;
  --oe2_bN <= c0;

  --ADDRESSES
  a_w <= waddr(6 downto 0);
  a_r1 <= raddr1(6 downto 0);
  a_r2 <= raddr2(6 downto 0);

  wrN <= NOT we;

  --asdfclock <= not wclk;

  t_al: SRAM32x128
         port map(CE1 => wclk, CSB1 => cs_wr_aN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r1_aN,
                  OEB2 => oe1_aN, WEB2 => c1,
                  A2 => a_r1, I2 => dbits0, O2 => rdata1
                  );
  t_ar: SRAM32x128
         port map(CE1 => wclk, CSB1 => cs_wr_aN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r2_aN,
                  OEB2 => oe2_aN, WEB2 => c1,
                  A2 => a_r2, I2 => dbits0, O2 => rdata2
                  );
  t_ba: SRAM32x128
         port map(CE1 => wclk, CSB1 => cs_wr_bN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r1_bN,
                  OEB2 => oe1_bN, WEB2 => c1,
                  A2 => a_r1, I2 => dbits0, O2 => rdata1
                  );
  t_br: SRAM32x128
         port map(CE1 => wclk, CSB1 => cs_wr_bN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r2_bN,
                  OEB2 => oe2_bN, WEB2 => c1,
                  A2 => a_r2, I2 => dbits0, O2 => rdata2
                  );

  end generate a8b32;
end;



library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library saed90nm;
use saed90nm.SRAM32x64;
use saed90nm.SRAM32x128;
-- pragma translate_on
entity saed90nm_syncram_2p is
  generic ( abits : integer := 32; dbits : integer := 5 );
  port (
    rclk      : in std_ulogic;
    renable   : in std_ulogic;
    raddress  : in std_logic_vector((abits -1) downto 0);
    readout  : out std_logic_vector((dbits -1) downto 0);
    wclk      : in std_ulogic;
    write : in std_ulogic;
    waddress: in std_logic_vector((abits - 1) downto 0);
    datain : in std_logic_vector((dbits -1) downto 0)
  ); 
end;  

architecture behavioral of saed90nm_syncram_2p is   
  component SRAM32x64 is
    port (
      CE1       : in std_ulogic;
      CSB1      : in std_ulogic;
      OEB1      : in std_ulogic;
      WEB1      : in std_ulogic;
      A1        : in std_logic_vector(5 downto 0);
      I1        : in std_logic_vector(31 downto 0);
      O1        : out std_logic_vector(31 downto 0);
      CE2       : in std_ulogic;
      CSB2      : in std_ulogic;
      OEB2      : in std_ulogic;
      WEB2      : in std_ulogic;
      A2        : in std_logic_vector(5 downto 0);
      I2        : in std_logic_vector(31 downto 0);
      O2        : out std_logic_vector(31 downto 0)
    );
  end component;

  component SRAM32x128 is
    port (
      CE1       : in std_ulogic;
      CSB1      : in std_ulogic;
      OEB1      : in std_ulogic;
      WEB1      : in std_ulogic;
      A1        : in std_logic_vector(6 downto 0);
      I1        : in std_logic_vector(31 downto 0);
      O1        : out std_logic_vector(31 downto 0);
      CE2       : in std_ulogic;
      CSB2      : in std_ulogic;
      OEB2      : in std_ulogic;
      WEB2      : in std_ulogic;
      A2        : in std_logic_vector(6 downto 0);
      I2        : in std_logic_vector(31 downto 0);
      O2        : out std_logic_vector(31 downto 0)
    );
  end component;

  signal en2N : std_ulogic;
  signal wr1N : std_ulogic;


  signal ahelp1 : std_logic_vector(10 downto 0);
  signal inhelp1: std_logic_vector(45 downto 0);

  signal ahelp2 : std_logic_vector(10 downto 0);
  signal outhelp2 : std_logic_vector(45 downto 0);

  signal outhelp1 : std_logic_vector(45 downto 0);

  signal dbits0 : std_logic_vector(31 downto 0);

  signal cs0r : std_ulogic;
  signal cs1r : std_ulogic;

  signal cs0w : std_ulogic;
  signal cs1w : std_ulogic;

  signal re0 : std_ulogic;
  signal re1 : std_ulogic;

  signal apartr : std_logic_vector(6 downto 0);
  signal apartw : std_logic_vector(6 downto 0);

  signal c0  : std_ulogic;
  signal c1  : std_ulogic;

  begin
  dbits0 <= (others => '0');
  c0 <= '0';
  c1 <= '1';
  ahelp1(10 downto abits) <= (others => '0');
  ahelp1((abits-1) downto 0) <= waddress;
  inhelp1(45 downto dbits) <= (others => '0');
  inhelp1((dbits-1) downto 0) <= datain;

  ahelp2(10 downto abits) <= (others => '0');
  ahelp2((abits-1) downto 0) <= raddress;


  en2N <= not renable;
  wr1N <= not write;


  a6b32 : if (abits <= 6) and (dbits <= 32) generate
  begin

    x0 : SRAM32x64
      port map(CE1 => wclk, CSB1 => wr1N, OEB1 => c1,
        WEB1 => wr1N, A1 => ahelp1(5 downto 0), I1 => inhelp1(31 downto 0), O1 => open,
        CE2 => rclk, CSB2 => en2N, OEB2 => c0, 
        WEB2 => c1, A2 => ahelp2(5 downto 0), I2 => dbits0, O2 => outhelp2(31 downto 0)
        );

     readout <= outhelp2((dbits - 1) downto 0);

  end generate a6b32;


a8b32 : if (abits = 8) AND (dbits <= 32) generate

    apartw <= ahelp1(6 downto 0);
    apartr <= ahelp2(6 downto 0);

    cs0r <= ahelp2(7);
    cs1r <= NOT ahelp2(7);

    cs0w <= ahelp1(7);
    cs1w <= NOT ahelp1(7);

    re0 <= NOT ((NOT ahelp2(7)) AND renable);
    re1 <= NOT (ahelp2(7) AND renable);

    x0 : SRAM32x128
      port map(CE1 => wclk, CSB1 => cs0w, OEB1 => c1,
        WEB1 => wr1N, A1 => apartw, I1 => inhelp1(31 downto 0), O1 => open,

        CE2 => rclk, CSB2 => cs0r, OEB2 => re0, 
        WEB2 => c1, A2 => apartr, I2 => dbits0, O2 => outhelp1(31 downto 0)

        );

    x1 : SRAM32x128
      port map(CE1 => wclk, CSB1 => cs1w, OEB1 => c1,
        WEB1 => wr1N, A1 => apartw, I1 => inhelp1(31 downto 0), O1 => open,

        CE2 => rclk, CSB2 => cs1r, OEB2 => re1, 
        WEB2 => c1, A2 => apartr, I2 => dbits0, O2 => outhelp2(31 downto 0)

        );

    process (rclk, ahelp2, outhelp2, outhelp1)
    begin
      if  ahelp2(7) = '1' then
        readout  <= outhelp2((dbits-1) downto 0);
      elsif ahelp2(7) = '0' then
        readout <= outhelp1((dbits-1) downto 0);
      else
        readout <= (others => 'Z');
      end if;
    end process;

  end generate a8b32;
  end;