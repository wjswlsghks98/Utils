function cov2D = convertCov(cov3D)
% Convert 3D covariance to 2D covariance
    cov2D = zeros(4,size(cov3D,2));
    cov2D(1,:) = cov3D(1,:);
    cov2D(2,:) = cov3D(2,:);
    cov2D(3,:) = cov3D(4,:);
    cov2D(4,:) = cov3D(5,:);
end