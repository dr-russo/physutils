%EPSP Tau Measurements
clear
m=1;
n=1;
RESULTS(100)=struct('cell','','label','','cond','','tau',0,'normr',0);

%%
loadphys
dt = time(2)-time(1);

%%
eps = 2;
c1 = {'-60mV','-70mV','-80mV'};	%Episodes
c2 = {'ctrl','SR,CGP'};
c3 = {'-70mV','-80mV'};
c4 = {'ctrl','-70,SR/CGP','-60,SR/CGP','-60,AP5'};

condition = {'-60mV'};
label = {'LOT','ASSN','AON'};

s1 = 0.5;
s2 = 1.5;
s3 = 2.5;

w = 0.1;

xlims = [s1-w,s1+2*w;
		 s2-w,s2+2*w;
		 s3-w,s3+2*w];
cellname = getcellname(currentfile);


%%
close all
for m=1:eps
	trace = data{2*m};
	for n=1:3
		ftrace = sharplowpass(trace,1/dt,1);
		[tau(m,n),nr(m,n)] = epsptau(time,ftrace,xlims(n,:));
	end
end
%%


%%
for m = 1:eps
	for n=1:3
		p = 3*(m-1)+n;
	RESULTS(p).cell = cellname;
	RESULTS(p).label = label{n};
	RESULTS(p).cond = condition{m};
	RESULTS(p).tau = tau(m,n);
	RESULTS(p).normr = nr(m,n);
	end
end

%%
for p = 1:length([RESULTS(:).tau])
	fprintf(1,'%s\t%s\t%s\t%6.5f\t%6.5f\n',...
			RESULTS(p).cell,...
			RESULTS(p).label,...
			RESULTS(p).cond,...
			RESULTS(p).tau,...
			RESULTS(p).normr);	
end

%%
%QUICK
close all
loadphys
%%
dt = time(2)-time(1);

stim = [0.49,1.47,2.44];
label = {'LOT','ASSN','AON'};
episodes = 2;
events = 3;
window = [stim(1),stim(1)+0.1];
	ftrace = sharplowpass(data{2},1/dt,2);
[tau(1,1),nr(1,1)] = epsptau(time,ftrace,window);
%%
for m = 1:episodes
	for n = 1:events
	window = [stim(n),stim(n)+0.1];
	ftrace = sharplowpass(data{2*m},1/dt,0.5);
[tau(m,n),nr(m,n)] = epsptau(time,ftrace,window);
fprintf(1,'%d\t%s\t%6.5f\t%6.5f\n',m,label{n},tau(m,n),nr(m,n));
	end
end
