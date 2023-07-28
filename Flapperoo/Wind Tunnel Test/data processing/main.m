% Ronan Gissler June 2023
clear
close all
addpath 'process trial'
addpath 'process trial/functions'
addpath 'plotting'

% path to folder where all processed data (.mat files) are stored
data_path = "../processed data/";

[file,path] = uigetfile(data_path + '*.mat');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end

file = convertCharsToStrings(file);

plot_trial(file, data_path, false)