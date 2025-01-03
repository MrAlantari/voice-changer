function setFromSlider(slider, whichGlobal)
    global g_semitones g_lowGain g_midGain g_highGain;

    if whichGlobal == "semitones"
        g_semitones = round(src.Value);
    elseif whichGlobal == "lowGain"
        g_lowGain = 10^(slider.Value / 20);
    elseif whichGlobal == "midGain"
        g_midGain = 10^(slider.Value / 20);
    elseif whichGlobal == "highGain"
        g_highGain = 10^(slider.Value / 20);
    end
end