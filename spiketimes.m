%%
% sp = cell(size(data));
% 
% fs = 20000;
% for n=1:length(data)
%     sp{n} = SpikeFinder(time,data{n},fs,1e-3,0);
% end

%%
sp = cell(size(data));
for n=1:length(data)
    sp{n} = simpledetection(time,data,10,3.5);
end
%%
dt = time(2)-time(1);
raster = cell(size(sp));

for t=1:length(sp)
    raster{t}(round(sp{t}/dt)) = 1;
end
%%
rasterplot(raster,dt);