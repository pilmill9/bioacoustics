%function result=makexmlfordetections(hyd)

%Create localization xml from the hyd data structure
%input: hydrophone data structure from Tyler
%output: xml to store in Tethys dbxml database

file='tylerlocateout.xml';
fileid=fopen(file,'w');
if fileid==-1
  error('Cannot open file for writing: %s', file);
end

fprintf(fileid, '<?xml version="1.0" encoding="utf-8"?>\n');
fprintf(fileid, '<ty:Localizations xmlns:ty="http://tethys.sdsu.edu/schema/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tethys.sdsu.edu/schema/1.0 tethys.xsd " >\n');
fprintf(fileid, '<Localization>\n');
%read in hyd array and add parameter values

parnames=fieldnames(localize_struct.hyd); %number of parameters

numhyd=numel(localize_struct.hyd(3).coordinates(1,:)) %number of hydrophones

fprintf(fileid, '<sensor>'); %stores hyd

for i=2 %hydrophone coordinates
    for j=1:numhyd
    fprintf(fileid, '\n<coordinates>');    
    %fprintf(fileid, '<var>'); 
    fprintf(fileid, '<lat>');
    
    lat=localize_struct.hyd(3).coordinates(1,j);
       
    fprintf(fileid, '%d', lat) ; %value of parm variable
    
    fprintf(fileid, '</lat>');
    
    fprintf(fileid, '<long>');
    
    long=localize_struct.hyd(3).coordinates(2,j);
       
    fprintf(fileid, '%d', long) ; %value of parm variable
    fprintf(fileid,('</long>')); 

    score=localize_struct.hyd(3).score(1,j);
    fprintf(fileid, '<score>');
    fprintf(fileid, '%d', score) ;
    fprintf(fileid, '</score>') ;
    fprintf(fileid, '</coordinates>\n') ;
    
     fprintf(fileid, '<delays>');
        for k=1:4
            fprintf(fileid, '<value>');
            delays=localize_struct.hyd(3).delays(1,k); 
            fprintf(fileid, '%d',delays);  
            fprintf(fileid, '</value>');
        end
     fprintf(fileid, '</delays>');
  
     fprintf(fileid, '<coord_time>');
        for k=1:2
            fprintf(fileid, '<value>');
            coord_time=localize_struct.hyd(3).coord_time(1,k); 
            fprintf(fileid, '%d',coord_time);  
            fprintf(fileid, '</value>');
        end
     fprintf(fileid, '</coord_time>');

     fprintf(fileid, '<dex>');
     dex=localize_struct.hyd(3).dex(j); 
     fprintf(fileid, '%d',dex);         
     fprintf(fileid, '</dex>');
     
     fprintf(fileid, '<rtimes>');
     rtimes=localize_struct.hyd(3).rtimes(j); 
     fprintf(fileid, '%d',rtimes);         
     fprintf(fileid, '</rtimes>');
     
     fprintf(fileid, '<e2>');
     e2=localize_struct.hyd(3).e2(j); 
     fprintf(fileid, '%d',e2);         
     fprintf(fileid, '</e2>');

    %fprintf(fileid, '</var>\n');
       
    end
end

fprintf(fileid, '</sensor>\n'); %end sensor

fprintf(fileid, '<parms>\n');

num=localize_struct.parm.num_calls;
fprintf(fileid, '<num_calls>');
fprintf(fileid, '%d',  num);
fprintf(fileid, '</num_calls>'); 

num=localize_struct.parm.phase;
fprintf(fileid, '<phase>');
fprintf(fileid, '%d', num);
fprintf(fileid, '</phase>');

num=localize_struct.parm.pow;
fprintf(fileid, '<pow>');
fprintf(fileid, '%d', num);
fprintf(fileid, '</pow>');

num=localize_struct.parm.num_maxima;
fprintf(fileid, '<num_maxima>');
fprintf(fileid, '%d', num);
fprintf(fileid, '</num_maxima>');

num=localize_struct.parm.number_maxima;
fprintf(fileid, '<number_maxima>');
fprintf(fileid, '%d', num);
fprintf(fileid, '</number_maxima>');

num=localize_struct.parm.lsq_cutoff;
fprintf(fileid, '<lsq_cutoff>');
fprintf(fileid, '%d',num);
fprintf(fileid, '</lsq_cutoff>');

num=localize_struct.parm.phase;
fprintf(fileid, '<phase>');
fprintf(fileid, '%d',num);
fprintf(fileid, '</phase>');

num=localize_struct.parm.cc_cutoff;
fprintf(fileid, '<cc_cutoff>');
fprintf(fileid, '%d', num);
fprintf(fileid, '</cc_cutoff>');

 numssp=numel(localize_struct.parm.ssp(:,1));
 fprintf(fileid, '\n<ssp>\n');
        for k=1:2
            for l=1:numssp
                fprintf(fileid, '<value>');
                ssp=localize_struct.parm.ssp(l,k); 
                fprintf(fileid, '%d',ssp);  
                fprintf(fileid, '</value>\n');
            end
            
        end
     fprintf(fileid, '</ssp>');

fprintf(fileid, '</parms>\n');
fprintf(fileid, '</Localization>'); %end sensor
fprintf(fileid, '</ty:Localizations>'); %end sensor

fclose(fileid); 