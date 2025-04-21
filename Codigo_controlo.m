%% Código de controlo.m
% Operação ótima: Cenários VC_MAX e VC_MIN no mesmo gráfico
clc; clear; close all;

%determinação de solução
[x, melhor_custo] = otimizador_brute_force_incertezas();

% Simula o sistema hidráulico
res = simulador_hidraulico(x);

% Parâmetros físicos e tarifários
rho = 1000;       % densidade da água (kg/m^3)
g1  = 9.81;       % aceleração gravítica (m/s^2)
eta = 0.65;       % eficiência da bomba
a1  = 260;        % coef. da curva hidráulica
a2  = -0.002;

% Horas do dia 0–23
t = 0:24;
N = numel(t);

% Prealocar vetores
on_off    = zeros(1,N);
tarifaVec = zeros(1,N);
cost_u    = zeros(1,N);
cost_l    = zeros(1,N);
energy_u  = zeros(1,N);
energy_l  = zeros(1,N);

h_tl = 2;
h_lt = 7;


% Cálculo hora a hora
for i = 1:N
    hora = t(i);
    on_off(i)    = estado_bomba(hora, x);
    tarifaVec(i) = tarifa_energia(hora);

    Qp_u = res.Qp_values_u(i);
    Qp_l = res.Qp_values_l(i);

    % Energia consumida (kWh)
    energy_u(i) = rho*g1*(Qp_u/3600)*(a1 + a2*(Qp_u^2))/1000;
    energy_l(i) = rho*g1*(Qp_l/3600)*(a1 + a2*(Qp_l^2))/1000;

    % Custo horário (€/h)
    cost_u(i) = energy_u(i) * tarifaVec(i)/eta;
    cost_l(i) = energy_l(i) * tarifaVec(i)/eta;

    
    if res.h_values_l(i) < h_tl || res.h_values_u(i) > h_lt || res.h_values_l(i) > h_lt || res.h_values_u(i) < h_tl
         disp(['Penalização em hora ', num2str(i-1)]);
         cost_u(i) = cost_u(i) + 5;
         cost_l(i) = cost_l(i) + 5;
    end
    
end

% Acumulados
cumCost_u = cumsum(cost_u);
cumCost_l = cumsum(cost_l);
cumE_u    = cumsum(energy_u);
cumE_l    = cumsum(energy_l);

%% Gráfico conjunto: VC_MAX vs VC_MIN com penalizações (versão com cores mais escuras)
figure('Name','Comparação VC\_MAX vs VC\_MIN','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
hold on; box on;

% Estado da bomba
stairs(t, on_off, 'k-', 'LineWidth', 1.5); % estado da bomba (esquerda)

% Níveis dos depósitos com cores escuras
plot(t, res.h_values_u(1:25), 'r-', 'LineWidth', 1.5); % VC_MAX (esquerda, vermelho escuro)
plot(t, res.h_values_l(1:25), 'b-', 'LineWidth', 1.5); % VC_MIN (esquerda, azul escuro)

% Penalizações com símbolos destacados
penal_u = find((res.h_values_u < h_tl) | (res.h_values_u > h_lt));
penal_l = find((res.h_values_l < h_tl) | (res.h_values_l > h_lt));

plot(t(penal_u), res.h_values_u(penal_u), 'ro', 'MarkerSize', 8, 'LineWidth', 2); % penalizações VC_MAX (vermelho escuro)
plot(t(penal_l), res.h_values_l(penal_l), 'bs', 'MarkerSize', 8, 'LineWidth', 2); % penalizações VC_MIN (azul escuro)

% Eixo da direita
yyaxis right

% Custo acumulado com cores fortes
plot(t, cumCost_u, 'm-', 'LineWidth', 1.5); % VC_MAX (magenta escuro)
plot(t, cumCost_l, 'Color', [0.3 0 0.5], 'LineWidth', 1.5); % VC_MIN (roxo escuro)

% Energia acumulada com cores escuras
plot(t, cumE_u, 'g-', 'LineWidth', 1.5); % VC_MAX (verde escuro)
plot(t, cumE_l, 'Color', [0 0.5 0], 'LineWidth', 1.5); % VC_MIN (verde oliva escuro)

% Eixos e legendas
xlabel('Tempo (h)');
yyaxis left
ylabel('Estado bomba (0/1) / Nível (m)');
yyaxis right
ylabel('Custo acumulado (€) / Energia (kWh)');
title('Comparação – Operação Ótima: VC\_MAX vs VC\_MIN');

legend({'Bomba ON/OFF', ...
        'Nível VC\_MAX', 'Nível VC\_MIN', ...
        'Penal. VC\_MAX', 'Penal. VC\_MIN', ...
        'Custo VC\_MAX', 'Custo VC\_MIN', ...
        'Energia VC\_MAX', 'Energia VC\_MIN'}, ...
        'Location','northwest');




