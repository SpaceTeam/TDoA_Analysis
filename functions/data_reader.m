fileID = fopen('LORA2.txt');
A = fread(fileID);
latitude = [];
longitude = [];
alt = [];
year = [];
month = [];
day = [];
hour = [];
minute = [];
second = [];
CountsSincePPS = [];
CountsPerSecond = [];

for i=6:length(A)
    if(A(i-5)=='d' && A(i-4)=='a' && A(i-3)=='t' && A(i-2)=='a' && A(i-1)==':')
        latitude = [latitude typecast(uint8([A(i) A(i+1) A(i+2) A(i+3)]),'int32')];
        longitude = [longitude typecast(uint8([A(i+4) A(i+5) A(i+6) A(i+7)]),'int32')];
        alt = [alt typecast(uint8([A(i+8) A(i+9)]),'int16')];
        year = [year A(i+10)];
        month = [month A(i+11)];
        day = [day A(i+12)];
        hour = [hour A(i+13)];
        minute = [minute A(i+14)];
        second = [second A(i+15)];
        CountsSincePPS = [CountsSincePPS typecast(uint8([A(i+16) A(i+17) A(i+18) A(i+19)]),'uint32')];
        CountsPerSecond = [CountsPerSecond typecast(uint8([A(i+20) A(i+21) A(i+22) A(i+23)]),'uint32')];
    end
end