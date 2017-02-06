% autoss

function [cluster_class, spikes, par, inspk, ipermut] = autoss(data, FILENAME, SAMPLING_RATE)
%% Spike detection via "Get_Spikes"
if size(data, 1) >= 2 && size(data, 2) == 1
    data = data'; % transpose data into a 1 x N vector
end
data_withzero = data;

%% Gap detection & removal: if gap exists, remove gap, otherwise, go to next step
[gap_label, gap_logic_idx] = gap_detection(data); 
if gap_label
    data_without_gaps = data(~gap_logic_idx); % if gap exists, remove gap from data for later processing
else
    data_without_gaps = data; % data has to be represented by double
end


%% Use Get_Spikes to detect spikes 
data = double(data_without_gaps); % data has to be represented by double
[index, spikes] = get_spikes_ming(FILENAME, data);

%% Do_Clustering: spike_sorting 
[cluster_class, spikes, par, inspk, ipermut] = do_clustering_ming(data, spikes, index, FILENAME); 
% if sum(cluster_class) == 0
%     cluster_class = [0, 0]; % If fails to load paramter file, return 0 to skip this file
%     spikes = 0; 
%     par = 0;
%     inspk = 0; 
%     ipermut = 0;
%     return;
% end
cluster_class(:, 2) = cluster_class(:, 2) ./ 1000; % convert time from ms back to seconds

%% If gap_label == 1, transform the timing without gap into correct timing with gaps in-between
[gap_label, gap_logic_idx] = gap_detection(data_withzero); 
if gap_label
%     abs_cluster_class = add_gap_timing(gap_logic_idx, cluster_class, SAMPLING_RATE); % correct spike timing by adding gap duration back
%     cluster_class = abs_cluster_class; 
    cluster_class = add_gap_timing(gap_logic_idx, cluster_class, SAMPLING_RATE); % correct spike timing by adding gap duration back
end
end