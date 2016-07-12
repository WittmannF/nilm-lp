## definicao dos conjuntos e parametros
set ESTADO; 		    	# Conjunto de estados
set TS; 			    	# Conjunto de discretizações total
set TS2;			    	# Conjunto de discretizações da janela
							
param disc_i; 		    	# Discretizacao inicial
param window; 		    	# Tamanho da janela
param disp{ESTADO};     	# ID do dispositivo
param ant{ESTADO};      	# Index do Estado anterior
param Xprev{ESTADO};    	# Estado X anterior
param Pdisp{ESTADO};    	# Potência dos estados
param mindisc{ESTADO};  	# Número mínimo de discretizações
param numdisp;				# Número de dispositivos
param Ptotal{TS};			# Potência total da leitura do medidor

## Definicao das variaveis
var X{ESTADO,TS2} binary;   # Estado X do dispositivo e in ESTADO para o instante de tempo t in TS2
var DELTA{TS2};				# Erro para o instante de tempo t in TS2
var Pe{e in ESTADO} >= 0.95*Pdisp[e], <= 1.05*Pdisp[e];
var PeX{ESTADO,TS2};
var ua{ESTADO,TS2} binary;  # Binário que indica que o estado e in ESTADO foi ativado no instante t in TS2
var up{ESTADO,TS2} binary;  # Binário que indica que o estado e in ESTADO foi desativado no instante t in TS2

## Definicao da funcao objetivo
minimize erro_quadratico: 
  sum{t in TS2} DELTA[t];
 
## Definicao das restricoes

# Erro absoluto
subject to diferenca_combinatoria_1 {t in TS2}:
  Ptotal[t] - sum{e in ESTADO} (Pdisp[e]*X[e,t]) <= DELTA[t];

subject to diferenca_combinatoria_2 {t in TS2}:
  Ptotal[t] - sum{e in ESTADO} (Pdisp[e]*X[e,t]) >= -DELTA[t];

  
# Evitar que múltiplos estados da mesma carga sejam ativados  
subject to evitar_sobreposicao {t in TS2, d in 1..numdisp}:
  sum{e in ESTADO : disp[e] == d} X[e,t] <= 1;     
 
 
# Definir estados para 0 quando a leitura total for menor que 30W ou maior que 40% 
subject to set_zero {t in TS2, e in ESTADO : Ptotal[t] < 30}:
  X[e,t] = 0;

# subject to set_zero2 {t in TS2, e in ESTADO : 1.4*Ptotal[t] < Pdisp[e]}:
  #X[e,t] = 0;
  
# Variaveis para armazenar mudança de estados
subject to calculo_ligado {t in TS2, e in ESTADO : t > disc_i}:
  X[e,t] - X[e,t-1] = ua[e,t] - up[e,t];

subject to impedir_igualdade {t in TS2, e in ESTADO}: #impedir que ua e up sejam iguais a 1 simultaneamente
  ua[e,t] + up[e,t] <= 1; 
  
subject to variavel_inicial {e in ESTADO, t in TS2: t>1 and t = disc_i}:
  X[e,disc_i] - Xprev[e] = ua[e,t] - up[e,t];
    
# Limitar estado anterior  
subject to maquina_estados {t in TS2, e in ESTADO : ant[e] > 0}:
  ua[e,t] = up[ant[e],t];
  
  
# Manter tempo mínimo de estados
subject to numero_minimo_amostras {e in ESTADO, t in disc_i..(disc_i + window - mindisc[e] -1) : mindisc[e]>1 and t > disc_i}:
  sum{n in t..(t+mindisc[e]-1)} (X[e,n]) >= mindisc[e]*(X[e,t] - X[e,t-1]);

#################### Outras Restrições ############## 

# Definir para zero todas as cargas maiores que 40% do valor total  
#subject to set_zero {t in TS2, e in ESTADO : Ptotal[t] < 1.4*Pdisp[e]}:
 # X[e,t] = 0;

## ESTRATEGIAS PARA LIMITAR A TROCA DE ESTADOS PARA CADA INSTANTE DE TEMPO 

# PRIMEIRA ESTRATEGIA
#subject to troca_estado1 {t in TS2}:
#  sum{e in ESTADO} X[e,t] - X[e,t-1] <= 1;   
  
#subject to troca_estado2 {t in TS2}:
#  sum{e in ESTADO} X[e,t-1] - X[e,t] <= 1;   

# SEGUNDA ESTRATEGIA: Fazer com que para cada instante de tempo apenas um estado seja ativo
# Evitar que múltiplos estados da mesma carga sejam ativados simultaneamente
#subject to evitar_sobreposicao {t in TS2}:
#  sum{e in ESTADO} ua[e,t] + up[e,t] <= 1;   

# TERCEIRA ESTRATEGIA: Colocar penalização na funcao objetivo
# erro absoluto
#subject to diferenca_combinatoria_1 {t in TS2}:
#  Ptotal[t] - sum{e in ESTADO} (Pdisp[e]*X[e,t] - 20*(ua[e,t] + up[e,t])) <= DELTA[t];

#subject to diferenca_combinatoria_2 {t in TS2}:
#  Ptotal[t] - sum{e in ESTADO} (Pdisp[e]*X[e,t] - 20*(ua[e,t] + up[e,t])) >= -DELTA[t];

## OUTRAS ESTRATEGIAS
# --- Manter cargas dentro de um intervalo (percentagem)  
#subject to diferenca_combinatoria_3 {e in ESTADO, t in TS2}:
#  PeX[e,t] <= 1.01*Pdisp[e]*X[e,t];

#subject to diferenca_combinatoria_4 {e in ESTADO, t in TS2}:
#  0.99*Pdisp[e]*X[e,t] <= PeX[e,t];

#subject to diferenca_combinatoria_5 {e in ESTADO, t in TS2}:
#  Pe[e] - PeX[e,t] <= 1.01*Pdisp[e]*(1-X[e,t]);

#subject to diferenca_combinatoria_6 {e in ESTADO, t in TS2}:
#  0.99*Pdisp[e]*(1-X[e,t]) <= Pe[e] - PeX[e,t]; 
