function M = mel_bank(f,N)
% f=frequency vector
% N=number of filters
% L=length of bank
fs=44100;
if nargin==1
    N=26;
end

L=length(f);
nfft=(L-1)*2;

MEL=@(f) 1125*log(1+f/700);
IMEL=@(m) 700*(exp(m/1125)-1);

f1=50;
f2=7000;
m1=MEL(f1);
m2=MEL(f2);

mel_bins=linspace(m1,m2,N+2);
bins=IMEL(mel_bins);

% indices=floor((nfft+1)*bins/fs)+1;
indices=round(1+(L-1)*2/fs*bins);

M=zeros(N, L);
for ii=1:N
    len=indices(ii+2)-indices(ii)+1;
    T=triang(len); T=T'; T=T/max(T);
    M(ii, indices(ii):indices(ii+2))=T;
end

end