clc
clear all
close all

% Ler dados originais
M = csvread('z_ground_truth.csv');

refr = M(:,2);
wash = M(:,3);
stove = M(:,4);
all = M(:,5);
time = 1:length(refr);


% Ler arquivos com dados
DELTA = z_results_delta;
X = z_results_x;
ESTADO = z_results_estado;

% Vetores
TS = X(:,1);
Ptotal = X(:,2:end)*ESTADO(:,2);

% Matriz para associação de estados aos respectivos dispositivos
states = [1 1 2 2 2 3];
F = zeros(max(states), length(states));
for i=1:length(states) % columns, from 1 to 14
    for j=1:max(states) % lines, from 1 to 7
        if j==states(i)
            F(j,i) = 1;
        end   
    end
end

K = F*diag(ESTADO(:,2));
Pdisp = X(:,2:end)*K';

%% Subplot Ground Truth Data
subplot(2,1,1);
bar(time, [refr wash stove], 'stacked')
legend('Refr','Washing Machine','Stove')
xlabel('# of Samples')
ylabel('Power [W]')
title('Dados Originais')

%% Subplot com resultados
subplot(2,1,2);
bar(TS, Pdisp, 1,'stacked');
xlabel('t (min)')
ylabel('Active Power [W]')
t(3) = title('Full Model');
