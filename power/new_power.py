from __future__ import print_function
import usi
import sys
import os.path
import json
#import dc2scv
#from dc2csv import pwrrpt2csv


"""



"""



def load(*k, **kw):
    """Load initial model configuration"""
    from tools.python.arguments import parser
    parser.add_argument('-o', '--option', dest='option', action='append', type=str, help='Give configuration option')
    parser.add_argument('-p', '--python', dest='python', action='append', type=file, help='Execute python scripts')
    parser.add_argument('-j', '--json', dest='json', action='append', type=str, help='Read JSON configuration')
    parser.add_argument('-l', '--list', dest='list', action='store_true', help='List options')

#Function to start the Conversion from DC Report to CSV:
def csvconversion(*k, **kw):
    #################################
    #Define name of input file here:
    #################################
    inputfile="/vhdl/power/testreport.rpt"
    #################################
    #Define output file name here:
    #################################
    outputfile="results.csv"
    #################################
    #If the input file exsists and if the outputfile does not exist:
    if os.path.isfile(inputfile)==True and os.path.isfile(outputfile)==False:
        pwrrpt2csv(inputfile,outputfile)
    #If outputfile doesn't exist and input file doesn't exist as well, quit with message:
    elif os.path.isfile(outputfile)==False:
        print("No Input .csv found, Exiting...")
        quit()


def view(*k, **kw):
    #Define out_category here like in power.py:
    """View detailed model configuration"""
    total = {}
    out_category = {
        "sta_power": "Static power (leakage): %0.4f pW",
        "int_power": "Internal power (dynamic): %0.4f uW",
        "swi_power": "Switching power (dynamic): %0.4f uW"
    }
    #Filter for power values, from irignal power.py
    params = usi.cci.parameter.readPropertyDict()
    params = usi.cci.parameter.filterDict(params, "power")
    param_list = usi.cci.parameter.paramsToDict(params)

    out = {}
    #Filter for generics, same procedure as above
    paramsg = usi.cci.parameter.readPropertyDict()
    paramsg = usi.cci.parameter.filterDict(paramsg, "generics")
    testlist2 = usi.cci.parameter.paramsToDict(paramsg)
  
    #Query, if file exists. Else: Quit with error!
    #Saves one indention level in comparison to previous version
    #Put the name of the input file in the first if:
    if os.path.isfile("results.csv")==False:
        print("CSV file missing, quitting")
        quit()
    else:
        #open file for read and put it in string s, close afterwards
        file=open("results.csv","r")
        s=file.read()
        file.close()

    #Filter out power values, from the original power.py. Strip .power.
    for base, value in param_list.items():
        parts = base.rsplit(".power.", 1)
        if len(parts) == 2:
            name = parts[0]
            var = parts[1]
            if name not in out:
                out[name] = dict()
            out[name][var] = value
        else:
            print("Mal formated power parameter:", base)

    #filter out generics values, for mmu, ivectorcache etc., strip .generics.
    for base, value in testlist2.items():
        parts = base.rsplit(".generics.", 1)
        if len(parts) == 2:
            name = parts[0]
            var = parts[1]
            if name not in out:
                out[name] = dict()
            out[name][var] = value
        else:
            print("Mal formated generic parameter:", base)
    #print(type(out))

    #Create testitems.json with all values used later. Used for debugging.
    dumpdictx=out.items()
    j = json.dumps(dumpdictx, indent=2)
    f = open('testitems.json', 'w')   
    f.write(j)
    f.close()     

    file=open("newoutput.csv","w")
    file.write("Hierarchy;Switch Power(uW);Internal Power(uW);")
    file.write("Leakage Power(pW);Total Power(uW);Percentage\n")
    for comp, var in out.items():
        #Query, if dc_name exists for component. Otherwise ignore component for power report
        if "dc_name" in out[comp].keys():
            #Write first part of component
            print("*****************************************************")
            print("* Component:", comp)
            print("* ---------------------------------------------------")
            #
            for name, val in var.items():


                #############################################
                #General Values at time of Power estimation:    
                #############################################                
                f_old=100000000 #frequency 
                t_rate=0.1 #toggle rate
                #############################################     
                #Values for specific models at time of power estimation
                #############################################
                #ahbctrl
                old_ahbctrl_m=16 #masters (ToDo determine if connected masters through <=ahbm_none matter)
                old_ahbctrl_s=16 #slaves (ToDo determine if connected masters through <=ahbs_none matter)
                #ahbmem
                old_ahbmem_bits = 8388610 #no of bits in mem
                old_ahbmem_width = 32 #width of mem
                #apbctrl
                old_apbctrl_s = 16 #apbctrl slaves (ToDo determine if connected masters through <=apb_none matter)
                #gptimer
                old_gptimers_n=2
                #mmu
                old_dtlb_num = 8
                old_itlb_num = 8
                #icache
                old_icache_ilinesz = 8
                old_icache_isetsz = 4
                old_icache_isets = 1
                #dcache
                old_dcache_dlinesz = 8
                old_dcache_dsetsz = 1
                old_dcache_dsets = 1
                #These values for rom, sdram, sram and io are not correct atm
                #Size of Memory in bits:
                old_sdram_nbits = 1024
                old_sram_nbits = 1024
                old_io_nbits = 1024
                old_rom_nbits = 1024

                #General Values from SystemC, used for calculations
                t_diff=out["ahbctrl"]["t_diff"] #Time between start and end of Sim
                f_new=1/out["ahbctrl"]["val_of_clk"] # Clock frequency
                #print(f_new)

                #If Name is in the Out category (int_power, sta_power, swi_power)
                if name in list(out_category.keys()):
                    #set a,b,c=0 to delete former value
                    a=0
                    b=0
                    c=0
                    #For int_power. Here also: 
                    if name=="int_power":
                        #print(translatedict[comp])
                        #If there are more instances of one "translatedict", i.e. "itag"
                        #Then count these instances and accumulate them


                        #The calculations are as stated in the power modeling report
                        if comp=="ahbctrl":
                            a=find_intpower(s,out[comp]["dc_name"])
                            a=a*(out[comp]["no_of_slaves"] + out[comp]["no_of_masters"])
                            a=a*f_new/(old_ahbctrl_m+old_ahbctrl_s)
                            val=a/f_old
                        elif comp=="ahbmem":
                            a=find_intpower(s,out[comp]["dc_name"])
                            a=a*(out[comp]["no_of_bits"])
                            val=a*f_new/(old_ahbmem_bits*f_old)
                        elif comp=="apbctrl":
                            a=find_intpower(s,out[comp]["dc_name"])
                            val=a*(out[comp]["no_of_slaves"])*f_new/(f_old*old_apbctrl_s)
                        elif comp=="leon3_0.leon3":
                            a=find_intpower(s,out[comp]["dc_name"])
                            a=a*f_new/f_old
                            val=a
                        elif comp=="gptimer":
                            a=find_intpower(s,out[comp]["dc_name"])
                            val=a*f_new/(f_old*old_gptimers_n)
                        elif comp=="irqmp":
                            a=find_intpower(s,out[comp]["dc_name"])
                            a=a*f_new/f_old
                        elif comp=="mctrl":
                            a=find_intpower(s,out[comp]["dc_name"])
                            val=a*f_new/f_old
                        elif comp=="sram":
                            a=find_intpower(s,out[comp]["dc_name"])*f_new*out[comp]["bsize"]
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(f_old*old_sram_nbits)
                        elif comp=="io":
                            a=find_intpower(s,out[comp]["dc_name"])*f_new*out[comp]["bsize"]
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(f_old*old_io_nbits)
                        elif comp=="rom":
                            a=find_intpower(s,out[comp]["dc_name"])*f_new*out[comp]["bsize"]
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(f_old*old_rom_nbits)
                        elif comp=="sdram":
                            a=find_intpower(s,out[comp]["dc_name"])*f_new*out[comp]["bsize"]
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(f_old*old_sdram_nbits)
                        elif comp=="leon3_0":
                            a=find_intpower(s, out[comp]["dc_name"])
                            val=a*f_new/f_old
                        # For MMU: Serach for itlb0 and dtlb0 needed as well
                        elif comp=="leon3_0.mmu":
                            a=find_intpower(s, out[comp]["dc_name"])
                            b=find_intpower(s,"itlb0")+find_intpower(s,"dtlb0")
                            b=b*(out["leon3_0"]["itlb_num"]+out["leon3_0"]["dtlb_num"])
                            b=b/(old_itlb_num+old_dtlb_num)
                            val=(a+b)*f_new/f_old
                        # Search for idata and itag as well
                        elif comp=="leon3_0.ivectorcache":
                            a=find_intpower(s, out[comp]["dc_name"])
                            b=find_intpower(s, "itag")
                            c=find_intpower(s, "idata")
                            #itagpower normalized,  with f_new
                            b=b*old_icache_ilinesz/(32*256*old_icache_isetsz)
                            b=b*f_new/f_old
                            #idatapower normalized,  with f_new
                            c=c/((old_icache_isetsz+1)*8*2**old_icache_isetsz)
                            c=c*f_new/f_old
                            #calc new power now:
                            val=a+b*out[comp]["no_of_bits_itag"]+c*out[comp]["no_of_bits_idata"]
                        # Search for ddata and dtag as well
                        elif comp=="leon3_0.dvectorcache":
                            a=find_intpower(s, out[comp]["dc_name"])
                            b=find_intpower(s, "dtag")
                            c=find_intpower(s, "ddata")
                            #dtagpower normalized, already with f_new
                            b=b*old_dcache_dlinesz/(32*256*old_dcache_dsetsz)
                            b=b*f_new/f_old
                            #ddatapower normalized, already with f_new
                            c=c/((old_dcache_dsetsz+1)*8*2**old_dcache_dsetsz)
                            c=c*f_new/f_old
                            #calc new power now:
                            val=a+b*out[comp]["no_of_bits_dtag"]+c*out[comp]["no_of_bits_ddata"]
                        else:
                            val=0
                        # Write new value in dict for VCD output
                        out[comp][name]=val

                    if name=="sta_power":                        
                        if comp=="ahbctrl":
                            a=find_stapower(s,out[comp]["dc_name"])
                            a=a*(out[comp]["no_of_slaves"] + out[comp]["no_of_masters"])
                            val=a/(old_ahbctrl_m+old_ahbctrl_s)
                        elif comp=="ahbmem":
                            a=find_stapower(s,out[comp]["dc_name"])
                            val=a*(out[comp]["no_of_bits"])/old_ahbmem_bits
                        elif comp=="apbctrl":
                            a=find_stapower(s,out[comp]["dc_name"])
                            val=a*(out[comp]["no_of_slaves"])/old_apbctrl_s
                        elif comp=="leon3_0.leon3":
                            a=find_stapower(s,out[comp]["dc_name"])
                            #scheint so auszureichen
                            val=a
                        elif comp=="gptimer":
                            a=find_stapower(s,out[comp]["dc_name"])
                            #Scheint so auszureichen
                            val=a
                        elif comp=="irqmp":
                            a=find_stapower(s,out[comp]["dc_name"])
                            #Scheint so auszureichen:
                            val=a
                        elif comp=="mctrl":
                            a=find_stapower(s,out[comp]["dc_name"])
                            #Scheint so auszureichen:
                            val=a
                        elif comp=="sram":
                            a=find_stapower(s,out[comp]["dc_name"])*out[comp]["bsize"]
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(old_sram_nbits)
                        elif comp=="io":
                            a=find_stapower(s,out[comp]["dc_name"])*out[comp]["bsize"]
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(old_io_nbits)
                        elif comp=="rom":
                            a=find_stapower(s,out[comp]["dc_name"])*out[comp]["bsize"]
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(old_rom_nbits)
                        elif comp=="sdram":
                            a=find_stapower(s,out[comp]["dc_name"])*out[comp]["bsize"]
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(old_sdram_nbits)
                        elif comp=="leon3_0":
                            a=find_stapower(s,out[comp]["dc_name"])
                            val=a
                        elif comp=="leon3_0.mmu":
                            a=find_stapower(s,"(mmutw")
                            b=find_stapower(s,"itlb0")+find_stapower(s,"dtlb0")
                            b=b*(out["leon3_0"]["itlb_num"]+out["leon3_0"]["dtlb_num"])
                            b=b/(old_itlb_num+old_dtlb_num)
                            val=a+b
                        elif comp=="leon3_0.ivectorcache":
                            a=find_stapower(s, out[comp]["dc_name"])
                            b=find_stapower(s, "itag")
                            c=find_stapower(s, "idata")
                            #itagpower normalized
                            b=b*old_icache_ilinesz/(32*256*old_icache_isetsz)
                            #idatapower normalized
                            c=c/((old_icache_isetsz+1)*8*2**old_icache_isetsz)
                            #calc new power now:
                            val=a+b*out[comp]["no_of_bits_itag"]+c*out[comp]["no_of_bits_idata"]
                        elif comp=="leon3_0.dvectorcache":
                            a=find_stapower(s, out[comp]["dc_name"])
                            b=find_stapower(s, "dtag")
                            c=find_stapower(s, "ddata")
                            #dtagpower normalized
                            b=b*old_dcache_dlinesz/(32*256*old_dcache_dsetsz)
                            #ddatapower normalized
                            c=c/((old_dcache_dsetsz+1)*8*2**old_dcache_dsetsz)
                            #calc new power now:
                            val=a+b*out[comp]["no_of_bits_dtag"]+c*out[comp]["no_of_bits_ddata"]                            
                        else:
                            val=0
                        # Write new value in dict for VCD output
                        out[comp][name]=val

                    if name=="swi_power":
                        if comp=="ahbctrl":
                            a=find_swipower(s,out[comp]["dc_name"])
                            #Rechnung noch zu normalisieren:
                            a=a*(out[comp]["no_of_slaves"] + out[comp]["no_of_masters"])
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])
                            val=a/((old_ahbctrl_s+old_ahbctrl_m)*t_diff*t_rate*f_old)
                        elif comp=="ahbmem":
                            a=find_swipower(s,out[comp]["dc_name"])
                            #Rechnung noch zu normalisieren:
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])*32*out[comp]["no_of_bits"]
                            val=a/(f_old*t_rate*t_diff*old_ahbmem_width*old_ahbmem_bits)
                        elif comp=="apbctrl":
                            a=find_swipower(s,out[comp]["dc_name"])
                            #ToDo:
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])*(out[comp]["no_of_slaves"])
                            val=a/(f_old*t_rate*t_diff*old_apbctrl_s)
                        elif comp=="leon3_0.leon3":
                            a=find_swipower(s,out[comp]["dc_name"])
                            #print(swipwr)
                            a=a*out[comp]["dyn_instr"]/(t_diff*t_rate)
                            val=a/f_old
                        elif comp=="mctrl":
                            a=find_swipower(s,out[comp]["dc_name"])
                            #ToDo
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])
                            val=a/(f_old*t_diff*t_rate)
                        elif comp=="sram":
                            a=find_swipower(s,out[comp]["dc_name"])*out[comp]["bsize"]*32
                            a=a/(32*old_sram_nbits)
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(f_old*t_diff*t_rate)                            
                        elif comp=="io":
                            a=find_swipower(s,out[comp]["dc_name"])*out[comp]["bsize"]*32
                            a=a/(32*old_io_nbits)
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(f_old*t_diff*t_rate)  
                        elif comp=="rom":
                            a=find_swipower(s,out[comp]["dc_name"])*out[comp]["bsize"]*32
                            a=a/(32*old_rom_nbits)
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(f_old*t_diff*t_rate)  
                        elif comp=="sdram":
                            a=find_swipower(s,out[comp]["dc_name"])*out[comp]["bsize"]*32
                            a=a/(32*old_sdram_nbits)
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])
                            val=0
                            #uncomment the following for later implementation of this memory
                            #val=a/(f_old*t_diff*t_rate)
                        elif comp=="leon3_0":
                            a=find_swipower(s,out[comp]["dc_name"])
                            a=a*(out[comp]["dyn_reads"]+out[comp]["dyn_writes"])
                            val=a/(f_old*t_rate*t_diff)
                        elif comp=="leon3_0.mmu":
                            a=find_swipower(s,"itlb0")*(out[comp]["itlb.dyn_itlb_reads"]+out[comp]["itlb.dyn_itlb_writes"])
                            a=a*out["leon3_0"]["itlb_num"]/(old_itlb_num*t_rate*f_old)
                            a=find_swipower(s,"dtlb0")*(out[comp]["dtlb.dyn_dtlb_reads"]+out[comp]["dtlb.dyn_dtlb_writes"])
                            a=a*out["leon3_0"]["dtlb_num"]/(old_dtlb_num*t_rate*f_old)
                            val=(a+b)/t_diff
                        elif comp=="leon3_0.ivectorcache":
                            a=find_swipower(s, "itag")/(t_rate*f_old*32*256*old_icache_isetsz)
                            b=find_swipower(s, "idata")/(t_rate*f_old*(old_icache_isetsz+1)*8*2**old_icache_isetsz)
                            a=a*out[comp]["no_of_bits_itag"]
                            a=a*(out[comp]["dyn_tag_writes"]+out[comp]["dyn_tag_reads"])
                            b=b*out[comp]["no_of_bits_idata"]
                            b=b*(out[comp]["dyn_data_writes"]+out[comp]["dyn_data_reads"])
                            val=(a+b)/t_diff
                        elif comp=="leon3_0.dvectorcache":
                            a=find_swipower(s, "dtag")/(t_rate*f_old*32*256*old_dcache_dsetsz)
                            b=find_swipower(s, "ddata")/(t_rate*f_old*(old_dcache_dsetsz+1)*8*2**old_dcache_dsetsz)
                            a=a*out[comp]["no_of_bits_dtag"]
                            a=a*(out[comp]["dyn_tag_writes"]+out[comp]["dyn_tag_reads"])
                            b=b*out[comp]["no_of_bits_ddata"]
                            b=b*(out[comp]["dyn_data_writes"]+out[comp]["dyn_data_reads"])
                            val=(a+b)/t_diff
                        else:
                            val=0
                        # Write new value in dict for VCD output
                        out[comp][name]=val



                    #if name=="dyn_power"

                    print("*", out_category[name] % val)
                    if name not in total:
                      total[name] = 0.0
                    total[name] += val
                    #testliste = {}
            #Last part of Write:
            print ("*****************************************************")

            #Parts of new CSV here:
            #Write Hierarchy name
            file.write(comp)
            file.write(";")
            #Some components don't have a design for swi_power, therefore check here, else 0:
            if "swi_power" in out[comp].keys():
                file.write(str(out[comp]["swi_power"]))
            else:
                file.write("0")
            file.write(";")
            file.write(str(out[comp]["int_power"]))
            file.write(";")
            file.write(str(out[comp]["sta_power"]))
            file.write(";")
            #Some components don't have a design for swi_power, therefore check here too
            #Then: Write Total power for component           
            if "swi_power" in out[comp].keys():
                file.write(str(out[comp]["swi_power"]+out[comp]["sta_power"]+out[comp]["int_power"]))
            else:
                file.write(str(0+out[comp]["sta_power"]+out[comp]["int_power"]))
            file.write(";")
            #Write n/a (not available) for Percentage, as this would be impossible to calculate right away:
            file.write("n/a")
            file.write("\n")

    #Close new CSV file after loops have been processed
    file.close()



    


    #Print Power Summary here:        
    print ("*****************************************************")
    print ("* Power Summary:")
    print ("* ---------------------------------------------------")
    total_sum = 0.0
    total["sta_power"] /= 10e+6

    for name in list(out_category.keys()):
        print("*", out_category[name] % total[name])
        total_sum += total[name]
    print("* ---------------------------------------------------")
    print("* Total Power: %0.4f" % total_sum, "uW")
    print("*****************************************************")
    #"""



def writestuff(*k, **kw):
    dumpdict = usi.cci.parameter.readPropertyDict()
    #dumpdict = usi.cci.parameter.filterDict(dumpdict, "counters")
    j = json.dumps(dumpdict, indent=2)
    f = open('test1.json', 'w')
    print(j, file=f)
    f.close()    
def install():
    usi.on("end_of_evaluation")(csvconversion)
    usi.on("end_of_evaluation")(writestuff)
    #load()
    usi.on("end_of_evaluation")(view)


def find_intpower(s,dc_name):
    # Find int power
    c=0
    d=0
    anz=0
    ipwr=float(0)
    anz=s.count(dc_name)
    i=0
    while i < anz:
        c=c+s[c:].find(dc_name)
        c=c+1+s[c+1:].find(';')
        c=c+1+s[c+1:].find(';')
        d=c+1+s[c+1:].find(';')
        c=c+1
        # c and d indicate the int power indexes now
        ipwr=ipwr+float(s[c:d])
        i=i+1
    #print (ipwr)
    return ipwr
def find_stapower(s,dc_name):
    c=0
    d=0
    anz=0
    stapwr=float(0)
    anz=s.count(dc_name)
    i=0
    while i < anz:
        c=c+s[c:].find(dc_name)
        c=c+1+s[c+1:].find(';')
        c=c+1+s[c+1:].find(';')
        c=c+1+s[c+1:].find(';')
        d=c+1+s[c+1:].find(';')
        c=c+1
        # c and d indicate the static power indexes now
        stapwr=stapwr+float(s[c:d])
        i=i+1
    return stapwr

def find_swipower(s,dc_name):
    c=0
    d=0
    anz=0
    swipwr=float(0)
    anz=s.count(dc_name)
    i=0
    while i < anz:
        c=c+s[c:].find(dc_name)
        c=c+1+s[c+1:].find(';')
        d=c+1+s[c+1:].find(';')
        c=c+1
        # c and d indicate the swi power indexes now
        swipwr=swipwr+float(s[c:d])
        i=i+1
    return swipwr

#cut lastline, needed to be done twice to remove \n1\n
def pwrrpt2csv(inputfile, outputfile):
    #Open the report, s = reportstring, close file (Closing needed?)
    file=open(inputfile, "r") #Specify file here
    s=file.read()
    file.close()
     #Find start of Table. 'Hierarchy (...) Power' exists once in the reports

    c1=s.find('Hierarchy                              Power')
    #Find next 2 linebreak:
    c2=c1+s[c1:].find('\n')
    c1=c2+1+s[c2+1:].find('\n')
    #Start is 1 Char after second linebreak.
    c2=c1+1
    #Let s start from under the ---------- line. string "leon3mp" is the start
    s=s[c2:] 
    #Remove last line.
    s=s[:s.rfind('1')]
    #Open csv file to write everything:
    file = open(outputfile, "w")    
    #write first line into csv
    file.write("Hierarchy;Switch Power(uW);Internal Power(uW);")
    file.write("Leakage Power(pW);Total Power(uW);Percentage")

    #Define the numbers 
    #c and d alternate to define start/end points to write
    c=0
    d=0


    while c < len(s):
        #c=d because c=d+2 at the end of the while loop for exiting.
        c=d
        #Line Break at the end of a CSV line
        file.write("\n")
        #Find first space
        c=c+1+s[c+1:].find(' ') 
        #If d=0 for the first line. Afterwards its working differently
        if d==0:
            #Write Hierarchy Name
            file.write(s[d:c])
            file.write(";")
        else:       
            #Find first non whitespace char
            while s[c].isspace():
                c=c+1
            #d=c, d is start of writing process
            d=c
            #Jump to the next whitespace char with c now
            while s[c].isspace()==False:
                c=c+1
            #Check, if c+1 is a whitespace char     
            if s[c+1].isspace()==False:
                #check if next is digit or something else, needed for " (" sections
                if s[c+1].isdigit()==False:
                    #Jump one char ahead with c, so it doesn't indicate whitespace anymore
                    c=c+1
                    #If next char wasn't a digit, search for next whitespace
                    #Next whitespace is after closing of bracket " )"
                    while s[c].isspace()==False:
                        c=c+1                   
                    #Write Hierarchy Name
                    file.write(s[d:c])
                    file.write(";")
                else:
                    #Write Hierarchy Name
                    file.write(s[d:c])
                    file.write(";")
            else:   
                #Write Hierarchy Name
                file.write(s[d:c])
                file.write(";")
        #Find next non space char
        while s[c].isspace():
            c=c+1
        #Find next space char after that
        d=c+1+s[c+1:].find(' ')
        #Write first number
        file.write(s[c:d])
        file.write(";")
        #Find next non space char
        while s[d].isspace():
            d=d+1
        #Find next space char
        c=d+1+s[d+1:].find(' ')
        #Write Second Number
        file.write(s[d:c])
        file.write(";")
        #Find next non space char
        while s[c].isspace():
            c=c+1
        #Find next space char after that
        d=c+1+s[c+1:].find(' ')
        #Write third number
        file.write(s[c:d])
        file.write(";")
        #Find next non space char
        while s[d].isspace():
            d=d+1
        #Find next space char
        c=d+1+s[d+1:].find(' ')
        #Write fourth Number
        file.write(s[d:c])
        file.write(";")
        #Find next non whitespace char
        while s[c].isspace():
            c=c+1
        #Find next whitespace char after that
        d=c
        while s[d].isspace()==False:
            d=d+1    
        #Write fifth and final number
        file.write(s[c:d])      
        #c=d+2 for exiting in the end
        c=d+2

    #close file.
    file.close()
    #quit()

    
if __name__ == "__main__":
    install()

