function hR = rasterplot(data,varargin)

if iscell(data)
    sp = cell2mat(data);
else
    sp = data;
end

[M,N] = size(sp);

if nargin < 3
    hF = figure();
    hA = axes(); hold all
elseif ishandle(varargin{2});
    hA = varargin{2};
end
if nargin < 2
    dt = 1;
else
    dt = varargin{1};
end

hR = cell(M,1);

SZ = 0.01;
tickColor = [1 1 1];

%Determine whether spikedata is of one of two types:
%(1) Vector of ones/zeroes, in which ones indicate position of spike
%(2) Vector of times/indices of spike locations

if all(sp(1,:) == 0 | sp(1,:) == 1) %Type 1 (Note: assumes all episodes same format
    
    for m=1:M
        idx = find(sp(m,:)==1);
        L = length(idx);
        hR{m} = zeros(1,L);
        for n=1:L
                hR{m}(n) = line([idx(n)*dt idx(n)*dt],[(M-m+1)-0.5+SZ (M-m+1)+0.5-SZ],'Parent',hA,...
                           'Color',tickColor);
        end
    end
  
elseif all(sp{1} >= 0)         %Type 2
    
    for m=1:M
        hR{m} = zeros(1,N);
        for n=1:N
            hR{m}(n) = line([sp{m}(n)*dt,sp{m}(n)*dt],[m-0.5 m+0.5],'Parent',hA,...
                       'Color',tickColor);
        end
    end
    
end

set(hA,'XLim',[0 N*dt],'YLim',[0 M+1]);

end