function driver = MakeDriver(p1,p2,p3,p4,p5)
    s1 = ceil(size(p1,1)/3)*3;
    s2 = ceil(size(p2,1)/3)*3;
    s3 = ceil(size(p3,1)/3)*3;
    s4 = ceil(size(p4,1)/3)*3;
    s5 = ceil(size(p5,1)/3)*3;
    driver = zeros(s1+s2+s3+s4+s5,2);
    
    j=1;
    for i=1:3:size(p1)
        driver(j:j+1,:) = p1(i:i+1,:); 
        driver(j+2,:) = [NaN, NaN];
        j=j+3;
    end
    for i=1:3:size(p2)
        driver(j:j+1,:) = p2(i:i+1,:); 
        driver(j+2,:) = [NaN, NaN];
        j=j+3;
    end
    for i=1:3:size(p3)
        driver(j:j+1,:) = p3(i:i+1,:); 
        driver(j+2,:) = [NaN, NaN];
        j=j+3;
    end
    for i=1:3:size(p4)
        driver(j:j+1,:) = p4(i:i+1,:); 
        driver(j+2,:) = [NaN, NaN];
        j=j+3;
    end
    for i=1:3:size(p5)
        driver(j:j+1,:) = p5(i:i+1,:); 
        driver(j+2,:) = [NaN, NaN];
        j=j+3;
    end
end