  Este sistema baseia-se numa abordagem de tentar reduzir o preço, dentro dos limites físicos 0 e 9 metros, 
com a aplicação de uma penalização de 5 euros por cada hora fora do intervalo de segurança (2 e 7 metros).
  
  Subdivide-se em cinco documentos:
    
  - a função "estado_bomba.m", esta função recebe uma determinada hora (t) e a variável de decisão X, e para o t determina se a bomba está desligada ou ligada;
    
  - a função "tarifa_energia.m", esta função recebe uma determinada hora e retorna o valor da tarifa de eletricidade na mesma;
    
  - a função "otimizador_brute_force_incertezas.m", esta função é um otimizador, que tal como o nome indica funciona por "força-bruta", 
ou seja analisa todas as combinações da variável X permitidas, e escolhe aquela com o menor custo associado, podendo ser um pouco demorada no seu processo
e tem em conta as penalizações por se ignorar o intervalo de segurança;

  - a função "simulador_hidráulico.m", esta função recebe uma variável de decisão X e retorna o comportamento do sistema hidráulico (caudal da bomba, altura no depósito, custo)
nas duas situações de consumo max e min;

  - a função "Codigo_controlo", que é a função de controlo e a que permite controlar o sistema;


   Para colocar o sistema a funcionar e obter os gráficos e dados, é necessário que simplesmente se dê "Run" da função "Codigo_controlo", e os dados devem ser recebidos no final no cálculo.
