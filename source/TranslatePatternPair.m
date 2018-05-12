function [p1,p2] = TranslatePatternPair(p1,p2,trans)
    
    p1(:,1) = p1(:,1) + trans(1,1);
    p1(:,2) = p1(:,2) + trans(1,2);
    
    p2(:,1) = p2(:,1) + trans(2,1);
    p2(:,2) = p2(:,2) + trans(2,2);
    
end