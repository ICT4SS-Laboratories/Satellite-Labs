%% EX 2 - Hirvonen Equation (Geographic -> Cartographic)
% Lab 4 - Cartography
% Satellite Systems for Positioning and Maps - 01VTEWY
%
% Convert:
% P1: lat = 45° 3' 45.717'', lon = 7° 47' 26.292''
%     WGS84 - UTM zone 32, central meridian 9°
%
% P2: lat = 38° 32' 34.649'', lon = 16° 50' 06.493''
%     WGS84 - UTM zone 33, central meridian 15°

clc; clear; close all;
script_path = mfilename('fullpath');
if ~isempty(script_path)
    addpath(fileparts(script_path));
end

%% --- Input points ---
P(1).name = 'P1';
P(1).lat_deg = dms2deg_custom(45, 3, 45.717);
P(1).lon_deg = dms2deg_custom(7, 47, 26.292);
P(1).zone = 32;
P(1).lambda0_deg = 9;

P(2).name = 'P2';
P(2).lat_deg = dms2deg_custom(38, 32, 34.649);
P(2).lon_deg = dms2deg_custom(16, 50, 6.493);
P(2).zone = 33;
P(2).lambda0_deg = 15;

%% --- Conversion ---
fprintf('\n=== EX 2 - Hirvonen forward conversion ===\n');
fprintf('%-3s | %-12s | %-12s | %-10s | %-12s | %-12s\n', ...
    'Pt', 'Lat [deg]', 'Lon [deg]', 'UTM zone', 'East [m]', 'North [m]');
fprintf('----+--------------+--------------+------------+--------------+--------------\n');

for i = 1:numel(P)
    [east, north] = geo2utm_hirvonen(P(i).lat_deg, P(i).lon_deg, P(i).lambda0_deg);
    P(i).east = east;
    P(i).north = north;

    fprintf('%-3s | %12.8f | %12.8f | %10d | %12.3f | %12.3f\n', ...
        P(i).name, P(i).lat_deg, P(i).lon_deg, P(i).zone, P(i).east, P(i).north);
end

fprintf('\n')
