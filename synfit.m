function [p,s] = synfit(time,data,params)

scale = params(1);
offset = params(2);
tau1 = params(3);
tau2 = params(4);

time = time-time(1);	%Normalize time such that t0 = 0;

SYN = @(t,t1,t2)(1-exp(-t/t1)).*exp(-t/t2);

for n=1:25

sse_tau = @(A)sum( (data - (scale.*SYN(time,A(1),A(2))+offset) ).^2 );
p_tau = fminsearch(sse_tau,[tau1;tau2]);
tau1 = p_tau(1);
tau2 = p_tau(2);
 
sse_amp = @(B)sum( (data - (B(1)*SYN(time,tau1,tau2)+B(2)) ).^2 );
p_amp = fminsearch(sse_amp,[scale;offset]);
scale = p_amp(1);
offset = p_amp(2);

end

p = [scale,offset,tau1,tau2];
s = sum( (data - (scale.*SYN(time,tau1,tau2)+offset) ).^2 );



end

