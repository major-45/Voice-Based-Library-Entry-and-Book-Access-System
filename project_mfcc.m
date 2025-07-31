function [CC, del, deldel, PITCH, log_E] = project_mfcc(x)

% x is recorded speech
% each row of CC is for each frame, columns are the coeffs

fs = 44100;

y = pre_emphasis(x, fs);  % ✅ Fixed here

y = silence_remover(y);

frames = framing(y);

N = size(frames, 2);
K = pow2(nextpow2(N));
PITCH = zeros(size(frames,1),1);
cc = zeros(size(frames,1),13); % thirteen MFCCs per frame
log_E = zeros(size(frames,1),1);

for ii = 1:size(frames,1)
    s = frames(ii,:);
    w = hamming(N)';
    sw = s .* w;

    log_E(ii) = log10(sum(sw.^2));

    [swft, f] = my_fft(sw);
    psd = (abs(swft).^2) / N;
    M = mel_bank(f);
    cep = sum(M .* psd, 2);
    cep = log10(cep');
    cep = dct(cep);
    cc(ii,:) = cep(1:size(cc,2));

    a = abs(my_fft(s));
    [~, b] = findpeaks(a, f);
    c = b(b >= 60 & b <= 300);
    if ~isempty(c)
        PITCH(ii) = c(1);
    end
end

CC = cc(:,2:13);
del = delta(CC);
deldel = delta(del);

feature = [CC del deldel];
CC = feature;

end
