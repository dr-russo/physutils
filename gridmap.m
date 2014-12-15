function hFigure = gridmap(filename,xdims,ydims,spacing,timeInterval)

index = struct2cell(load(filename));
time = index{1};
NumPoints = length(index)-1;
t1 = timeInterval(1);
t2 = timeInterval(2);


baselineStart = t1 - 0.05;
baselineEnd = t1-0.001;


w = 1e-9;
ibaseStart = find(time > baselineStart-w & time < baselineStart+w,1);
ibaseEnd = find(time > baselineEnd-w & time < baselineEnd+w,1);

imeasureStart = find(time > t1-w & time < t1+w,1);
imeasureEnd = find(time > t2-w & time < t2+w,1);

Q = zeros(NumPoints,1);
units = -1e12; %pA
	
for m = 2:NumPoints+1
	currentData = units*index{m};
	currentData = currentData - mean(currentData(ibaseStart:ibaseEnd));
	measureSegment = currentData(imeasureStart:imeasureEnd);
	measureTime = time(imeasureStart:imeasureEnd);
	
	Q(m-1,1) = trapz(measureTime,measureSegment);
end

maximum = max(Q); 
assignin('base','Qv',Q);
Q = reshape(Q,xdims,ydims);
Q = Q';
assignin('base','Qmat',Q);

hFigure = imagesc(Q);
hA = gca;
set(hA,'Units','normalized','CLim',[0 7]);
hB = colorbar('Position',[0.92 0.5 0.018 0.4]);
xticklabels = (2*spacing):(2*spacing):(xdims*spacing);
yticklabels = ((2*spacing)+(ydims*spacing)):-(2*spacing):0;

yticks = get(hA,'YTick');
set(hA,'YTickMode','manual','YTick',(0:2:ydims+2)-1,...
	   'XTickLabelMode','manual','XTickLabel',xticklabels,...
	   'YTickLabelMode','manual','YTickLabel',yticklabels);
hT = title(hA,'1% Power','FontSize',16,'FontWeight','bold',...
			  'Units','normalized','Position',[0.127 1.0134]);
hXL = xlabel(hA,'Distance   {\mu}m','FontSize',16,'FontWeight','bold');
hYL = ylabel(hA,'Distance   {\mu}m','FontSize',16,'FontWeight','bold');
set(hA,'FontSize',14,'FontWeight','Bold','box','off');
hTxt = annotation('textbox',[0.9094 0.9056 0.0945 0.0602]);
set(hTxt,'String','pA.s','LineWidth',0,'EdgeColor','none','FitBoxToText','on',...
         'FontSize',14,'FontWeight','bold');
end