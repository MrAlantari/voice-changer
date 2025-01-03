function audioOut = tonePitch(audioOut)
    global g_semitones;

    win = kbdwin(512);
    overlapLength = 0.75 * numel(win);
    
    % Przetwarzanie STFT i przesunięcie tonu
    S = stft(audioOut, "Window", win, "OverlapLength", overlapLength, "Centered", false);
    audioOut = shiftPitch(S, g_semitones, "Window", win, "OverlapLength", overlapLength, "LockPhase", false);

    audioOut = audioOut * 10;
    audioOut = max(min(audioOut, 1), -1);
end