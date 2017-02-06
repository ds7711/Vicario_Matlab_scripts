% PostProcess of sorted data
% input: directory where the sorted data is stored
% function: removed unwanted variables inside each file
% required function: 
%   1. File_Detection()

function [sss, File2Process] = post_process(Processing_Folder)
sorted_file_keyword = '_ass_nw*';
File2Process = File_Detection(sorted_file_keyword, Processing_Folder);
num_file = length(File2Process);
sss = 1; 
try
    for iii = 1 : num_file
        temp_filename = File2Process{iii, 1};
        
        % split the original file name
        wavname_split_keyword = '_ass_nw-'; 
        % split the original wav name into string and numeric part
        temp_filename_splited = strsplit(temp_filename, wavname_split_keyword); 
        nw_original_name = temp_filename_splited{1, 1};
        nw_numeric_suffix = temp_filename_splited{1, end};
        temp_wav_name = [nw_original_name, '_e', nw_numeric_suffix];
        temp_wav_name = temp_wav_name(1 : end -4);
        mmm = matfile([Processing_Folder, '\', temp_filename], 'Writable', true);
        eval(['mmm.', temp_wav_name, ' = 0']);
        clearvars mmm;
    end
catch
    sss = 0; % fail to update the .mat file
end
end