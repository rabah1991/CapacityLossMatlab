function [loss_cap, Cap_cyc, Cap_cal]=semi_empirical_model(Data,N,period,batt,Crate)
%%
% Semi empirical model of the Li-ion batteries
% 06.10.2021             
% M.Rabah            
% e3Power               
% Matlab R2021a
%%
% Function estimates the loss of the capacity of Li-ion battery by using
% semi-empirical models of the LFP/C and LCO+NCA/LTO Li-ion batteries.
% The loss of capacity is calculated in percentage.
%% Requered information should be written as masive 
    %%
    % Data.time - time [s]
    % Data.SoC- battery state of charge from 0 to 1 [-]
    % Data.I - battery current [A]
    % Data.T - battery temperature [K]
    % Crate - rated capacity [Ah]
    % N - number of the cycle repetitions 
    % batt - Li-ion battery chemistry 
    % period - minimum storage period when calendar aging is considered [days]
    %%
    % output
    % loss_cap - total loss of capacity [%]
    % Cap_cyc - loss of capacity per each cycle [%]
    % Cap_cal - loss of capacity per each rest time [%]
%%
    loss_cap =[];
    Cap_cyc =[];
    Cap_cal =[];
%% Check
    if N<=0
        disp('Numer of the cycles repetionions should be more than 0')
        return;
    end
    if period<0
        disp('Rest period should be more or equal to 0')
        return;
    end
        
%% LTO battery aging model data "Lithium-titanate battery"
    I=[1 2 3 1 1]; % C-rate current [-]
    B=[0.0542 0.0289 0.0626 0.0215 0.0180]; 
    d=[0.3923 -0.0103 0.2260 0.2620 0.02346];
    n=1;                   
    LTO.B=polyfit(I,B,n);
    LTO.d=polyfit(I,d,n); 
    %𝐸(𝐼)=𝐸𝑎+𝑎∙I
    E = [63467 43458 19468 -85491 39699];
    LTO.p = polyfit(I,E,1);
    LTO.Ea=LTO.p(2); %Activation energy of reaction
    LTO.a=LTO.p(1);  %Fitting coeffiecnt
    LTO.z=0.5202;   %Constant
    
    LTO.a1=-0.0199;  %Fitting constant
    LTO.a2=0.0194;   %Fitting constant
    LTO.Ecal=112868; %Activation energy of reaction
    LTO.zcal=0.4052; %Constant 
    LTO.Tref=25+273.15;      % reference temperature [K] 

%% LFP battery aging model data "Lithium iron phosphate battery"
    I=[0.5 2 6 10]; 
    B=[0.0522 0.0338 0.1910 0.1438]; 
    n=1;                    
    LFP.B=polyfit(I,B,n);
    LFP.d=0;
    LFP.E = [31273 34721 10271 16959];
    LFP.P = polyfit(I,LFP.E,1);
    LFP.Ea=LFP.P(2);
    LFP.a=LFP.P(1);
    LFP.z=0.5305; 
    LFP.a1=0.0314;
    LFP.a2=0.0193;
    LFP.Ecal=28602;
    LFP.zcal=0.5877;
    LFP.Tref=273.15;               
%%
    R=8.314; % Gas constant [J/K/mol]
    if batt=='LTO'
        Chem=LTO;
    elseif batt=='LFP'
        Chem=LFP;
    elseif batt=='ABC'
        Chem=ABC;
    else
        disp('The battery chemistries should be LFP or LTO')
        return;
    end      
%%
    % rainflow algorithm
    %% Calculate number of cycles
    figure(1)
    plot(Data.time/3600,Data.SoC*100)
    grid on
    xlabel('Time, h')
    ylabel('SoC [%]')
    C=rainflow(Data.SoC,Data.time);  %returns cycle counts for x sampled at the time values stored in t
                                    %Usually, the algorithm extract cycles from load, stress or strain history obtained from measurement or simulation. 
                                    %Basically the cycle is the number the SOC does either start increasing or decreasing 
                                    
    for i=1:length(C(:,1))
        ch1=find(Data.time==C(i,4)); %Finding the row number of the equivilant start time
        ch2=find(Data.time==C(i,5)); %Finding the row number of the equivilant end time
        if C(i,1)==1 
            if Data.SoC(ch1)<Data.SoC(ch2)
                ch2=find(Data.SoC(ch2:end)<Data.SoC(ch1),1,'first')+ch2;
            else
                ch2=find(Data.SoC(ch2:end)>Data.SoC(ch1),1,'first')+ch2;
            end
        end
        CyC.I(i)=abs(mean(Data.I(ch1:ch2)))/Crate;
        CyC.T(i)=mean(Data.T(ch1:ch2));
        CyC.DoD(i)=C(i,2);
        CyC.SoC(i)=C(i,3);
        CyC.N(i)= C(i,1).*N; % N is number of cycles
        
    end
    
    LIM     = linspace(0,max(CyC.DoD)+0.05,30);                                                                                            
    NN(1:length(LIM)-1) = 0;
    for j=1:length(CyC.N)
        for i = 1:(length(LIM)-1)
            if  (CyC.DoD(j) >= LIM(i)) && (CyC.DoD(j) < LIM(i+1))
                 NN(i)= NN(i)+CyC.N(j);                  
            end
        end
    end
    figure(2)
    bar(LIM(1:end-1).*100,NN)
    grid on
    ylabel('Number of cycle')
    xlabel('DoD [%]')

%% calculation of the loss of capacity in percentage during cycling aging
    for i=1:length(CyC.DoD)
        Cap_cyc(i)=polyval(Chem.B,abs(CyC.I(i)))*exp(-(Chem.Ea+Chem.a*(CyC.I(i)))/R*(1/CyC.T(i)-1/Chem.Tref))*(CyC.N(i)*CyC.DoD(i))^(Chem.z-polyval(Chem.d,abs(CyC.I(i)))*CyC.DoD(i));
    end
    
%% calculate the calendar aging
    Cal.t=[];
    period=period*24*3600;
    i=1;
    dt=mean(diff(Data.time));
    while isempty(find(Data.I(i:end)==0))==0
        ch1=find(Data.I(i:end)==0,1,'first')+i;
        ch2=find(Data.I(ch1:end)~=0,1,'first')+ch1;
        if isempty(ch2)
            ch2=length(Data.I);
        end
        if ch2-ch1>=round(period/dt)
            Cal.SoC=mean(Data.SoC(ch1:ch2));
            Cal.T=mean(Data.T(ch1:ch2));
            Cal.t=(Data.time(ch2)-Data.time(ch1))./3600/24.*N;
            t = (Data.time(ch2)-Data.time(ch1))./3600/24.*N;
        end
        i=ch2+1;
    end
end
