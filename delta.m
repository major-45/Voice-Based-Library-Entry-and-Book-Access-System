function DEL = delta(coff, N)

% coff has coefficients along row. different column is different frames.

DEL=zeros(size(coff,1),size(coff,2));

if nargin==1
    N=2;
end

L=size(coff,2);

m=2*sum((1:N).^2);

for ii=1:L
    s=0;
    for n=1:N
        a=ii+n;
        b=ii-n;
        if a>L
            a=a-L;
        end
        if b<1
            b=L+b;
        end
        s=s+n*(coff(:,a)-coff(:,b));
    end
    DEL(:,ii)=s/m;
end
end

