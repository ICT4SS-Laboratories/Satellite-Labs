%% EX 3 - DOP Estimation
% Lab 3 - Planning of GNSS Survey
% Satellite Systems for Positioning and Maps - 01VTEWY
%
% Given:
%   Receiver geodetic coordinates (lat, lon, h)
%   Satellite positions in ECEF (from pos_sat.txt)
%
% Steps:
%   a) Calculate receiver ECEF coordinates (Xi, Yi, Zi)
%   b) Calculate rho (geometric range) and D matrix (observation matrix)
%   c) Calculate R (ECEF to ENU rotation) and Qxx = (D'*D)^-1
%   d) Calculate Quu (in ENU frame) and estimate GDOP, PDOP, HDOP, VDOP

clc; clear; close all;

%% --- Input Data ---

% Receiver geodetic coordinates
lat_deg = 43 + 3/60  + 48/3600;   % Latitude  [degrees]
lon_deg =  7 + 28/60 + 41/3600;   % Longitude [degrees]
h = 0;                            % Ellipsoidal height [m]

% Satellite ECEF positions [m]  (from pos_sat.txt)
% Columns: [SV_ID, X, Y, Z]

sat_data = [
     1,  22504974.806,  13900127.123,  -2557240.727;
     2,  -3760396.280, -17947593.853,  19494169.070;
     4,   9355256.428, -12616043.006,  21189549.365;
     7,  23959436.524,   5078878.903, -10562274.680;
    10,  10228692.060, -19322124.315,  14550804.347;
    13,  23867142.480,  -3892848.382,  10941892.224;
    17,  21493427.163, -15051899.636,   3348924.156;
    20,  14198354.868,  13792955.212,  17579451.054;
    23,  18493109.722,   4172695.812,  18776775.463;
    31,  -8106932.299,  12484531.565,  22195338.169;
    32,   8363810.808,  21755378.568,  13378858.106;
];

SV_IDs  = sat_data(:, 1);
Xsat    = sat_data(:, 2);
Ysat    = sat_data(:, 3);
Zsat    = sat_data(:, 4);
numSats = size(sat_data, 1);

%% --- Step a) Receiver ECEF coordinates ---

phi = deg2rad(lat_deg);   % geodetic latitude  [rad]
lam = deg2rad(lon_deg);   % geodetic longitude [rad]

% WGS84 parameters
a  = 6378137.0;
f  = 1 / 298.257223563;
e2 = 2*f - f^2;
W  = sqrt(1 - e2 * sin(phi)^2);
N  = a / W;                    % radius of curvature in prime vertical

Xrec = (N + h) * cos(phi) * cos(lam);
Yrec = (N + h) * cos(phi) * sin(lam);
Zrec = (N * (1 - e2) + h) * sin(phi);

fprintf('=== Step a) Receiver ECEF coordinates ===\n');
fprintf('  lat = %.6f deg,  lon = %.6f deg,  h = %.1f m\n', lat_deg, lon_deg, h);
fprintf('  Xrec = %+.4f m\n', Xrec);
fprintf('  Yrec = %+.4f m\n', Yrec);
fprintf('  Zrec = %+.4f m\n', Zrec);

%% --- Step b) Geometric range rho and D matrix ---
%
% For each satellite i:
%   rho_i = sqrt((Xsat_i - Xrec)^2 + (Ysat_i - Yrec)^2 + (Zsat_i - Zrec)^2)
%
%   D row: [D1, D2, D3, -1]
%   D1 = (Xsat - Xrec) / rho
%   D2 = (Ysat - Yrec) / rho
%   D3 = (Zsat - Zrec) / rho
%   D4 = -1   (receiver clock unknown column)
%
% Note: sign convention – the slides use D4 = -1, which corresponds to
%       the linearised pseudorange model rho = r - c*dt_rec + ...
%       (clock bias appears with a -1 coefficient on the receiver side).

rho = zeros(numSats, 1);
D   = zeros(numSats, 4);

fprintf('\n=== Step b) Ranges and D matrix ===\n');
fprintf('  SV | rho [m]            | D1         D2         D3         D4\n');
fprintf('  ---+--------------------+--------------------------------------------\n');

for i = 1:numSats
    dX = Xsat(i) - Xrec;
    dY = Ysat(i) - Yrec;
    dZ = Zsat(i) - Zrec;
    rho(i) = sqrt(dX^2 + dY^2 + dZ^2);

    D(i, :) = [dX/rho(i),  dY/rho(i),  dZ/rho(i),  -1];

    fprintf('  %2d | %16.4f   | %+.6f  %+.6f  %+.6f  %+.1f\n', ...
            SV_IDs(i), rho(i), D(i,1), D(i,2), D(i,3), D(i,4));
end

%% --- Step c) Qxx matrix and ECEF-to-ENU rotation matrix R ---
%
% Co-factor matrix (unweighted, unit-weight observations):
%   Qxx = (D' * D)^(-1)   [4x4]
%
% ECEF-to-ENU rotation matrix (3x3) at the receiver position:
%
%        | -sin(lam)             cos(lam)            0       |
%  R  =  | -sin(phi)*cos(lam)   -sin(phi)*sin(lam)  cos(phi)|
%        |  cos(phi)*cos(lam)    cos(phi)*sin(lam)  sin(phi)|

Qxx = inv(D' * D);

R = [ -sin(lam),             cos(lam),             0;
      -sin(phi)*cos(lam),   -sin(phi)*sin(lam),   cos(phi);
       cos(phi)*cos(lam),    cos(phi)*sin(lam),   sin(phi)];

fprintf('\n=== Step c) Qxx matrix (4x4) ===\n');
disp(Qxx);

fprintf('ECEF-to-ENU rotation matrix R (3x3):\n');
disp(R);

%% --- Step d) Quu matrix and DOP values ---
%
% Extract the 3x3 position sub-matrix of Qxx (drop the clock column/row):
%   Q*xx = Qxx(1:3, 1:3)
%
% Rotate to local ENU frame:
%   Q*uu = R * Q*xx * R'   [3x3, diagonal = [East^2, North^2, Up^2]]
%
% DOP definitions:
%   GDOP = sqrt( Qxx(1,1)+Qxx(2,2)+Qxx(3,3)+Qxx(4,4) )  -- includes clock
%   PDOP = sqrt( Q*uu(1,1)+Q*uu(2,2)+Q*uu(3,3) )         -- 3D position
%   HDOP = sqrt( Q*uu(1,1)+Q*uu(2,2) )                   -- horizontal (E,N)
%   VDOP = sqrt( Q*uu(3,3) )                              -- vertical (U)

Qxx_pos = Qxx(1:3, 1:3);           % 3x3 position sub-matrix
Quu     = R * Qxx_pos * R';        % ENU co-factor matrix

GDOP = sqrt(Qxx(1,1) + Qxx(2,2) + Qxx(3,3) + Qxx(4,4));
PDOP = sqrt(Quu(1,1) + Quu(2,2) + Quu(3,3));
HDOP = sqrt(Quu(1,1) + Quu(2,2));
VDOP = sqrt(Quu(3,3));

fprintf('\n=== Step d) DOP values ===\n');
fprintf('  Quu matrix (3x3, ENU frame):\n');
disp(Quu);
fprintf('  GDOP = %.4f\n', GDOP);
fprintf('  PDOP = %.4f\n', PDOP);
fprintf('  HDOP = %.4f\n', HDOP);
fprintf('  VDOP = %.4f\n', VDOP);

%% --- Summary table ---
fprintf('\n--- Summary ---\n');
fprintf('  Receiver: lat=%.6f deg, lon=%.6f deg, h=%.1f m\n', lat_deg, lon_deg, h);
fprintf('  Number of satellites used: %d\n', numSats);
fprintf('  %-6s  %-8s\n', 'Index', 'DOP');
fprintf('  %-6s  %-8.4f\n', 'GDOP', GDOP);
fprintf('  %-6s  %-8.4f\n', 'PDOP', PDOP);
fprintf('  %-6s  %-8.4f\n', 'HDOP', HDOP);
fprintf('  %-6s  %-8.4f\n', 'VDOP', VDOP);
