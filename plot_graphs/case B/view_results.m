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
states = [1 1 2 2 3 3 4 5 6 6 6 7 7];
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
sp(1) = subplot(4,1,1);
bar(time, DATA(:,1:7),1,'stacked');
L = legend(app_list);
xlabel('t (min)')
ylabel('Active Power [W]')
title('Ground Truth Data')
%legend('Location','northwest')

%% Subplot Full Model data
sp(2) = subplot(4,1,2);
Pdisp = X(:,2:end)*K';
bar(TS, Pdisp, 1,'stacked');
xlabel('t (min)')
ylabel('Active Power [W]')
t(3) = title('Full Model');

%% Metrics for the FULL model
disp(['================ Results for the FULL model ================']);
i = 1;
for y_true = DATA(:,1:7)
    y_pred = Pdisp(:,i);
    disp(['================ ',app_list(i,:),' ================']);
    TEE = round(abs(sum(y_true) - sum(y_pred))/sum(y_true)*100,1)
    TIE = round(sum(abs(y_true(1:length(y_pred)) - y_pred))/sum(y_true)*100,1)
    
    i=i+1;
end

%% Read results from AMPL for CO
X_co = x_co;
ESTADO_co = estado_co;

% Vectors
TS_co = X_co(:,1); 
Ptotal_co = X_co(:,2:end)*ESTADO_co(:,2);
K_co = F*diag(ESTADO_co(:,2));
 
%% Subplot CO data
sp(3) = subplot(4,1,3);
Pdisp_co = X_co(:,2:end)*K_co';
bar(TS_co, Pdisp_co,1,'stacked');
ylabel('Power [W]')
t(2) = title('(b) Combinatorial Optimization');

%% Metrics for the CO model
disp(['================ Results for the CO model ================']);
i = 1;
for y_true = DATA(:,1:7)
    y_pred = Pdisp_co(:,i);
    disp(['================ ',app_list(i,:),' ================']);
    TEE = round(abs(sum(y_true) - sum(y_pred))/sum(y_true)*100,1)
    TIE = round(sum(abs(y_true(1:length(y_pred)) - y_pred))/sum(y_true)*100,1)
    
    i=i+1;
end

%% Read results from Pattern Recognition
FGE_pr = csvread('unk1.csv',0,1);
HPE_pr = csvread('unk2.csv',0,1);
CDE_pr = csvread('unk3.csv',0,1);
unk4 = csvread('unk4.csv',0,1); % Part of  

sp(4) = subplot(4,1,4);
bar(time, [FGE_pr HPE_pr CDE_pr unk4],1,'stacked');
L = legend('FGE','HPE','CDE','Unk4');
xlabel('t (min)')
ylabel('Active Power [W]')
title('Ground Truth Data')

%% Metrics for the Patt. Rec. model
disp(['================ Results for the Patt. Rec. model ================']);
i = 1;
y_preds = [CDE_pr FGE_pr HPE_pr unk4];
app_list = ['CDE';'FGE';'HPE'];
for y_true = [CDE_P FGE_P HPE_P]
    y_pred = y_preds(:,i);
    disp(['================ ',app_list(i,:),' ================']);
    TEE = round(abs(sum(y_true) - sum(y_pred))/sum(y_true)*100,1)
    TIE = round(sum(abs(y_true(1:length(y_pred)) - y_pred))/sum(y_true)*100,1)
    
    i=i+1;
end

%% Visualize results
