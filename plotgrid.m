function [hFig1,hF2] = plotgrid(xdims,ydims,spacing,timeWindow,measure,mp,filename)
% PLOTGRID		Assembles grid scan data into colormap of current/voltage maxima, and
%				into plots of raw current/voltage traces at each point.
%
% filename		: filename string
% xdims,ydims	: dimensions of grid (columns,rows)
% spacing		: spacing in pixels/microns between spots
% timeWindow	: window over which to measure and plot
% measure		: measure area ('Q','q','charge','Charge') or amplitude ('Amplitude','amplitude','Amp','amp')
%

if nargin < 7
	filename = uigetfile('*.mat');
end

F = load(filename);
time = F.time;
data = F.data;

%Parameters
gridcolor = 0;
colormode = 1;
heading = {};
climits = 0;
interpolate = 1;
peakdir = 'p';
units = -1e12;

NumPoints = length(data);
if NumPoints ~= (xdims*ydims)
	fprintf(2,'Number of file episodes and grid dimensions do not match.');
	return;
end

w = 1e-9;								%Error allowed for loose find fcn
t1 = lfind(time,timeWindow(1),w);		%Measurement range
t2 = lfind(time,timeWindow(2),w);
b1 = lfind(time,timeWindow(1)-0.05,w);	%Baseline range
b2 = lfind(time,timeWindow(1)-0.001,w);

switch colormode
	case 0
		figbg = [0 0 0];
		plotcolor = [1 1 1];
		axiscolor = [1 1 1];
	case 1
		figbg = [1 1 1];
		plotcolor = [0 0 0];
		axiscolor = [0 0 0];
end



% Colormap %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


switch measure
	%Measure charge / area
	case {'Charge','charge','Q','q'}
		Q = zeros(NumPoints,1);
		for m = 2:NumPoints+1
			currentData = units*index{m};
			currentData = currentData - mean(currentData(b1:b2));
			measureSegment = currentData(t1:t2);
			measureTime = time(t1:t2);

			Q(m-1,1) = trapz(measureTime,measureSegment);
		end
		DATA = Q;
		label = 'pA.s';
		cmap = jet(64);
	%Measure peaks, PSPs or PSCs	
	case {'Amplitude','amplitude','Amp','amp','AMP'}
		AMP = zeros(NumPoints,1);
		for m = 2:NumPoints+1
			currentData = units*index{m};
			currentData = currentData - mean(currentData(b1:b2));
			measureSegment = currentData(t1:t2);
			measureTime = time(t1:t2);

			AMP(m-1,1) = maxamp(measureTime,measureSegment,0.25,peakdir);
		end
		DATA = AMP;
		label = 'pA';
		cmap = jet(64);
   %Determine if AP occurs
   case {'AP','ap'}
	   SP = zeros(NumPoints,1);
	   for m=2:NumPoints+1
		  currentData = units*index{m};
		  currentData = currentData - mean(currentData(b1:b2));
		  measureSegment = currentData(t1:t2);
		  measureTime = time(t1:t2);
		  SD = abs(std(currentData(b1:b2)));
		  A = maxamp(measureTime,measureSegment,0,peakdir);
		  if A > 25*SD
			 SP(m-1,1) = 1;
		  end
	   end
	   label = 'APs';
	   DATA = SP;
	   cmap =  [0, 50/255, 1.0000; 1,0,0];
	   climits = [0 1];
end

DATAMax = max(DATA);
mDATA = reshape(DATA,xdims,ydims);
mDATA = mDATA';

if interpolate == 1
	mDATA = interp2(mDATA,5,'cubic');
end

%Optionally plot color activation map
if mp == 1 || map == 3

hF1 = figure();
set(hF1,'Color',figbg);
imagesc(mDATA);
colormap(cmap);
hA1 = gca;

if climits == 0
	climits = [0 round(DATAMax)];
end

set(hA1,'Units','normalized','CLim',climits);
hCB = colorbar('Position',[0.92 0.5 0.02 0.4]);
if strcmpi(measure,'AP')
   set(hCB,'YTick',climits);
end
xticklabels = (2*spacing):(2*spacing):(xdims*spacing);
yticklabels = ((2*spacing)+(ydims*spacing)):-(2*spacing):0;

%Formatting

set(hA1,'YTickMode','manual',...
		'YTick',(0:2:ydims+2)-1,...
		'XTickLabelMode','manual',...
		'XTickLabel',xticklabels,...
		'YTickLabelMode','manual',....
		'YTickLabel',yticklabels,...
		'TickDir','out');
hT1 = title(hAxis1,heading,'FontSize',14,...
		'FontWeight','bold',...
		'Units','normalized',...
		'Position',[0.127 1.022],...
		'Color',axiscolor);
hXL1 = xlabel(hAxis1,'Distance  {\mu}m','FontSize',14,'FontWeight','bold','Color',axiscolor);
hYL1 = ylabel(hAxis1,'Distance  {\mu}m','FontSize',14,'FontWeight','bold','Color',axiscolor);
set(hA1,'FontSize',14,'FontWeight','bold','Box','off','Color',axiscolor,'XColor',axiscolor,'YColor',axiscolor);

hU1 = annotation('textbox','String',label,...
	   'Units','normalized','Position',[0.91 0.91 0.0945 0.0602],...
	   'LineWidth',0,'EdgeColor','none','FitBoxToText','on',...
       'FontSize',14,'FontWeight','bold','Color',axiscolor);

end %if mp

%Grid plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Optionally plot grid of traces
if mp == 2 || map == 3

units = 1e12; %pA
hSP = zeros(NumPoints,1);
hP = zeros(NumPoints,1);
maxima = zeros(NumPoints,1);
minima = zeros(NumPoints,1);

hF2 = figure();
set(hF2,'Color',figbg);
hold on;

for i=1:ydims   
	for j=1:xdims
		k = xdims*(i-1)+j;
		currentEpisode = units*index{k+1};
		currentEpisode = currentEpisode - mean(currentEpisode(b1:b2));
		hSP(k) = subplot(ydims,xdims,k);
		hP(k) = plot(time(t1:t2),currentEpisode(t1:t2));
		currentmax = max(currentEpisode(t1:t2));
		currentmin = min(currentEpisode(t1:t2));
		
		%Ensure that outliers/artifacts do not contribute to scaling
		if (currentmax < 3500 && currentmin > -3500)   
		 maxima(k) = max(currentEpisode(t1:t2));
		 minima(k) = min(currentEpisode(t1:t2));
		else
		 maxima(k) = 0;
		 minima(k) = 0;
		end
	end
end
maximum = max(maxima);
minimum = min(minima);

if abs(maximum) >= abs(minimum)
   ylimits = [minimum-0.15*abs(maximum), maximum+0.2*abs(maximum)];
   scale = abs(floor(maximum/10)*10);
elseif abs(minimum) > abs(maximum)
   ylimits = [minimum-0.02*abs(minimum), maximum+0.02*abs(minimum)];
   scale = abs(floor(minimum/10)*10);
end


hA2 = get(hF2,'Children');

for q = 1:(xdims*ydims)
   text('Parent',hSP(q),'Units','normalized',...
		'String',sprintf('%d',q),'Position',[0 1.4 0],...
        'FontSize',14,'FontName','Arial',...
		'VerticalAlignment','Top','Color',axiscolor);
end

for m = 1:(xdims*ydims)
	set(hA2(m),'Box','off',...
             'Visible','off',...
             'XLim',timeWindow,...
             'YLim',ylimits,...
             'XColor',axiscolor,...
             'YColor',axiscolor);
end


if gridcolor == 1
   if strcmpi(measure,'AP')
      for n = 1:NumPoints
         if DATA(n,1) == 1
            datacolor = cmap(2,:);
         elseif DATA(n,1) == 0
            datacolor = cmap(1,:);
         end
         set(hP(n),'Color',datacolor);
      end
   else
      I = (0:(climits(2)/63):climits(2))';
      cmap = [I jet(64)];
      for n = 1:NumPoints
         value = DATA(n,1);
         if value <= 0
            datacolor = cmap(1,2:4);
         elseif value >= climits(2)
            datacolor = cmap(end,2:4);
         else
            c = find(cmap(:,1) > value-0.01*climits(2) & cmap(:,1) < value+0.01*climits(2),1);
            datacolor = cmap(c,2:4);
         end
         set(hP(n),'Color',datacolor);
      end
   end
else
	set(hP,'Color',plotcolor);
end

for p=1:(xdims*ydims)
	pos = get(hSP(p),'Position');
	pos(3) = pos(3)+0.004;
	%pos(4) = pos(4)+0.01;
	set(hSP(p),'Position',pos);
end

set(hF2,'Position',[578 71 1012 915]);
set(hF2,'NextPlot','add');
hT2 = annotation(hF2,'textbox','String',heading,...
					 'Units','normalized',...
					 'Position',[0.1232 0.9586 0.2 0.04],...
				     'FontWeight','bold','EdgeColor','none','Color',axiscolor,...
					 'FitBoxToText','on','FontWeight','bold','FontSize',14);

% %Add distance markers
% pos1 = get(hSP(1),'Position');
% pos2 = get(hSP(2),'Position');
% pos3 = get(hSP(1+xdims),'Position');
% 
% xbar = zeros(1,4);
% xbar(1) = pos2(1)+pos2(3)/2;
% xbar(3) = pos1(1)+pos1(3)/2;
% ybar = zeros(1,4);
% ybar(2) = pos1(2);
% ybar(4) = pos3(2)-pos1(2);
% 
% hDx = annotation('doublearrow','Units','normalized','Position',xbar,'Color',axiscolor);
% hDy = annotation('doublearrow','Units','normalized','Position',ybar,'Color',axiscolor);
% set([hDx hDy],  'LineWidth',1,...
% 				'Color',axiscolor,...
%                 'Head1Style','rectangle',...
%                 'Head2Style','rectangle',...
%                 'Head1Length',hlen,...
%                 'Head2Length',hlen,...
%                 'Head1Width',hwid,...
%                 'Head2Width',hwid);

% [hScy,hLy] = scalebar(hSP(1),100,'pA','y');
% [hScx,hLx] = scalebar(hSP(1),50,'ms','x');

hCB2 = copyobj(hCB,hF2);
set(hCB2,'Position',[0.9348 0.6348  0.0119  0.3137]);

hU2 = annotation('textbox','String',label,...
				 'Units','normalized','Position',[0.92 0.92 0.0320 0.0464],...
				 'LineWidth',0,'EdgeColor','none','FitBoxToText','on',...
				 'FontSize',14,'FontWeight','bold','Color',axiscolor);

assignin('base','hSP',hSP);
			 
end %if mp			 
			 
%Subfunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				
function f = lfind(A,a,w)
	f = find(A > a-w & A < a+w,1);
end


end

