function audioOut = filterAudio(audioIn)
    global g_subBassGain g_bassGain g_midrangeGain g_presenceGain g_trebleGain;
    global g_subBass g_bass g_midrange g_presence g_treble;

    % Przetwarzanie pasmowe
    subBass = g_subBassGain * filtfilt(g_subBass, audioIn);
    bass = g_bassGain * filtfilt(g_bass, audioIn);
    midrange = g_midrangeGain * filtfilt(g_midrange, audioIn);
    presence = g_presenceGain * filtfilt(g_presence, audioIn);
    treble = g_trebleGain * filtfilt(g_treble, audioIn);

    % Sumowanie pasm
    audioOut = subBass + bass + midrange + presence + treble;
end