function hs = pstimulus(hAxis,onset,length,number,isi,style)
%=============================================================================== 
% DRAWSTIMULUS Draw line markers to indicate temporal position of 
% photostimulus. Draws either single bar or series of ticks for 
% stimulus trains.
%
%=============================================================================== 

hFig = get(hAxis,'Parent');
initAxisUnits = get(hAxis,'Units');
initFigUnits = get(hFig,'Units');
set(hFig,'Units','pixels');
set(hAxis,'Units','pixels');

axispos = get(hAxis,'Position');
width = axispos(3);
xlimits = get(hAxis,'XLim');
dataToAxisScale = abs(width/(xlimits(2)-xlimits(1)));
onset = (onset-xlimits(1))*dataToAxisScale+axispos(1);
length = (length/1000)*dataToAxisScale;

color = [0 0 255]/255; 


if nargin < 4
	XPos = onset;
    YPos = axispos(2)+axispos(4)+10;
 	hStim = annotation('line','Units','pixels',...
 						'Position',[XPos,YPos,length,0],...
						'LineWidth',5,'Color',color);
	set(hStim,'Units','normalized');

else
	XPos = onset;
	YPos = axispos(2)+axispos(4)+10;
	isi = (isi/1000)*dataToAxisScale;
	height = 6;
	width = 4;
	for n=1:number
		hStim(n) = annotation('rectangle','Units','pixels',...
			                   'Position',[XPos YPos width height],...
							   'Color',color,'FaceColor',color);
		XPos = XPos + isi;
	end
	set(hStim(:),'Units','normalized');
	
end

set(hFig,'Units',initFigUnits);
set(hAxis,'Units',initAxisUnits);

end