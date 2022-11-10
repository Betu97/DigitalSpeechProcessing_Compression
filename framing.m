function [X, suv, t] = framing (x, fs, win)

suv = vunvoiced(x, fs, win);

filtered = filter([1 -0.97], 1, x);

col = round(win * fs);

buffered = buffer (filtered, col, 0, 'nodelay');

ham_win = hamming(win * fs);

X = diag(ham_win) * buffered;

frames = ( (length(x)-(win * fs)) / (win*fs) ) + 1 ;

t = win/2:win:length(x)/fs;

end




