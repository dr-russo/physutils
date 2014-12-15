function hF = responsecurve(inputs,responses)
%RESPONSECURVE Calculates and plots an activation curve of neuron response 
%			   according to input.
%
%Parameters:
%INPUTS		Stimulus levels (voltage).	
%RESPONSES  Synaptic responses (pA/mV).
%
%Returns:
%HF			Figure handle for response curve.

normResponses = responses/responses(end);
normyunits = 'norm.';
yunits = 'EPSC (pA)';

font = 'Helvetica';
fweight = 'normal';
aweight = 'bold';
fsize = 22;

power = voltagetopower(inputs);
xunits = 'Power (mW)';

hF = figure;
hold on;
set(hF,'Color','k');
[hA,hP1,hP2] = plotyy(inputs,responses,inputs,normResponses);
set(hP1,'Marker','o',...
		'MarkerFaceColor','w',...
        'MarkerEdgeColor','w',...
		'MarkerSize',10,...
		'LineStyle','none');
set(hP2,'Marker','none',...
		'LineStyle','none',...
		'Color','w');
[maxResponse, imax] = max(responses);
set(hA(1),'YColor','w','YLim',[0 maxResponse+10]);
set(hA(2),'YColor','w','YLim',[0 normResponses(imax)+10/maxResponse],...
          'YTickMode','manual','YTick',[0,0.5,1],...
          'YTickLabelMode','manual','YTickLabel',[0 0.5 1]);
set(hA,'Color','none','XColor','w',...
       'FontName',font,...
       'FontSize',fsize,...
       'FontWeight',aweight,...
       'LineWidth',1.5,...
       'TickDir','out',...
       'TickLength',[0.01 0.01],...
       'Box','off');

xlimits = get(hA(1),'XLim');
fitx = 0:(xlimits(2)/1000):xlimits(2);
pfit = [0 maxResponse 0 1];
P = sigfit(inputs,responses,pfit);
sig = @(x)(P(1)+(P(2)./ (1 + exp((P(3)-x)./P(4)))));
fity = sig(fitx);


hPF = plot(hA(1),fitx,fity);
set(hPF,'LineStyle','--','Marker','none','Color','w','LineWidth',1.5);

xlabel(xunits,'FontName',font,'FontSize',fsize,'FontWeight',fweight);
ylabel(hA(1),yunits,'FontName',font,'FontSize',fsize,'FontWeight',fweight);
ylabel(hA(2),normyunits,'FontName',font,'FontSize',fsize,'FontWeight',fweight);

end


