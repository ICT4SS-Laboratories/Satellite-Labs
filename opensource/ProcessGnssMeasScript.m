%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%               ProcessGnssMeasScript.m,         %%%%%%%%%%%%%%%%
%%%%%%%%%%% script to read GnssLogger output, compute and plot: %%%%%%%%%%%
%%%%%%%% pseudoranges, C/No, and weighted least squares PVT solution  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author: Frank van Diggelen
% Open Source code for processing Android GNSS Measurements
% Modified by Alex Minetto, Simone Zocca, and Andrea Nardin
% Dept. of Electronics and Telecommunications
% Politecnico di Torino

% NOTE: Compatible with GNSSLogger App v2.0.0.1
% WARNING: CodeType breaks the code for logs retrieved by GNSSLogger App
% v3.0.0.1

% you can run the data in pseudoranges log files collected through your device by:
% 1) changing 'dirName = ...' to match the local directory you are using:
% 3) running ProcessGnssMeasScript.m script file (this script)
clc, close all, clear all
% include library functions (utilities and functions)
addpath('library')

%% input data (GNSS logger)
% To add your own data:
% save data from GnssLogger App, and edit dirName and prFileName appropriately
prFileName    = 'gnss_log_2026_03_16_13_27_35.txt';
dirName       = 'files/';

%% true position
% param.llaTrueDegDegM = [];
%enter true WGS84 lla, if you know it:
param.llaTrueDegDegM = [
    45 + 3/60 + 55.6036/3600, ...
    7 + 39/60 + 30.3144/3600, ...
    250
    ];  % Rooms I area

%% Set the data filter and Read log file
dataFilter = SetDataFilter;
[gnssRaw,gnssAnalysis] = ReadGnssLogger(dirName,prFileName,dataFilter);
if isempty(gnssRaw), return, end

%% Get online ephemeris from Nasa CCDIS service, first compute UTC Time from gnssRaw:
fctSeconds = 1e-3*double(gnssRaw.allRxMillis(end));
utcTime = Gps2Utc([],fctSeconds);
%allGpsEph = GetNasaHourlyEphemeris(utcTime,dirName);
%if isempty(allGpsEph), return, end

%% process raw measurements, compute pseudoranges:
[gnssMeas] = ProcessGnssMeas(gnssRaw);

%% Satellite availability per epoch
min_satellites = 4;
availability = SatelliteAvailability(gnssMeas, min_satellites);
fprintf('Percentage of time with >= %d satellites: %.2f%%\n', ...
        min_satellites, availability);

%% plot pseudoranges and pseudorange rates
h1 = figure;
[colors] = PlotPseudoranges(gnssMeas,prFileName);
h2 = figure;
PlotPseudorangeRates(gnssMeas,prFileName,colors);
h3 = figure;
PlotCno(gnssMeas,prFileName,colors);

%% compute WLS position and velocity
% gpsPvt = GpsWlsPvt(gnssMeas,allGpsEph);
gpsPvt = [];

if ~isempty(gpsPvt)
    %% plot PVT results
    h4 = figure;
    ts = 'Raw Pseudoranges, Weighted Least Squares solution';
    PlotPvt(gpsPvt,prFileName,param.llaTrueDegDegM,ts); drawnow;
    h5 = figure;
    PlotPvtStates(gpsPvt,prFileName);


    %% plot PVT on geoplot
    h8 = figure('Name','[Optional] Plot Positioning Solution on Map');
    geoplot(gpsPvt.allLlaDegDegM(:,1),gpsPvt.allLlaDegDegM(:,2)), hold on

    % animated geoplot
    for epochIdx = 1:size(gpsPvt.allLlaDegDegM,1)
        figure(h8)
        geoplot(gpsPvt.allLlaDegDegM(epochIdx,1),gpsPvt.allLlaDegDegM(epochIdx,2),'ro','MarkerSize',4,'MarkerFaceColor','r')
        drawnow
        pause(0.01)
    end
end

%% end of ProcessGnssMeasScript
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2016 Google Inc.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
