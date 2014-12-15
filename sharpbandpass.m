function filtdata = sharpbandpass(data,fs,fcLow,fcHigh)
% SHARPBANDPASS  
%
% Inputs:
%     data      Time-series data vector
%     fs        Sample rate of data (Hz)
%     fcLow     Low-frequency cutoff (Hz)
%     fcHigh    High-frequency cutoff (Hz)
%     
% Outputs:
%     filtdata  Filtered data vector.
%       
%===============================================================================

if ~iscell(data)
    data = {data};
end

for q=1:length(data)

    [m,n] = size(data{q});

    if m == 1 
        data{q} = data{q}';
        N = n;
    else
        N = m;
    end

    fdLow = round(n*fcLow / fs);
    fdHigh = round(n*fcHigh / fs);

    if fcLow == 0, fdLow = -1; end

    fdData = fft(data{q});

    nullfreq = [1:fdLow+1, (fdHigh+1):(N-fdHigh+1), (N-fdLow+1):n];
    fdData(nullfreq,:) = zeros(size(nullfreq));

    dataOut = real(ifft(fdData));

    %Return data in same format as input
    if m == 1
        filtdata{q,1} = dataOut';
    else
        filtdata{q,1} = dataOut;
    end

end

end