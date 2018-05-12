function retrans = CompensateDrift(mytrans, W1dx, W1dy, W2dx, W2dy)
    retrans(1,1)=mytrans(1)+W1dx;
    retrans(1,2)=mytrans(2)+W1dy;
    retrans(2,1)=mytrans(1)+W2dx;
    retrans(2,2)=mytrans(2)+W2dy;
end