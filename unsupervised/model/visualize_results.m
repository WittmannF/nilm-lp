clc
clear all
close all

% Ler dados originais
gt = csvread('z_ground_truth.csv', 0,1);

X = csvread('z_results_x.csv');
X = X(:,2:7);

% Centroids
ESTADO = [235
5569
7608
3753
2373
131];

% Vetores
TS = 1:length(X);
Ptotal = X*ESTADO;

% Matriz para associação de estados aos respectivos dispositivos
states = [1 2 3 4 5 6];
F = zeros(max(states), length(states));
for i=1:length(states) % columns, from 1 to 14
    for j=1:max(states) % lines, from 1 to 7
        if j==states(i)
            F(j,i) = 1;
        end   
    end
end

K = F*diag(ESTADO);
Pdisp = X*K';

%% Subplot Ground Truth Data
subplot(2,1,1);
bar(TS, gt, 'stacked')
xlabel('t (min)')
ylabel('Potência Ativa [W]')
title('Dados Originais')

%% Subplot com resultados
subplot(2,1,2);
bar(TS, Pdisp, 1,'stacked');
xlabel('Amostra (delta = 15s)')
ylabel('Active Power [W]')
title('Full Model');

