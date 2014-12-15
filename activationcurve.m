function hF = activationcurve(inputs,responses,calibration)
%ACTIVATIONCURVE Generate an activation curve of neuron response vs. inputs
%
%INPUTS 
%RESPONSES
%CALIBRATION Matrix that relates inputs (e.g. voltages) to actual power

normResponses = responses/responses(end);
normyunits = 'norm.';
yunits = 'EPSC (pA)';

font = 'Helvetica';
fweight = 'normal';
aweight = 'bold';
fsize = 22;

if nargin == 3
	for n = 1:length(inputs)
		P(n) = find(calibration(:,1) == inputs(n));
	end
	inputs = calibration(P,2)/1000;
	xunits = 'Power (mW)';
else
	xunits = 'Voltage (V)';
end
assignin('base','inputscal',inputs);
hF = figure;
hold on;
set(hF,'Color','k');
[hA,hP1,hP2] = plotyy(inputs,responses,inputs,normResponses);
set(hP1,'Marker','o','LineStyle','none','MarkerFaceColor','w',...
        'MarkerEdgeColor','w','MarkerSize',10);
set(hP2,'Marker','none','LineStyle','none','Color','w');
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

fitfcn = 'exp';
switch fitfcn
   case {'exp'}
      dfit = fit(inputs,responses,'exp2');
      fity = feval(dfit,fitx);
   case {'sig'}
      sigfunc = @(A, x)(A(1)+(A(2)./ (1 + exp((A(3)-x)/A(4)))));
      A0 = [0,maxResponse,0,1];
      Afit = nlinfit(inputs, responses, sigfunc, A0);  
      fity = feval(sigfunc,Afit,fitx);
      assignin('base','Afit',Afit);
end

hPF = plot(hA(1),fitx,fity);
set(hPF,'LineStyle','--','Marker','none','Color','w','LineWidth',1.5);

xlabel(xunits,'FontName',font,'FontSize',fsize,'FontWeight',fweight);
ylabel(hA(1),yunits,'FontName',font,'FontSize',fsize,'FontWeight',fweight);
ylabel(hA(2),normyunits,'FontName',font,'FontSize',fsize,'FontWeight',fweight);

end


