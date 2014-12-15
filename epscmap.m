%%
xdims = 11;
ydims = 8;
spacing = 20;
[file, path] = uigetfile();
index = struct2cell(load([path file]));
time = index{1};

NumPoints = length(index)-1;
Q = zeros(NumPoints,1);

w = 1e-6;
baseStart = find(time > 0.35-w & time < 0.35+w,1);
baseEnd = find(time > 0.399-w & time < 0.399+w,1);

measureStart = find(time > 0.40-w & time < 0.40+w,1);
measureEnd = find(time > 0.45-w & time < 0.45+w,1);
%%

units = -1e12; %pA;
for m=2:NumPoints+1
	
	currentData = units*index{m};
	currentData = currentData - mean(currentData(baseStart:baseEnd));
	measureSegment = currentData(measureStart:measureEnd);
	measureTime = time(measureStart:measureEnd);
	
 	Q(m-1,1) = max(measureSegment);

end
%%
Q = reshape(Q,11,8)';
%%
hF = imagesc(Q);
hA = gca;
hB = colorbar('Position',[0.9200 0.5000 0.0180 0.4000]);
xticklabels = (2*spacing):(2*spacing):(xdims*spacing);
yticklabels = ((2*spacing)+(ydims*spacing)):-(2*spacing):0;

yticks = get(hA,'YTick');
set(hA,'YTickMode','manual','YTick',(0:2:ydims+2)-1,...
	   'XTickLabelMode','manual','XTickLabel',xticklabels,...
	   'YTickLabelMode','manual','YTickLabel',yticklabels);
%%
hT = title(hA,'AON-to-AON EPSCs    99% power','FontSize',16,'FontWeight','bold');
hXL = xlabel(hA,'Distance   {\mu}m','FontSize',16,'FontWeight','bold');
hYL = ylabel(hA,'Distance   {\mu}m','FontSize',16,'FontWeight','bold');
%%
set(hA,'FontSize',14,'FontWeight','Bold','box','off');
%%
hTxt = annotation('textbox',[0.9094 0.9056 0.0945 0.0602]);
set(hTxt,'String','pA','LineWidth',0,'EdgeColor','none','FitBoxToText','on',...
         'FontSize',14,'FontWeight','bold');

