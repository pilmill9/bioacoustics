import csv, os, sys
from datetime import datetime, timedelta
#open metadata, contruct xml, add data

def convlong(value):
        
        if int (value) <0:
            value = 360 +value
            
        return value;

#csvFile='metadata.txt' #input of hydrophone metadata

csvFile=sys.argv[-1] #input data file name containing hydrophone metadata
xmlFile='myXmlFile15.xml' 

xmlData = open(xmlFile, 'w')
xmlData.write('<?xml version="1.0" encoding="utf-8"?>' + "\n")


xmlData.write('<ty:Localizations xmlns:ty="http://tethys.sdsu.edu/schema/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tethys.sdsu.edu/schema/1.0 tethys.xsd " >')

#xmlData.write('<ty:Localizations xmlns:ty="http://tethys.sdsu.edu/schema/1.0">')
xmlData.write("\n")

xmlData.write('<Localize> TEST 1')

xmlData.write(' <Localizations> SERIES 1 ')

# localization data is in the subdirectory: 
paths='C:\\Program Files\\Tethys\\client-python\\loc_convert\\Tyler localization data\\loc\\test\\'

fds = [open(path, 'r') for path in os.listdir(paths)]

for fd in fds:
    
    print paths + fd.name
    xmlData.write(' <Localization> '  + fd.name)
    
    xmlData.write('<ZeroLocation>')   
    xmlData.write("\n")
    
    csvData=csv.reader(open(csvFile), delimiter=',') #data from zero location
    
    for row in csvData: #write zero location metadata
    
        if row[0]:
    
            fielda = '<Sensor><Name>{0}</Name>'.format(row[0])
        else:
            fielda = ''
            
        if row[1]:
    
            fieldb = '<Latitude>{0}</Latitude>'.format(row[1])
        else:
            fieldb = ''       
    
        if row[2]:
            val=convlong(float(format(row[2] )  )  )
            
            fieldc = '<Longitude>{0}</Longitude>'.format(val)
        else:
            fieldc = ''
            
        if row[3]:
    
            fieldd = '<Depth>{0}</Depth>'.format(row[3])
        else:
            fieldd = ''  
            
        if row[4]:
    
            fielde = '<Channel>{0}</Channel></Sensor>'.format(row[4])
        else:
            fielde = ''  
       
        xmlData.write(fielda +"\n")
        xmlData.write(fieldb+"\n")
        xmlData.write(fieldc+"\n")
        xmlData.write(fieldd+"\n")
        xmlData.write(fielde+"\n")
        
    xmlData.write("</ZeroLocation>" +"\n")
    
    csvData1 = csv.reader(open(paths + fd.name), delimiter=' ') #data from localizations 
        
    for row in csvData1: #write locations
   
        if row[0]:
            
            #python_datetime = datetime.fromordinal(int(float(format(row[0])))) + timedelta(days=float(format(row[0]))%1) - timedelta(days = 366)
            python_datetime=format(row[0])
            fielda = '<LocationA><Time>{0}</Time>'.format(python_datetime)
        else:
            fielda = ''
    
        if row[1]:
            fieldb = '<Latitude>{0}</Latitude>'.format(row[1])
        else:
            fieldb = ''
    
        if row[2]:
            val=convlong(float(format(row[2] )  )  )
            
            fieldc = '<Longitude>{0}</Longitude>'.format(val)
        else:
            fieldc = ''
    
        if row[3]:
            fieldd = '<RMS>{0}</RMS></LocationA>'.format(row[3])
        else:
            fieldd = ''

        xmlData.write(fielda +"\n")
        xmlData.write(fieldb+"\n")
        xmlData.write(fieldc+"\n")
        xmlData.write(fieldd+"\n")
        
    fielde='</Localization>' 
    xmlData.write(fielde+"\n")
      
fielde='</Localizations></Localize>' 
xmlData.write(fielde+"\n")   

xmlData.write("</ty:Localizations>")
xmlData.close()
