

fid=fopen(filename);
if fid == -1,
  warning('File does not exist');
  return
end

while 1
   line = fgetl(fid);
   if ~ischar(line),
     break
   end
   if strncmp('R =',dblnk(line),3),
      [strs,~,~,n]=sscanf(line,'%s', 3);
      R=strs(3:end);
      [strs,~,~,n]=sscanf(line,'%s', 5);
      strs=sscanf(line(n:end),'%s', 3);
      xtu=strs(5:end);
      [strs,~,~,n]=sscanf(line,'%s', 8);
      strs=sscanf(line(n:end),'%s', 3);
      xtl=strs(5:end);
   end  
   
   if strcmp('UPPER-SURFACE BOUNDARY-LAYER DATA',dblnk(line)),
      line = fgetl(fid); line = fgetl(fid); line = fgetl(fid); line = fgetl(fid);
      % jump blanklines
      while 1
         line = fgetl(fid);
         if strcmp('LOWER-SURFACE BOUNDARY-LAYER DATA',dblnk(line)),
            break
         end
         if strncmp('RTHETA',dblnk(line),6)
            line=fgetl(fid);
         end
         if strncmp('TRANSI',dblnk(line),6)
            line=fgetl(fid);
         end
         if strncmp('HBAR MAX',dblnk(line),8)
            line=fgetl(fid);
         end
         if strncmp('CF SET',dblnk(line),6)
            line=fgetl(fid);
         end
         strs=sscanf(line,'%f',[1 6]);
         if strs(1) == 1,
             Hte = strs(2);
             break
         end
      end
   end 
end
fclose(fid);