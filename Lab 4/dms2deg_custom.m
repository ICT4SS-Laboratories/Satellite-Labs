function deg = dms2deg_custom(d, m, s)
%DMS2DEG_CUSTOM Convert DMS to decimal degrees.

sgn = sign(d);
if sgn == 0
    sgn = 1;
end

deg = sgn * (abs(d) + m / 60 + s / 3600);
end
