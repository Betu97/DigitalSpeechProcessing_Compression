function [suv] = vunvoiced(x,fs,win) %#codegen
% [suv] = vunvoiced(x,fs,win)
%
% Voiced and unvoiced detection of speech signal x sampled at fs Hz and
% using a window size of win seconds. suvDetectorFileName is a MAT file
% that contains the Voiced/Unvoiced detection model.

suvDetectorFileName = 'suvDetect.mat';
load(suvDetectorFileName);
featureShort = {'ZCR','energy'};
[features] = stFeatureExtraction2(x, fs, win, win,featureShort);
features = transpose(features);
% Energia logarítmica
features(:,2) = log(features(:,2));
suv = predict(svmModel,features);
suv = medfilt1(suv,5);
end

