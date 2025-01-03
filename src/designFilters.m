function designFilters()
    global g_subBass g_bass g_midrange g_presence g_treble g_fs;

    g_subBass = designfilt('lowpassiir', 'FilterOrder', 4, ...
        'HalfPowerFrequency', 60, 'SampleRate', g_fs);

    g_bass = designfilt('bandpassiir', 'FilterOrder', 4, ...
        'HalfPowerFrequency1', 60, 'HalfPowerFrequency2', 250, 'SampleRate', g_fs);

    g_midrange = designfilt('bandpassiir', 'FilterOrder', 4, ...
        'HalfPowerFrequency1', 250, 'HalfPowerFrequency2', 2000, 'SampleRate', g_fs);

    g_presence = designfilt('bandpassiir', 'FilterOrder', 4, ...
        'HalfPowerFrequency1', 2000, 'HalfPowerFrequency2', 6000, 'SampleRate', g_fs);
    
    g_treble = designfilt('highpassiir', 'FilterOrder', 4, ...
        'HalfPowerFrequency', 6000, 'SampleRate', g_fs);
end