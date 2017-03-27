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
states = [1 2 2 3 3 4 4 4 5 5 5 6 7 7];
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
DATA = csvread('z_ground_truth.csv');
time = 1:length(DATA);
CDE_P = DATA(:,1);
CDE_Q = DATA(:,2);
DWE_P = DATA(:,3);
DWE_Q = DATA(:,4);
FGE_P = DATA(:,5);
FGE_Q = DATA(:,6);
HPE_P = DATA(:,7);
HPE_Q = DATA(:,8);
WOE_P = DATA(:,9);
WOE_Q = DATA(:,10);
TV_P = DATA(:,11);
TV_Q = DATA(:,12);
ALL_P = DATA(:,13);
ALL_Q = DATA(:,14);

%% Subplot Ground Truth Data
sp(1) = subplot(2,1,1);
bar(time, [CDE_P DWE_P FGE_P HPE_P WOE_P TV_P],1,'stacked');
L = legend('CDE','DWE','FGE','HPE','WOE',' TV');
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

% TEE = \dfrac{|\sum_{t}{y_i(t)} - \sum_{t}{\hat{y}_i(t)}|}{\sum_{t} { y_i(t)}}
y_true_cde = CDE_P;
y_pred_cde = Pdisp(:,1);
TEE_cde = round(abs(sum(y_true_cde) - sum(y_pred_cde))/sum(y_true_cde)*100,1)

y_true_dwe = DWE_P;
y_pred_dwe = Pdisp(:,2);
TEE_dwe = round(abs(sum(y_true_dwe) - sum(y_pred_dwe))/sum(y_true_dwe)*100,1)

y_true_fge = FGE_P;
y_pred_fge = Pdisp(:,3);
TEE_fge = round(abs(sum(y_true_fge) - sum(y_pred_fge))/sum(y_true_fge)*100,1)

y_true_hpe = HPE_P;
y_pred_hpe = Pdisp(:,4);
TEE_hpe = round(abs(sum(y_true_hpe) - sum(y_pred_hpe))/sum(y_true_hpe)*100,1)

y_true_woe = WOE_P;
y_pred_woe = Pdisp(:,5);
TEE_woe = round(abs(sum(y_true_woe) - sum(y_pred_woe))/sum(y_true_woe)*100,1)

y_true_tv = TV_P;
y_pred_tv = Pdisp(:,6);
TEE_tv = round(abs(sum(y_true_tv) - sum(y_pred_tv))/sum(y_true_tv)*100,1)

% TIE = \dfrac{\sum_{t} { |y_i(t) - \hat{y}_i(t)|}}{\sum_{t} { y_i(t)}}
TIE_cde = round(sum(abs(y_true_cde(1:1435) - y_pred_cde))/sum(y_true_cde)*100,1) % adjust length to match with the prediction

TIE_dwe = round(sum(abs(y_true_dwe(1:1435) - y_pred_dwe))/sum(y_true_dwe)*100,1)

TIE_fge = round(sum(abs(y_true_fge(1:1435) - y_pred_fge))/sum(y_true_fge)*100,1)

TIE_hpe = round(sum(abs(y_true_hpe(1:1435) - y_pred_hpe))/sum(y_true_hpe)*100,1)

TIE_woe = round(sum(abs(y_true_woe(1:1435) - y_pred_woe))/sum(y_true_woe)*100,1)

TIE_tv = round(sum(abs(y_true_tv(1:1435) - y_pred_tv))/sum(y_true_tv)*100,1)


