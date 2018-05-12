function dist = PointDistance(x1,y1,x2,y2)
    
    first = (x1-x2)^2;
    second = (y1-y2)^2;
    dist = (first+second)^0.5;
    
end