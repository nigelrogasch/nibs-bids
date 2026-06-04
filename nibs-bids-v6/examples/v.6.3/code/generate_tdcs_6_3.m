clear; close all; clc;

% Settings
filePath = 'C:\Users\Nigel Rogasch\OneDrive - Adelaide University\Science\Projects\projects\2024_NIBS-BIDS\repository\nibs-bids-v6\examples\v.6.3\tdcs\';

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
data.Name = 'Example dataset: tDCS experiment';
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
    '# Example data set: transcranial direct current stimulation'
    ''
    ['This data set provides an example of formatting using a proposed ' ...
    'nibs-bidsv6.3 standard.']
    ''
    '## Experiment details'
    'The experiment involves a single tDCS.'
    ['tDCS is given over left primary motor cortex.']
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
fileNames = {'sub-001_task-rest_acq-tdcs_nibs.tsv'};

% List of acquisiton times
ac_times = {'1877-06-15T13:00:00'};

% Write table
T = table(fileNames, ac_times, 'VariableNames', {'filename', 'acq_time'});
outputName = [filePath,id,filesep,id,'_scans.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

%% S1mV files

% Task name
taskname = 'task-rest_acq-tdcs';

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
trial_type = {'tdcs'};

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
data.event_id.Levels.tdcs = 'Transcranial direct current stimulation';

% Convert the structure to JSON format
jsonData = jsonencode(data, 'PrettyPrint', true);

% Define the filename
filename = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_events.json'];

% Write the JSON data to a file
writejson(filename, jsonData);

% ### NIBS files ###
S = [];
S.event_id = {'tdcs'};
S.nibs_type = {'tES'};
S.stimulator_id = {'Soterix'};
S.element_id = {'elec1|elec2'};
S.stimulus_shape = {'Rectangle'};
S.stimulus_intensity = {'1|-1'};
S.stimulus_duration = {'10'};

% Write table
T = struct2table(S);
outputName = [filePath,id,filesep,'nibs',filesep,id,'_',taskname,'_nibs.tsv'];
writetable(T, outputName, 'Delimiter', 'tab', 'FileType', 'text');

% Write .json file
% Define the structure for the JSON data
data = struct();

% fields
data.NIBSDescription = 'Transcranial Direct Current Stimulation.';
data.ConcurrentModalities = {'none'};

device1.StimulatorID = 'Soterix';
device1.Manufacturer = 'Soterix';
device1.ManufacturerModelName = '1x1 tDCS';
device1.ManufacturerSerialNumber = '1300A';
data.StimulatorSet = [device1];

coil1.ElementID = 'elec_1';
coil1.ElementType = 'electrode';
coil1.ModelName = 'EASYpads';
coil1.SerialNumber = '123A';
coil1.Shape = 'rectangle';
coil1.Dimensions = {'50','70'};
coil1.Thickness = '20';
coil1.Material = 'sponge';
coil2.ElementID = 'elec_2';
coil2.ElementType = 'electrode';
coil2.ModelName = 'EASYpads';
coil2.SerialNumber = '123A';
coil2.Shape = 'rectangle';
coil2.Dimensions = {'50','70'};
coil2.Thickness = '20';
coil2.Material = 'sponge';
data.ElementSet = [coil1,coil2];

data.stimulus_shape.LongName = 'Shape of stimulus';
data.stimulus_shape.Description = 'Description of the stimulus shape';
data.stimulus_shape.Levels.Rectangle.RampUp = '30';
data.stimulus_shape.Levels.Rectangle.RampDown = '30';

data.stimulus_intensity.LongName = 'Stimulation intensity';
data.stimulus_intensity.Description = 'Stimulation current at each electrode separated by a delimiter. Total current MUST equal 0.';
data.stimulus_intensity.Units = 'mA';
data.stimulus_intensity.Delimeter = '|';

data.stimulus_duration.LongName = 'Stimulus duration';
data.stimulus_duration.Description = 'Time during which a contiguous non-zero current is applied through the element';
data.stimulus_duration.Units = 'mins';

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