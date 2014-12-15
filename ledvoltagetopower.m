function P = ledvoltagetopower(V)

	voltage = [0; 0.1; 0.2; 0.3; 0.5; 0.8; 1; 2; 3; 5; 7; 8; 9; 10];
	%20x objective power measurement (mW);
	power = [0.0000; 0.0240; 0.0738; 0.1244; 0.2228; 0.3610; 0.4476; 0.8313;...
			 1.1570; 1.7030; 2.1430; 2.3380; 2.5200; 2.6850];
	
	ft = polyfit(voltage,power,2);
	P = polyval(ft,V);
end
		 

	