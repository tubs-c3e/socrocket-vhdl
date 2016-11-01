import usi
import usi.shell
import sys
import json
import usi.cci.parameter as cci #from import usi.api.parameter as cci

"""
$ core/tools/execute leon3mp sdram hello -s start_mindsgn.py
"""
@usi.on('end_of_initialization')
def export_vhdl(*k, **kw):
    #usi.shell.start()
    #dict = cci.readPropertyDict()
    #print json.dumps(dict['ahbctrl'],indent=2)
    execfile('vhdl/SysCtoVHDL/script_leon3mp.py')
    sys.exit(0)
