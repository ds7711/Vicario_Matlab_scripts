% Function required: 
%   File_Detection
% input: 
%       data_path: where your sorted units are stored
%       cr_refractory: refractory period used to calculate contamination
%           rate in seconds (our default is 0.002sec)
%       contamination_ub: upper band for including units (default is 0.02)
% output: 
%       matlab files that correspond to the original recording file, which
%       contains all units from the same recording session. 

%% Merge neurons from the same recording into the same matlab file
function mat_merge(data_path, cr_refractory, contamination_ub)

%% Find all the output matlab files 
% keyword of unsurpervised sorting results: "_ass_nw-"
% data_path = 'C:\Users\md\Desktop\SS_Output';
units_file_keyword = '_ass_nw-';
FileName = File_Detection(units_file_keyword, data_path); 
% cr_refractory = 0.002; % refractory period used to calculate contamination rate
% contamination_ub = 0.02; % upper band for including units

%% Extract the recording-specific part of the matlab files
num_channels = size(FileName, 1); % number of channels to merge
str_idx = cell(num_channels, 1); % define a cell array to store the substring associated with the original recording
for iii = 1 : num_channels
    tmp = FileName{iii, 1};
    tmp_idx = regexpi(tmp, units_file_keyword); % get the starting index of the keyword
    str_idx{iii, 1} = tmp(1 : tmp_idx);
end
recording_files = unique(str_idx);
num_recordings = size(recording_files, 1);
trg_keyword = '.*trig';
IDstm_keyword = '.*IDstim';
units_keyword = '.*_ass_nw'; % slightly different from units_file_keyword

%% load channels from the same recording (.smr) file into the workspace and save
new_folder = '\merged\';
mkdir([data_path, new_folder]);
for iii = 1 : num_recordings
    tmp_recording = recording_files{iii, 1};
    tmp_logidx = strcmp(tmp_recording, str_idx);
    % load files only when the temp_logidx is true
    for jjj = 1 : num_channels
        if tmp_logidx(jjj, 1)
            load([data_path, '\', FileName{jjj, 1}]);
        end
    end
    %% save the name of the units that meet the criterion
    tmp_unit_list = who('-regexp', units_keyword);
    tmp_good_unit = cell(2, 1);
    tmp = who('-regexp', IDstm_keyword); % get the ID_stim name
    tmp_good_unit{1, 1} = tmp{1, 1};
    tmp = who('-regexp', trg_keyword); % get the trig_name
    tmp_good_unit{2, 1} = tmp{1, 1};
    for kkk = 1 : size(tmp_unit_list)
        tmp_unit = eval(tmp_unit_list{kkk, 1});
        spiketiming = tmp_unit.times;
        [contamination_rate, tot_spikes, firing_rate] = unit_stats(spiketiming, cr_refractory);
        if contamination_rate < contamination_ub % add more filter here if you want
            tmp_good_unit{end + 1, 1} = tmp_unit_list{kkk, 1};
        end
    end
    %% save the remaining variables
    if size(tmp_good_unit, 1) > 2
        save([data_path, new_folder, tmp_recording], tmp_good_unit{:});
        % save([data_path, new_folder, tmp_recording], '-regexp', units_keyword, trg_keyword, IDstm_keyword);
    end
    % clearvars('-regexp', units_keyword, trg_keyword, IDstm_keyword)
    % clearvars('-except', iii, jjj, data_path, trg_keyword, IDstm_keyword, units_keyword, num_recordings, FileName, str_idx, recording_files);
    clearvars('-regexp', ['.*', tmp_recording]);
end