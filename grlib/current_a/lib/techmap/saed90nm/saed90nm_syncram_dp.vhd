------------------------------------------------------------------------------
-- $Id: saed90nm_syncram_dp.vhd 185 2010-02-17 20:49:54Z rickcox $
--
-- saed90nm specific RAMs
-- This contains 
-- 1) a parameterized saed90nm_syncram_dp design
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

  signal en1N, en2N : std_ulogic;
  signal wr1N, wr2N : std_ulogic;
  constant c0 : std_ulogic := '0';

begin

  a5b22 : if (abits = 5) AND (dbits = 22) generate
  begin
    en1N <= not enable1;
    wr1N <= not write1;
    en2N <= not enable2;
    wr2N <= not write2;
    t0 : SRAM22x32
         port map(CE1 => clk1, CSB1 => en1N, WEB1 => wr1N,
                  A1 => address1, I1 => datain1, O1 => dataout1,
                  OEB1 => c0,
                  CE2 => clk2, CSB2 => en2N, WEB2 => wr2N,
                  A2 => address2, I2 => datain2, O2 => dataout2,
                  OEB2 => c0 );
  end generate a5b22;

  a5b39 : if (abits = 5) AND (dbits = 39) generate
  begin
    en1N <= not enable1;
    wr1N <= not write1;
    en2N <= not enable2;
    wr2N <= not write2;
    t0 : SRAM39x32
         port map(CE1 => clk1, CSB1 => en1N, WEB1 => wr1N,
                  A1 => address1, I1 => datain1, O1 => dataout1,
                  OEB1 => c0,
                  CE2 => clk2, CSB2 => en2N, WEB2 => wr2N,
                  A2 => address2, I2 => datain2, O2 => dataout2,
                  OEB2 => c0 );
  end generate a5b39;

  --gener : if not ( ((abits = 5) AND (dbits = 22))
  --              or ((abits = 5) AND (dbits = 39)) ) generate
  --begin
  --  t0 : generic_syncram_dp generic map (tech => 0, abits => abits, dbits => dbits)
  --       port map (clk1, address1, datain1, dataout1, enable1, write1,
  --                 clk2, address2, datain2, dataout2, enable2, write2 );
  --end generate gener;
end;

