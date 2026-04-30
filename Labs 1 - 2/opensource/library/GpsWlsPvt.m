function gpsPvt = GpsWlsPvt(gnssMeas,allGpsEph,bRaw)
%gpsPvt = GpsWlsPvt(gnssMeas,allGpsEph,bRaw)
%compute PVT from gnssMeas
% Input: gnssMeas, structure of pseudoranges, etc. from ProcessGnssMeas
%        allGpsEph, structure with all ephemeris
%        [bRaw], default true, true => use raw pr, false => use smoothed
%
% Output: 
% gpsPvt.FctSeconds    Nx1 time vector, same as gnssMeas.FctSeconds
%       .allLlaDegDegM Nx3 matrix, (i,:) = [lat (deg), lon (deg), alt (m)]
%       .sigmaLlaM     Nx3 standard deviation of [lat,lon,alt] (m)
%       .allBcMeters   Nx1 common bias computed with llaDegDegM
%       .allVelMps     Nx3 (i,:) = velocity in NED coords
%       .sigmaVelMps   Nx3 standard deviation of velocity (m/s)
%       .allBcDotMps   Nx1 common freq bias computed with velocity
%       .numSvs        Nx1 number of satellites used in corresponding llaDegDegM
%       .hdop          Nx1 hdop of corresponding fix
%
%Algorithm: Weighted Least Squares

%Author: Frank van Diggelen
%Open Source code for processing Android GNSS Measurements
%Modified: added HDOP threshold to invalidate low-quality epochs

if nargin<3
    bRaw = true;
else
    if any(~isfield(gnssMeas,{'PrSmM','PrSmSigmaM'}))
       error('If bRaw is false, gnssMeas must have fields gnssMeas.PrSmM and gnssMeas.PrSmSigmaM')
    end
end

% Maximum HDOP above which the solution is considered unreliable
HDOP_THRESHOLD = 10;

xo =zeros(8,1);

weekNum     = floor(gnssMeas.FctSeconds/GpsConstants.WEEKSEC);

N = length(gnssMeas.FctSeconds);
gpsPvt.FctSeconds      = gnssMeas.FctSeconds;
gpsPvt.allLlaDegDegM   = zeros(N,3)+NaN; 
gpsPvt.sigmaLLaM       = zeros(N,3)+NaN;
gpsPvt.allBcMeters     = zeros(N,1)+NaN;
gpsPvt.allVelMps       = zeros(N,3)+NaN;
gpsPvt.sigmaVelMps     = zeros(N,3)+NaN;
gpsPvt.allBcDotMps     = zeros(N,1)+NaN;
gpsPvt.numSvs          = zeros(N,1);
gpsPvt.hdop            = zeros(N,1)+inf;

for i=1:N
    iValid = find(isfinite(gnssMeas.PrM(i,:)));
    svid    = gnssMeas.Svid(iValid)';
    
    [gpsEph,iSv] = ClosestGpsEph(allGpsEph,svid,gnssMeas.FctSeconds(i));
    svid = svid(iSv);
    numSvs = length(svid);
    gpsPvt.numSvs(i) = numSvs;
    if numSvs<4
        continue;
    end
    
    %% WLS PVT
    prM     = gnssMeas.PrM(i,iValid(iSv))';
    prSigmaM= gnssMeas.PrSigmaM(i,iValid(iSv))';
    prrMps  = gnssMeas.PrrMps(i,iValid(iSv))';
    prrSigmaMps = gnssMeas.PrrSigmaMps(i,iValid(iSv))';
    tRx = [ones(numSvs,1)*weekNum(i),gnssMeas.tRxSeconds(i,iValid(iSv))'];
    prs = [tRx, svid, prM, prSigmaM, prrMps, prrSigmaMps];
    
    xo(5:7) = zeros(3,1);
    [xo,~,H,Wpr,Wrr] = WlsPvt(prs,gpsEph,xo);
    
    % Compute HDOP first, before storing results
    llaDegDegM = Xyz2Lla(xo(1:3)');
    RE2N = RotEcef2Ned(llaDegDegM(1),llaDegDegM(2));
    Hned = [H(:,1:3)*RE2N', ones(numSvs,1)];
    P = inv(Hned'*Hned);
    hdop = sqrt(P(1,1)+P(2,2));
    gpsPvt.hdop(i) = hdop;

    % Invalidate epoch if HDOP exceeds threshold
    if hdop > HDOP_THRESHOLD
        continue;
    end

    % Store results only for good-quality epochs
    gpsPvt.allLlaDegDegM(i,:) = llaDegDegM;
    gpsPvt.allBcMeters(i) = xo(4);
    
    vNed = RE2N*xo(5:7);
    gpsPvt.allVelMps(i,:) = vNed;
    gpsPvt.allBcDotMps(i) = xo(8);
    
    P = inv(Hned'*(Wpr'*Wpr)*Hned);
    gpsPvt.sigmaLLaM(i,:) = sqrt(diag(P(1:3,1:3)));
    
    P = inv(Hned'*(Wrr'*Wrr)*Hned);
    gpsPvt.sigmaVelMps(i,:) = sqrt(diag(P(1:3,1:3)));
end

end