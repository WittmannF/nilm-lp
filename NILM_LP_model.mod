# definicao dos conjuntos e parametros
set ESTADO;
set TS;
set TS2;

param disc_i; # discretizacao inicial
param window; # tamanho da janela
param disp{ESTADO};
param Pdisp{ESTADO};
param mindisc{ESTADO}; 
param numdisp;
param Ptotal{TS};

# Definicao das variaveis
var X{ESTADO,TS2} binary;
var DELTA{TS2};
var Pe{e in ESTADO} >= 0.95*Pdisp[e], <= 1.05*Pdisp[e];
var PeX{ESTADO,TS2};

# definicao da funcao objetivo
minimize erro_quadratico: 
  sum{t in TS2} DELTA[t];
 
# Definicao das restricoes
subject to diferenca_combinatoria_1 {t in TS2}:
  Ptotal[t] - sum{e in ESTADO} PeX[e,t] <= DELTA[t];

subject to diferenca_combinatoria_2 {t in TS2}:
  Ptotal[t] - sum{e in ESTADO} PeX[e,t] >= -DELTA[t];
  
subject to diferenca_combinatoria_3 {e in ESTADO, t in TS2}:
  PeX[e,t] <= 1.05*Pdisp[e]*X[e,t];

subject to diferenca_combinatoria_4 {e in ESTADO, t in TS2}:
  0.95*Pdisp[e]*X[e,t] <= PeX[e,t];

subject to diferenca_combinatoria_5 {e in ESTADO, t in TS2}:
  Pe[e] - PeX[e,t] <= 1.05*Pdisp[e]*(1-X[e,t]);

subject to diferenca_combinatoria_6 {e in ESTADO, t in TS2}:
  0.95*Pdisp[e]*(1-X[e,t]) <= Pe[e] - PeX[e,t];
 
#subject to numero_minimo_amostras {e in ESTADO, t in 1..(card(TS2)-mindisc[e]+1) : mindisc[e]>1 and t > 1}:
#  sum{n in t..(t+mindisc[e]-1)} (X[e,n]) >= mindisc[e]*(X[e,t] - X[e,t-1]);
  
subject to evitar_sobreposicao {t in TS2, d in 1..numdisp}:
#   X[2,t] + X[3,t] + X[4,t] <= 1;# Estados correspondentes ao Washer
  sum{e in ESTADO : disp[e] == d} X[e,t] <= 1; 