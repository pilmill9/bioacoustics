import csv
from datetime import datetime, timedelta

csvFile = 'LOCTESTCSV.csv'
xmlFile = 'myXMLfile.xml'

csvData = csv.reader(open(csvFile))
xmlData = open(xmlFile, 'w')
xmlData.write('<?xml version="1.0" encoding="utf-8"?>' + "\n")

xmlData.write('<ty:Localizations xmlns:ty="http://tethys.sdsu.edu/schema/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tethys.sdsu.edu/schema/1.0 tethys.xsd " >')
xmlData.write("\n")
rowNum = 0

def convlong(value):
        
        if int (value) <0:
            value = 360 +value
            
        return value;


for row in csvData:
    #print "row is ", row

    if row[0]:
        
        python_datetime = datetime.fromordinal(int(float(format(row[0])))) + timedelta(days=float(format(row[0]))%1) - timedelta(days = 366)
        fielda = '<Localizations><Localization><Location><DateTime>{0}</DateTime></Location></Localization></Localizations>'.format(python_datetime)
    else:
        fielda = ''

    if row[1]:
        fieldb = '<Localizations><Localization><Location><Latitude>{0}</Latitude></Location></Localization></Localizations>'.format(row[1])
    else:
        fieldb = ''

    if row[2]:
        val=convlong(float(format(row[2] )  )  )
        
        fieldc = '<Localizations><Localization><Location><Longitude>{0}</Longitude></Location></Localization></Localizations>'.format(val)
    else:
        fieldc = ''

    if row[3]:
        fieldd = '<Localizations><Localization><Selection><Detection><EventRef><RMS>{0}</RMS></EventRef></Detection></Selection></Localization></Localizations>'.format(row[3])
    else:
        fieldd = ''

    # Compile the string
    #final_string = fielda + fieldb + fieldc + fieldd
    # xmlData.write(final_string + "\n")
    
    xmlData.write(fielda +"\n")
    xmlData.write(fieldb+"\n")
    xmlData.write(fieldc+"\n")
    xmlData.write(fieldd+"\n")
    
xmlData.write("</ty:Localizations>")
xmlData.close()



