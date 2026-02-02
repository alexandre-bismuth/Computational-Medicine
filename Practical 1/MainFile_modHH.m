close all; % to close all open figures
clear; clc; % to clear all variabless and workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main File to run the Hodgkin-Huxley Neuron Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Settings: 
global input_args
% model_name: 
mod = @modHH;
t_sim = 500; % lenght of the simulation in ms
% ODE settings
ODEstep = 0.1; % integration step in ms 
options=odeset('MaxStep',ODEstep);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial Conditions (one for each of the state variables)
% Values for [V_0, m_0, h_0, n_0];
CI = [-60, 0.5, 0.5, 0.5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Model Optional Inputs (see model file for details)
input_args = {};
% Examples of how to use the different Model Optional Inputs
% -> you can uncomment what you need
%
% input_args{1} = 1; % flag_ode: 1 when solving ODEs, 0 when computing variables
input_args{2} = [1,80,0.5,100]; % Periodic stimulus
% input_args{2} = [2,80]; % Constant stimulus
% input_args{2} = [3,80,t_sim]; % Ascending Ramp Stimulus
% input_args{2} = [4,80,t_sim]; % Descending Ramp Stimulus
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulations
[t,y] = ode15s(mod,[0 t_sim],CI,options);
% Computed Variables: 4 ionic currents
input_args{1}=0; 
lCVs=size(feval(mod,t(1),y(1,:)),1);
CVs = zeros(length(t),lCVs);
for j=1:size(y,1)
    CVs(j,:)=feval(mod,t(j),y(j,:));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1: Membrane Potential and Stimulus Current + Zoom on last beat
figure(1); 
subplot(3,1,1); hold on;
plot(t,CVs(:,1),'LineWidth',2); 
ylabel('I_{stim} (uA/uF)'); xlabel('time (ms)');
xlim([0 t_sim]);
subplot(3,1,2); hold on;
plot(t,y(:,1),'LineWidth',2); 
ylabel('Membrane Potential (mV)'); xlabel('time (ms)');
xlim([0 t_sim]);
subplot(3,1,3); hold on;
plot(t,y(:,1),'LineWidth',2); 
ylabel('Membrane Potential (mV)'); xlabel('time (ms)');
xlim([350 450]);
%% ***Optional Figures*** Uncomment below if you want to see them
% %% Figure 2: Gating Variables
% h2=figure(2); 
% subplot(3,1,1); hold on;
% plot(t,y(:,2),'LineWidth',2); 
% ylabel('gate m'); xlabel('time (ms)');
% xlim([0 t_sim]);
% subplot(3,1,2); hold on;
% plot(t,y(:,3),'LineWidth',2); 
% ylabel('gate h'); xlabel('time (ms)');
% xlim([0 t_sim]);
% subplot(3,1,3); hold on;
% plot(t,y(:,4),'LineWidth',2); 
% ylabel('gate n'); xlabel('time (ms)');
% xlim([0 t_sim]);
% %% Figure 3: Ionic Currents
% h3=figure(3); 
% subplot(2,2,1); hold on;
% plot(t,CVs(:,1),'LineWidth',2); 
% ylabel('I_{stim} (uA/uF)'); xlabel('time (ms)');
% xlim([0 t_sim]);
% subplot(2,2,2); hold on;
% plot(t,CVs(:,3),'LineWidth',2); 
% ylabel('I_{K} (uA/uF)'); xlabel('time (ms)');
% subplot(2,2,3); hold on;
% plot(t,CVs(:,2),'LineWidth',2); 
% ylabel('I_{Na} (uA/uF)'); xlabel('time (ms)');
% xlim([0 t_sim]);
% subplot(2,2,4); hold on;
% plot(t,CVs(:,4),'LineWidth',2); 
% ylabel('I_{leak} (uA/uF)'); xlabel('time (ms)');
% xlim([0 t_sim]);

%% END FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%