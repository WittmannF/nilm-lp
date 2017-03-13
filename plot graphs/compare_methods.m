clc
clear all
close all
%% Initial variables
axis_coord = [400 1440 0 5500]; % Axis scaling coordinates

%% Read results from AMPL for the FULL model
X = x;
ESTADO = estado;

% Vectors
TS = X(:,1); 
Pdisp = X(:,2:end)*diag(ESTADO(:,2));
Ptotal = X(:,2:end)*ESTADO(:,2);

F = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0
     0 0 1 1 1 0 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 1 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 0 1 1 1 0 0 0 0 0 0
     0 0 0 0 0 0 0 0 0 1 1 1 1 0 0
     0 0 0 0 0 0 0 0 0 0 0 0 0 1 1];
 
K = F*diag(ESTADO(:,2));
Pdisp = X(:,2:end)*K';

%% Read ground truth data
DATA = csvread('ground_truth.csv');
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

%% Read Pattern Recognition Results
names = {'onemin_dry.csv', 'onemin_dws.csv', 'onemin_refr.csv', 'onemin_htp.csv', 'onemin_unk.csv'};

PATREC = zeros(1440,5);
i = 1;
for name = names  
    appl = csvread(char(name));
    PATREC(:,i) = appl(:,2);
    i = i+1;    
end

%% Plot Results
% Subplot Ground Truth Data
sp(1) = subplot(4,1,1);
bar(time, [CDE_P DWE_P FGE_P HPE_P WOE_P TV_P],'stacked');
hold on
P = bar(0); % Additional element in the legend for unknown loads
set(P(1),'facecolor',[0.5 0.5 0.5])
set(P(1),'facecolor',[0.5 0.5 0.5])
L = legend('CDE','DWE','FGE','HPE','WOE',' TV','Unkn');
ylabel('Power [W]')
t(1) = title('Ground Truth Data');
axis(axis_coord)
set(gca,'xtick',[],'fontsize',7)
%legend('Location','northwest')

% Subplot CO data
sp(2) = subplot(4,1,2);
Pdisp = X(:,2:end)*K';
bar(TS, Pdisp,'stacked');
ylabel('Power [W]')
t(2) = title('Combinatorial Optimization');
axis(axis_coord)
set(gca,'xtick',[],'fontsize',7)

% hold on

axes('position',[.17 .6 .1 .07]) % Put subzoom
b = bar(Pdisp(700:800,:), 'stacked', 'EdgeColor', 'none');
axis tight
set(gca,'xtick',[],'ytick',[]);

axes('position',[.43 .6 .1 .07]) % Put subzoom
b = bar(Pdisp(700:800,:), 'stacked', 'EdgeColor', 'none');
axis tight
set(gca,'xtick',[],'ytick',[]);


axes('position',[.67 .6 .1 .07]) % Put subzoom
b = bar(Pdisp(700:800,:), 'stacked', 'EdgeColor', 'none');
axis tight
set(gca,'xtick',[],'ytick',[]);




% Subplot Full Model data
sp(3) = subplot(4,1,3);
Pdisp = X(:,2:end)*K';
bar(TS, Pdisp,'stacked');
set(gca,'xtick',[],'fontsize',7)
ylabel('Power [W]')
t(3) = title('This Work');
axis(axis_coord)


% Subplot Patter Recognition data
sp(4) = subplot(4,1,4);
P = bar(PATREC,'stacked');
C = [53 42 134;
    12 116 220;
    6 169 193;
    124 191 123
    127 127 127]/255;
for n=1:length(P) 
set(P(n),'facecolor',C(n,:));
end
set(gca,'fontsize',7)
xlabel('Index of the element (min)')
ylabel('Power [W]')
t(4) = title('Pattern Recognition');
axis(axis_coord)


%% Post subplot config
% Size of the graph
x0=15;
y0=10;
width=17;
height=12;
set(gcf,'units','centimeters','position',[x0,y0,width,height])

% Position of the title

for i = 1:4
    t(i).Position(2) = t(i).Position(2) - 1250;
end

% Size of each subplot
for i = 1:4
    sp(i).Position(4) = sp(i).Position(4)*1.35;
end

% Position of the legend
L.Position = [0.14, 0.785, 0.0950, 0.1854];

