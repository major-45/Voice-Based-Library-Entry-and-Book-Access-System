function y = pre_emphasis(x, fs)

    % Default pre-emphasis coefficient
    alpha1 = 0.99;

    % Apply pre-emphasis filter: y(n) = x(n) - alpha * x(n-1)
    y = filter([1, -alpha1], 1, x);

    % Plot the pre-emphasized signal
    figure;
    plot(y, 'r');
    title('Pre-Emphasized Signal');
    xlabel('Sample Index');
    ylabel('Amplitude');

    % Play original and pre-emphasized audio
    sound(x, fs); pause(2);
    sound(y, fs); pause(2);

end
