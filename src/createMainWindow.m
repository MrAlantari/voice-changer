function createMainWindow

    global g_mainWindow g_startButton g_stopButton g_exitButton ...
        g_reverbButton g_tonePitchButton g_plotButton ...
        g_equalizerButton ...
        g_amplitudeAxes  ...
        g_pitchSlider g_highSlider g_midSlider g_lowSlider;

    global g_isRunning g_isReverbOn g_isTonePitchOn g_isPlotOn ...
        g_isEqualizerOn ...
        g_semitones lowGain midGain highGain;

    lowGain = 1;
    midGain = 1;
    highGain = 1;

    g_isReverbOn = false;
    g_isTonePitchOn = false;
    g_isEqualizerOn = false;
    g_semitones = 0;

    g_mainWindow = uifigure('Name', 'Voice Changer', 'Position', [100 100 1300 320], 'Resize', 'off');

    g_tonePitchButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz zmianę tonu', ...
        'Position', [50, 250, 200, 40], 'ValueChangedFcn', @(src, ~)toggleTonePitch(src));

    g_pitchSlider = uislider(g_mainWindow, 'Position', [300, 280, 250, 3], ...
        'Limits', [-10, 10], 'Value', 0, 'MajorTicks', -10:2:10, 'MinorTicks', -10:1:10, ...
        'ValueChangedFcn', @(src, ~)setSemitones(src));

    g_reverbButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz pogłos', ...
        'Position', [50, 200, 200, 40], 'ValueChangedFcn', @(src, ~)toggleReverb(src));

    g_plotButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz wykres', ...
    'Position', [50, 130, 200, 40], 'ValueChangedFcn', @(src, ~)tooglePlot(src));

    g_startButton = uibutton(g_mainWindow, 'push', 'Text', 'Rozpocznij', ...
    'Position', [300, 80, 200, 40], 'ButtonPushedFcn', @(~, ~)startRecording());

    g_stopButton = uibutton(g_mainWindow, 'push', 'Text', 'Zatrzymaj', ...
    'Position', [50, 80, 200, 40], 'Enable', 'off', 'ButtonPushedFcn', @(~, ~)stopRecording());

    g_exitButton = uibutton(g_mainWindow, 'push', 'Text', 'Wyjdź', ...
    'Position', [50, 30, 200, 40], 'ButtonPushedFcn', @(~, ~)exitApp());

    g_amplitudeAxes = uiaxes(g_mainWindow, 'Position', [1000, 40, 260, 240]);
    xlabel(g_amplitudeAxes, 'Time');
    ylabel(g_amplitudeAxes, 'Frequency');
    xlim(g_amplitudeAxes, [0 0.025]);
    ylim(g_amplitudeAxes, [-2 2]);

    g_equalizerButton = uibutton(g_mainWindow, 'state', 'Text', 'Equalizer', ...
        'Position', [600 250 200 40], 'ValueChangedFcn', @(src, ~)toogleEqualizer(src));

    % Slider dla niskich częstotliwości
    g_lowSlider = uislider(g_mainWindow, 'Position', [600, 230, 250, 3], ...
        'Limits', [-10, 10], 'Value', 0, 'MajorTicks', -10:2:10, ...
        'MinorTicks', -10:1:10, 'ValueChangedFcn', @(src, ~)setLowGain(src));

    lowSliderLabel = uilabel(g_mainWindow, 'Text', "Niskie częstotliwości", ...
        'FontColor', 'black', 'Position', [870 200 150 60]);
    
    % Slider dla średnich częstotliwości
    g_midSlider = uislider(g_mainWindow, 'Position', [600, 190, 250, 3], ...
        'Limits', [-10, 10], 'Value', 0, 'MajorTicks', -10:2:10, ...
        'MinorTicks', -10:1:10, 'ValueChangedFcn', @(src, ~)setMidGain(src));

    lowSliderLabel = uilabel(g_mainWindow, 'Text', "Średnie częstotliwości", ...
        'FontColor', 'black', 'Position', [870 160 150 60]);
    
    % Slider dla wysokich częstotliwości
    g_highSlider = uislider(g_mainWindow, 'Position', [600, 150, 250, 3], ...
        'Limits', [-10, 10], 'Value', 0, 'MajorTicks', -10:2:10, ...
        'MinorTicks', -10:1:10, 'ValueChangedFcn', @(src, ~)setHighGain(src));

    lowSliderLabel = uilabel(g_mainWindow, 'Text', "Wysokie częstotliwości", ...
        'FontColor', 'black', 'Position', [870 120 150 60]);




    function exitApp(~,~)
        delete(g_mainWindow);
    end



    function stopRecording(~,~)
        g_isRunning = false;
    end


    function startRecording(~,~)
        g_startButton.Enable = 'off';
        g_stopButton.Enable = 'on';
        g_exitButton.Enable = 'off';

        fs = 44100;
        frameLength = 1024;

        t = (0:frameLength - 1) / fs;

        dataPlot = plot(g_amplitudeAxes, t, zeros(size(t)));

        [lowPass, bandPass, highPass] = designFilters(fs);

        drawnow;

        %, 'Device', 'CABLE Input (VB-Audio Virtual Cable)'

        audioReader = audioDeviceReader('SampleRate', fs, 'SamplesPerFrame', frameLength);
        audioWriter = audioDeviceWriter('SampleRate', fs);
        reverb = reverberator('SampleRate',fs);
    
        g_isRunning = true;
    
        while g_isRunning
            audioIn = audioReader();

            audioOut = audioIn;

            if g_isEqualizerOn
                audioOut = filterAudio(audioOut, lowPass, bandPass, highPass);
            end

            if g_isReverbOn
                audioOut = reverb(audioOut);
            end
            
            if g_isTonePitchOn
                audioOut = tonePitch(audioOut);
            end

            if g_isPlotOn
                toPlot = audioOut;
                if size(toPlot, 2) == 2
                    toPlot = mean(toPlot, 2);
                end
                dataPlot.YData = toPlot;
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


    function toggleTonePitch(src)

        g_isTonePitchOn = src.Value;
        if g_isTonePitchOn
            src.Text = 'Wyłącz zmianę tonu';
        else
            src.Text = 'Włącz zmianę tonu';
        end
    end



    function audioOut = tonePitch(audioOut)
        % Okno i przesunięcie
        win = kbdwin(512);
        overlapLength = 0.75 * numel(win);
        
        % Przetwarzanie STFT i przesunięcie tonu
        S = stft(audioOut, "Window", win, "OverlapLength", overlapLength, "Centered", false);
        audioOut = shiftPitch(S, g_semitones, "Window", win, "OverlapLength", overlapLength, "LockPhase", false);

        audioOut = audioOut * 10;
        audioOut = max(min(audioOut, 1), -1);
    end



    function setSemitones(src)
        g_semitones = round(src.Value);
    end



    function toggleReverb(src)
        g_isReverbOn = src.Value;
        if g_isReverbOn
            src.Text = 'Wyłącz pogłos';
        else
            src.Text = 'Włącz pogłos';
        end
    end


    function tooglePlot(src)
        g_isPlotOn = src.Value;
        if g_isPlotOn
            src.Text = 'Wyłącz wykres';
        else
            src.Text = 'Włącz wykres';
        end
    end

    function toogleEqualizer(src)
        g_isEqualizerOn = src.Value;
        if g_isEqualizerOn
            src.Text = 'Wyłącz Equalizer';
        else
            src.Text = 'Włącz Equalizer';
        end
    end

    function setLowGain(slider)
        lowGain = 10^(slider.Value / 20); % Przelicz na skalę liniową (dB na liniowe)
    end
    
    function setMidGain(slider)
        midGain = 10^(slider.Value / 20);
    end
    
    function setHighGain(slider)
        highGain = 10^(slider.Value / 20);
    end


    function [lowPass, bandPass, highPass] = designFilters(fs)

        % Filtr dolnoprzepustowy (niskie częstotliwości)
        lowPass = designfilt('lowpassiir', 'FilterOrder', 4, ...
            'HalfPowerFrequency', 200, 'SampleRate', fs);
        
        % Filtr środkowoprzepustowy (średnie częstotliwości)
        bandPass = designfilt('bandpassiir', 'FilterOrder', 4, ...
            'HalfPowerFrequency1', 200, 'HalfPowerFrequency2', 3000, 'SampleRate', fs);
        
        % Filtr górnoprzepustowy (wysokie częstotliwości)
        highPass = designfilt('highpassiir', 'FilterOrder', 4, ...
            'HalfPowerFrequency', 3000, 'SampleRate', fs);

    end


    function audioOut = filterAudio(audioIn, lowPass, bandPass, highPass)
        % Przetwarzanie pasmowe
        lowBand = lowGain * filtfilt(lowPass, audioIn);
        midBand = midGain * filtfilt(bandPass, audioIn);
        highBand = highGain * filtfilt(highPass, audioIn);
    
        % Sumowanie pasm
        audioOut = lowBand + midBand + highBand;
    end

end