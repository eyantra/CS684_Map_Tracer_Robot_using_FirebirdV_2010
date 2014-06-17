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

%Opening the file
fid = fopen('Combine.txt', 'w');
%Getting the values and putting it in 2D array
File1 = csvread('Camera.txt');
%Finding out the size of array
[m1,n1] = size(File1);
%Opening the file
File2 = csvread('Xbee.txt');
%Getting the values and putting it in 2D array
[m2,n2] = size(File2);
%Finding out the size of array
p=1;
q=1;
flag=0;
while(flag==0)
 %If the diffrence between the timestamp is greater than 1000 then neglect
 %and move to next timestamp
 currdiff=abs(File1(p,1)-File2(q,1));
 if( (File1(p,1)-File2(q,1)>1000 ))
    q=q+1;
    
    if (q>m2) 
        break 
    end
        
 else
 
    if( (File2(q,1)-File1(p,1)>1000 ))
        p=p+1;
    
    if (p>m1) 
        break 
    end
 
    else
     
        %If both the timestamp is equal
        if(File1(p,1)==File2(q,1))
            A=[File1(p,1),File1(p,2), File2(q,1), File2(q,2)];
            fprintf(fid, '%d,%d,%d,%d,%d,%f,%f,%f\n',File2(q,2),File2(q,3),File2(q,4),File2(q,5),File2(q,6),File1(p,2),File1(p,3),File1(p,4));
            p=p+1;
            q=q+1;
            
            if (q>m2 || p>m1) 
                 break 
            end
            
            continue
        else
 
             if(File1(p,1)<File2(q,1))
             currdiff_new=abs(File1(p+1,1)-File2(q,1));
                %if new values has less diffrence than increase the index
                if(currdiff_new<=currdiff)
                    p=p+1;
                    if (p>m1) 
                        break 
                    end
                else
                    %if old values has less diffrence than increase the
                    %index then write the Combine the two Files and put it
                    %on to Combine.txt
                    A=[File1(p,1),File1(p,2), File2(q,1), File2(q,2)];
                    fprintf(fid, '%d,%d,%d,%d,%d,%f,%f,%f\n',File2(q,2),File2(q,3),File2(q,4),File2(q,5),File2(q,6),File1(p,2),File1(p,3),File1(p,4));
                    p=p+1;
                    q=q+1;
                    if (q>m2 || p>m1) 
                        break 
                    end
                end
             end
 
             if(File1(p,1)>File2(q,1))
             currdiff_new=abs(File1(p,1)-File2(q+1,1));
                %if new values has less diffrence than increase the index
                if(currdiff_new<=currdiff)
                    q=q+1;
                    if (q>m2) 
                        break 
                    end
                else
                    %if old values has less diffrence than increase the
                    %index then write the Combine the two Files and put it
                    %on to Combine.txt
                     A=[File1(p,1),File1(p,2), File2(q,1), File2(q,2)];
                     fprintf(fid, '%d,%d,%d,%d,%d,%f,%f,%f\n',File2(q,2),File2(q,3),File2(q,4),File2(q,5),File2(q,6),File1(p,2),File1(p,3),File1(p,4));
                     q=q+1;
                     p=p+1;
                     if (q>m2 || p>m1) 
                        break 
                    end
                 end
             end
        end
    end
 end
end