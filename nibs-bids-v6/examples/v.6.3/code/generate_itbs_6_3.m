clear; close all; clc;

% Settings
filePath = 'C:\Users\Nigel Rogasch\OneDrive - Adelaide University\Science\Projects\projects\2024_NIBS-BIDS\repository\nibs-bids-v6\examples\v.6.3\itbs\';

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
% if ~isfolder([filePathID,'emg'])
%     mkdir([filePathID,'emg']);
% end
if ~isfolder([filePathID,'nibs'])
    mkdir([filePathID,'nibs']);
end

%% Generate dataset_description.json

% Write .json file
% Define the structure for the JSON data
data = struct();

% List of field
data.Name = 'Example dataset: intermittent theta burst stimulation';
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
    '# Example data set: intermittent theta burst stimulation'
    ''
    ['This data set provides an example of formatting using a proposed ' ...
    'nibs-bidsv6.3 standard.']
    ''
    '## Experiment details'
    'The experiment involves a single block of iTBS.'
    ['TMS is given over left primary motor cortex.']
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
fileNames = {'sub-001_task-rest_acq-itbs_nibs.tsv'};

% List of acquisiton times
ac_times = {'1877-06-15T13:00:00'};

% Write table
T = table(fileNames, ac_times, 'VariableNames', {'filename', 'acq_time'});
outputName = [filePath,id,filesep,id,'_scans.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

%% S1mV files

% Task name
taskname = 'task-rest_acq-itbs';

% ### Event file ####
% Parameters
n = 1;                % Number of values
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
S.duration = 'n/a';

% Original trial types
trial_type = {'itbs'};

% Number of repetitions per type
reps_per_type = 1;

% Expand to 40 elements (10 of each)
expanded_types = repmat(trial_type, reps_per_type, 1);

% Randomize the order
shuffled_types = expanded_types(randperm(numel(expanded_types)));
S.event_id = shuffled_types;

% Write table
T = struct2table(S);
outputName = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_events.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file for _events.tsv
% Define the structure for the JSON data
data = struct();

% fields
data.event_id.LongName = 'Stimulation type';
data.event_id.Description = 'NIBS stimulation event';
data.event_id.Levels.itbs = 'Intermittent theta burst stimulation';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_events.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### NIBS files ###
S = [];
S.event_id = {'itbs'};
S.nibs_type = {'TMS'};
S.stimulator_id = {'Magstim'};
S.element_id = {'Coil_1'};
S.stimulus_shape = {'Biphasic'};
S.stimulus_intensity = {'50'};
S.stimulus_duration = {'200'};
S.pattern1_frequency = {'50'};
S.pattern1_count = {'3'};
S.pattern2_frequency = {'5'};
S.pattern2_duration = {'2'};
S.pattern3_count = {'20'};
S.pattern3_duration = {'200'};

% Write table
T = struct2table(S);
outputName = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_nibs.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.NIBSDescription = 'Intermittent theta burst stimulation.';
data.ConcurrentModalities = {'none'};

device1.StimulatorID = 'Magstim';
device1.Manufacturer = 'Magstim';
device1.ManufacturerModelName = 'Rapid';
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
data.stimulus_shape.Levels.Biphasic = 'Biphasic pulse shape as per stimulator setting';

data.stimulus_intensity.LongName = 'Stimulation intensity';
data.stimulus_intensity.Description = 'TMS pulse intensity';
data.stimulus_intensity.Units = '% Maximum Stimulator Output';

data.stimulus_duration.LongName = 'Stimulus duration';
data.stimulus_duration.Description = 'Time during which a contiguous non-zero current is applied through the coil';
data.stimulus_duration.Units = 'Microseconds';

data.pattern1_frequency.LongName = 'Frequency of interval between stimuli in pattern1 (burst)';
data.pattern1_frequency.Description = 'Frequency of interval from the start of the first stimulus to the start of the proceeding stimulus in pattern1 (burst)';
data.pattern1_frequency.Units = 'Hz';

data.pattern1_count.LongName = 'Number of stimuli in repeating pattern (burst)';
data.pattern1_count.Description = 'Total number stimuli in repeating pattern (burst)';

data.pattern2_frequency.LongName = 'Frequency of interval between stimuli in pattern2 (train)';
data.pattern2_frequency.Description = 'Frequency of interval from the start of the first stimulus in pattern1 block to the start of the first stimulus in subsequent pattern1 block (train)';
data.pattern2_frequency.Units = 'Hz';

data.pattern2_duration.LongName = 'Duration of pattern1 repeats (train)';
data.pattern2_duration.Description = 'Duration of pattern1 repeats including stimulus duration and interval duration (train)';
data.pattern2_duration.Units = 's';

data.pattern3_count.LongName = 'Number of repeats of pattern2 (sequence)';
data.pattern3_count.Description = 'Total number of times pattern 2 repeats (sequence)';

data.pattern3_duration.LongName = 'Duration of pattern2 repeats (sequence)';
data.pattern3_duration.Description = 'Duration of pattern2 repeats including patten2 duration and interval duration (sequence)';
data.pattern3_duration.Units = 's';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_nibs.json'];

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