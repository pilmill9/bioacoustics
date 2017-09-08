%function maplocations(q, varargin)

function [array, time]= maplocations(q, start, stop, id, varargin) 

%Rename to vizMapLocations: returns array of lat/long, depth, time of detections
%satisfying the input conditions.
%Arguments are query handler, start and stop time, project id and
%optionally a lat/long bounding box. Additional formating output arguments
%can be provided including basis map and map formating options.  

%The options are to code by depth, time. The input selection options are
%the same as for dbGetDetections. Calls colrmarkermap to render the 
%map. Eventual this will have the options of selecting the map server.
%Currently employs webmap:ocean basemap and googlemaps. 

event_duration = 0;
meta_conditions = '';  % selection criteria for detection meta data
det_conditions = '';
conj_meta = 'where';
conj_det = 'where';
show_query='';
q=dbInit(); 
idx=1;
lat1='';

return_elements = {};
idx = 1;
simple=0;

while idx < length(varargin)
    switch varargin{idx}
        case 'Map'
            Map = varargin{idx+1}; idx = idx+2;
        case 'Basemap'
            Basemap = varargin{idx+1}; idx = idx+2;
        case 'Points', 
            Points = varargin{idx+1}; idx = idx + 2;
        case 'Attributes'
            Attributes = varargin{idx+1}; idx = idx + 2;
        case 'AttributeRange'
            AttributeRange = varargin{idx+1}; idx = idx + 2;
        case 'AttributeFmtStr'
            AttributeFmtStr = varargin{idx+1}; idx = idx + 2;
        case 'Color'            
            Colormap = varargin{idx+1}; idx = idx + 2;
        case 'Icon'
            IconName = {'Icon', varargin{idx+1}}; idx = idx + 2;
        case 'IconScale'
            IconScale= {'IconScale', varargin{idx+1}}; idx = idx + 2;
        case 'Lat1'
            lat1={'Lat1', varargin{idx+1}}; idx=idx+2; %pm bounding box
        case 'Long1'
            long1={'Long1', varargin{idx+1}}; idx=idx+2;
        case 'Lat2'
            lat2={'Lat2', varargin{idx+1}}; idx=idx+2; 
        case 'Long2'
            long2={'Long2', varargin{idx+1}}; idx=idx+2;
        case 'Time'
            time={'Time', varargin{idx+1}}; idx=idx+2;
        case 'CM'
            cm={'CM', varargin{idx+1}}; idx=idx+2; 
        otherwise
            error('Bad argument at argument %d', idx + nargin);
    end
end

%{
while idx < length(varargin)
    switch varargin{idx}
        
        case {'Project', 'Site'}
            field = sprintf('$det/DataSource/%s', varargin{idx});
            meta_conditions = ...
                sprintf('%s%s %s', ...
                meta_conditions, conj_meta, dbListMemberOp(field, varargin{idx+1}));
            conj_meta = ' and';
            idx = idx+2;
        case 'Deployment'
            comparison = dbRelOp(varargin{idx}, '$det/DataSource/%s', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison);
            conj_meta = ' and';
            idx = idx+2;
       
        case { 'Effort/Start', 'Effort/End'}
            comparison = dbRelOpChar(varargin{idx}, ...
                '$det/%s', varargin{idx+1}, false);
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison);
            conj_meta = ' and';
            idx = idx+2;
        case {'Effort'}
            % detections after this are 'On' effort, 'Off' effort, or
            % both *
            switch varargin{idx+1}
                case 'On', effort='OnEffort';
                case 'Off', effort='OffEffort';
                case {'Both', '*'}, effort='*';
                otherwise
                    error('Bad effort specifciation');
            end
            idx=idx+2;
       
        case 'SpeciesID'
            if benchmark
                spID = varargin{idx+1};
            end
            varargin{idx+1} = sprintf(dbSpeciesFmt('GetInput'), varargin{idx+1});
            %if OnEffort, use meta_conditions as well
            if strcmp(effort,'OnEffort')
                field = sprintf('$det/Effort/Kind/%s = %s',...
                    varargin{idx},varargin{idx+1});
                meta_conditions = ...
                    sprintf('%s%s %s',...
                    meta_conditions,conj_meta,field);
				conj_meta = ' and';
            end
            det_conditions = ...
                sprintf('%s%s $detection/%s = %s', ...
                det_conditions, conj_det, ...
                varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx + 2;
       
        case {'Call'}
            if benchmark
                spCall = varargin{idx+1};
            end
            %if OnEffort, use meta_conditions as well
            if strcmp(effort,'OnEffort')
                field = sprintf('$det/Effort/Kind/%s = "%s"',...
                    varargin{idx},varargin{idx+1});
                meta_conditions = ...
                    sprintf('%s%s %s',...
                    meta_conditions,conj_meta,field);
				conj_meta = ' and';
            end
            det_conditions = ...
                sprintf('%s%s $detection/%s = "%s"', ...
                det_conditions, conj_det, varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx+2;
        
        case {'Start', 'End'}
            % Detection start or end conditions
            comparison = dbRelOp(varargin{idx}, '$detection/%s', varargin{idx+1});
            det_conditions = ...
                sprintf('%s%s %s', ...
                det_conditions, conj_det,comparison);
            conj_det = ' and';
            idx = idx+2;            
       
        case 'ShowQuery'
            show_query = varargin{idx+1};
            idx = idx+2;
       
        otherwise
            error('Bad arugment:  %s', varargin{idx});
    end
end


query_str = dbGetCannedQuery('GetDetections.xq');

source = 'collection("Detections")/ty:Detections';
if length(return_elements) > 0
    additional_info = sprintf('{$detection/%s}\n', return_elements{:});
else
    additional_info = '';
end
query = sprintf(query_str, source, meta_conditions, effort, ...
    det_conditions, additional_info);

% Display XQuery
if show_query
    fprintf(query);
end

%Execute XQuery
j_result = q.Query(query);
xml_result = char(j_result);

%A map of types to send to the wrapper, in Key/Value pairs
%Each key represents an element name, and the value reps their return type.
typemap={
    'idx','double';...
    'Deployment','double';...
    'Start','datetime';...
    'End','datetime';...
    'SpeciesID','decimal';...
    % 'Score','double';...  lose some digits if not string
    };

result=tinyxml2_tethys('parse',xml_result,typemap);

%initialize
noEnd=true;
timestamps = [];
EndP = [];
info = [];
if ~iscell(result.Detections)
    if isfield(result.Detections.Detection,'End')
        timestamps = zeros(length(result.Detections.Detection),2);
        noEnd=false;
    else
        %only start times
        timestamps = zeros(length(result.Detections.Detection),1);
    end

    rows=size(timestamps,1);

    % Assume only start times until we know better
    EndP = zeros(rows,1);
    
    %init info
    if nargout >2
        info.deploymentIdx = zeros(length(result.Detections.Detection),1);
        info.deployments=struct();
        if ~isempty(return_elements) %returning a field?
            fieldnms = regexprep(return_elements, '.*/([^/]+$)', '$1');
            for fidx = 1:length(fieldnms)
                info.(fieldnms{fidx}) = cell(rows, 1);
            end
        end
    end
    
%}    

%Build Xqueries for start/stop only, start/stop, project Id and lat/long
%boundingbox, start/stop and project Id:

if (~isempty(id)) %query with id and time
str=sprintf(['for $locs in collection("Localizations")/ty:Localize where $locs/Id="%s" return ' ...
             'for $loc in $locs/Localizations/Localization/Time where $loc>"%s" and $loc<"%s" return' ...
             '<Result> <Loc> {$loc} </Loc> </Result>'], id, start, stop);
              
if (~isempty(lat1)) %query with id, lat/long bounding box and time
str=sprintf(['for $locs in collection("Localizations")/ty:Localize where $locs/Id="%s" return ' ...
             'for $loc in $locs/Localizations/Localization where $loc/Time>"%s" and $loc/Time<"%s" ' ...
             'and $loc/LongLat/Longitude>%s and $loc/LongLat/Latitude>%s ' ...
             'and $loc/LongLat/Longitude<%s and $loc/LongLat/Latitude<%s return ' ...
             '<Result>{string($loc/LongLat/Latitude) },{ string($loc/LongLat/Longitude)}, ' ...
             '{string($loc/Time)},' ...
             '</Result>'], id, start, stop, long1{2}, lat1{2}, long2{2}, lat2{2});  
         
else %query with time only
str=sprintf([' for $det in collection("Localizations")/ty:Localize/Localizations/Localization ' ...
        'where $det/Time>"%s" and $det/Time<"%s" return' ...
        '<Result> <Loc> { string($det/LongLat/Latitude)}, {string($det/LongLat/Longitude)} </Loc> </Result>'], start, stop)
simple=1;

end
             
%str=sprintf(' <Result> {for $det in collection("Localizations")/ty:Localize/Localizations/Localization where $det/Time> "asdf" and $det/Time< " %s " return <out> { string($det/LongLat/Latitude ),  string($det/LongLat/Longitude)} </out>} </Result>  ', start);

%str=inline(str)

%evalString = sprintf("most of the string with %s a placeholder", extraArg);
%strs = eval( str );
%out=q.QueryTethys('<Result> { for $det in
%collection("Localizations")/ty:Localize/Localizations/Localization where $det/Time>"2011-09-21T21:20:01.000" and $det/Time<"2011-10-10T21:20:01.000" return  <out> { string($det/LongLat/Latitude ), string($det/LongLat/Longitude), string($det/Time)} </out>} </Result> ' );

%str1='<Result> {for $det in  collection("Localizations")/ty:Localize/Localizations/Localization where $det/Time>"2011-09-21T21:20:01.000" and $det/Time<"2011-10-10T21:20:01.000" return  <out> { string($det/LongLat/Latitude ), string($det/LongLat/Longitude)} </out>} </Result> ';
%str11='<Result> { for $det in  collection("Localizations")/ty:Localize/Localizations/Localization where $det/Time>start and $det/Time<stop return  <out> { string($det/LongLat/Latitude ), string($det/LongLat/Longitude), string($det/Time)} </out>} </Result> ';

%str21=regexprep(str11, 'start', start);
%str21=regexprep(str21, 'stop', stop); 

%str2=strcat('<Result> { for $det in  collection("Localizations")/ty:Localize/Localizations/Localization where $det/Time>',start)

%str2=strcat(str2, 'and $det/Time<')

%str2=strcat(str2, stop)
%str2=strcat(str2, 'return  <out> { string($det/LongLat/Latitude ), string($det/LongLat/Longitude), string($det/Time)} </out>} </Result>' )

%and $det/Time<"2011-10-10T21:20:01.000" return  <out> {
%string($det/LongLat/Latitude ), string($det/LongLat/Longitude), string($det/Time)} </out>} </Result> ')

%if (strcmp(str, str1))
%    display True
%end
%j_result = q.Query(str);

out=q.QueryTethys(str);

out=char(out);
out=strrep(char( strrep(out, '<Result>','') ) , '</Result>','' ); %parse xml 
out=strrep(char(out), '<Loc>',' ');
newstr=strrep(out, '</Loc>', ' ');
a=strsplit(newstr, ',');
b=size(a); 

if (simple) %no depth or time
    out6=str2num(char(newstr));
end

if (~isempty(time)) %time of localization
    out6=reshape(a, 3, b(2)/3); 
    out6=transpose(out6); 
%out6=newstr; 
    time=char(out6(:,3));
    out6=[ str2num(char(out6(:,1))) str2num( char( out6(:,2))) ];
end
%colormarkerswebmap(out6, time);
%call map optionally with depth or time of localization.
vizMarkerWebmap(out6, time,'',''); 
end