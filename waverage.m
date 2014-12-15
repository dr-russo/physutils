function [ wAvg ] = waverage(data,waveforms)
%waverage  Calculate average of multiple repetitions/trials for each
%		   waveform.

if ischar(data)
	loadphys(data);
elseif iscell(data)

nTraces = length(data); %Number traces
nEps = floor(nTraces/waveforms);

	if nTraces <= waveforms
		wAvg = data;
	else
		wAvg = cell(waveforms,1);
		for m = 1:waveforms
			p=1;
			runSum = data{m};
			for n = 1:nEps
				if (m+n*waveforms) <= nTraces
				
					runSum = runSum + data{m+n*waveforms};
					p=p+1;
				end
			end
			wAvg(m,1) = {runSum/p};
		end

	end %if nTraces <= waveforms

end %isstring(data)

end %waverage


    
    
    
