function [latitude,longitude,alt] = calc_pos_wikipedia(lat_rec,lon_rec,alt_rec,t,num_reloggers,tdoa)

r_equ = 6378137;
r_pol = 6356752;
r_earth = sqrt( ( (r_equ^2*cos(lat_rec/180*pi)).^2 + (r_pol^2*sin(lat_rec/180*pi)).^2 ) / ( (r_equ*cos(lat_rec/180*pi)).^2 + (r_pol*sin(lat_rec/180*pi)).^2 ) );
r = r_earth*ones(1,num_reloggers) + alt_rec; %6371000
x = r.*cos(lat_rec/180*pi).*cos(lon_rec/180*pi);
y = r.*cos(lat_rec/180*pi).*sin(lon_rec/180*pi);
z = r.*sin(lat_rec/180*pi);

c = 299792458;

A = zeros(num_reloggers-2,1);
B = A;
C = A;
D = A;

for m=3:num_reloggers
    A(m-2) = 2*(x(m)-x(1)) / (c*(t(m)-t(1))) - 2*(x(2)-x(1)) / (c*(t(2)-t(1)));
    B(m-2) = 2*(y(m)-y(1)) / (c*(t(m)-t(1))) - 2*(y(2)-y(1)) / (c*(t(2)-t(1)));
    C(m-2) = 2*(z(m)-z(1)) / (c*(t(m)-t(1))) - 2*(z(2)-z(1)) / (c*(t(2)-t(1)));
    D(m-2) = c*(t(m)-t(1)) - c*(t(2)-t(1)) - ((x(m)-x(1))^2 + (y(m)-y(1))^2 + (z(m)-z(1))^2) / (c*(t(m)-t(1))) + ((x(2)-x(1))^2 + (y(2)-y(1))^2 + (z(2)-z(1))^2) / (c*(t(2)-t(1)));
end

M = [A B C];
X = M \ -D + [x(1); y(1); z(1)];

x = X(1);
y = X(2);
z = X(3);

r = sqrt(x^2 + y^2 + z^2);
alt = r - r_earth;
longitude = atan2(y, x) * 360 / (2*pi);
latitude = asin(z/r) * 360 / (2*pi);

end
