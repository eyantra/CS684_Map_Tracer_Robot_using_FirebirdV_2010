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

%Opening the file for reading
File = csvread('Combine.txt');
%csvread reads a file and makes a 2D array
[m,n] = size(File);
%Find out the size of 2D array
map=zeros(1040,880);
%Initilize the array with all zeros
%1040=640(Resolution of Camera)+200(Left Pad)+200(Right Pad)
for index=1:m
    %Sample row of Combine.txt will look like 6,3,10,0,0,123.178512,236.914670,350.479989
    %Extracting the sensor values, angle and coordinate of image
    a=min(File(index,1),30);
    b=min(File(index,2),30);
    c=min(File(index,3),30);
    d=min(File(index,4),30);
    e=min(File(index,5),30);
    
    theata=File(index,6);
    image_position=[File(index,7),File(index,8)];
    
    
    
    if(a > 0)
            %180 + theata because sensor 1 is in extreme left location
            a_x=cosd(180+theata);
            a_y=sind(180+theata);
            %Applying Padding to avoid negative values
            x=image_position(1)+200;
            y=image_position(2)+200;
            for i=1:150
                %converting decimal values to integer values
                x=uint16(x+a_x);
                y=uint16(y+a_y);
                if(i<=2.4*a)
                    %Checking if x and y does not excceds the image
                    %coordinates
                    if(x>1 && x<1040 && y>1 && y<880)
                        %Plotting multiple 1 so as to make thick line.
                        map(x,y)=1;
                        map(x,y+1)=1;    
                        map(x,y-1)=1;    
                        map(x+1,y)=1;
                        map(x+1,y+1)=1;
                        map(x+1,y-1)=1;
                        map(x-1,y)=1;
                        map(x-1,y+1)=1;
                        map(x-1,y-1)=1;
                        
                    end
                else
                  if(x>1 && x<1040 && y>1 && y<880)  
                      %Make the values beyond it as object
                    map(x,y)=-1;    
                  end
                end
                
                
                
                
            end
    end
        
        %Similar as a it is exact same code
        if(b > 0)
            b_x=cosd(135+theata);
            b_y=sind(135+theata);
            x=image_position(1)+200;
            y=image_position(2)+200;
            for i=1:192
            
                x=uint16(x+b_x);
                y=uint16(y+b_y);
                if(i<=2.4*b)
                    if(x>1 && x<1040 && y>1 && y<880)
                        map(x,y)=1;
                        map(x,y+1)=1;    
                        map(x,y-1)=1;    
                        map(x+1,y)=1;
                        map(x+1,y+1)=1;
                        map(x+1,y-1)=1;
                        map(x-1,y)=1;
                        map(x-1,y+1)=1;
                        map(x-1,y-1)=1;
                    end
                else
                  if(x>1 && x<1040 && y>1 && y<880)  
                    map(x,y)=-1;    
                  end
                end
                
                
                
                
            end
        end
        
        
        %Similar as a it is exact same code
        if(c > 0)
            c_x=cosd(90+theata);
            c_y=sind(90+theata);
            x=image_position(1)+200;
            y=image_position(2)+200;
            for i=1:192
            
                x=uint16(x+c_x);
                y=uint16(y+c_y);
                if(i<=2.4*c)
                    if(x>1 && x<1040 && y>1 && y<880)
                        map(x,y)=1;
                        map(x,y+1)=1;    
                        map(x,y-1)=1;    
                        map(x+1,y)=1;
                        map(x+1,y+1)=1;
                        map(x+1,y-1)=1;
                        map(x-1,y)=1;
                        map(x-1,y+1)=1;
                        map(x-1,y-1)=1;
                    end
                else
                  if(x>1 && x<1040 && y>1 && y<880)  
                    map(x,y)=-1;    
                  end
                end
                
                
                
                
            end
        end
        
        %Similar as a it is exact same code
        if(d > 0)
            d_x=cosd(45+theata);
            d_y=sind(45+theata);
            x=image_position(1)+200;
            y=image_position(2)+200;
            for i=1:192
            
                x=uint16(x+d_x);
                y=uint16(y+d_y);
                if(i<=2.4*d)
                    if(x>1 && x<1040 && y>1 && y<880)
                        map(x,y)=1;
                        map(x,y+1)=1;    
                        map(x,y-1)=1;    
                        map(x+1,y)=1;
                        map(x+1,y+1)=1;
                        map(x+1,y-1)=1;
                        map(x-1,y)=1;
                        map(x-1,y+1)=1;
                        map(x-1,y-1)=1;
                    end
                else
                  if(x>1 && x<1040 && y>1 && y<880)  
                    map(x,y)=-1;    
                  end
                end
                
                
                
                
            end
        end

        %Similar as a it is exact same code
        if(e > 0)
            e_x=cosd(theata);
            e_y=sind(theata);
            x=image_position(1)+200;
            y=image_position(2)+200;
            for i=1:192
            
                x=uint16(x+e_x);
                y=uint16(y+e_y);
                if(i<=2.4*e)
                    if(x>1 && x<1040 && y>1 && y<880)
                        map(x,y)=1;
                        map(x,y+1)=1;    
                        map(x,y-1)=1;    
                        map(x+1,y)=1;
                        map(x+1,y+1)=1;
                        map(x+1,y-1)=1;
                        map(x-1,y)=1;
                        map(x-1,y+1)=1;
                        map(x-1,y-1)=1;
                    end
                else
                  if(x>1 && x<1040 && y>1 && y<880)  
                    map(x,y)=-1;    
                  end
                end    
            end
        end
end

imshow(map);
%Applying Image Processing to enhance the image
H = fspecial('disk',10);
blurred = imfilter(map,H,'replicate'); 
size=size(blurred);
for i=1:size(1)
    for j=1:size(2)
        if(blurred(i,j)>=0.25)
        map(i,j)=1;
        else
        map(i,j)=0;    
        end
    end
end
%Again applying Image Processing to further enhance the image
H1 = fspecial('disk',10);
blurred1 = imfilter(map,H1,'replicate'); 
for i=1:size(1)
    for j=1:size(2)
        if(blurred1(i,j)>=0.25)
        map(i,j)=1;
        else
        map(i,j)=0;    
        end
    end
end
figure; imshow(map)

% pause(20)
% close all
% clear all
% clc