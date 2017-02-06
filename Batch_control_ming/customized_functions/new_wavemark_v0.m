% create new wavemark output variables 
function [num_classes, varargout] = new_wavemark(raw_wav_data, wav_name, SAMPLING_RATE, Data_Path, LEAST_NUM_SPIKE)

data = raw_wav_data.values;

try
    % [cluster_class, spikes, par, inspk, ipermut] = autoss(data, wav_name, SAMPLING_RATE);
    [cluster_class, spikes] = autoss(data, wav_name, SAMPLING_RATE);
    % if sum(cluster_class) == 0
    %     num_classes = 0;
    %     return;
    % end

    wavname_split_keyword = '_e'; 
    % split the original wav name into string and numeric part
    temp_wav_name_splited = strsplit(wav_name, wavname_split_keyword); 
    nw_original_name = temp_wav_name_splited{1, 1};
    nw_numeric_suffix = temp_wav_name_splited{1, end};
    nw_suffix = '_ass_nw_';
    base_name = [nw_original_name, nw_suffix, nw_numeric_suffix];

    num_classes = length(unique(cluster_class(:, 1)));
    if num_classes
        % create a wavemark that stores all the spikes: like multiunit exported
        % from spike2
        temp_nw = raw_wav_data;  % xxx: a copy of raw wav data to store new wavmark data
        % remove useless field
        fields_to_rm = {'scale', 'offset', 'units', 'start', 'interval'};
        temp_nw = rmfield(temp_nw, fields_to_rm);
        % get the logic index of one class of spikes
        temp_all_spiketiming = cluster_class(:, 1);
        temp_nw.title = base_name;
        temp_nw.times = temp_all_spiketiming;
        temp_nw.length = length(temp_all_spiketiming);
        temp_nw.values = spikes;
        temp_nw.comment = 'spike waveform stored in values';
        temp_nw.resolution = NaN;
        eval([base_name, ' = temp_nw']);  % copy a struct to store the the spike timing and wavform
        varargout{1, 1} = eval(base_name);
        save([Data_Path, '\', wav_name], base_name, '-append');

        clearvars temp_nw; 
        for kkk = 1 : num_classes
            temp_nameofnv = [base_name, '_0', num2str(kkk)]; % name of new variable
            temp_nw = raw_wav_data;  % xxx: a copy of raw wav data to store new wavmark data
            % remove useless field
            fields_to_rm = {'scale', 'offset', 'units', 'start', 'interval'};
            temp_nw = rmfield(temp_nw, fields_to_rm);
            % get the logic index of one class of spikes
            temp_logic_idx_class = cluster_class(:, 1) == kkk;
            temp_spiketiming = cluster_class(temp_logic_idx_class, 2);
            if length(temp_spiketiming) > LEAST_NUM_SPIKE % proceed only if there's at least certain number of spikes in this class
                temp_nw.title = temp_nameofnv;
                temp_nw.times = temp_spiketiming;
                temp_nw.length = length(temp_spiketiming);
                temp_nw.values = spikes(temp_logic_idx_class, :);
                temp_nw.comment = 'spike waveform stored in values';
                temp_nw.resolution = NaN;
                eval([temp_nameofnv, ' = temp_nw']);  % copy a struct to store the the spike timing and wavform
                varargout{kkk + 1, 1} = eval(temp_nameofnv);
                save([Data_Path, '\', wav_name], temp_nameofnv, '-append');
            end
        end
        % overwrite the original wavform data to save space: to finish
    end

catch
    num_classes = 0;  % if there's an error, go to next file
end

end