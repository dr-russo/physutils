function I = vclampiv(time,data,base,meas)

dt = time(2)-time(1);
N = length(data);
I = zeros(N,1);
units = 1e12;
b1 = round(base(1)/dt);
b2 = round(base(2)/dt);
m1 = round(meas(1)/dt);
m2 = round(meas(2)/dt);


for n=1:N
	currenttrace = units*data{n};
	baseline = mean(currenttrace(b1:b2));
	currenttrace = currenttrace-baseline;
	I(n) = mean(currenttrace(m1:m2));
end

end

