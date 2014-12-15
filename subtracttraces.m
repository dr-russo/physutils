function sdata = subtracttraces(data1,data2)
%===============================================================================
% SUBTRACTTRACES
% Subtract traces in physiology dataset.  Substracts first episode of data set 1
% from first episode of data set 2, etc. 
%
% RETURNS
%   sdata   Subtracted data set (data2-data1);
%
% INPUTS
%   data1   First data set.
%   data2   Second data set.
%===============================================================================

%Check that data sets contain equal number of episodes.
if (iscell(data1) && iscell(data2)) && (length(data1) ~= length(data2))
		fprintf(2,'Data sets must contain equal numbers of episodes.');
end

nEpisodes = length(data1);
sdata = cell(size(data1));

%Subtract data sets
for n=1:nEpisodes
	sdata{n} =  data2{n} - data1{n};
end

end
