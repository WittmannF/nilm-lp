## definicao dos conjuntos e parametros
set ESTADO; 				    # Conjunto de estados
set TS; 					    # Conjunto de discretizações total
set TS2;					    # Conjunto de discretizações da janela
							
param disc_i; 				    # Discretizacao inicial
param window; 			     	# Tamanho da janela
param disp{ESTADO};			    # ID do dispositivo
param ant{ESTADO};			    # Index do Estado anterior
param Xprev{ESTADO};		    # Estado X anterior
param Pdisp{ESTADO};		    # Potência Ativa dos estados
# param Qdisp{ESTADO};		    # Potência reativa dos estados
param mindisc{ESTADO};		    # Número mínimo de discretizações
param numdisp;				    # Número de dispositivos
param Ptotal{TS};			    # Potência total da leitura do medidor
# param Qtotal{TS};			    # Potência total da leitura do medidor
param TH;					    # Threshold de potência
param G{ESTADO} default 0;		# Initial online time
param Soma_X{ESTADO} default 0;	# Somatoria dos estados no tempo final
param Tf;					    # Tempo final da janela

## Definicao das variaveis
var X{ESTADO,TS2} binary;       # Estado X do dispositivo e in ESTADO para o instante de tempo t in TS2
var DELTA_P{TS2};				# Erro para o instante de tempo t in TS2
# var DELTA_Q{TS2};				# Erro para o instante de tempo t in TS2
var up{ESTADO,TS2} binary;      # Binário que indica que o estado e in ESTADO foi ativado no instante t in TS2
var down{ESTADO,TS2} binary;    # Binário que indica que o estado e in ESTADO foi desativado no instante t in TS2

## Funcao objetivo considerando apenas a potencia ativa
minimize erro_quadratico: 
	sum{t in TS2} (DELTA_P[t]);
	
## Definicao da funcao objetivo considerando potencia ativa e reativa
# minimize erro_quadratico: 
#	sum{t in TS2} (DELTA_P[t] + DELTA_Q[t]);
 
## Definicao das restricoes

# Erro absoluto P
subject to diferenca_combinatoria_1 {t in TS2}:
	Ptotal[t] - sum{e in ESTADO} (Pdisp[e]*X[e,t]) <= DELTA_P[t];

subject to diferenca_combinatoria_2 {t in TS2}:
	Ptotal[t] - sum{e in ESTADO} (Pdisp[e]*X[e,t]) >= -DELTA_P[t];

# Erro absoluto Q
#subject to diferenca_combinatoria_3 {t in TS2}:
#	Qtotal[t] - sum{e in ESTADO} (Qdisp[e]*X[e,t]) <= DELTA_Q[t];

#subject to diferenca_combinatoria_4 {t in TS2}:
#	Qtotal[t] - sum{e in ESTADO} (Qdisp[e]*X[e,t]) >= -DELTA_Q[t];

# Evitar que múltiplos estados da mesma carga sejam ativados  
subject to evitar_sobreposicao {t in TS2, d in 1..numdisp}:
	sum{e in ESTADO : disp[e] == d} X[e,t] <= 1;

# Definir estados para 0 quando a leitura total for menor que 30W ou maior que 40% 
subject to set_zero {t in TS2, e in ESTADO : Ptotal[t] < TH}:
	X[e,t] = 0;

# Define states to zero if the current measurement is lower than a given state
#subject to set_zero_2 {t in TS2, e in ESTADO : Pdisp[e] > 1.4*Ptotal[t]}:
#    X[e,t] = 0;

# Variaveis para armazenar mudança de estados
subject to calculo_ligado {t in TS2, e in ESTADO : t > disc_i}:
	X[e,t] - X[e,t-1] = up[e,t] - down[e,t];

subject to impedir_igualdade {t in TS2, e in ESTADO}: 
	up[e,t] + down[e,t] <= 1; 

subject to variavel_inicial {e in ESTADO, t in TS2: t>1 and t = disc_i}:
	X[e,disc_i] - Xprev[e] = up[e,t] - down[e,t];

# Limitar estado anterior  
subject to maquina_estados {t in TS2, e in ESTADO : ant[e] > 0}:
	up[e,t] = down[ant[e],t];

# Manter tempo mínimo de estados
subject to numero_minimo_amostras_1 {e in ESTADO, t in G[e] + disc_i .. (Tf - mindisc[e] + 1) : t>disc_i}:
	sum{n in t..(t + mindisc[e] - 1)} (X[e,n]) >= mindisc[e]*(X[e,t] - X[e,t-1]);

subject to numero_minimo_amostras_2 {e in ESTADO}:
	sum{n in disc_i .. G[e]} (1 - X[e,n]) = 0;

subject to numero_minimo_amostras_3 {e in ESTADO, t in (Tf - mindisc[e] + 2) .. Tf}:
	sum{n in t .. Tf} (X[e,n] - (X[e,t] - X[e,t-1])) >= 0;
