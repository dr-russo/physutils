function [M,S] = movingavg(time,data,w)
%===============================================================================
% MOVAVG Calculates a moving average across time series data, using a
% window size defined by w (ms).
%
% RETURNS:
%   M       mean vector
%   S   
% 
% INPUTS:
%   time    time vector
%   data    timeseries data vector
%   w       window size for moving average (ms) 
%
% MJR 7/2013
%===============================================================================





   dt = time(2)-time(1);
   dw = round((w/1000)/dt);
   n = length(data);
   N = -dw+1;
   M = zeros(N,1);
   S = zeros(N,1);

   for m=1:(n-dw)
      M(m,1) = sum(data(m:m+dw))/dw;
      S(m,1) = std(data(m:m+dw));
   end
   
end