function [tau,nr] = epsptau(time,data,window,showfit)

dt = time(2)-time(1);
t1 = round(window(1)/dt);
t2 = round(window(2)/dt);
b1 = round((window(1)-0.04)/dt);
b2 = t1;

LData = log(abs(data - mean(data(b1:b2))));
DSeg = LData(t1:t2);
TSeg = time(t1:t2);

[peak,imax] = max(DSeg);

a = peak - abs(0.025*peak);
b = peak - abs(0.5*peak);
c = peak - abs(0.75*peak);
 
f1 = imax+linfind(DSeg(imax:end),a,0.01);
f2 = imax+linfind(DSeg(imax:end),b,0.01);
f3 = imax+linfind(DSeg(imax:end),c,0.01);
if f3 > length(DSeg)
	f3 = length(DSeg);
end
if f2 > length(DSeg)
	f2 = length(DSeg);
end

hF = figure();
hold on;

F = zeros(200,3);

NR = 5;
r1 = f1;
r2 = f2;
dxS = 0;
dxE = round(0.002/dt);
q = 1;
fitLen = 0.05/dt;
while (NR > 1.5) && (fitLen > (0.020/dt))
	[f,s] = polyfit(TSeg(r1:r2),DSeg(r1:r2),1);
	F(q,1:2) = f;
	F(q,3) = s.normr;
	NR = s.normr;
	r1 = r1+dxS;
	r2 = r2-dxE;
	fitLen = r2-r1;
	q = q+1;
end

FFits = F(F(:,1)~= 0,:);
[nr,nbest] = min(FFits(:,3));
FBest = FFits(nbest,1:2);
tau = -1/FBest(1);

%Optionally plot data segment and linear fit
if showfit == 1
	try
	plot(TSeg(imax:f3),DSeg(imax:f3));

	plot(TSeg(f1:f2),FBest(1)*TSeg(f1:f2)+FBest(2),'r');

	set(gca,'XLim',[TSeg(imax),TSeg(f3)],...
		'YLim',[min(DSeg(imax:f3)),max(DSeg(imax:f3))]);

	h = plot([TSeg(r1);TSeg(r2)],[DSeg(r1),DSeg(r2)]);
	set(h,'LineStyle','none','Marker','o','MarkerFaceColor','r',...
						'MarkerEdgeColor','r','MarkerSize',6);
	pause(0.4);
	catch
	end
end




function y = linfind(data,target,tolerance)
	for y = 1:length(data) 
		if (data(y) < target+tolerance) && (data(y) > target-tolerance)
			break;
		end
	end		
end

end
