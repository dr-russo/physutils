function recordname = getrecordname(filename)

[nameStart nameEnd] = regexp(filename,'\d{6}\w[_\s]\d{3}','once');
recordname = filename(nameStart:nameEnd);

end