function createMainWindow

    global g_mainWindow g_startButton g_stopButton g_exitButton ...
        g_reverbButton g_tonePitchButton g_plotButton g_chorusButton ...
        g_equalizerButton ...
        g_amplitudeAxes  ...
        g_pitchSlider g_trebleSlider g_presenceSlider g_midrangeSlider ... 
        g_bassSlider g_subBassSlider g_voiceLevelSlider;

    global g_semitones g_isRunning g_dataPlot g_fs g_frameLength g_audioLevel;

    global g_subBassGain g_bassGain g_midrangeGain g_presenceGain g_trebleGain;

    g_audioLevel = 1;

    g_semitones = 0;
    g_fs = 44100;
    g_frameLength = 1024;

    g_mainWindow = uifigure('Name', 'Voice Changer', 'Position', [100 100 1400 330], ...
        'Resize', 'off', 'CloseRequestFcn', @(~,~) exitApp());

    g_voiceLevelSlider = uislider(g_mainWindow, 'Position', [300, 220, 150, 3], ...
        'Limits', [0, 10], 'Value', 1, 'MajorTicks', 0:2:10, 'MinorTicks', 0:1:10, ...
        'ValueChangedFcn', @(src, ~)changeVolumeLevel(src));

    voiceLevelLabel = uilabel(g_mainWindow, 'Text', "Volume multipler (0-10)", ...
        'FontColor', 'black', 'Position', [460 180 150 60]);

    g_tonePitchButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz zmianę tonu', ...
        'Position', [50, 250, 200, 40], ...
        'ValueChangedFcn', @(src, ~)toggleButtons(src, 'zmianę tonu'));

    g_pitchSlider = uislider(g_mainWindow, 'Position', [300, 280, 250, 3], ...
        'Limits', [-12, 12], 'Value', 0, 'MajorTicks', -12:2:12, 'MinorTicks', -12:1:12, ...
        'ValueChangedFcn', @(src, ~)setSemitones(src));

    g_reverbButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz pogłos', ...
        'Position', [50, 200, 200, 40], ...
        'ValueChangedFcn', @(src, ~)toggleButtons(src, 'pogłos'));

    g_plotButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz wykres', ...
        'Position', [50, 130, 200, 40], ...
        'ValueChangedFcn', @(src, ~)toggleButtons(src, 'wykres'));

    g_startButton = uibutton(g_mainWindow, 'push', 'Text', 'Rozpocznij', ...
        'Position', [300, 80, 200, 40], ...
        'ButtonPushedFcn', @(~, ~)startRecording());

    g_stopButton = uibutton(g_mainWindow, 'push', 'Text', 'Zatrzymaj', ...
        'Position', [50, 80, 200, 40], 'Enable', 'off', ...
        'ButtonPushedFcn', @(src, ~)stopRecording());

    g_exitButton = uibutton(g_mainWindow, 'push', 'Text', 'Wyjdź', ...
        'Position', [50, 30, 200, 40], 'ButtonPushedFcn', @(~, ~)exitApp());

    g_amplitudeAxes = uiaxes(g_mainWindow, 'Position', [1100, 40, 260, 240]);
    xlabel(g_amplitudeAxes, 'Time');
    ylabel(g_amplitudeAxes, 'Frequency');
    xlim(g_amplitudeAxes, [0 0.025]);
    ylim(g_amplitudeAxes, [-1 1]);

    t = (0:g_frameLength - 1) / g_fs;
    g_dataPlot = plot(g_amplitudeAxes, t, zeros(size(t)));

    g_chorusButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz chorus', ...
        'Position', [300, 130, 200, 40], ...
        'ValueChangedFcn', @(src, ~)toggleButtons(src, 'chorus'));

    % Equalizer

    g_equalizerButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz Equalizer', ...
        'Position', [600 250 200 40], 'ValueChangedFcn', @(src, ~)toggleButtons(src, 'Equalizer'));

    g_subBassSlider = uislider(g_mainWindow, 'Position', [600, 230, 250, 3], ...
        'Limits', [-12, 12], 'Value', 1, 'MajorTicks', -12:2:12, ...
        'MinorTicks', -12:1:12, 'ValueChangedFcn', @(src, ~)setGain(src, "SubBass"));

    subBassSliderLabel = uilabel(g_mainWindow, 'Text', "SubBass (<60Hz)", ...
        'FontColor', 'black', 'Position', [870 200 150 60]);
    
    g_bassSlider = uislider(g_mainWindow, 'Position', [600, 190, 250, 3], ...
        'Limits', [-12, 12], 'Value', 1, 'MajorTicks', -12:2:12, ...
        'MinorTicks', -12:1:12, 'ValueChangedFcn', @(src, ~)setGain(src, "Bass"));

    bassSliderLabel = uilabel(g_mainWindow, 'Text', "Bass (60Hz ~ 250Hz)", ...
        'FontColor', 'black', 'Position', [870 160 150 60]);
    
    g_midrangeSlider = uislider(g_mainWindow, 'Position', [600, 150, 250, 3], ...
        'Limits', [-12, 12], 'Value', 1, 'MajorTicks', -12:2:12, ...
        'MinorTicks', -12:1:12, 'ValueChangedFcn', @(src, ~)setGain(src, "Midrange"));

    midrangeSliderLabel = uilabel(g_mainWindow, 'Text', "Midrange (250Hz ~ 2000Hz)", ...
        'FontColor', 'black', 'Position', [870 120 200 60]);

    g_presenceSlider = uislider(g_mainWindow, 'Position', [600, 110, 250, 3], ...
        'Limits', [-12, 12], 'Value', 1, 'MajorTicks', -12:2:12, ...
        'MinorTicks', -12:1:12, 'ValueChangedFcn', @(src, ~)setGain(src, "Presence"));

    presenceSliderLabel = uilabel(g_mainWindow, 'Text', "Presence (2000Hz ~ 6000Hz)", ...
        'FontColor', 'black', 'Position', [870 80 200 60]);

    g_trebleSlider = uislider(g_mainWindow, 'Position', [600, 70, 250, 3], ...
        'Limits', [-12, 12], 'Value', 1, 'MajorTicks', -12:2:12, ...
        'MinorTicks', -12:1:12, 'ValueChangedFcn', @(src, ~)setGain(src, "Treble"));

    trebleSliderLabel = uilabel(g_mainWindow, 'Text', "Midrange (>6000Hz)", ...
        'FontColor', 'black', 'Position', [870 40 150 60]);


    function exitApp(~,~)
        delete(g_mainWindow);
    end


    function stopRecording(~,~)
        g_isRunning = false;
    end


    function setSemitones(src)
        g_semitones = round(src.Value);
    end

    function setGain(slider, whichGain)
        roundValue = round(slider.Value);
        slider.Value = roundValue;
        if whichGain == "SubBass"
            g_subBassGain = 10^(roundValue / 20);
        elseif whichGain == "Bass"
            g_bassGain = 10^(roundValue / 20);
        elseif whichGain == "Midrange"
            g_midrangeGain = 10^(roundValue / 20);
        elseif whichGain == "Presence"
            g_presenceGain = 10^(roundValue / 20);
        elseif whichGain == "Treble"
            g_trebleGain= 10^(roundValue / 20);
        end
    end

    function changeVolumeLevel(slider)
        roundValue = round(slider.Value);
        slider.Value = roundValue;
        g_audioLevel = roundValue;
    end

end