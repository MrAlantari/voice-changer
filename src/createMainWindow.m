function createMainWindow

    global g_mainWindow g_startButton g_stopButton g_exitButton g_isRunning;

    g_mainWindow = uifigure('Name', 'Voice Changer', 'Position', [100 100 300 200]);

    g_startButton = uibutton(g_mainWindow, 'push', 'Text', 'Rozpocznij', ...
    'Position', [50, 130, 200, 40], 'ButtonPushedFcn', @(~, ~)startRecording());

    g_stopButton = uibutton(g_mainWindow, 'push', 'Text', 'Zatrzymaj', ...
    'Position', [50, 80, 200, 40], 'Enable', 'off', 'ButtonPushedFcn', @(~, ~)stopRecording());

    g_exitButton = uibutton(g_mainWindow, 'push', 'Text', 'Wyjdź', ...
    'Position', [50, 30, 200, 40], 'ButtonPushedFcn', @(~, ~)exitApp());

    function exitApp(~,~)
        delete(g_mainWindow)
    end

    function stopRecording(~,~)
        g_isRunning = false;
    end

    function startRecording(~,~)
        g_startButton.Enable = 'off';
        g_stopButton.Enable = 'on';

        drawnow;
    
        frameLength = 1024;
        semitones = -10;
    
        audioReader = audioDeviceReader('SampleRate', 44100, 'SamplesPerFrame', frameLength);
        audioWriter = audioDeviceWriter('SampleRate', 44100);
    
        g_isRunning = true;
    
        while g_isRunning
            audioIn = audioReader();
            
            % Okno i przesunięcie
            win = kbdwin(512);
            overlapLength = 0.75 * numel(win);
            
            % Przetwarzanie STFT i przesunięcie tonu
            S = stft(audioIn, "Window", win, "OverlapLength", overlapLength, "Centered", false);
            audioOut = shiftPitch(S, semitones, "Window", win, "OverlapLength", overlapLength, "LockPhase", false);

            audioOut = audioOut * 10;
            audioOut = max(min(audioOut, 1), -1);

            audioWriter(audioOut);

            drawnow;
        end
    
        release(audioReader);
        release(audioWriter);
        
        g_startButton.Enable = 'on';
        g_stopButton.Enable = 'off';
    end

end