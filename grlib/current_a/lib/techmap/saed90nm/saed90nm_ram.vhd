------------------------------------------------------------------------------
-- $Id: saed90nm_ram.vhd 189 2010-02-25 22:17:44Z rickcox $
--
-- saed90nm specific RAMs
-- This contains 
-- 1) component statements for each physical RAM
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--  RAM Components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library saed90nm;
use saed90nm.SRAM22x32;
use saed90nm.SRAM39x32;
use saed90nm.SRAM8x1024_1rw;
use saed90nm.SRAM32x256_1rw;
use saed90nm.SRAM32x64;
-- pragma translate_on

package saed90nm_ram is

  component SRAM22x32 is
    port (
      CE1       : in std_ulogic;
      CSB1      : in std_ulogic;
      OEB1      : in std_ulogic;
      WEB1      : in std_ulogic;
      A1        : in std_logic_vector(4 downto 0);
      I1        : in std_logic_vector(21 downto 0);
      O1        : out std_logic_vector(21 downto 0);
      CE2       : in std_ulogic;
      CSB2      : in std_ulogic;
      OEB2      : in std_ulogic;
      WEB2      : in std_ulogic;
      A2        : in std_logic_vector(4 downto 0);
      I2        : in std_logic_vector(21 downto 0);
      O2        : out std_logic_vector(21 downto 0)
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

  component SRAM32x64
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

  component SRAM32x256_1rw
    port (
      CE      : in std_ulogic;
      A       : in std_logic_vector(7 downto 0);
      I       : in std_logic_vector(31 downto 0);
      O       : out std_logic_vector(31 downto 0);
      CSB     : in std_ulogic;
      WEB     : in std_ulogic;
      OEB     : in std_ulogic
    );
  end component;

end package;

