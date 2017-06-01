clc
clear all
close all

%% Read results from AMPL for the FULL model
X = z_results_x;
ESTADO = z_results_estado;

% Vectors
TS = X(:,1); 
Pdisp = X(:,2:end)*diag(ESTADO(:,2)); % Ignore index at X(:,1)
Ptotal = X(:,2:end)*ESTADO(:,2);

% Make F-matrix
states = [1 1 2 2 3 4 5 6 6 6 7 7];
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

%% Read ground truth data
app_list = ['BME';'CDE';'DWE';'FGE';'FRE';'HPE';'TVE'];
DATA = csvread('z_ground_truth.csv',1,1);
time = 1:length(DATA);
BME_P = DATA(:,1);
CDE_P = DATA(:,2);
DWE_P = DATA(:,3);
FGE_P = DATA(:,4);
FRE_P = DATA(:,5);
HPE_P = DATA(:,6);
TVE_P = DATA(:,7);
ALL_P = DATA(:,8);


%% Subplot Ground Truth Data
sp(1) = subplot(2,1,1);
bar(time, DATA(:,1:7),1,'stacked');
L = legend(app_list);
xlabel('t (min)')
ylabel('Active Power [W]')
title('Ground Truth Data')
%legend('Location','northwest')

%% Subplot Full Model data
sp(2) = subplot(2,1,2);
Pdisp = X(:,2:end)*K';
bar(TS, Pdisp, 1,'stacked');
xlabel('t (min)')
ylabel('Active Power [W]')
t(3) = title('Full Model');

%% Metrics for the FULL model
i = 1;
TEE_avg = 0;
TIE_avg = 0;
n_app = length(Pdisp(1,:));
for y_true = DATA(:,1:7)
    y_pred = Pdisp(:,i);
    disp(['================ ',app_list(i,:),' ================']);
    TEE = round(abs(sum(y_true) - sum(y_pred))/sum(y_true)*100,1)
    TIE = round(sum(abs(y_true(1:length(y_pred)) - y_pred))/sum(y_true)*100,1)
    
    TEE_avg = TEE_avg + TEE/n_app;
    TIE_avg = TIE_avg + TIE/n_app;
    
    i=i+1;
end

disp(['================ Average ================']);
TEE_avg
TIE_avg

 
