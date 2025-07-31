function z = silence_remover(y, nf)
fs=44100;

if nargin==1
    nf=4096;
end
n=0:(length(y)-1);
y=reshape(y,[1,length(y)]);
% frame=nf/fs; % frame length in time
frame=y*y';

frame=frame*nf/length(y);

TE=sum(y.^2);
z=[];
p=1;
eng=[];
k=[];
while p+nf-1<=length(y)
    b=y(p:p+nf-1);
    pe=sum(b.^2);
    if pe>=frame
        z=[z b];
    end
    p=p+nf;
end


end

