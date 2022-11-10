wavFilename = "Gravacions/Seleccionats/veu1.wav";
order = 13;
Twp = 0.1;
Tap = 0.005;
win = 0.01;
step = 0.005;

[veu, fs] = audioread(wavFilename);

[X, suv, tf] = framing (veu, fs, win);
[f0, tp] = pitch(veu, fs, 'Range', [60 250], 'WindowLength', round(Twp * fs), 'OverlapLength', (round(Twp * fs) - round(Tap * fs)), 'MedianFilterLength', order);
f0i = interp1(tp / fs, f0, tf);
f0i(find(suv == 1)) = 0;

[S, F, T] = spectrogram(veu, round(Twp * fs), round(Tap * fs), length(veu), fs);
figure('Units', 'Normalized', 'OuterPosition', [0.125 0.125 0.75 0.75]);
subplot(3,1,1);
imagesc(T, F, 20 * log10(abs(S)));
set(gca,'ydir','normal');
ylim([0 4000]);
hold on
t = linspace(0, length(veu) / fs, length(f0i));
plot(t, f0i, 'LineWidth', 2);
plot(t, suv * 1000, '--', 'Color', [0 0 0]);
title('Signal Spectrogram');
hold off

[y, LPC] = vocoder(X, order, suv, f0i, fs);

subplot(3,1,2);
title('Result Comparison');
hold on
plot((0:(length(veu.')-1))/fs,veu.'/sqrt(var(veu.'))+10, 'b');
plot((0:(length(y)-1))/fs,y/sqrt(var(y))-10, 'r');
hold off

subplot(3,1,3);
h = [];
for s= 1:length(LPC)
    h = [h, freqz(1, LPC(s,:), size(LPC,2)).'];
end
spectrogram(h);
ylim([0 4000]);
title('Singal LPC Spectrogram');
% sound(y*10, fs);
% pause(length(y) / fs);
% sound(veu.', fs);
