function loss= loss_rocArea(label, out, varargin)
%LOSS_ROCAREA - Loss function: Area over the ROC curve
%
% Synopsis:
% LOSS= loss_rocArea(LABEL, OUT)
%
% IN  LABEL - matrix of true class labels, size [nClasses nSamples]
%     OUT   - matrix (or vector for 2-class problems) of classifier outputs
%
% OUT LOSS  - loss value (area over roc curve)
%
% Note: This loss function is for 2-class problems only.
%
% Benjamin Blankertz
%
% Taken from the BBCI Toolbox distributed with a MIT License
% https://github.com/bbci/bbci_public
% 
% Copyright (c) 2015 The BBCI Group
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

if size(label,1)~=2,
  error('roc works only for 2-class problems');
end
N= sum(label, 2);
lind= [1:size(label,1)]*label;

%resort the samples such that class 2 comes first.
%this makes ties count against the classifier, otherwise
%loss_rocArea(y, ones(size(y))) could result in a loss<1.
[so,si]= sort(-lind);
lind= lind(:,si);
out= out(:,si);

[so,si]= sort(out);
lo= lind(si);
idx2= find(lo==2);
ncl1= cumsum(lo==1);
roc= ncl1(idx2)/N(1);

% area over the roc curve
loss= 1 - sum(roc)/N(2);
end