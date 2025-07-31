function [frames] = framing(y, tf, tgap)

y=y/max(abs(y)); % normalize
y=reshape(y,[1,length(y)]);

fs=44100;

if nargin==1
    tf=25; % frame length is milisec
    tgap=10; % gap between frames
end

nf=round(tf*fs*1e-3); % number of elements
ngap=round(tgap*fs*1e-3);

TE=sum(y.^2);
aa=[]; bb=[];
frames=[];
p=1;

while p+nf-1<=length(y)
    b=y(p:(p+nf-1));
    fe=sum(b.^2);


    frames=[frames; b];

    %     aa=[aa 100*fe/TE];
    %     bb=[bb p];
    p=p+ngap;
end
% stem(bb,aa);
end