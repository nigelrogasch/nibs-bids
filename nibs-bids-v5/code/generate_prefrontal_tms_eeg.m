clear; close all; clc;

% Settings
filePath = 'G:\My Drive\Science\Projects\projects\2024_NIBS-BIDS\repository\nibs-bids-v5\prefrontal-tms-eeg\';

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

% %% Input output curve files
% 
% % Task name
% taskname = 'task-prefrontaltms';
% 
% % Empty data file
% outputName = [filePath,id,filesep,'eeg',filesep,id,'_',taskname,'_emg.mat'];
% save(outputName);
% 
% % Data file .json
% % Write .json file
% % Define the structure for the JSON data
% data = struct();
% 
% % fields
% data.TaskName = 'EMG during TMS input-output curve.';
% data.TaskDescription = 'EMG recorded from right first dorsal interosseus muscle while participants hand was at rest during TMS input-output curve.';
% data.Manufacturer = 'SickEMG products';
% data.ManufacturerModelName = 'Cool^2';
% data.ManufacturerSerialNumber = '3234-00';
% data.EMGChannelCount = 1;
% data.EMGreference = 'single electrode placed on carpal joint';
% data.EMGground = 'wrist strap';
% data.SamplingFrequency = 2000;
% data.PowerLineFrequency = 50;
% dataSoftwareFilters = 'n/a';
% 
% % Convert the structure to JSON format
% jsonData = jsonencode(data, 'PrettyPrint', true);
% 
% % Define the filename
% filename = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_emg.json'];
% 
% % Write the JSON data to a file
% writejson(filename, jsonData);
% 
% % _nibs.tsv
% trial_type = {'TMS90';'TMS100';'TMS110';'TMS120'};
% tms_intensity_mso = {'54';'60';'66';'72'};
% tms_pos_centre = {'LeftM1';'LeftM1';'LeftM1';'LeftM1'};
% tms_pos_ydir = {'45';'45';'45';'45'};
% tms_pulse_shape = {'Monophasic';'Monophasic';'Monophasic';'Monophasic';};
% tms_pulse_direction = {'PA';'PA';'PA';'PA'};
% 
% % Write table
% T = table(trial_type,tms_intensity_mso, tms_pos_centre,tms_pos_ydir,tms_pulse_shape, tms_pulse_direction, 'VariableNames', {'trial_type','tms_intensity_mso', 'tms_pos_centre','tms_pos_ydir','tms_pulse_shape','tms_pulse_direction'});
% outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_nibs.tsv'];
% writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');
% 
% % Write .json file
% % Define the structure for the JSON data
% data = struct();
% 
% % fields
% data.NIBSType = 'TMS';
% data.NIBSDescription = 'Input-output curve.';
% data.Manufacturer = 'Magstim';
% data.ManufacturerModelName = 'BiStim^2';
% data.ManufacturerSerialNumber = '3234-00';
% data.CoilDetails.ModelName = 'D70';
% data.CoilDetails.SerialNumber = '4150-00';
% 
% data.trial_type.LongName = 'Stimulation type';
% data.trial_type.Description = 'Different stimulation intensity conditions provided for input-output curve.';
% data.trial_type.Levels.TMS90 = 'TMS at 90% RMT';
% data.trial_type.Levels.TMS100 = 'TMS at 100% RMT';
% data.trial_type.Levels.TMS110 = 'TMS at 110% RMT';
% data.trial_type.Levels.TMS120 = 'TMS at 120% RMT';
% 
% data.tms_intensity_mso.LongName = 'TMS intensity';
% data.tms_intensity_mso.Description = 'TMS intensity, described as a percentage of maximum stimulator output (MSO).';
% data.tms_intensity_mso.Units = 'percent';
% 
% data.tms_pos_centre.LongName = 'Position of the centre of the TMS coil.';
% data.tms_pos_centre.Description = 'TMS Coil Position Relative to underlying anatomy.';
% data.tms_pos_centre.Levels.LeftM1 = "Coil center positioned over Left M1 (primary motor cortex).";
% 
% data.tms_pos_ydir.LongName = 'TMS Coil Handle Direction';
% data.tms_pos_ydir.Description = 'The angular direction of the TMS coil handle relative to the midline with handle pointing to posterior.';
% data.tms_pos_ydir.Units = 'degrees';
% 
% data.tms_pulse_shape.LongName = 'Shape of the TMS pulse';
% data.tms_pulse_shape.Description = 'Shape of the TMS pulse.';
% data.tms_pulse_shape.Levels.Monophasic = 'Monophasic pulse shape';
% data.tms_pulse_shape.Levels.Biphasic = 'Biphasic pulse shape';
% 
% data.tms_pulse_direction.LongName = 'Direction of the TMS pulse';
% data.tms_pulse_direction.Description = 'Direction of the TMS pulse in the underlying cortex.';
% data.tms_pulse_direction.Levels.PA = 'Posterior to anterior';
% data.tms_pulse_direction.Levels.AP = 'Anterior to posterior';
% data.tms_pulse_direction.Levels.PAAP = 'Posterior to anterior then anterior to posterior';
% data.tms_pulse_direction.Levels.APPA = 'Anterior to posterior then posterior to anterior';
% 
% % Convert the structure to JSON format
% jsonData = jsonencode(data, 'PrettyPrint', true);
% 
% % Define the filename
% filename = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_nibs.json'];
% 
% % Write the JSON data to a file
% writejson(filename, jsonData);
% 
% % Generate _events.tsv
% 
% % Parameters
% n = 40;                % Number of values
% mean_interval = 5;     % Mean interval between values
% jitter_percent = 0.10; % 10% jitter
% 
% % Generate jittered intervals
% min_interval = mean_interval * (1 - jitter_percent);
% max_interval = mean_interval * (1 + jitter_percent);
% intervals = min_interval + (max_interval - min_interval) * rand(1, n-1);
% 
% % Generate the vector from cumulative sum of intervals
% vec = [0, cumsum(intervals)];
% 
% onset = num2cell(vec');
% duration = num2cell(zeros(n,1));
% 
% % Original trial types
% trial_type = {'TMS90'; 'TMS100'; 'TMS110'; 'TMS120'};
% 
% % Number of repetitions per type
% reps_per_type = 10;
% 
% % Expand to 40 elements (10 of each)
% expanded_types = repmat(trial_type, reps_per_type, 1);
% 
% % Randomize the order
% shuffled_types = expanded_types(randperm(numel(expanded_types)));
% trial_type = shuffled_types;
% 
% % Write table
% T = table(onset,duration,trial_type, 'VariableNames', {'onset','duration','trial_type'});
% outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_events.tsv'];
% writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');
% 
% % Write .json file for _events.tsv
% % Define the structure for the JSON data
% data = struct();
% 
% % fields
% data.trial_type.LongName = 'Stimulation type';
% data.trial_type.Description = 'Different stimulation intensity conditions provided for input-output curve.';
% data.trial_type.Levels.TMS90 = 'TMS at 90% RMT';
% data.trial_type.Levels.TMS100 = 'TMS at 100% RMT';
% data.trial_type.Levels.TMS110 = 'TMS at 110% RMT';
% data.trial_type.Levels.TMS120 = 'TMS at 120% RMT';
% 
% % Convert the structure to JSON format
% jsonData = jsonencode(data, 'PrettyPrint', true);
% 
% % Define the filename
% filename = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_events.json'];
% 
% % Write the JSON data to a file
% writejson(filename, jsonData);

%% Helper function for writing JSON to file
function writejson(filename, jsonData)
    fid = fopen(filename, 'w');
    if fid == -1
        error('Could not create file for writing.');
    end
    fwrite(fid, jsonData, 'char');
    fclose(fid);
end