function Xc = getCircCenter(A1,N1,A2)
%GETCIRCCENTER returns the center of the circle given three points that are
%on the circle.
    v1 = N1 - A1; v2 = A2 - A1;
    v11 = v1'*v1; v22 = v2'*v2; v12 = v1'*v2;
    b = 1/2 * 1/(v11*v22 - v12^2);
    k1 = b * v22 * (v11 - v12);
    k2 = b * v11 * (v22 - v12);
    Xc = A1 + k1*v1 + k2*v2;
end

