function cellname = getcellname(filename)

[nameStart nameEnd] = regexp(filename,'\d{6}\w','once');
cellname = filename(nameStart:nameEnd);

end
