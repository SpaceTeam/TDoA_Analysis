function [latitude,longitude,alt,year,month,day,hour,minute,second,timestamp,num_data_points,tdoa] = sort_out_usable_data(num_reloggers,num_loras,latitude,longitude,alt,year,month,day,hour,minute,second,timestamp,maxlen,len, min_time)

max_points_per_second = 10;

%% just take times greater than minimum time
times = datetime(year,month,day,hour,minute,second);
indices_first_points = zeros(num_reloggers,num_loras);
new_len = zeros(num_reloggers,num_loras);
for lora=1:num_loras
    for relogger=1:num_reloggers
        for point=1:len(relogger,lora)
            if(times(point,relogger,lora) >= min_time)
                indices_first_points(relogger,lora) = point;
                new_len(relogger,lora) = len(relogger,lora)-indices_first_points(relogger,lora)+1;
                break;
            end
        end
    end
end
maxlen = max(max(new_len));

new_latitude = zeros(maxlen,num_reloggers,num_loras);
new_longitude = zeros(maxlen,num_reloggers,num_loras);
new_alt = zeros(maxlen,num_reloggers,num_loras);
new_year = zeros(maxlen,num_reloggers,num_loras);
new_month = zeros(maxlen,num_reloggers,num_loras);
new_day = zeros(maxlen,num_reloggers,num_loras);
new_hour = zeros(maxlen,num_reloggers,num_loras);
new_minute = zeros(maxlen,num_reloggers,num_loras);
new_second = zeros(maxlen,num_reloggers,num_loras);
new_timestamp = zeros(maxlen,num_reloggers,num_loras);

for lora=1:num_loras
    for relogger=1:num_reloggers
        new_latitude(1:new_len(relogger,lora),relogger,lora) = latitude(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_longitude(1:new_len(relogger,lora),relogger,lora) = longitude(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_alt(1:new_len(relogger,lora),relogger,lora) = alt(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_year(1:new_len(relogger,lora),relogger,lora) = year(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_month(1:new_len(relogger,lora),relogger,lora) = month(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_day(1:new_len(relogger,lora),relogger,lora) = day(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_hour(1:new_len(relogger,lora),relogger,lora) = hour(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_minute(1:new_len(relogger,lora),relogger,lora) = minute(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_second(1:new_len(relogger,lora),relogger,lora) = second(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
        new_timestamp(1:new_len(relogger,lora),relogger,lora) = timestamp(indices_first_points(relogger,lora):indices_first_points(relogger,lora)+new_len(relogger,lora)-1,relogger,lora);
    end
end
latitude = new_latitude;
longitude = new_longitude;
alt = new_alt;
year = new_year;
month = new_month;
day = new_day;
hour = new_hour;
minute = new_minute;
second = new_second;
timestamp = new_timestamp;
len = new_len;

%% find oldest and newest data point
times = datetime(year,month,day,hour,minute,second);
timeDurationSerial = datenum(max(max(max(times)))) - datenum(min(min(min(times(1,:)))));
second_start = int64(datenum(min(min(times(1,:))))*86400);
num_seconds = int64(timeDurationSerial*86400) + 1;

%% sort points to timetable
sorted_indices = zeros(num_loras,num_reloggers,num_seconds,max_points_per_second);
pointer_sorted_indices = ones(num_loras,num_reloggers,num_seconds);

for lora=1:num_loras
    for relogger=1:num_reloggers
        for point=1:len(relogger,lora)
            abs_second = int64(datenum(datetime(year(point,relogger,lora),month(point,relogger,lora),day(point,relogger,lora),hour(point,relogger,lora),minute(point,relogger,lora),second(point,relogger,lora)))*86400) - second_start + 1;
            sorted_indices(lora,relogger,abs_second,pointer_sorted_indices(lora,relogger,abs_second)) = point;
            pointer_sorted_indices(lora,relogger,abs_second) = pointer_sorted_indices(lora,relogger,abs_second)+1;
            if(pointer_sorted_indices(lora,relogger,abs_second)>max_points_per_second)
                pointer_sorted_indices(lora,relogger,abs_second) = max_points_per_second;
            end
        end
    end
end

%% take only points received by all receivers
num_data_points = zeros(1,num_loras);
indices_data_points = zeros(num_loras,num_reloggers,min(min(len)));
for lora=1:num_loras
    for abs_second=1:num_seconds
        for point1=1:pointer_sorted_indices(lora,1,abs_second)-1
            indices_data_points(lora,1,num_data_points(lora)+1) = sorted_indices(lora,1,abs_second,point1);
            num_reloggers_received = 1;
            for relogger2=2:num_reloggers
                for point2=1:pointer_sorted_indices(lora,relogger2,abs_second)-1
                    if(abs(timestamp(sorted_indices(lora,1,abs_second,point1),1,lora) - timestamp(sorted_indices(lora,relogger2,abs_second,point2),relogger2,lora)) < 1e-3)
                        if(sorted_indices(lora,relogger2,abs_second,point2)<1)
                            sorted_indices(lora,relogger2,abs_second,point2)=1;
                        end
                        indices_data_points(lora,relogger2,num_data_points(lora)+1) = sorted_indices(lora,relogger2,abs_second,point2);
                        num_reloggers_received = num_reloggers_received+1;
                    end
                end
            end
            if(num_reloggers_received >= num_reloggers)
                num_data_points(lora) = num_data_points(lora)+1;
            end
        end
    end
end


maxlen = max(num_data_points);
latitude_new = zeros(maxlen,num_reloggers,num_loras);
longitude_new = zeros(maxlen,num_reloggers,num_loras);
alt_new = zeros(maxlen,num_reloggers,num_loras);
year_new = zeros(maxlen,num_reloggers,num_loras);
month_new = zeros(maxlen,num_reloggers,num_loras);
day_new = zeros(maxlen,num_reloggers,num_loras);
hour_new = zeros(maxlen,num_reloggers,num_loras);
minute_new = zeros(maxlen,num_reloggers,num_loras);
second_new = zeros(maxlen,num_reloggers,num_loras);
timestamp_new = zeros(maxlen,num_reloggers,num_loras);

for lora=1:num_loras
    for relogger=1:num_reloggers
        for data_point = 1:num_data_points(lora)
            latitude_new(data_point,relogger,lora) = latitude(indices_data_points(lora,relogger,data_point),relogger,lora);
            longitude_new(data_point,relogger,lora) = longitude(indices_data_points(lora,relogger,data_point),relogger,lora);
            alt_new(data_point,relogger,lora) = alt(indices_data_points(lora,relogger,data_point),relogger,lora);
            year_new(data_point,relogger,lora) = year(indices_data_points(lora,relogger,data_point),relogger,lora);
            month_new(data_point,relogger,lora) = month(indices_data_points(lora,relogger,data_point),relogger,lora);
            day_new(data_point,relogger,lora) = day(indices_data_points(lora,relogger,data_point),relogger,lora);
            hour_new(data_point,relogger,lora) = hour(indices_data_points(lora,relogger,data_point),relogger,lora);
            minute_new(data_point,relogger,lora) = minute(indices_data_points(lora,relogger,data_point),relogger,lora);
            second_new(data_point,relogger,lora) = second(indices_data_points(lora,relogger,data_point),relogger,lora);
            timestamp_new(data_point,relogger,lora) = timestamp(indices_data_points(lora,relogger,data_point),relogger,lora);
        end
    end
end

latitude = latitude_new;
longitude = longitude_new;
alt = alt_new;
year = year_new;
month = month_new;
day = day_new;
hour = hour_new;
minute = minute_new;
second = second_new;
timestamp = timestamp_new;

tdoa = zeros(length(timestamp),num_reloggers,num_reloggers,num_loras);
for lora=1:num_loras
    for i=1:num_reloggers
        for j=1:num_reloggers
%             tdoa_raw = timestamp(:,i,lora)-timestamp(:,j,lora);
%                 outl_alt = isoutlier(alt_rocket(1:num_data_points(lora),lora),'movmedian',seconds(outlier_window_in_seconds),'SamplePoints',time(1:num_data_points(lora),lora));
%             tdoa(:,i,j,lora) = smoothdata(tdoa_raw,'gaussian',30);
            tdoa(:,i,j,lora) = timestamp(:,i,lora)-timestamp(:,j,lora);
        end
    end
end

end