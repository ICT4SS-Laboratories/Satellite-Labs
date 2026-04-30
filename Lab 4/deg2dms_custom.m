function [d, m, s] = deg2dms_custom(deg)
%DEG2DMS_CUSTOM Convert decimal degrees to DMS components.

d = fix(deg);
minutes_total = abs(deg - d) * 60;
m = fix(minutes_total);
s = (minutes_total - m) * 60;
end
