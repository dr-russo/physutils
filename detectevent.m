function [E,varargout] = detectevent(time,data,w,baseline)
%DETECTEVENT

dt = time(2)-time(1);
% t1 = 1;
% t2 = length(data);
SD = std(baseline);
%data = data - mean(data(t1:t2));		%Baseline data

w = round((w/1000)/dt);

N = length(data);
M = zeros(N,1);
S = zeros(N,1);
E= zeros(N,1);

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
   if S(n,1) >= 3.5
		E(n,1) = 1;
   end
end
varargout(1) = {M};
varargout(2) = {S};

end