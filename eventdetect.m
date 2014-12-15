function events = eventdetect(data,time,varargin)
%===============================================================================
% EVENTDETECT
% Simple synaptic event detection using an optimally scaled sliding template
% 
% Outputs:
%   events  Vector of event times.
%   
% Inputs:
%   data    Timeseries data vector.
%   time    Time vector for timeseries data, or sample interval (dt) of data
% 
% MJRusso 10/2014. Based on event detection methods using a scaled template
% developed by J.Clements. See Clements & Bekkers, Biophysical Journal 1997 for
% a complete treatment of these algorithms. 
%===============================================================================

%Event detection mode
animate = 1;
event_type = 1;

%Determine timing
if length(time) == 1
    dt = time;
else
    dt = time(2)-time(1);
end

%Time parameters
minsep      = 0.02;
base        = 0.01;
rise        = 0.005;
decay       = 0.02;
tmplen      = 0.08;
step        = 0.001;

iminsep     = floor(minsep/dt);
ibase       = floor(base/dt);
irise       = floor(rise/dt);
idecay      = floor(decay/dt);
itmplen     = floor(tmplen/dt);
istep       = floor(step/dt);

%Fit parameters
thresh  = 0.1;

%Template parameters
tmp_sign    = -1;
tmp_minamp  = -10;
tmp_qsyn    = 1.5;

%Define initial template parameters
t_b1 = floor(0.2/dt);                       
t_b2 = floor(0.25/dt);                            
data = 1e12*data;                                

tmp_scale = 1;
tmp_offset = mean(data(t_b1:t_b2));                 
tmp_noise = std(data(round(0.1/dt):round(0.2/dt)));

%Generate template from initial parameters 
tmp_t = 0:dt:tmplen; 
tmp_syn = alphasyn(tmp_t,rise,decay,tmp_qsyn,base);

N = length(tmp_t);
err = 1e9;
num_events = 0;

options = optimset('Display','off');

if animate
   
    hf = figure('Color','b','Position',[200 100 900 600]);
    ha = axes(...
            'DrawMode','fast',...
        	'ActivePositionProperty','outerposition',...
            'ALim',[0 1],...
            'Box','off',...
	'CameraUpVector',[0 1 0],...
	'CameraViewAngle',[6.60861],...
	'CameraViewAngleMode','auto',...
	'CLim',[0 1],...
	'DataAspectRatio',[1 1 1],...
	'FontName','Helvetica',...
	'FontSize',16,...
	GridLineStyle = :
	Layer = bottom
	LineStyleOrder = -
	LineWidth = [0.5]
	MinorGridLineStyle = :
	NextPlot = replace
	OuterPosition = [0 0 1 1]
	PlotBoxAspectRatio = [1 1 1]
	PlotBoxAspectRatioMode = auto
	Projection = orthographic
	Position = [0.13 0.11 0.775 0.815]
	TickLength = [0.01 0.025]
	TickDir = in
	TickDirMode = auto
	TightInset = [0.0339286 0.0309524 0.00892857 0.0142857]
	Title = [174.003]
	Units = normalized
	View = [0 90]
	XColor = [0 0 0]
	XDir = normal
	XGrid = off
	XLabel = [175.003]
	XAxisLocation = bottom
	XLim = [0 1]
	XLimMode = auto
	XMinorGrid = off
	XMinorTick = off
	XScale = linear
	XTick = [ (1 by 11) double array]
	XTickLabel = [ (11 by 3) char array]
	XTickLabelMode = auto
	XTickMode = auto
	YColor = [0 0 0]
	YDir = normal
	YGrid = off
	YLabel = [176.003]
	YAxisLocation = left
	YLim = [0 1]
	YLimMode = auto
	YMinorGrid = off
	YMinorTick = off
	YScale = linear
	YTick = [ (1 by 11) double array]
	YTickLabel = [ (11 by 3) char array]
	YTickLabelMode = auto
	YTickMode = auto
	ZColor = [0 0 0]
	ZDir = normal
	ZGrid = off
	ZLabel = [177.003]
	ZLim = [0 1]
	ZLimMode = auto
	ZMinorGrid = off
	ZMinorTick = off
	ZScale = linear
	ZTick = [0 0.5 1]
	ZTickLabel = 
	ZTickLabelMode = auto
	ZTickMode = auto

	BeingDeleted = off
	ButtonDownFcn = 
	Children = []
	Clipping = on
	CreateFcn = 
	DeleteFcn = 
	BusyAction = queue
	HandleVisibility = on
	HitTest = on
	Interruptible = on
	Parent = [1]
	Selected = off
	SelectionHighlight = on
	Tag = 
	Type = axes
	UIContextMenu = []
	UserData = []
	Visible = on);
    
    
end




%================================= Main Loop ===================================
prev_event = -1;


for n = 1 : istep : N
    
	t1 = n;
	t2 = n+itmplen;

	dataseg = data(t1:t2);

    tmp_sse = sse(dataseg,tmp_syn,tmp_scale,tmp_offset);
	tmp_scale = minscale(dataseg,tmp_syn);
	tmp_offset = minoffset(dataseg,tmp_syn,tmp_scale);
	tmp_stderr = sqrt(tmp_sse/(N-1));
	tmp_detect = tmp_scale/tmp_stderr;
	
    %------------------------------ Event Detected -----------------------------
	if  (abs(tmp_detect) > thresh) && (sign(tmp_scale) == sign(tmp_sign)); 
        %If threshold exceeded and correct direction
		
        %Check separation from previous event
        if (prev_event >= 0) && (n - prev_event > iminsep)
        %Include event
        prev_event = n;  
        num_events = num_events+1;
        end
    end
    %---------------------------------------------------------------------------
     
 end %main iteration
 
 events = num_events;  
 
end %main function
			



%============================== Subfunctions ===================================

function syn = alphasyn(t,tau_on,tau_off,qsyn,ax)
%Generates an alpha synapse with delay of ax and total charge of qsyn
if isvector(t)
	syn = zeros(1,length(t));
	for u=1:length(t)
		syn(u)= (qsyn/(tau_off-tau_on))*(exp(-(t(u)-ax)/tau_off)-...
			     exp(-(t(u)-ax)/tau_on))*Hv(t(u)-ax);
	end
else
    syn = (qsyn/(tau_off-tau_on))*(exp(-(t-ax)/tau_off)-...
			     exp(-(t-ax)/tau_on))*Hv(t-ax);
end

    %Heaviside step function for alpha synapse
    function h = Hv(s)
            if s > 0
                h = 1;
            else 
                h = 0;
            end
    end
    

end

function S = sse(data,template,scale,offset)
%Sum of squared error between data and template	
	N = length(template);
	S = sum(data.^2) + scale^2*sum(template.^2) + N*offset^2-...
		2*(scale*sum(data.*template)+offset*sum(data)-scale*offset*sum(template));
end

function min = minscale(data,template)
%Minimum 	
	N = length(template);
	min = (sum(data.*template)-sum(template)*sum(data)/N)/...
		  (sum(template.^2)-sum(template)^2/N);
end

function min = minoffset(data,template,scale)

	N = length(template);
	min = (sum(data)-scale*sum(template))/N;
end

%Set up live animation of event detection
% if animate > 0
% 	fontname = 'Arial';
% 	fontsz = 14;
% 	fontwt = 'bold';
% 	
% 	hF1 = figure();
% 	assignin('base','hF1',hF1);
% 
% 	set(hF1,'Color','w','Position',[440 40 960 640]); %pixels
% 	%hSA1 = subplot(3,1,1); hold on
% 	hA1 = axes('Position',[0.076,0.75,0.57,0.22]); hold on
% 	hP1 = plot(time,data,'b');
% 	a1 = round(0.4/DT);
% 	a2 = round(0.8/DT);
% 	minimum = min(data(a1:a2));
% 	maximum = max(data(a1:a2));
% 	span = abs(maximum-minimum);
% 	set(hA1,'XLim',[time(1),time(end)],'YLim',[minimum-0.1*span,maximum+0.1*span],'Box','on');
% 	hL1 = ylabel(units);
% 	%Template
% 	%subplot(3,1,1);
% 	hP2 = plot(NaN,NaN);
% 	set(hP2,'Color','r');
% 	%Text boxes to display template fitting
% 	
% 	%hSA2 = subplot(3,1,2);
% 	%Raster of events
% 	hA2 = axes('Position',[0.076,0.45,0.57,0.22]); hold on
% 	hP3 = plot(NaN,NaN);
% 	set(hA2,'YLim',[0.8 2.2],'YTick',[]);
% 	hL2 = ylabel('Events');
% 
% 	%Threshold - detection criterion
% 	%hSA3 = subplot(3,1,3);
% 	hA3 = axes('Position',[0.076,0.15,0.57,0.22]); hold on
% 	hP4 = plot(NaN,NaN);
% 	set(hA3,'XLim',[time(1) time(end)]);
% 	hL3 = ylabel('Fit Index');
% 	hL4 = xlabel(tunits); 
% 	
% 	set([hA1,hA2,hA3],'XLim',[time(1)-DT,time(end)]);
% 	
% 	hA4 = axes('Position',[0.73, 0.45, 0.25, 0.35]); hold on
% 	set(hA4,'visible','off');
% 	hL5 = xlabel('ms');
% 	hL6 = ylabel(units);
% 	hA = [hA1,hA2,hA3,hA4];
% 	set(hA,'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt,'Box','off','TickDir','out','TickLength',[0.01 0],'LineWidth',1.5);
% 	set(hA4,'Box','on');
% 	hL = [hL1,hL2,hL3,hL4,hL5,hL6];
% 	set(hL,'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt);
% 	
% 	hB1 = annotation('textbox','String',{},'Position', [0.72,0.94,0.2,0.05],'LineStyle','none','FitBoxToText','on');
% 	hB2 = annotation('textbox','String',{},'Position', [0.72,0.9,0.2,0.05],'LineStyle','none','FitBoxToText','on');
% 	hB3 = annotation('textbox','String',{},'Position', [0.72,0.86,0.2,0.05],'LineStyle','none','FitBoxToText','on');
% 	hB4 = annotation('textbox','String',{},'Position', [0.72,0.82,0.2,0.05],'LineStyle','none','FitBoxToText','on');
% 
% 	hB = [hB1,hB2,hB3,hB4];
% 	set(hB,'FontName',fontname,'FontSize',fontsz,'FontWeight',fontwt);
% end

% function T = template(t,RISE,DECAY)
% 	if t <= 0
% 		T = 0;
% 	else
% 		T = (1-exp(-t/RISE)).*exp(-t/DECAY);
% 	end
% end

% function L = linfind(data,start,target,dir)
% 	w = 0.01;
% 	k = start;
% 	while data(k) ~= target
% 		if abs(data(k)-target) <= w
% 			break;
% 		end
% 		k = k+dir;
% 	end
% 	L = k;
%
%

