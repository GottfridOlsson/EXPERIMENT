%% [PROJECT] CALCULATIONS FOR M.B.A.K.J.A.  %%
%-------------------------------------------%%
%      Author: GOTTFRID OLSSON
%     Created: 2021-10-07, 18:41
%     Updated: 2021-10-18, 22:15
%       About: Calculations and plot to be
%              exported as .svg and used w.
%              Inkscape to produce a file w.
%              right dimensions to laser cut.
%%------------------------------------------%%

%% MBAKJA: Mekanisk Berakning Av Kompensation for Jordens Axellutning
clc, clf

% CONSTANTS %

alpha = 23.44;              % axial tilt of the Earth, Jan 1 2021
days_constant = 10;         %[-], given by How To Invent Everything (p.272)
days_shift = 81.25;

r_min = 1;                  % min radius to plot
r_max = 25;                 % max radius to plot (only need 'alpha' many)
dr = 5;                     % steps between thicker lines
theta_cut = 23*(pi/180);    % angles (+- along x axis) to NOT plot r-lines
r_empty_start = 11;         % radius to NOT plot, start
r_empty_end = r_max;      % radius to NOT plot, end
n_plot_points = 200;        % # points to include in radius plot

d_kerf = 0.4;               %[mm], laser cutters width, measured 2021-10-07 
r_kerf = d_kerf/2;          %[mm]

day_to_rad = 2*pi/365;
deg_to_rad = 2*pi/360;       %[-], conversion factor degrees to radians
rad_to_deg = 1/deg_to_rad; 

% for dayticks
r_offset_alpha = 3;       % # dr steps
dday_ticks = 1;             % interval ticks in days
dday_ticks_bold = 5;        % interval bold       ticks of plotted ticks
dday_ticks_extra_bold = 10; % interval extra bold ticks of plotted ticks
num_dr = 2;                 % # points radially in ring (line between)
dr_r_ring = 2.5;            % # dr steps
dr_r_ring_bold = 0.6;       % # dr steps
dr_r_ring_extra_bold = 0.7; % # dr steps
dr_r_offset_dayDots = 0.37; % # dr steps
starting_day_of_month = [0 31 59 90 120 151 181 212 243 273 304 334];
theta_extra_for_dr = -2*pi/(120); % extra theta for dr (r = n*dr)

daysInYear = 0:1:365-1; %365 days in a year (0,1,2,...,364)
theta = linspace(0,2*pi);
degPerDay = 360/365;
radPerDay = degPerDay*deg_to_rad;


% FUNCTIONS %
correction = @(d) alpha*cos(day_to_rad*(d+days_constant+days_shift)); %[deg]
polar_radius = @(r) r;


% CALCULATIONS %
polar_correction_eval = abs(correction(daysInYear));


%polarplot(polar_correction_eval, 'r')
% PLOT % 
plotCorrection = true; %if false; plot the straight r-line


% PLOT R and CORRECTION CURVE %
plotCorrectionCurveAndRCurves = true;
if plotCorrectionCurveAndRCurves == true && plotCorrection == true
    for i=r_min:r_max
        polarplot(polar_correction_eval, 'r')%, 'LineWidth', 2); hold on;
        hold on;
        theta_pos_cut = linspace(theta_cut,pi-theta_cut,n_plot_points/2);
        theta_neg_cut = linspace(pi+theta_cut,2*pi-theta_cut,n_plot_points/2);
        theta_pos = linspace(0,pi,n_plot_points/2);
        theta_neg = linspace(pi,2*pi,n_plot_points/2);
        if not(mod(i,dr)==0)
            theta_extra = theta_extra_for_dr;
        else
            theta_extra = 0;
        end
        radii = polar_radius(i)*ones(n_plot_points/2);
        if (i >= r_empty_start) && (i <= r_empty_end)
            theta_1 = linspace(theta_cut-theta_extra,...
                pi-theta_cut+theta_extra,n_plot_points/2);
            theta_2 = linspace(pi+theta_cut-theta_extra,...
                2*pi-theta_cut+theta_extra,n_plot_points/2);
        else
            theta_1 = theta_pos;
            theta_2 = theta_neg;
        end

        polarplot(theta_1, radii, 'b')
        polarplot(theta_2, radii, 'b')
    end
end

% PLOT DAY TICK RING %
dayDotsOutside= false;  %true = dots outside ring, dalse = inside
plotDayticksRing = true;
if plotDayticksRing == true && plotCorrection == true
    day_dayticks = 0:dday_ticks:365-1;      %365 days in a year (!=366)
    theta_dayticks = -days_shift*day_to_rad+day_dayticks*day_to_rad;
    r_ring_start = alpha + r_offset_alpha;
    r_ring = linspace(r_ring_start+dr_r_ring_bold+dr_r_ring_extra_bold,...
        r_ring_start+dr_r_ring, num_dr);
    r_ring_bold = linspace(r_ring_start+dr_r_ring_extra_bold,...
        r_ring_start+dr_r_ring,num_dr);
    r_ring_extra_bold = linspace(r_ring_start, ...
        r_ring_start+dr_r_ring, num_dr);
    
    for i = 1:length(theta_dayticks)
        if and( not(mod(i-1, dday_ticks_bold)==0),...
                not(mod(i-1, dday_ticks_extra_bold)==0) )
            r = r_ring;
        elseif mod(i-1, dday_ticks_extra_bold)==0
            r = r_ring_extra_bold;
        else
            r = r_ring_bold;
        end
        
        hold on
        polarplot(theta_dayticks(i)*ones(1,num_dr), r, 'k')
        
        for k = 1:length(starting_day_of_month)
            if (i-1) == starting_day_of_month(k)
                if dayDotsOutside == true
                    polarplot(theta_dayticks(i),...
                        r(2)+dr_r_offset_dayDots, 'm.')
                else
                    polarplot(theta_dayticks(i),...
                        r(1)-dr_r_offset_dayDots, 'm.')
                    if i == 1
                    polarplot(theta_dayticks(i),...
                        r(1)-dr_r_offset_dayDots, 'm.')
                    end
                end
                    
            end
        end
        %disp(i-1)
        %pause
    end
end

% PLOT RINGS TO BE CUT %
big_green_ring_r = alpha+r_offset_alpha+dr_r_ring+2*dr_r_ring_bold;
small_green_ring_r = 2.8*big_green_ring_r/154;
 % Matlab 30.14 --> 154 Inkscape efter skalning
 %testar M3-skruv (medeldiameter 2.675 enl. verkstadshandboken men tar lite
 %bigger dimension 2.8) x = 2.8*(30.14/154) i Matlab som ger x --> 2.8 
 % i Inkscape efter skalning


% PLOT R-LINE %
if plotCorrection == false
   r_line = linspace(0, r_ring_start+dr_r_ring);
   theta_line = zeros(1, length(r_line));
   polarplot(theta_line, r_line, 'b')
   hold on
end

polarplot(theta, big_green_ring_r*ones(1, length(theta)), 'g')
polarplot(theta, small_green_ring_r*ones(1, length(theta)), 'g')
set(gca,'RTickLabel',[], 'ThetaTickLabel', [])
 %, 'ticklabelinterpreter', 'latex', 'FontSize', 12);
% dday_thetaticks = 5;
%theta_ticks = daysInYear*dday_thetaticks;
%theta_ticks = theta_ticks(theta_ticks < 365);
%theta_tick_labels = theta_ticks;
%thetaticks(theta_ticks)
%thetaticklabels(theta_tick_labels)
grid off



getDate = clock; year = getDate(1); month = getDate(2);
day = getDate(3); hour = getDate(4); minute  = getDate(5);
done = sprintf('Done at %d-%d-%d %dh %dmin', year,month,day,hour,minute);
disp(done)
% EOF