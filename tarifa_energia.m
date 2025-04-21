function custo = tarifa_energia(x)
    % Verifica se a hora está dentro do intervalo válido
    if x < 0 || x > 24
        error('Hora fora do intervalo permitido (0 a 24 horas).');
    end

    % Define os intervalos de tempo e os custos
    intervalos = [0, 2; 2, 4; 4, 6; 6, 8; 8, 10; ...
                  10, 12; 12, 14; 14, 16; 16, 18; ...
                  18, 20; 20, 22; 22, 24.0001];  % levemente maior que 24
    custos = [0.0713, 0.0651, 0.0593, 0.0778, 0.0851, ...
              0.0923, 0.0968, 0.10094, 0.10132, 0.10230, ...
              0.10189, 0.10132];

    for i = 1:size(intervalos, 1)
        if x >= intervalos(i, 1) && x < intervalos(i, 2)
            custo = custos(i);
            return;
        end
    end
end

