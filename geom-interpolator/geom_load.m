clear all

nx = 120;
ny = 40;

filename = 'geom';

fid=fopen(filename);
if fid == -1,
  warning('File does not exist');
  return
end

xl = [];
yl = [];
xu = [];
yu = [];

while 1
    line = fgetl(fid);
    if length(line) <2,
        break
    end
    strs=sscanf(line,'%f %f %f %f');
    if length(strs) == 4;
        xl = [xl; strs(1)];
        yl = [yl; strs(2)];
        xu = [xu; strs(3)];
        yu = [yu; strs(4)];
    end
end
fclose(fid);

xl_hd = transpose(linspace(xl(1),xl(end),nx)); %this interpolation for STRAIGHT sections only!!!!!
xu_hd = transpose(linspace(xu(1),xu(end),nx));
yl_hd = makima(xl,yl,xl_hd);
yu_hd = pchip(xu,yu,xu_hd);

close
plot(xl_hd,yl_hd,'k')
hold on
plot(xl,yl,'r')
%plot(xu,yu,'k')
%hold off
axis equal

fileID = fopen('geom_hd','w');
fprintf(fileID,'%s\n','Nozzle');
fprintf(fileID,'%3.0f %3.0f\n',nx,ny);
fprintf(fileID,'%2.5f %2.5f %2.5f %2.5f\n',transpose([xl_hd, yl_hd, xu_hd, yu_hd]));
fclose(fileID);