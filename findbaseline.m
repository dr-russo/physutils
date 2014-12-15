function ibase = findbaseline(data,minbase)
%===============================================================================
% FINDBASELINE
%
% RETURNS
%
% INPUTS
%   data    Data for which to find baseline.
%   minbase Length of desired baseline
%===============================================================================

ibase = 0;             %Baseline indices
datadt = diff(data);   %Derivative of data
%Determine tolerance from range of derivative
tolerance = 0.15;   
for ii=1:(length(datadt)-minbase)
    %Ensure that baseline does not include artifacts or rapidly changing events.
    if min(datadt(ii:(ii+minbase-1))/min(datadt) < tolerance) && ...
       max(datadt(ii:(ii+minbase-1))/max(datadt) < tolerance)
        ibase = [ii (ii+minbase-1)];
        break;
    end
end

%Warn if no baseline found
if ~(ibase)
    fprintf(2,'No satisfactory baseline found.\n');
end
