------------------------------------------------------------------------------
-- $Id: saed90nm_syncram.vhd 189 2010-02-25 22:17:44Z rickcox $
--
-- saed90nm specific RAMs
-- This contains 
-- 1) a parameterized saed90nm_syncram design
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

  signal en1N, en2N : std_ulogic;
  signal wr1N, wr2N : std_ulogic;
  constant c0  : std_ulogic := '0';
  constant c1  : std_ulogic := '1';

begin

  a10b8 : if (abits = 10) AND (dbits = 8) generate
  begin
    en1N <= not enable;
    wr1N <= not write;
    t0 : SRAM8x1024_1rw
         port map(CE => clk, CSB => en1N, WEB => wr1N,
                  A => address, I => datain, O => dataout,
                  OEB => c0 );
  end generate a10b8;

  a8b32 : if (abits = 8) AND (dbits = 32) generate
  begin
    en1N <= not enable;
    wr1N <= not write;
    t0 : SRAM32x256_1rw
         port map(CE => clk, CSB => en1N, WEB => wr1N,
                  A => address, I => datain, O => dataout,
                  OEB => c0 );
  end generate a8b32;

  a6b32 : if (abits = 6) AND (dbits = 32) generate
  begin
    en1N <= not enable;
    wr1N <= not write;
    t0 : SRAM32x64
         port map(CE1 => clk, CSB1 => en1N, WEB1 => wr1N,
                  A1 => address, I1 => datain, O1 => dataout,
                  OEB1 => c0,
                  CE2 => clk, CSB2 => en1N, WEB2 => wr1N,
                  A2 => address, I2 => datain, O2 => open,
                  OEB2 => c1 );
  end generate a6b32;

  -- map this to the 32X39 DUAL port memory.
  a5b39 : if (abits = 5) AND (dbits = 39) generate
  begin
    en1N <= not enable;
    wr1N <= not write;
    t0 : SRAM39x32
         port map(CE1 => clk, CSB1 => en1N, WEB1 => wr1N,
                  A1 => address, I1 => datain, O1 => dataout,
                  OEB1 => c0,
                  CE2 => clk, CSB2 => en1N, WEB2 => wr1N,
                  A2 => address, I2 => datain, O2 => open,
                  OEB2 => c1 );

  end generate a5b39;

  --gener : if not ( ((abits = 10) AND (dbits = 8))
  --              or ((abits = 8) AND (dbits = 32)) 
  --              or ((abits = 6) AND (dbits = 32))
  --              or ((abits = 5) AND (dbits = 39)) ) generate
  --begin
  --  t0 : generic_syncram generic map (abits, dbits)
  --       port map (clk, address, datain, dataout, write);
  --end generate gener;
end;

