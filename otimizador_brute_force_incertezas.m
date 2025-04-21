function [melhor_x, melhor_custo] = otimizador_brute_force_incertezas()
    % Faixas de tempo e duração (valores discretizados)
    tempos = 0:1:24;
    duracoes = 1:1:6;

    h_min = 0;
    h_max = 9; 
    h_tl = 2;
    h_lt = 7;
    melhor_custo = inf;
    melhor_x = [];

    % Loop sobre todas as combinações possíveis (brute force)
    for t1 = tempos
        for t2 = tempos
            if t2 <= t1  % Garante que o segundo não começa antes do primeiro
                continue;
            end
            for d1 = duracoes
                for d2 = duracoes
                    x = [t1 t2 d1 d2];
                    res = simulador_hidraulico(x);

                    % === Restrições RÍGIDAS (intransponíveis) ===
                     if any(res.h_values_l < h_min) || any(res.h_values_u > h_max) || any(res.h_values_l > h_max) || any(res.h_values_u < h_min)
                        continue; % Rejeita se violar os limites
                    end
                    
                    % === Restrições de Penalização ===
                    for t = 1:length(res.h_values_l)

                        if res.h_values_l(t) < h_tl || res.h_values_u(t) > h_lt || res.h_values_l(t) > h_lt || res.h_values_u(t) < h_tl
                            res.C_W_u(t) = res.C_W_u(t) + 5;
                            res.C_W_l(t) = res.C_W_l(t) + 5;
                        end
                    end
                    % Custo total com penalidade
                    res.custo_total_u = sum(res.C_W_u);
                    res.custo_total_l = sum(res.C_W_l);
                    custo = (res.custo_total_u + res.custo_total_l)/2;

                    if custo < melhor_custo
                        melhor_custo = custo;
                        melhor_x = x;
                    end
                end
            end
        end
    end

    disp('Melhor solução encontrada:');
    disp(melhor_x);
    disp('Custo:');
    disp(melhor_custo);
end
