%% %%%%%%%%%%%%%%%%%%%%%%
% Battery lifetime model%
% 06.10.2021             
% M.Rabah            
% e3Power               
% Matlab R2021a

clc; clear; close all;
%% Load simulated battery data
load('Batt.mat')
%% Requered information should be written as masive 
%%
    % Data.time - time [s]
    % Data.SoC- battery state of charge from 0 to 1 [-]
    % Data.I - battery current [A]
    % Data.T - battery temperature [K]
    % C_n - rated capacity [Ah]
    % N - number of the cycle repetitions 
    % batt - Li-ion battery chemistry 
    % period - minimum storage period when calendar aging is considered [days]
%%
Data.time=Batt.Time;
Data.SoC=Batt.Data(:,11)./100;
Data.I=Batt.Data(:,1);
Data.T=Batt.Data(:,12)+273.15; %Add 10 if you want to test in 35c 
C_n=23;
batt='LTO';
N=1000;
period=1.15740740740741e-05; % 0.01;
%% 
[Loss_cap, Cap_cyc, Cap_cal]=semi_empirical_model(Data,N,period,batt,C_n);
fprintf('Total loss of the capacity %g percents.\n',Loss_cap);
fprintf('Total loss of the capacity during cycling aging %g percents.\n',sum(Cap_cyc));
