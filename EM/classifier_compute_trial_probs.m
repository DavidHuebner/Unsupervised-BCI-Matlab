function [probs,data_log_likelihood] = classifier_compute_trial_probs(classifier,likelihoods,stimuli)
%% Compute the probabilities for the symbols given the log likelihoods of the projections, the stimuli and the classifier
% likelihoods   --  cell array, with per cell (Sx2) likelihoods,
%                   first column, contains likelihood for positive stimulus
%                   second column, contains likelihood for negative
%                   stimulus
%
% stimuli       --  cell_array with per cell  (nr_commands X S) matrix,
%                   BINARY ARRAY to indicate whether command a was intensified
%                   during stimulus s
%
% By Pieter-Jan Kindermans, 2014
%
% Modified and commented by david.huebner@blbt.uni-freiburg.de, 2017

data_log_likelihood = 0;
probs = zeros(length(likelihoods),classifier.nr_commands);

% Loop over each selected character
for c_i =1:length(likelihoods)
    % Compute the unnormalized probability of each option, i.e. sum the
    % corresponding log-likelihoods
    
    cur_stimuli = stimuli{c_i};
    cur_likelihoods = likelihoods{c_i};
    
    % In True-Zero Training for BCI this loop corresponds to the log of the 
    % numerator of ""inferring the desired symbol"" on page 6, i.e.
    % log (p(a_t)) + sum(log(p(x_t,i|a_t))) for t=1..6
    for a_i = 1:classifier.nr_commands
        index = cur_stimuli(a_i,:);
        probs(c_i,a_i) = probs(c_i,a_i)+sum(cur_likelihoods(index,1));      % Target
        probs(c_i,a_i) = probs(c_i,a_i)+sum(cur_likelihoods(~index,2));     % Non-Targets
        probs(c_i,a_i) = probs(c_i,a_i)-log(classifier.nr_commands);        % Prior: #Classes
    end    
    % Normalize across selection. Effectively this is computing
    % exp(probs(d_i,:))/sum(exp(probs(d_i,:)), but a small numeric trick is
    % used in logsumexp in order to avoid overflow    
    normalizing_constant = logsumexp(probs(c_i,:));
    probs(c_i,:) = exp(probs(c_i,:)-normalizing_constant);  
    
    % ==> probs are now rescaled to be in [0,1] and to sum up to 1
    
    % Update log-likelihood with logsumexp(probs(c_i,:)).
    data_log_likelihood = data_log_likelihood+normalizing_constant;
end

end
