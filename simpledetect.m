function [peakIndex,peakLoc] = simpledetect(time,data,threshold)

%===============================================================================
%===============================================================================


dt = time(2)-time(1);               %Sample interval
tMinSep = 0.0025;                   %Minimum time separating events
iMinSep = floor(0.0025/dt);         %Minimum indices separating events
tBaseline = 0.2;                    %Baseline length (s)
iBaseline = floor(0.2/dt);          %Baseline length (indices)

Noise = std(data(1:iBaseline));     %Noise estimate, standard deviation

Th = threshold*Noise;               %Calculate threshold as multiple of S.D.

peakIndex = zeros(size(data));


for n=1:iMinSep:(length(data)-iMinSep);
        
    [peak,loc] = max(data(n:(n+iMinSep)));

    if peak >= Th
        if peak >= 50*Th
            %artifact
            continue;
        else
           peakIndex(n+loc) = 1;
        end
    end    
    
end

peakLoc = find(peakIndex == 1);


end