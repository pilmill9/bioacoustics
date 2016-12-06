function result=makexmlfordetections(hyd)

%Create detections xml from the hyd data structure
%input: hydrophone data structure from Tyler
%output: xml to store in Tethys dbxml database

fileid=fopen('tylerdetectout.xml','w');

fprintf(fileid, '<?xml version="1.0" encoding="utf-8"?>\n');
fprintf(fileid, '<ty:Localizations xmlns:ty="http://tethys.sdsu.edu/schema/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tethys.sdsu.edu/schema/1.0 tethys.xsd " >\n');

fprintf(fileid, '<calls>\n');
%read in from the hyd array:

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
fprintf(fileid, '</ty:Localizations>');
%fprintf(fileid, '</xml>');
fclose(fileid);

end 

