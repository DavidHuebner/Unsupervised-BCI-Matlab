function classifier = classifier_mix_maximization(classifier)
%% Execute the maximization step for the EM algorithm
%
% Parameters:
% classifier   -- the classifier struct should contain the classifier.probs matrix.                
%
% returns:
% classifier   -- classifier.em_pos and classifier.em_neg are updated.
%               
% written by Pieter-Jan Kindermans


% Infer number of total number of epochs (N) and number of trials (nr_trials)
N=0;
nr_trials = length(classifier.data);
for i=1:nr_trials
    N = N+size(classifier.data{i},1);
end

xTyp = zeros('like',classifier.w);
xTyn = zeros('like',classifier.w);

% Add contributions for each selection that has to be made
for c_i = 1:nr_trials
    cur_probs = classifier.probs(c_i,:);

    cur_XTYp = classifier.XTYp{c_i};
    cur_XTYn = classifier.XTYn{c_i};
    
    % Weigh the contribution per option with the probability of that option.
    for a_i =1:classifier.nr_commands
        xTyp  = xTyp + cur_probs(a_i)*cur_XTYp(:,a_i);
        xTyn  = xTyn + cur_probs(a_i)*cur_XTYn(:,a_i);
    end
end
classifier.em_pos = xTyp/N; 
classifier.em_neg = -xTyn/N;
end


