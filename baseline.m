function bdata = baseline(data,dt,interval)
%===============================================================================
% BASELINE 
% Calculates and subtracts the baseline (over specified interval) from data. 
%	
% OUTPUTS:
%	bdata		Baselined data (same dimensions as [data]).
%	
% INPUTS:
%	data		Raw data for baseline subtraction
%	interval    Interval over which to determine baseline, [t1 t2].
%	dt          Sampling interval of data (default = 1).
%
%===============================================================================
	if nargin < 3 
        interval = [0 0.1*length(data)];
    end
	if nargin < 2
		dt = 1;
    end
	
    %Restrict interval to nearest integer multiple of dt
	t1 = floor(interval(1)/dt)+1;     
	t2 = floor(interval(2)/dt)+1;

    if iscell(data)
        nEpisodes = size(data,1);
        bdata = cell(length(data),1);
        for n = 1:nEpisodes
            bdata{n} = data{n} - mean(data{n}(t1:t2)); 
        end
    else
        
        bdata = data - mean(data(t1:t2));
    end
	
end

