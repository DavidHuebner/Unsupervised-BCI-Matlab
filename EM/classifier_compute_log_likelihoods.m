function likelihoods = classifier_compute_log_likelihoods(classifier,projection)
% Compute the LOG!! likelihood based on the projection
% Originally written by Pieter-Jan Kindermans
%
% Commented by 
% david.huebner@blbt.uni-freiburg.de, 11-2015
% 
% In this function the probability p(x|w,a) = N(x^T*w|y(a),beta) is
% computed (see Page 6 in the paper "True Zero-Training Brain-Computer
% Interfaces"). Here, beta is chosen to be 1.
%
% classifier.label are the rescaled target and non-target class labels. 
% One can show that when they are chosen as N/N+ and N/N- respectively,
% that this leads to an equivalence between least square regression and
% linear discriminant analysis in terms of the projection w. For instance,
% in the paradigm of the MIX scenario, there are N+ = 8 targets and N-=26 
% non-targets contained in every 34 symbols.
%
% For more information, see:
% Bishop's Machine learning book, Springer, 2006, Chapter 4.1.5
%
% The function gauss_log_lik then computes the log likelihood of the projections 
% given the two different class means and assuming a unit variance.
%
% The return value is a cell with 1xlength(projection) entries where each
% entry contains one vector for the target probabilities and one for
% non-target
likelihoods={};
    for c_i =1:length(projection)
        likelihoods{end+1}=[gauss_log_lik(projection{c_i},classifier.label(1)),...
                            gauss_log_lik(projection{c_i},classifier.label(2))];
    end
end