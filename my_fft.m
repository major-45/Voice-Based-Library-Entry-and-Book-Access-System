function [yfinal, ffinal] = my_fft(x,fs)

if nargin==1
    fs=44100;
end

m=length(x);
nfft=pow2(nextpow2(m));

y=fft(x,nfft);
f=fs*(0:(nfft-1))/nfft;

% yshift=fftshift(y);
% fshift=(-n/2:(n/2-1))*fs/n;

ffinal=f(f>=0 & f<=fs/2);       % Right half
yfinal=y(f>=0 & f<=fs/2);

% figure; plot(f,abs(y)); title('main');
% figure; plot(fshift, abs(yshift)); title('center zero');
% figure; plot(ffinal, abs(yfinal)); title('only unique part');

end

