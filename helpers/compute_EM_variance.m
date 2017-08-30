function [EM_var_pos, EM_var_neg] = compute_EM_variance(C,data_norm,mean_pos,mean_neg)
% Computes the variance of the EM-estimator.
% Returns one variance value for each of the two classes
%
% !!! Important: This function assumes that the data is whitened !!!
%
% Originally by Thibault Verhoeven, 2017

[N,feat_dim] = size(data_norm);
prec = eye(feat_dim);
dist_p = data_norm*C.classifier.Whiten - repmat(mean_pos'*C.classifier.Whiten,N,1);
dist_n = data_norm*C.classifier.Whiten - repmat(mean_neg'*C.classifier.Whiten,N,1);

p1 = -0.5*sum(times(dist_p,dist_p),2)*(8.0/34);
p2 = -0.5*sum(times(dist_n,dist_n),2)*(26.0/34);

H11 = zeros(feat_dim,feat_dim);
H22 = zeros(feat_dim,feat_dim);

for i=1:N
    distmat = dist_p(i,:)'*dist_p(i,:);
    temp = (p1(i)+p2(i))*p1(i)*(distmat-prec);
    temp = temp - p1(i)*p1(i)*distmat;
    H11 = H11 + temp/((p1(i)+p2(i))*(p1(i)+p2(i)));
    
    distmat = dist_n(i,:)'*dist_n(i,:);
    temp = (p1(i)+p2(i))*p2(i)*(distmat-prec);
    temp = temp - p2(i)*p2(i)*distmat;
    H22 = H22 + temp/((p1(i)+p2(i))*(p1(i)+p2(i)));
end

EM_var_pos = trace(inv(-1.0*H11));
EM_var_neg = trace(inv(-1.0*H22));
end