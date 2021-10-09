clc
close all
clear variables

% Load the log-returns of A & B
data = readtable('lab4_data.xlsx');
%%
ATTPx = data.T;
VERPx = data.VZ;
Price = [ATTPx VERPx];
Date = datenum(data.Date);
ATT = price2ret(ATTPx);
VER = price2ret(VERPx);
%%
figure(1)
plot(Date,ATTPx,'r');hold on;
plot(Date,VERPx,'b');dateaxis('x',12);hold off
title('Prices of AT&T and Verizon over past 1 year');xlabel('Date');ylabel('Prices');
%%
figure(2)
subplot(2,1,1);autocorr(ATT);title('Autocorrelation Return of AT&T')
subplot(2,1,2);autocorr(VER);title('Autocorrelation Return of Verizon')
%%
figure(3)
subplot(2,1,1);autocorr(ATT.^2);title('Autocorrelation Return of AT&T')
subplot(2,1,2);autocorr(VER.^2);title('Autocorrelation Return of Verizon')
%%
[muA,sigmaA] = normfit(ATT);
U_ATT = normcdf(ATT, muA, sigmaA);
[muV,sigmaV] = normfit(VER);
U_VER = normcdf(VER, muV, sigmaV);
%%
figure(4)
scatterhist(ATT,VER,'NBins',[12,12],'Marker','.','MarkerSize',10);
xlabel('AT&T');ylabel('Verizon');hold on
xline(muA,'r');%xline(muA+2*sigmaA,'b');xline(muA-2*sigmaA,'b');
yline(muV,'r');%yline(muV+2*sigmaV,'b');yline(muV-2*sigmaV,'b');
%%
Theta = copulafit('Clayton',[U_ATT U_VER]);
%%
figure(5)
u = linspace(0,1,25);
[u1,u2] = meshgrid(u,u);
yp = copulapdf('Clayton',[u1(:),u2(:)],Theta);
surf(u1,u2,reshape(yp,25,25),'facecolor','interp');
xlabel('AT&T');ylabel('Verizon');zlabel('PDF of Clayton Copula');
%%
figure(6)
scatterhist(U_ATT,U_VER,'NBins',[12,12],'Direction','out','Marker','.','MarkerSize',12);
xlabel('Transformed AT&T');ylabel('Transformed Verizon');hold on
%contour(u1,u2,reshape(yp,25,25),'showtext','on','linewidth',1);
%%
figure(7)
yc = copulacdf('Clayton',[u1(:),u2(:)],Theta);
surf(u1,u2,reshape(yc,25,25),'facecolor','interp');
xlabel('AT&T');ylabel('Verizon');zlabel('CDF of Clayton Copula');
%%
n = 50000;
sp = copularnd('Clayton',Theta,n);
%contour(u1,u2,reshape(yp,25,25),'showtext','on','linewidth',1);
%%
bin2 = histcounts2(norminv(sp(:,1)),norminv(sp(:,2)),[20,20]);
binarea = (8/20).^2;
yinv2 = bin2./(n*binarea);
s = linspace(-4,4,20);
[s1,s2] = meshgrid(s,s);
figure(9)
surf(s1,s2,yinv2,'facecolor','interp');
xlabel('AT&T');ylabel('Verizon');zlabel('PDF of norminv Clayton');
figure(10)
scatterhist(norminv(sp(:,1)),norminv(sp(:,2)),'NBins',[50,50],'Direction','out','Marker','.','MarkerSize',3);
xlabel('AT&T');ylabel('Verizon');hold on
contour(s1,s2,yinv2,'showtext','on','linewidth',2);
xline(2,'b');xline(-2,'b');
yline(2,'b');yline(-2,'b');
%%
figure(8)
scatterhist(sp(:,1),sp(:,2),'NBins',[20,20],'Direction','out','Marker','.','MarkerSize',1);
xlabel('Transformed AT&T');ylabel('Transformed Verizon');hold on
contour(u1,u2,reshape(yp,25,25),'showtext','on','linewidth',1);
%%
% inva = norminv(sp(:,1));
% invb = norminv(sp(:,2));
% bin = zeros(100,100);
% for i = 1:100
%     for j = 1:100
%         jlow = j*0.08-4-0.08;
%         ilow = i*0.08-4-0.08;
%         xcount = (inva>jlow) .* (inva<=j*0.08-4);
%         ycount = (invb>ilow) .* (invb<=i*0.08-4);
%         bin(i,j) = sum(xcount.*ycount);
%     end
% end
% %%
% 
% yinv = bin./(n*binarea);
% figure(8)
% surf(s1,s2,yinv,'facecolor','interp');
% xlabel('AT&T');ylabel('Verizon');zlabel('PDF of norminv Clayton');
%%
% figure(11);
% scatterhist(inva,invb,'NBins',[50,50],'Direction','out','Marker','.','MarkerSize',3);
% xlabel('AT&T');ylabel('Verizon');hold on
% contour(s1,s2,yinv,'showtext','on','linewidth',2);
% %%
% figure(10)
% scatter(inva,invb,'.');xlabel('AT&T');ylabel('Verizon');
%%
rndu = copularnd('Clayton',Theta,10);
mu = [muA muV];
sigma = [sigmaA sigmaV];
rndReturn = norminv(rndu,repmat(mu,10,1),repmat(sigma,10,1));
rnfPx = ret2price(rndReturn, Price(end,:));
%%
figure(12)
plot(1:14,[Price(end-3:end,:);rnfPx(2:end,:)],'linewidth',2,'Marker','*');
ylim([20 70]);
xticks(1:14);
xticklabels(datestr(Date(end-13:end),7));
xline(3.5,'r');
legend('AT&T','Verizon');
title('10-Day Forward Prices');
xlabel('Date');ylabel('Prices');







