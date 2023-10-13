function [latitude,longitude,altitude,year,month,day,hour,minute,second,CountsSincePPS,CountsPerSecond,timestamp,len] = read_file(filepath)

fileID = fopen(filepath);
A = fread(fileID);

len = 0;
for i=6:length(A)-24
    if(A(i-5)=='d' && A(i-4)=='a' && A(i-3)=='t' && A(i-2)=='a' && A(i-1)==':')
        year = A(i+10);
        latitude = double(typecast(uint8([A(i) A(i+1) A(i+2) A(i+3)]),'int32'))/1e7;
        CountsSincePPS = double(typecast(uint8([A(i+16) A(i+17) A(i+18) A(i+19)]),'uint32'));
        CountsPerSecond = double(typecast(uint8([A(i+20) A(i+21) A(i+22) A(i+23)]),'uint32'));
        timestamp = CountsSincePPS/CountsPerSecond;
        if(latitude~=0 && year~=0 && timestamp < 0.97) %only take data if valid gps fix
            len = len+1;
        end
    end
end

latitude = zeros(len,1);
longitude = zeros(len,1);
altitude = zeros(len,1);
year = zeros(len,1);
month = zeros(len,1);
day = zeros(len,1);
hour = zeros(len,1);
minute = zeros(len,1);
second = zeros(len,1);
CountsSincePPS = zeros(len,1);
CountsPerSecond = zeros(len,1);
timestamp = zeros(len,1);

cnt = 1;
for i=6:length(A)-24
    if(A(i-5)=='d' && A(i-4)=='a' && A(i-3)=='t' && A(i-2)=='a' && A(i-1)==':')
        if(cnt<=len)
            latitude(cnt) = double(typecast(uint8([A(i) A(i+1) A(i+2) A(i+3)]),'int32'))/1e7;
            longitude(cnt) = double(typecast(uint8([A(i+4) A(i+5) A(i+6) A(i+7)]),'int32'))/1e7;
            altitude(cnt) = typecast(uint8([A(i+8) A(i+9)]),'int16');
            year(cnt) = A(i+10);
            month(cnt) = A(i+11);
            day(cnt) = A(i+12);
            hour(cnt) = A(i+13);
            minute(cnt) = A(i+14);
            second(cnt) = A(i+15);
            CountsSincePPS(cnt) = double(typecast(uint8([A(i+16) A(i+17) A(i+18) A(i+19)]),'uint32'));
            CountsPerSecond(cnt) = double(typecast(uint8([A(i+20) A(i+21) A(i+22) A(i+23)]),'uint32'));
            timestamp(cnt) = CountsSincePPS(cnt)/CountsPerSecond(cnt);
            
            if(latitude(cnt)~=0 && year(cnt)~=0 && timestamp(cnt) < 0.97) %only take data if valid gps fix
                cnt = cnt+1;
            end
        end
    end
end

fclose(fileID);

end

