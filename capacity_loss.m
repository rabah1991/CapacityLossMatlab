%% %%%%%%%%%%%%%%%%%%%%%%
% Battery lifetime model%
% 06.10.2021             
% M.Rabah            
% e3Power               
% Matlab R2021a



clc; clear; close all;
%% Load battery data
% Datasw1 -> Median SoC = 15%
% Datasw2 -> Median SoC = 50%
load('Datasw2.mat')
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
Data.time=Datasw.time;
Data.SoC=(Datasw.SoC)/100;
Data.I=Datasw.I;
Data.T=Datasw.T+273.15; %Add 10 if you want to test in 35c 
C_n=30;
batt='LTO';
N=2300;
period=450;

%% 
[Loss_cap, Cap_cyc, Cap_cal]=semi_empirical_model(Data,N,period,batt,C_n);
fprintf('Total loss of the capacity %g percents.\n',Loss_cap);
fprintf('Total loss of the capacity during cycling aging %g percents.\n',sum(Cap_cyc));
