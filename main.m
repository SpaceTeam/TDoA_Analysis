addpath('functions'); % add folder with used functions
filepath = 'tdoa_data\'; % path to tdoa raw data

%% parameters
N_smooth = 40; % window size for Gaussian-weighted moving average
min_time = datetime(2022,9,25,0,0,0); % only points newer than this time value are considered (ignore older flights)

%% constants
num_receivers = 4; % number of used receivers (so far only 4 receivers are considered for tdoa calculations)
num_loras = 2; % number of lora modules per receiver

%% read data
[latitude,longitude,altitude,year,month,day,hour,minute,second,CountsSincePPS,CountsPerSecond,timestamp,maxlen,len] = read_files(filepath,num_receivers,num_loras);
year = 2000 + year;

%% sort out useful data
[latitude,longitude,altitude,year,month,day,hour,minute,second,timestamp,num_data_points,tdoa] = sort_out_usable_data(num_receivers,num_loras,latitude,longitude,altitude,year,month,day,hour,minute,second,timestamp,maxlen,len, min_time);
time = datetime(year,month,day,hour,minute,second,timestamp*1e3);
time = reshape(time(:,1,:),[length(year),num_loras]);

%% smooth raw tdoas
for lora=1:num_loras
    % find outliers
    outl = zeros(num_data_points(lora),1);
    for i=1:num_receivers
        for j=1:num_receivers
            outl = bitor(outl, isoutlier(tdoa(1:num_data_points(lora),i,j,lora),'mean'));
        end
    end
    % smooth tdoas
    for i=1:num_receivers
        for j=1:num_receivers
            tdoa_smoothed = smoothdata(tdoa(not(outl),i,j,lora),'gaussian',N_smooth);
            tdoa(1:length(tdoa_smoothed),i,j,lora) = tdoa_smoothed;
        end
    end
    num_data_points(lora) = length(tdoa_smoothed);
end

%% calc positions
latitude_rocket = zeros(max(num_data_points),num_loras);
longitude_rocket = zeros(max(num_data_points),num_loras);
alt_rocket = zeros(max(num_data_points),num_loras);
for lora=1:num_loras
    for i=1:num_data_points(lora)
        [latitude_rocket(i,lora),longitude_rocket(i,lora),alt_rocket(i,lora)] = calc_pos(latitude(i,:,lora),longitude(i,:,lora),altitude(i,:,lora),timestamp(i,:,lora),num_receivers,reshape(tdoa(i,:,:,lora),[num_receivers num_receivers]));
    end
end

%% export kml data, can be converted to gpx for example with GPSBabel
for lora=1:num_loras
    kmlwrite(['export\kml_lora' num2str(lora) '.kml'],latitude_rocket(:,lora),longitude_rocket(:,lora),alt_rocket(:,lora));
end

%% plot altitude
for lora=1:num_loras
    figure;
    plot(time(1:num_data_points(lora),lora),alt_rocket(1:num_data_points(lora),lora)/1e3);
    xlabel('Time');
    ylabel('Altitude in km');
end