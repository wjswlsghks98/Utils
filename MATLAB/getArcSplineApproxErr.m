function res = getArcSplineApproxErr(A1,A2,k,pt)
%GETARCSPLINEAPPROXERR returns true if arc spline approximation for point
%pt is valid, using the covariance matrix cov.

    v = 1/(2*hsq)*[0,-1;1,0] * (A2 - A1);
    Xc = 1/2 * (A1 + A2) - hsq^2/k * v;
    R = norm(Xc - A1);
    proj = Xc + (R/norm(Xc-pt)) * (pt - Xc);
    res = proj - pt;
end

