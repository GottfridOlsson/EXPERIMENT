%% ----- Measurement of solar intensity ----- %%
%----------------------------------------------%
%    Author:     Gottfrid Olsson
%   Updated:     2021-02-28, 21:23
%      Note:     Data and graph over measurement
%                of temperature over time.
%----------------------------------------------%

%%
clf, clc, hold on

T = [11 12 14 15 16 19 20  22  22]; % [celsius] temperature
t = [ 0  6 19 29 38 63 75 129 168]; % [min] time after start

T_error = ones(1,length(T))*0.5;

errorbar(t, T, T_error, 'ro', 'linewidth', 2)
plot(t,T, 'k--', 'linewidth', 1.5)
axis([min(t) max(t) min(T)*0.95, max(T)*1.03])
set(gca, 'FontSize', 14, 'ticklabelinterpreter', 'latex');
%title('Temperatur {\"o}ver tid', 'Interpreter', 'Latex', 'FontSize', 18)
xlabel('Tid [min]','Interpreter', 'Latex', 'FontSize', 16)
ylabel('Temperatur [$^{\circ}$C]', 'Interpreter', 'Latex', 'FontSize', 16)
legend('Uppm{\"a}tt temperatur', 'Hj{\"a}lplinje', 'Interpreter', 'Latex', 'FontSize', 14, 'Location', 'best')