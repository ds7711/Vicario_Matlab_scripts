% autoss_batch_main: automatic spikesorting in batch mode
%   input: raw continuous wavefroms exported from Spike2 channel by channel
%           in .mat format; put all the .mat files in a folder
%   output: spike waveforms and spiketiming separated from each channel,
%           which is stored in .mat format (follows the .mat format when 
%           a wavemark channel is exported from Spike2 to .mat)
% 
%   customized function required: 
%       1. File_Detection: detect data files inside a folder
%       2. new_wavemark (core function): detect and sort the raw data,
%           convert data into desired format, store them in the folder you
%           select; 
%       3. autoss
%       4. get_spikes_ming
%       5. do_clustering_ming
%       6. gap_detection
%       7. add_gap_timing

%% see the last part for merging parameters

%% Add the path of wave clus  % EDIT HERE %Where wave_clus.m exists
addpath(genpath('C:\Users\md\Dropbox\MD_scripts\Matlab_Lab_Script\Wave_clus_Ming_v1.0_organized'));
%addpath(genpath('C:\Users\md\Dropbox\MD_scripts\Matlab_Lab_Script\Wave_clus_Ming_v2.0'));
close all; clc;
clear; 
SAMPLING_RATE = 25000;
LEAST_NUM_SPIKE = 100; % the number of spikes in cluster is less than this number, it's not saved

%% Data file detection
wav_data_keyword = '_e\d*';  % '.' any character; '*' any number of character
starting_path = 'C:\Users\Mingwen\Desktop\Wave_Clus_ValidationProject'; 

Original_Data_Folder = uigetdir(starting_path, 'Select the Folder where the original data is stored');  
FileName = File_Detection(wav_data_keyword, Original_Data_Folder); 

Data_Store_Folder = uigetdir(starting_path, 'Select the Folder where you want to store the sorted data');  
cd(Data_Store_Folder); % change the working directory to where the data would be stored for convenience

%% Load each file and spike sorting all the waveform variables inside it 
num_file = length(FileName); 

for iii = 1 : num_file
    % load the waveform matlab files inside the matlab file one by one (one or more experiment)
    cd(Data_Store_Folder); % make sure matlab is working the right folder
    temp_filename = FileName{iii, 1};
    load([Original_Data_Folder, '\', temp_filename]); 
    
    % detect all the wav form variables (one or more electrodes)
    % wav_keyword = '_e\d*';  % keyword for variables that contain continous waveform
    wav_keyword = '_e[1234567890]';
    wav_name_list = who('-regexp', wav_keyword); 
    num_wav = length(wav_name_list); 
    
    for jjj = 1 : num_wav
        tic
        % load wavform variables inside the matlab file one by one (usually, it's wave data from different channels)
        temp_wav_name = wav_name_list{jjj, 1}; % get the 1st variable name in the list 
        raw_wav_data = eval(temp_wav_name); 
%         if ~strcmp(temp_wav_name, temp_filename) % to overcome the problem of filenaming inconsistency between .mat files and variabls it contained
%             temp_wav_name = temp_filename; 
%         end
        [num_classes] = new_wavemark(raw_wav_data, temp_wav_name, SAMPLING_RATE, Original_Data_Folder, LEAST_NUM_SPIKE); 
        pause(1.5); % pause seconds for figures to display
        
        % if num_classes ==0, there's a loading error in do_clustering_ming (line: [clu, tree] = run_cluster(handles);)
        % loading error at clu=load([fname '.dg_01.lab']);
        if num_classes == 0 
            % variables are cleared to free memory and prevent scripts
            % goint to infinite loop; 
            clearvars -except iii jjj SAMPLING_RATE LEAST_NUM_SPIKE Data_Store_Folder ...
                    FileName Original_Data_Folder sss num_classes;
            toc
            continue;
        end
        
        % split the original file name
        wavname_split_keyword = '_e'; 
        % split the original wav name into string and numeric part
        temp_wav_name_splited = strsplit(temp_wav_name, wavname_split_keyword); 
        nw_original_name = temp_wav_name_splited{1, 1};
        nw_numeric_suffix = temp_wav_name_splited{1, end};
        nw_suffix = '_ass_nw-';
        base_name = [nw_original_name, nw_suffix, nw_numeric_suffix];
        % move and rename the file
        [sss, mmessage] = movefile([Original_Data_Folder, '\', temp_wav_name, '.mat'], [Data_Store_Folder, '\', base_name, '.mat'], 'f');
        disp(sss);
        disp(mmessage);
        clearvars -except iii jjj SAMPLING_RATE LEAST_NUM_SPIKE Data_Store_Folder ...
                FileName Original_Data_Folder sss num_classes;
        toc
    end 
    
end


%% delete the raw waveforms and bad spikes to save space: to complete
cd(Data_Store_Folder); % marke sure it's in the right folder
[sss, File2Process] = post_process(Data_Store_Folder);
if ~sss
    warndlg('Fail to delete the raw waveform!')
end

%% resave the data so that windows knows files become smaller
clearvars -except File2Process Data_Store_Folder;
cd(Data_Store_Folder);
for iii = 1 : length(File2Process)
    load([Data_Store_Folder, '\', File2Process{iii, 1}]);
    save([Data_Store_Folder, '\', File2Process{iii, 1}], '-regexp', [File2Process{iii, 1}(1: end - 15), '+']);
    clearvars -except File2Process Data_Store_Folder iii;
end

%% Merge the sorted files together
cr_refractory_period = 0.002;
contamination_ub = 0.02;
mat_merge(Data_Store_Folder, cr_refractory_period, contamination_ub);

