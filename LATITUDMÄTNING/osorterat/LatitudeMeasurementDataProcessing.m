%% SOLAR ANGLE alpha OVER TIME WITH HOME MADE ANGLE APPARATUS %%
%-------------------------------------------------------------%%
%      Author: GOTTFRID OLSSON
%     Created: 2021-08-24, 11:58
%     Updated: 2022-04-23, 17:53
%       About: Data processing of latitude measurements taken
%              with a homemade angle apparatus PMAS. 
%              Angle beta is Sun-PMAS-horizon and angle alpha, 
%              also known as solar angle, is alpha = 90deg-beta.
%               1. Find solar noon angle from measured alpha
%                  during the same day (Sun highest in the sky).
%               2. Plot noon-angle alpha over time (years).
%               3. Curve-fit a cosinus function.
%               4. Get latitude and earths axial tilt.
%               5. BE AMAZED! :D
%%------------------------------------------------------------%%
%%
clc, clf, clear all

% READ CSV-FILE %
addpath("D:\PROJEKT\ASTRONOMY\LATITUDMÄTNING");
lastUpdated   = "2022-05-23";
T             = readtable('latitudeMeasurements ['+lastUpdated+'].csv');
Date          = T.Date(1:end);
TimeOfDay     = T.TimeOfDay(1:end);
MeasuredAngle = T.MeasuredAngle(1:end);
Uncertainty   = T.Uncertainty(1:end);

showAlphaForEachDay = false; %True if you want to see

% CONSTANTS %
startDate = Date(1); endDate = Date(end);
allDays   = 0:DayOfYear2021(endDate);
startDay  = min(allDays); endDay = max(allDays);
extraDays = 10;
myActualLatitude = 57.68; %Google Maps
earthsAxialTilt = 23.44;
% https://nssdc.gsfc.nasa.gov/planetary/factsheet/earthfact.html

% 1. FIND NOON-ANGLE FOR EACH DAY %
uniqueDates = unique(Date);
uniqueDayOfYear = unique(DayOfYear2021(Date));
MeasurementOfDate = @(date) T(T.Date == date,:);
LatitudeOfDate = @(date) MeasurementOfDate(date).MeasuredAngle;
TimeOfDate = @(date) MeasurementOfDate(date).TimeOfDay;

% naive approach: take minimal angle (sun highest in sky) for each date
NumUniqueDates = numel(uniqueDates);
naiveNoonAngle = zeros(NumUniqueDates,1);
accMinIndexes  = zeros(NumUniqueDates,1);
minIndex       = zeros(NumUniqueDates,1);
diffMeasTheoryAngle = zeros(NumUniqueDates,1);

for index = 1:NumUniqueDates
    date_i = uniqueDates(index);
    [naiveNoonAngle(index), minIndex] = min(LatitudeOfDate(date_i));
    
    %This part is a mess, but it works - so don't touch it! //2021-08-24
    if index == 1
        accMinIndexes(index) = minIndex;
    else
        accMinIndexes(index) = minIndex + ...
            accMinIndexes(index)+ accMinIndexes(index-1);
        if index ~= NumUniqueDates
            %we need to add the number of measurements left on each day
            %to the NEXT accMinIndex, otherwise we skip elements in Table
            correction = numel(LatitudeOfDate(date_i)) - minIndex;
            accMinIndexes(index+1) = correction;
        end
    end
end

naiveNoonAngleTable = T(accMinIndexes,:);
% for a more sophisticated approach: do curvefit with cosine and min/max
if showAlphaForEachDay == true
    for index = 1:NumUniqueDates
       clf
       date_i = uniqueDates(index);
       timeArray  = TimeOfDate(date_i);
       alphaArray = LatitudeOfDate(date_i);
       NumTime = numel(timeArray);

       minutes = zeros(1,NumTime);
       alpha = zeros(1,NumTime);
       for k = 1:NumTime
           timeString_k = string(timeArray(k,1));
           minutes_k = getMinutesFromTimeString(timeString_k);
           minutes(k) = minutes_k;
           alpha_k = alphaArray(k,1);
           alpha(k) = alpha_k;
           plot(minutes_k, alpha_k, 'ro', 'LineWidth', 2); hold on;
           set(gca,'Ticklabelinterpreter','latex','Fontsize',14)
           title(string(date_i),...
                'Interpreter','latex','Fontsize',19)
           xlabel('Minute of day (12:00 = 720)',...
                'interpreter','latex','Fontsize',16)
           ylabel('Measured $\alpha$ (deg)',...
                'interpreter','latex','Fontsize',16)
       end
       naiveNoonAngle = min(alpha);
       naiveNoonAngleTime = minutes(alpha == naiveNoonAngle);
       plot(naiveNoonAngleTime, naiveNoonAngle, 'bs', 'MarkerSize', 10,...
           'LineWidth', 3)

       pause
       clc
       if index ~= NumUniqueDates
           fprintf('Press a key to move on (%d left)\n',NumUniqueDates-index)
       end
    end
end

% CALCULATED CORRECTION %
CorrectionOfDay = @(dayOfYear) -earthsAxialTilt*cos(2*pi*(dayOfYear+10)/365);

% 3. CURVE-FIT COSINUS %
day = uniqueDayOfYear;
alpha = naiveNoonAngle;
errorAlpha = naiveNoonAngleTable.Uncertainty; %2022-01-21
diffAngle = (alpha + CorrectionOfDay(day)) - myActualLatitude;

 %"actual" curve for myActualLatitude = 57.68
f_moreExact = @(day) myActualLatitude + earthsAxialTilt*cos(2*pi*(day+10)/365);
f = @(b, day) b(1) + b(2)*cos(b(3)*day+b(4)); %fitting function
b0 = [60, earthsAxialTilt, 2*pi/360, 0]; %initial guess 

opts = statset('maxIter', 1000, 'TolFun', 1e-6); %fit options
mdl = fitnlm(day, alpha, f, b0, 'Options', opts); %the fit
coeff = mdl.Coefficients.Estimate; %the fit coeff b

%%
% PLOT %
clc, clf, hold on;
h_1 = -1; h_2 = 366; h_3 = 2*h_2-1;
day1 = day(day>h_1 & day<h_2); day2 = day(day>h_2-1 & day<h_3);
alpha1 = alpha(day>h_1 & day<h_2); alpha2 = alpha(day>h_2-1 & day<h_3);
errorAlpha1 = errorAlpha(day>-1 & day<366);
errorAlpha2 = errorAlpha(day>h_2 & day<h_3);
allDaysAndExtra = [allDays, max(allDays)+1:1:max(allDays)+extraDays];

ymin = 30; ymax = 85; ytickstep = 2;
xmin = startDay; xmax = endDay + extraDays; 
xticksMonths = calcXticksMonthsUpToDate(startDate, endDate);
xTicks = xticksMonths; yTicks = ymin:ytickstep:ymax;

errorbar(day1, alpha1, errorAlpha1, 'rx', 'LineWidth',1.6,'MarkerSize',11);
errorbar(day2, alpha2, errorAlpha2, 'go', 'LineWidth',1.6,'MarkerSize',7);
plot(allDaysAndExtra ,f(coeff, allDaysAndExtra), 'b', 'LineWidth', 2)
fplot(@(day) f_moreExact(day),[0 endDay+extraDays],'k--','LineWidth',1.8);
set(gca,'Ticklabelinterpreter','latex','Fontsize',18)
titleCurve = sprintf('f(x) = %.2f + %.2f *$cos$(%.3fx + %.2f)',...
    coeff(1),coeff(2),coeff(3),coeff(4));
actualCurve = sprintf('g(x) = %.2f + %.2f *$cos$(%.3fx + %.2f)',...
    myActualLatitude,earthsAxialTilt,2*pi/365,2*pi*10/365);
title(['$\qquad\,\,$ Fitted curve: $'+string(titleCurve)+'$ ' ...
    'Theoretical curve: $'+string(actualCurve)+'$'],...
    'Interpreter','latex','Fontsize',22)
xlabel('Day $x$ from year 2021 (Jan1 = 0)',...
    'interpreter','latex','Fontsize',20)
ylabel('Measured angle $\alpha$ (deg)',...
    'interpreter','latex','Fontsize',20)
%legend(['Datapoints 2021',newline,'(naive noon angle)'], ...
%    ['Datapoints 2022',newline,'(naive noon angle)'],...
%    'Fitted curve $f(x)$','Theoretical curve',...
%    'Location','Best','Interpreter','latex','Fontsize',14)
legend('Datapoints 2021', 'Datapoints 2022',...
    'Fitted curve $f(x)$','Theoretical curve',...
    'Location','Best','Interpreter','latex','Fontsize',18)
axis([xmin xmax ymin ymax]) %[ ] do one graph with latutide [0 90]
grid on
xticks(xTicks)
yticks(yTicks)
%text(50, 50, "Datapoints 2021: " + length(alpha1) + newline + "Datapoints 2022: "+ length(alpha2))

% NOTE! f(x) = A + B*cos(C*x+D) means:
%   A: mean latitude (e.g. when no correction is needed)
%   B: should be ~23.5, Earths axial tilt (correction amplitude)
%   C: ~2*pi/360 = 0.016 since it compensates for each day (d)
%   D: ~2*pi*10/365 = 0.164 acc. to the model in How To Invent Everything
% Nice to see how it all makes sense! //2021-08-25, 15:04

%% FNCTIONS
function dayofyear2021 = DayOfYear2021(date)
    dayofyear2021 = datenum(date) - datenum('2021-01-01');
end
function totalMinutes  = getMinutesFromTimeString(timeString)
    % timeString in format 'hh:mm' [24h]
    % convert times of format 'hh:mm' to number of minutes
    getSubstring = @(string,i,n) extractBetween(string,i,n);
    hourString = getSubstring(timeString,1,2);
    minuteString = getSubstring(timeString,4,5);
    
    HourStringToDigitMinute = @(hourString) str2num(hourString)*60;
    MinuteStringToDigitMinute = @(minuteString) str2num(minuteString);
    
    hourMinutes = HourStringToDigitMinute(hourString);
    minutes = MinuteStringToDigitMinute(minuteString);
    
    totalMinutes = hourMinutes + minutes;
end
function xticksMonths = calcXticksMonthsUpToDate(startDate, endDate)
    startYear = year(startDate);
    endYear = year(endDate);
    endMonth = month(endDate);
    xticksMonths = [];

    %get months for all years up to year (endYear - 1)
    while startYear < endYear
        if isLeapYear(startYear)
            daysPerMonth = [31 29 31 30 31 30 31 31 30 31 30 31]; %leap year
        else
            daysPerMonth = [31 28 31 30 31 30 31 31 30 31 30 31]; %no leap year
        end
        xticksMonths = [xticksMonths, daysPerMonth];
        startYear = startYear + 1;
    end
    
    % is endYear a leap year?
    if isLeapYear(endYear)
        daysPerMonth = [31 29 31 30 31 30 31 31 30 31 30 31]; %leap year
    else
        daysPerMonth = [31 28 31 30 31 30 31 31 30 31 30 31]; %no leap year
    end
    
    if endMonth < 12
        for i = 1:endMonth+1
            xticksMonths = [xticksMonths, daysPerMonth(i)];
        end
    else %if endMonth is !< 12 it is == 12 , therefore next month is Jan
        xticksMonths = [xticksMonths, daysPerMonth(1)];
    end
    
    for i = 1:length(xticksMonths)
        if i == 1
            xticksMonths(i) = xticksMonths(1);
        else
            xticksMonths(i) = xticksMonths(i) + xticksMonths(i-1);
        end
    end
    xticksMonths = [0, xticksMonths];

end
function isLeapYear = isLeapYear(year)
    if mod(year, 400) == 0
        isLeapYear = true;
    end
    if mod(year, 100) == 0
        isLeapYear = false;
    end
    if mod(year, 4) == 0
        isLeapYear = true;
    else
        isLeapYear = false;
    end
end
% EOF %