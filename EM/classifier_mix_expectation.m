function [classifier] = classifier_mix_expectation(classifier)
%% Execute the expectation step for the EM algorithm
% During this step, we compute the probability for each option symbol per
% trial p(c_t|X_t,w) 
%
% parameters:
% classifier   -- the classifier struct should contain the data and the stimuli
%
% returns
% classifier   -- 
%   .probs: matrix [nr_trials x nr_commands] where entry(i,j)
%                     describes the probability that symbol j was target in trial i.
%   .data_log_likelihood: A measure of how good the classifier
%                                   is separating the data
% 
% Internal variables are:
%   projection: w^T*X for each epoch x
%   likelihood: The target and non-target likelihood of each epoch x 
%               (It is computed based on the projection)
%   
% --
% written by Pieter-Jan Kindermans
%
% Updated by david.huebner@blbt.uni-freiburg.de
projection = classifier_compute_projection(classifier,classifier.data);   
likelihoods = classifier_compute_log_likelihoods(classifier,projection);
[probs,data_log_likelihood] = classifier_compute_trial_probs(classifier,likelihoods,classifier.stimuli);
classifier.probs = probs;
classifier.data_log_likelihood = data_log_likelihood;
end