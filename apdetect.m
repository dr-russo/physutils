function events = apdetect(data,time)
%===============================================================================
% APDETECT  
% Simple action potential detection and preliminary classification through best-
% fit of a scaling template to data.
%
% INPUTS:  
% time       Time vector (alternatively, scalar value of sample interval)
% data       Time-series data.
% 
% OUTPUTS:
% events     Vector, event locations within data vector
% 
%
% MJRusso (9/2014) Based upon template-fitting event detection by J.Clements.
%===============================================================================

%NOTE: i-prefixes indicate a data vector index, while t-prefixes indicate an
%explicit time reference, in seconds.

dt = time(2)-time(1);                  %Sample interval


%Default parameters
tTmpLen      = 3e-3;                   %Length of template, seconds
tBase        = 1e-3;                   %Baseline of template
iMinSep      = floor(0.002/dt)+1;      %Minimum separation between events
MinAmp       = 1e-4;                   %Minimum amplitude for event,V
tTauOff      = 1e-3;                   %Decay time constant of AP
                                       %Multiples of Scale/SE for
tTime = 0:dt:tTmpLen;                  %Template time vector


%Define initial template parameters [scale*template + offset]
scale = 1e-4;
scaleOut = ones(size(data));
offset = median(data);
Thresh = 2*std(data(1:floor(0.2/dt))); %Noise


%Construct template function [derivative of filtered exponential] (See subfunction)
TmpFcn = template(tTime,tBase,tTauOff);

%Apply filter for near-instantaneous rise time
TmpFcn = gaussfilter(TmpFcn,1/dt,4);

%dF/dt, then normalize
TmpFcn = diff(TmpFcn)./(diff(tTime));
TmpFcn = TmpFcn./max(TmpFcn);
figure();
plot(TmpFcn);

N = length(TmpFcn);


%Loop variables
iStart = 1;                              
iStep = round(0.001/dt);
iStop = length(time)-length(TmpFcn);

%Initialize output variables
NumEvents = 0;                      
EventIndex = zeros(size(time));%Output vector of event indices
detect = zeros(size(time));
prevEvent = 0;                      %Index of most recent event

%============================ Event Detection Sequence =========================
fprintf(1,'Detecting...\n');
for n=iStart:iStep:iStop
    
    t1 = n;
    t2 = n+(N-1);
    
    cData = data(t1:t2);
    
    sse = sumsquarederror(cData,TmpFcn,scale,offset);
    scale = minscale(cData,TmpFcn);
    scaleOut(n) = scale;
    offset = minoffset(cData,TmpFcn,scale);
    stderr = sqrt(sse/(N-1));
    detect(n) = scale/stderr;
    
    if abs(detect(n)) > Thresh && scale >= MinAmp
        
        %Check separation from previous events
        if prevEvent == 0 || t1-prevEvent > iMinSep
            EventIndex(n) = 1;
            NumEvents = NumEvents + 1;
            prevEvent = n;
        else
            continue;
        end
    end
    
    
end %main detection loop

fprintf(1,'Events Detected: %d\n',NumEvents);
fprintf(1,'Detection complete.\n');


end %function
    
%=========================== Subfunctions ======================================

function f = template(time,baseline,tau)
    
    fexp = @(t) exp(-t./tau);
    
    f = zeros(size(time));
    f(time >= baseline) = feval(fexp,time((time-baseline)>=0));   
    
end

function S = sumsquarederror(data,template,scale,offset)
	
	NN = length(template);
	S = sum(data.^2) + scale^2*sum(template.^2) + NN*offset^2-...
		 2*(scale*sum(data.*template)+offset*sum(data)-scale*offset*sum(template));
end

function minimum = minscale(data,template)
	
	NN = length(template);
	minimum = (sum(data.*template)-sum(template)*sum(data)/NN)/...
		  (sum(template.^2)-sum(template)^2/NN);
end

function minimum = minoffset(data,template,scale)

	NN = length(template);
	minimum = (sum(data)-scale*sum(template))/NN;
end
