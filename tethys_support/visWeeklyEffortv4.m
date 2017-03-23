function datasets = visWeeklyEffortv4(queryEng, varargin)

%plots = visWeeklyEffort(queryEngine, Arguments);
%write me

%Path to save plots
path = '';
%input flags, overwritten via user input
save=false;
sub_yr=false;
start = false;
stop = false;
usr_max=false;
usr_calls=false;
usr_sites = false;
usr_depls = false;
usr_duty = true;
make_plots = true;
get_scores = false;
count=0;
iter=0;
 

%defaults
type = 'site'; %plot type to make
varied_depls = false; % same deployments all sites, or specific?
varied_calls = false; % same calls for all species, or specific?
xstep_unit = 'month'; %monthly marks
xstep_length = 1; %each month
granularity = '';
combine_calls = false;

%storage for inputs
site_cells={};
depl_cells={};
sp_cells = {};
call_cells = {[]};

%counts, will be changed if input.
site_count = 1;
depl_count = 1;
sp_count = 1;
call_count = 1;

req_input = {'Project','SpeciesID','Call','Site','Deployment'};%minimum arguments
q_input = {}; %will get populated to send to dbGetEffort/Detections
vidx=1;
while vidx <= length(varargin)
    switch varargin{vidx}
        case 'Document'%not implemented
            doc_id = strcat('dbxml:///Detections/', varargin{vidx+1});
            document = true;
            vidx = vidx+2;
        case 'UserID',
            userid = varargin{vidx+1};
            q_input = [q_input,'UserID',userid];
            vidx = vidx+2;
        case 'Project'
            project = varargin{vidx+1};
            token = find( cellfun(@(input) strcmp(input,'Project'),req_input));
            req_input(token)=[];
            q_input = [q_input,'Project',project];
            vidx = vidx+2;
        case 'Granularity'
            granularity = varargin{vidx+1};
            q_input = [q_input,'Granularity',granularity];
            q_granIdx = length(q_input);
            vidx = vidx+2;
        case 'Site'
            site_count = 0; %reinit
            if iscell(varargin{vidx+1})
                site_cells = varargin{vidx+1};
                site_count = length(site_cells);
            else
                site_cells = varargin(vidx+1);
                site_count = 1;
            end
            token = find( cellfun(@(input) strcmp(input,'Site'),req_input));
            req_input(token)=[];
            usr_sites = true;
            q_input = [q_input,{'Site',''}];
            q_siteIdx = length(q_input);
            vidx = vidx+2;
        case 'Deployment'
            depl_count = 0; %reinit
            if iscell(varargin{vidx+1})
                depl_cells = varargin{vidx+1};
            else
                depl_cells = varargin(vidx+1);
            end
            for i=1:length(depl_cells)
                depl_cells{i} = sort(depl_cells{i});
                depl_count = depl_count+numel(depl_cells{i});
            end
            token = find( cellfun(@(input) strcmp(input,'Deployment'),req_input));
            req_input(token)=[];
            q_input = [q_input,{'Deployment',[]}];
            q_depIdx = length(q_input);
            usr_depls=true;
            %determine if same for all, or diff for each
            if length(depl_cells)>1
                varied_depls = true;
            end
            vidx = vidx+2;
        case 'SpeciesID'
            if iscell(varargin{vidx+1})
                sp_cells = varargin{vidx+1};
                sp_count = length(sp_cells);
            else
                sp_cells = varargin(vidx+1);
                sp_count = 1;
            end
            for i =1:sp_count
                maxY.(sp_cells{i}) = 0; %saves maximum values per-species
            end
            q_input = [q_input,{'SpeciesID',''}];
            q_spIdx = length(q_input);
            token = find( cellfun(@(input) strcmp(input,'SpeciesID'),req_input));
            req_input(token)=[];
            vidx = vidx+2;
        case 'Group'
            group = varargin{vidx+1};
            grouped = true; % flag
            q_input = [q_input,'Group',group];
            vidx = vidx+2;
        case 'UserDefined'
            q_input = [q_input,'UserDefined',varargin(vidx+1)];
            vidx = vidx+2;
        case {'Software','Method','Version'}
            q_input = [q_input,varargin{vidx},varargin(vidx+1)];
            vidx = vidx+2;
        case 'Call'
            if iscell(varargin{vidx+1}) && iscell(varargin{vidx+1}{1})
                call_cells = varargin{vidx+1};
            elseif iscell(varargin{vidx+1})
                call_cells = varargin(vidx+1);
            else
                call_cells = {varargin(vidx+1)};
            end
            if length(call_cells)>1
                %we're quering different calls for each input sp
                %else, only 1 call and 1 species entered
                varied_calls = true;
            end
            usr_calls = true;
            q_input = [q_input,{'Call',''}];
            token = find( cellfun(@(input) strcmp(input,'Call'),req_input));
            req_input(token)=[];
            q_callIdx = length(q_input);
            vidx = vidx+2;
        case 'XStep'
            if iscell(varargin{vidx+1})
                xstep_length = varargin{vidx+1}{1};
                xstep_unit = varargin{vidx+1}{2};
            else
                xstep_unit = varargin{vidx+1};
            end
            vidx = vidx+2;
        case 'SaveTo'
            path = varargin{vidx+1};
            save = true;
            vidx =vidx+2;
        case 'Start'
            usr_start = varargin{vidx+1};
            start=true;
            vidx=vidx+2;
        case 'End'
            usr_stop = varargin{vidx+1};
            stop = true;
            vidx=vidx+2;
        case 'YMax'
            usr_max = true;
            yMax_usr = varargin{vidx+1};
            vidx = vidx+2;
        case 'Duty'
            usr_duty = varargin{vidx+1};
            vidx = vidx+2;
        case 'BinSize_m'
            binsize_m = varargin{vidx+1};
            q_input = [q_input,'BinSize_m',binsize_m];
            q_binIdx = length(q_input);
            vidx = vidx+2;
        case 'Plot'
            %ignore making plots?
            make_plots = varargin{vidx+1};
            vidx = vidx+2;
        case 'CombineCall'
            %include call granularity with the query as well.
            %should ONLY  be done with a primary granularity of binned
            combine_calls = varargin{vidx+1};
            vidx = vidx+2;
        case 'Type'
            switch(lower(varargin{vidx+1}))
                case 'yearly'
                    type = 'yearly';
                case 'subPlot'
                    type = 'subplot';
                case 'site'
                    type = 'site';
                case 'score'
                    get_scores = true;
                otherwise
                    error('Bad arugment:  %s', varargin{vidx+1});
            end
            vidx = vidx+2;
        otherwise
            error('Bad arugment:  %s', varargin{vidx});
    end
end

if ~isempty(req_input)
    error('Missing argument: %s\n',req_input{:});
end

if usr_depls
    if ~usr_sites && varied_depls
        error('Must enter Sites to correspond to the deployments entered')
    elseif usr_sites && site_count ~=length(depl_cells)&& varied_depls
        error('Number of deployments must match number of sites')
    end
end


%determine number of calls if entered
%Populate per-species.
if usr_calls
    call_count = 0;
    for i=1:length(call_cells)
        spCalls = call_cells{i};
        spCall_count = length(spCalls);
        if spCall_count>2
            %check for subtype(s)
            tokens = find(cellfun(@(calls) strcmp(calls,'Subtype'),spCalls));
            if ~isempty(tokens)
                spCall_count = length(tokens) + ... %number of tokens
                    mod(spCall_count,length(tokens)*3); % number of non-subtyped
            end
        end
        call_count = call_count + spCall_count;
    end
end

%determine number of queries
%Since counts start as 1, even if no
%deployments/sites/calls entered, it will calc properly.
N_queries=0;
N_data=0; % site & call queries
if length(call_cells) == sp_count
    N_queries = call_count * depl_count * site_count;
    N_data = call_count * site_count;
    if varied_depls
        N_queries = call_count * depl_count;
    end
elseif sp_count > length(call_cells) && length(call_cells)==1
    %otherwise, we're quering the same calls for sp (or no calls entered)
    N_queries = sp_count*call_count * depl_count * site_count;
    N_data = sp_count*call_count * site_count;
    if varied_depls
        N_queries = sp_count*call_count * depl_count;
    end
    
else
    error('Unbalanced input of species and calls')
end

%loop:
%Species
%%%%Call
%%%%%%%%Site
%%%%%%%%%%%%Deployment

%Populate structs that contain all info to be used on each plot.


if usr_max
    data(N_data) = struct('Effort',[],'Subtype','','maxY',yMax_usr);
else
    data(N_data) = struct('Effort',[],'Subtype','','maxY',-1);
end
all_effort = [];
datIdx = 1;
qIdx = 1; %counter for queries

for spidx=1:sp_count %spp
    spID = sp_cells{spidx};
    if varied_calls
        spCall_count = length(call_cells{spidx});
        spCalls = call_cells{spidx};
    else
        spCall_count = length(call_cells{1}); %
        spCalls = call_cells{1}; %calls for this sp
    end
    cidx = 1;
    while cidx <= spCall_count %call
        call = spCalls{cidx};
        input = q_input;
        subtype = '';
        %check for subtype, if not at end
        if spCall_count > 2 && cidx~=spCall_count &&strcmp(spCalls{cidx+1},'Subtype')
            %move over
            cidx = cidx+2;
            subtype = spCalls{cidx};
            %add Subtype to input, record position
            input = [input,'Subtype',subtype];
            q_subIdx = length(input);
            data(datIdx).Subtype = subtype;
        end
        cidx = cidx + 1;
        for sidx=1:site_count
            detections = [];
            site = site_cells{sidx};
            if varied_depls
                siteDepl_count = length(depl_cells{sidx});
                siteDepls = depl_cells{sidx};
            else
                siteDepl_count = length(depl_cells{1});
                siteDepls = depl_cells{1};
            end
            for didx = 1:siteDepl_count
                depl = siteDepls(didx);
                %lowest level, populate inpts
                input{q_spIdx} = spID;
                if strcmp(call,'all')
                    input(q_callIdx-1:q_callIdx) = [];
                else
                    input{q_callIdx} = call;
                end
                input{q_siteIdx} = site;
                input{q_depIdx} = depl;
                %lowest level, populate plot struct
                data(datIdx).spID = spID;
                data(datIdx).Call = call;
                if ~isempty(subtype)
                    data(datIdx).Subtype = subtype;
                end
                data(datIdx).Site = site;
                data(datIdx).Deployment(didx).ID = depl;
                
                
                fprintf('getting effort for %s%02d%s - %s.%s.%s..',...
                    project,depl,site,spID,call,subtype);
                
                %query
                effort = ...
                    dbGetEffort(queryEng,input{:});
                %run query again as calls if requested
                if strcmp(granularity,'binned') && combine_calls
                    c_input = input;
                    c_input{q_granIdx} = 'call';
                    %remove binsize input
                    c_input{q_binIdx} = [];
                    c_input{q_binIdx-1} = [];
                    %remove empties
                    c_input= c_input(~cellfun('isempty', c_input));
                    effort = [effort dbGetEffort(queryEng,c_input{:})];
                end
                
                
                [x,y] = size(effort);
                if x*y > 2
                    fprintf('\n**Multiple Efforts Detected (short breaks will be truncated)\n')
                    for i =1:x
                        fprintf('Range %d: %s  to  %s\n',i,...
                            datestr(effort(i,1)),...
                            datestr(effort(i,2)));
                    end
                    fprintf('\n');
                elseif x*1 ==1
                    fprintf('\nRange: %s  to  %s\n\n', ...
                        datestr(effort(1,1)),...
                        datestr(effort(1,2)));
                elseif x*y == 0
                    fprintf('no effort found\n');
                end
                all_effort = [all_effort;effort];
                data(datIdx).Deployment(didx).Effort = effort;
                if ~isempty(data(datIdx).Deployment(didx).Effort)
                    data(datIdx).Effort = [data(datIdx).Effort;effort];
                    %get deployment & duty info
                    if usr_duty %default true
                        depl_info = dbDeploymentInfo(queryEng,...
                            'Project',project,'Site',site,'DeploymentID',depl);
                        interval = depl_info.SamplingDetails.Channel.DutyCycle.Regimen.RecordingInterval_m; %was originally _m{1};
                        duration = depl_info.SamplingDetails.Channel.DutyCycle.Regimen.RecordingDuration_m;  %was originally _m{1};
                        data(datIdx).Deployment(didx).Interval_h = ...
                            interval/60;
                        data(datIdx).Deployment(didx).Duration_h = ...
                            duration/60;
                    else
                        data(datIdx).Deployment(didx).Interval_h = 0;
                        data(datIdx).Deployment(didx).Duration_h = 0;
                    end
                    %get detections
                    if ~get_scores
                        detections=...
                            dbGetDetections(queryEng,input{:});
                    else
                        input = [input,{'Return','Score'}];
                        [detections,~,info] = dbGetDetections(queryEng,input{:});
                        data(datIdx).Deployment(didx).Scores = info.Score;
                        input(end-1:end) = [];
                    end
                    
                    
                    
                    %run query again as calls if requested
                    if strcmp(granularity,'binned') && combine_calls
                        detections = [detections dbGetDetections(queryEng,c_input{:})];
                    end

                    %%if they're binned, floor them, add the binsize_m as
                    %%end 
                    if strcmp(granularity,'binned') && ~isempty(detections)
                        start_vec = datevec(detections(:,1));
                        start_vec(:,5:6) = 0;
                        detections = datenum(start_vec);
                        %put back into struct
                        data(datIdx).Deployment(didx).Detections(:,1) = detections;
                        %add ends
                        for i=1:length(detections)
                        data(datIdx).Deployment(didx).Detections(i,2) = ...
                            addtodate(detections(i,1),binsize_m,'minute');
                        end
                    else
                        data(datIdx).Deployment(didx).Detections = detections;
                    end
                    
                end
                qIdx = qIdx+1;
            end
            %if there was no effort at all, don't increment
            if ~isempty(data(datIdx).Effort)
                datIdx = datIdx+1;
            end
        end
    end
end

if datIdx == 1 && isempty(data(datIdx).Effort)
    disp('no effort found!')
    return
end

%%%Determine timeframe of data
startnums = all_effort(:,1);
endnums = all_effort(:,2);
years = sort(unique(year(all_effort)));

%%user defined start/stop
if start && stop
    years = year(usr_start):year(usr_stop);
end

earliest_start = min(startnums);
latest_end = max(endnums);

startday = floor(earliest_start);
endday = ceil(latest_end);

%pad graph a week before and after effort times.
startday = startday - 7;
endday = endday +7;

pstart = startday;
pstop = endday;

%user entered?
if start
    pstart = usr_start;
end
if stop
    pstop = usr_stop;
end

%%%check for overlaps
%%%calculate number of hours and days for the deployments (inner,eidx)
for datIdx=1:length(data)
    data(datIdx).daily_totals=[];
    for didx = 1:length(data(datIdx).Deployment)
        %effort overlap
        effort = data(datIdx).Deployment(didx).Effort;
        if ~isempty(effort)
            effort = sortrows(effort,1);
            
            total = size(effort,1);
            for j = total-1:-1:1
                uprLt = effort(j,1);
                lwrLt = effort(j+1,1);
                uprRt = effort(j,2);
                lwrRt = effort(j+1,2);
                isOverlap = (lwrLt <= uprRt + 0.0375);
                if isOverlap
                    %store overlap if we want to plot later
                    data(datIdx).Deployment(didx).EffOverlap = intersect([floor(uprLt):floor(uprRt)],...
                        [floor(lwrLt):floor(lwrRt)]);
                    if uprRt < lwrRt
                        effort(j,2) = effort(j+1,2);
                    end
                    effort(j+1,:) = [];
                end
            end
            %apply new effort dates
            data(datIdx).Deployment(didx).Effort = effort;
            
            %organize deployment timeframe, days, hours .. based on effort
            %more init
            data(datIdx).Deployment(didx).units_of_effort=[]; %stores num_hrs per day on effort
            data(datIdx).Deployment(didx).days_of_deployment=[]; %stores all days even with effort gaps
            data(datIdx).Deployment(didx).length_deployment=[]; %count of days in deployment
            for eidx = 1:size(data(datIdx).Deployment(didx).Effort,1)
                %expand out each day of effort
                days_of_effort=floor(effort(eidx,1)):floor(effort(eidx,2)); %vector of all recording days
                days_of_effort = days_of_effort';
                
                %sometimes effort restarts where effort ends (the same day)
                %need to accouunt for that, i.e., merge days by comparing
                if eidx>1 && data(datIdx).Deployment(didx).days_of_deployment(end) == days_of_effort(1)
                    days_of_effort = days_of_effort(2:end);
                end
                hours_per_day = ones(length(days_of_effort),1)*24;
                hours_per_day(1) = 24-((effort(eidx,1) - floor(effort(eidx,1)))*24);
                hours_per_day(end) = (effort(eidx,2) - floor(effort(eidx,2)))*24;
                %incorporate duty cycle into hours per day
                if data(datIdx).Deployment(didx).Duration_h >0
                    intervals_per_day = hours_per_day / data(datIdx).Deployment(didx).Interval_h;
                    %actual hours spent recording
                    hours_per_day = intervals_per_day * data(datIdx).Deployment(didx).Duration_h;
                end
                
                %fill in gaps between effort for a deployment
                days_of_deployment = days_of_effort;
                if eidx < size(data(datIdx).Deployment(didx).Effort,1)
                    days_between_effort=ceil(effort(eidx,2)):1:floor(effort(eidx+1,1))-1;
                    days_between_effort = days_between_effort';
                    %append the gap
                    days_of_deployment = [days_of_deployment;days_between_effort];
                    %set effort hours for this gap to 0
                    num_days = length(days_between_effort);
                    hours_per_day(end+num_days) = 0;
                end
                data(datIdx).Deployment(didx).days_of_deployment = ...
                    [data(datIdx).Deployment(didx).days_of_deployment;days_of_deployment];
                data(datIdx).Deployment(didx).length_deployment = ...
                    length(data(datIdx).Deployment(didx).days_of_deployment);
                data(datIdx).Deployment(didx).units_of_effort= ...
                    [data(datIdx).Deployment(didx).units_of_effort;hours_per_day];
            end
            
            %cell array containing the days of the deployment
            days_of_data = {};
            days_of_data=zeros(length(data(datIdx).Deployment(didx).days_of_deployment),1);
            days_of_data(:,1)= data(datIdx).Deployment(didx).days_of_deployment(:);
            %append to deployment
            data(datIdx).Deployment(didx).deployment_days = days_of_data;
            
            %%%organize detections
            dets = data(datIdx).Deployment(didx).Detections;
            if ~strcmp(granularity,'call')
                %check detection overlap on non-call
                
                if ~isempty(dets)
                    dets = sortrows(dets,1);
                    total = size(dets,1);
                    for j = total-1:-1:1
                        uprLt = dets(j,1);
                        lwrLt = dets(j+1,1);
                        uprRt = dets(j,2);
                        lwrRt = dets(j+1,2);
                        isOverlap = (lwrLt <= uprRt );
                        if isOverlap
                            %store overlap if we want to plot later
                            data(datIdx).Deployment(didx).DetOverlap = intersect([floor(uprLt):floor(uprRt)],...
                                [floor(lwrLt):floor(lwrRt)]);
                            if uprRt < lwrRt
                                dets(j,2) = dets(j+1,2);
                            end
                            dets(j+1,:) = [];
                        end
                    end
                    %reapply detections
                    data(datIdx).Deployment(didx).Detections = dets;
                    
                    
                    %find elapsed time, anything under 1 minute is rounded up to 1 min.
                    %Do this only for non-call detections
                    
                    spdatediff = bsxfun(@minus,dets(:,2), dets(:,1));
                    minute = .0007;
                    for itr=1:length(spdatediff)
                        if spdatediff(itr)<= minute
                            spdatediff(itr)= minute;
                        end
                    end
                end
            end
            
            daily_totals = []; %storage for summed times
            k =1;
            idx = 1;
            % Add up all bouts that happened on the same julian day - this is GMT.
            if ~isempty(dets)
                starttimes=floor(dets(:,1));
                while idx<=length(starttimes)
                    same_days =[];
                    same_days = find (starttimes == starttimes(idx));
                    daily_totals(k,1)= starttimes(idx);
                    if ~strcmp(granularity,'call')
                        hours_that_day= sum(spdatediff(same_days))*24;
                        daily_totals(k,2) = hours_that_day;
                    else
                        %for call detections, just need to count the number
                        daily_totals(k,2)= length(same_days);
                    end
                    k = k+1; %increment row
                    idx=max(same_days)+1; %increment day index
                end
                data(datIdx).daily_totals = [data(datIdx).daily_totals;daily_totals];
            end
        end
    end
    
    %For encounters spanning >24 hours, carry excess into the next
    %day. Do this by iterating through the array, looking for >24.
    if strcmp(granularity,'encounter')
        daily_totals = data(datIdx).daily_totals;
        if ~isempty(daily_totals)
            idx = 1;
            while idx<=size(daily_totals,1)
                day = daily_totals(idx,1);
                summed_hrs = daily_totals(idx,2);
                if summed_hrs >24
                    excess = summed_hrs - 24;
                    %cap
                    daily_totals(idx,2) = 24;
                    %find the next day
                    index = find(daily_totals==day+1);
                    if isempty(index)
                        %add the next day and excess
                        daily_totals(end+1,1) = day+1;
                        daily_totals(end,2) = excess;
                        daily_totals = sortrows(daily_totals);
                    else
                        daily_totals(index,2) = daily_totals(index,2)+excess;
                    end
                end
                idx = idx+1;
            end
            data(datIdx).daily_totals = daily_totals;
        end
    end
end%end data loop

%compute per week info: cumulative hours, start datenums,percent effort

switch type
    case 'site'
        %each plot will be based on an entry in the data struct
        %each deployment will be plotted together per site/call/spp
        N_plots = 1; %1 plot per data set
        plot_span(N_plots,1) = pstart;
        plot_span(N_plots,2) = pstop;
        
        
    case 'yearly'
        %each plot contains the deployments for that year only.
        %make enough plots to cover all years
        pstart = datenum([years(1) 01 01]);
        pstop = datenum([years(end) 12 31]);

        N_plots = length(years); %for each year per dataset
        for i=1:N_plots
            plot_span(i,1) = datenum([years(i) 01 01]);
            plot_span(i,2) = datenum([years(i) 12 31]);
        end
        
    case 'subplot'
        %one plot, with N sublots for each year
        N_plots = 1; %one plot per dataset
        N_subplots = length(years);
        pstart = datenum([years(1) 01 01]);
        pstop = datenum([years(end) 12 31]);
end

%Final organization of data to be plotted
for datIdx=1:length(data)
    %create vector containing all days from start to stop
    plot_days = pstart:pstop;
    plot_days = plot_days';
    
    %create the weeks
    num_of_weeks = ceil(length(plot_days)/7);
    
    %add daily eff hours
    %loop thru deployments to get the hours and days
    data(datIdx).eff_deployments = []; %stores deployments with effort
    for didx = 1:length(data(datIdx).Deployment)
            if ~isempty(data(datIdx).Deployment(didx).days_of_deployment)
                data(datIdx).eff_deployments = ...
                    [data(datIdx).eff_deployments,data(datIdx).Deployment(didx).ID];
                dep_start =data(datIdx).Deployment(didx).days_of_deployment(1);
                eff_hrs = data(datIdx).Deployment(didx).units_of_effort;
                start_idx=find(plot_days == dep_start);
                end_idx = length(eff_hrs)+start_idx-1; %should be == length_deployment+1, since counting (1)
                if end_idx-start_idx+1 ~=data(datIdx).Deployment(didx).length_deployment
                    error('deployment length error: %s %d',data(datIdx).Site,data(datIdx).Deployment(didx).ID);
                end
                plot_days(start_idx:end_idx,2) = eff_hrs;
            end
    end
    
   
    data(datIdx).cum_hrs = zeros(num_of_weeks,1);
    data(datIdx).pcnt_eff = zeros(num_of_weeks,1);
    data(datIdx).week = zeros(num_of_weeks,1);
    
    dt_idx = 1; %keeps track of the days we've added
    for i = 1:num_of_weeks
        % Use the first day of the week to identify the week
        hrs_wk = [];
        first_day = 7*(i-1) + 1;
        last_day = min(first_day + 6, size(plot_days ,1));
        data(datIdx).week(i,1) = plot_days(first_day);
        data(datIdx).pcnt_eff(i,1) = ...
            (sum(plot_days(first_day:last_day,2))/(7*24))*100;
        %check daily totals that fall within that week
        while dt_idx<=size(data(datIdx).daily_totals,1)
            hit_day = data(datIdx).daily_totals(dt_idx,1);
            hit_hrs = data(datIdx).daily_totals(dt_idx,2);
            if hit_day >= plot_days(first_day) && ...
                    hit_day <= plot_days(last_day)
                %takes place this week, add it
                hrs_wk = [hrs_wk,hit_hrs];
                dt_idx = dt_idx+1;
            else
                break; %cancel the loop
            end
        end
        data(datIdx).cum_hrs(i,1) = sum(hrs_wk);
    end
    
    %Get and save YMax for this species
    max_hrs = max(data(datIdx).cum_hrs);
    if max_hrs > maxY.(data(datIdx).spID)
        maxY.(data(datIdx).spID) = max_hrs;
    end
    
    data(datIdx).plot_days = plot_days;
    groupmax=max(maxY.(data(datIdx).spID )); %pm
end
    
fprintf('Plot Start: %s\n',datestr(pstart));
fprintf('Plot End: %s\n\n',datestr(pstop));

datasets = struct('Data',data);
if ~make_plots
    return
end

if (iter==0) %pm
    groupmax=max(data(1).cum_hrs); %pm change to calculate once
    for datIdx=2:length(data)
        if max(data(datIdx).cum_hrs) >groupmax
            groupmax=max(data(datIdx).cum_hrs);
        end
    end % pm
end %end iter

iter=iter+1;  

%%%Plotting section
%initializes figures, calls code to actually produce plot
for datIdx=1:length(data);
    for n=1:N_plots
        %prepare for plotting
        site = data(datIdx).Site;
        species = num2str(data(datIdx).spID);
        call = data(datIdx).Call;
        subtype = data(datIdx).Subtype;
        deployments = num2str(data(datIdx).eff_deployments,'%d.');
        
        if data(datIdx).maxY == -1
            data(datIdx).maxY = maxY.(species);
        end
        
        if isempty(subtype)
            title = sprintf('Plot %d: %s%s%s - %s - %s', ...
                n, project,deployments, site, species, call);
        else
            title = sprintf('Plot %d: %s%s%s - %s - %s.%s', ...
                n, project,deployments, site, species, call,subtype);
        end
        %plot size
        
        count=count+1;
        
        rect = [0,0,1200,250];

        fprintf('count is: %s', count);
   
       if usr_max
           
            visWeeklyPlotv4( data(datIdx),granularity,xstep_length,xstep_unit,groupmax, project, site_cells, count,'First',plot_span(n,1),'Last',plot_span(n,2),'YMax',true );
        else
            visWeeklyPlotv4(data(datIdx),granularity,xstep_length,xstep_unit,groupmax, count,'First',plot_span(n,1),'Last',plot_span(n,2),'YMax', false);
        end
    end
    disp('next set')
    
end

disp('finished, if many plots created, give it a second...')

