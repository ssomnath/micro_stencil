function SubPattern = AlignPattern(SubPattern)
    for i=1:3:size(SubPattern,1)-1
    
    Sslope = (SubPattern(i+1,2)-SubPattern(i,2))/(SubPattern(i+1,1)-SubPattern(i,1));
    if(abs(Sslope) > 100)
        sline = [Inf, Inf];
        refpt = [SubPattern(i,1),0];
    else
        sline = polyfit([SubPattern(i,1),SubPattern(i+1,1)],[SubPattern(i,2),SubPattern(i+1,2)],1);
        refpt = [0,polyval(sline,0)];
    end
    
    s1 = PointDistance(refpt(1),refpt(2),SubPattern(i,1),SubPattern(i,2));
    s2 = PointDistance(refpt(1),refpt(2),SubPattern(i+1,1),SubPattern(i+1,2));
    
    temp = zeros(2,2);
    % farther point on SubPattern goes to SubPattern i
    temp(1,:) = SubPattern(i+(s2>s1),:);
    % closer point on SubPattern goes to Driver i+1
    temp(2,:) = SubPattern(i+(s1>s2),:);
    SubPattern(i:i+1,:) = temp(:,:);
    
end