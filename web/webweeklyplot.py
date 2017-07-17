def webweeklyplot():
    import random
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    from pylab import figure, show, legend, ylabel
    from datetime import datetime, timedelta
    import sys
    
    # generate some random data (approximately over 5 years)
    data = [float(random.randint(1271517521, 1429197513)) for _ in range(1000)]
    print "raw data: ", data[1]
    #sys.exit()
    
    with open(r'C:\test\detectionsave.txt', 'r') as f:
       floats=map(float, f)
    print "input Tet dets: ", floats[1]
    
    with open(r'C:\test\cumhoursweek.txt', 'r') as g:
       weeks=map(float, g)
    print "cum hours week: ", weeks
    
    with open(r'C:\test\cumhours.txt', 'r') as h:
       cumhours=map(float, h)
    print "cum hours: ", cumhours
    
    print "len cum: ", len(cumhours)
    print "weeks: ", len(weeks)
       
    #data=floats
    # convert the epoch format to matplotlib date format 
    mpl_data = mdates.epoch2num(data) #pm: put in detection/effort dates here
    print "trans Tet: ", mpl_data[1]
    
    #mpl_data1=mdates.epoch2num(floats)
    
    # plot it
    
    ptime=[]
    pptime=[]
    
    for i in range(len(floats)):
        
        ptime.append(datetime.fromordinal(int(floats[i])) + timedelta(days=floats[i]%1) - timedelta(days = 366))
        pptime.append(datetime.fromordinal(int(floats[i]+500)) + timedelta(days=floats[i]%1) - timedelta(days = 366))
        i=i+1
        #aa.append(ptime.strftime("%d/%m/%y"))
    
    print "ptime: ", ptime   
       
    weekstrans=[]
    for i in range(len(weeks)):
        
        weekstrans.append( datetime.fromordinal( int(weeks[i]) ) + timedelta(days=weeks[i]%1) - timedelta(days = 366) )
        i=i+1
        
    print "weeks trans: ", weekstrans
    
    # create the general figure
    fig1 = figure()
    
    plt.title("cumulative hours effort") 
    # and the first axes using subplot populated with data 
    ax1 = fig1.add_subplot(111)
    #line1 = ax1.plot(ptime, 'o-')
    
    line1= ax1.hist(ptime, bins=50, color='lightblue')
    ylabel("Left Y-Axis Data")
    ax1.set_xlabel("x label")
     
    
    # now, the second axes that shares the x-axis with the ax1
    ax2 = fig1.add_subplot(111, sharex=ax1, frameon=False)
    #line2 = ax2.plot(pptime, 'xr-')
    line2=ax2.hist(pptime, bins=20, color='lightgreen')
    ax2.yaxis.tick_right()
    ax2.yaxis.set_label_position("right")
    
    ylabel("Right Y-Axis Data")
    #ax2.set_ylabel('rhs')
    plt.show(fig1)
    return


webweeklyplot()