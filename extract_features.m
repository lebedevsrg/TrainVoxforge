%% computePitchMFCC


function [pitch1, mfcc1, flen] = extract_features(x,fs)


pwrThreshold = -50; % Frames with power below this threshold (in dB) are likely to be silence
freqThreshold = 1000; % Frames with zero crossing rate above this threshold (in Hz) are likely to be silence or unvoiced speech

% Audio data will be divided into frames of 30 ms with 75% overlap
frameTime = 30e-3;
samplesPerFrame = floor(frameTime*fs);
startIdx = 1;
stopIdx = samplesPerFrame;
increment = floor(0.25*samplesPerFrame);
overlapLength = samplesPerFrame - increment;

[pitch1,~] = pitch(x,fs,  'WindowLength',samplesPerFrame, 'OverlapLength',overlapLength);

mfcc1 = mfcc(x,fs,'WindowLength',samplesPerFrame,  'OverlapLength',overlapLength, 'LogEnergy', 'Replace');
numFrames = length(pitch1);
voicing = zeros(numFrames,1);

    for i = 1: numFrames        
        xFrame = x(startIdx:stopIdx,1); % 30ms 
        if audiopluginexample.SpeechPitchDetector.isVoicedSpeech(xFrame,fs,pwrThreshold,freqThreshold)
            voicing(i) = 1;
        end
        startIdx = startIdx + increment;
        stopIdx = stopIdx + increment;    
    end
    
% pitch1(voicing == 0) = nan;
% pitch1 = rmmissing(pitch1);  
% mfcc1(voicing == 0,:) = nan;
% mfcc1 = rmmissing(mfcc1);  

mfcc1;
flen = numel(pitch1);

end
                