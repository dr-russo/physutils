function P = voltagetopower(V)

voltage = [0; 0.1; 0.2; 0.3; 0.5; 0.8; 1; 2; 3; 5; 7; 8; 9; 10];
%20x objective power measurement (uW -> mW)
power = [0.002; 24; 73.8; 124.4; 222.8; 361; 447.6; 831.3; 1157; 1703; 2143; 2338; 2520; 2685]./1000;	 
		
P = zeros(size(V));

for n=1:length(V)

	index = find(voltage == V(n),1);
		
	if ~isempty(index)
		P(n) = power(index);
	else
		pfit = polyfit(voltage,power,4);
		P(n) = polyval(pfit,V(n));
	end
end
		 

	