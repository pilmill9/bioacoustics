%function result=makexmlfordetections(hyd)

%Create detections xml from the hyd data structure
%input: hydrophone data structure from Tyler
%output: xml to store in Tethys dbxml database

file='tylerdetectout2.xml';
fileid=fopen(file,'w');
if fileid==-1
  error('Cannot open file for writing: %s', file);
end

fprintf(fileid, '<?xml version="1.0" encoding="utf-8"?>\n');
fprintf(fileid, '<ty:Detections xmlns:ty="http://tethys.sdsu.edu/schema/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tethys.sdsu.edu/schema/1.0 tethys.xsd " >\n');
fprintf(fileid, '<detection>\n');
%read in hyd array and add parameter values

fprintf(fileid, '<parms>\n');
parnames=fieldnames(hyd(1).detection.parm);

for i= 1:numel(parnames)-1
    fprintf(fileid, '<%s>',char(parnames(i))); %name of parm variable
    
    extracted=extractfield( hyd(1).detection.parm, char(parnames(i)));
       
    fprintf(fileid, '%d', extracted) ; %value of parm variable
    
    fprintf(fileid, '</%s>\n',char(parnames(i)));
end


parnames1=fieldnames(hyd(1).detection.parm.measure)  ;

fprintf(fileid, '<measure>');

for j=1:numel(parnames1)
    
    fprintf(fileid, '<%s>',char(parnames1(j))); %name of parm variable
    
    extracted=extractfield( hyd(1).detection.parm.measure, char(parnames1(j)));
       
    fprintf(fileid, '%d', extracted) ; %value of parm variable
    
    fprintf(fileid, '</%s>\n',char(parnames1(j)));
    
end

fprintf(fileid, '</measure>\n');

fprintf(fileid, '</parms>\n');

fprintf(fileid, '<calls>\n');
%read in from the hyd array and add call values:

for i=1:length(hyd)
    %fprintf( 'loop is i=  %d ' , i); 
    
    fprintf(fileid, '<call>\n');
    start_time=hyd(i).detection.calls(1).start_time;
    end_time =hyd(i).detection.calls(1).end_time;
    spec_noise=hyd(i).detection.calls(1).spec_noise;
    spec_rl=hyd(i).detection.calls(1).spec_rl;
    fprintf(fileid, '<start> %d </start> <end> %d </end> <spec_noise> %d </spec_noise> <spec_rl> %d </spec_rl> \n', start_time, end_time, spec_noise, spec_rl );

    fprintf(fileid, '<cm_max>\n');
    
    for n=1:length(hyd(i).detection.calls(1).cm_max.index) %make variable of length
    %fprintf('inner loop is n= %d', n);
    index=hyd(i).detection.calls(1).cm_max.index(n);
    values=hyd(i).detection.calls(1).cm_max.values(n);
    scale=hyd(i).detection.calls(1).cm_max.scale;
    size='';
        for o=1:2 
         if( o==1)
         size =strcat(size,  num2str( hyd(i).detection.calls(1).cm_max.size(o) ));
         else
         size =strcat(size, 'x', num2str( hyd(i).detection.calls(1).cm_max.size(o) ));
         end   
        end

    fprintf(fileid, '<index> %d </index> <values> %d </values> <scale> %d </scale> <size> %s </size>\n', ...
         index, values, scale, size );
    end
    fprintf(fileid, '</cm_max>\n');
    fprintf(fileid, '</call>\n');
end
fprintf(fileid, '</calls>');
fprintf(fileid, '</detection>');
fprintf(fileid, '</ty:Detections>');
%fprintf(fileid, '</xml>');
fclose(fileid);

%end 

