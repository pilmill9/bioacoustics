function vizMarkerWebmap(varargin)

%This function loads the load localization file
%and displays the webmap
%The options for marker coloring are depth or time.
%For a demo use vizMarkerWebmap without arguments
%The required input is the lat/long position as a double array
%and optionally the depth or time of the position.

nVarargs = length(varargin);
 
if nVarargs>0
    pos=varargin{1}; %pm an array with lat and long
    time=varargin(2);
    cm=varargin(3); %get spectrogram for demo
    depth=varargin(4);
else
    pos='';
    time='';
    cm='';
    depth='';
end 

if (~isempty(pos))
    %get the array of data.
    
    depth=zeros(size(pos(:,1))); 
    
    if (~isempty(pos))
        posit=[pos depth];
    else
        posit=horzcat(pos, num2cell(depth));
    end 
    
    coordarray=posit;

    % coordarray(:,:,3)=1; 
    %coordarray=transp(coordinates);
    
    if( ~isempty(depth) || ~isempty(depth{1}) && isempty(time) )
        tt=struct('Latitude', coordarray(:,1), 'Longitude',coordarray(:,2), 'Depth', coordarray(:,3) );
   
    else 
        tt=struct('Latitude', coordarray(:,1), 'Longitude',coordarray(:,2));
    end
    
    timearray=cell2mat(time); 
   
    t1 = datenum(2013,11,1,8,0,0);
    t2 = datenum(2013,11,14,8,0,0);
    t=t1:t2;
    t=transpose(t); 
    
    aa=char(time);
    aa=datenum(aa,  'yyyy-MM-ddTHH:mm:ss.000');
       
    if( ~isempty(time) && ~isempty(time{1}) )
         tt=struct('Latitude', coordarray(:,1), 'Longitude',coordarray(:,2), 'Time', aa);
    end
        
    % tmp=cell(size(tt)); 
    %[tt(:).Depth]=deal(tmp{:})
    %tt=setfield(tt,'Depth', 0)
   % for(i=1:size(tt.Longitude)) 
   %     tt(i).Depth=0;
    %end 
    %ss=struct2table(tt);
elseif(isempty(cm) || isempty(cm{1}) )
    load('PMRF_localizations_04Feb15_175526__all14_timed1_134.mat'); %pm TD: make an input generated from start time
    coordarray=transp(localize_struct.hyd(3).coordinates); %pm lat long depth for the hydrophone
    dexs=transp(localize_struct.hyd(3).dex); %pm the dex for the associated detections
    %coordarray=transp(coordinates);
    coordarray=[coordarray dexs]; 
    tt=struct('Latitude', coordarray(:,1), 'Longitude',coordarray(:,2), 'Depth',  coordarray(:,3));
    %ss=struct2table(tt);
else %run demo of cmmax
    load('PMRF_localizations_04Feb15_175526__all14_timed1_134.mat'); 
    load('PMRF_detections_04Feb15_175526__all14_timed1_134');%pm TD: make an input generated from start time
    coordarray=transp(localize_struct.hyd(3).coordinates);
    dexs=transp(localize_struct.hyd(3).dex); %pm the dex for the associated detections
    %coordarray=transp(coordinates);
    coordarray=[coordarray dexs]; %pm lat/long 
    %allcmmax=[hyd(3).detection(1).calls.cm_max]; 
   % coordarray=[coordarray allcmmax.values]
   allcmmax=[hyd(3).detection(1).calls.cm_max]; 
        dd=size(allcmmax);
        
        ee=size(dexs);
        selectcmmax=[];
        count=0;
           for j= 1:ee(1)
               for i=1:dd(2)

                   if dexs(j)==i
                    %display(dexs(j));
                    %display(j);
                    %display(i);
                    count=count+1;
                    %display(allcmmax(j)); 
                    %allcmmax(j).dex=dexs(j); 
                    allcmmax(j).line=j;
                    selectcmmax=[selectcmmax allcmmax(j).line];
                   end
               end
           end
    tt=struct('Latitude', coordarray(:,1), 'Longitude',coordarray(:,2), 'CM',  dexs);
%all cmmax corresponding to detections  
end

%figure
%worldmap world
%geoshow( ss.Latitude,  ss.Longitude, 'DisplayType', 'Line')
%plot3m(ss.Latitude, ss.Longitude, ss.Depth, 'r-');
%showplot(); 

p=geopoint(tt);

%Create an attribute spec and modify it to define a table of values to display in the feature balloon, including year, cause, country, location, and maximum height. The attribute spec defines the format of the expected value for each field.

%attribspec = makeattribspec(p);

%desiredAttributes = ...
       %{'Max_Height', 'Cause', 'Year', 'Location', 'Country'};
%allAttributes = fieldnames(attribspec);
%attributes = setdiff(allAttributes, desiredAttributes);
%attribspec = rmfield(attribspec, attributes);
%attribspec.Max_Height.AttributeLabel = '<b>Maximum Height</b>';
%attribspec.Max_Height.Format = '%.1f Meters';
%attribspec.Cause.AttributeLabel = '<b>Cause</b>';
%attribspec.Year.AttributeLabel = '<b>Year</b>';
%attribspec.Year.Format = '%.0f';
%attribspec.Location.AttributeLabel = '<b>Location</b>';
%attribspec.Country.AttributeLabel = '<b>Country</b>';
%Create a web map, specifying the base layer. Then add the marker overlay. In the illustration, note the table containing the data you specified in the attribute spec.
%geoshow(p, 'DisplayType', 'surface')

webmap('ocean basemap');

color=[.9,.9,.9];
%colors(:196)=.9;
col(196,1)=.9;
col(196,2)=.9;
col(196,3)=.9;
col(:,:)=.9;
col(196,1)=.1;
%pm create series
for i=1:196 %pm map by sequence
    B(i,1)=1;
    B(i,2)=i/200;
    B(i,3)=0;
end

if (pos)
    maxd=max(coordarray(:,3));
else
    maxd=max(localize_struct.hyd(3).coordinates(:));
end 

if (pos)
    for i=1:size(p) %196 %pm map by depth light aqua to dark blue
        D(i,1)=0;
        D(i,2)=1-(coordarray(i,1)/maxd)^.2;
        D(i,3)=1-(coordarray(i,1)/maxd);
    end 
   
else
    for i=1:size(p) %196 %pm map by depth light aqua to dark blue
        D(i,1)=0;
        D(i,2)=1-(localize_struct.hyd(3).coordinates(3,i)/maxd)^.2;
        D(i,3)=1-(localize_struct.hyd(3).coordinates(3,i)/maxd);
    end

end


if(~isempty(time) && ~isempty(time{1}) )
    maxd=max(aa);
   
    for i=1:size(p) %196 %pm map by depth light aqua to dark blue map for time
        D(i,1)=t(i)/(maxd+1);
        if i==1
            D(i,2)=1-( aa(i) ) /(maxd+1) ;
        else
            D(i,2)=abs(1-( abs( aa(i)-aa(i-1)  )^2 ) /aa(i) ) ;
            if D(i,2)>1
                D(i,2)=1;
            end
        end
        D(i,3)=abs(1-(( aa(i) )/(maxd+1)));
        if D(i,3)>1
            D(i,3)=1;
        end        
    end
end

for i=1:10
    C(i,1)=i/10;
    C(i,2)=1;
    C(i,3)=1;
end
attribspec = makeattribspec(p);

desiredAttributes = {'Depth'};

if(~isempty(time) && ~isempty(time{1}) )
    desiredAttributes = {'Time'};
end 

if(~isempty(cm) && ~isempty(cm{1}) )
    desiredAttributes = {'CM'};
end 

%pm insert spectrogram pointer here, as option

%if spect
% get the dex
%get the detection
%extract the cm
%make a plot and display it at mouse over

allAttributes = fieldnames(attribspec);
attributes = setdiff(allAttributes, desiredAttributes);
attribspec = rmfield(attribspec, attributes);

if(depth(1)>0) %pm no depth yet in the database, TD: update schema, add depth. 
attribspec.Depth.AttributeLabel = '<b>Depth</b>';
attribspec.Depth.Format = '%.0f';
end

if(~isempty(time) && ~isempty(time{1})) %pm no depth yet in the database, TD: update schema, add depth. 
attribspec.Time.AttributeLabel = '<b>Time</b>';
attribspec.Time.Format = '%.0f';
end

if(~isempty(cm) && ~isempty(cm{1})) %pm no depth yet in the database, TD: update schema, add depth. 
attribspec.CM.AttributeLabel = '<b>CM</b>';
attribspec.CM.Format = '%.0f';
end

%pm new attribute spec: calculate from hyd cm_max and unzip spectro,
%init->just scatter
if( (maxd>0) && isempty(time) )
wmmarker(p, 'color', D, 'Description', attribspec, 'OverlayName', 'PMRF:Localizations');
elseif(time{1})
wmmarker(p, 'color', D, 'Description', attribspec, 'OverlayName', 'PMRF:Localizations'); 
else
wmmarker(p, 'color', D);
end

%mapview();
%wmmarker(p, 'color', jets );
wmzoom(12); %max zoom for ocean basemap pm

%wmprint();