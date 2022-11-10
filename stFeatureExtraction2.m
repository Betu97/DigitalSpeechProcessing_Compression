function Features = stFeatureExtraction2(signal, fs, win, step,featureShort)

% function Features = stFeatureExtraction2(signal, fs, win, step,featureShort)
%
% This function computes basic audio feature sequencies for an audio
% signal, on a short-term basis.
%
% ARGUMENTS:
%  - signal:    the audio signal
%  - fs:        the sampling frequency
%  - win:       short-term window size (in seconds)
%  - step:      short-term step (in seconds)
% - featureShort: list (cell array) of short term features, within {'ZCR',
%                       'energy','enEntropy','specCentroid','specSpread',
%                       'specEntropy','specFlux','specRolloff','mfcc',
%                       'harmRatio','f0','chromaVec'}
% RETURNS:
%  - Features: a [MxN] matrix, where M is the number of features and N is
%  the total number of short-term windows. Each line of the matrix
%  corresponds to a seperate feature sequence
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

% if STEREO ...
if (min(size(signal))>1)
    signal = (sum(signal,2)/2); % convert to MONO
end

% convert window length and step from seconds to samples:
windowLength = round(win * fs);
step = round(step * fs);

curPos = 1;
L = length(signal);

% compute the total number of frames:
numOfFrames = floor((L-windowLength)/step) + 1;
% number of features to be computed:
numOfFeatures = 35;
Features = zeros(numOfFeatures, numOfFrames);
Ham = window(@hamming, windowLength);
%mfccParams = feature_mfccs_init(windowLength, fs);
for i=1:numOfFrames % for each frame
    % get current frame:
    frame  = signal(curPos:curPos+windowLength-1);
    frame  = frame .* Ham;
    frameFFT = getDFT(frame, fs);
    
    if (sum(abs(frame))>eps)
        % compute time-domain features:
        n = 1;
        if ~isempty(classindex('ZCR',featureShort))
            Features(n,i) = feature_zcr(frame);
            n = n + 1;
        end
        if ~isempty(classindex('energy',featureShort))
            Features(n,i) = feature_energy(frame);
            n = n + 1;
        end
    else
        Features(:,i) = zeros(numOfFeatures, 1);
    end    
    curPos = curPos + step;
    frameFFTPrev = frameFFT;
end
%Features(35, :) = medfilt1(Features(35, :), 3);
Features = Features(1:(n-1),:);