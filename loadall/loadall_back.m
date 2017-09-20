%load all

%folder structure (all:(deploy, detect, ensemble, locs))
%all: .m files
%detect: .mat input files
%locs: .mat loc input files
%all: array_struct
%sourcemaps: 4 sourcemaps dets, depl, ens, locs

%start: in root folder
%execute loadall.mat

%end load 14 deploys, 4 ensembles, locs for number of days, detects for
%number of days
cd \testloadall; 
fdetnames=dir('./detections/*.mat');
flocnames = dir('./localizations/*.mat');
load('c:\testloadall/ensembles/hydrophone_struct.mat'); 
load('c:\testloadall/ensembles/array_struct.mat'); %load array_struct

numfids = length(fdetnames);

autoloaddetections(); 

%load all mat file for localization to be located in ../localizations:
%for k=1:1

for k=1:numfids
   cd ..;
   cd ./localizations;
   load(flocnames(k).name ); %load locs
   cd ..;
   cd ./detections; 
   load(fdetnames(k).name);%load dets
   
  % 1.autodet
   % 2.autoloc
end

%3. autoens
%4. autohyd



%Order of action: 
%LOAD FIRST DETECTION MAT FILE
%LOAD FIRST LOC MAT FILE
%LOAD array_struct


%execute autoload dets 
%execute autoload locs
%execute autoload ensembles
%execute autoload deployments


%load array_struct
%   load 1st det, 1st locs
    
 %   for i= 1: length(files)
  %     load detections(i).names
   %    load locs(i).names