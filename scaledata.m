function scdata = scaledata(data,u)
%===============================================================================
% SCALEDATA 
% Scale time series data by a scalar factor u.  
%
% OUTPUT
%   scdata  Scaled data.
%
% INPUT
%   data    (1) data vector
%           (2) matrix where each row episode or trial
%           (3) cell array of vectors, each entry episode or trial
% MJR 6/2013
%===============================================================================

if iscell(data)
    scdata = cell(size(data));
    for n = 1:length(data)
        scdata{n} = u*data{n};
    end
else
    scdata = data.*u;
end


end