function fname = uigetfilename()

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='none';

prompt = 'Enter file ending:';
name = 'File Name';
numlines = 1;
defaultanswer = {'_0'};
   

fname=inputdlg(prompt,name,numlines,defaultanswer,options);

end