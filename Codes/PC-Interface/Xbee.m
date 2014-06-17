%  
%							AUTHORS
%							IIT BOMBAY STUDENTS :
%
%							ARPIT MALANI (10305901)
%							HERMESH GUPTA (10305080)
%							RAHUL NIHALANI (10305003)
%							VIVEK V VELANKAR (10305050)
%
% 							Last Modified : 9 Nov 2010

%Open file
fid = fopen('Xbee.txt', 'w');
%Open Computer Port on which Xbee is attached to
s = serial('COM14');
fopen(s);
fprintf(s,'*IDN?');

%Iteration to some large number can also use while(1)
for i = 1:10000
%Listen for Xbee port 10 characters at a time    
out = fscanf(s,'%c',10);
%The out will be some thing of format a%b0d$e3c7
%In every pair first char shows the sensor index/name and second is ascii represent the distance 

%Finding is a is available there are times when bits can go out of order in
%that case default distance would be 0
k=strfind(out, 'a');
if (length(k)>0)
    a=out(k(1)+1)-0;
else
    a=0;
end

k=strfind(out, 'b');
if (length(k)>0)
    b=out(k(1)+1)-0;
else
    b=0;
end
k=strfind(out, 'c');
if (length(k)>0)
    c=out(k(1)+1)-0;
else
    c=0;
end
k=strfind(out, 'd');
if (length(k)>0)
    d=out(k(1)+1)-0;
else
    d=0;
end
k=strfind(out, 'e');
if (length(k)>0)
    e=out(k(1)+1)-0;
else
    e=0;
end
%convert time to string
ts=datestr(now,'HHMMSSFFF')
%convert string to long variable
t=(ts(1)-48)*100000000+(ts(2)-48)*10000000+(ts(3)-48)*1000000+(ts(4)-48)*100000+(ts(5)-48)*10000+(ts(6)-48)*1000+(ts(7)-48)*100+(ts(8)-48)*10+(ts(9)-48)
%Write timestamp and sensor values on to file Xbee.txt
fprintf(fid, '%d,%d,%d,%d,%d,%d\n', t,a,b,c,d,e)

end

fclose(fid);