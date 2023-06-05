%% [PROJECT] PRECISION MEASUREMENT OF SUNANGLE (PMAS) %%
%-----------------------------------------------------%%
%      Author: GOTTFRID OLSSON
%     Created: 2021-12-01, 18:19
%     Updated: 2022-03-05, 21:38
%       About: PMAS:
%              i) Plot protractor lines to lasercut
%                 a protractor
%%----------------------------------------------------%%

%% PLOT PROTRACTOR %%
clc, clf


% --- Constants --- %
tickFontSize = 13; textFontSize = 15;
distanceBetweenDegreeLines = 1.2; %[mm]
numberOfLines = 180; %180 = 1 deg sep, 180*10 = 0.1 deg sep
R = distanceBetweenDegreeLines*numberOfLines/pi;
R = 180/2;                  % [mm], radius of protractor
h_top = 8;                 % [mm], height on top of half-circle protractor
delta_th = 1;             % [deg], (delta) sub degrees on protractor
th_main  = 0:delta_th:180;  % [deg], main marked degrees on protractor
th_start = 180;             % [deg], starting angle for polarplot
num_r_values = 2;           % [-], # values in r (2 is ok for linear)
th_text = -90:10:90;        % [-], for rotation of text
th_t_a = 0:10:90; th_t_b = -80:10:0;
th_text_2 = [th_t_a abs(th_t_b)]; % text
text_d = 4;                 % [mm], distance from l_th_10 to text
R_cut_d = -0.1;              % [mm], distance from R to laser cutting R_cut

l_th_10  = 11;              % [mm], length of 10 deg lines
l_th_5   = 3;             % [mm], length of 5  deg lines (sort of)
l_th_1   = 4;             % [mm], length of 1 degree lines (sort of)
l_th_sub = 0;             % [mm], length of sub  degree lines (sort of)

d_hole_screw = 0;           % [mm], diameter hole for screw
d_hole_plumb = 5;           % [mm], diameter hole for plumb bob

x_hole_screw_center = (180-2*6)/2; %from drawing of lighttube
y_hole_screw_center = h_top - 4;   %from geometry + drawing of lighttube
x_hole_plumb_center = 0;
y_hole_plumb_center = 0;


% --- Functions --- %
deg2rad = @(deg) pi*(deg/180);
%'polarCircle(x_center, y_center, radius)', see below

% --- Calculate Variables --- %
TH = th_start + th_main;

% Create values for laser cutting 
R_cut_sc = R + R_cut_d;
TH_cut_sc = linspace(pi-atan(h_top/R_cut_sc),...
    2*pi+atan(h_top/R_cut_sc));
R_cut_sc = R_cut_sc*ones(1, length(TH_cut_sc));

TH_cut_top = linspace(0, pi);
R_cut_top = h_top./sin(TH_cut_top); % y = h_top = r*sin(theta)

% Convert cartesian circular eq. to polar
[TH_hole_screw1, R_hole_screw1] = polarCircle(x_hole_screw_center, ...
    y_hole_screw_center, d_hole_screw/2);
[TH_hole_screw2, R_hole_screw2] = polarCircle(-x_hole_screw_center, ...
    y_hole_screw_center, d_hole_screw/2);
[TH_hole_plumb, R_hole_plumb]   = polarCircle(x_hole_plumb_center, ...
    y_hole_plumb_center, d_hole_plumb/2);

% Degree lines for protractor
r_10  = R    - l_th_10;
r_5   = r_10 + l_th_5;
r_1   = r_5  + l_th_1;
r_sub = r_1  + l_th_sub;

R_10  = linspace(r_10,  R, num_r_values);
R_5   = linspace(r_5,   R, num_r_values);
R_1   = linspace(r_1,   R, num_r_values);
R_sub = linspace(r_sub, R, num_r_values);


% --- Plot --- %
j = 1;
for i=1:length(TH)
    TH_plot = deg2rad(TH(i))*ones(1, num_r_values);
    if mod(TH(i), 10) == 0       %every 10 deg
        R_plot = R_10;
    elseif mod(TH(i), 5) == 0    %every 5 deg
        R_plot = R_5;
    elseif floor(TH(i)) == TH(i) %every whole deg (before sub)
        R_plot = R_1;
    else
        R_plot = R_sub;          %if none of above, we have sub-degrees
    end
    
    polarplot(TH_plot, R_plot, 'r'); hold on;
    
    if mod(TH(i), 10) == 0
        text(deg2rad(TH(i)), r_10 - text_d, num2str(abs(th_text_2(j))),...
        'HorizontalAlignment', 'center', 'Interpreter', 'latex',...
        'FontSize', tickFontSize, 'Rotation', th_text(j))
        j = j + 1;
    end
end

% Lines to cut with lasercutter 
polarplot(TH_cut_sc, R_cut_sc, 'g') %semi-circular
polarplot(TH_cut_top, R_cut_top, 'g')
 %it wasn't possible to merge these into TH_cut and R_cut unfortunately...

% Holes for plump bob and screws into lighttube 
polarplot(TH_hole_screw1, R_hole_screw1, 'g')
polarplot(TH_hole_screw2, R_hole_screw2, 'g')
polarplot(TH_hole_plumb,  R_hole_plumb,  'g')

% Text for myself
text(deg2rad(180+90), R/3.5, 'Gottfrid Olsson $\,$ 2022-03-05',...
    'HorizontalAlignment', 'center', 'Interpreter', 'latex',...
        'FontSize', textFontSize, 'Rotation', 0)
text(deg2rad(180+90), R/6, 'PMAS version Gamma', ...
    'HorizontalAlignment', 'center', 'Interpreter', 'latex',...
    'FontSize', textFontSize, 'Rotation', 0)
    
% Plot Esthetics 
set(gca,'RTickLabel',[], 'ThetaTickLabel', [])
rlim([0 max(R_cut_sc)]); %thetalim([180 360]);
grid off

%% Create TH and R in polar coord. for circle with center in carteesian
function [TH_circle, R_circle] = polarCircle(x_center, y_center, radius)
    theta_circle = linspace(0, 2*pi+0.1);
    r_circle = radius; 
    [x_cicle, y_circle] = pol2cart(theta_circle, r_circle);
    [TH_circle, R_circle] = cart2pol(x_cicle+x_center, y_circle+y_center);
end
% EOF %