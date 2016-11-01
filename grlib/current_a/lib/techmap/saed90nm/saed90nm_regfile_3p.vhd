------------------------------------------------------------------------------
-- $Id: saed90nm_regfile_3p.vhd 140 2009-11-30 20:26:13Z rickcox $
--
-- saed90nm specific RAMs
-- This contains 
-- 1) a parameterized saed90nm_regfile_3p design
--    that either instantiates technology specific RAM cells
--    or calls the technology independent RAM generator.
--    This latter case will result in FF based RAMS
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--  RAM Instantiations
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
--use techmap.allmem.all;
use techmap.saed90nm_ram.all;
-- pragma translate_off
library saed90nm;
use saed90nm.SRAM22x32;
use saed90nm.SRAM39x32;
use saed90nm.SRAM8x1024_1rw;
use saed90nm.SRAM32x256_1rw;
use saed90nm.SRAM32x64;
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

  -- decoded chip selects
  signal cs_wr_aN  : std_ulogic;
  signal cs_r1_aN  : std_ulogic;
  signal cs_r2_aN  : std_ulogic;
  signal cs_wr_bN  : std_ulogic;
  signal cs_r1_bN  : std_ulogic;
  signal cs_r2_bN  : std_ulogic;
  signal cs_wr_cN  : std_ulogic;
  signal cs_r1_cN  : std_ulogic;
  signal cs_r2_cN  : std_ulogic;
 
  -- addresses to the RAMs
  signal a_w  : std_logic_vector((abits - 3) downto 0);
  signal a_r1 : std_logic_vector((abits - 3) downto 0);
  signal a_r2 : std_logic_vector((abits - 3) downto 0);
  
  -- read output enables
  signal oe1_aN : std_logic;
  signal oe1_bN : std_logic;
  signal oe1_cN : std_logic;
  signal oe2_aN : std_logic;
  signal oe2_bN : std_logic;
  signal oe2_cN : std_logic;

  signal wrN  : std_ulogic;
  
  constant c1  : std_ulogic := '1';
  constant c0  : std_ulogic := '0';
  constant dbits0  : std_logic_vector((dbits - 1) downto 0) := (others => '0');



begin

  a8b32 : if (abits = 8) AND (dbits = 32) generate
  begin
    -- 6 dual port rams used to implement a 1w, 2r configuration
    -- stacked in 2 banks of 3 high to get enough addresses - A, B, C
    -- both left and right banks written in parallel on port1
    -- independent reads on port2 - left bank is read1, right bank is read2
    --
    --    AL    AR  : addresses 0-63
    --    BL    BR  : addrsses 64-127
    --    CL    CR  : addresses 127-255 (only 192 addresses are actually used
    --    ^     ^
    --    |     +-- Right bank write port 1 is write, write port 2 is unused
    --    |         Right bank read port 1 is unused, read port 2 is read1
    --    |
    --    + ------- Left bank write port 1 is write, write port 2 is unused
    --              Left bank read port 1 is unused, read port 2 is read2

  -- Decode chip selects for banks A, B and C from 2 MS address bits
  cs_wr_aN <= NOT ( NOT waddr(7) AND NOT waddr(6) );
  cs_wr_bN <= NOT ( NOT waddr(7) AND     waddr(6) );
  cs_wr_cN <= NOT ( waddr(7) );    -- only 192 of the 256 addresses are implemented
  cs_r1_aN <= NOT ( NOT raddr1(7) AND NOT raddr1(6) );
  cs_r1_bN <= NOT ( NOT raddr1(7) AND     raddr1(6) );
  cs_r1_cN <= NOT ( raddr1(7) );   -- only 192 of the 256 addresses are implemented  
  cs_r2_aN <= NOT ( NOT raddr2(7) AND NOT raddr2(6) );
  cs_r2_bN <= NOT ( NOT raddr2(7) AND     raddr2(6) );
  cs_r2_cN <= NOT ( raddr2(7) );   -- only 192 of the 256 addresses are implemented

  -- Decode OE for each bank - each bank uses wired tristates mutual exclusively
  oe1_aN <= NOT ( re1 AND NOT raddr1(7) AND NOT raddr1(6) );
  oe1_bN <= NOT ( re1 AND NOT raddr1(7) AND     raddr1(6) );
  oe1_cN <= NOT ( re1 AND raddr1(7) );    -- only 192 of the 256 addresses are implemented
  oe2_aN <= NOT ( re2 AND NOT raddr2(7) AND NOT raddr2(6) );
  oe2_bN <= NOT ( re2 AND NOT raddr2(7) AND     raddr2(6) );
  oe2_cN <= NOT ( re2 AND raddr2(7) );    -- only 192 of the 256 addresses are implemented

  -- Addresses to the RAMs - upper 2 bits used for chip selects
  a_w  <= waddr(5 downto 0);
  a_r1 <= raddr1(5 downto 0);
  a_r2 <= raddr2(5 downto 0);
    
  wrN <= NOT we;
  
    t_al : SRAM32x64
         port map(CE1 => wclk, CSB1 => cs_wr_aN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r1_aN,
                  OEB2 => oe1_aN, WEB2 => c1,
                  A2 => a_r1, I2 => dbits0, O2 => rdata1
                  );
    t_ar : SRAM32x64
         port map(CE1 => wclk, CSB1 => cs_wr_aN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r2_aN,
                  OEB2 => oe2_aN, WEB2 => c1,
                  A2 => a_r2, I2 => dbits0, O2 => rdata2
                  );
    t_bl : SRAM32x64
         port map(CE1 => wclk, CSB1 => cs_wr_bN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r1_bN,
                  OEB2 => oe1_bN, WEB2 => c1,
                  A2 => a_r1, I2 => dbits0, O2 => rdata1
                  );
    t_br : SRAM32x64
         port map(CE1 => wclk, CSB1 => cs_wr_bN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r2_bN,
                  OEB2 => oe2_bN, WEB2 => c1,
                  A2 => a_r2, I2 => dbits0, O2 => rdata2
                  );
    t_cl : SRAM32x64
         port map(CE1 => wclk, CSB1 => cs_wr_cN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r1_cN,
                  OEB2 => oe1_cN, WEB2 => c1,
                  A2 => a_r1, I2 => dbits0, O2 => rdata1
                  );
    t_cr : SRAM32x64
         port map(CE1 => wclk, CSB1 => cs_wr_cN,
                  OEB1 => c1, WEB1 => wrN,
                  A1 => a_w , I1 => wdata, O1 => open,
                  CE2 => rclk, CSB2 => cs_r2_cN,
                  OEB2 => oe2_cN, WEB2 => c1,
                  A2 => a_r2, I2 => dbits0, O2 => rdata2
                  );

  end generate a8b32;

-- no alternative implementations!

end;

