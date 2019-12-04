close all;
clear
%
% Change here for different plots %
%
stage = 'Optimise/DCF';
%
testno = '3';
%
% % % % % % % % % % % % % % % % % % 
%
% euler bit
fin = fopen(['output/' stage '/euler_test' testno '.mat'],'r');
data = fscanf(fin,'%f');
ni = data(1,1);
nj = data(2,1);
idone = 2;
x = zeros(ni,nj);
y = zeros(ni,nj);
ro = zeros(ni,nj);
vx = zeros(ni,nj);
vy = zeros(ni,nj);
p = zeros(ni,nj);
%
for i=1:ni
  for j=1:nj
    x(i,j)  = data(idone+1,1);
    y(i,j)  = data(idone+2,1);
    ro(i,j) = data(idone+3,1);
    vx(i,j) = data(idone+4,1);
    vy(i,j) = data(idone+5,1);
    p(i,j)  = data(idone+6,1);
    idone = idone+6;
  end 
end
fclose(fin);
%
% Contour Static Pressure
%
figure('Name','Static Pressure');
hold on
daspect([1 1 1]);
plot(x(:,1),y(:,1),'b','Linewidth',1);
plot(x(:,nj),y(:,nj),'b','LineWidth',1);
pmax = round(max(max(p)),1,'significant');
pmin = round(min(min(p)),1,'significant');
delp = (pmax-pmin)/pmin;
V = linspace(pmin,pmax,21);
[C,h] = contourf(x,y,p,V,'LineWidth',.5);
%clabel(C,'manual','FontSize',14);
colorbar
hold off;
%pause
%
% Plot grid
%
figure('Name','Grid');
hold on;
daspect([1 1 1]);
for j=1:nj
  plot(x(:,j),y(:,j),'b');
end
for i=1:ni
  plot(x(i,:),y(i,:),'b');
end
hold off;
%
% Contour derived variables
%
gam = 1.4;
a = sqrt(gam*p(1,1)/ro(1,1));
p0 = zeros(ni,nj);
mach = zeros(ni,nj);
for i=1:ni
  for j=1:nj
    mach(i,j) = sqrt(ro(i,j)*(vx(i,j)^2+vy(i,j)^2)/(gam*p(i,j)));
    p0(i,j) = p(i,j)*(1.+.5*(gam-1.)*mach(i,j)^2)^(gam/(gam-1));
  end 
end
hold off
%
% Contour pstat
%
figure('Name','Stagnation Pressure');
hold on
daspect([1 1 1]);
contourf(x,y,p0,20,'LineWidth',.5);
plot(x(:,1),y(:,1),'b','Linewidth',1);
plot(x(:,nj),y(:,nj),'b','LineWidth',1);
p0max = max(max(p0));
p0min = min(min(p0));
title (['$P_{0,max}=' num2str(p0max,'%10.4e\n') '\qquad P_{0,min}=' num2str(p0min,'%10.4e\n') '$'],'interpreter','latex')
colorbar
hold off
%
% Contour Mach number
%
figure('Name','Mach Number');
hold on
daspect([1 1 1]);
contourf(x,y,mach,20,'LineWidth',.5);
plot(x(:,1),y(:,1),'b','Linewidth',1);
plot(x(:,nj),y(:,nj),'b','LineWidth',1);
machmax = max(max(mach));
machmin = min(min(mach));
title (['$M_{max}=' num2str(machmax,'%10.4f\n') '\qquad M_{min}=' num2str(machmin,'%10.4f\n') '$'],'interpreter','latex')
colorbar
%
rgas = 287.1;
cp = rgas*gam/(gam-1.0); %change according to gas
cv = cp/gam;
ds = zeros(ni,nj);
for i=1:ni
  for j=1:nj
    ds(i,j) = cv*log(p(i,j)/p(1,1))+cp*log(ro(1,1)/ro(i,j));
  end 
end
hold off
%
% Contour relative entropy
%
figure('Name','Entropy');
hold on
daspect([1 1 1]);
contourf(x,y,ds,20,'LineWidth',.5);
plot(x(:,1),y(:,1),'b','Linewidth',1);
plot(x(:,nj),y(:,nj),'b','LineWidth',1);
dsmax = max(max(ds));
title (['$ds_{max}=' num2str(dsmax,'%10.2f\n') '$'],'interpreter','latex')
colorbar
hold off
%
%
% CONVERGENCE PLOT %
%
pltconv_file = ['output/' stage '/pltcv_test' testno '.csv'];
pltconv = csvread (pltconv_file);
nstep       = pltconv(:,1);
delroavg    = pltconv(:,2);
delrovxavg  = pltconv(:,3);
delrovyavg  = pltconv(:,4);
try
    delroeavg   = pltconv(:,5);
end
%
figure('Name','Convergence');
hold on
plot (nstep,log10(delroavg),'DisplayName','$\rho$')
plot (nstep,log10(delrovxavg),'DisplayName','$V_x$')
plot (nstep,log10(delrovyavg),'DisplayName','$V_y$')
try
    plot (nstep,log10(delroeavg),'DisplayName','$E$')
end
xlim([nstep(1),nstep(end)]);
xlabel('Number of iterations','Interpreter','latex')
ylabel('$\log_{10}(\Delta$value$/$reference$)$','Interpreter','latex')
title (['$' num2str(nstep(end)) '$ iterations to converge'],'interpreter','latex')
hl = legend('show');
set(hl,'Interpreter','latex');
hold off
%