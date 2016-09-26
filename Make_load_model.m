DATA = csvread('24h.csv');

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

figure, plot(TV_P)
hist(DishWs_P(DishWs_P>30),1000)
title('Fridge P - Histogram for states > 30W')
xlabel('Power [W]')
ylabel('Freq')
median(Heatpump_P(Heatpump_P>1400 & Heatpump_P<1900 ))
clf
figure, plot(TV_P)
for k = 1:10
    [idx, C, sumd] = kmeans(DishWs_P,k, 'Distance', 'euclidean');
    
    if k == 1
        nearest_pt = C;
    else
        a = sort(C);
        nearest_pt = min(a(2:end)-a(1:end-1));
    end
    %plot(k,nearest_pt,'*', k,sum(sumd),'+', k, min(histc(idx,unique(idx))), 'ok');
    plot(k,nearest_pt,'*', k, min(histc(idx,unique(idx))), 'ok');
    hold on;
end

k = 2; %number of states 
[idx, C] = kmedoids(Fridge_P,k, 'Distance', 'euclidean');
model = C(idx);
plot(1:length(idx),Fridge_P,1:length(idx),model)
legend('Original','Model')
title('Fridge - Original load and model')
xlabel('Time(min)')
ylabel('Power(W)')

figure,
k = 2
[idx, C, sumd] = kmedoids(TV_P(TV_P>30),k, 'Distance', 'euclidean');
C
histc(idx,unique(idx))
k = 3
[~, C, sumd] = kmedoids(TV_P(TV_P>30),k, 'Distance', 'euclidean');
C   
k = 4
[~, C, sumd] = kmedoids(TV_P(TV_P>30),k, 'Distance', 'euclidean');
C   




hist(Heatpump_P(Heatpump_P>30),1000)
title('Fridge P - Histogram for states > 30W')
xlabel('Power [W]')
ylabel('Freq')
median(Heatpump_P(Heatpump_P>1400 & Heatpump_P<1900 ))
median(Heatpump_P(Heatpump_P>2100 & Heatpump_P<2600 ))
[~, C] = kmedoids(Fridge_P(Fridge_P>30),1)


hist(Fridge_P(Fridge_P>30),1000)
title('Fridge P - Histogram for states > 30W')
xlabel('Power [W]')
ylabel('Freq')
median(Fridge_P(Fridge_P>110 & Fridge_P<160))
[~, C] = kmedoids(Fridge_P(Fridge_P>30),1)

hist(DishWs_P(DishWs_P>30),1000)
title('Dish Washer P - Histogram for states > 30W')
xlabel('Power [W]')
ylabel('Freq')
median(DishWs_P(DishWs_P>125 & DishWs_P<155))
median(DishWs_P(DishWs_P>470 & DishWs_P<515))
[~, C] = kmedoids(DishWs_P(DishWs_P>30),3, 'Distance', 'euclidean')

plot(T,Dryer_P,T,Dryer_Q)
hist(Dryer_Q(Dryer_Q>30),1000)
median(Dryer_Q(Dryer_Q>390 & Dryer_Q<440 ))


plot(T,DishWs_P,T,DishWs_Q)
hist(DishWs_Q(DishWs_Q>30),1000)
median(DishWs_Q(DishWs_Q>30 & DishWs_Q<55 ))

% Get Q data from Fridge
plot(T,Fridge_P,T,Fridge_Q)
plot(T,Fridge_Q)
hist(Fridge_Q,1000)
median(Fridge_Q(Fridge_Q>30 & Fridge_Q<55 ))


% Get Q data from Heatpump
plot(T,Heatpump_P,T,Heatpump_Q)
plot(T,Heatpump_Q)
hist(Heatpump_Q(Heatpump_P>2000 & Heatpump_P<2600 ),1000)
median(Heatpump_Q(Heatpump_P>30 & Heatpump_P<45 ))

% Get Q data from TV Entert
plot(T,TV_P,T,TV_Q)
plot(T,TV_Q)
hist(TV_Q(TV_Q>10),1000)
median(TV_Q(TV_P>180 & TV_P<370 ))