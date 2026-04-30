%% EX 1 - Modulus of Linear Deformation
% Lab 4 - Cartography
% Satellite Systems for Positioning and Maps - 01VTEWY
%
% Part A:
%   Plot m_l for:
%   lat = [30, 37, 45, 60] deg
%   lon' = 0:0.5:3 deg
%
% Part B:
%   Application to Politecnico di Torino (Duca vs Valentino sites):
%   1) Cartographic coordinates (E, N)
%   2) Euclidean cartographic distance
%   3) Real distance using m_l at midpoint
%   4) Comparison

clc; clear; close all;
script_path = mfilename('fullpath');
if ~isempty(script_path)
    addpath(fileparts(script_path));
end

%% --- Part A: m_l curves ---
lat_cases_deg = [30, 37, 45, 60];
lon_prime_deg = 0:0.5:3;

figure('Color', 'w');
hold on;
grid on;
box on;

for i = 1:numel(lat_cases_deg)
    m_l = linear_deformation_modulus(lat_cases_deg(i), lon_prime_deg);
    plot(lon_prime_deg, m_l, '-o', 'LineWidth', 1.3, ...
        'DisplayName', sprintf('lat = %d^\\circ', lat_cases_deg(i)));
end

xlabel('$long^{\prime}\,[deg]$', 'Interpreter', 'latex');
 ylabel('$m_l$', 'Interpreter', 'latex');
 title('Linear deformation modulus $m_l = 0.9996\left(1 + \frac{\lambda^2}{2} \cos^2 \varphi \right)$', ...
       'Interpreter', 'latex');
 legend('Location', 'northwest');
 