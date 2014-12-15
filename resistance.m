function [R,nPoints] = resistance(IData,VData)

minPoints = 4;
if  length(IData) ~= length(VData)
	fprintf(2,'Inputs must be the same length.');
	return;
end
N = length(VData);


[minP,S] = polyfit(IData(N-minPoints:N),VData(N-minPoints:N),1);
minS = S.normr;
nPoints = minPoints;

%Try to achieve better fit with additional points
for m = 1:2
	p2 = N-3+m;
	p1 = N-3-minPoints;
	
	[P,S] = polyfit(IData(p1:p2),VData(p1:p2),1);
	if S.normr < minS
		minS = S.normr;
		minP = P;
		nPoints = size(p1:p2,1);
	elseif S.normr >= minS
		continue;
	end
end
	R = minP;
end

