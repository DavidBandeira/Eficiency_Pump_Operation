

function res = simulador_hidraulico(x)
    
   
    % funções de caudal

    Qr = @(t) -0.004*(t.^3) + 0.09*(t.^2) + 0.1335*t + 20; 

    Qvc_max = @(t) -1.19333*(10^-7)*(t.^7) - 4.9074*(10^-5)*(t.^6) + 3.733*(10^-3)*(t.^5)...
    - 0.09621*(t.^4) + 1.03965*(t.^3) - 3.8645*(t.^2) - 1.0124*t + 75.393;

    Qvc_min = @(t) 1.19333*(10^-7)*(t.^7) - 6.54846*(10^-5)*(t.^6) + 4.1432*(10^-3)*(t.^5)...
    - 0.100585*(t.^4) + 1.05575*(t.^3) - 3.85966*(t.^2) - 1.32657*t + 75.393;

    % variáveis
    h_f = 150;
    Af = 185; % área (m^2)
    f = 0.02; % coeficiente de arrasto de fanning
    d = 0.3; % diâmetro (m)
    B_R = 2500; % (m)
    R_F = 5000; % (m)
    eta = 0.65; % eficiência da bomba 
    rho = 1000; % densidade da água (kg/m^3)
    g = 9.81 * 3600^2; % aceleração gravítica (m/h^2)
    a1 = 260;
    a2 = -0.002;

    
    %constantes
    
    C3 = h_f;
    C4 = (32*f)/((d^5)*g*(pi^2));
    
    
    % variações da altura no depósito
    
    dhdt__u = @(Qp, Qvc_max, Qr) (Qp - Qvc_max - Qr) / Af; 
    dhdt__l = @(Qp, Qvc_min, Qr) (Qp - Qvc_min - Qr) / Af;

    
    % vetor de tempo
    t = 0:1:24; % de 0 a 24 horas, com intervalos de 1 hora

    % Preallocate vectors for height and Qp
    h_values_u = zeros(size(t));
    h_values_l = zeros(size(t));
    Qp_values_u = zeros(size(t));
    Qp_values_l = zeros(size(t));

    u = zeros(size(t));
    l = zeros(size(t));

    h_values_u(1) = 4;
    h_values_l(1) = 4;

    for i = 2:length(t)
    % Obter o estado da bomba no instante de tempo t(i)
    y = estado_bomba(t(i), x);  
    
            Qr1 = Qr(i);
            Qvc_max1 = Qvc_max(i);
            Qvc_min1 = Qvc_min(i);
    % Definir Qp com base no estado da bomba
        if y == 1
             % A bomba está ligada
            
            % Avaliar `h_values_u(i-1)` antes de usar
            h_ant_u = h_values_u(i-1);
            h_ant_l = h_values_l(i-1);

            Qp_init = 20; % Chute inicial razoável
            options = optimset('Display', 'iter', 'TolFun', 1e-10, 'TolX', 1e-10); 
            
            Qp_values_u(i) = fsolve(@(Qp) a1 + a2*Qp^2 - h_ant_u - C3 - C4*B_R*(Qp^2) - C4*R_F*((Qp - Qr1)^2), Qp_init, options);

            Qp_values_l(i) = fsolve(@(Qp) a1 + a2*Qp^2 - h_ant_l - C3 - C4*B_R*(Qp^2) - C4*R_F*((Qp - Qr1)^2), Qp_init, options);

            u(i) = dhdt__u(Qp_values_u(i), Qvc_max1, Qr1);
            l(i) = dhdt__l(Qp_values_l(i), Qvc_min1, Qr1); 
            h_values_u(i) = u(i) + h_values_u(i-1);
            h_values_l(i) = l(i) + h_values_l(i-1);
            
        else
            Qp_values_u(i) = 0;  % A bomba está desligada
            Qp_values_l(i) = 0;  
            
            u(i) = dhdt__u(0, Qvc_max1, Qr1);
            l(i) = dhdt__l(0, Qvc_max1, Qr1); 
            h_values_u(i) = u(i) + h_values_u(i-1);
            h_values_l(i) = l(i) + h_values_l(i-1);
        
        end
    
    end

    
    C_W_u = zeros(1, 25); % Inicializar vetor de custos
    C_W_l = zeros(1, 25);
    W_u = zeros(1, 25);
    W_l = zeros(1, 25);
    g1 = 9.81;

    for t = 1:24

        tarifa = tarifa_energia(t-1); % Usa t-1 para corresponder às horas 0 a 23

        W_u(t) = rho*g1*(Qp_values_u(t)/3600)*(a1 + a2*(Qp_values_u(t)^2))/1000; % kiloWats/hora
        C_W_u (t) = W_u(t)*tarifa/eta;

        W_l(t) = rho*g1*(Qp_values_l(t)/3600)*(a1 + a2*(Qp_values_l(t)^2))/1000; % kiloWats/hora
        C_W_l (t) = W_l(t)*tarifa/eta;


    end

    % Retorna o custo total para minimizar
    custo_total_u = sum(C_W_u);
    custo_total_l = sum(C_W_l);
    
    res.W_u = W_u;
    res.W_l = W_l;
    res.C_W_u = C_W_u;
    res.C_W_l = C_W_l;
    res.h_values_l = h_values_l;
    res.h_values_u = h_values_u;
    res.Qp_values_u = Qp_values_u;
    res.Qp_values_l = Qp_values_l;
    res.u = u;
    res.l = l;
    res.custo_total_u = custo_total_u;
    res.custo_total_l = custo_total_l;
    

end