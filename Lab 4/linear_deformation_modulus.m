function m = linear_deformation_modulus(lat_deg, lon_prime_deg)
%LINEAR_DEFORMATION_MODULUS UTM linear deformation modulus approximation.
%   m = k0 * (1 + 0.5 * (lambda')^2 * cos(phi)^2)
%   with:
%     - phi in radians (latitude)
%     - lambda' in radians (longitude from central meridian)
%     - k0 = 0.9996

k0 = 0.9996;
phi = deg2rad(lat_deg);
lambda_prime = deg2rad(lon_prime_deg);

m = k0 .* (1 + 0.5 .* (lambda_prime .^ 2) .* (cos(phi) .^ 2));
end
