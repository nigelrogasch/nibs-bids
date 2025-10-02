clear; close all; clc;

%%

% Provide the TMS protocol to build
tms_protocol = 'iTMS'; % 'iTBS'|'cTBS'|'10Hz'|'1Hz'|'QPS'|'iTMS'

%% TMS intervention builder

switch tms_protocol
    case 'iTBS'
        pulses_in_burst = 3;
        inter_pulse_interval = 0.02;
        bursts_in_train = 10;
        inter_burst_interval = 0.2;
        trains_in_protocol = 20;
        inter_train_interval = 10;
    case 'cTBS'
        pulses_in_burst = 3;
        inter_pulse_interval = 0.02;
        bursts_in_train = 200;
        inter_burst_interval = 0.2;
        trains_in_protocol = 1;
        inter_train_interval = 0;
    case '10Hz'
        pulses_in_burst = 40;
        inter_pulse_interval = 0.1;
        bursts_in_train = 75;
        inter_burst_interval = 30;
        trains_in_protocol = 1;
        inter_train_interval = 0;
    case '1Hz'
        pulses_in_burst = 600;
        inter_pulse_interval = 1;
        bursts_in_train = 1;
        inter_burst_interval = 0;
        trains_in_protocol = 1;
        inter_train_interval = 0;
    case 'QPS'
        pulses_in_burst = 4;
        inter_pulse_interval = 0.005;
        bursts_in_train = 360;
        inter_burst_interval = 5;
        trains_in_protocol = 1;
        inter_train_interval = 0;
    case 'iTMS'
        pulses_in_burst = 2;
        inter_pulse_interval = 0.0015;
        bursts_in_train = 180;
        inter_burst_interval = 5;
        trains_in_protocol = 1;
        inter_train_interval = 0;
    otherwise
        fprintf('Invalid TMS protocol name.\n');
end

% Build the protocol
protcol_mat = zeros(trains_in_protocol,bursts_in_train,pulses_in_burst);
protocol_mat(1,1,1) = 0;
for i = 2:trains_in_protocol
        protocol_mat(i,:) = protocol_mat(i-1) + inter_train_interval;
end
for i = 1:trains_in_protocol
    for j = 2:bursts_in_train
        protocol_mat(i,j) = protocol_mat(i,j-1) + inter_burst_interval;
    end
end
for i = 1:trains_in_protocol
    for j = 1:bursts_in_train
        for k = 2:pulses_in_burst
            protocol_mat(i,j,k) = protocol_mat(i,j,k-1) + inter_pulse_interval;
        end
    end
end

% Reverse so matrix is pulse x burst x train
Ap = permute(protocol_mat, [3 2 1]);
protocol_vec = Ap(:);

% Calculate time vector and final protocol
ipis = [inter_pulse_interval,inter_burst_interval,inter_train_interval];
minipi = min(ipis(ipis>0));
time = protocol_vec(1):0.001:protocol_vec(end);

protocol_final = zeros(1,length(time));
for i = 1:length(protocol_vec)
    [~,ti] = min(abs(protocol_vec(i)-time));
    protocol_final(ti) = 1;
end

% Total pulses
total_pulses = pulses_in_burst*bursts_in_train*trains_in_protocol;
fprintf('Total pulses = %d\n',total_pulses);

% Total duration (first pulse to last pulse)
total_duration = time(end);
fprintf('Total duration = %.2f s\n',total_duration);

% Figure of the protocol
figure('color','w');
plot(time,protocol_final);
xlabel('Time (s)');
title(tms_protocol);
