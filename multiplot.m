function fHandle = multiplot(filename,events,xlimits,ylimits,header)
%MULTIPLOT Creates subplots of multiple events within a single data
%		   time series record.
%INPUTS 
%  filename: name of .mat file to plot.
%	events: number of events within time series.
%   xlimits: n x 2 matrix that defines time windows for each event,
%	   where n is number of events.  For example, a record with two
%	   events would be defined by a matrix [a,b;c,d] where a to b
%	   define the window for the 1st event and c to d define the
%	   window for the second event.
%	ylimits: n x 2 matrix that defines limits of y axis for each event.
%	header: cell array of strings that define titles for each event.
%OUTPUTS 
%	fHandle: figure handle for generated subplots

Episodes = load(filename);
Episodes = struct2cell(Episodes);
Time = Episodes{1};
NumEpisodes = length(Episodes);
deltaT = Time(2)-Time(1);

fHandle = figure();
hold on;
hS = zeros(events,1);  %subplot handles

for j = 2:2:NumEpisodes
   currentEpisode = Episodes{j};
   for i = 1:events
      baseInterval = [xlimits(i,1)-0.05, xlimits(i,1)];
      currentEpisode = baseline(currentEpisode,baseInterval,deltaT);
      hS(i) = subplot(1,events,i);
      hold on;
      plot(Time,1000.*currentEpisode);
      set(hS(i),'XLim',xlimits(i,:),'YLim',ylimits(i,:));
      title(header{i},'FontWeight','bold','FontSize',16,'FontName','Arial','Units','normalized');
      xlabel('ms','FontWeight','bold','FontSize',16,'FontName','Arial','Units','normalized');
      ylabel('mV','FontWeight','bold','FontSize',16,'FontName','Arial','Units','normalized');
   end
   
end


set(fHandle,'Position',[380 225 870 460],'PaperPositionMode','auto','Units','normalized');
for k = 1:events
   set(hS(k),'Units','normalized',...
      'Layer','top',...
		'Box','off',...
		'TickDir','out',...
		'TickLength',[0.01 0.01],...
		'FontName','Arial',...
		'FontSize',16,...
		'FontUnits','Points',...
		'FontWeight','normal',...
		'FontAngle','normal',...
		'LineWidth',1.5,...
		'XTickMode','manual',...
		'XTick',[xlimits(k,1) xlimits(k,2)],...
		'XTickLabelMode','manual',...
		'XTickLabel',[0,1000*(xlimits(k,2)-xlimits(k,1))]);
end

ctrlColor = [0.3922,0,0.5882];
expColor = [0 220/255 0];

for m = 1:events
   hP = get(hS(m),'Children');
   set(hP(end),'Color',ctrlColor);
   set(hP(end-1),'Color',expColor);
end

end

   



