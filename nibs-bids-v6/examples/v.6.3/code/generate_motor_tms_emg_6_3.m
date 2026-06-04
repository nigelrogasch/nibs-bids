clear; close all; clc;

% Settings
filePath = 'C:\Users\Nigel Rogasch\OneDrive - Adelaide University\Science\Projects\projects\2024_NIBS-BIDS\repository\nibs-bids-v6\examples\v.6.3\motor-tms-emg\';

% Generate folder if it doesn't exist
if ~isfolder(filePath)
    mkdir(filePath);
end

% Participants
id = 'sub-001';
filePathID = [filePath,id,filesep];
if ~isfolder(filePathID)
    mkdir(filePathID);
end
if ~isfolder([filePathID,'emg'])
    mkdir([filePathID,'emg']);
end
if ~isfolder([filePathID,'nibs'])
    mkdir([filePathID,'nibs']);
end

%% Generate dataset_description.json

% Write .json file
% Define the structure for the JSON data
data = struct();

% List of field
data.Name = 'Example dataset: motor TMS-EMG experiment';
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
    '# Example data set: motor TMS-EMG'
    ''
    ['This data set provides an example of formatting using a proposed ' ...
    'nibs-bidsv6.3 standard.']
    ''
    '## Experiment details'
    'The experiment involves collecting TMS-EMG data from and individual.'
    '2 protocols are performed: S1mV, and SICI.'
    ['TMS is given over left primary motor cortex, and EMG is recorded from ' ...
    'right first dorsal interosseus muscle.']
    ''
    '## Notes'
    'The EMG data files are empty and do not correspond to BIDS data types.'
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

%% Generate scans.tsv and scans.json

% List of files
fileNames = {'sub-001_task-rest_acq-s1mV_emg.mat';...
    'sub-001_task-rest_acq-sici_emg.mat'};

% List of acquisiton times
ac_times = {'1877-06-15T13:00:00';...
    '1877-06-15T13:10:00'};

% Write table
T = table(fileNames, ac_times, 'VariableNames', {'filename', 'acq_time'});
outputName = [filePath,id,filesep,id,'_scans.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

%% S1mV files

% Task name
taskname = 'task-rest_acq-s1mV';

% ### EMG file ###
outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_emg.mat'];
save(outputName);

% Data file .json
% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.TaskName = 'EMG during TMS.';
data.TaskDescription = 'EMG recorded from right first dorsal interosseus muscle while participants hand was at rest during TMS.';
data.Manufacturer = 'SickEMG products';
data.ManufacturerModelName = 'Cool^2';
data.ManufacturerSerialNumber = '3234-00';
data.EMGPlacementScheme = 'Other';
data.EMGPlacementSchemeDescription = 'Single electrode placed over the muscle belly of the right first dorsal interosseus muscle.';
data.EMGChannelCount = 1;
data.EMGReference = 'Single electrode placed on carpal joint';
data.EMGGround = 'Wrist strap';
data.SamplingFrequency = 2000;
data.PowerLineFrequency = 50;
data.SoftwareFilters = 'n/a';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_emg.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### Event file ####
% Parameters
n = 5;                % Number of values
mean_interval = 5;     % Mean interval between values
jitter_percent = 0.10; % 10% jitter

% Generate jittered intervals
min_interval = mean_interval * (1 - jitter_percent);
max_interval = mean_interval * (1 + jitter_percent);
intervals = min_interval + (max_interval - min_interval) * rand(1, n-1);

% Generate the vector from cumulative sum of intervals
vec = [0, cumsum(intervals)];

S= [];
S.onset = num2cell(vec');
S.duration = num2cell(zeros(n,1));

% Original trial types
trial_type = {'spTMS'};

% Number of repetitions per type
reps_per_type = 5;

% Expand to 40 elements (10 of each)
expanded_types = repmat(trial_type, reps_per_type, 1);

% Randomize the order
shuffled_types = expanded_types(randperm(numel(expanded_types)));
S.event_id = shuffled_types;

% Write table
T = struct2table(S);
outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_events.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file for _events.tsv
% Define the structure for the JSON data
data = struct();

% fields
data.event_id.LongName = 'Stimulation type';
data.event_id.Description = 'Single pulse TMS';
data.event_id.Levels.spTMS = 'Single pulse';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_events.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### NIBS files ###
S = [];
S.event_id = {'spTMS'};
S.nibs_type = {'TMS'};
S.stimulator_id = {'Magstim'};
S.element_id = {'Coil_1'};
S.stimulus_shape = {'Monophasic'};
S.stimulus_intensity = {'50'};
S.stimulus_duration = {'200'};

% Write table
T = struct2table(S);
outputName = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_nibs.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.NIBSDescription = 'Single pulse TMS to evoke MEP of 1 mV.';
data.ConcurrentModalities = {'emg'};
data.IntendedFor = 'bids::sub-001/emg/sub-001_task-rest_acq-s1mV_events.tsv';

device1.StimulatorID = 'Magstim';
device1.Manufacturer = 'Magstim';
device1.ManufacturerModelName = 'BiStim^2';
device1.ManufacturerSerialNumber = '3234-00';
data.StimulatorSet = [device1];

coil1.ElementID = 'Coil_1';
coil1.ElementType = 'coil';
coil1.ModelName = 'D70';
coil1.SerialNumber = '4150-00';
coil2.ElementID = 'Coil_2';
coil2.ElementType = 'coil';
coil2.ModelName = 'D70';
coil2.SerialNumber = '4150-00';
data.ElementSet = [coil1,coil2];

data.stimulus_shape.LongName = 'Shape of stimulus';
data.stimulus_shape.Description = 'Description of the stimulus shape';
data.stimulus_shape.Levels.Monophasic = 'Monophasic pulse shape as per stimulator setting';

data.stimulus_intensity.LongName = 'Stimulation intensity';
data.stimulus_intensity.Description = 'TMS pulse intensity';
data.stimulus_intensity.Units = '% Maximum Stimulator Output';

data.stimulus_duration.LongName = 'Stimulus duration';
data.stimulus_duration.Description = 'Time during which a contiguous non-zero current is applied through the coil';
data.stimulus_duration.Units = 'Microseconds';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_nibs.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

%% SICI files

% Task name
taskname = 'task-rest_acq-SICI';

% ### EMG file ###
outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_emg.mat'];
save(outputName);

% Data file .json
% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.TaskName = 'EMG during TMS.';
data.TaskDescription = 'EMG recorded from right first dorsal interosseus muscle while participants hand was at rest during TMS.';
data.Manufacturer = 'SickEMG products';
data.ManufacturerModelName = 'Cool^2';
data.ManufacturerSerialNumber = '3234-00';
data.EMGPlacementScheme = 'Other';
data.EMGPlacementSchemeDescription = 'Single electrode placed over the muscle belly of the right first dorsal interosseus muscle.';
data.EMGChannelCount = 1;
data.EMGReference = 'Single electrode placed on carpal joint';
data.EMGGround = 'Wrist strap';
data.SamplingFrequency = 2000;
data.PowerLineFrequency = 50;
data.SoftwareFilters = 'n/a';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_emg.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### Event file ####
% Parameters
n = 10;                % Number of values
mean_interval = 5;     % Mean interval between values
jitter_percent = 0.10; % 10% jitter

% Generate jittered intervals
min_interval = mean_interval * (1 - jitter_percent);
max_interval = mean_interval * (1 + jitter_percent);
intervals = min_interval + (max_interval - min_interval) * rand(1, n-1);

% Generate the vector from cumulative sum of intervals
vec = [0, cumsum(intervals)];

S= [];
S.onset = num2cell(vec');
S.duration = num2cell(zeros(n,1));

% Original trial types
trial_type = {'spTMS','SICI'};

% Number of repetitions per type
reps_per_type = 5;

% Expand to 40 elements (10 of each)
expanded_types = repmat(trial_type, reps_per_type, 1);

% Randomize the order
shuffled_types = expanded_types(randperm(numel(expanded_types)));
S.event_id = shuffled_types';

% Write table
T = struct2table(S);
outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_events.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file for _events.tsv
% Define the structure for the JSON data
data = struct();

% fields
data.event_id.LongName = 'Stimulation type';
data.event_id.Description = 'Single pulse TMS';
data.event_id.Levels.spTMS = 'Single pulse';
data.event_id.Levels.SICI = 'SICI with 2 ms ISI';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_events.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### NIBS files ###
S = [];
S.event_id = {'spTMS';'SICI'};
S.nibs_type = {'TMS';'TMS'};
S.stimulator_id = {'Magstim';'Magstim'};
S.element_id = {'Coil_1';'Coil_1'};
S.stimulus_shape = {'Monophasic';'Monophasic'};
S.stimulus_intensity = {'50';'n/a'};
S.stimulus_duration = {'200';'200'};
S.pattern1_count = {'n/a';'2'};
S.pattern1_interval = {'n/a';'2'};
S.pattern1_intensity = {'n/a';'35|50'};

% Write table
T = struct2table(S);
outputName = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_nibs.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.NIBSDescription = 'Single and paired pulse (SICI) protocol.';
data.ConcurrentModalities = {'emg'};
data.IntendedFor = 'bids::sub-001/emg/sub-001_task-rest_acq-SICI_events.tsv';

device1.StimulatorID = 'Magstim';
device1.Manufacturer = 'Magstim';
device1.ManufacturerModelName = 'BiStim^2';
device1.ManufacturerSerialNumber = '3234-00';
data.StimulatorSet = [device1];

coil1.ElementID = 'Coil_1';
coil1.ElementType = 'coil';
coil1.ModelName = 'D70';
coil1.SerialNumber = '4150-00';

coil2.ElementID = 'Coil_2';
coil2.ElementType = 'coil';
coil2.ModelName = 'D70';
coil2.SerialNumber = '4150-00';
data.ElementSet = [coil1,coil2];

data.stimulus_shape.LongName = 'Shape of stimulus';
data.stimulus_shape.Description = 'Description of the stimulus shape';
data.stimulus_shape.Levels.Monophasic = 'Monophasic pulse shape as per stimulator setting';

data.stimulus_intensity.LongName = 'Stimulation intensity';
data.stimulus_intensity.Description = 'Stimulator intensity for single or multiple pulses (if separated by a delimiter). Note that if seperated, number of values MUST equal patter1_count.';
data.stimulus_intensity.Units = '% Maximum Stimulator Output';

data.stimulus_duration.LongName = 'Stimulus duration';
data.stimulus_duration.Description = 'Time during which a contiguous non-zero current is applied through the coil';
data.stimulus_duration.Units = 'Microseconds';

data.pattern1_count.LongName = 'Number of stimuli in repeating pattern';
data.pattern1_count.Description = 'Total number stimuli in repeating pattern';

data.pattern1_interval.LongName = 'Interval between stimuli in pattern1';
data.pattern1_interval.Description = 'Interval from the start of the first stimulus to the start of the proceeding stimulus';
data.pattern1_interval.Units = 'Milliseconds';

data.pattern1_intensity.LongName = 'Changing stimulation intensity for multiple pulses';
data.pattern1_intensity.Description = 'Stimulator intensity for multiple pulses with changing intensity  (separated by a delimiter). Note that if seperated, number of values MUST equal patter1_count.';
data.pattern1_intensity.Units = '% Maximum Stimulator Output';
data.pattern1_intensity.Delimiter = '|';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_nibs.json'];

% Write the JSON data to a file
writejson(filename, jsonData);


% %% Input output curve files
% 
% % Task name
% taskname = 'task-inputoutputcurve';
% 
% % Empty data file
% outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_emg.mat'];
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
% 
% %% SICI
% 
% % Task name
% taskname = 'task-sici';
% 
% % Empty data file
% outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_emg.mat'];
% save(outputName);
% 
% % Data file .json
% % Write .json file
% % Define the structure for the JSON data
% data = struct();
% 
% % fields
% data.TaskName = 'EMG during SICI.';
% data.TaskDescription = 'EMG recorded from right first dorsal interosseus muscle while participants hand was at rest during TMS SICI.';
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
% trial_type = {'single';'paired'};
% tms_intensity_mso = {72;72};
% tms_intensity_mso_con = {'n/a';42};
% tms_pos_centre = {'LeftM1';'LeftM1'};
% tms_pos_ydir = {'45';'45'};
% tms_pulse_shape = {'Monophasic';'Monophasic'};
% tms_pulse_direction = {'PA';'PA'};
% 
% % Write table
% T = table(trial_type,tms_intensity_mso,tms_intensity_mso_con, tms_pos_centre,tms_pos_ydir,tms_pulse_shape, tms_pulse_direction, 'VariableNames', {'trial_type','tms_intensity_mso','tms_intensity_mso_con', 'tms_pos_centre','tms_pos_ydir','tms_pulse_shape','tms_pulse_direction'});
% outputName = [filePath,id,filesep,'emg',filesep,id,'_',taskname,'_nibs.tsv'];
% writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');
% 
% % Write .json file
% % Define the structure for the JSON data
% data = struct();
% 
% % fields
% data.NIBSType = 'TMS';
% data.NIBSDescription = 'SICI';
% data.Manufacturer = 'Magstim';
% data.ManufacturerModelName = 'BiStim^2';
% data.ManufacturerSerialNumber = '3234-00';
% data.CoilDetails.ModelName = 'D70';
% data.CoilDetails.SerialNumber = '4150-00';
% 
% data.trial_type.LongName = 'Stimulation type';
% data.trial_type.Description = 'Single and paired pulses for SICI protocol.';
% data.trial_type.Levels.single = 'Single pulse test stimulus';
% data.trial_type.Levels.paired = 'Paired pulse test stimulus; ISI = 2ms, conditioning pulse intensity = 80% AMT';
% 
% data.tms_intensity_mso.LongName = 'TMS intensity of test stimulus';
% data.tms_intensity_mso.Description = 'TMS intensity, described as a percentage of maximum stimulator output (MSO).';
% data.tms_intensity_mso.Units = 'percent';
% 
% data.tms_intensity_mso_con.LongName = 'TMS intensity of conditioning stimulus';
% data.tms_intensity_mso_con.Description = 'TMS intensity, described as a percentage of maximum stimulator output (MSO).';
% data.tms_intensity_mso_con.Units = 'percent';
% 
% data.tms_pos_centre.LongName = 'Position of the centre of the TMS coil.';
% data.tms_pos_centre.Description = 'TMS Coil Position Relative to underlying anatomy.';
% data.tms_pos_centre.Levels.LeftM1 = 'Coil center positioned over Left M1 (primary motor cortex).';
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
% n = 20;                % Number of values
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
% trial_type = {'single'; 'paired'};
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
% data.trial_type.Description = 'Single and paired pulses for SICI protocol.';
% data.trial_type.Levels.single = 'Single pulse test stimulus';
% data.trial_type.Levels.paired = 'Paired pulse test stimulus; ISI = 2ms, conditioning pulse intensity = 80% AMT';
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