%loadall P. Miller 2017
function loadall()

%Summary: 
%The input files should be copied into the correct folders to begin.
%The folder organization is (all:(deployments, detections, ensemble, localizations))
%Folder all contains the matlab program files, array_struct, hydrophone_struct and the SourceMap files
%The order of execution is first the SourceMap container are preloaded into the
%Tethys database. The array structs are then loaded.
%The detections, localizations, deployments and ensembles are loaded into
%their respective containers. Lastly, the database is queried to determine
%the numbers of documents loaded into each container. 

%Execution: loadall()

%Output: Displays the number of documents loaded into each container. 


%1. Load sourcemaps into database

filename='SIO.detdex26.xml'; 
command=sprintf('import.py --file %s SourceMaps', filename);
system(command);

filename='deployments.xml'; 
command=sprintf('import.py --file %s SourceMaps', filename);
system(command);

filename='ensemble1.xml'; 
command=sprintf('import.py --file %s SourceMaps', filename);
system(command);

filename='SIO.Loc.v570.xml'; 
command=sprintf('import.py --file %s SourceMaps', filename);
system(command);

%2. Load array structs 

load('c:/loadall/ensembles/array_struct.mat')
cd 'c:/loadall/ensembles'; 
build_ensembles('array_struct.mat', 'test', 'base'); %1

%3. Load detections into database
cd 'c:/loadall/detections'; 
autoloaddetections(); 

%4. Load deployments into database 
cd 'c:/loadall/deployments';

autoloaddeployment(); 

cd /loadall; 

fdetnames=dir('./detections/*.mat');
flocnames = dir('./localizations/*.mat');
load('c:/loadall/ensembles/hydrophone_struct.mat'); 
load('c:/loadall/ensembles/array_struct.mat'); %load array_struct

numfids = length(fdetnames);

%5. Load localizations into database
autoloadlocs(); 

%6 Test installation

detections=q.QueryTethys('count(collection("Detections")/ty:Detections)');
display 'Number of detection documents stored ', detections
localizations=q.QueryTethys('count(collection("Localizations")/ty:Localize)');
display 'Number of localization documents stored ', localizations
ensembles=q.QueryTethys('count(collection("Ensembles")/ty:Ensemble)');
display 'Number of ensemble documents stored ', ensembles
deployments=q.QueryTethys('count(collection("Deployments")/ty:Deployment)');
display 'Number of deployment documents stored ', deployments
