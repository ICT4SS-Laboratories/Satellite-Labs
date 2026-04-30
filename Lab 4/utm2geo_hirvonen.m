function [lat_deg, lon_deg] = utm2geo_hirvonen(east, north, central_meridian_deg)
%UTM2GEO_HIRVONEN Convert UTM-like cartographic coordinates to geodetic.
%   [lat_deg, lon_deg] = UTM2GEO_HIRVONEN(E, N, central_meridian_deg)
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

x = east - false_east;
y = north - false_north;

e4 = e2^2;
e6 = e2^3;

M = y / k0;
mu = M / (a * (1 - e2/4 - 3*e4/64 - 5*e6/256));

e1 = (1 - sqrt(1 - e2)) / (1 + sqrt(1 - e2));

phi1 = mu ...
    + (3*e1/2 - 27*e1^3/32) .* sin(2*mu) ...
    + (21*e1^2/16 - 55*e1^4/32) .* sin(4*mu) ...
    + (151*e1^3/96) .* sin(6*mu) ...
    + (1097*e1^4/512) .* sin(8*mu);

C1 = ep2 .* cos(phi1).^2;
T1 = tan(phi1).^2;
N1 = a ./ sqrt(1 - e2 .* sin(phi1).^2);
R1 = a * (1 - e2) ./ ((1 - e2 .* sin(phi1).^2) .^ (3/2));
D = x ./ (N1 * k0);

lat = phi1 - (N1 .* tan(phi1) ./ R1) .* ( ...
    (D.^2) ./ 2 ...
    - (5 + 3*T1 + 10*C1 - 4*C1.^2 - 9*ep2) .* (D.^4) ./ 24 ...
    + (61 + 90*T1 + 298*C1 + 45*T1.^2 - 252*ep2 - 3*C1.^2) .* (D.^6) ./ 720);

lon = deg2rad(central_meridian_deg) + ( ...
    D ...
    - (1 + 2*T1 + C1) .* (D.^3) ./ 6 ...
    + (5 - 2*C1 + 28*T1 - 3*C1.^2 + 8*ep2 + 24*T1.^2) .* (D.^5) ./ 120) ./ cos(phi1);

lat_deg = rad2deg(lat);
lon_deg = rad2deg(lon);
end
