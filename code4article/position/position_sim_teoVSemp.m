format long
% add to path super folders (one level)
addpath(fileparts(pwd));
% add to path sub folders 
addpath(genpath(pwd));


%% Parameters
% time index of Lindley process
n=4;
% number of samples
num_samples=10000000;
% Drift of the process - mean of the increment
mu=-1.8;
% standard error of the increment
s=10;
% initial condition
x=1;


%% Simulated density
% simulated increments
Xn = laprnd(num_samples, n, mu, s*sqrt(2));
% simultated process - to be filled
Yn_sequence = zeros(num_samples, n+1);
% initial condition
Yn_sequence(:,1) = repelem(x,num_samples);
for i = 1:n
    Yn_sequence(:,i+1) = max(0,Yn_sequence(:,i)+Xn(:,i));
end
% select `n`-th element of the sequence
Yn = Yn_sequence(:,n+1);
% it will be used in plotting
maxYn = max(Yn);
% Empirical mass in zero
c = sum(Yn==0)/num_samples;
%}


%% Analytic density
% number of points at which the analytic curves will be plotted
resolution = 1000;
% points at which the analytic curves will be plotted
u = linspace(0.0001, maxYn, resolution);
if mu >= 0
    fprintf('mu>=0 \n')
    theo_curve_rec = arrayfun(@(u) f_Tn_s(u,n,mu,x,s),u);
    % Teorical mass in zero
    c_rec = f_Tn_s(0,n,mu,x,s);
elseif mu < -x 
    fprintf('mu<-x \n')
    theo_curve_rec = arrayfun(@(u) f_Tn_muMinoreMenoX(n,u,mu,x,s),u);
    % Teorical mass in zero
    c_rec = f_Tn_muMinoreMenoX(n,0,mu,x,s);
 elseif mu > -x  
    fprintf('-x<=mu<0 \n')
    theo_curve_rec = arrayfun(@(u) f_Tn_muMaggioreMenoX(n,u,mu,x,s),u);
    % Teorical mass in zero
    c_rec = f_Tn_muMaggioreMenoX(n,0,mu,x,s);
end



%% Plotting 
figure(3)
num_bins=200;
[height,b]=hist(Yn(find(Yn~=0)),num_bins);
bins=diff(b);
bin_width = bins(1);
l1=bar(b, height / (bin_width*sum(height)) * (1-c),'k'); hold on;
p1=plot(0.1, c, '.k', 'MarkerSize',23); hold on;
xlim([0,maxYn]); 
l2=plot(u,theo_curve_rec,'r','LineWidth',1.4); hold on;
p2=plot(0.3, c_rec, '.r'); hold on;
xlabel('Position');
ylabel('Density');
title(['W_{', num2str(n), '} density.  \mu: ', num2str(mu) , ',  \sigma:  ', num2str(s), ', x: ', num2str(x)]);
%legend([l2 l3],{'analitica', 'ricorsiva'})
legend([l1,l2],{'empirica', 'teorica'});
p2.MarkerSize = 20;

