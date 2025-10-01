clear; close all; clc;

% Settings
filePath = 'G:\My Drive\Science\Projects\projects\2024_NIBS-BIDS\repository\nibs-bids-v5\prefrontal-tms-eeg-hybrid\';

% Participants
id = 'sub-001';

%% Generate dataset_description.json

% Write .json file
% Define the structure for the JSON data
data = struct();

% List of field
data.Name = 'Example dataset: prefrontal TMS-EEG experiment';
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
    '# Example data set: prefrontal TMS-EEG'
    ''
    ['This data set provides an example of formatting using a proposed ' ...
    'nibs-bidsv5 standard.']
    ''
    '## Experiment details'
    'The experiment involves collecting TMS-EEG data from an individual.'
    '2 protocols are performed:' 
    '* RMT'
    '* TMS-EEG over left prefrontal cortex (100 trials).'
    ['TMS is given over left prefrontal cortex, and EEG is recorded from ' ...
    '64 channels. Neuronavigation is used to record TMS coil position for each trial.']
    ''
    '## Notes'
    'The EEG data files are empty and do not correspond to BIDS data types.'
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
    'ses-tmseeg'};

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
    'sub-001_task-prefrontaltms_eeg.tsv'};

% List of acquisiton times
acq_times = {'1877-06-15T13:00:00';...
    '1877-06-15T13:10:00'};

% Write table
T = table(fileNames, acq_times, 'VariableNames', {'filename', 'acq_time'});
outputName = [filePath,id,filesep,'ses-tmseeg',filesep,id,'_scans.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

%% RMT files

% Task name
taskname = 'task-rmt';
sesname = 'ses-tmseeg';

% _nibs.tsv
tms_rmt = {60};
tms_pos_centre = {'LeftM1'};
tms_pos_ydir = {'45'};
tms_pulse_shape = {'Monophasic'};
tms_pulse_direction = {'PA'};

% Write table
T = table(tms_rmt, tms_pos_centre,tms_pos_ydir,tms_pulse_shape, tms_pulse_direction, 'VariableNames', {'tms_rmt', 'tms_pos_centre','tms_pos_ydir','tms_pulse_shape','tms_pulse_direction'});
outputName = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_stimsys-tms_nibs.tsv'];
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
filename = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_stimsys-tms_nibs.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

%% TMS-EEG files

% Task name
taskname = 'task-prefrontaltms';
sesname = 'ses-tmseeg';

% ### Empty data file ###
outputName = [filePath,id,filesep,sesname,filesep,'eeg',filesep,id,'_',sesname,'_',taskname,'_eeg.mat'];
save(outputName);

% Data file .json
% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.TaskName = 'EEG during TMS to left DLPFC.';
data.TaskDescription = 'EEG recorded while participant was at rest with eyes open during TMS to left DLPFC.';
data.Manufacturer = 'SickEEG products';
data.ManufacturerModelName = 'Cool^2';
data.ManufacturerSerialNumber = '3234-00';
data.EEGChannelCount = 64;
data.EEGreference = 'single electrode placed on forehead';
data.EEGground = 'single electrode placed on forehead';
data.SamplingFrequency = 10000;
data.PowerLineFrequency = 50;
dataSoftwareFilters = 'n/a';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'eeg',filesep,id,'_',sesname,'_',taskname,'_eeg.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### _events.tsv ###

% Parameters
n = 100;                % Number of values
mean_interval = 5;     % Mean interval between values
jitter_percent = 0.10; % 10% jitter

% Generate jittered intervals
min_interval = mean_interval * (1 - jitter_percent);
max_interval = mean_interval * (1 + jitter_percent);
intervals = min_interval + (max_interval - min_interval) * rand(1, n-1);

% Generate the vector from cumulative sum of intervals
vec = [0, cumsum(intervals)];

onset = num2cell(vec');
duration = num2cell(zeros(n,1));

% Original trial types
trial_type_name = {'TMSDLPFC'};
trial_type = cell(100,1);
for i=1:n
    trial_type{i} = trial_type_name;
end

% Trial number
trial_id = [1:100]';

% Write table
T = table(onset,duration,trial_type,trial_id, 'VariableNames', {'onset','duration','trial_type','trial_no'});
outputName = [filePath,id,filesep,sesname,filesep,'eeg',filesep,id,'_',sesname,'_',taskname,'_events.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file for _events.tsv
% Define the structure for the JSON data
data = struct();

% fields
data.trial_type.LongName = 'Stimulation type';
data.trial_type.Description = 'TMS pulses.';
data.trial_type.Levels.TMSDLPFC = 'TMS to left DLPFC';

data.trial_id.LongName = 'Trial number';
data.trial_id.Description = 'Trial number of TMS pulses given.';
data.trial_id.Units = 'Integer';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'eeg',filesep,id,'_',sesname,'_',taskname,'_events.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

%% ### _nibs.tsv ###
target_id = cell(1,1);
for i = 1
    target_id{i} = 'DLPFC';
end

trial_type = cell(1,1);
for i = 1
    trial_type{i} = 'TMSDLPFC';
end
tms_intensity_mso = cell(1,1);
for i = 1
    tms_intensity_mso{i} = 72;
end
tms_pulse_shape = cell(1,1);
for i = 1
    tms_pulse_shape{i} = 'Monophasic';
end
tms_pulse_direction = cell(1,1);
for i = 1
    tms_pulse_direction{i} = 'PA';
end

% Write table
T = table(target_id,trial_type,tms_intensity_mso,tms_pulse_shape,tms_pulse_direction,...
    'VariableNames', {'target_id','trial_type','tms_intensity_mso','tms_pulse_shape','tms_pulse_direction',...
    });
outputName = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_stimsys-tms_nibs.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.NIBSType = 'TMS';
data.NIBSDescription = 'TMS-EEG over left DLPFC';
data.Manufacturer = 'Magstim';
data.ManufacturerModelName = 'BiStim^2';
data.ManufacturerSerialNumber = '3234-00';
data.CoilDetails.ModelName = 'D70';
data.CoilDetails.SerialNumber = '4150-00';

data.target_id.Description = "Unique identifier for each target. This column must appear first in the file.";

data.trial_type.LongName = 'Stimulation type';
data.trial_type.Description = 'TMS pulses.';
data.trial_type.Levels.TMSDLPFC = 'TMS to left DLPFC';
data.trial_type.IntendedFor = 'bids::sub-001/ses-tmseeg/eeg/sub-001_ses-tmseeg_task-prefrontaltms_eeg.mat';

data.tms_intensity_mso.LongName = 'TMS intensity';
data.tms_intensity_mso.Description = 'TMS intensity, described as a percentage of maximum stimulator output (MSO).';
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

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_stimsys-tms_nibs.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### Marker file ###
target_id = cell(100,1);
for i = 1:100
    target_id{i} = 'DLPFC';
end
trial_id = cell(100,1);
for i = 1:100
    trial_id{i} =i;
end
tms_pos_r1_c1 = cell(100,1);
for i = 1:100
    tms_pos_r1_c1{i} = 1;
end
tms_pos_r1_c2 = cell(100,1);
for i = 1:100
    tms_pos_r1_c2{i} = 0;
end
tms_pos_r1_c3 = cell(100,1);
for i = 1:100
    tms_pos_r1_c3{i} = 0;
end
tms_pos_r1_c4 = cell(100,1);
for i = 1:100
    tms_pos_r1_c4{i} = 20;
end
tms_pos_r2_c1 = cell(100,1);
for i = 1:100
    tms_pos_r2_c1{i} = 0;
end
tms_pos_r2_c2 = cell(100,1);
for i = 1:100
    tms_pos_r2_c2{i} = 1;
end
tms_pos_r2_c3 = cell(100,1);
for i = 1:100
    tms_pos_r2_c3{i} = 0;
end
tms_pos_r2_c4 = cell(100,1);
for i = 1:100
    tms_pos_r2_c4{i} = 20;
end
tms_pos_r3_c1 = cell(100,1);
for i = 1:100
    tms_pos_r3_c1{i} = 0;
end
tms_pos_r3_c2 = cell(100,1);
for i = 1:100
    tms_pos_r3_c2{i} = 0;
end
tms_pos_r3_c3 = cell(100,1);
for i = 1:100
    tms_pos_r3_c3{i} = 1;
end
tms_pos_r3_c4 = cell(100,1);
for i = 1:100
    tms_pos_r3_c4{i} = 20;
end
tms_pos_r4_c1 = cell(100,1);
for i = 1:100
    tms_pos_r4_c1{i} = 0;
end
tms_pos_r4_c2 = cell(100,1);
for i = 1:100
    tms_pos_r4_c2{i} = 0;
end
tms_pos_r4_c3 = cell(100,1);
for i = 1:100
    tms_pos_r4_c3{i} = 0;
end
tms_pos_r4_c4 = cell(100,1);
for i = 1:100
    tms_pos_r4_c4{i} = 1;
end

% Write table
T = table(target_id,trial_id,...
    tms_pos_r1_c1,tms_pos_r1_c2,tms_pos_r1_c3,tms_pos_r1_c4,...
    tms_pos_r2_c1,tms_pos_r2_c2,tms_pos_r2_c3,tms_pos_r2_c4,...
    tms_pos_r3_c1,tms_pos_r3_c2,tms_pos_r3_c3,tms_pos_r3_c4,...
    tms_pos_r4_c1,tms_pos_r4_c2,tms_pos_r4_c3,tms_pos_r4_c4,...
    'VariableNames', {'target_id','trial_id',...
    'tms_pos_r1_c1','tms_pos_r1_c2','tms_pos_r1_c3','tms_pos_r1_c4',...
    'tms_pos_r2_c1','tms_pos_r2_c2','tms_pos_r2_c3','tms_pos_r2_c4',...
    'tms_pos_r3_c1','tms_pos_r3_c2','tms_pos_r3_c3','tms_pos_r3_c4',...
    'tms_pos_r4_c1','tms_pos_r4_c2','tms_pos_r4_c3','tms_pos_r4_c4',...
    });
outputName = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_stimsys-tms_markers.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');


% ### Marker json ###
% Write .json file
% Define the structure for the JSON data
data = struct();

data.target_id.Description = "Unique identifier for each target. This column must appear first in the file."

data.trial_id.LongName = 'Trial number';
data.trial_id.Description = 'Trial number of TMS pulses given.';
data.trial_id.Units = 'Integer';
data.trial_id.IntendedFor = 'bids::sub-001/ses-tmseeg/eeg/sub-001_ses-tmseeg_task-prefrontaltms_eeg.mat';

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
filename = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_',taskname,'_stimsys-tms_markers.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### coordsystem file ###
% Write .json file
% Define the structure for the JSON data
data = struct();

data.NeuronavigationDetails.Manufacturer = 'BrainSight';
data.NeuronavigationDetails.ManufacturerModelName = 'BrainSight3';
data.NeuronavigationDetails.SoftwareVersions = '3.1';
data.otherfields = "As suggested to stay in line with EEG etc. Might need to add description of affine transformation matrix.";

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,sesname,filesep,'nibs',filesep,id,'_',sesname,'_stimsys-tms_coordsystem.json'];

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