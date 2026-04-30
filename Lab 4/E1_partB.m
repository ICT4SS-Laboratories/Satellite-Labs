clear all
clc

%% --- Part B: application on two Politecnico sites ---
% Approximate coordinates from open map sources; replace with your
% Google Earth centroid values if needed.
duca_lat_deg = 45.0627508;
duca_lon_deg = 7.6615427;

valentino_lat_deg = 45.0543575;
valentino_lon_deg = 7.6858188;

central_meridian_deg = 9; % UTM zone 32

[E_duca, N_duca] = geo2utm_hirvonen(duca_lat_deg, duca_lon_deg, central_meridian_deg);
[E_val, N_val] = geo2utm_hirvonen(valentino_lat_deg, valentino_lon_deg, central_meridian_deg);

cartographic_distance = hypot(E_val - E_duca, N_val - N_duca);

lat_mid_deg = (duca_lat_deg + valentino_lat_deg) / 2;
lon_mid_deg = (duca_lon_deg + valentino_lon_deg) / 2;
lon_prime_mid_deg = lon_mid_deg - central_meridian_deg;
m_mid = linear_deformation_modulus(lat_mid_deg, lon_prime_mid_deg);

real_distance = cartographic_distance / m_mid;
distance_difference = real_distance - cartographic_distance;

fprintf('\n=== EX 1 - Application on Politecnico sites ===\n');
fprintf('Duca site      -> E = %.3f m, N = %.3f m\n', E_duca, N_duca);
fprintf('Valentino site -> E = %.3f m, N = %.3f m\n', E_val, N_val);
fprintf('\nCartographic distance (Euclidean) = %.3f m\n', cartographic_distance);
fprintf('m_l at midpoint                   = %.9f\n', m_mid);
fprintf('Estimated real distance           = %.3f m\n', real_distance);
fprintf('Difference (real - cartographic)  = %.3f m\n\n', distance_difference);
