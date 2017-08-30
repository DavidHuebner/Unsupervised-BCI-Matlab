function log_lik = gauss_log_lik(X,mu)
% Computes the log-likelihood of a normal distribution with mean mu and
% unit variance(!)
log_lik = -log(sqrt(2*pi))-0.5*((X-mu).^2);
end