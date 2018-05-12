function dist = pointLineDist(xa,ya,xb,yb,xc,yc)
		
	dist = Inf;
	% r = (ac.ab)/(ab.ab)
	r = ((xc - xa)*(xb - xa) + (yc-ya)*(yb-ya))/((xb-xa)^2 + (yb-ya)^2);
	% disp "r = " + num2str(r)
	if(r > 0 && r < 1)
		% disp "case 1"
		% Finding the point p where cp is perpendicular to AB:
		xp = xa + r*(xb-xa);
    	yp = ya + r*(yb-ya);
    	% disp "\tPoint P=("+num2str(xp)+","+num2str(yp)+")"
    	dist = ((xp-xc)^2 + (yp-yc)^2)^0.5;
    elseif(r >=1)
		% disp "case 2"
		dist = ((xb-xc)^2 + (yb-yc)^2)^0.5;
	else % if(r <= 0)
		% disp "case 3 ( r<0)"
		dist = ((xa-xc)^2 + (ya-yc)^2)^0.5;
    end