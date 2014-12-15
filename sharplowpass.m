function fdata = sharplowpass(data,fs,fc)
%SHARPLOWPASS Sharp low-pass filter implemented via FFT.
%
%DATA	1D Timeseries data.
%FS     Sample rate (sample interval)^-1
%FC     Cutoff frequency, in kHz.

fc = fc*1000;
N = length(data);
df = fs/N;
d = round(fc*df);

fftdata = fft(data);
fftdata(d:(N-d))=0;
fdata = real(ifft(fftdata));


end

