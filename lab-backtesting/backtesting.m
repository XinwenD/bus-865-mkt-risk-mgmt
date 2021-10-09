clc
clear
close all
%% Import data
% data = readtable('NTDOY.csv');
%%
% ninR = price2ret(data.AdjClose);
ninR = trnd(1,1000,1)/100;
%% Plot historical returns
plot(data.Date(2:end),ninR);
dates = 1:length(ninR); %data.Date(:);
xlabel('Dates');ylabel('Returns');title('Historical Returns');
datetick('x',12);xlim([dates(1) dates(end)]);
%% Define model and variables
Mdl = arima('ARLags',1,'MALags',1,'Variance',garch(0,0));
T = length(ninR);
EstWin = 950;
p = 0.05;
NumObs = 1;
NumPaths = 100;
VaR_5p = NaN(T,1);%
VaR_1p = NaN(T,1);%
ES = NaN(T,1);
Simu = NaN(T,NumPaths);
%% Estimation and simulation of each test
for t = EstWin+1:T
    try
        EstMdl = estimate(Mdl,ninR(t-EstWin:t-1));
        [Innovations, Variances] = infer(EstMdl, ninR(t-EstWin:t-1));
        Simu(t,:) = simulate(EstMdl,NumObs,'NumPaths',NumPaths,...
            'E0',Innovations,'V0',Variances);
        s = Simu(:,t);%
        VaR_5p(t) = prctile(s, 5);%
        VaR_1p(t) = prctile(s, 1);%
        index_5p = Simu(:,t)<=VaR_5p(t);%
        ES(t) = mean(s(index_5p));%
        %ES(t) = mean(prctile(Simu(t,:),1:5));
    catch
        VaR_5p(t) = prctile(ninR(t-EstWin:t-1), 5);%
        VaR_1p(t) = prctile(ninR(t-EstWin:t-1), 1);%
        nR = ninR(t-EstWin:t-1);%
        index_5p = ninR(t-EstWin:t-1)<VaR_5p(t);%
        ES(t) = mean(nR(index_5p));%
    end
end
%% Save variable to current path
% save ('VaR.mat', 'VaR');
% save ('ES.mat', 'ES');
% save ('Simu.mat', 'Simu');
%% Find violations and Cal VR
ninR_TstWin = ninR(EstWin + 1:T);
VaR_TstWin = VaR_5p(EstWin + 1:T);
ES_TstWin = ES(EstWin + 1:T);
index_5p = ninR_TstWin<=VaR_5p(EstWin + 1:T);
VR = length(find(index_5p))/(p *(T - EstWin));
s = std(VaR_5p(EstWin + 1:T));
%%
dates = 1:length(ninR_TstWin); %data.Date(EstWin + 1:T);
figure(1)
plot(dates,ninR_TstWin,'r--', dates, VaR_TstWin,'b');
hold on
plot(dates(index_5p),ninR_TstWin(index_5p),'r.','markersize',20)
xlabel('Dates');ylabel('Returns & VaR');title('VaR & Violations');
datetick('x',12);xlim([dates(1) dates(end)]);
%% NS and tests
NS = ninR_TstWin./ES_TstWin.*index_5p;
NS_bar = mean(NS(index_5p));
v = VaR_TstWin * 0;
v(index_5p) = 1;
ber = bern_test(p,v);
ind = ind_test(v);
disp([ber,1-chi2cdf(ber,1),ind,1-chi2cdf(ind,1)])
%%
figure(2)
subplot(2,1,1);
plot(dates,ninR_TstWin,'r--',dates,ES_TstWin,'b');
datetick('x',12);xlim([dates(1) dates(end)]);
xlabel('Dates');ylabel('Returns & ES');title('ES & Normalized ES');
hold on;

subplot(2,1,2);
plot(dates(index_5p),NS(index_5p),'r.','markersize',10)
yline(NS_bar,'r');
datetick('x',12);xlim([dates(1) dates(end)]);
xlabel('Dates');ylabel('Normalized ES, for Violations');
hold off
%% Market Risk Capital
% For Basel, the previous trading days are 250, which is also the testing
% window. In lab the testing window may not the same with Basel
% We just count the violations in the previous 250 trading days
index_5p = ninR_TstWin<=VaR_5p(EstWin + 1:T);
vios = index_5p(end-49:end);
if sum(vios)<=20 %20
    ksi = 3;
elseif sum(vios)>=50 %50
    ksi = 4;
else
    ksi = 3+(1/30)*(sum(vios)-4); %1/30
end
% Average 1% VaR over past 60 trading days
VaR_5p_Ave = mean(VaR_5p(end-50:end));
constant = 0; % Change it according to the question
MarRiskCap = ksi*max(-VaR_5p(end),-VaR_5p_Ave)+constant;
disp(MarRiskCap)




