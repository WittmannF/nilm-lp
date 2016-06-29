## definicao dos conjuntos e parametros
set ESTADO;
set TS;
set TS2;

param disc_i; # discretizacao inicial
param window; # tamanho da janela
param disp{ESTADO};
param ant{ESTADO}; # Estado anterior
param Pdisp{ESTADO};
param mindisc{ESTADO}; 
param numdisp;
param Ptotal{TS};

## Definicao das variaveis
var X{ESTADO,TS2} binary;
var DELTA{TS2};
var Pe{e in ESTADO} >= 0.95*Pdisp[e], <= 1.05*Pdisp[e];
var PeX{ESTADO,TS2};
var ua{ESTADO,TS2} binary;
var up{ESTADO,TS2} binary;

## Definicao da funcao objetivo
minimize erro_quadratico: 
  sum{t in TS2} DELTA[t];
 
## Definicao das restricoes

# erro absoluto
subject to diferenca_combinatoria_1 {t in TS2}:
  Ptotal[t] - sum{e in ESTADO} PeX[e,t] <= DELTA[t];

subject to diferenca_combinatoria_2 {t in TS2}:
  Ptotal[t] - sum{e in ESTADO} PeX[e,t] >= -DELTA[t];

# Intervalo de 5% identificação cargas  
subject to diferenca_combinatoria_3 {e in ESTADO, t in TS2}:
  PeX[e,t] <= 1.01*Pdisp[e]*X[e,t];

subject to diferenca_combinatoria_4 {e in ESTADO, t in TS2}:
  0.99*Pdisp[e]*X[e,t] <= PeX[e,t];

subject to diferenca_combinatoria_5 {e in ESTADO, t in TS2}:
  Pe[e] - PeX[e,t] <= 1.01*Pdisp[e]*(1-X[e,t]);

subject to diferenca_combinatoria_6 {e in ESTADO, t in TS2}:
  0.99*Pdisp[e]*(1-X[e,t]) <= Pe[e] - PeX[e,t]; 

# Evitar que múltiplos estados da mesma carga sejam ativados  
subject to evitar_sobreposicao {t in TS2, d in 1..numdisp}:
  sum{e in ESTADO : disp[e] == d} X[e,t] <= 1;   

# Variaveis para armazenar mudança de estados
subject to calculo_ligado {t in TS2, e in ESTADO : t > disc_i}:
  X[e,t] - X[e,t-1] = ua[e,t] - up[e,t];

subject to impedir_igualdade {t in TS2, e in ESTADO : t > disc_i}: #impedir que ua e up sejam iguais a 1 simultaneamente
  ua[e,t] + up[e,t] <= 1;  
  
# Limitar estado anterior  
subject to maquina_estados {t in TS2, e in ESTADO : t > disc_i and ant[e] > 0}:
  ua[e,t] = up[ant[e],t];

## Variaveis de mudanca de estados
#subject to calculo_ligado {t in TS2, e in ESTADO : t > disc_i}:
#  X[e,t] - X[e,t-1] = ua[e,t] - up[e,t];
	
  
####################old stuff ############## 
# subject to numero_minimo_amostras {e in ESTADO, t in disc_i..(disc_i + window - mindisc[e] + 1) : mindisc[e]>1 and t > disc_i}:
#  sum{n in t..(t+mindisc[e]-1)} (X[e,n]) >= mindisc[e]*(X[e,t] - X[e,t-1]);

# Condição para limitar o número de cargas acionadas em um mesmo instante para uma  
#subject to limitar_acionamento_1 {t in TS2 : t > disc_i}:
#  sum{e in ESTADO} (X[e,t] - X[e,t-1]) <= 1;

#subject to limitar_acionamento_2 {t in TS2 : t > disc_i}:
#  sum{e in ESTADO} (X[e,t] - X[e,t-1]) >= -1;
  
#subject to evitar_sobreposicao {t in TS2, d in 1..numdisp}:
#  sum{e in ESTADO : disp[e] == d} X[e,t] <= 1; 