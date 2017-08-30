function out = logsumexp(x)
% By Pieter-Jan Kindermans
%
% Comment by david.huebner@blbt.uni-freiburg.de:
% There is a trick used here in order to avoid overflow of the values,
% using the identity: log(sum(exp(x))) = x_max+log(sum(exp(x-x_max))
% see https://hips.seas.harvard.edu/blog/2013/01/09/computing-log-sum-exp/
% for a more detailed explanation
    x_max = max(x);
    x_temp = x-x_max;
    x_exp = exp(x_temp);
    x_expsum = sum(x_exp);
    out = log(x_expsum)+x_max;
end