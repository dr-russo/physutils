function [result,R,Rnew] = sag(time, data, episodes, firstI, deltaI,visible)
%===============================================================================
%SAG	Measures the voltage sag parameters for each trace in a
%		current-clamp IV.  
%		Returns the Vrest, Vsag, Vsteady, Vsag-Vsteady difference, and
%		an index of sag magnitude (1-Vsag/Vsteady)*100;
%
%TIME		Time vector.
%DATA		I-clamp data.
%EPISODES	Episodes to include in analysis
%FIRSTI		Amplitude of first current step (indicated +/-).
%DELTAI		Magnitude of current step (pA)
%VISIBLE	Online visualization of analysis (1=ON,0=OFF)
%
%RESULT = SAG(TIME, DATA, EPISODES, FIRSTI, DELTAI, VISIBLE)
%===============================================================================

if nargin < 6
	visible = 0;
end


dt = time(2)-time(1);
N = length(episodes);
result = zeros(N,6);
R = zeros(2,1);

w = 4; %ms

%MJR Data
stim = round(0.5/dt);
b1 = round(0.45/dt);
b2 = round(0.499/dt);
tsag1 = round(0.525/dt);
tsag2 = round(0.625/dt);
tstdy1 = round(1.4/dt);
tstdy2 = round(1.499/dt);
xlims = [0 2];

% %JB Data
% stim = round(0.162/dt);
% b1 = round(0.1/dt);
% b2 = round(0.15/dt);
% tsag1 = round(0.165/dt);
% tsag2 = round(0.285/dt);
% tstdy1 = round(0.79	/dt);
% tstdy2 = round(0.84/dt);
% xlims = [0 1];

if visible == 1
	hF = figure();
	hSP1 = zeros(N,1);
	hSP2 = zeros(N,1);
	hSeg = zeros(N,2);
end

for m = 1:N
    n = (N+1)-m;
    cdata = 1000*data{episodes(m)};
    if mean(diff(cdata(stim:tsag1))) > 0
		dir = 'p';
	else
		dir = 'n';
	end
    [M,Imax] = maxamp(time,cdata(tsag1:tsag2),w,dir);
	Imax = Imax+tsag1;	%Normalize to entire trace
    
	result(n,1) = firstI+(m-1)*deltaI;							%Current injection
	result(n,2) = mean(cdata(b1:b2));							%Membrane potential
    result(n,3) = M-result(n,2);								%Voltage at sag 
    result(n,4) = mean(cdata(tstdy1:tstdy2))-result(n,2);		%Voltage at steady-state
    result(n,5) = -1*(result(n,3) - result(n,4));	%Sag difference
    result(n,6) = ((result(n,3)-result(n,4))/result(n,4))*100;		%Sag index
	

	
	if visible == 1
		hSP1 = subplot(1,2,1); hold on
		hP(m) = plot(time,cdata,'k'); 
		dw = round(w/1000/dt);
		if result(n,1) == -50 || result(n,1) == -100;
			c1 = 'go';
			c2 = c1;
		else
			c1 = 'ro';
			c2 = 'bo';
		end
		hSeg(m,1) = plot(time(Imax-dw:Imax+dw),cdata(Imax-dw:Imax+dw),c1);
		hSeg(m,2) = plot(time(tstdy1:tstdy2),cdata(tstdy1:tstdy2),c2);
		%set(hSeg(m,1),'MarkerFaceColor','b');
	end
    
	
end
	indx1 = find(result(:,1)==-50);
	indx2 = find(result(:,1)==-100);
	
	R1(1) = result(indx1,3)/-50;
	R1(2) = result(indx1,4)/-50;
	R2(1) = result(indx1,3)/-100;
	R2(2) = result(indx1,4)/-100;
	
	Rnew = [R1;R2].*1000;
	
	F1 = resistance(result(:,1),result(:,3));	%Rsag
	F2 = resistance(result(:,1),result(:,4));	%Rsteady
	R(1) = 1000*F1(1); %MOhm (for mV and pA)
	R(2) = 1000*F2(1); %MOhm (for mV and pA)



if visible == 1
	subplot(1,2,1);
	set(hSP1,'XLim',xlims);
	xlabel('seconds');
	ylabel('mV');
	
	hSP2 = subplot(1,2,2); hold on
	hV1 = plot(result(:,1),result(:,3),'ro-','MarkerFaceColor','r','MarkerSize',5);
	hV2 = plot(result(:,1),result(:,4),'bo-','MarkerFaceColor','b','MarkerSize',5);
	RsagPlot = polyval(F1,result(:,1));
	RstdyPlot = polyval(F2,result(:,1));
	plot(result(:,1),RsagPlot,'r--');
	plot(result(:,1),RstdyPlot,'b--');
	assignin('base','hF',hF);
	xlabel('I_{injected} (pA)');
	ylabel('mV')

end
end
