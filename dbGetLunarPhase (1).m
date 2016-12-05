function [phasenum, lengthofphase]=dbGetLunarPhase(date, numphases)

date=datestr(date,'mm/dd/yyyy') ;

%fullURL = ['http://api.usno.navy.mil/moon/phase?date=1/1/2011&nump=10'];
fullURL = 'http://api.usno.navy.mil/moon/phase?date=%s&nump=%d';

url=sprintf(fullURL, date, numphases);

str = urlread([url]);

data=parse_json(str);

j=1;
for i=1:numphases
    
    phase=data{1,1}.phasedata{1,i}.phase;
    date = data{1,1}.phasedata{1,i}.date;
 
    if (strcmp(phase,'New Moon'))
        newmoondate{j} = date;
        j=j+1;
    end
end

for m=1:j-2
  lengthofphase(m) =datenum(  newmoondate{m+1},'yyyymmdd')-datenum(newmoondate{m},'yyyymmdd'); 
end


for k=1:j-2
  phasenum(k,1)=datenum(newmoondate(k),'yyyymmmdd');

  for i=2:lengthofphase(k)
      phasenum(k, i)=addtodate(phasenum(k,1),i-1,'day');
      datestr(phasenum(k,i));
  end

end












