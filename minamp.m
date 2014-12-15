function [Minimum,MinI] = minamp(time,data,w)
%=============================================================================== 
% MINAMP Determines minimum amplitude of data, but calculates average value
%		 in a +/- w ms window around maximum to mitigate noise effects.
%
% RETURNS:
%	Minimum		Minimum value.
%	MinI		Index of maximum value.
%
% PARAMETERS:
%   time		Time vector of data. 
%	data	    Data vector.
%	w			Window (in ms) over which to average around maximum.
%
%===============================================================================

dt = time(2)-time(1);
w = round((w/1000)/dt);

[M,MinI] = min(data);

if (MinI-w >= 1) && (MinI+w <= length(data)) 
	Minimum = mean(data((MinI-w):(MinI+w)));
elseif MinI+w > length(data)
	Minimum = mean(data((MinI-w):MinI));
elseif MinI-w < 1
	Minimum = mean(data(MinI:(MinI+w)));
else
	Minimum = M;
end

end
