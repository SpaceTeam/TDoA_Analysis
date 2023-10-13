close all;
offset = [];
time = [];
i_b = 1;
i_o=1;
secs = 0;
for i_a=102:2:min(length(a)-100,length(b)-100)
    for i_b=i_a-100:2:i_a+100
        if(a(i_a)==b(i_b))
            if((b(i_b-1)-a(i_a-1)) > 0)
%                 if(length(time)>1)
%                     if(secs+(65536*a(i_a)+a(i_a-1))/72e6 < time(end))
%                         secs=secs+1;
%                     end
%                 end
%                 if(secs>0)
%                     break;
%                 end
                offset = [offset b(i_b-1)-a(i_a-1)];
                time = [time secs+(65536*a(i_a)+a(i_a-1))/72e6];
            end
        end
    end
end

U = polyfit(time,offset,1);
lin = polyval(U,time);
abweichung = (offset - lin)/72e6*3e8;

stem(time, abweichung);
std(abweichung)
