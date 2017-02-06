% var2struct
function temp_nw = var2sruct(spikes, cluster_class, raw_wav_struct)
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

end