function [y, state] = denoisingAudio(x, d, state, M)

    if isempty(state)
        state.h = zeros(M, 1);          % Wagi filtra
        state.bx = zeros(M, 1);        % Bufor próbek
    end

    mi = 0.05;
    gamma = 0.001;
    
    % Rozmiar bloku
    Nx = length(x);
    y = zeros(1, Nx);
    e = zeros(1, Nx);

    % Przetwarzanie próbek bloku
    for n = 1:Nx
        % Aktualizacja bufora próbek
        state.bx = [x(n); state.bx(1:M-1)];
        
        % Filtracja sygnału
        y(n) = state.h' * state.bx;
        
        % Obliczenie błędu
        e(n) = d(n) - y(n);
        
        % Adaptacja wag filtra NLMS
        eng = state.bx' * state.bx;  % Energia sygnału w buforze
        state.h = state.h + ( (2 * mi) / (gamma + eng) ) * e(n) * state.bx;
    end
end