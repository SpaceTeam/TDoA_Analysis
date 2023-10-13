function [latitude,longitude,altitude,year,month,day,hour,minute,second,CountsSincePPS,CountsPerSecond,timestamp,maxlen,len] = read_files(filepath,num_receivers,num_loras);

maxlen = 0;
len = zeros(num_receivers,num_loras);
for relogger=1:num_receivers
    for lora=1:num_loras
        [~,~,~,~,~,~,~,~,~,~,~,~,len(relogger,lora)] = read_file([filepath num2str(relogger) '_LORA' num2str(lora) '.txt']);
        if(len(relogger,lora)>maxlen)
            maxlen = len(relogger,lora);
        end
    end
end

latitude = zeros(maxlen,num_receivers,num_loras);
longitude = zeros(maxlen,num_receivers,num_loras);
altitude = zeros(maxlen,num_receivers,num_loras);
year = zeros(maxlen,num_receivers,num_loras);
month = zeros(maxlen,num_receivers,num_loras);
day = zeros(maxlen,num_receivers,num_loras);
hour = zeros(maxlen,num_receivers,num_loras);
minute = zeros(maxlen,num_receivers,num_loras);
second = zeros(maxlen,num_receivers,num_loras);
CountsSincePPS = zeros(maxlen,num_receivers,num_loras);
CountsPerSecond = zeros(maxlen,num_receivers,num_loras);
timestamp = zeros(maxlen,num_receivers,num_loras);

for relogger=1:num_receivers
    for lora=1:num_loras
        [latitude(1:len(relogger,lora),relogger,lora),longitude(1:len(relogger,lora),relogger,lora),altitude(1:len(relogger,lora),relogger,lora),year(1:len(relogger,lora),relogger,lora),month(1:len(relogger,lora),relogger,lora),day(1:len(relogger,lora),relogger,lora),hour(1:len(relogger,lora),relogger,lora),minute(1:len(relogger,lora),relogger,lora),second(1:len(relogger,lora),relogger,lora),CountsSincePPS(1:len(relogger,lora),relogger,lora),CountsPerSecond(1:len(relogger,lora),relogger,lora),timestamp(1:len(relogger,lora),relogger,lora),~] = read_file([filepath num2str(relogger) '_LORA' num2str(lora) '.txt']);
    end
end
end

