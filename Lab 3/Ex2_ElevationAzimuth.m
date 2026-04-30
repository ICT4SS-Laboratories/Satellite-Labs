%% EX 2 - Calculate Elevation and Azimuth of a satellite
% Lab 3 - Planning of GNSS Survey
% Satellite Systems for Positioning and Maps - 01VTEWY
%
% Given:
%   Satellite position in ECEF (m)
%   Station geodetic coordinates (lat, lon, h)
%
% Steps:
%   a) Convert lat/lon from degrees to radians
%   b) Calculate e^2 and W (WGS84 parameters)
%   c) Calculate station ECEF coordinates (Xi, Yi, Zi)
%   d) Calculate local ENU coordinates (e, n, u)
%   e) Estimate Azimuth and Elevation

clc; clear; close all;

%% --- Input Data ---

% Satellite ECEF position [m]
Xsat = 17485397.829;
Ysat =  6573222.932;
Zsat = 17921233.429;

% Station geodetic coordinates
lat_deg = 44 + 3/60 + 38.114/3600;   % Latitude  [degrees]
lon_deg = 7 + 39/60 + 20.605/3600;   % Longitude [degrees]
h = 0;                               % Ellipsoidal height [m]

%% --- Step a) Convert to radians ---
phi = deg2rad(lat_deg);   % geodetic latitude  [rad]
lam = deg2rad(lon_deg);   % geodetic longitude [rad]

fprintf('=== Step a) Geodetic coordinates (radians) ===\n');
fprintf('  phi (lat) = %.10f rad\n', phi);
fprintf('  lam (lon) = %.10f rad\n', lam);

%% --- Step b) WGS84 ellipsoid parameters, e^2 and W ---
a = 6378137.0;               % semi-major axis [m]
f = 1 / 298.257223563;       % flattening
e2 = 2*f - f^2;              % first eccentricity squared:  e^2 = 2f - f^2
W  = sqrt(1 - e2 * sin(phi)^2);  % auxiliary quantity

fprintf('\n=== Step b) WGS84 auxiliary parameters ===\n');
fprintf('  a   = %.4f m\n', a);
fprintf('  f   = 1/%.9f\n', 1/f);
fprintf('  e^2 = %.15f\n', e2);
fprintf('  W   = %.15f\n', W);

%% --- Step c) Station ECEF coordinates (Xi, Yi, Zi) ---
% Normal radius of curvature in the prime vertical
N = a / W;

Xi = (N + h) * cos(phi) * cos(lam);
Yi = (N + h) * cos(phi) * sin(lam);
Zi = (N * (1 - e2) + h) * sin(phi);

fprintf('\n=== Step c) Station ECEF coordinates ===\n');
fprintf('  Xi = %+.4f m\n', Xi);
fprintf('  Yi = %+.4f m\n', Yi);
fprintf('  Zi = %+.4f m\n', Zi);

%% --- Step d) Local ENU coordinates (e, n, u) ---
% Rotation matrix R (ECEF --> ENU), where phi=latitude, lam=longitude:
%
%        | -sin(lam)            cos(lam)           0       |
%  R  =  | -sin(phi)*cos(lam)  -sin(phi)*sin(lam)  cos(phi)|
%        |  cos(phi)*cos(lam)   cos(phi)*sin(lam)  sin(phi)|
%
%  [e; n; u] = R * [Xsat-Xi; Ysat-Yi; Zsat-Zi]

R = [ -sin(lam),              cos(lam),              0;
      -sin(phi)*cos(lam),    -sin(phi)*sin(lam),   cos(phi);
       cos(phi)*cos(lam),     cos(phi)*sin(lam),   sin(phi)];

dXYZ = [Xsat - Xi; Ysat - Yi; Zsat - Zi];

enu = R * dXYZ;
e_local = enu(1);
n_local = enu(2);
u_local = enu(3);

fprintf('\n=== Step d) Local ENU coordinates ===\n');
fprintf('  e (East)  = %+.4f m\n', e_local);
fprintf('  n (North) = %+.4f m\n', n_local);
fprintf('  u (Up)    = %+.4f m\n', u_local);

%% --- Step e) Azimuth and Elevation ---
% Elevation is the angle above the local horizontal plane:
%   Elevation = atan2(u, sqrt(n^2 + e^2))
%
% Azimuth is the angle measured clockwise from North:
%   Azimuth = atan2(e, n)   (gives [-pi, pi]; need to map to [0, 2*pi])

Elevation_rad = atan2(u_local, sqrt(n_local^2 + e_local^2));
Elevation_deg = rad2deg(Elevation_rad);

Azimuth_rad = atan2(e_local, n_local);
Azimuth_deg = rad2deg(Azimuth_rad);
if Azimuth_deg < 0
    Azimuth_deg = Azimuth_deg + 360;   % Map to [0, 360) deg
end

fprintf('\n=== Step e) Satellite Azimuth and Elevation ===\n');
fprintf('  Elevation = %.6f deg\n', Elevation_deg);
fprintf('  Azimuth   = %.6f deg\n', Azimuth_deg);

fprintf('\n--- Summary ---\n');
fprintf('  Station : lat=%.6f deg, lon=%.6f deg, h=%.1f m\n', ...
        lat_deg, lon_deg, h);
fprintf('  Station ECEF: [%.3f, %.3f, %.3f] m\n', Xi, Yi, Zi);
fprintf('  Satellite ECEF: [%.3f, %.3f, %.3f] m\n', Xsat, Ysat, Zsat);
fprintf('  Elevation = %.4f deg\n', Elevation_deg);
fprintf('  Azimuth   = %.4f deg\n', Azimuth_deg);
