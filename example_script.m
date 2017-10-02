%% Example script
% This function simulates the training of an unsupervised classifier on 
% visual ERP data
%
% To begin the example, load data from the Zenodo repository
%
% https://zenodo.org/record/192684
%
% and extract it to a local folder <your_data_path>;. Also, make sure that
% you cloned this whole GitHub repository. 
%
% https://github.com/DavidHuebner/Unsupervised-BCI-Matlab
%
% You can then run this example.
%
% Please report any problems to david.huebner@blbt.uni-freiburg.de
%
% @David Hübner, Jul, 2017

% !! Set your data path !!
your_data_path = '';

% Change to the current folder and add required paths to the Matlab repository
addpath('EM')
addpath('helpers')

% Load stimuli and epoch data for subject 1 (out of 13)
load(fullfile(your_data_path,'S1.mat'));

% Load the sequence data for LLP indicating whether epoch k was part of
% sequence 1 or sequence 2. It is the same for all subjects.
load(fullfile(your_data_path,'sequence.mat'));

% Extract a feature vector where the features are the mean amplitudes in
% the 6 given intervals
fv = proc_jumpingMeans(epo,[50 120; 121 200; 201 280;281 380;381 530; 531 700]);

% Bring feature matrix in the shape [N * feat_dim] 
% where feat_dim = n_channels * n_time_intervals
data = reshape(fv.x,31*6,12852)';

% Next, look at "stimuli" which encodes which symbols are highlighted for
% each visual highlighting event (stimulus)
% Shape: [feat_dim * N] with entry(i,j)=1 if symbol i was highlighted
% during epoch j and 0 else.
stimuli = epo.stimuli;

% Denote the number of epochs per trial, i.e. the number of highlighting
% events which occur when writing a single character
nr_ept = 68;

% Decide about the classifier:
% gamma = -1; MIX, gamma = 0; EM, gamma = +1; LLP
gamma = -1;

% Mixing matrix for the LLP method describing the target and non-target
% ratio for the different subgroups in the data.
% !! Note that only two subgroups are supported at the moment !!
A = [3/8 5/8; 2/18 16/18];

% [OPTIONAL] Matrix y contains the label information for performance assessment
% Shape: [N] where entry at position k is 1 if epoch k was a target and 0
% if it was a non-target
y = epo.y(1,:);

% [OPTIONAL]: Set seed. The classifier is randomly initialized and a
% fixed seed ensures reproducibility of the results
rng(1234);

% [OPTIONAL]: Which trials should be analyzed If no values "[]" are given,
% then the whole data set is analyzed. 
trials = 1:23;

%%%%%%%%%%%%%%%%%%%%%%%%%%% Run %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
C = simulate_MIX(data,stimuli,sequence,y,nr_ept,A,gamma,trials);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Obtain and display spelled symbols
[probs,select]=max(C.classifier.probs,[],2);
disp(['Final sentence: ' convert_position_to_letter(select)])
