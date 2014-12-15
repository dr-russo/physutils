function [hScale,hLabel] = scalebar(hAxis,dist,units,axis,pos)
%===============================================================================
% SCALEBAR Generates a scalebar according to x or y data or both x and y data.
%
% PARAMETERS:
%	hAxis	Axis in which to draw scalebar.
%	[dist]	Distance in units of x or y data.  Defines length of scalebar.
%	{units} Units of x or y data - for label.
%	"axis"  Specify axis "x","y",or "both".
%	[pos]   Position of bar (in normalized units of axis).
%
% RETURNS:
%  [hScale]	Handles for scalebars
%  [hLabel]	Handles for text annotations
%
%===============================================================================


hFig = get(hAxis,'Parent');

%Remember original figure and axis units
initAxisUnits = get(hAxis,'Units');
initFigUnits = get(hFig,'Units');

%Set units for figure and axis to normalized
set(hFig,'Units','normalized');
set(hAxis,'Units','normalized');

fontsettings = {'FontName','Arial','FontSize',14,'FontWeight','bold'};

axisPos = get(hAxis,'Position');

scaleColor = [0 0 0];
lineWidth = 2.5;

%Argument handling
if nargin < 5
	XPos = 0.1;
	YPos = 0.1;
else
	XPos = pos(1);
	YPos = pos(2);
end


%Draw X scalebar ---------------------------------------------------------------
switch axis 
	
	case {'x','X'}
	
	xDist = dist;
	xUnits = units;
	
	xLabelStr = [num2str(xDist) ' ' xUnits];
	
	if strcmp(xUnits,'ms') || strcmp(xUnits,'um')
		xDist = xDist/1000;
	end
	
	xWidth = axisPos(3);
	xData = get(hAxis,'XLim');
	xScale = xDist*abs(xWidth/(xData(2)-xData(1)));

      
% 	APos = data2axis(hAxis,pos);
% 	XPos = APos(1);
% 	YPos = APos(2);
      
   
	hSx = annotation(		'line','Units','normalized',...
							'Tag','scalebar',...
							'Position',[XPos,YPos,xScale,0],...
							'LineWidth',lineWidth,'Color',scaleColor);

	hLx = annotation(		'textbox','Units','normalized',...
							'Tag','scalebar',...
							'String',xLabelStr,...
							fontsettings{:},...
							'HorizontalAlignment','right',...
							'LineStyle','none',...
							'FitBoxToText','on',...
							'Color',scaleColor,...
							'Margin',0);
						
	xLabelPos = get(hLx,'Position');
	xLabelPos(1) = XPos+0.05;
	xLabelPos(2) = YPos-xLabelPos(4);
	set(hLx,'Position',xLabelPos);
					   
	hScale = hSx;
	hLabel = hLx;
   
%Draw Y Scalebar----------------------------------------------------------------
	
	case {'y','Y'}
		
	yDist = dist;
	yUnits = units;
	
	
	yLabelStr = [num2str(yDist) ' ' yUnits];
	
	if strcmpi(yUnits,'nA')
		yDist = yDist*1000;
	end
	
	yHeight = axisPos(4);
	yData = get(hAxis,'YLim');
	yScale = yDist*abs(yHeight/(yData(2)-yData(1)));
	
	
	hSy = annotation(		'line','Units','normalized',...
							'Tag','scalebar',...
							'Position',[XPos,YPos,0,yScale],...
							'LineWidth',2.5,'Color',scaleColor);

	hLy = annotation(		'textbox','Units','normalized',...
							'Tag','scalebar',...
							'String',yLabelStr,...
							fontsettings{:},...
							'HorizontalAlignment','right',...
							'LineStyle','none',...
							'FitBoxToText','on',...
							'Color',scaleColor,...
							'Margin',0);
						
	yLabelPos = get(hLy,'Position');
	yLabelPos(1) = XPos-yLabelPos(3);
	yLabelPos(2) = YPos+yScale/2-yLabelPos(4)/2;
	set(hLy,'Position',yLabelPos);

               
% 	ylabelxpos = map(XPos-labeloffset,axispos(1),axispos(1)+axispos(3),0,1);
% 	ylabelypos = map(YPos+(yscale/5),axispos(2),axispos(2)+axispos(4),0,1);
% 	hLy = text('Units','normalized',...
% 				  'String',ylabelstr,...
% 				  'Position',[ylabelxpos,ylabelypos,0],...
% 				  'Rotation',90,...
% 				  'FontName',fname,'FontSize',fsize,'FontWeight',fweight,...
% 				  'Margin',0.1,'Color',scaleColor);
	

	hScale = hSy;
	hLabel = hLy;

%Draw Compound Scalebar --------------------------------------------------------	
	
case {'xy','XY','both','Both'}	
	
	%Initialize handles for total number of axes
	hScale = zeros(length(dist),1);
	hLabel = zeros(length(dist),1);
	
	xDist = dist(1);
	xUnits = units{1};
	yDist = dist(2);
	yUnits = units{2};
	
	xLabelStr = [num2str(xDist) ' ' xUnits];
	yLabelStr = [num2str(yDist) ' ' yUnits];

	xWidth = axisPos(3);
	xData = get(hAxis,'XLim');
	xScale = xDist*abs(xWidth/(xData(2)-xData(1)));
   
   
	hSx = annotation(		'line','Units','normalized',...
							'Tag','scalebar',...
							'Position',[XPos,YPos,xScale,0],...
							'LineWidth',lineWidth,'Color',scaleColor);

	hLx = annotation(		'textbox','Units','normalized',...
							'Tag','scalebar',...
							'String',xLabelStr,...
							fontsettings{:},...
							'HorizontalAlignment','center',...
							'VerticalAlignment','top',...
							'LineStyle','none',...
							'FitBoxToText','on',...
							'Color',scaleColor,...
							'Margin',0);
						
	xLabelPos = get(hLx,'Position');
	xLabelPos(1) = XPos+0.05;
	xLabelPos(2) = YPos-xLabelPos(4);
	set(hLx,'Position',xLabelPos);
	
			

	yHeight = axisPos(4);
	yData = get(hAxis,'YLim');
	yScale = yDist*abs(yHeight/(yData(2)-yData(1)));
	
	
	hSy = annotation(		'line','Units','normalized',...
							'Tag','scalebar',...
							'Position',[XPos+xScale,YPos,0,yScale],...
							'LineWidth',2.5,'Color',scaleColor);

	hLy = annotation(		'textbox','Units','normalized',...
							'Tag','scalebar',...
							'String',yLabelStr,...
							fontsettings{:},...
							'HorizontalAlignment','right',...
							'VerticalAlignment','middle',...
							'LineStyle','none',...
							'FitBoxToText','on',...
							'Color',scaleColor,...
							'Margin',0);
						
	yLabelPos = get(hLy,'Position');
	yLabelPos(1) = (XPos+xScale)-yLabelPos(3);
	yLabelPos(2) = YPos+yScale/2-yLabelPos(4)/2;
	set(hLy,'Position',yLabelPos);
	
	hScale = [hSx,hSy];
	hLabel = [hLx,hLy];
	
	
end


% set(hAxis,'Units',initAxisUnits);
% set(hFig,'Units',initFigUnits);

end




