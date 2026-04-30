function [xHat,dRho,H,dx] = pvtCore(pseudoranges,svPos,svClockBias,xHat,Wpr)
%
% Inputs:
%       pseudoranges:   pseudorange vector, one for each sat
%       svPos:          3D satelite positions (ECEF, meters)
%       svClockBias:    satellite clock bias (seconds)
%       xHat:           linearization point [x; y; z; bc] (meters)
%       Wpr:            diagonal matrix of weights (1/sigma_pr)
%
% Outputs:
%       xHat:           updated solution (updated lin. point)
%       dRho:           residuals
%       H:              H matrix (geometry / observation matrix)
%       dx:             delta_x, i.e. update of lin. point

numSat = length(pseudoranges);

%--- Calculate line of sight vectors and ranges from satellite to xHat -------
% v(i,:) = vector from lin. point to satellite i
v = svPos - ones(numSat,1)*xHat(1:3)';   % numSat x 3

% Euclidean range from lin. point to each satellite
range = sqrt(sum(v.^2, 2));              % numSat x 1

% Unit line-of-sight vectors from lin. point to satellite
% (sign convention: pointing from receiver toward satellite)
v = v ./ (range * ones(1,3));            % numSat x 3

% H matrix: first 3 cols are the negative unit LOS vectors
% (pointing from satellite toward receiver), last col is +1 for clock bias
H = [-v, ones(numSat,1)];                % numSat x 4

%--- Calculate nominal measurements prHat ------------------------------------
% prHat = geometric range - c*dtsv + bc
%   dtsv > 0  =>  satellite clock ahead  => pr too small  => subtract c*dtsv
%   bc   > 0  =>  receiver clock ahead   => pr too large  => add bc
prHat = range - GpsConstants.LIGHTSPEED * svClockBias + xHat(4);  % numSat x 1

%--- Calculate range residual dRho -------------------------------------------
dRho = pseudoranges - prHat;             % numSat x 1

%--- Calculate pvt update dx using Weighted Least Squares --------------------
% Minimise ||Wpr*(dRho - H*dx)||^2  =>  dx = pinv(Wpr*H) * Wpr * dRho
dx = pinv(Wpr * H) * Wpr * dRho;        % 4 x 1

%--- Update linearization point xHat ----------------------------------------
xHat = xHat + dx;                        % 4 x 1

end % end of function pvtCore