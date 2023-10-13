function [latitude,longitude,alt] = calc_pos(lat_rec,lon_rec,alt_rec,t,num_reloggers,tdoa)

r_equ = 6378137;
r_pol = 6356752;
r_earth = sqrt( ( (r_equ^2*cos(lat_rec/180*pi)).^2 + (r_pol^2*sin(lat_rec/180*pi)).^2 ) / ( (r_equ*cos(lat_rec/180*pi)).^2 + (r_pol*sin(lat_rec/180*pi)).^2 ) );
r = r_earth*ones(1,num_reloggers) + alt_rec; %6371000
x = r.*cos(lat_rec/180*pi).*cos(lon_rec/180*pi);
y = r.*cos(lat_rec/180*pi).*sin(lon_rec/180*pi);
z = r.*sin(lat_rec/180*pi);

xref = x(1);
yref = y(1);
zref = z(1);
for i=1:num_reloggers
    x(i) = x(i)-xref;
    y(i) = y(i)-yref;
    z(i) = z(i)-zref;
end

c = 299792458;

a1 = tdoa(1,2)*(x(3)-x(1))-tdoa(1,3)*(x(2)-x(1));
b1 = tdoa(1,2)*(y(3)-y(1))-tdoa(1,3)*(y(2)-y(1));
c1 = tdoa(1,2)*(z(3)-z(1))-tdoa(1,3)*(z(2)-z(1));
beta31 = x(3)^2+y(3)^2+z(3)^2-(x(1)^2+y(1)^2+z(1)^2);
beta21 = x(2)^2+y(2)^2+z(2)^2-(x(1)^2+y(1)^2+z(1)^2);
g1 = 1/2*( c^2*tdoa(1,2)*tdoa(1,3)*tdoa(3,2)+tdoa(1,2)*beta31-tdoa(1,3)*beta21 );

a2 = tdoa(1,2)*(x(4)-x(1))-tdoa(1,4)*(x(2)-x(1));
b2 = tdoa(1,2)*(y(4)-y(1))-tdoa(1,4)*(y(2)-y(1));
c2 = tdoa(1,2)*(z(4)-z(1))-tdoa(1,4)*(z(2)-z(1));
beta41 = x(4)^2+y(4)^2+z(4)^2-(x(1)^2+y(1)^2+z(1)^2);
g2 = 1/2*(c^2*tdoa(1,2)*tdoa(1,4)*tdoa(4,2)+tdoa(1,2)*beta41-tdoa(1,4)*beta21);

n1 = (b1*c2-b2*c1)/(a1*b2-a2*b1);
n2 = (b2*g1-b1*g2)/(a1*b2-a2*b1);

eps1 = (a2*c1-a1*c2)/(a1*b2-a2*b1);
eps2 = (a1*g2-a2*g1)/(a1*b2-a2*b1);

p1 = 1/(c*tdoa(1,2)) * ((x(2)-x(1))*n1+(y(2)-y(1))*eps1+(z(2)-z(1)));
p2 = c*tdoa(1,2)/2 + 1/(2*c*tdoa(1,2)) * (2*((x(2)-x(1))*n2+(y(2)-y(1))*eps2)-beta21);

h1 = n1^2+eps1^2-p1^2+1;
h2 = 2*(n1*(n2-x(1))+eps1*(eps2-y(1))-z(1)-p1*p2);
h3 = (n2-x(1))^2+(eps2-y(1))^2+z(1)^2-p2^2;

z = zeros(1,2);
z(1) = -h2/(2*h1)+sqrt((h2/(2*h1))^2-h3/h1);
z(2) = -h2/(2*h1)-sqrt((h2/(2*h1))^2-h3/h1);
x = n1*z+[n2 n2];
y = eps1*z+[eps2 eps2];

x = real(x) + [xref xref];
y = real(y) + [yref yref];
z = real(z) + [zref zref];

r = sqrt(x.^2 + y.^2 + z.^2);
alt = r - [r_earth r_earth];
longitude = atan2(y, x) * 360 / (2*pi);
latitude = asin(z ./ r) * 360 / (2*pi);

solution = 1;

alt = alt(solution);
longitude = longitude(solution);
latitude = latitude(solution);

end
