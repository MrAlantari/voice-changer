function toggleButtons(src, key)

    global g_buttonsToggle;

    g_buttonsToggle(key) = src.Value;

    if g_buttonsToggle(key)
        src.Text = "Wyłącz " + key;
    else
        src.Text = "Włącz " + key;
    end
end