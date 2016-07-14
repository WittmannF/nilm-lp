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
% subplot(2,1,1)
% bar(TS, Pdisp,'stacked');
% hold on
% plot(Ptotal,'k')
% plot(Ptotalorg(:,1),Ptotalorg(:,2),'k-','LineWidth',1.5)
% legend(' Dryer 1 ','Dryer 2','DishWasher 1','DishWasher 2','DishWasher 3',...
%     'Fridge','Heatpump 1','Heatpump 2','Heatpump 3',' Kitchenwall 1',...
%     'Kitchenwall 2','Kitchenwall3',' TV1',' TV2','Total','Org')
% xlabel('Timestamp (t)')
% ylabel('Power [W]')
% title('Disaggregation Results')
% 
% clf
F = [1 1 0 0 0 0 0 0 0 0 0 0 0 0
     0 0 1 1 1 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 1 0 0 0 0 0 0 0 0
     0 0 0 0 0 0 1 1 1 0 0 0 0 0
     0 0 0 0 0 0 0 0 0 1 1 1 0 0
     0 0 0 0 0 0 0 0 0 0 0 0 1 1];
K = F*diag(ESTADO(:,2));
Pdisp = X(:,2:end)*K';
bar(TS, Pdisp,'stacked');
hold on
plot(Ptotal,'k')
plot(Ptotalorg(:,1),Ptotalorg(:,2),'k-','LineWidth',1.5)
legend(' Dryer','DishWasher',...
    'Fridge','Heatpump',' Kitchenwall',' TV'),'Total','Org')
xlabel('Timestamp (t)')
ylabel('Power [W]')
title('Disaggregation Results')

% 
% % Plot inferior
% subplot(2,1,2)
% bar(DELTA(:,2))
% xlabel('Timestamp (t)')
% ylabel('Delta [W]')
% title('Error')

DATA = csvread('24h.csv');
time = 1:length(DATA);
Dryer_P = DATA(:,1);
Dryer_Q = DATA(:,2);
DishWs_P = DATA(:,3);
DishWs_Q = DATA(:,4);
Fridge_P = DATA(:,5);
Fridge_Q = DATA(:,6);
Heatpump_P = DATA(:,7);
Heatpump_Q = DATA(:,8);
Kitchenwall_P = DATA(:,9);
Kitchenwall_Q = DATA(:,10);
TV_P = DATA(:,11);
TV_Q = DATA(:,12);
All_P = DATA(:,13);
All_Q = DATA(:,14);

subplot(2,1,1)
bar(time, [Dryer_P DishWs_P Fridge_P Heatpump_P Kitchenwall_P TV_P],'stacked');
legend(' Dryer','DishWasher',...
    'Fridge','Heatpump',' Kitchenwall',' TV')
xlabel('Timestamp (t)')
ylabel('Power [W]')
title('Original Data')

subplot(2,1,2)
Pdisp = X(:,2:end)*K';
bar(TS, Pdisp,'stacked');
xlabel('Timestamp (t)')
ylabel('Power [W]')
title('Disaggregation Results')
legend(' Dryer','DishWasher',...
    'Fridge','Heatpump',' Kitchenwall',' TV')
