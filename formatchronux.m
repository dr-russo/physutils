function chdata = formatchronux(data,dt)

M = size(data,1);


for m=1:M
     spikeLoc = find(data(M,:)==1);
     chdata(m) = struct('times',dt*spikeLoc);
    
end



end