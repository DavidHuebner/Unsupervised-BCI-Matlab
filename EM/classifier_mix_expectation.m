function [classifier] = classifier_mix_expectation(classifier)
%% Execute the expectation step for the EM algorithm
% During this step, we compute the probability for each option per symbol
% selection.% 
%
% parameters:
% classifier   -- the classifier struct should contain the data and the stimuli
%
% returns
% classifier   -- classifier.projection contains the projected EEG and is used in
%              the update for classifier.sigma_t during the M-step
%              classifier.probs, this is a (SxN) matrix, 
%              where S is the number of selections that have to
%              be made and N is the number of options to choose from.
%
% written by Pieter-Jan Kindermans
% 
% implemented semi-supervised algorithm in case the label information are
% avaialble
% david.huebner@blbt.uni-freiburg.de
    projection = classifier_compute_projection(classifier,classifier.data);   % x^T*w
    likelihoods = classifier_compute_log_likelihoods(classifier,projection);
    [probs,data_log_likelihood] = classifier_compute_trial_probs(classifier,likelihoods,classifier.stimuli);
    classifier.probs = probs;
    classifier.data_log_likelihood = data_log_likelihood;
end