﻿import usi.cci.parameter as cci #from import usi.api.parameter as cci
import timeit
from jinja2 import Environment, FileSystemLoader
import subprocess
import os
import shutil

def intToHex(integer_dict):
    return '16#'+'%03X'%integer_dict['value']+'#'
    
def set_var(variable):
    if variable.has_key('base'):
        if variable['base'] == 'hex':
            return '16#'+'%03X'%variable['value']+'#'
    elif isinstance(variable['value'], bool):
        return str(int(variable['value']))
    else:
        return variable['value']
    
def create_generic_map(values):
    var_string = ''
    if isinstance(values, dict):
        key = values.keys()
        for i in key:
            if not isinstance(values[i], list):
                if 'vhdl_name' in  values[i]:
                    if isinstance(values[i]['value'], bool):
                        var_string += values[i]['vhdl_name']+'=>'+str(int(values[i]['value']))+',\n'
                    elif 'base' in values[i]:
                        if values[i]['base'] == 'hex':
                            var_string += values[i]['vhdl_name']+'=>'+'16#'+'%03X'%values[i]['value']+'#'+',\n'
                    else:
                        var_string += values[i]['vhdl_name']+'=>'+ str(values[i]['value'])+',\n'
                             
                #parameters from tpp files
                elif i == 'hindex' or i == 'pindex' or i == 'pirq' or i == 'hirq':
                    if not values[i]['value'] == 0 or not (i=='pirq' or i=='hirq'):
                        var_string +=   i +'=>'+ format(values[i]['value'])+',\n'
                elif i == 'hmask' or i == 'pmask' or i == 'paddr' or i == 'haddr':
                    var_string += i +'=>'+'16#'+'%03X'%values[i]['value']+'#'+',\n'
        #delete the comma
        var_string = var_string[:-2]
    return var_string
##Path to the GRLIB

if __name__ ==  '__main__':
    ##set path
    temp_path = 'vhdl/SysCtoVHDL/zedboard_template'
    grlib_design_path= 'designs/leon3-digilent-xc7z020'
    dst_design_path = 'vhdl/VHDL/designs/leon3-digilent-xc7z020'
    ##Read Property
    all_values = cci.readPropertyDict()
    all_values['GRLIB_PATH']=os.environ.get('GRLIB_PATH', '../grlib-gpl-1.3.7-b4144')

    ##set filter 
    env = Environment(loader=FileSystemLoader(temp_path))
    env.filters['create_generic_map'] = create_generic_map 
    env.filters['set_var'] = set_var
    env.filters['intToHex'] = intToHex


  ##Exist the folder?
    if os.path.exists('vhdl/VHDL/designs/leon3-digilent-xc7z020') == True:
        shutil.rmtree('vhdl/VHDL/designs/leon3-digilent-xc7z020')       # Delete folder
    shutil.copytree(os.path.join(all_values['GRLIB_PATH'] , grlib_design_path),dst_design_path)

    ##Dict with the information to create the files
    templ ={'Makefile':'templ_Makefile.mak','config.vhd':'templ_config.vhd', 'leon3mp.vhd':'templ_leon3mp.vhd'}
    print('Creating files')
    ##Creating the files and move them in the right folder
    for i in templ.keys():
        with open(i, 'w') as writefile :
            writefile.write(env.get_template(templ[i]).render(all_values))
        os.rename(i,os.path.join(dst_design_path,i))
    shutil.copyfile(os.path.join(temp_path, 'testbench.vhd'),os.path.join(dst_design_path, 'testbench.vhd'))    
    
    ##Shell commands
    os.chdir(dst_design_path)
    subprocess.call(['make', 'vsim'])
    os.chdir('../../..')
    print('Back in main directory')

