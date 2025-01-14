function [audioOut, delayBuffer, writeIndex] = chorus(audioIn, delayBuffer, writeIndex, delayTime, modDepth, modRate)
    global g_fs g_audioLevel;

    bufferSize = length(delayBuffer);
    
    t = (0:length(audioIn)-1)' / g_fs;
    modSignal = modDepth * sin(2 * pi * modRate * t);
    delaySamples = round((delayTime + modSignal) * g_fs);
    
    audioOut = zeros(size(audioIn));
    
    for n = 1:length(audioIn)
        readIndex = mod(writeIndex - delaySamples(n), bufferSize) + 1;
        
        audioOut(n) = audioIn(n) + (g_audioLevel * 0.2 * delayBuffer(readIndex)) + delayBuffer(readIndex);
        
        delayBuffer(writeIndex) = audioIn(n) * (g_audioLevel * 0.3);
        writeIndex = mod(writeIndex, bufferSize) + 1;
    end
end