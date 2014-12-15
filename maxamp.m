function [Maximum,MaxI] = maxamp(time,data,w)
%=============================================================================== 
% MAXAMP Determines maximum amplitude of data, but calculates average value
%		 in a +/- w ms window around maximum to mitigate noise effects.
%
% RETURNS:
%	Maximum		Maximum value.
%	MaxI		Index of maximum value.
%
% PARAMETERS:
%   time		Time vector of data. 
%	data	    Data vector.
%	w			Window (in ms) over which to average around maximum.
%
%===============================================================================

dt = time(2)-time(1);
w = round((w/1000)/dt);

[M,MaxI] = max(data);

if (MaxI-w >= 1) && (MaxI+w <= length(data)) 
	Maximum = mean(data((MaxI-w):(MaxI+w)));
elseif MaxI+w > length(data)
	Maximum = mean(data((MaxI-w):MaxI));
elseif MaxI-w < 1
	Maximum = mean(data(MaxI:(MaxI+w)));
else
	Maximum = M;
end

end
