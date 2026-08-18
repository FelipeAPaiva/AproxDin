pkg load symbolic;
syms inicializar;

clc; clear; close all;

set(groot, 'defaultLineLineWidth', 2);
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultTextFontSize', 12);

%---------- FUNÇÃO INTEGRAL PONTO A PONTO ----------%
function [integral_final] = integralpp(eixo_y, dt)

  tamanho_y = length(eixo_y);
  integracao = zeros(1, tamanho_y);
  integracao(1) = 0;

  for i = 2:tamanho_y
    integracao(i) = integracao(i - 1) + (eixo_y(i) + eixo_y(i-1))*dt/2;
  endfor

  integral_final = integracao(:);

  endfunction

%---------- FUNÇÃO LUGAR DAS RAÍZES ----------%
function lugar_das_raizes(funcao, titulo_lugar_das_raizes)
  figure;
  rlocus(funcao);
  titulo(titulo_lugar_das_raizes);
  lg = legend();
  set(lg, "FontSize", 12, 'location', 'southWest');
  set(gca, "FontSize", 12);
  grid on;
  hold on;
  drawnow;
endfunction

%---------- FUNÇÃO BODE ----------%
function plot_bode(funcao_bode, titulo_bode)
  figure
  bode(funcao_bode);
  margin(funcao_bode);
  titulo(titulo_bode);
  grid on;
  drawnow;
  endfunction

%---------- FUNÇÃO PLOT DOS GRÁFICOS ----------%
function plotgrafico(xgrafico, ygrafico, cor, titulografico)
  plot(xgrafico, ygrafico, cor, 'LineWidth', 2);
  titulo(titulografico);
  xlabel('Tempo (s)', "FontSize", 12);
  ylabel('Variável controlada', "FontSize", 12);
  grid on;
  hold on;
  set(gca, "FontSize", 12);
  drawnow;
endfunction

%---------- FUNÇÃO PARA PLOT DE PONTOS ----------%
function plotponto(pontox, pontoy,cor, xminimo, yminimo)
  plot(pontox, pontoy, sprintf('%so', cor), 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', cor);
  plot([pontox pontox], [yminimo pontoy], sprintf('--%s', cor), 'LineWidth', 2, 'HandleVisibility', 'off');
  plot([xminimo pontox], [pontoy pontoy], sprintf('--%s', cor), 'LineWidth', 2, 'HandleVisibility', 'off');
  hold on;
  drawnow;
  set(gca, "FontSize", 12);
endfunction

%---------- FUNÇÃO PARA DEFINIR O LIMITE DOS EIXOS ----------%
function limiteeixos(x, y)

  % Quantidade de casas decimais na exibição
  N = 1;

  % Quantidade de números nos eixos
  qtd = 6;

  % Limite do eixo x
  xlim([min(x), max(x)]);

  % Limites de y
  ymin = min(y);
  ymax = max(y);

  % Valores igualmente espaçados (sem arredondar!)
  yt = linspace(ymin, ymax, qtd);

  % Define limites e ticks
  ylim([min(yt), max(yt)]);
  yticks(yt);

  % Arredondamento apenas visual:
  ytlabels = arrayfun(@(v) sprintf(['%.', num2str(N), 'f'], v), yt, "UniformOutput", false);

  yticklabels(ytlabels);

endfunction


%---------- FUNÇÃO DE LEGENDAS ----------%
function legendas(var_legenda)
  legend(var_legenda, "FontSize", 12, 'location', 'southEast');
endfunction

%---------- FUNÇÃO DO TITULO ----------%
function titulo(tit)
  title(tit, "FontSize", 12)
endfunction

format short;

pkg load control;

while(true)
  system('cls');
  clc; clear; close all;
%---------- MENU DE ESCOLHAS ----------%
fprintf("Escolha uma opção abaixo:\n[1] Aproximação de primeira ordem\n[2] Aproximação de segunda ordem superamortecida método de Miller\n[3] Aproximação de segunda ordem superamortecida método de Ziegler-Nichols\n[4] Aproximação de segunda ordem superamortecida de fase não minima\n[5] Aproximação de segunda ordem subamortecida\n[6] Aproximação de terceira ordem de fase não mínima\n[7] Aproximação de segunda ordem com um zero\n[8] Método dos mínimos quadrados\n[9] Finalizar código\n");
escolha = input('Digite a opção escolhida: ', 's');
fprintf("");

%---------- VERIFICA SE A ESCOLHA DO USUÁRIO FAZ PARTE DAS OPÇÕES DISPONÍVEIS ----------%
if ~ismember(escolha, {'1','2','3','4','5', '6', '7', '8', '9'})
    fprintf("Opção inválida!\n");
    fprintf('\nPressione qualquer tecla para continuar...')
    pause;
    continue;
end

if escolha == '9'
    fprintf("Finalizando código...\n");
    break;
end


%---------- PEDE PARÂMETROS NECESSÁRIOS PARA O FUNCIONAMENTO DO CÓDIGO ----------%
fprintf("\nDigite os seguintes parâmetros: \n")

% Seleção gráfica do arquivo
[file, path] = uigetfile({'*.csv;*.txt', 'Arquivos CSV ou TXT (*.csv, *.txt)'}, 'Selecione o arquivo de dados');

if isequal(file,0)
    fprintf('\nNenhum arquivo foi selecionado.\n');
    fprintf('\nPressione qualquer tecla para finalizar...')
    pause;
    continue;
end

fprintf('Arquivo selecionado: %s\n', file);

dados_csv = fullfile(path, file);

variavel_manipulada_inicial = input('Valor inicial da variavel manipulada: ');
variavel_manipulada_final = input('Valor final da variavel manipulada: ');
tempo_degrau = input('Digite o tempo em segundos onde foi dado o degrau da variavel manipulada: ');

%---------- VERIFICA SE O ARQUIVO ABRE ----------%
fid = fopen(dados_csv, 'r');
if fid == -1
    fprintf('\nNão foi possível abrir o arquivo.\n');
    fprintf('\nPressione qualquer tecla para finalizar...')
    pause;
    continue;
end

%---------- VERIFICA DELIMITADOR ----------%
linha1 = fgetl(fid);
frewind(fid);

if ~isempty(strfind(linha1, ';'))
    delimitador = ';';
elseif ~isempty(strfind(linha1, ','))
    delimitador = ',';
elseif ~isempty(strfind(linha1, char(9)))
    delimitador = '\t';
elseif ~isempty(strfind(linha1, ' '))
    delimitador = ' ';
else
    fprintf('\nDelimitador não reconhecido\n');
    fprintf('\nPressione qualquer tecla para finalizar...')
    pause;
    continue;
end

%---------- LÊ O ARQUIVO ----------%
dados = textscan(fid, '%f%f', 'Delimiter', delimitador, 'HeaderLines', 1);
fclose(fid);

tempo = dados{1};
variavel_controlada = dados{2};


%---------- ATRIBUI AS VARIAVEIS EM RELAÇÃO AS COLUNAS DO ARQUIVO ----------%
tempo = dados{1};
variavel_controlada = dados{2};

%---------- ENCONTRA ALGUNS PARÂMETROS PARA A UTILIZAÇÃO NO CÓDIGO ----------%
xmin = tempo(1);
xmax = tempo(end);
ymin = min(variavel_controlada);
ymax = max(variavel_controlada);
tamanho_tempo = length(tempo);


%---------- CONSTROI O DEGRAU COM BASE NOS DADOS FORNECIDOS PELO USUÁRIO ----------%
u = (tempo>=tempo_degrau)*(variavel_manipulada_final - variavel_manipulada_inicial); %RESPOSTA DEGRAU

%---------- PERGUNTA AO USUÁRIO SE DESEJA SUB-AMOSTRAR O SINAL ----------%
fprintf("\nDeseja sub-amostrar o sinal? O tamanho dos dados é %e\n[1] Sim (CUIDADO: torna o programa mais rápido, porém pode haver perdas de informações se usado de maneira errada.)\n[2] Não\n", tamanho_tempo);
escolha_sub_amostragem = input('Digite a opção escolhida: ', 's');

periodo_amostragem = tempo(2) - tempo(1);

%---------- SUB AMOSTRAGEM PARA TORNAR O CÓDIGO MAIS LEVE ----------%
if escolha_sub_amostragem =='1'
  tamanho_sub_amostragem = input('Digite o máximo tamanho do vetor que você deseja: ');
  passo = ceil(tamanho_tempo/tamanho_sub_amostragem);
  if tamanho_sub_amostragem > tamanho_tempo
    fprintf('\nImpossível o tamanho dos dados sub-amostrados ser maior que o tamanho dos dados originais, por isso será mantido o vetor original.\n');
    passo = 1;
  endif
  tempo = tempo(1:passo:end);
  variavel_controlada = variavel_controlada(1:passo:end);
  tempo_plot = tempo;
  y_plot = variavel_controlada;
  u_plot = u(1:passo:end);
elseif escolha_sub_amostragem == '2'
  tempo_plot = tempo;
  y_plot = variavel_controlada;
  u_plot = u;
else
  fprintf("\nOpção inválida\n");
  fprintf('\nPressione qualquer tecla para finalizar...')
  pause;
  continue;
end

indice_tempo_degrau = find(tempo >= tempo_degrau, 1);

%---------- PERGUINTA AO USUÁRIO SE DESEJA FILTRAR O SINAL ----------%
fprintf("\nDeseja filtrar o sinal?\n[1] Sim (Obs: se apresentar uma grande quantidade de dados o software pode ser lento ou estourar a memória do octave)\n[2] Não\n");
escolha_2 = input("Digite sua escolha: ");

%---------- CASO O USUÁRIO ESCOLHA FILTRAR O SINAL ----------%
if escolha_2 == 1

  %---------- DEFINI A FREQUENCIA DE AMOSTRAGEM COM BASE NO VETOR DE TEMPO ----------%
  frequencia_de_amostragem = 1/(tempo(2)-tempo(1));

  fprintf("\nA frequencia de amostragem do sinal é %.e, para escolher uma janela N especifica, a frequencia de corte é dada por f_corte = f_amostragem/N\n\n", round(frequencia_de_amostragem));

  %---------- PERGUNTA AO USUÁRIO A FREQUÊNCIA DE CORTE DESEJADA ----------%
  frequencia_de_corte = input('Digite a frequência de corte do filtro: ');
  fprintf("\n");

  %---------- DEFINI O TAMANHO DA JANELA NECESSÁRIO PARA FILTRAR A FREQUENCIA DESEJADA PELO USUARIO ----------%
  n = ceil(frequencia_de_amostragem/frequencia_de_corte);

  %---------- CALCULA O ATRASO GERADO PELO FILTRO ----------%
  atraso = floor((n-1)/2);

  %---------- MONTA O VETOR b NECESSARIO PARA FILTRAR O SINAL COM A FUNÇÃO FILTER ----------%
  b = ones(1, n)/n;

  %---------- ENCONTRA O VALOR MÉDIO FINAL E INICIAL ----------%
  yinicial_medio = mean(variavel_controlada(1:n))
  yfinal_medio = mean(variavel_controlada(end-n+1:end))

  %---------- DEFINE A VARIAVEL CONTROLADA INICIAL E FINAL COM BASE NOS VALORES MÉDIOS ENCONTRADOS ----------%
  variavel_controlada_inicial = yinicial_medio;
  variavel_controlada_final = yfinal_medio;

  %---------- CENTRALIZA A FUNÇÃO PARA O ZERO POIS A FUNÇÃO FILTER TRABALHA COM VALORES INICIAIS IGUAIS A ZERO ----------%
  variavel_controlada_centralizada = variavel_controlada - yinicial_medio;

  %---------- FILTRA O SINAL COM A FUNÇÃO FILTER ----------%
  filtro_centralizado = filter(b, 1, variavel_controlada_centralizada);

  %---------- VOLTA A FUNÇÃO PARA O REGIME PERMANENTE INICIAL ----------%
  filtro = filtro_centralizado + yinicial_medio;

  %---------- CORRIGE O ATRASO ----------%
  filtro = filtro(atraso+1:end);
  tempo = tempo(1:end-atraso);
  variavel_controlada = variavel_controlada(1:end-atraso);
  tempo_plot = tempo_plot(1:end-atraso);
  y_plot = y_plot(1:end-atraso);
  xmin = tempo(1);
  xmax = tempo(end);
  u_plot = u_plot(1:end-atraso);


%---------- CASO O USUÁRIO ESCOLHA NÃO FILTRAR O SINAL ----------%
elseif escolha_2 == 2
  filtro = variavel_controlada;
  fprintf('\n');
  variavel_controlada_inicial = round(variavel_controlada(1)*1e6)/1e6
  variavel_controlada_final = round(variavel_controlada(end)*1e6)/1e6
  fprintf('\n')

%---------- CASO O USUÁRIO ESCOLHA UMA OPÇÃO INVÁLIDA ----------%
else
  fprintf("\nOpção inválida\n")
  fprintf('\nPressione qualquer tecla para finalizar...')
  pause;
  continue;
end


  %---------- PLOTA O GRÁFICO DO SINAL ORIGINAL SUB AMOSTRADO ----------%
  figure
  plotgrafico(tempo_plot, y_plot, 'b', '');

  %---------- PLOTA O FILTRO SUB AMOSTRADO ----------%
  plotgrafico(tempo, filtro, 'r', 'Filtro vs medição real');
  legendas({'Variavel controlada real', 'Filtro'});
  limiteeixos([xmin, xmax], [ymin, ymax]);

%---------- CÁLCULO DE ERROS ----------%
fprintf("\n");
erro = variavel_controlada - filtro;
erro_real = abs(erro);
erro_maximo = max(abs(erro_real))
erro_medio = mean(abs(erro_real))
erro_rms = sqrt(mean(erro_real.^2))
fprintf('\n')
k = (variavel_controlada_final - variavel_controlada_inicial)/(variavel_manipulada_final - variavel_manipulada_inicial)

%---------- DEFINI A LETRA S COMO FUNÇÃO DE TRANSFERÊNCIA ----------%
s = tf('s');

fprintf("\n");
%---------- CASO O USUÁRIO ESCOLHA APROXIMAR PARA UMA RESPOSTA DE PRIMEIRA ORDEM ----------%
if escolha =='1'

  %---------- ENCONTRA O VALOR DE 63% COMO ESTABELECIDO NO ARTIGO ----------%
  V63 = (1-exp(-1))*(variavel_controlada_final - variavel_controlada_inicial) + variavel_controlada_inicial

  %---------- ENCONTRA A POSIÇÃO DO VETOR ONDE É IMEDIATAMENTE MAIOR OU IGUAL A V63 ----------%
  idx = find(filtro(indice_tempo_degrau:end) >= V63, 1) + indice_tempo_degrau - 1;
  %---------- ENCONTRA O VETOR LOGO NA POSIÇÃO ANTERIOR ----------%
  y1 = filtro(idx-1);
  %---------- ENCONTRA A POSIÇÃO DO V63 ----------%
  y2 = filtro(idx);
  %---------- ENCONTRA O TEMPO ANTERIOR AO ATINGIR 63% ----------%
  t1 = tempo(idx-1);
  %---------- ENCONTRA O TEMPO DO V63 ----------%
  t2 = tempo(idx);
  %---------- FAZ UMA INTERPOLAÇÃO SIMPLES ENTRE OS 2 PONTOS PARA UMA APROXIMAÇÃO MAIS EXATA ----------%
  tempo_63 = t1 + (V63 - y1) * (t2 - t1) / (y2 - y1)

  %---------- PLOTA O GRÁFICO DO SINAL ORIGINAL SUB AMOSTRADO ----------%
  figure
  plotgrafico(tempo_plot, y_plot, 'b', '')

  %---------- PLOTA O FILTRO SUB AMOSTRADO ----------%
  plotgrafico(tempo_plot, filtro, 'r', 'Filtro vs medição real')

  %---------- PLOTA O PONTO 63% ----------%
  plotponto(tempo_63, V63, 'k', xmin, ymin);
  limiteeixos([xmin, xmax], [ymin, ymax]);
  legendas({'Variavel controlada real', 'Filtro', sprintf("tempo63 = %f  V63 = %f", tempo_63, V63)});

  %---------- CALCULA OS TERMOS NECESSÁRIOS PARA A APROXIMAÇÃO ----------%
  tau = tempo_63 - tempo_degrau
  k = k
  a = 1/tau
  tempo_de_subida = 2.2/a
  tempo_de_acomodacao = 4/a

  %---------- PRINTA A FUNÇÃO DE TRANSFERÊNCIA NA JANELA DE COMANDOS ----------%
  fprintf("\nA função de primeira ordem em malha aberta aproximada é:\n")
  funcao_aproximada = k*a/(s+a)
  fprintf('\n');
  polo = pole(funcao_aproximada)

    %---------- ERRO CASO DE POLOS POSITIVOS ----------%
  if max(real(polo)) > 0
    fprintf('\n\nImpossível aproximar\n');
    fprintf('Pressione qualquer tecla para continuar...');
    pause;
    system('cls');
    clc; clear; close all;
    continue;
  endif

  %---------- PLOTA O LUGAR GEOMETRICO DAS RAIZES E O DIAGRAMA DE BODE SEM COMPENSAÇÃO ----------%
if k > 0
  lugar_das_raizes(funcao_aproximada, 'Lugar das raízes do sistema sem compensação');

  elseif k < 0
  lugar_das_raizes(-funcao_aproximada, 'Lugar das raízes do sistema sem compensação');
end

  plot_bode(funcao_aproximada, 'Diagrama de bode em malha aberta');

  %---------- CRIA O VETOR COM O DEGRAU CRIADO COM OS DADOS DO USUÁRIO ----------%
  y_step = lsim(funcao_aproximada, u_plot, tempo_plot) + variavel_controlada_inicial;

  %---------- ENCONTRA O PONTO 63% DA FUNÇÃO APROXIMADA ----------%
  fprintf("\n");
  V63_funcao_de_tranferencia = (1-exp(-1))*(y_step(end) - y_step(1)) + y_step(1)
  idx_funcao_aproximada = find(y_step >= V63_funcao_de_tranferencia, 1);
  y1 = y_step(idx_funcao_aproximada - 1);
  y2 = y_step(idx_funcao_aproximada);
  t1 = tempo_plot(idx_funcao_aproximada-1);
  t2 = tempo_plot(idx_funcao_aproximada);

  %---------- FAZ UMA INTERPOLAÇÃO SIMPLES PARA ENCONTRAR O VALOR MAIS EXATO ----------%
  tempo_63_da_funcao_de_tranferencia = t1 + (V63_funcao_de_tranferencia - y1)*(t2 - t1)/(y2-y1)

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DOS DADOS ORIGINAIS SUB AMOSTRADO E A RESPOSTA DA FUNÇÃO ----------%
  figure
  %---------- PLOT DOS DADOS ORIGINAIS ----------%
  plotgrafico(tempo_plot, y_plot, 'b', '')

  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real')
  limiteeixos([xmin, xmax], [ymin, ymax]);
  legendas({'Variavel controlada real', 'Aproximação de primeira ordem'});

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DOS DADOS ORIGINAIS SUB AMOSTRADO E A RESPOSTA DA FUNÇÃO ----------%
  figure
  %---------- PLOT DOS DADOS ORIGINAIS ----------%
  plotgrafico(tempo_plot, y_plot, 'b', '')
  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real');
  limiteeixos([xmin, xmax], [ymin, ymax]);

  %---------- PLOT DO PONTO 63% ----------%
  plotponto(tempo_63_da_funcao_de_tranferencia, V63_funcao_de_tranferencia, 'k', xmin, ymin)
  legendas({'Variavel controlada real', 'Aproximação de primeira ordem',sprintf("tempo63 = %f  V63 = %f", tempo_63_da_funcao_de_tranferencia, V63_funcao_de_tranferencia) });

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DO FILTRO SUB AMOSTRADO E O DA FUNÇÃO APROXIMADA PARA COMPARAÇÃO ----------%
  figure
  %---------- PLOT DO FILTRO ----------%
  plotgrafico(tempo_plot, filtro, 'k', '');

  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs FILTRO')
  limiteeixos(tempo_plot, [min([filtro, y_step]), max([filtro, y_step])]);
  legendas({'Filtro', 'Função de transferência'});

  %---------- PRINTA OS ERROS DA FUNÇÃO COMPARADA COM O FILTRO ----------%
  fprintf("\nErros filtro vs função de transferência\n");
  y_step = y_step(1:length(filtro));
  erro_real_funcao_de_transferencia = abs(filtro - y_step);
  erro_maximo_funcao_de_transferencia = max(erro_real_funcao_de_transferencia)
  erro_medio_funcao_de_transferencia = mean(erro_real_funcao_de_transferencia)
  erro_rms_funcao_de_transferencia = sqrt(mean(erro_real_funcao_de_transferencia.^2))

  %---------- TEMPO DE ACOMODAÇÃO ESCOLHIDO PELO USUÁRIO ----------%
  fprintf("\nEscolha o tempo de acomodação em malha fechada.\nDica: pode usar [nº]e-n para indicar um número pequeno. Exemplo: 2e-3 para indicar 2 milisegundos\n\n");
  TSMF_primeira_ordem = input("Digite o tempo de acomodação desejado aqui: ");
  fprintf("\n");
  KPI = 4/(k*a*TSMF_primeira_ordem);

%---------- CALCULA KP E KI COM BASE NA METODOLOGIA PROPOSTA PELO ARTIGO ----------%
  KP = KPI
  KI = KPI*a

  %---------- ENCONTRA A FUNÇÃO DO PI BASEADA NA METODOLOGIA PROPOSTA NO ARTIGO ----------%
  fprintf("\nA função do PI é dada por:\n");
  PI = KPI*(s+a)/s

  fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
  discretizacao = input('Digite sua escolha: ');
  fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(PI, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(PI, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

  %---------- ENCONTRA A FUNÇÃO EM MALHA ABERTA COMPENSADA ----------%
  MA = PI*funcao_aproximada;
  MA = minreal(MA);

  %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
  fprintf("\nA função em malha fechada é dada por:\n");
  funcao_em_malha_fechada = k*a*KPI/(s+k*a*KPI)
  fprintf('\n');
  polo_malha_fechada = pole(funcao_em_malha_fechada)
##  funcao_em_malha_fechada_feedback = feedback(MA, 1);

  fprintf("\n")
  tempo_de_subida_malha_fechada = 2.2/(k*a*KPI)
  tempo_de_acomodacao_malha_fechada = 4/(k*a*KPI)

  %---------- CRIA UMA NOVA FIGURA COM O LUGAR GEOMETRICO DAS RAIZES COMPENSADO COM O PI ----------%
  lugar_das_raizes(MA, 'Lugar das raízes do sistema compensado');

  %---------- CRIA UMA NOVA FIGURA COM O DIAGRAMA DE BODE DO SISTEMAS EM MALHA ABERTA COMPENSADO ----------%
  plot_bode(MA, 'Diagrama de bode em malha aberta compensado');

  %----------  CRIA UMA NOVA FIGURA COM O PLOT DA FUNÇÃO EM MALHA FECHADA ----------%
  ##  [y_malha_fechada_feedback, x_malha_fechada_feedback] = step(funcao_em_malha_fechada_feedback,tempo(end));
  [y_malha_fechada, x_malha_fechada] = step(funcao_em_malha_fechada, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  [y_malha_aberta, x_malha_aberta] = step(funcao_aproximada/k, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));

  ##  plotgrafico(x_malha_fechada_feedback, y_malha_fechada_feedback, 'b', '');
  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', '');
  plotgrafico(x_malha_aberta, y_malha_aberta, 'r', 'Função em malha fechada');
  limiteeixos([0, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)])], [min([y_malha_aberta; y_malha_fechada]), max([y_malha_aberta; y_malha_fechada])]);
  legendas({'Função em malha fechada', 'Função em malha aberta dividido pelo ganho k'});

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', 'Função em malha fechada');
  limiteeixos([0, 2*tempo_de_acomodacao_malha_fechada], [min([y_malha_fechada]), max([y_malha_fechada])]);
end

%---------- CASO O USUÁRIO ESCOLHA APROXIMAR PARA UMA RESPOSTA DE SEGUNDA ORDEM SUPERAMORTECIDA PELO MÉTODO DE MILLER ----------%
if escolha == '2'

  %---------- ENCONTRA OS PARAMETROS NECESSÁRIOS PARA A APROXIMAÇÃO ----------%

  %---------- ENCONTRA O VALOR DE 63% COMO ESTABELECIDO NO ARTIGO ----------%
  V63 = (1-exp(-1))*(variavel_controlada_final - variavel_controlada_inicial) + variavel_controlada_inicial

  %---------- ENCONTRA A POSIÇÃO DO VETOR ONDE É IMEDIATAMENTE MAIOR OU IGUAL A V63 ----------%
  idx = find(filtro(indice_tempo_degrau:end) >= V63, 1) + indice_tempo_degrau - 1;
  %---------- ENCONTRA O VETOR LOGO NA POSIÇÃO ANTERIOR ----------%
  y1 = filtro(idx-1);
  %---------- ENCONTRA A POSIÇÃO DO V63 ----------%
  y2 = filtro(idx);
  %---------- ENCONTRA O TEMPO ANTERIOR AO ATINGIR 63% ----------%
  t1 = tempo(idx-1);
  %---------- ENCONTRA O TEMPO DO V63 ----------%
  t2 = tempo(idx);
  %---------- FAZ UMA INTERPOLAÇÃO SIMPLES ENTRE OS 2 PONTOS PARA UMA APROXIMAÇÃO MAIS EXATA ----------%
  tempo_63 = t1 + (V63 - y1) * (t2 - t1) / (y2 - y1)

  %---------- PONTO DE INFLEXÃO REAL -> derivada máxima (curvatura zero) ----------%

  dy = gradient(filtro(indice_tempo_degrau:end), tempo);
  [dmax, ind_inflexao] = max(dy);
  t_inflexao = tempo(ind_inflexao+indice_tempo_degrau-1)
  y_inflexao = filtro(ind_inflexao+indice_tempo_degrau-1)
  m = dmax

  %---------- RETA TANGENTE ----------%
  reta = y_inflexao + m * (tempo - t_inflexao);
  indice_ymin_reta = find(reta >= ymin, 1);
  indice_ymax_reta = find(reta >= ymax, 1);
  reta = reta(indice_ymin_reta - 1:indice_ymax_reta);
  tempo_reta = tempo(indice_ymin_reta-1:indice_ymax_reta);
  t_theta = (variavel_controlada_inicial - y_inflexao)/m + t_inflexao

  %---------- PLOTA O GRÁFICO DO FILTRO COM TEMPO MORTO E DEMAIS PONTOS IMPORTANTES ----------%
  figure
  plotgrafico(tempo, filtro, 'b', '');
  plotgrafico(tempo_reta, reta, 'k', 'Pontos importantes')
  plotponto(t_theta, variavel_controlada_inicial, 'r', xmin, ymin);
  plotponto(tempo_63, V63, 'green', xmin, ymin);
  plot(t_inflexao, y_inflexao, 'mo', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'm');
  limiteeixos(tempo, filtro);
  legendas({'Filtro','Reta tangente', sprintf('t theta = %f VC inicial = %f', t_theta, variavel_controlada_inicial), sprintf('tempo 63 = %f VC 63 = %f', tempo_63, V63), sprintf('Ponto de inflexão')});

  %---------- ENCONTRANDO OS PARÂMETROS NECESSÁRIOS PARA A APROXIMAÇÃO  ----------%
  theta = t_theta - tempo_degrau
  tau = tempo_63 - t_theta
  b = 1/tau
  a = 1/theta
  tempo_de_acomodacao = 4/abs(min([a, b]))

  fprintf('\nA função aproximada é:\n')
  funcao_aproximada = k*b*a/((s+b)*(s+a))
  fprintf('\n');
  polos = pole(funcao_aproximada)

    %---------- ERRO CASO DE POLOS POSITIVOS ----------%
  if max(real(polos)) > 0
    fprintf('\n\nImpossível aproximar\n');
    fprintf('Pressione qualquer tecla para continuar...');
    pause;
    system('cls');
    clc; clear; close all;
    continue;
  endif

  %---------- PLOTA O LUGAR GEOMETRICO DAS RAIZES E O DIAGRAMA DE BODE SEM COMPENSAÇÃO ----------%
if k > 0
  lugar_das_raizes(funcao_aproximada, 'Lugar das raízes do sistema sem compensação');

  elseif k < 0
  lugar_das_raizes(-funcao_aproximada, 'Lugar das raízes do sistema sem compensação');
end

  plot_bode(funcao_aproximada, 'Diagrama de bode em malha aberta');

  %---------- CRIA O VETOR COM O DEGRAU CRIADO COM OS DADOS DO USUÁRIO ----------%
  y_step = lsim(funcao_aproximada, u_plot, tempo_plot) + variavel_controlada_inicial;

  %---------- ENCONTRA O PONTO 63% DA FUNÇÃO APROXIMADA ----------%
  fprintf("\n");
  V63_funcao_de_tranferencia = (1-exp(-1))*(y_step(end) - y_step(1)) + y_step(1)
  idx_funcao_aproximada = find(y_step >= V63_funcao_de_tranferencia, 1);
  y1 = y_step(idx_funcao_aproximada - 1);
  y2 = y_step(idx_funcao_aproximada);
  t1 = tempo_plot(idx_funcao_aproximada-1);
  t2 = tempo_plot(idx_funcao_aproximada);

  %---------- FAZ UMA INTERPOLAÇÃO SIMPLES PARA ENCONTRAR O VALOR MAIS EXATO ----------%
  tempo_63_da_funcao_de_tranferencia = t1 + (V63_funcao_de_tranferencia - y1)*(t2 - t1)/(y2-y1)

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DOS DADOS ORIGINAIS SUB AMOSTRADO E A RESPOSTA DA FUNÇÃO ----------%
  figure
  %---------- PLOT DOS DADOS ORIGINAIS ----------%
  plotgrafico(tempo_plot, y_plot, 'b', '')

  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real')
  limiteeixos([xmin, xmax], [ymin, ymax]);
  legendas({'Variavel controlada real', 'Aproximação de primeira ordem'});

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DOS DADOS ORIGINAIS SUB AMOSTRADO E A RESPOSTA DA FUNÇÃO ----------%
  figure
  %---------- PLOT DOS DADOS ORIGINAIS ----------%
  plotgrafico(tempo_plot, y_plot, 'b', '')
  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real');
  limiteeixos([xmin, xmax], [ymin, ymax]);

  %---------- PLOT DO PONTO 63% ----------%
  plotponto(tempo_63_da_funcao_de_tranferencia, V63_funcao_de_tranferencia, 'k', xmin, ymin)
  legendas({'Variavel controlada real', 'Aproximação de primeira ordem',sprintf("tempo63 = %f  V63 = %f", tempo_63_da_funcao_de_tranferencia, V63_funcao_de_tranferencia) });

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DO FILTRO SUB AMOSTRADO E O DA FUNÇÃO APROXIMADA PARA COMPARAÇÃO ----------%
  figure
  %---------- PLOT DO FILTRO ----------%
  plotgrafico(tempo_plot, filtro, 'k', '');

  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs FILTRO')
  limiteeixos(tempo_plot, [min([filtro, y_step]), max([filtro, y_step])]);
  legendas({'Filtro', 'Função de transferência'});

  %---------- PRINTA OS ERROS DA FUNÇÃO COMPARADA COM O FILTRO ----------%
  fprintf("\nErros filtro vs função de transferência\n");
  y_step = y_step(1:length(filtro));
  erro_real_funcao_de_transferencia = abs(filtro - y_step);
  erro_maximo_funcao_de_transferencia = max(erro_real_funcao_de_transferencia)
  erro_medio_funcao_de_transferencia = mean(erro_real_funcao_de_transferencia)
  erro_rms_funcao_de_transferencia = sqrt(mean(erro_real_funcao_de_transferencia.^2))

  %---------- TEMPO DE ACOMODAÇÃO ESCOLHIDO PELO USUÁRIO ----------%
  fprintf("\nEscolha o tempo de acomodação em malha fechada.\nDica: pode usar [nº]e-n para indicar um número pequeno. Exemplo: 2e-3 para indicar 2 milisegundos\n\n");
  TSMF = input("Digite o tempo de acomodação desejado aqui: ");
  fprintf("\n");
  KPID = 4/(TSMF*k*b*a)

%---------- CALCULA KP E KI COM BASE NA METODOLOGIA PROPOSTA PELO ARTIGO ----------%
  KP = KPID*(a+b)
  KI = KPID*a*b
  KD = KPID

  %---------- ENCONTRA A FUNÇÃO DO PI BASEADA NA METODOLOGIA PROPOSTA NO ARTIGO ----------%
  fprintf("\nA função do controlador é dada por:\n");
  PID = KPID*(s+a)*(s+b)/s

  fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
  discretizacao = input('Digite sua escolha: ');
  fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(PID, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(PID, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

  %---------- ENCONTRA A FUNÇÃO EM MALHA ABERTA COMPENSADA ----------%
  MA = PID*funcao_aproximada;
  MA = minreal(MA);

  %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
  fprintf("\nA função em malha fechada é dada por:\n");
  funcao_em_malha_fechada = minreal(feedback(MA, 1))
  fprintf('\n');
  polo_malha_fechada = pole(funcao_em_malha_fechada)

  fprintf("\n")
  tempo_de_subida_malha_fechada = 2.2/(KPID*k*b*a)
  tempo_de_acomodacao_malha_fechada = 4/(KPID*k*b*a)

  %---------- CRIA UMA NOVA FIGURA COM O LUGAR GEOMETRICO DAS RAIZES COMPENSADO COM O PI ----------%
  lugar_das_raizes(MA, 'Lugar das raízes do sistema compensado');

  %---------- CRIA UMA NOVA FIGURA COM O DIAGRAMA DE BODE DO SISTEMAS EM MALHA ABERTA COMPENSADO ----------%
  plot_bode(MA, 'Diagrama de bode em malha aberta compensado');

  %----------  CRIA UMA NOVA FIGURA COM O PLOT DA FUNÇÃO EM MALHA FECHADA ----------%
##    [y_malha_fechada_feedback, x_malha_fechada_feedback] = step(funcao_em_malha_fechada_feedback,tempo(end));
  [y_malha_fechada, x_malha_fechada] = step(funcao_em_malha_fechada, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  [y_malha_aberta, x_malha_aberta] = step(funcao_aproximada/k, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));

  figure;
##    plotgrafico(x_malha_fechada_feedback, y_malha_fechada_feedback, 'b', '');
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', '');
  plotgrafico(x_malha_aberta, y_malha_aberta, 'r', 'Função em malha fechada');
  limiteeixos([0, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)])], [min([y_malha_aberta; y_malha_fechada]), max([y_malha_aberta; y_malha_fechada])]);
  legendas({'Função em malha fechada', 'Função em malha aberta dividido pelo ganho k'});

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', 'Função em malha fechada');
  limiteeixos([0, 2*tempo_de_acomodacao_malha_fechada], [min([y_malha_fechada]), max([y_malha_fechada])]);

end

%---------- CASO O USUÁRIO ESCOLHA APROXIMAR PARA UMA RESPOSTA DE SEGUNDA ORDEM SUPERAMORTECIDA PELO MÉTODO DE ZIEGLER-NICHOLS ----------%
if escolha == '3'

  %---------- ENCONTRA OS PARAMETROS NECESSÁRIOS PARA A APROXIMAÇÃO ----------%

  %---------- PONTO DE INFLEXÃO REAL -> derivada máxima (curvatura zero) ----------%

  dy = gradient(filtro(indice_tempo_degrau:end), tempo);
  [dmax, ind_inflexao] = max(dy)
  t_inflexao = tempo(ind_inflexao+indice_tempo_degrau-1)
  y_inflexao = filtro(ind_inflexao+indice_tempo_degrau-1)
  m = dmax

  %---------- RETA TANGENTE ----------%
  reta = y_inflexao + m * (tempo - t_inflexao);
  indice_ymin_reta = find(reta >= ymin, 1);
  indice_ymax_reta = find(reta >= ymax, 1);
  reta = reta(indice_ymin_reta - 1:indice_ymax_reta);
  tempo_reta = tempo(indice_ymin_reta-1:indice_ymax_reta);
  t_theta = (variavel_controlada_inicial - y_inflexao)/m + t_inflexao
  tempo_ZN = (variavel_controlada_final - y_inflexao)/m + t_inflexao

  %---------- PLOTA O GRÁFICO DO FILTRO COM TEMPO MORTO E DEMAIS PONTOS IMPORTANTES ----------%
  figure
  plotgrafico(tempo, filtro, 'b', '');
  plotgrafico(tempo_reta, reta, 'k', 'Pontos importantes')
  plotponto(t_theta, variavel_controlada_inicial, 'r', xmin, ymin);
  plotponto(tempo_ZN, variavel_controlada_final, 'green', xmin, ymin);
  plot(t_inflexao, y_inflexao, 'mo', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'm');
  limiteeixos(tempo, filtro);
  legendas({'Filtro','Reta tangente', sprintf('t theta = %f VC inicial = %f', t_theta, variavel_controlada_inicial), sprintf('tempo ZN = %f VC final = %f', tempo_ZN, variavel_controlada_final), sprintf('Ponto de inflexão')});

  %---------- ENCONTRANDO OS PARÂMETROS NECESSÁRIOS PARA A APROXIMAÇÃO  ----------%
  theta = t_theta - tempo_degrau
  tau = tempo_ZN - t_theta
  b = 1/tau
  a = 1/theta
  tempo_de_acomodacao = 4/abs(min([a, b]))

  fprintf('\nA função aproximada é:\n')
  funcao_aproximada = k*b*a/((s+b)*(s+a))
  fprintf('\n');
  polos = pole(funcao_aproximada)

    %---------- ERRO CASO DE POLOS POSITIVOS ----------%
  if max(real(polos)) > 0
    fprintf('\n\nImpossível aproximar\n');
    fprintf('Pressione qualquer tecla para continuar...');
    pause;
    system('cls');
    clc; clear; close all;
    continue;
  endif

  %---------- PLOTA O LUGAR GEOMETRICO DAS RAIZES E O DIAGRAMA DE BODE SEM COMPENSAÇÃO ----------%
if k > 0
  lugar_das_raizes(funcao_aproximada, 'Lugar das raízes do sistema sem compensação');

  elseif k < 0
  lugar_das_raizes(-funcao_aproximada, 'Lugar das raízes do sistema sem compensação');
end

  plot_bode(funcao_aproximada, 'Diagrama de bode em malha aberta');

  %---------- CRIA O VETOR COM O DEGRAU CRIADO COM OS DADOS DO USUÁRIO ----------%
  y_step = lsim(funcao_aproximada, u_plot, tempo_plot) + variavel_controlada_inicial;

  %---------- ENCONTRA O PONTO 63% DA FUNÇÃO APROXIMADA ----------%
  fprintf("\n");
  V63_funcao_de_tranferencia = (1-exp(-1))*(y_step(end) - y_step(1)) + y_step(1)
  idx_funcao_aproximada = find(y_step >= V63_funcao_de_tranferencia, 1);
  y1 = y_step(idx_funcao_aproximada - 1);
  y2 = y_step(idx_funcao_aproximada);
  t1 = tempo_plot(idx_funcao_aproximada-1);
  t2 = tempo_plot(idx_funcao_aproximada);

  %---------- FAZ UMA INTERPOLAÇÃO SIMPLES PARA ENCONTRAR O VALOR MAIS EXATO ----------%
  tempo_63_da_funcao_de_tranferencia = t1 + (V63_funcao_de_tranferencia - y1)*(t2 - t1)/(y2-y1)

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DOS DADOS ORIGINAIS SUB AMOSTRADO E A RESPOSTA DA FUNÇÃO ----------%
  figure
  %---------- PLOT DOS DADOS ORIGINAIS ----------%
  plotgrafico(tempo_plot, y_plot, 'b', '')

  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real')
  limiteeixos([xmin, xmax], [ymin, ymax]);
  legendas({'Variavel controlada real', 'Aproximação de primeira ordem'});

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DOS DADOS ORIGINAIS SUB AMOSTRADO E A RESPOSTA DA FUNÇÃO ----------%
  figure
  %---------- PLOT DOS DADOS ORIGINAIS ----------%
  plotgrafico(tempo_plot, y_plot, 'b', '')
  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real');
  limiteeixos([xmin, xmax], [ymin, ymax]);

  %---------- PLOT DO PONTO 63% ----------%
  plotponto(tempo_63_da_funcao_de_tranferencia, V63_funcao_de_tranferencia, 'k', xmin, ymin)
  legendas({'Variavel controlada real', 'Aproximação de primeira ordem',sprintf("tempo63 = %f  V63 = %f", tempo_63_da_funcao_de_tranferencia, V63_funcao_de_tranferencia) });

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DO FILTRO SUB AMOSTRADO E O DA FUNÇÃO APROXIMADA PARA COMPARAÇÃO ----------%
  figure
  %---------- PLOT DO FILTRO ----------%
  plotgrafico(tempo_plot, filtro, 'k', '');

  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs FILTRO')
  limiteeixos(tempo_plot, [min([filtro, y_step]), max([filtro, y_step])]);
  legendas({'Filtro', 'Função de transferência'});

  %---------- PRINTA OS ERROS DA FUNÇÃO COMPARADA COM O FILTRO ----------%
  fprintf("\nErros filtro vs função de transferência\n");
  y_step = y_step(1:length(filtro));
  erro_real_funcao_de_transferencia = abs(filtro - y_step);
  erro_maximo_funcao_de_transferencia = max(erro_real_funcao_de_transferencia)
  erro_medio_funcao_de_transferencia = mean(erro_real_funcao_de_transferencia)
  erro_rms_funcao_de_transferencia = sqrt(mean(erro_real_funcao_de_transferencia.^2))

  %---------- TEMPO DE ACOMODAÇÃO ESCOLHIDO PELO USUÁRIO ----------%
  fprintf("\nEscolha o tempo de acomodação em malha fechada.\nDica: pode usar [nº]e-n para indicar um número pequeno. Exemplo: 2e-3 para indicar 2 milisegundos\n\n");
  TSMF = input("Digite o tempo de acomodação desejado aqui: ");
  fprintf("\n");
  KPID = 4/(TSMF*k*b*a)

%---------- CALCULA KP E KI COM BASE NA METODOLOGIA PROPOSTA PELO ARTIGO ----------%
  KP = KPID*(a+b)
  KI = KPID*a*b
  KD = KPID

  %---------- ENCONTRA A FUNÇÃO DO PI BASEADA NA METODOLOGIA PROPOSTA NO ARTIGO ----------%
  fprintf("\nA função do controlador é dada por:\n");
  PID = KPID*(s+a)*(s+b)/s

  fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
  discretizacao = input('Digite sua escolha: ');
  fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(PID, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(PID, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

  %---------- ENCONTRA A FUNÇÃO EM MALHA ABERTA COMPENSADA ----------%
  MA = PID*funcao_aproximada;
  MA = minreal(MA);

  %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
  fprintf("\nA função em malha fechada é dada por:\n");
  funcao_em_malha_fechada = minreal(feedback(MA, 1))
  fprintf('\n');
  polo_malha_fechada = pole(funcao_em_malha_fechada)

  fprintf("\n")
  tempo_de_subida_malha_fechada = 2.2/(KPID*k*b*a)
  tempo_de_acomodacao_malha_fechada = 4/(KPID*k*b*a)

  %---------- CRIA UMA NOVA FIGURA COM O LUGAR GEOMETRICO DAS RAIZES COMPENSADO COM O PI ----------%
  lugar_das_raizes(MA, 'Lugar das raízes do sistema compensado');

  %---------- CRIA UMA NOVA FIGURA COM O DIAGRAMA DE BODE DO SISTEMAS EM MALHA ABERTA COMPENSADO ----------%
  plot_bode(MA, 'Diagrama de bode em malha aberta compensado');

  %----------  CRIA UMA NOVA FIGURA COM O PLOT DA FUNÇÃO EM MALHA FECHADA ----------%
  [y_malha_fechada, x_malha_fechada] = step(funcao_em_malha_fechada, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  [y_malha_aberta, x_malha_aberta] = step(funcao_aproximada/k, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', '');
  plotgrafico(x_malha_aberta, y_malha_aberta, 'r', 'Função em malha fechada');
  limiteeixos([0, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)])], [min([y_malha_aberta; y_malha_fechada]), max([y_malha_aberta; y_malha_fechada])]);
  legendas({'Função em malha fechada', 'Função em malha aberta dividido pelo ganho k'});

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', 'Função em malha fechada');
  limiteeixos([0, 2*tempo_de_acomodacao_malha_fechada], [min([y_malha_fechada]), max([y_malha_fechada])]);

end

%---------- CASO O USUÁRIO ESCOLHA APROXIMAR PARA UMA RESPOSTA DE SEGUNDA ORDEM SUPERAMORTECIDA DE FASE NÃO MINIMA ----------%
if escolha == '4'

  %---------- ENCONTRA OS PARAMETROS NECESSÁRIOS PARA A APROXIMAÇÃO ----------%

  %---------- ENCONTRA O VALOR DE 63% COMO ESTABELECIDO NO ARTIGO ----------%
  V63 = (1-exp(-1))*(variavel_controlada_final - variavel_controlada_inicial) + variavel_controlada_inicial

  %---------- ENCONTRA A POSIÇÃO DO VETOR ONDE É IMEDIATAMENTE MAIOR OU IGUAL A V63 ----------%
  idx = find(filtro(indice_tempo_degrau:end) >= V63, 1) + indice_tempo_degrau - 1;
  %---------- ENCONTRA O VETOR LOGO NA POSIÇÃO ANTERIOR ----------%
  y1 = filtro(idx-1);
  %---------- ENCONTRA A POSIÇÃO DO V63 ----------%
  y2 = filtro(idx);
  %---------- ENCONTRA O TEMPO ANTERIOR AO ATINGIR 63% ----------%
  t1 = tempo(idx-1);
  %---------- ENCONTRA O TEMPO DO V63 ----------%
  t2 = tempo(idx);
  %---------- FAZ UMA INTERPOLAÇÃO SIMPLES ENTRE OS 2 PONTOS PARA UMA APROXIMAÇÃO MAIS EXATA ----------%
  tempo_63 = t1 + (V63 - y1) * (t2 - t1) / (y2 - y1)

  %---------- ENCONTRA OS PARAMETROS NECESSÁRIOS PARA A APROXIMAÇÃO ----------%

  [m, indice_ponto_minimo] = min(filtro(indice_tempo_degrau:end));

  indice_ponto_minimo = indice_ponto_minimo + indice_tempo_degrau - 1;

  indice_tempo_morto = find(filtro(indice_ponto_minimo:end)>=variavel_controlada_inicial, 1);
  indice_tempo_morto = indice_tempo_morto + indice_ponto_minimo - 1;
  y2 = filtro(indice_tempo_morto);
  y1 = filtro(indice_tempo_morto-1);
  x2 = tempo(indice_tempo_morto);
  x1 = tempo(indice_tempo_morto-1);

  %---------- FAZ INTERPOLAÇÃO SIMPLES PARA ENCONTRAR UM TEMPO MORTO MAIS PRÓXIMO DO REAL UTILIZANDO EQUAÇÃO DA RETA ----------%
  m = (y2-y1)/(x2-x1);
  t_theta = (variavel_controlada_inicial - y1)/m + x1

  %---------- PLOTA O GRÁFICO DO FILTRO COM TEMPO MORTO E PONTO 63% ----------%
  figure
  plotgrafico(tempo, filtro, 'b', 'Pontos importantes');
  plotponto(t_theta, variavel_controlada_inicial, 'k', xmin, ymin);
  plotponto(tempo_63, V63, 'r', xmin, ymin);
  limiteeixos(tempo, filtro);
  legendas({'Filtro', sprintf('t theta = %f VC inicial = %f', t_theta, variavel_controlada_inicial), sprintf('tempo63 = %f VC63 = %f', tempo_63, V63)});

  %---------- ENCONTRANDO OS PARÂMETROS NECESSÁRIOS PARA A APROXIMAÇÃO  ----------%
  theta = t_theta - tempo_degrau
  tau = tempo_63 - t_theta
  b = 1/tau
  a = 2/theta
  tempo_de_acomodacao = 4/abs(min([a, b]))

  %---------- APROXIMA A RESPOSTA PARA UMA FUNCAO E ENCONTRA OS POLOS E O STEP ----------%
  fprintf('\nA função aproximada é:\n')
  funcao_aproximada = -k*b*(s - a)/((s + b)*(s + a))
  fprintf('\n');
  polos = pole(funcao_aproximada)
  zeros = zero(funcao_aproximada)

    %---------- ERRO CASO DE POLOS POSITIVOS ----------%
  if max(real(polos)) > 0
    fprintf('\n\nImpossível aproximar\n');
    fprintf('Pressione qualquer tecla para continuar...');
    pause;
    system('cls');
    clc; clear; close all;
    continue;
  endif

  %---------- PLOTA O LUGAR GEOMETRICO DAS RAIZES E O DIAGRAMA DE BODE SEM COMPENSAÇÃO ----------%
if k > 0
  lugar_das_raizes(funcao_aproximada, 'Lugar das raízes do sistema sem compensação');

  elseif k < 0
  lugar_das_raizes(-funcao_aproximada, 'Lugar das raízes do sistema sem compensação');
end

  plot_bode(funcao_aproximada, 'Diagrama de bode em malha aberta');

  %---------- CRIA O VETOR COM O DEGRAU CRIADO COM OS DADOS DO USUÁRIO ----------%
  y_step = lsim(funcao_aproximada, u_plot, tempo_plot) + variavel_controlada_inicial;

  %---------- ENCONTRA O PONTO 63% DA FUNÇÃO APROXIMADA ----------%
  fprintf("\n");
  V63_funcao_de_tranferencia = (1-exp(-1))*(y_step(end) - y_step(1)) + y_step(1)
  idx_funcao_aproximada = find(y_step >= V63_funcao_de_tranferencia, 1);
  y1 = y_step(idx_funcao_aproximada - 1);
  y2 = y_step(idx_funcao_aproximada);
  t1 = tempo_plot(idx_funcao_aproximada-1);
  t2 = tempo_plot(idx_funcao_aproximada);

  %---------- FAZ UMA INTERPOLAÇÃO SIMPLES PARA ENCONTRAR O VALOR MAIS EXATO ----------%
  tempo_63_da_funcao_de_tranferencia = t1 + (V63_funcao_de_tranferencia - y1)*(t2 - t1)/(y2-y1)

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DOS DADOS ORIGINAIS SUB AMOSTRADO E A RESPOSTA DA FUNÇÃO ----------%
  figure
  %---------- PLOT DOS DADOS ORIGINAIS ----------%
  plotgrafico(tempo_plot, y_plot, 'b', '')

  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real')
  limiteeixos([xmin, xmax], [ymin, ymax]);
  legendas({'Variavel controlada real', 'Aproximação de primeira ordem'});

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DOS DADOS ORIGINAIS SUB AMOSTRADO E A RESPOSTA DA FUNÇÃO ----------%
  figure
  %---------- PLOT DOS DADOS ORIGINAIS ----------%
  plotgrafico(tempo_plot, y_plot, 'b', '')
  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real');
  limiteeixos([xmin, xmax], [ymin, ymax]);

  %---------- PLOT DO PONTO 63% ----------%
  plotponto(tempo_63_da_funcao_de_tranferencia, V63_funcao_de_tranferencia, 'k', xmin, ymin)
  legendas({'Variavel controlada real', 'Aproximação de primeira ordem',sprintf("tempo63 = %f  V63 = %f", tempo_63_da_funcao_de_tranferencia, V63_funcao_de_tranferencia) });

  %---------- CRIA UMA NOVA FIGURA COM O PLOT DO FILTRO SUB AMOSTRADO E O DA FUNÇÃO APROXIMADA PARA COMPARAÇÃO ----------%
  figure
  %---------- PLOT DO FILTRO ----------%
  plotgrafico(tempo_plot, filtro, 'k', '');

  %---------- PLOT DA FUNÇÃO ----------%
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs FILTRO')
  limiteeixos(tempo_plot, [min([filtro, y_step]), max([filtro, y_step])]);
  legendas({'Filtro', 'Função de transferência'});

  %---------- PRINTA OS ERROS DA FUNÇÃO COMPARADA COM O FILTRO ----------%
  fprintf("\nErros filtro vs função de transferência\n");
  y_step = y_step(1:length(filtro));
  erro_real_funcao_de_transferencia = abs(filtro - y_step);
  erro_maximo_funcao_de_transferencia = max(erro_real_funcao_de_transferencia)
  erro_medio_funcao_de_transferencia = mean(erro_real_funcao_de_transferencia)
  erro_rms_funcao_de_transferencia = sqrt(mean(erro_real_funcao_de_transferencia.^2))

    %---------- CALCULA O MENOR TEMPO DE ACOMODAÇÃO ACEITAVEL PARA O SISTEMA ----------%
    fprintf("\nEscolha o tempo de acomodação em malha fechada.\nDica: pode usar [nº]e-n para indicar um número pequeno. Exemplo: 2e-3 para indicar 2 milisegundos\n\n");
    TSMF = input('Digite o tempo de acomodação desejado: ');
    fprintf("\n")

    %---------- CALCULO DO POLO DOMINANTE COM O TEMPO DE ACOMODAÇÃO DESEJADO PELO USUÁRIO ----------%
    polo_alocado = - 4 /TSMF
    zpi = polos(1)
    zpd = polos(2)

    %---------- GERA O PI UNITÁRIO ----------%
    PI_ganho_unitario = zpk([zpi, zpd], 0, 1);

    %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PI_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPI PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPID = 1/abs(MA_VALOR);

    if k > 0
      KPID = KPID
    elseif k < 0
      KPID = -KPID
    endif

    %---------- NOVO PI COM O GANHO CALCULADO ----------%

    KP = -KPID*(zpi+zpd)
    KI = KPID*zpi*zpd
    KD = KPID
    fprintf('\nO controlador é dado por:\n')
    controlador = zpk([zpi, zpd], 0, KPID)

    fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
    discretizacao = input('Digite sua escolha: ');
    fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(controlador, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(controlador, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

    %---------- MALHA ABERTA COM O CONTROLADOR PI ----------%
    MA = controlador*funcao_aproximada;
    MA = minreal(MA);

    %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
    fprintf("\nA função em malha fechada é dada por:\n");
    funcao_em_malha_fechada = minreal(feedback(MA, 1))
    fprintf('\n');
    polos_malha_fechada = pole(funcao_em_malha_fechada)
    zeros_malha_fechada = zero(funcao_em_malha_fechada)

    fprintf("\n")
    polo_dominante_malha_fechada = max(real(polos_malha_fechada))
    tempo_de_acomodacao_malha_fechada = 4/abs(polo_dominante_malha_fechada)

      %---------- LUGAR DAS RAÍZES E O DIAGRAMA DE BODE ----------%
  lugar_das_raizes(MA, 'Lugar das raízes com compensação');
  plot_bode(MA, 'Diagrama de bode em malha aberta compensado');

  %----------  CRIA UMA NOVA FIGURA COM O PLOT DA FUNÇÃO EM MALHA FECHADA ----------%
  [y_malha_fechada, x_malha_fechada] = step(funcao_em_malha_fechada, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  [y_malha_aberta, x_malha_aberta] = step(funcao_aproximada/k, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', '');
  plotgrafico(x_malha_aberta, y_malha_aberta, 'r', 'Função em malha fechada');
  limiteeixos([0, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)])], [min([y_malha_aberta; y_malha_fechada]), max([y_malha_aberta; y_malha_fechada])]);
  legendas({'Função em malha fechada', 'Função em malha aberta dividido pelo ganho k'});

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', 'Função em malha fechada');
  limiteeixos([0, 2*tempo_de_acomodacao_malha_fechada], [min([y_malha_fechada]), max([y_malha_fechada])]);


  endif

%---------- CASO O USUÁRIO ESCOLHA APROXIMAR PARA UMA RESPOSTA DE SEGUNDA ORDEM SUBAMORTECIDA ----------%
if escolha == '5'
  %---------- ENCONTRA OS PARAMETROS NECESSÁRIOS PARA A APROXIMAÇÃO ----------%
  [VCpico, idx_pico] = max(filtro(indice_tempo_degrau:end));
  idx_pico = idx_pico + indice_tempo_degrau - 1;
  VCpico = VCpico
  TVCmax = tempo(idx_pico)
  Tp = TVCmax - tempo_degrau
  k = k
  UP = (VCpico - variavel_controlada_final)/(variavel_controlada_final - variavel_controlada_inicial)*100
  fator_de_amortecimento = (-log(UP/100)/sqrt(pi^2 + log(UP/100)^2))
  wn = pi/(Tp*sqrt(1-fator_de_amortecimento^2))
  tempo_de_acomodacao = 4/(fator_de_amortecimento*wn)

  %---------- PLOTA O GRÁFICO DO FILTRO COM O PONTO MÁXIMO ----------%
  figure
  plotgrafico(tempo_plot, filtro, 'r', 'Tempo de pico');
  plotponto(TVCmax, VCpico, 'k', xmin, ymin);
  limiteeixos(tempo_plot, filtro);
  legendas({'Filtro', sprintf('TVCmax = %f VCpico = %f', TVCmax, VCpico)});

  %---------- APROXIMA A RESPOSTA PARA UMA FUNCAO E ENCONTRA OS POLOS E O STEP ----------%
  fprintf('\nA função aproximada é:\n')
  funcao_aproximada = k*wn^2/(s^2 + 2*fator_de_amortecimento*wn*s + wn^2)
  fprintf('\n');
  polos = pole(funcao_aproximada)

    %---------- ERRO CASO DE POLOS POSITIVOS ----------%
  if max(real(polos)) > 0
    fprintf('\n\nImpossível aproximar\n');
    fprintf('Pressione qualquer tecla para continuar...');
    pause;
    system('cls');
    clc; clear; close all;
    continue;
  endif

  y_step = lsim(funcao_aproximada, u_plot, tempo_plot) + variavel_controlada_inicial;

  %---------- PLOTA A RESPOSTA DA FUNÇÃO COM A RESPOSTA REAL DO SISTEMAS ----------%
  figure
  plotgrafico(tempo_plot, variavel_controlada, 'b', '');
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real');
  limiteeixos([xmin, xmax], [ymin, ymax]);
  legendas({'Resposta real', 'Função aproximada'});

  %---------- PLOTA O FILTRO COM A RESPOSTA DA FUNÇÃO APROXIMADA ----------%
  figure
  plotgrafico(tempo_plot, filtro, 'k', '');
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs FILTRO');
  limiteeixos([xmin, xmax], [min([filtro; y_step]), max([filtro; y_step])]);
  legendas({'Filtro', 'Função aproximada'});

  [VCpico_funcao, idx_pico_funcao] = max(y_step);
  tvc_max_funcao = tempo_plot(idx_pico_funcao);

  %---------- PLOTA A FUNÇÃO COM O PONTO MÁXIMO ----------%
  figure
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada com o ponto máximo');
  plotponto(tvc_max_funcao, VCpico_funcao, 'k', xmin, min(y_step));
  limiteeixos([xmin; xmax], y_step);
  legendas({'Função aproximada', sprintf('TVCmax = %f VCpico = %f', tvc_max_funcao, VCpico_funcao)});

  %---------- PRINTA OS ERROS DA FUNÇÃO COMPARADA COM O FILTRO ----------%
  fprintf("\nErros filtro vs função de transferência\n");
  y_step = y_step(1:length(filtro));
  erro_real_funcao_de_transferencia = abs(filtro - y_step);
  erro_maximo_funcao_de_transferencia = max(erro_real_funcao_de_transferencia)
  erro_medio_funcao_de_transferencia = mean(erro_real_funcao_de_transferencia)
  erro_rms_funcao_de_transferencia = sqrt(mean(erro_real_funcao_de_transferencia.^2))

  %---------- PLOTA O LUGAR GEOMETRICO DAS RAÍZES ----------%
if k>0
  lugar_das_raizes(funcao_aproximada, 'Lugar das raízes sem compensação');
elseif k<0
  lugar_das_raizes(-funcao_aproximada, 'Lugar das raízes sem compensação');
end

  %---------- PLOTA O DIAGRAMA DE BODE DA FUNÇÃO APROXIMADA ----------%
  plot_bode(funcao_aproximada, 'Diagrama de bode em malha aberta');

  %---------- PERGUNTA O TEMPO DE ACOMODAÇÃO DESEJADO PELO PROJETISTA ----------%
  fprintf("\nEscolha o tempo de acomodação em malha fechada.\nDica: pode usar [nº]e-n para indicar um número pequeno. Exemplo: 2e-3 para indicar 2 milisegundos\n\n");
  TSMF_segunda_ordem_sub = input("Digite o tempo de acomodação desejado aqui: ");
  fprintf("\n");

  %---------- CÁLCULO DO KPID ----------%
  KPID = 4/(k*(wn^2)*TSMF_segunda_ordem_sub)
  KP = 2*fator_de_amortecimento*wn*KPID
  KI = KPID*wn^2
  KD = KPID

  %---------- PID ----------%
  fprintf('\nO controlador é dado por:\n')
  PID = zpk(polos, 0, KPID)

    fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
    discretizacao = input('Digite sua escolha: ');
    fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(PID, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(PID, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

  %---------- MALHA ABERTA COM O PID ----------%
  MA = PID*funcao_aproximada;
  MA = minreal(MA);

  %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
  fprintf("\nA função em malha fechada é dada por:\n");
  funcao_em_malha_fechada = k*(wn^2)*KPID/(s+k*(wn^2)*KPID)
  fprintf('\n');
  polo_malha_fechada = pole(funcao_em_malha_fechada)

  fprintf("\n")
  tempo_de_subida_malha_fechada = 2.2/(k*(wn^2)*KPID)
  tempo_de_acomodacao_malha_fechada = 4/(k*(wn^2)*KPID)

  %---------- LUGAR DAS RAÍZES E O DIAGRAMA DE BODE ----------%
  lugar_das_raizes(MA, 'Lugar das raízes com compensação');
  plot_bode(MA, 'Diagrama de bode em malha aberta compensado');

  %----------  CRIA UMA NOVA FIGURA COM O PLOT DA FUNÇÃO EM MALHA FECHADA ----------%
  [y_malha_fechada, x_malha_fechada] = step(funcao_em_malha_fechada, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  [y_malha_aberta, x_malha_aberta] = step(funcao_aproximada/k, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', '');
  plotgrafico(x_malha_aberta, y_malha_aberta, 'r', 'Função em malha fechada');
  limiteeixos([0, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)])], [min([y_malha_aberta; y_malha_fechada]), max([y_malha_aberta; y_malha_fechada])]);
  legendas({'Função em malha fechada', 'Função em malha aberta dividido pelo ganho k'});

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', 'Função em malha fechada');
  limiteeixos([0, 2*tempo_de_acomodacao_malha_fechada], [min([y_malha_fechada]), max([y_malha_fechada])]);

end

%---------- APROXIMAÇÃO DE TERCEIRA ORDEM DE FASE NÃO MÍNIMA ----------%

if escolha == '6'

  %---------- ENCONTRA OS PARAMETROS NECESSÁRIOS PARA A APROXIMAÇÃO ----------%

  [m, indice_ponto_minimo] = min(filtro(indice_tempo_degrau:end));

  indice_ponto_minimo = indice_ponto_minimo + indice_tempo_degrau - 1;

  indice_tempo_morto = find(filtro(indice_ponto_minimo:end)>=variavel_controlada_inicial, 1);
  indice_tempo_morto = indice_tempo_morto + indice_ponto_minimo - 1;
  y2 = filtro(indice_tempo_morto);
  y1 = filtro(indice_tempo_morto-1);
  x2 = tempo(indice_tempo_morto);
  x1 = tempo(indice_tempo_morto-1);

  %---------- FAZ INTERPOLAÇÃO SIMPLES PARA ENCONTRAR UM TEMPO MORTO MAIS PRÓXIMO DO REAL UTILIZANDO EQUAÇÃO DA RETA ----------%
  m = (y2-y1)/(x2-x1);
  t_theta = (variavel_controlada_inicial - y1)/m + x1

  theta = t_theta - tempo_degrau

  [VCpico, idx_pico] = max(filtro(indice_tempo_degrau:end));
  idx_pico = idx_pico + indice_tempo_degrau - 1;
  VCpico = VCpico
  TVCmax = tempo(idx_pico)
  Tp = TVCmax - t_theta
  k = k
  UP = (VCpico - variavel_controlada_final)/(variavel_controlada_final - variavel_controlada_inicial)*100
  fator_de_amortecimento = (-log(UP/100)/sqrt(pi^2 + log(UP/100)^2))
  wn = pi/(Tp*sqrt(1-fator_de_amortecimento^2))
  tempo_de_acomodacao = 4/(fator_de_amortecimento*wn)

    %---------- FUNÇÃO APROXIMADA ----------%
  fprintf('\nA função aproximada é:\n')
  funcao_aproximada = -k*(wn^2)*(s-2/theta)/((s^2 + 2*fator_de_amortecimento*wn*s + wn^2)*(s+2/theta))
  fprintf('\n');
  polos = pole(funcao_aproximada)

    %---------- ERRO CASO DE POLOS POSITIVOS ----------%
  if max(real(polos)) > 0
    fprintf('\n\nImpossível aproximar\n');
    fprintf('Pressione qualquer tecla para continuar...');
    pause;
    system('cls');
    clc; clear; close all;
    continue;
  endif

  zeros = zero(funcao_aproximada)
  y_step = lsim(funcao_aproximada, u_plot, tempo_plot) + variavel_controlada_inicial;

  %---------- PLOTA O GRÁFICO DO FILTRO COM TEMPO MORTO E PONTO MAXIMO ----------%
  figure
  plotgrafico(tempo, filtro, 'b', 'Pontos importantes');
  plotponto(t_theta, variavel_controlada_inicial, 'k', xmin, ymin);
  plotponto(TVCmax, VCpico, 'r', xmin, ymin);
  limiteeixos(tempo, filtro);
  legendas({'Filtro', sprintf('t theta = %f VC inicial = %f', t_theta, variavel_controlada_inicial), sprintf('tempo máximo = %f VC pico = %f', TVCmax, VCpico)});

  %---------- PLOTA A RESPOSTA DA FUNÇÃO COM A RESPOSTA REAL DO SISTEMAS ----------%
  figure
  plotgrafico(tempo_plot, variavel_controlada, 'b', '');
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real');
  limiteeixos([xmin, xmax], [ymin, ymax]);
  legendas({'Resposta real', 'Função aproximada'});

  %---------- PLOTA O FILTRO COM A RESPOSTA DA FUNÇÃO APROXIMADA ----------%
  figure
  plotgrafico(tempo_plot, filtro, 'k', '');
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs FILTRO');
  limiteeixos([xmin, xmax], [min([filtro; y_step]), max([filtro; y_step])]);
  legendas({'Filtro', 'Função aproximada'});

  [VCpico_funcao, idx_pico_funcao] = max(y_step);
  tvc_max_funcao = tempo_plot(idx_pico_funcao);

  %---------- PLOTA A FUNÇÃO COM O PONTO MÁXIMO ----------%
  figure
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada com o ponto máximo');
  plotponto(tvc_max_funcao, VCpico_funcao, 'k', xmin, min(y_step));
  limiteeixos([xmin; xmax], y_step);
  legendas({'Função aproximada', sprintf('TVCmax = %f VCpico = %f', tvc_max_funcao, VCpico_funcao)});

  %---------- PRINTA OS ERROS DA FUNÇÃO COMPARADA COM O FILTRO ----------%
  fprintf("\nErros filtro vs função de transferência\n");
  y_step = y_step(1:length(filtro));
  erro_real_funcao_de_transferencia = abs(filtro - y_step);
  erro_maximo_funcao_de_transferencia = max(erro_real_funcao_de_transferencia)
  erro_medio_funcao_de_transferencia = mean(erro_real_funcao_de_transferencia)
  erro_rms_funcao_de_transferencia = sqrt(mean(erro_real_funcao_de_transferencia.^2))

  %---------- PLOTA O LUGAR GEOMETRICO DAS RAÍZES ----------%
if k>0
  lugar_das_raizes(funcao_aproximada, 'Lugar das raízes sem compensação');
elseif k<0
  lugar_das_raizes(-funcao_aproximada, 'Lugar das raízes sem compensação');
end

  %---------- PLOTA O DIAGRAMA DE BODE DA FUNÇÃO APROXIMADA ----------%
  plot_bode(funcao_aproximada, 'Diagrama de bode em malha aberta');

    %---------- CALCULA O MENOR TEMPO DE ACOMODAÇÃO ACEITAVEL PARA O SISTEMA ----------%
    tempo_de_acomodacao_minimo_aceitavel = 2*4 / abs(max(real(polos)));
    fprintf('\nO menor tempo de acomodação aceitável para esse sistema é %e segundos.\n', tempo_de_acomodacao_minimo_aceitavel)
    TSMF_segunda_ordem_com_um_zero = input('Sabendo o tempo de acomodação minimo aceitável, digite o tempo de acomodação desejado: ');
    fprintf('\n')
    polo_alocado = - 4 /TSMF_segunda_ordem_com_um_zero

    fprintf('\nDeseja um PID com zeros complexos, um PID com zeros reais ou um PI?\n[1] PID com zeros complexos\n[2] PID com zeros reais\n[3] PI\n')
    escolha_controlador_fase_nao_minima = input('Digite sua escolha: ');
    fprintf('\n')

    if escolha_controlador_fase_nao_minima == 1

    %---------- GERA O PI UNITÁRIO ----------%
    PID_ganho_unitario = (s^2 + 2*fator_de_amortecimento*wn*s + wn^2)/s;

    %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PID_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPI PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPID = 1/abs(MA_VALOR);

    if k > 0
      KPID = KPID
    elseif k < 0
      KPID = -KPID
    endif

    %---------- NOVO PI COM O GANHO CALCULADO ----------%

    KP = KPID*2*fator_de_amortecimento*wn
    KI = KPID*wn^2
    KD = KPID
    fprintf('\nO controlador é dado por:\n')
    controlador = KPID*PID_ganho_unitario

  elseif escolha_controlador_fase_nao_minima == 2

    %---------- CALCULO DO POLO DOMINANTE COM O TEMPO DE ACOMODAÇÃO DESEJADO PELO USUÁRIO ----------%
    zpi = 10*min(real(polos))
    zpd = -2/theta

    %---------- GERA O PI UNITÁRIO ----------%
    PID_ganho_unitario = zpk([zpi, zpd], 0, 1);

    %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PID_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPI PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPID = 1/abs(MA_VALOR);

    if k > 0
      KPID = KPID
    elseif k < 0
      KPID = -KPID
    endif

    %---------- NOVO PI COM O GANHO CALCULADO ----------%

    KP = -KPID*(zpi+zpd)
    KI = KPID*zpi*zpd
    KD = KPID
    fprintf('\nO controlador é dado por:\n')
    controlador = zpk([zpi, zpd], 0, KPID)

  elseif escolha_controlador_fase_nao_minima == 3
    %---------- CALCULO DO POLO DOMINANTE COM O TEMPO DE ACOMODAÇÃO DESEJADO PELO USUÁRIO ----------%
    zpi = -2/theta

    %---------- GERA O PI UNITÁRIO ----------%
    PI_ganho_unitario = zpk(zpi, 0, 1);

    %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PI_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPI PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPI = 1/abs(MA_VALOR);

    if k > 0
      KPI = KPI
    elseif k < 0
      KPI = -KPI
    endif

    %---------- NOVO PI COM O GANHO CALCULADO ----------%

    KP = KPI
    KI = -KPI*zpi
    fprintf('\nO controlador é dado por:\n')
    controlador = zpk(zpi, 0, KPI)

  else

    fprintf('\nOpção inválida\n');
    fprintf('\nPressione qualquer tecla para finalizar...')
    pause;
    continue;

    endif

    fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
    discretizacao = input('Digite sua escolha: ');
    fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(controlador, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(controlador, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif


    %---------- MALHA ABERTA COM O CONTROLADOR PI ----------%
    MA = controlador*funcao_aproximada;
    MA = minreal(MA);

    %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
    fprintf("\nA função em malha fechada é dada por:\n");
    funcao_em_malha_fechada = minreal(feedback(MA, 1))
    fprintf('\n');
    polos_malha_fechada = pole(funcao_em_malha_fechada)
    zeros_malha_fechada = zero(funcao_em_malha_fechada)

    fprintf("\n")
    polo_dominante_malha_fechada = max(real(polos_malha_fechada))
    tempo_de_acomodacao_malha_fechada = 4/abs(polo_dominante_malha_fechada)

      %---------- LUGAR DAS RAÍZES E O DIAGRAMA DE BODE ----------%
  lugar_das_raizes(MA, 'Lugar das raízes com compensação');
  plot_bode(MA, 'Diagrama de bode em malha aberta compensado');

  %----------  CRIA UMA NOVA FIGURA COM O PLOT DA FUNÇÃO EM MALHA FECHADA ----------%
  [y_malha_fechada, x_malha_fechada] = step(funcao_em_malha_fechada, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  [y_malha_aberta, x_malha_aberta] = step(funcao_aproximada/k, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', '');
  plotgrafico(x_malha_aberta, y_malha_aberta, 'r', 'Função em malha fechada');
  limiteeixos([0, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)])], [min([y_malha_aberta; y_malha_fechada]), max([y_malha_aberta; y_malha_fechada])]);
  legendas({'Função em malha fechada', 'Função em malha aberta dividido pelo ganho k'});

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', 'Função em malha fechada');
  limiteeixos([0, 2*tempo_de_acomodacao_malha_fechada], [min([y_malha_fechada]), max([y_malha_fechada])]);

endif



  %---------- CASO O USUÁRIO ESCOLHA APROXIMAR PARA UMA RESPOSTA DE SEGUNDA ORDEM COM UM ZERO ----------%

  if escolha == '7'

    %---------- ENCONTRA OS PARAMETROS NECESSÁRIOS PARA A APROXIMAÇÃO ----------%

  [y_pico_1, indice_pico_1] = max(filtro(indice_tempo_degrau:end));

  indice_pico_1 = indice_pico_1 + indice_tempo_degrau - 1;
  y_pico_1 = y_pico_1
  t_pico_1 = tempo(indice_pico_1)

  [y_minimo_funcao_segunda_ordem_com_zero,indice_ponto_minimo_apos_pico_1] = min(filtro(indice_pico_1:end));
  indice_ponto_minimo_apos_pico_1 = indice_ponto_minimo_apos_pico_1 + indice_pico_1 - 1;

  [y_pico_2, indice_pico_2] = max(filtro(indice_ponto_minimo_apos_pico_1:end));
  y_pico_2 = y_pico_2
  t_pico_2 = tempo(indice_pico_2 + indice_ponto_minimo_apos_pico_1 -1)

  y_regime_permanente = variavel_controlada_final
  UP = (y_pico_1 - y_regime_permanente)/(y_regime_permanente - variavel_controlada_inicial)*100
  Tb = (t_pico_2 - t_pico_1)
  fprintf('\n');
  a = log((variavel_controlada_final-y_pico_1)/(variavel_controlada_final-y_pico_2))/Tb
  b = 2*pi/Tb
  z = a - b/tan(b*(t_pico_1 - tempo_degrau))
  c = k*(a^2+b^2)/z
  G = sqrt(1 + ((a*z-a^2-b^2)/(b*z))^2)
  tempo_de_acomodacao = -log(0.02/G)/a

  %---------- FUNÇÃO APROXIMADA ----------%
  fprintf('\nA função aproximada é:\n')
  funcao_aproximada = c*(s+z)/(s^2+2*a*s+a^2+b^2)
  fprintf('\n');
  polos = pole(funcao_aproximada)

    %---------- ERRO CASO DE POLOS POSITIVOS ----------%
  if max(real(polos)) > 0
    fprintf('\n\nImpossível aproximar\n');
    fprintf('Pressione qualquer tecla para continuar...');
    pause;
    system('cls');
    clc; clear; close all;
    continue;
  endif

  zeros = zero(funcao_aproximada)
  y_step = lsim(funcao_aproximada, u_plot, tempo_plot) + variavel_controlada_inicial;
  minimo_filtro = min(filtro);

  %---------- PLOTA O GRÁFICO DO FILTRO COM DOIS PICOS CONSECUTIVOS ----------%
  figure
  plotgrafico(tempo, filtro, 'b', 'Picos');
  plotponto(t_pico_1, y_pico_1, 'k', xmin, minimo_filtro);
  plotponto(t_pico_2, y_pico_2, 'r', xmin, minimo_filtro);
  limiteeixos(tempo, filtro);
  legendas({'Filtro', sprintf('tempo pico 1 = %f y pico 1 = %f', t_pico_1, y_pico_1), sprintf('t pico 2 = %f y pico 2 = %f', t_pico_2, y_pico_2)});

  %---------- PLOTA A RESPOSTA DA FUNÇÃO COM A RESPOSTA REAL DO SISTEMAS ----------%
  figure
  plotgrafico(tempo_plot, variavel_controlada, 'b', '');
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real');
  limiteeixos([xmin, xmax], [min([variavel_controlada; y_step]), max([variavel_controlada; y_step])]);
  legendas({'Resposta real', 'Função aproximada'});

  %---------- PLOTA O FILTRO COM A RESPOSTA DA FUNÇÃO APROXIMADA ----------%
  figure
  plotgrafico(tempo_plot, filtro, 'k', '');
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs FILTRO');
  limiteeixos([xmin, xmax], [min([filtro; y_step]), max([filtro; y_step])]);
  legendas({'Filtro', 'Função aproximada'});

  [VCpico_funcao, idx_pico_funcao] = max(y_step);
  tvc_max_funcao = tempo_plot(idx_pico_funcao);

  %---------- PLOTA A FUNÇÃO COM O PONTO MÁXIMO ----------%
  figure
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada com o ponto máximo');
  plotponto(tvc_max_funcao, VCpico_funcao, 'k', xmin, min(y_step));
  limiteeixos([xmin; xmax], y_step);
  legendas({'Função aproximada', sprintf('TVCmax = %f VCpico = %f', tvc_max_funcao, VCpico_funcao)});

  %---------- PRINTA OS ERROS DA FUNÇÃO COMPARADA COM O FILTRO ----------%
  fprintf("\nErros filtro vs função de transferência\n");
  y_step = y_step(1:length(filtro));
  erro_real_funcao_de_transferencia = abs(filtro - y_step);
  erro_maximo_funcao_de_transferencia = max(erro_real_funcao_de_transferencia)
  erro_medio_funcao_de_transferencia = mean(erro_real_funcao_de_transferencia)
  erro_rms_funcao_de_transferencia = sqrt(mean(erro_real_funcao_de_transferencia.^2))

  %---------- PLOTA O LUGAR GEOMETRICO DAS RAÍZES ----------%
if k>0
  lugar_das_raizes(funcao_aproximada, 'Lugar das raízes sem compensação');
elseif k<0
  lugar_das_raizes(-funcao_aproximada, 'Lugar das raízes sem compensação');
end

  %---------- PLOTA O DIAGRAMA DE BODE DA FUNÇÃO APROXIMADA ----------%
  plot_bode(funcao_aproximada, 'Diagrama de bode em malha aberta');

  if zeros > 0
    %---------- CALCULA O MENOR TEMPO DE ACOMODAÇÃO ACEITAVEL PARA O SISTEMA ----------%
    tempo_de_acomodacao_minimo_aceitavel = 2*4/a;
    fprintf('\nO menor tempo de acomodação aceitável para esse sistema é %e segundos.\n', tempo_de_acomodacao_minimo_aceitavel)
    TSMF_segunda_ordem_com_um_zero = input('Sabendo o tempo de acomodação minimo aceitável, digite o tempo de acomodação desejado: ');
    fprintf("\n")

    %---------- CALCULO DO POLO DOMINANTE COM O TEMPO DE ACOMODAÇÃO DESEJADO PELO USUÁRIO ----------%
    polo_alocado = - 4 /TSMF_segunda_ordem_com_um_zero
    zpi = -a + b*i
    zpd = -a - b*i

    %---------- GERA O PID UNITÁRIO ----------%
    PID_ganho_unitario = zpk([zpi, zpd], 0, 1);

    %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PID_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPID PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPID = 1/abs(MA_VALOR);

    if k > 0
      KPID = KPID
    elseif k < 0
      KPID = -KPID
    endif

    %---------- NOVO PID COM O GANHO CALCULADO ----------%
    KP = -KPID*(zpi+zpd)
    KI = KPID*(a^2 + b^2)
    KD = KPID
    fprintf('\nO controlador é dado por:\n')
    controlador = zpk([zpi, zpd], 0, KPID)

    fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
    discretizacao = input('Digite sua escolha: ');
    fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(controlador, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(controlador, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

    %---------- MALHA ABERTA COM O CONTROLADOR PI ----------%
    MA = controlador*funcao_aproximada;
    MA = minreal(MA);

    %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
    fprintf("\nA função em malha fechada é dada por:\n");
    funcao_em_malha_fechada = minreal(feedback(MA, 1))
    fprintf('\n');
    polos_malha_fechada = pole(funcao_em_malha_fechada)
    zeros_malha_fechada = zero(funcao_em_malha_fechada)

    fprintf("\n")
    polo_dominante_malha_fechada = max(real(polos_malha_fechada))
    tempo_de_acomodacao_malha_fechada = 4/abs(polo_dominante_malha_fechada)

  endif

  if zeros < 0

    fprintf('\nVocê prefere um controlador PID convencional ou um controlador alternativo?\n[1] PID convencional\n[2] Controlador alternativo\n');
    escolha_controlador = input('Digite sua escolha: ');

    if escolha_controlador == 1
    %---------- CALCULA O MENOR TEMPO DE ACOMODAÇÃO ACEITAVEL PARA O SISTEMA ----------%
    tempo_de_acomodacao_minimo_aceitavel = 2*4/min([z, a]);
    fprintf('\nO menor tempo de acomodação aceitável para esse sistema é %e segundos.\n', tempo_de_acomodacao_minimo_aceitavel)
    TSMF_segunda_ordem_com_um_zero = input('Sabendo o tempo de acomodação minimo aceitável, digite o tempo de acomodação desejado: ');
    fprintf("\n")

    %---------- CALCULO DO POLO DOMINANTE COM O TEMPO DE ACOMODAÇÃO DESEJADO PELO USUÁRIO ----------%
    polo_alocado = - 4 /TSMF_segunda_ordem_com_um_zero
    zpi = -a + b*i
    zpd = -a - b*i

    %---------- GERA O PI UNITÁRIO ----------%
    PID_ganho_unitario = zpk([zpi, zpd], 0, 1);

    %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PID_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPI PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPID = 1/abs(MA_VALOR);

    if k > 0
      KPID = KPID
    elseif k < 0
      KPID = -KPID
    endif

    %---------- NOVO PI COM O GANHO CALCULADO ----------%
    KP = -KPID*(zpi+zpd)
    KI = KPID*(a^2 + b^2)
    KD = KPID
    fprintf('\nO controlador é dado por:\n')
    controlador = zpk([zpi, zpd], 0, KPID)

    fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
    discretizacao = input('Digite sua escolha: ');
    fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(controlador, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(controlador, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

    %---------- MALHA ABERTA COM O CONTROLADOR PI ----------%
    MA = controlador*funcao_aproximada;
    MA = minreal(MA);

    %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
    fprintf("\nA função em malha fechada é dada por:\n");
    funcao_em_malha_fechada = minreal(feedback(MA, 1))
    fprintf('\n');
    polos_malha_fechada = pole(funcao_em_malha_fechada)
    zeros_malha_fechada = zero(funcao_em_malha_fechada)

    fprintf("\n")
    polo_dominante_malha_fechada = max(real(polos_malha_fechada))
    tempo_de_acomodacao_malha_fechada = 4/abs(polo_dominante_malha_fechada)

    elseif escolha_controlador == 2
    %---------- CALCULO DO GANHO K PARA O CONTROLADOR ----------%
    fprintf("\n")
    TSMF_segunda_ordem_com_um_zero = input("Digite o tempo de acomodação desejado pelo sistema: ");
    fprintf("\n")
    k_controlador = 4/(TSMF_segunda_ordem_com_um_zero*c)

    %---------- CONTROLADOR PROPOSTO ----------%
    fprintf('\nO controlador é dado por:\n')
    controlador = zpk(polos, [0, zeros], k_controlador)

    fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
    discretizacao = input('Digite sua escolha: ');
    fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(controlador, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(controlador, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

    %---------- MALHA ABERTA COM O CONTROLADOR PI ----------%
    MA = controlador*funcao_aproximada;
    MA = minreal(MA);

    %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
    fprintf("\nA função em malha fechada é dada por:\n");
##    funcao_em_malha_fechada_2 = minreal(feedback(MA, 1))
    funcao_em_malha_fechada = k_controlador*c/(s+k_controlador*c)
    fprintf('\n');
    polos_malha_fechada = pole(funcao_em_malha_fechada)

    fprintf("\n")
    polo_dominante_malha_fechada = max(real(polos_malha_fechada))
    tempo_de_acomodacao_malha_fechada = 4/abs(polo_dominante_malha_fechada)

  else
    fprintf('\nOpção inválida\n');
    fprintf('\nPressione qualquer tecla para finalizar...')
    pause;
    continue;
    end

  endif


  %---------- LUGAR DAS RAÍZES E O DIAGRAMA DE BODE ----------%
  lugar_das_raizes(MA, 'Lugar das raízes com compensação');
  plot_bode(MA, 'Diagrama de bode em malha aberta compensado');

  %----------  CRIA UMA NOVA FIGURA COM O PLOT DA FUNÇÃO EM MALHA FECHADA ----------%
  [y_malha_fechada, x_malha_fechada] = step(funcao_em_malha_fechada, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  [y_malha_aberta, x_malha_aberta] = step(funcao_aproximada/k, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', '');
  plotgrafico(x_malha_aberta, y_malha_aberta, 'r', 'Função em malha fechada');
  limiteeixos([0, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)])], [min([y_malha_aberta; y_malha_fechada]), max([y_malha_aberta; y_malha_fechada])]);
  legendas({'Função em malha fechada', 'Função em malha aberta dividido pelo ganho k'});

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', 'Função em malha fechada');
  limiteeixos([0, 2*tempo_de_acomodacao_malha_fechada], [min([y_malha_fechada]), max([y_malha_fechada])]);

  end

%---------- CASO O USUÁRIO ESCOLHA APROXIMAR USANDO O MÉTODO DOS MÍNIMOS QUADRADOS----------%
if escolha == '8'
%---------- PERGUNTA QUAL A ORDEM DESEJADA E SE DESEJA ADICIONAR UM ZERO NA FUNÇÃO ----------%
   ordem = input('Digite a ordem da função que deseja aproximar: ');
   if ordem <= 0
     fprintf('\nImpossível ter uma função com ordem igual a %d.\nPressione qualquer tecla para continuar...', ordem)
     pause;
     continue;
   endif
   printf('\nDeseja adicionar um zero para melhor aproximação?\n[1]Sim\n[2]Não\n')
   escolha_zero = input('Digite sua escolha: ');

  fprintf('\n')
  VCpico = max(filtro)
  UP = (VCpico - variavel_controlada_final)/(variavel_controlada_final - variavel_controlada_inicial)*100


%---------- DESLOCA O FILTRO PARA ZERO E ENCONTRA O dt ----------%
   y_deslocado = filtro(:) - variavel_controlada_inicial;
   dt = tempo(2) - tempo(1);
   u_anterior = u_plot(:);

%---------- CALCULA A INTEGRAL DE ORDEM DESEJADA DO DEGRAU ----------%
    for i = 1:ordem
      u_anterior = integralpp(u_anterior, dt);
    endfor

%---------- PARÂMETROS IMPORTANTES ----------%
      u_MMQO = u_anterior(:);
      N = length(u_plot);
      y_anterior = y_deslocado;
      denominador = s^ordem;

%---------- CASO O USUÁRIO DESEJE ADICIONAR UM ZERO NA FUNÇÃO ----------%
      if escolha_zero == 1

    du_anterior = u_plot(:);

%---------- CALCULA A INTEGRAL DE ORDEM N-1 PARA CALCULAR O ZERO DA FUNÇÃO----------%
    for i = 1:(ordem-1)
      du_anterior = integralpp(du_anterior, dt);
    endfor

%---------- PARÂMETROS IMPORTANTES ----------%
      du = du_anterior(:);

%---------- CRIA UMA MATRIZ DE ZEROS PARA ALOCAR MEMÓRIA E ALOCA O DU E U NO X ----------%
        X = zeros(N, ordem + 2);
        X(:, 1) = du;
        X(:, 2) = u_MMQO;

%---------- CALCULA AS INTEGRAIS DE Y E ADICIONA NA MATRIZ X----------%
        for i=3:ordem+2
          y_anterior = integralpp(y_anterior, dt);
          X(:,i) = -y_anterior(:);
        endfor

%---------- ALOCA A MATRIZ Y ----------%
        Y = y_deslocado;

%---------- ENCONTRA OS COEFICIENTES PARA A FUNÇÃO DE TRANSFERÊNCIA E O TAMANHO DE THETA ----------%
        theta = X\Y;
        num = [theta(1) theta(2)];
        den_controle =[1, theta(3:end)'];

%---------- MONTA A FUNÇÃO DE TRANSFERÊNCIA COM OS COEFICIENTES CALCULADOS ----------%
        fprintf('\n\nA função aproximada é:\n\n')
        funcao_aproximada = tf(num, den_controle)
        fprintf('\n')
%---------- CALCULA OS ZEROS E OS POLOS DA FUNÇÃO ----------%
        polos = pole(funcao_aproximada)
        zero_funcao_aproximada = zero(funcao_aproximada)

        vetor_polos = sort(real(polos));

%---------- CALCULA O MENOR TEMPO DE ACOMODAÇÃO POSSÍVEL ----------%
        if zero_funcao_aproximada > 0
          TSMF_MINIMO = 8/abs(vetor_polos(end));
        else
          TSMF_MINIMO = 8/abs(max([vetor_polos(end), zero_funcao_aproximada]));
        endif


%---------- CASO O USUÁRIO NÃO DESEJE ADICIONAR UM ZERO NA FUNÇÃO ----------%
      elseif escolha_zero == 2
%---------- CRIA UMA MATRIZ DE ZEROS PARA ALOCAR MEMÓRIA E ALOCA O U NO X ----------%
        X = zeros(N, ordem+1);
        X(:,1) = u_MMQO;

%---------- CALCULA AS INTEGRAIS DE Y E ADICIONA NA MATRIZ X----------%
        for i=2:ordem+1
          y_anterior = integralpp(y_anterior, dt);
          X(:,i) = -y_anterior(:);
        endfor
%---------- ALOCA A MATRIZ Y ----------%
        Y = y_deslocado;

%---------- ENCONTRA OS COEFICIENTES PARA A FUNÇÃO DE TRANSFERÊNCIA E O TAMANHO DE THETA ----------%
        theta = X\Y;

        num = [theta(1)];
        den_controle =[1, theta(2:end)'];

%---------- MONTA A FUNÇÃO DE TRANSFERÊNCIA COM OS COEFICIENTES CALCULADOS ----------%
        fprintf('\n\nA função aproximada é:\n\n')
        funcao_aproximada = tf(num, den_controle)

%---------- CALCULA OS POLOS DA FUNÇÃO ----------%
        fprintf('\n')
        polos = pole(funcao_aproximada)

%---------- CALCULA O MENOR TEMPO DE ACOMODAÇÃO POSSÍVEL ----------%
        vetor_polos = sort(real(polos));
        TSMF_MINIMO = 8/abs(vetor_polos(end));

%---------- DA ERROR CASO O USUÁRIO ESCOLHA UMA OPÇÃO QUE NÃO EXISTA ----------%
      else
        fprintf('\n\nOpção inválida\n\nPressione qualquer tecla para contiuar...\n\n')
        pause;
        continue;

      endif

%---------- DA ERROR CASO A FUNÇÃO APRESENTE UM POLO POSITIVO (FUNÇÃO INSTÁVEL) IMPOSSÍVEL DE APROXIMAR ----------%
      if vetor_polos(end) > 0
        fprintf('\n\nImpossível aproximar para ordem igual a %d.\n', ordem);
        fprintf('Pressione qualquer tecla para continuar...');
        pause;
        system('cls');
        clc; clear; close all;
        continue;
      endif

%---------- APLICA O DEGRAU NA FUNÇÃO APROXIMADA ----------%
      fprintf('\n')
      k = dcgain(funcao_aproximada)
      y_step = lsim(funcao_aproximada, u_plot, tempo_plot) + variavel_controlada_inicial;

  %---------- PLOTA A RESPOSTA DA FUNÇÃO COM A RESPOSTA REAL DO SISTEMAS ----------%
  figure
  plotgrafico(tempo_plot, variavel_controlada, 'b', '');
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs resposta real');
  limiteeixos([xmin, xmax], [min([variavel_controlada; y_step]), max([variavel_controlada; y_step])]);
  legendas({'Resposta real', 'Função aproximada'});

  %---------- PLOTA O FILTRO COM A RESPOSTA DA FUNÇÃO APROXIMADA ----------%
  figure
  plotgrafico(tempo_plot, filtro, 'k', '');
  plotgrafico(tempo_plot, y_step, 'r', 'Função aproximada vs FILTRO');
  limiteeixos([xmin, xmax], [min([filtro; y_step]), max([filtro; y_step])]);
  legendas({'Filtro', 'Função aproximada'});

  %---------- PRINTA OS ERROS DA FUNÇÃO COMPARADA COM O FILTRO ----------%
  fprintf("\nErros filtro vs função de transferência\n");
  y_step = y_step(1:length(filtro));
  erro_real_funcao_de_transferencia = abs(filtro - y_step);
  erro_maximo_funcao_de_transferencia = max(erro_real_funcao_de_transferencia)
  erro_medio_funcao_de_transferencia = mean(erro_real_funcao_de_transferencia)
  erro_rms_funcao_de_transferencia = sqrt(mean(erro_real_funcao_de_transferencia.^2))

  %---------- PLOTA O LUGAR GEOMETRICO DAS RAÍZES ----------%
if k>0
  lugar_das_raizes(funcao_aproximada, 'Lugar das raízes sem compensação');
elseif k<0
  lugar_das_raizes(-funcao_aproximada, 'Lugar das raízes sem compensação');
end

  %---------- PLOTA O DIAGRAMA DE BODE DA FUNÇÃO APROXIMADA ----------%
  plot_bode(funcao_aproximada, 'Diagrama de bode em malha aberta');

  %---------- ESCOLHA CONTROLADOR ----------%
    fprintf('\nVocê prefere um controlador PI ou um controlador PID?\n[1] PI\n[2] PID\n[3] Controle alternativo\n');
    escolha_controlador = input('Digite sua escolha: ');

    if escolha_controlador == 3

    fprintf('\n')
    TSMF_escolhido = input('Digite o tempo de acomodação desejado: ');

     elseif (escolha_controlador == 1 || escolha_controlador == 2)

    fprintf('\nO menor tempo de acomodação desse sistema é de %e segundos. Sabendo disso, qual o tempo de acomodação desejado?\n', TSMF_MINIMO);
    TSMF_escolhido = input('Digite o tempo de acomodação: ');
    fprintf('\n')

    else
    fprintf('\n\nOpção inválida\nPressione qualquer tecla para continuar...')
    pause;
    continue;

    endif

    %---------- CALCULA O POLO QUE DEVE SER ALOCADO EM MALHA FECHADA ----------%
    polo_alocado = -4/TSMF_escolhido
    fprintf('\n');

  if escolha_controlador == 1

  if ordem == 1

    %---------- CRIA O PI UNITÁRIO ----------%
    zpi = vetor_polos(1)
    PI_ganho_unitario = zpk(zpi, 0, 1);

  else

    %---------- CRIA O PI UNITÁRIO ----------%
    zpi = 10*polo_alocado
    PI_ganho_unitario = zpk(zpi, 0, 1);

    endif

    %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PI_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPI PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPI = 1/abs(MA_VALOR);

    if k > 0
      KPI = KPI
    elseif k < 0
      KPI = -KPI
    endif

    %---------- NOVO PI COM O GANHO CALCULADO ----------%
    KP = KPI
    KI = -KPI*zpi
    fprintf('\nO controlador é dado por:\n')
    controlador = zpk(zpi, 0, KPI)

  elseif escolha_controlador == 2
  if ordem == 1
    idx = find(real(polos) >= (vetor_polos(1) - 1e-6 ));
  else
    idx = find(real(polos) >= (vetor_polos(end-1) - 1e-6 ));
  endif
  zp1 = polos(idx(1))
  zp2 = polos(idx(end))

  PID_ganho_unitario= zpk([zp1, zp2], 0, 1);

    %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PID_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPI PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPID = 1/abs(MA_VALOR);

    if k > 0
      KPID = KPID
    elseif k < 0
      KPID = -KPID
    endif

    %---------- NOVO PI COM O GANHO CALCULADO ----------%
    KP = -KPID*(zp1+zp2)
    KI = round(KPID*zp1*zp2*1e6)*1e-6
    KD = KPID
    fprintf('\nO controlador é dado por:\n')
    controlador = zpk([zp1, zp2], 0, KPID)

  elseif escolha_controlador == 3

  if escolha_zero == 1

  if zero_funcao_aproximada < 0
      PID_ganho_unitario= zpk(polos, [0, zero_funcao_aproximada], 1);
    else
      PID_ganho_unitario= zpk(polos, 0, 1);
  endif

  elseif escolha_zero == 2

  PID_ganho_unitario= zpk(polos, 0, 1);

  endif

  %---------- GERA A RESPOSTA EM MALHA ABERTA DO SISTEMA COM O CONTROLADOR COM GANHO IGUAL A 1 ----------%
    [num, den_controle] = tfdata(PID_ganho_unitario*funcao_aproximada, "vector");

    %---------- ENCONTRA O KPI PARA O TEMPO DE ACOMODAÇÃO DEJESADO PELO USUÁRIO ----------%
    MA_VALOR = polyval(num, polo_alocado)/polyval(den_controle, polo_alocado);

    fprintf('\n')
    KPID = 1/abs(MA_VALOR);

    if k > 0
      KPID = KPID
    elseif k < 0
      KPID = -KPID
    endif

    fprintf('\nO controlador é dado por:\n')
    controlador = KPID*PID_ganho_unitario
endif

    fprintf("\nDeseja discretizar (método de TUSTIN) o controlador?\n[1] Sim\n[2] Não\n");
    discretizacao = input('Digite sua escolha: ');
    fprintf('\n')

    %---------- DISCRETIZA O CONTROLADOR ----------%
    if discretizacao == 1
      [num_controle, den_controle] = tfdata(controlador, 'v');
      ordem_controlador = max(length(num_controle)-1, length(den_controle)-1)

      frequencia_amostragem_controlador = input('Digite a frequência de amostragem do controlador: ');
      fprintf('\n')
      Ts = 1/frequencia_amostragem_controlador
      controlador_discreto = minreal(c2d(controlador, Ts, 'tustin'));
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

      if ordem_controlador_discreto > ordem_controlador
        while(ordem_controlador_discreto > ordem_controlador)
        [z, p, k_controlador_discreto] = zpkdata(controlador_discreto, 'v');

        [~, idx_polo] = min(abs(real(p)+1));
        [~, idx_zero] = min(abs(real(z)+1));

        p(idx_polo) = [];
        z(idx_zero) = [];

        controlador_discreto = zpk(z, p, k_controlador_discreto, Ts);

        [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
        ordem_controlador_discreto = max(length(num_controle_discreto)-1, length(den_controle_discreto)-1);

        endwhile

      endif
      [num_controle_discreto, den_controle_discreto] = tfdata(controlador_discreto, 'v');
      num_abs = abs(num_controle_discreto);
      den_abs = abs(den_controle_discreto);
      maximo_coeficiente = max([num_abs, den_abs]);

      for i = 1:length(num_abs)
        grandeza = num_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          num_controle_discreto(i) = 0;
        endif
      endfor

      for i = 1:length(den_abs)
        grandeza = den_abs(i)/maximo_coeficiente;
        if grandeza < 1e-6
          den_controle_discreto(i) = 0;
        endif
      endfor

      controlador_discreto = tf(num_controle_discreto, den_controle_discreto, Ts);
      controlador_discreto = set(controlador_discreto, 'variable', 'z^-1')
      fprintf('\n');

      tamanho_numerador = length(num_controle_discreto);
      tamanho_denominador = length(den_controle_discreto);

      syms N Y(N) X(N) ;

      entrada = 0;
      saida = 0;

      for i=1:tamanho_numerador;

        entrada += sym(num2str(num_controle_discreto(i)))*X(N-sym(num2str(i-1)));

    endfor

      for i=2:tamanho_denominador;

        saida += sym(num2str(den_controle_discreto(i)))*Y(N-sym(num2str(i-1)));

    endfor

    fprintf('\nA equação diferença é descrito por Y/X, na qual Y é a saída do controlador, e X a entrada do controlador (erro).\n')
    fprintf('Y(N) representa a saída atual do controlador, Y(N-1) representa a saída anterior Y(N-2) representa a anterior da anterior, e assim por diante, o mesmo vale para X(N), X(N-1)...\n\n');

      Y_N = vpa(entrada - saida);
      fprintf('Y(N) = %s\n\n', char(Y_N));

    endif

%---------- MALHA ABERTA COM O CONTROLADOR PI ----------%
    MA = controlador*funcao_aproximada;
    MA = minreal(MA);

    %---------- ENCONTRA A FUNÇÃO DE TRANSFERENCIA EM MALHA FECHADA E PRINTA NA JANELA DE COMANDOS ----------%
    fprintf("\nA função em malha fechada é dada por:\n");
    funcao_em_malha_fechada = minreal(feedback(MA, 1))
    fprintf('\n');
    polos_malha_fechada = pole(funcao_em_malha_fechada)
    zeros_malha_fechada = zero(funcao_em_malha_fechada)

    fprintf("\n")
    polo_dominante_malha_fechada = max(real(polos_malha_fechada))
    tempo_de_acomodacao_malha_fechada = 4/abs(polo_dominante_malha_fechada)

      %---------- LUGAR DAS RAÍZES E O DIAGRAMA DE BODE ----------%
  lugar_das_raizes(MA, 'Lugar das raízes com compensação');
  plot_bode(MA, 'Diagrama de bode em malha aberta compensado');

  %----------  CRIA UMA NOVA FIGURA COM O PLOT DA FUNÇÃO EM MALHA FECHADA ----------%
  [y_malha_fechada, x_malha_fechada] = step(funcao_em_malha_fechada, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));
  [y_malha_aberta, x_malha_aberta] = step(funcao_aproximada/k, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)]));

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', '');
  plotgrafico(x_malha_aberta, y_malha_aberta, 'r', 'Função em malha fechada');
  limiteeixos([0, max([2*tempo_de_acomodacao_malha_fechada, tempo(end)])], [min([y_malha_aberta; y_malha_fechada]), max([y_malha_aberta; y_malha_fechada])]);
  legendas({'Função em malha fechada', 'Função em malha aberta dividido pelo ganho k'});

  figure;
  plotgrafico(x_malha_fechada, y_malha_fechada, 'k', 'Função em malha fechada');
  limiteeixos([0, 2*tempo_de_acomodacao_malha_fechada], [min([y_malha_fechada]), max([y_malha_fechada])]);

   endif

  fprintf('\nPressione qualquer tecla para finalizar...')
  pause;

end

