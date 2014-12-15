function [E,varargout] = simpledetection(time,data,window,threshold)
%===============================================================================
% SIMPLEDETECTION
%
%
%
%===============================================================================

%Sample interval
dt = time(2)-time(1);
%Set window according to sample interval
w = round((window/1000)/dt);

N = length(data);
M = zeros(N,1);
S = zeros(N,1);
E = zeros(N,1);

SD = std(data(1:1+(50*w)));  %Initial standard deviation

for n = 1:N
  
   if (n-w/2) < 1
      t1 = 1;
   else
      t1 = n-w/2;
   end
   
   if n+w > N
      t2 = N;
   else
      t2 = n+w/2;
   end
   
   M(n,1) = mean(data(t1:t2));
   S(n,1) = std(data(t1:t2))/SD; %sd as multiple of baseline SD
   
   if S(n,1) >= threshold
		E(n,1) = 1;
   end
   
   if (n+50)*w > N
       SD = std(data(N-(50*w)));
   else
       SD = std(data(n:(n+50*w)));
   end
end
varargout(1) = {M};
varargout(2) = {S};

end