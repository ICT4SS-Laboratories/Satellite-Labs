function [east, north] = geo2utm_hirvonen(lat_deg, lon_deg, central_meridian_deg)
%GEO2UTM_HIRVONEN Convert geodetic coordinates to UTM-like cartographic.
%   [E, N] = GEO2UTM_HIRVONEN(lat_deg, lon_deg, central_meridian_deg)
%   uses WGS84 and k0 = 0.9996 (UTM), consistent with Hirvonen workflow.

% WGS84 parameters
a = 6378137.0;
f = 1 / 298.257223563;
e2 = f * (2 - f);
ep2 = e2 / (1 - e2);
k0 = 0.9996;

% False East/North for UTM northern hemisphere
false_east = 500000.0;
false_north = 0.0;

phi = deg2rad(lat_deg);
lambda = deg2rad(lon_deg);
lambda0 = deg2rad(central_meridian_deg);

e4 = e2^2;
e6 = e2^3;

N = a ./ sqrt(1 - e2 .* (sin(phi) .^ 2));
T = tan(phi) .^ 2;
C = ep2 .* (cos(phi) .^ 2);
A = cos(phi) .* (lambda - lambda0);

M = a .* ( ...
    (1 - e2/4 - 3*e4/64 - 5*e6/256) .* phi ...
    - (3*e2/8 + 3*e4/32 + 45*e6/1024) .* sin(2*phi) ...
    + (15*e4/256 + 45*e6/1024) .* sin(4*phi) ...
    - (35*e6/3072) .* sin(6*phi));

east = false_east + k0 .* N .* ( ...
    A ...
    + (1 - T + C) .* (A .^ 3) ./ 6 ...
    + (5 - 18*T + T.^2 + 72*C - 58*ep2) .* (A .^ 5) ./ 120);

north = false_north + k0 .* ( ...
    M ...
    + N .* tan(phi) .* ( ...
        (A .^ 2) ./ 2 ...
        + (5 - T + 9*C + 4*C.^2) .* (A .^ 4) ./ 24 ...
        + (61 - 58*T + T.^2 + 600*C - 330*ep2) .* (A .^ 6) ./ 720));
end
