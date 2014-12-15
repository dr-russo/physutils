function [Amp,AUC,RT,HW,Lat] = synstats(file,stim)

index = struct2cell(load(file));
time = index{1};
dt = time(2)-time(1);
N = length(index)-1;
BASE = 0.04;
base = 0.04/dt;
W = 0.1;
T1 = stim-BASE;
T2 = stim+W;

t1 = round(T1/dt);
t2 = round(T2/dt);


Amp = zeros(N,1);
AUC = zeros(N,1);
RT = zeros(N,1);
%Tau = zeros(N,1);
HW = zeros(N,1);
Lat = zeros(N,1);

u = 1e12;

figure();
hP = plot(NaN,NaN);
set(gca,'XLim',[time(t1),time(t2)]-time(t1));

for n = 1:N

   ctime = time(t1:t2)-time(t1);  %Get t1:t2 of time vector and zero
   cdata = index{n+1}(t1:t2);
   bline = mean(cdata(1:base));
   cdata = u*(cdata - bline);	%Baseline data
   set(hP,'XData',ctime,'YData',cdata);
   
   assignin('base','ctime',ctime);
   assignin('base','cdata',cdata);
   
   EV = eventdet(ctime,cdata,2,[0.001 BASE]);
   
   if sum(EV) >= 10
   
   %Calculate maximum amplitude
   [A,maxI] = maxamp(ctime,cdata,0.25,'n');
   Amp(n,1) = A;
   
   %Calculate area under curve
   AUC(n,1) = trapz(ctime,cdata);
   
   %Calculate 10-90% rise time
   Rise = (maxI-(0.01/dt)):maxI;
   Fall = maxI:length(cdata);
   T5 = time(lfind(cdata(Rise),0.05*A,0.01,1));
   T10 = time(lfind(cdata(Rise),0.1*A,0.01,1));
   T50_1 = time(lfind(cdata(Rise),0.5*A,0.01,1));
   T90 = time(lfind(cdata(Rise),0.9*A,0.01,1));
   
   RT(n,1) = T90-T10;
   
%    %Calculate time constant, tau_off
%    t0 = ctime(maxI);
%    Tail = 0.03/dt;
%    FitExp = fittype(@(amp,tau,off,x)amp*exp(-(x-t0)/tau) + off);
%    INIT = [M-BL,0.010,BL];
%    F = fit(ctime(maxI:(maxI+Tail))',cdata(maxI:(maxI+Tail))',FitExp,'StartPoint',INIT);
%    hold on;
%    hP2 = plot(F,'r');
% 
%    Tau(n,1) = F.tau;
   
   %Calculate half-width
   T50_2 = time(lfind(cdata(Fall),0.5*A,0.01,1));
   HW(n,1) = T50_2-T50_1;
   
   %Calculate latency to 10% rise;
   Lat(n,1) = T5 - (T1+stim);
   end

end
end