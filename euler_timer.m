clear all
% change the output path here!
subpath = 'Optimise/Isentropic/';
path = ['~/OneDrive/OneDrive\ -\ University\ Of\ Cambridge/IIB/Coursework/4A2/4A2_git/' subpath];
command = 'time ./Euler';
%
n=10;
usert = [];
syst = [];
%
for i=1:1:n;
    i
    [status,cmdout] = system(['cd ' path ' ; ' command]);
    % breake lines
    output = splitlines(cmdout);
    % extract the time in line
    num = regexp(char(output(end-2)),['\d+\.?\d*'],'match');
    usert = [usert;str2num(char(num(1)))*60+str2num(char(num(2)))];
    num = regexp(char(output(end-1)),['\d+\.?\d*'],'match');
    syst = [syst;str2num(char(num(1)))*60+str2num(char(num(2)))];
end