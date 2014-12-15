function hF = plotphys(time,data,varargin)
%PLOTPHYS	Plot of time series electrophysiological data
%
%TIME       Time vector
%DATA       Data, cell array where each trial or episode in a separate cell
%
%Optional arguments:
%EPISODES	Episodes/trial numbers to plot
%XLIMS		X(time) limits of plot
%UNITS		Data units, pA/pa/i/I for current, mV/mv/v/V for voltage
%HEADERS	Title for plots
%AXISON		Axis on(1) or off(0)
%TYPE       Plot type: Normal, plot episodes(0)
%			Plot episodes & mean of episodes(1)
%	        Plot episodes & mean for baseline and for responses(2)
%STIM       Start time of stimulus/event
%BG         black background(0) or white background(1)	
%AXIS       Destination: new figure(0), or axis/figure handle

%Default values %%%%%%%%%%%%%%%%%%%%%%%
episodes = 1:length(data);
xlims = [time(1),time(end)];
units = 'pA';
header = {};
ptype = 0;
bgcolor = 0;
axisOn = 1;
stim = 0.4;
hA = [];

%Parse varargin %%%%%%%%%%%%%%%%%%%%%%%
for arg=1:length(varargin)
	switch varargin{arg}
		case {'Episodes','episodes','Episode','episode'}
			episodes = varargin{arg+1};
		case {'XLim','XLims','xlim','xlims'}
			xlims = varargin{arg+1};
		case {'units','Units'}
			units = varargin{arg+1};
		case {'Header','header'}
			header = varargin{arg+1};
		case {'Type','type'}
			ptype = varargin{arg+1};
		case {'BG','bg'}
			bgcolor = varargin{arg+1};
		case {'AxisOn','axison','Axison','axisOn'}
			axisOn = varargin{arg+1};
		case {'Axis','axis'}
			hA = varargin{arg+1};
		case {'Stim','stim','Stimulus','stimulus'};
	end
end
	


%Plot appearance %%%%%%%%%%%%%%%%%%%%%%
if bgcolor == 0
	figbg = [0 0 0];
	plotcolor = [1 1 1];
	trialcolor = [1,1,1];
	meancolor = [0 0 1];
	axiscolor = [1 1 1];
else
	figbg = [1 1 1];
	plotcolor = [0 0 155]/255;
	trialcolor = [120 120 120]/255;
    meancolor = plotcolor;
	axiscolor = [0 0 0];
end

fontName = 'Helvetica';
fontSize = 18;
axisFontSize = 16;
fontWeight = 'normal';

if ishandle(hA)
	handletype = get(hAxis,'Type');
	if ~strcmp(handletype,{'axis','axes'});
	  fprintf(2,'Handle must be a valid axis handle plot destination.');
    end
else
	hF = figure();
	set(hF,'Color',figbg);
	hA = axes(); hol on
end


switch units
	case {'pA','pa','i','I','PA'}
		U = 1e12;
		ulabel = 'pA';
	case {'mV','MV','mv','v','V'}
		U = 1e3;
		ulabel = 'mV';
end





%Generate plots %%%%%%%%%%%%%%%%%%%%%%%

N = length(episodes);

t1 = round(xlims(1)/dt);
t2 = round(xlims(2)/dt);
bt1 = round((stim-0.02)/dt);
bt2 = round(stim/dt);

maximum = 0;
minimum = 0;
cdata = zeros(N,length(time(t1:t2)));
switch ptype
	case 0
		hP = zeros(N,1);
		for m = 1:N
			n = episodes(m);
			cdata(m,:) = U*(data{n}(t1:t2)-mean(data{n}(bt1:bt2)));
			hP(m,1) = plot(hA,time(t1:t2),cdata(m,:),'Color',plotcolor);		
			currentmax = max(cdata(m,:));
			currentmin = min(cdata(m,:));
			if currentmax > maximum
				maximum = currentmax;
			end
			if currentmin < minimum
				minimum = currentmin;
			end
		end
	case 1
		for m = 1:N
			n = episodes(m);
			cdata(m,:) = U*(data{n}(t1:t2)-mean(data{n}(bt1:bt2)));
		end
		meanData = mean(cdata,1);
		hP = plot(hA,time(t1:t2),mean(cdata,1),'Color',plotcolor,'LineWidth',1);
		maximum = max(meanData);
		minimum = min(meanData);
	case 2
		hP = zeros(N+1,1);
		for m = 1:N
			n = episodes(m);
			cdata(m,:) = U*(data{n}(t1:t2)-mean(data{n}(bt1:bt2)));
			hP(m,1) = plot(hA,time(t1:t2),cdata(m,:),'Color',trialcolor);		%hP
			currentmax = max(cdata(m,:));
			currentmin = min(cdata(m,:));
			if currentmax > maximum
				maximum = currentmax;
			end
			if currentmin < minimum
				minimum = currentmin;
			end
		end
		hP(N+1,1) = plot(hA,time(t1:t2),mean(cdata,1),'Color',meancolor,'LineWidth',2);
	
	case 3
		hP = zeros(N+2,1);
		events = zeros(N,1);
		for m = 1:N
			n = episodes(m);
			cdata(m,:) = U*(data{n}(t1:t2)-mean(data{n}(bt1:bt2)));
			E = detectevent(time(t1:t2),cdata(m,:),2,U*data{n}(bt1:bt2));
			if sum(E) > 100
				events(m,1) = 1;
			end
			hP(m,1) = plot(hA,time(t1:t2),cdata(m,:),'Color',trialcolor);		
			currentmax = max(cdata(m,:));
			currentmin = min(cdata(m,:));
			if currentmax > maximum
				maximum = currentmax;
			end
			if currentmin < minimum
				minimum = currentmin;
			end
		end
		pos=0;
		neg=0;
		presponses = zeros(1,length(time(t1:t2)));
		nresponses = zeros(1,length(time(t1:t2)));
		for p=1:N
			if events(p,1) == 1
				presponses = presponses + cdata(p,:);
				pos=pos+1;
			elseif events(p,1) == 0
				nresponses = nresponses + cdata(p,:);
				neg=neg+1;
			end
		end
		if pos > 0
			PMean = presponses/pos;
			hP(N+1,1) = plot(hA,time(t1:t2),PMean,'b','LineWidth',1.5,'Color',meancolor);
		end
		if neg > 0
			NMean = nresponses/neg;
			hP(N+2,1) = plot(hA,time(t1:t2),NMean,'b','LineWidth',1.5,'Color',meancolor);		
		end
end %ptypes		
		

%Plot adjustments %%%%%%%%%%%%%%%%%%%%%

if abs(maximum) >= abs(minimum)
   ylims = [minimum-0.05*abs(minimum), maximum+0.1*abs(maximum)];
elseif abs(minimum) > abs(maximum)
   ylims = [minimum-0.1*abs(minimum), maximum+0.05*abs(maximum)];
end

set(hA, 'XLim',xlims,...											
		'YLim',ylims,...								
		'Units','normalized',...
		'Box','off',...
		'TickDir','out',...
		'TickLength',[0.01 0.01],...
		'FontName',fontName,...
		'FontSize',axisFontSize,...
		'FontUnits','Points',...
		'FontWeight',fontWeight,...
		'FontAngle','normal',...
		'LineWidth',1.5,...
		'Color',figbg,...
		'XColor',axiscolor,...
		'YColor',axiscolor);
ticklabel = str2double(cellstr((get(hA,'XTickLabel'))));
set(hA,'XTickLabel',num2str(1000*(ticklabel-xlims(1)))); %Normalize X labels
	

if axison == 1
	xlabel('ms');
	ylabel(ulabel);
	if ~isempty(header)
		title(header);
	end
else
   set(hA,'Visible','off');
   apos = get(hA,'Position');
   if ~isempty(header)
		annotation('textbox','String',header,'Position',[apos(1),apos(2)+0.025,0.2,0.05],...
					'LineStyle','none','FontName','Helvetica','FontSize',hfsize,...
					'FontWeight','bold','FitBoxToText','on','Color',[0 1 0]);
   end
end

end


