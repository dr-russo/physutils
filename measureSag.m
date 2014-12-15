function [ result ] = measureSag(data, first_trace, last_trace)
%measureSag Measures the voltage sag parameters for each trace in a
%current-clamp IV.  Returns the Vsag, Vsteady, difference Vsag-Vsteady, and
%ratio of Vsag/Vsteady for each episode in the data series.  Use
%traces2matrix() first to properly format the data for input.

if first_trace < last_trace
    nTraces = (last_trace - first_trace)+1;
end

timing = data(1,:);
dt = (timing(2) - timing(1))*1000; %milliseconds
result = zeros(nTraces,5);

sag_start = 500/dt; %milliseconds
sag_end = 600/dt;
steady_start = 1400/dt;
steady_end = 1500/dt;
baseline_start = 450/dt;
baseline_end = 499/dt;

n = 1;
for m = (first_trace+1):(last_trace+1)
    
    currentTrace = data(m,:);
    
    M = minValue(currentTrace,sag_start,sag_end);
    window_start = (sag_start + M(1,2))-2/dt;
    window_end = (sag_start + M(1,2))+2/dt;
    
    result(n,1) = 1000*segmentAverage(currentTrace,window_start,window_end); 
    result(n,2) = 1000*segmentAverage(currentTrace,steady_start,steady_end);
    result(n,3) = -1*(result(n,1) - result(n,2));
    result(n,4) = result(n,1)/result(n,2);
    result(n,5) = 1000*segmentAverage(currentTrace,baseline_start,baseline_end);
    n = n+1;
end

