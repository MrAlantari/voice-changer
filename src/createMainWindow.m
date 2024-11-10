function createMainWindow

    global g_mainWindow g_startButton g_stopButton g_exitButton ...
        g_reverbButton g_tonePitchButton g_isRunning ... 
        g_pitchSlider ...
        g_isReverbOn g_isTonePitchOn g_semitones;

    g_isReverbOn = false;
    g_isTonePitchOn = false;
    g_semitones = 0;

    g_mainWindow = uifigure('Name', 'Voice Changer', 'Position', [100 100 600 320]);

    g_tonePitchButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz zmianę tonu', ...
        'Position', [50, 250, 200, 40], 'ValueChangedFcn', @(src, ~)toggleTonePitch(src));

    g_pitchSlider = uislider(g_mainWindow, 'Position', [300, 280, 250, 3], ...
        'Limits', [-10, 10], 'Value', 0, 'MajorTicks', -10:2:10, 'MinorTicks', -10:1:10, ...
        'ValueChangedFcn', @(src, ~)setSemitones(src));

    g_reverbButton = uibutton(g_mainWindow, 'state', 'Text', 'Włącz pogłos', ...
        'Position', [50, 200, 200, 40], 'ValueChangedFcn', @(src, ~)toggleReverb(src));

    g_startButton = uibutton(g_mainWindow, 'push', 'Text', 'Rozpocznij', ...
    'Position', [300, 80, 200, 40], 'ButtonPushedFcn', @(~, ~)startRecording());

    g_stopButton = uibutton(g_mainWindow, 'push', 'Text', 'Zatrzymaj', ...
    'Position', [50, 80, 200, 40], 'Enable', 'off', 'ButtonPushedFcn', @(~, ~)stopRecording());

    g_exitButton = uibutton(g_mainWindow, 'push', 'Text', 'Wyjdź', ...
    'Position', [50, 30, 200, 40], 'ButtonPushedFcn', @(~, ~)exitApp());



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

        drawnow;
    
        frameLength = 1024;

        audioReader = audioDeviceReader('SampleRate', fs, 'SamplesPerFrame', frameLength);
        audioWriter = audioDeviceWriter('SampleRate', fs);
        reverb = reverberator('SampleRate',fs);
    
        g_isRunning = true;
    
        while g_isRunning
            audioIn = audioReader();

            audioOut = audioIn;

            if g_isReverbOn
                audioOut = reverb(audioOut);
            end
            
            if g_isTonePitchOn
                audioOut = tonePitch(audioOut);
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


end