function hF = qsubplot(data,episodes,dims,xlims,units,headers,axison,ptype,colormode)
%QSUBPLOT	Subplots of time series data.
%
%HF = qsubplot(DATA,EPISODES,DIMS,XLIMS,UNITS,HEADERS,AXISON,TYPE,COLORMODE)
%
%DATA	Data file, first vector is time
%EPISODES	Episodes to plot
%DIMS		Dimensions of subplot (rows x cols)
%XLIMS		X(time) limits of plot
%UNITS		Data units, pA/pa/i/I for current, mV/mv/v/V for voltage
%HEADERS	Title for plots
%AXISON		Axis on(1) or off(0)
%PTYPE		Normal, plot episodes(0)
%			Plot episodes & mean of episodes(1)
%			Plot episodes & mean for baseline and for responses(2)
%COLORMODE  black background(0) or white background(1)

%Argument check
if nargin == 1
   if isstruct(data)
      DATA = data.FILE;
      episodes = data.EPS;
      dims = data.DIMS;
      xlims = data.XLIMS;
      units = data.UNITS;
      headers = data.HEADER;
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
      headers = {''};
   end
end


if colormode == 0
   figbg = [0 0 0];
   acolor = [1 1 1];
elseif colormode == 1;
   figbg = [1 1 1];
   acolor = [0 0 0];
end
	
nplots = dims(1)*dims(2);
if nargin < 9
	colormode = 1;
end
if nargin < 8
	ptype = 0;
end
if nargin < 7
	axison = 1;
end
if nargin < 6
	headers{1:nplots} = {''};
end

hF = figure();
set(hF,'Color',figbg);
hold on

for s = 1:(dims(1)*dims(2))
   
   if size(DATA,1) > 1
      FILE = DATA{s};
   else
      FILE = DATA;
   end	
	
   if size(units,1) == 1
      U = units;
   else
      U = units{s};
   end
   
   if size(xlims,1) == 1
      XLIMS = xlims;
   else
      XLIMS = xlims(s,:);
   end
   
   
   hSP(s) = subplot(dims(1),dims(2),s);
   qplot(FILE,episodes,XLIMS,U,'',axison,ptype,colormode,hSP(s));
   axpos = get(hSP(s),'Position');
   annotation('textbox','String',headers{s},'Position',[axpos(1),axpos(2)+axpos(4)-0.04,0.2,0.05],...
		       'LineStyle','none','FontName','Helvetica','FontSize',22,...
			   'FontWeight','normal','FitBoxToText','on','Color',acolor);
   
end
assignin('base','hSP',hSP);

end


