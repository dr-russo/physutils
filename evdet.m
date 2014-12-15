%===============================================================================
% EVENTDETECT
% Simple synaptic event detection using the best-fit of a sliding template 
% 
% Outputs:
%
% Inputs:
% 
%
%===============================================================================

function E = evdet(time,data,varargin)


MinSep = 0.020; %sec
QSyn = 1.5;
tunits = 'sec';

E = zeros(100,6);

%Set parameters according to measurement type:
switch type
case {'PSP','psp','voltage','v'}
	data = 1e3*data;			%Conversion to mV
	tBase = 0.010;
	RISE = 0.010;
	DECAY = 0.040;
	W = 0.08;					%Window size (length of template)
	detect = 0.3;				%Detection threshold (vc)
	MinAmp = 1;					%Minimum amplitude of event
	comp = @gt;
	peakdir = 'p';
	amp = @max;
	units = 'mV';
	sign = +1;
case {'PSC','psc','current','i'}
	data = 1e12*data;			%Conversion to pA
	tBase = 0.010;
	RISE = 0.001;				
	DECAY = 0.06;
	W = 0.08;
	detect = 0.1;				%Detection threshold (ic)
	MinAmp = 10;					%Minimum amplitude of event
	comp = @lt;
	peakdir = 'n';
	amp = @min;
	units = 'pA';
	sign = -1;
end


DT = time(2)-time(1);			%Sample period
Xms = round(0.010/DT);			%Define 10ms in terms of indices:
BL1 = floor(0.2/DT);			%Set baseline
BL2 = floor(0.4/DT);
BLINE = mean(data(BL1:BL2));
data = data - BLINE;			%Baseline data
STIM = round(0.4004/DT);			%Stimulus onset

%Define initial template parameters
SCALE = 1;
OFFSET = mean(data(round(0.1/DT):round(0.2/DT)));
NOISE = std(data(round(0.1/DT):round(0.2/DT)));


%Window size
w = round(W/DT);

STEP = round(0.001/DT); %Move template by STEP indices (corresponds to 1ms)
tTemp = 0:DT:W;
dLength = length(1:1+w)-length(tTemp);
if dLength > 0
	tTemp = [tTemp,W+(1:dLength).*DT];
elseif dLength < 0
	tTemp = 0:DT:(W-dLength);
end
	
	

TEMP = alphasyn(tTemp,RISE,DECAY,QSyn,tBase);
%TEMP = template(tTemp,RISE,DECAY);
N = length(TEMP);

nTimePoints = length(time);

%Start/Stop Positions
if interval == -1
	START = 1;
	STOP = length(time)-w;
elseif interval(2) > (time(end)-W)
	START = round(interval(1)/DT);
	STOP = length(time)-w;
else
	START = round(interval(1)/DT);
	STOP = round(interval(2)/DT);
end

ERR = 1e9;
nEvents = 0;
%DATA = data(1,(START:(START+w)));
Th = zeros(1, round((N-START)/STEP));
SE = zeros(size(Th));

options = optimset('Display','off');

%Set up live animation of event detection
if animate > 0
	fontname = 'Arial';
	fontsz = 14;
	fontwt = 'bold';
	
	hF1 = figure();
	assignin('base','hF1',hF1);

	set(hF1,'Color','w','Position',[440 40 960 640]); %pixels
	%hSA1 = subplot(3,1,1); hold on
	hA1 = axes('Position',[0.076,0.75,0.57,0.22]); hold on
	hP1 = plot(time,data,'b');
	a1 = round(0.4/DT);
	a2 = round(0.8/DT);
	minimum = min(data(a1:a2));
	maximum = max(data(a1:a2));
	span = abs(maximum-minimum);
	set(hA1,'XLim',[time(1),time(end)],'YLim',[minimum-0.1*span,maximum+0.1*span],'Box','on');
	hL1 = ylabel(units);
	%Template
	%subplot(3,1,1);
	hP2 = plot(NaN,NaN);
	set(hP2,'Color','r');
	%Text boxes to display template fitting
	
	%hSA2 = subplot(3,1,2);
	%Raster of events
	hA2 = axes('Position',[0.076,0.45,0.57,0.22]); hold on
	hP3 = plot(NaN,NaN);
	set(hA2,'YLim',[0.8 2.2],'YTick',[]);
	hL2 = ylabel('Events');

	%Threshold - detection criterion
	%hSA3 = subplot(3,1,3);
	hA3 = axes('Position',[0.076,0.15,0.57,0.22]); hold on
	hP4 = plot(NaN,NaN);
	set(hA3,'XLim',[time(1) time(end)]);
	hL3 = ylabel('Fit Index');
	hL4 = xlabel(tunits); 
	
	set([hA1,hA2,hA3],'XLim',[time(1)-DT,time(end)]);
	
	hA4 = axes('Position',[0.73, 0.45, 0.25, 0.35]); hold on
	set(hA4,'visible','off');
	hL5 = xlabel('ms');
	hL6 = ylabel(units);
	hA = [hA1,hA2,hA3,hA4];
	set(hA,'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt,'Box','off','TickDir','out','TickLength',[0.01 0],'LineWidth',1.5);
	set(hA4,'Box','on');
	hL = [hL1,hL2,hL3,hL4,hL5,hL6];
	set(hL,'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt);
	
	hB1 = annotation('textbox','String',{},'Position', [0.72,0.94,0.2,0.05],'LineStyle','none','FitBoxToText','on');
	hB2 = annotation('textbox','String',{},'Position', [0.72,0.9,0.2,0.05],'LineStyle','none','FitBoxToText','on');
	hB3 = annotation('textbox','String',{},'Position', [0.72,0.86,0.2,0.05],'LineStyle','none','FitBoxToText','on');
	hB4 = annotation('textbox','String',{},'Position', [0.72,0.82,0.2,0.05],'LineStyle','none','FitBoxToText','on');

	hB = [hB1,hB2,hB3,hB4];
	set(hB,'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt);
end


%Main loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=START:STEP:STOP
	t1 = n;
	t2 = n+w;
	
%Correct for boundary
	
	DATA = data(t1:t2);


	% Calculate SSE between template and data segment
	% SSE = @(C)sum( (DATA-(C(1).*TEMP+C(2)) ).^2);
	% [C,~,EXIT] = fminsearch(SSE,[SCALE;OFFSET],options);

	SSE = sse(DATA,TEMP,SCALE,OFFSET);
	SCALE = minscale(DATA,TEMP);
	OFFSET = minoffset(DATA,TEMP,SCALE);
	STDERR = sqrt(SSE/(N-1));
	THRESH = SCALE/STDERR;
	Th(1,n)= THRESH;
	
	if animate > 0
		set(hP4,'XData',time(START:n),'YData',Th(START:n),'Color','m');
	end

	%Event Detected%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if  (abs(THRESH) > detect) && feval(comp,SCALE,0) %Ensure direction
		%Check separation from previous event
		if abs(Th(1,n)) > abs(Th(1,n-STEP))
			continue;
		elseif abs(Th(1,n)) <= abs(Th(1,n-STEP))
			p = n-STEP;  %set n to previous n
			p1 = p;
			p2 = p+w;
		
			if (nEvents) > 0 && (p1 < (E(nEvents,1) + (MinSep/DT)))
					continue;
			end
			
		
		nEvents = nEvents+1;		%Outputs:
		E(nEvents,1) = p1;			%(1)Index of event start
		E(nEvents,2) = SCALE;		%Overwritten
		E(nEvents,3) = OFFSET;		%Overwritten

		%Plot raster of events & snapshot of event
			if animate > 0 
				line('Parent',hA2,'XData',[time(p) time(p)],'YData',[1 2]);
				plot(hA4,1000*time(p1:p2),data(p1:p2),'b'); hold on
				plot(hA4,1000*(time(p1)+tTemp),SCALE*TEMP+OFFSET,'r'); hold off
				set(hA4,'XLim',1000*[time(p1),time(p2)]);
				set(hA4,'Visible','on');
			end
		end
	end
	%Event Detected%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if animate == 2
		SYN = SCALE*TEMP + OFFSET;
		%subplot(3,1,1); hold on
		set(hP2,'XData',tTemp+(n*DT),'YData',SYN);

		sc = ['Scale : ' num2str(SCALE)];
		off = ['Offset : ' num2str(OFFSET)];
		ssetext = ['SSE : ' num2str(SSE)];
		noisetext = ['Noise : ' num2str(NOISE)];

		set(hB1,'String',sc);
		set(hB2,'String',off);
		set(hB3,'String',ssetext);
		set(hB4,'String',noisetext);
		pause(0.0001);
	end

end %main iteration

if animate == 1
	%subplot(3,1,3);
	plot(hA3,Th,'m');
	annotation('textbox','String',['Events : ' num2str(nEvents)],'Position',[0.72,0.9,0.2,0.05],...
		'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt,'LineStyle','none');
end

%Calculate precise parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if animate > 0 && nEvents >0
	hF2 = figure();
	assignin('base','hF2',hF2);
	set(hF2,'Color','w');
	hSP = zeros(nEvents,1);
	if nEvents <=6
		cols = nEvents;
		rows = 1;
	else
		cols = 6;
		rows = floor(nEvents/6) + 1*(mod(nEvents,6)>0);
	end
end

for m = 1:nEvents
	%Select window of data that contains event
	tE1 = E(m,1);
	tOnset = round(tBase/DT);
	tE2 = tE1 + w;
	D = data(tE1:tE2);
	T = time(tE1:tE2);
	
	%Recalculate RISE and DECAY by fitting event
	[peak,imax] = feval(amp,D);
	
	%Derive initial fitting parameters for rise from linear fit
	F1Lin = polyfit(T(tOnset:imax),D(tOnset:imax),1);
	F1 = [F1Lin(2);peak;sign/F1Lin(1)];
	F2 = [0;peak;sign*DECAY];
	
	F1 = efit(T(tOnset:imax),D(tOnset:imax),F1);
	F2 = efit(T(imax:end),D(imax:end),F2);	    %Outputs
	E(m,2) = findbase(data,tE1+imax,peakdir);	%(2)Onset of event	
	E(m,3) = peak;								%(3)Amplitude 
	
	E(m,4) = trapz(T,D);						%(4)Area(charge)
	
	rise = D(1:imax);					
	decay = D(imax:end);
	hw1 = lfind(rise,(peak*0.5),0.01,1);
	hw2 = lfind(decay,(peak*0.5),0.01,1);
	E(m,5) = time(hw2)-time(hw1);				%(5)Half-width
	
	E(m,6) = abs(F1(3));						%(6)Time constant, onset
	E(m,7) = abs(F2(3));						%(7)Time constant, decay
	
	FIT_R = F1(1)+F1(2).*exp((T(1:imax)-T(1))/F1(3));
	FIT_D = F2(1)+F2(2).*exp((T(imax:end)-T(imax))/F2(3));
	
	assignin('base','F1',F1);
	assignin('base','F2',F2);
	
	if animate > 0 && nEvents > 0
		hSP(m) = subplot(rows,cols,m); hold on
		set(hSP(m),'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt,'Box','off','TickDir','out','TickLength',[0.01 0],'LineWidth',1.5);
		hT1 = title(num2str(m));
		hT2 = xlabel('sec');
		hT3 = ylabel(units);
		set([hT1,hT2,hT3],'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt);
		set(hT1,'FontSize',fontsz+2);
		plot(T(1:imax),FIT_R,'r');
		plot(T(imax:end),FIT_D,'r');
		plot(T,D,'b');
		set(hSP(m),'XLim',[T(1) T(end)]);
		pos = get(hSP(m),'Position');
		pos(2) = (0.20*pos(2))+pos(2);
		pos(4) = 0.9*pos(4);
		set(hSP(m),'Position',pos);
	end
	
end %loop through events

if nEvents > 0 
	%Resize output matrix
	E = E(1:nEvents,:);
	%Convert indices to time
	E(:,1) = 1000*(time(E(:,1))+tBase);  %Onset of template
	E(:,2) = 1000*time(E(:,2));		  %Onset of data-event
	%Convert to millieseconds
	E(:,5) = 1000*E(:,5);
	E(:,6) = 1000*E(:,6);
	E(:,7) = 1000*E(:,7);
else
	E(:) = [];
end

end %evdet

%Subfunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function S = sse(data,template,scale,offset)
	
	N = length(template);
	S = sum(data.^2) + scale^2*sum(template.^2) + N*offset^2-...
		 2*(scale*sum(data.*template)+offset*sum(data)-scale*offset*sum(template));
end

function minSc = minscale(data,template)
	
	N = length(template);
	minSc = (sum(data.*template)-sum(template)*sum(data)/N)/...
		  (sum(template.^2)-sum(template)^2/N);
end

function minOff = minoffset(data,template,scale)

	N = length(template);
	minOff = (sum(data)-scale*sum(template))/N;
end


% function T = template(t,RISE,DECAY)
% 	if t <= 0
% 		T = 0;
% 	else
% 		T = (1-exp(-t/RISE)).*exp(-t/DECAY);
% 	end
% end

% function L = linfind(data,start,target,dir)
% 	w = 0.01;
% 	k = start;
% 	while data(k) ~= target
% 		if abs(data(k)-target) <= w
% 			break;
% 		end
% 		k = k+dir;
% 	end
% 	L = k;
% end		

