function hF = qplot(data,episodes,xlims,units,header,axison,ptype,colormode,dest)
%QPLOT		Plot of time series data.
%
%HF = qplot(FILENAME,EPISODES,XLIMS,UNITS,HEADERS,AXISON,ptype,COLORMODE)
%
%DATA       Data file, first vector is time
%EPISODES	Episodes to plot
%XLIMS		X(time) limits of plot
%UNITS		Data units, pA/pa/i/I for current, mV/mv/v/V for voltage
%HEADERS	Title for plots
%AXISON		Axis on(1) or off(0)
%PTYPE      Plot type: Normal, plot episodes(0)
%			Plot episodes & mean of episodes(1)
%	        Plot episodes & mean for baseline and for responses(2)
%COLORMODE  black background(0) or white background(1)	
%DEST       Destination: new figure(0), or axis/figure handle

%Argument check
if nargin == 1
   if isstruct(data)
      DATA = data.FILE;
      episodes = data.EPS;
      xlims = data.XLIMS;
      units = data.UNITS;
      header = data.HEADER;
      axison = data.AXIS;
      ptype = data.PTYPE;
      colormode = data.COLORMODE;
   else
      fprintf(2,'Single argument must be a struct containing function parameters.\n');
   end
else
   DATA = data;
   if nargin < 8
      colormode = 1;
   end
   if nargin < 7
      ptype = 0;
   end
   if nargin < 6
      axison = 1;
   end
   if nargin < 5
      header = {''};
   end
end


%Plot appearance
if colormode == 0
	figbg = [0 0 0];
	plotcolor = [1 1 1];
	trialcolor = [1,1,1];
	meancolor = [0 0 255]/255;
	axiscolor = [1 1 1];
else
	figbg = [1 1 1];
	plotcolor = [0 0 155]/255;
	trialcolor = [120 120 120]/255;
   meancolor = plotcolor;
	axiscolor = [0 0 0];
end

fsize = 22;
hfsize = 18;
afsize = 18;


if nargin == 9
   if ishandle(dest)
      H = dest;
      type = get(H,'Type');
      if strcmp(type,'figure');
         H = get(H,'Children');
      end
   end
elseif nargin < 9
   hF = figure();
   set(hF,'Color',figbg);
   H = axes();
   hold on;
end


switch units
	case {'pA','pa','i','I'}
		U = 1e12;
		ulabel = 'pA';
	case {'mV','mv','v','V'}
		U = 1e3;
		ulabel = 'mV';
end




index = struct2cell(load(DATA));
time = index{1};
dt = time(2)-time(1);
if episodes == -1
	N = length(index)-1;
	episodes = 1:N;
else
	N = length(episodes);
end
t1 = round(xlims(1)/dt);
t2 = round(xlims(2)/dt);
bt1 = round((xlims(1)-0.02)/dt);
bt2 = t1;


maximum = 0;
minimum = 0;
cdata = zeros(N,length(time(t1:t2)));
hold on;
switch ptype
	case 0
		hP = zeros(N,1);
		for m = 1:N
			n = episodes(m);
			cdata(m,:) = U*(index{n+1}(t1:t2)-mean(index{n+1}(bt1:bt2)));
			hP(m,1) = plot(H,time(t1:t2),cdata(m,:),'Color',plotcolor);		
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
			cdata(m,:) = U*(index{n+1}(t1:t2)-mean(index{n+1}(bt1:bt2)));
		end
		meanData = mean(cdata,1);
		hP = plot(H,time(t1:t2),mean(cdata,1),'Color',plotcolor,'LineWidth',2);
		maximum = max(meanData);
		minimum = min(meanData);
	case 2
		hP = zeros(N+1,1);
		for m = 1:N
			n = episodes(m);
			cdata(m,:) = U*(index{n+1}(t1:t2)-mean(index{n+1}(bt1:bt2)));
			hP(m,1) = plot(H,time(t1:t2),cdata(m,:),'Color',trialcolor);		%hP
			currentmax = max(cdata(m,:));
			currentmin = min(cdata(m,:));
			if currentmax > maximum
				maximum = currentmax;
			end
			if currentmin < minimum
				minimum = currentmin;
			end
		end
		hP(N+1,1) = plot(H,time(t1:t2),mean(cdata,1),'Color',meancolor,'LineWidth',2);
	
	case 3
		hP = zeros(N+2,1);
		events = zeros(N,1);
		for m = 1:N
			n = episodes(m);
			cdata(m,:) = U*(index{n+1}(t1:t2)-mean(index{n+1}(bt1:bt2)));
			E = eventdet(time(t1:t2),cdata(m,:),2,U*index{n+1}(bt1:bt2));
			if sum(E) > 20
				events(m,1) = 1;
			end
			hP(m,1) = plot(H,time(t1:t2),cdata(m,:),'Color',trialcolor);		
			currentmax = max(cdata(m,:));
			currentmin = min(cdata(m,:));
			if currentmax > maximum
				maximum = currentmax;
			end
			if currentmin < minimum
				minimum = currentmin;
			end
      end
      assignin('base','events',events);
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
			hP(N+1,1) = plot(H,time(t1:t2),PMean,'b','LineWidth',1.5,'Color',meancolor);
		end
		if neg > 0
			NMean = nresponses/neg;
			hP(N+2,1) = plot(H,time(t1:t2),NMean,'b','LineWidth',1.5,'Color',meancolor);		
		end
end %ptypes		
		

%Automatically set y limits.
if abs(maximum) >= abs(minimum)
   ylims = [minimum-0.05*abs(minimum), maximum+0.1*abs(maximum)];
elseif abs(minimum) > abs(maximum)
   ylims = [minimum-0.1*abs(minimum), maximum+0.05*abs(maximum)];
end

%hA = get(hF,'Children');													%hA
set(H,'XLim',xlims,...											
		'YLim',ylims,...								
		'Units','normalized',...
		'Box','off',...
		'TickDir','out',...
		'TickLength',[0.01 0.01],...
		'FontName','Helvetica',...
		'FontSize',afsize,...
		'FontUnits','Points',...
		'FontWeight','normal',...
		'FontAngle','normal',...
		'LineWidth',1.5,...
		'Color','none',...
		'XColor',axiscolor,...
		'YColor',axiscolor);
ticklabel = str2double(cellstr((get(H,'XTickLabel'))));
set(H,'XTickLabel',num2str(1000*(ticklabel-xlims(1)))); %Normalize X labels
	

if axison == 1
	xlabel('ms');
	ylabel(ulabel);
	title(header);
else
	set(H,'Visible','off');
   apos = get(H,'Position');
   if ~strcmp(header,'')
	annotation('textbox','String',header,'Position',[apos(1),apos(2)+0.025,0.2,0.05],...
		       'LineStyle','none','FontName','Helvetica','FontSize',hfsize,...
			   'FontWeight','bold','FitBoxToText','on','Color',[0 1 0]);
   end
end

function f = lfind(A,a,w)
	f = find(A > a-w & A < a+w,1);
end

end


