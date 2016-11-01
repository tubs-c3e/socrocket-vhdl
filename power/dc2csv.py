# This script/The function pwrrpt2csv is used to convert the hiercharical power reports from 
# the DC Compiler to csv-Tables. This table is seperated by semicolons(;).
import sys

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

