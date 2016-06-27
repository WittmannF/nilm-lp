clc
clear all
close all

% Ler arquivos com dados
DELTA = delta;
X = x;
ESTADO = estado;
Ptotalorg = ptotalorg;

% Vetores
TS = X(:,1);
Pdisp = X(:,2:end)*diag(ESTADO(:,2));
Ptotal = X(:,2:end)*ESTADO(:,2);

% Plot superior
subplot(2,1,1)
bar(TS, [Pdisp(:,1) Pdisp(:,2) Pdisp(:,3) Pdisp(:,4) Pdisp(:,5)],'stacked');
hold on
plot(Ptotal,'k')
plot(Ptotalorg(:,1),Ptotalorg(:,2),'k-','LineWidth',1.5)
legend('Refr','Washer1','Washer2','Washer3','Stove','Total','Org')
xlabel('Timestamp (t)')
ylabel('Power [W]')
title('Disaggregation Results')

% Plot inferior
subplot(2,1,2)
stem(DELTA(:,2),':.')
xlabel('Timestamp (t)')
ylabel('Delta [W]')
title('Error')

