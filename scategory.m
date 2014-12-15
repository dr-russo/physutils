function hF = scategory(cat,varargin)
%SCATEGORY	Scatter plots organized into categorical columns.


%Argument handling:

cat = {cat};

for n = 1:(nargin-1)
	if iscell(varargin{n})
		cnames = varargin{n};
		break;
	else
		cat{n+1} = varargin{n};
	end
end

%Generate plot:
hF = figure();
set(hF,'Position',[700 200 600 450]);
for m=1:length(cat)
	x = m*ones(length(cat{m}),1);
	hP(m) = plot(x,cat{m},'o'); hold on
	hM(m) = plot(m,mean(cat{m}),'o');
	hE(m) = errorbar(m,mean(cat{m}),std(cat{m})/sqrt(length(cat{m})),'.');
end

%Plot properties:
hA = gca;
pointStyle = {'MarkerFaceColor','w','MarkerEdgeColor','b','MarkerSize',6};
meanStyle = {'MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',10};
errorStyle = {'LineWidth',1,'Color','b'};
axisStyle = {'LineWidth',1.5,...
	         'Color','w',...
			 'TickDir','out',...
			 'TickLength',[0.01 0.01],...
			 'XTick',(1:length(cat)),...
			 'Box','off',...
			 'FontName','Helvetica',...
			 'FontSize',16,...
			 'FontWeight','bold'};

set(hA,axisStyle{:});
set(hP,pointStyle{:});		
set(hM,meanStyle{:});
set(hE,errorStyle{:});
w = 0.1; %Errorbar halfwidth
for r=1:length(hE)
 	hC = get(hE(r),'Children');
 	xE = get(hC(2),'XData');
	xE([4 7]) = xE([1 2])-w;
	xE([5 8]) = xE([1 2])+w;
	set(hC(2),'XData',xE);
end
 		 
if exist('cnames','var')
	set(hA,'XTickLabel',cnames);
end
			 

end