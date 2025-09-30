clear; close all; clc;

% Settings
filePath = 'G:\My Drive\Science\Projects\projects\2024_NIBS-BIDS\repository\nibs-bids-v5\prefrontal-itbs-beh\';

% Participants
id = 'sub-001';

%% Generate dataset_description.json

% Write .json file
% Define the structure for the JSON data
data = struct();

% List of field
data.Name = 'Example dataset: prefrontal iTBS and working memory experiment';
data.BIDSVersion = '1.11.0';
data.DatasetType = 'raw';
data.Licence = 'CC0';
data.Authors = ['Nigel Rogasch'];

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,'dataset_description.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

%% Generate README.md

% Define the markdown content
md_content = {
    '# Example data set: working memory before and after prefrontal iTBS.'
    ''
    ['This data set provides an example of formatting using a proposed ' ...
    'nibs-bidsv5 standard.']
    ''
    '## Experiment details'
    'The experiment involves collecting working memory data before and after prefrontal iTBS from an individual.'
    '4 protocols are performed:' 
    '* RMT'
    '* Pre working memory performance'
    '* iTBS over left prefrontal cortex (standard protocol).'
    '* Post working memory performance'
    ''
    'TMS is given over left prefrontal cortex. Neuronavigation is used to record TMS coil position.'
    ''
    '## Notes'
    'The data files are empty and do not correspond to BIDS data types.'
    'They are included for demonstration purposes only.'
    ''
};

% Define the output file name
filename = [filePath,'README.md'];

% Open the file for writing
fid = fopen(filename, 'w');

% Write each line to the file
for i = 1:length(md_content)
    fprintf(fid, '%s\n', md_content{i});
end

% Close the file
fclose(fid);

%% Generate participants.tsv

% List of inputs
participant_id = {id};
age = {'40'};
sex = {'M'};

% Write table
T = table(participant_id, age, sex, 'VariableNames', {'participant_id','age','sex'});
outputName = [filePath,'participants.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% List of field
data.age.Description = 'age of the participant';
data.age.Units = 'year';

data.sex.Description = 'sex of the participant as reported by the participant';
data.sex.Levels.M = 'male';
data.sex.Levels.F = 'female';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,'participants.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

%% Generate ses.tsv

% List of files
fileNames = {'ses-mri';...
    'ses-tmsbeh'};

% List of acquisiton times
acq_times = {'1877-06-14T13:00:00';...
    '1877-06-15T13:00:00'};

% Write table
T = table(fileNames, acq_times, 'VariableNames', {'session_id', 'acq_time'});
outputName = [filePath,id,filesep,id,'_sessions.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');


%% Generate scans.tsv and scans.json

% List of files
fileNames = {'sub-001_task-rmt_nibs.tsv';...
    'sub-001_task-workingmemory_run-1_beh.tsv';...
    'sub-001_task-itbs_nibs.tsv';...
    'sub-001_task-workingmemory_run-2_beh.tsv';...
    };

% List of acquisiton times
acq_times = {'1877-06-15T13:00:00';...
    '1877-06-15T13:10:00';...
    '1877-06-15T13:15:00';...
    '1877-06-15T13:20:00';...
    };

% Write table
T = table(fileNames, acq_times, 'VariableNames', {'filename', 'acq_time'});
outputName = [filePath,id,filesep,'ses-tmsbeh',filesep,id,'_scans.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

%% RMT files

% Task name
taskname = 'task-rmt';
sesname = 'ses-tmsbeh';

% _nibs.tsv
tms_rmt = {60};
tms_pos_centre = {'LeftM1'};
tms_pos_ydir = {'45'};
tms_pulse_shape = {'Monophasic'};
tms_pulse_direction = {'PA'};

% Write table
T = table(tms_rmt, tms_pos_centre,tms_pos_ydir,tms_pulse_shape, tms_pulse_direction, 'VariableNames', {'tms_rmt', 'tms_pos_centre','tms_pos_ydir','tms_pulse_shape','tms_pulse_direction'});
outputName = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_nibs.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.NIBSType = 'TMS';
data.NIBSDescription = 'Resting motor threshold';
data.Manufacturer = 'Magstim';
data.ManufacturerModelName = 'BiStim^2';
data.ManufacturerSerialNumber = '3234-00';
data.CoilDetails.ModelName = 'D70';
data.CoilDetails.SerialNumber = '4150-00';

data.tms_rmt.LongName = 'TMS Resting Motor Threshold';
data.tms_rmt.Description = 'Lowest stimulation intensity required to evoke at least 5 out of 10 MEPs with a peak-to-peak amplitude > 0.05 mV, described as a percentage of maximum stimulator output (MSO).';
data.tms_rmt.Units = 'percent';

data.tms_pos_centre.LongName = 'Position of the centre of the TMS coil.';
data.tms_pos_centre.Description = 'TMS Coil Position Relative to underlying anatomy.';
data.tms_pos_centre.Levels.LeftM1 = "Coil center positioned over Left M1 (primary motor cortex).";

data.tms_pos_ydir.LongName = 'TMS Coil Handle Direction';
data.tms_pos_ydir.Description = 'The angular direction of the TMS coil handle relative to the midline with handle pointing to posterior.';
data.tms_pos_ydir.Units = 'degrees';

data.tms_pulse_shape.LongName = 'Shape of the TMS pulse';
data.tms_pulse_shape.Description = 'Shape of the TMS pulse.';
data.tms_pulse_shape.Levels.Monophasic = 'Monophasic pulse shape';
data.tms_pulse_shape.Levels.Biphasic = 'Biphasic pulse shape';

data.tms_pulse_direction.LongName = 'Direction of the TMS pulse';
data.tms_pulse_direction.Description = 'Direction of the TMS pulse in the underlying cortex.';
data.tms_pulse_direction.Levels.PA = 'Posterior to anterior';
data.tms_pulse_direction.Levels.AP = 'Anterior to posterior';
data.tms_pulse_direction.Levels.PAAP = 'Posterior to anterior then anterior to posterior';
data.tms_pulse_direction.Levels.APPA = 'Anterior to posterior then posterior to anterior';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_nibs.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

%% iTBS files

% Task name
taskname = 'task-itbs';
sesname = 'ses-tmsbeh';

% _nibs.tsv
tms_intensity_mso = {42};
tms_pulse_shape = {'Biphasic'};
tms_pulse_direction = {'PAAP'};

n = 1;
tms_pos_r1_c1 = cell(n,1);
for i = 1:n
    tms_pos_r1_c1{i} = 1;
end
tms_pos_r1_c2 = cell(n,1);
for i = 1:n
    tms_pos_r1_c2{i} = 0;
end
tms_pos_r1_c3 = cell(n,1);
for i = 1:n
    tms_pos_r1_c3{i} = 0;
end
tms_pos_r1_c4 = cell(n,1);
for i = 1:n
    tms_pos_r1_c4{i} = 20;
end
tms_pos_r2_c1 = cell(n,1);
for i = 1:n
    tms_pos_r2_c1{i} = 0;
end
tms_pos_r2_c2 = cell(n,1);
for i = 1:n
    tms_pos_r2_c2{i} = 1;
end
tms_pos_r2_c3 = cell(n,1);
for i = 1:n
    tms_pos_r2_c3{i} = 0;
end
tms_pos_r2_c4 = cell(n,1);
for i = 1:n
    tms_pos_r2_c4{i} = 20;
end
tms_pos_r3_c1 = cell(n,1);
for i = 1:n
    tms_pos_r3_c1{i} = 0;
end
tms_pos_r3_c2 = cell(n,1);
for i = 1:n
    tms_pos_r3_c2{i} = 0;
end
tms_pos_r3_c3 = cell(n,1);
for i = 1:n
    tms_pos_r3_c3{i} = 1;
end
tms_pos_r3_c4 = cell(n,1);
for i = 1:n
    tms_pos_r3_c4{i} = 20;
end
tms_pos_r4_c1 = cell(n,1);
for i = 1:n
    tms_pos_r4_c1{i} = 0;
end
tms_pos_r4_c2 = cell(n,1);
for i = 1:n
    tms_pos_r4_c2{i} = 0;
end
tms_pos_r4_c3 = cell(n,1);
for i = 1:n
    tms_pos_r4_c3{i} = 0;
end
tms_pos_r4_c4 = cell(n,1);
for i = 1:n
    tms_pos_r4_c4{i} = 1;
end

% Write table
T = table(tms_intensity_mso,tms_pulse_shape,tms_pulse_direction,...
    tms_pos_r1_c1,tms_pos_r1_c2,tms_pos_r1_c3,tms_pos_r1_c4,...
    tms_pos_r2_c1,tms_pos_r2_c2,tms_pos_r2_c3,tms_pos_r2_c4,...
    tms_pos_r3_c1,tms_pos_r3_c2,tms_pos_r3_c3,tms_pos_r3_c4,...
    tms_pos_r4_c1,tms_pos_r4_c2,tms_pos_r4_c3,tms_pos_r4_c4,...
    'VariableNames', {'tms_intensity_mso','tms_pulse_shape','tms_pulse_direction',...
    'tms_pos_r1_c1','tms_pos_r1_c2','tms_pos_r1_c3','tms_pos_r1_c4',...
    'tms_pos_r2_c1','tms_pos_r2_c2','tms_pos_r2_c3','tms_pos_r2_c4',...
    'tms_pos_r3_c1','tms_pos_r3_c2','tms_pos_r3_c3','tms_pos_r3_c4',...
    'tms_pos_r4_c1','tms_pos_r4_c2','tms_pos_r4_c3','tms_pos_r4_c4',...
    });
outputName = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_nibs.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.NIBSType = 'TMS';
data.NIBSDescription = 'iTBS over left DLPFC';
data.Manufacturer = 'Magstim';
data.ManufacturerModelName = 'Rapid';
data.ManufacturerSerialNumber = '3234-00';
data.CoilDetails.ModelName = 'D70';
data.CoilDetails.SerialNumber = '4150-00';
data.NeuronavigationDetails.Manufacturer = 'BrainSight';
data.NeuronavigationDetails.ManufacturerModelName = 'BrainSight3';
data.NeuronavigationDetails.SoftwareVersions = '3.1';
data.NeuronavigationDetails.NeuronavigationCoordinateSystem = 'Other';
data.NeuronavigationDetails.NeuronavigationCoordinateUnits = 'RAS';
data.NeuronavigationDetails.NeuronavigationCooridinateSystemDescription = "RAS orientation: Origin halfway between LPA and RPA, positive x-axis towards RPA, positive y-axis orthogonal to x-axis through Nasion, z-axis orthogonal to xy-plane, pointing in superior direction.";
data.NeuronavigationDetails.NeuronavigationCoilCoordiateSystemDescription = "Origin is centre of the coil, positive x-axis towards the right of the coil, positive y-axis orthogonal to x-axis through and away from the coil handle, z-axis orthogonal to xy-plane along the planar surface of the coil, positive pointing up (i.e., away from the participant’s head) of the active side of the coil.";
data.NeuronavigationDetails.IntendedFor = "bids::sub-001/ses-mri/anat/sub-001_T1w.nii";

data.tms_intensity_mso.LongName = 'TMS intensity (set to 70% RMT)';
data.tms_intensity_mso.Description = 'TMS intensity of stimulation, described as a percentage of maximum stimulator output (MSO).';
data.tms_intensity_mso.Units = 'percent';

data.tms_pulse_shape.LongName = 'Shape of the TMS pulse';
data.tms_pulse_shape.Description = 'Shape of the TMS pulse.';
data.tms_pulse_shape.Levels.Monophasic = 'Monophasic pulse shape';
data.tms_pulse_shape.Levels.Biphasic = 'Biphasic pulse shape';

data.tms_pulse_direction.LongName = 'Direction of the TMS pulse';
data.tms_pulse_direction.Description = 'Direction of the TMS pulse in the underlying cortex.';
data.tms_pulse_direction.Levels.PA = 'Posterior to anterior';
data.tms_pulse_direction.Levels.AP = 'Anterior to posterior';
data.tms_pulse_direction.Levels.PAAP = 'Posterior to anterior then anterior to posterior';
data.tms_pulse_direction.Levels.APPA = 'Anterior to posterior then posterior to anterior';

data.tms_pos_r1_c1.LongName = 'Row 1 column 1 of affine transformation matrix describing coil position';
data.tms_pos_r1_c1.Description = 'Corresponds to the [1,1] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r1_c1.Units = 'n/a';

data.tms_pos_r1_c2.LongName = 'Row 1 column 2 of affine transformation matrix describing coil position';
data.tms_pos_r1_c2.Description = 'Corresponds to the [1,2] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r1_c2.Units = 'n/a';

data.tms_pos_r1_c3.LongName = 'Row 1 column 3 of affine transformation matrix describing coil position';
data.tms_pos_r1_c3.Description = 'Corresponds to the [1,3] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r1_c3.Units = 'n/a';

data.tms_pos_r1_c4.LongName = 'Row 1 column 4 of affine transformation matrix describing coil position';
data.tms_pos_r1_c4.Description = 'Corresponds to the [1,4] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r1_c4.Units = 'n/a';

data.tms_pos_r2_c1.LongName = 'Row 2 column 1 of affine transformation matrix describing coil position';
data.tms_pos_r2_c1.Description = 'Corresponds to the [2,1] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r2_c1.Units = 'n/a';

data.tms_pos_r2_c2.LongName = 'Row 2 column 2 of affine transformation matrix describing coil position';
data.tms_pos_r2_c2.Description = 'Corresponds to the [2,2] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r2_c2.Units = 'n/a';

data.tms_pos_r2_c3.LongName = 'Row 2 column 3 of affine transformation matrix describing coil position';
data.tms_pos_r2_c3.Description = 'Corresponds to the [2,3] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r2_c3.Units = 'n/a';

data.tms_pos_r2_c4.LongName = 'Row 2 column 4 of affine transformation matrix describing coil position';
data.tms_pos_r2_c4.Description = 'Corresponds to the [2,4] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r2_c4.Units = 'n/a';

data.tms_pos_r3_c1.LongName = 'Row 3 column 1 of affine transformation matrix describing coil position';
data.tms_pos_r3_c1.Description = 'Corresponds to the [3,1] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r3_c1.Units = 'n/a';

data.tms_pos_r3_c2.LongName = 'Row 3 column 2 of affine transformation matrix describing coil position';
data.tms_pos_r3_c2.Description = 'Corresponds to the [3,2] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r3_c2.Units = 'n/a';

data.tms_pos_r3_c3.LongName = 'Row 3 column 3 of affine transformation matrix describing coil position';
data.tms_pos_r3_c3.Description = 'Corresponds to the [3,3] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r3_c3.Units = 'n/a';

data.tms_pos_r3_c4.LongName = 'Row 3 column 4 of affine transformation matrix describing coil position';
data.tms_pos_r3_c4.Description = 'Corresponds to the [3,4] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r3_c4.Units = 'n/a';

data.tms_pos_r4_c1.LongName = 'Row 4 column 1 of affine transformation matrix describing coil position';
data.tms_pos_r4_c1.Description = 'Corresponds to the [4,1] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r4_c1.Units = 'n/a';

data.tms_pos_r4_c2.LongName = 'Row 4 column 2 of affine transformation matrix describing coil position';
data.tms_pos_r4_c2.Description = 'Corresponds to the [4,2] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r4_c2.Units = 'n/a';

data.tms_pos_r4_c3.LongName = 'Row 4 column 3 of affine transformation matrix describing coil position';
data.tms_pos_r4_c3.Description = 'Corresponds to the [4,3] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r4_c3.Units = 'n/a';

data.tms_pos_r4_c4.LongName = 'Row 4 column 4 of affine transformation matrix describing coil position';
data.tms_pos_r4_c4.Description = 'Corresponds to the [4,4] row/column position in the affine transformation matrix describing coil position.';
data.tms_pos_r4_c4.Units = 'n/a';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_nibs.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### Event files ###

% Task name
taskname = 'task-itbs';
sesname = 'ses-tmsbeh';

% _events.tsv
onset = {0};
duration = {188.8};
pulses_in_burst = {3};
inter_pulse_interval = {0.02};
bursts_in_train = {10};
inter_burst_interval = {0.2};
trains_in_protocol = {20};
inter_train_interval = {9.84};

% Write table
T = table(onset,duration,pulses_in_burst,inter_pulse_interval,bursts_in_train,inter_burst_interval,trains_in_protocol,inter_train_interval, 'VariableNames', {'onset','duration','pulses_in_burst','inter_pulse_interval','bursts_in_train','inter_burst_interval','trains_in_protocol','inter_train_interval'});
outputName = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_events.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.pulses_in_burst.LongName = 'Pulses in burst';
data.pulses_in_burst.Description = 'Number of pulses included in a burst.';
data.pulses_in_burst.Units = 'integer';

data.inter_pulse_interval.LongName = 'Inter-pulse interval';
data.inter_pulse_interval.Description = 'Interval in seconds between consecutive TMS pulses.';
data.inter_pulse_interval.Units = 'seconds';

data.bursts_in_train.LongName = 'Bursts in train.';
data.bursts_in_train.Description = 'Number of bursts included in a train.';
data.bursts_in_train.Units = 'integer';

data.inter_burst_interval.LongName = 'Inter-burst interval';
data.inter_burst_interval.Description = 'Interval in seconds between the first pulse in the intial burst and the first pulse in the subsequent burst.';
data.inter_burst_interval.Units = 'seconds';

data.trains_in_protocol.LongName = 'Trains in protocol.';
data.trains_in_protocol.Description = 'Number of trains included in a protocol.';
data.trains_in_protocol.Units = 'integer';

data.inter_train_interval.LongName = 'Inter-train interval';
data.inter_train_interval.Description = 'Interval in seconds between the first pulse in the intial train and the first pulse in the subsequent train.';
data.inter_train_interval.Units = 'seconds';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_events.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

%% beh files

% Task name
taskname = 'task-workingmemory';
sesname = 'ses-tmsbeh';

% _beh.tsv
accuracy = {70};

% Write table
T = table(accuracy, 'VariableNames', {'accuracy'});
outputName = [filePath,id,filesep,sesname,filesep,'beh',filesep,id,'_',sesname,'_',taskname,'_run-1_beh.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.TaskName = 'Working memory';

data.accuracy.LongName = 'Accuracy';
data.accuracy.Description = 'Percentage of correct responses.';
data.tms_rmt.Units = 'percent';


% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'beh',filesep,id,'_',sesname,'_',taskname,'_run-1_beh.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% Task name
taskname = 'task-workingmemory';
sesname = 'ses-tmsbeh';

% _beh.tsv
accuracy = {80};

% Write table
T = table(accuracy, 'VariableNames', {'accuracy'});
outputName = [filePath,id,filesep,sesname,filesep,'beh',filesep,id,'_',sesname,'_',taskname,'_run-2_beh.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.TaskName = 'Working memory';

data.accuracy.LongName = 'Accuracy';
data.accuracy.Description = 'Percentage of correct responses.';
data.tms_rmt.Units = 'percent';


% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'beh',filesep,id,'_',sesname,'_',taskname,'_run-2_beh.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

%% MRI files

% Task name
taskname = 'task-rest';
sesname = 'ses-mri';

% ### Empty data file ###
outputName = [filePath,id,filesep,sesname,filesep,'anat',filesep,id,'_',sesname,'_',taskname,'_T1w.mat'];
save(outputName);

% Write .json file
% Define the structure for the JSON data
data = struct();

data.MRIDetails = 'Include MRI details here.';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'anat',filesep,id,'_',sesname,'_',taskname,'_T1w.json'];

% Write the JSON data to a file
writejson(filename, jsonData);


%% Helper function for writing JSON to file
function writejson(filename, jsonData)
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not create file for writing.');
    end
    fwrite(fid, jsonData, 'char');
    fclose(fid);
end