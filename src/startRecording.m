function startRecording(~,~)

    global g_startButton g_stopButton g_exitButton;

    global g_isRunning g_dataPlot g_fs g_frameLength;

    global g_buttonsToggle g_audioLevel;

    g_startButton.Enable = 'off';
    g_stopButton.Enable = 'on';
    g_exitButton.Enable = 'off';

    drawnow;

    %, 'Device', 'CABLE Input (VB-Audio Virtual Cable)'

    audioReader = audioDeviceReader('SampleRate', g_fs, 'SamplesPerFrame', g_frameLength);
    audioWriter = audioDeviceWriter('SampleRate', g_fs);
    reverb = reverberator('SampleRate', g_fs);

    delayTime = 0.1;
    modDepth = 0.005;
    modRate = 1.5;

    maxDelay = delayTime + modDepth;
    bufferSize = round(maxDelay * g_fs);
    chorusBuffer = zeros(bufferSize, 1);
    writeIndex = 1;

    g_isRunning = true;

    while g_isRunning
        audioIn = audioReader();

        audioOut = audioIn * g_audioLevel;

        if g_buttonsToggle('pogłos')
            audioOut = reverb(audioOut);
        end
        
        if g_buttonsToggle('zmianę tonu')
            audioOut = tonePitch(audioOut);
        end

        if g_buttonsToggle('Equalizer')
            audioOut = filterAudio(audioOut);
        end

        if g_buttonsToggle('wykres')
            toPlot = audioOut;
            if size(toPlot, 2) == 2
                toPlot = mean(toPlot, 2);
            end
            g_dataPlot.YData = toPlot;
        end

        if g_buttonsToggle('chorus')
            [audioOut, chorusBuffer, writeIndex] = chorus(audioOut, ...
                chorusBuffer, writeIndex, delayTime, modDepth, modRate);
        end

        audioWriter(audioOut);

        drawnow;
    end

    release(audioReader);
    release(audioWriter);
    g_startButton.Enable = 'on';
    g_stopButton.Enable = 'off';
    g_exitButton.Enable = 'on';
end