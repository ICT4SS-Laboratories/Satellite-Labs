%% EX 3 - Hirvonen Equation (Cartographic -> Geographic)
% Lab 4 - Cartography
% Satellite Systems for Positioning and Maps - 01VTEWY
%
% Given:
%   East  = 470139.66 m
%   North = 5031468.37 m
%   WGS84 - UTM zone 32 (central meridian 9°)
%
% Reference value in slides:
%   Lon = 8° 37' 5.6209''
%   Lat = 45° 26' 9.9617''

clc; clear; close all;
script_path = mfilename('fullpath');
if ~isempty(script_path)
    addpath(fileparts(script_path));
end

%% --- Input ---
east = 470139.66;
north = 5031468.37;
central_meridian_deg = 9;

%% --- Inverse conversion ---
[lat_deg, lon_deg] = utm2geo_hirvonen(east, north, central_meridian_deg);
[lat_d, lat_m, lat_s] = deg2dms_custom(lat_deg);
[lon_d, lon_m, lon_s] = deg2dms_custom(lon_deg);

fprintf('\n=== EX 3 - Hirvonen inverse conversion ===\n');
fprintf('Input cartographic coordinates:\n');
fprintf('  East  = %.3f m\n', east);
fprintf('  North = %.3f m\n', north);
fprintf('\nEstimated geographic coordinates:\n');
fprintf('  Latitude  = %.10f deg  -> %d° %d'' %.4f''''\n', lat_deg, lat_d, lat_m, lat_s);
fprintf('  Longitude = %.10f deg  -> %d° %d'' %.4f''''\n', lon_deg, lon_d, lon_m, lon_s);

%% --- Comparison with slide reference ---
lat_ref_deg = dms2deg_custom(45, 26, 9.9617);
lon_ref_deg = dms2deg_custom(8, 37, 5.6209);

lat_err_arcsec = lat_deg - lat_ref_deg;
lon_err_arcsec = lon_deg - lon_ref_deg;

fprintf('\nReference from slides:\n');
fprintf('  Latitude  = %.10f deg\n', lat_ref_deg);
fprintf('  Longitude = %.10f deg\n', lon_ref_deg);
fprintf('\nResiduals (estimated - reference):\n');
fprintf('  dLat = %g deg\n', lat_err_arcsec);
fprintf('  dLon = %g deg\n\n', lon_err_arcsec);
