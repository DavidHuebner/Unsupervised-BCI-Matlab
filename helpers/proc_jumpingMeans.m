function dat= proc_jumpingMeans(dat, nSamples, nMeans)
%PROC_JUMPINGMEANS  - compute the mean in specified time ivals of epochs
%
%Synopsis:
% dat= proc_jumpingMeans(dat, nSamples, <nMeans>)
% dat= proc_jumpingMeans(dat, intervals)
%
%Arguments:
%      dat       - data structure of continuous or epoched data
%      nSamples  - number of samples from which the mean is calculated
%                  if nSamples is a matrix means over the rows are given
%                  back. nMeans is ignored then.
%      nMeans    - number of intervals from which the mean is calculated
%      intervals - each row contains an interval (format: [start end] in ms)
%                  in which the mean is to be calculated
%                  (requires field 't' in dat)
%
%Returns:
%      dat      - updated data structure
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

if nargin==0
    dat=[];return
end

[T, nChans, nMotos]= size(dat.x);
if length(nSamples)==1,
    if ~exist('nMeans','var'), nMeans= floor(T/nSamples); end
    dat.x =permute(mean(reshape(dat.x((T-nMeans*nSamples+1):T,:,:), ...
        [nSamples,nMeans,nChans,nMotos]),1),[2 3 4 1]);
    
    if isfield(dat, 'fs'),
        dat.fs= dat.fs/nSamples;
    end
    if isfield(dat, 't'),
        dat.t = mean(dat.t(reshape((T-nMeans*nSamples+1):T,nSamples,nMeans)));
    end
    
elseif size(nSamples,1)==1 && size(nSamples,2)~=2,
    
    intervals= nSamples([1:end-1; 2:end]');
    dat= proc_jumpingMeans(dat, intervals);
    
else
    nMeans= size(nSamples ,1);
    da = zeros(nMeans, nChans, nMotos);
    for i = 1:size(nSamples,1),
        if any(isnan(nSamples(i,:))),
            da(i,:,:) = NaN;
        else
            I = find(dat.t>=nSamples(i,1) & dat.t<=nSamples(i,2));
            da(i,:,:) = mean(dat.x(I,:,:),1);
        end
    end
    dat.x = da;
    dat= rmfield(dat, 'fs');
    dat.t = mean(nSamples, 2)';
end
