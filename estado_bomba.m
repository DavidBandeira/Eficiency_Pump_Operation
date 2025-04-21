function estado = estado_bomba(t, x)
    % x está dividido em duas partes:
    % Primeira metade -> instantes de início da bomba
    % Segunda metade -> durações correspondentes

    num_ativacoes = length(x) / 2;  % Número total de ativações
    t_inicial = x(1:num_ativacoes);  % Instantes de início
    duracoes = x(num_ativacoes+1:end);  % Durações de cada ativação

    estado = 0;  % Assume que a bomba está desligada

    % Verifica se t está dentro de algum período de ativação
    for i = 1:num_ativacoes
        if t >= t_inicial(i) && t <= (t_inicial(i) + duracoes(i))
            estado = 1;  % Bomba está ligada
            break;
        end
    end
end
