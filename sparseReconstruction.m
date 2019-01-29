I1 = imread('../images/img1.png');
I2 = imread('../images/img2.png');
%%% Converting image to grayscale
I1 = rgb2gray(I1);
I2 = rgb2gray(I2);

%%% Detecting surf points with threshold 10
points1 = detectSURFFeatures(I1,'MetricThreshold',10);
points2 = detectSURFFeatures(I2,'MetricThreshold',10);
[f1,vpts1] = extractFeatures(I1,points1);
[f2,vpts2] = extractFeatures(I2,points2);

%%% Finding coordinates of matched features in image1 and image2
indexPairs = matchFeatures(f1,f2) ;
matchedPoints1 = vpts1(indexPairs(:,1));
matchedPoints2 = vpts2(indexPairs(:,2));

figure; ax = axes;
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage','Parent',ax);
title(ax, 'Candidate point matches');
legend(ax, 'Matched points 1','Matched points 2');

%%%Estimating the Fundamental Matrix
pts2D1 = matchedPoints1.Location;
pts2D2 = matchedPoints2.Location;
[norm_F, T1, T2,inliers_a,inliers_b]= estimateFundamentalMatrixRANSAC(pts2D1,pts2D2);
% norm_F = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'NumTrials',4000);
%%% Camera Matrix
K = [558.7087 0 310.3210;0 558.2827 240.2395;0 0 1]; 
%%% Finding Essential Matrix
E = transpose(K) * norm_F * K;

%%% In case E is not rank 2
[U,D,V] = svd(E);
z = (D(1,1) + D(2,2))/2;
D_new = diag([z,z,0]);
E = U * D_new * transpose(V);
s1 = size(inliers_a,1);
inliers_a(:,3) = ones(s1,1);
inliers_a = transpose(inliers_a);
inliers_b(:,3) = ones(s1,1);
inliers_b = transpose(inliers_b);
%%% Finding R and T from given Essential Matrix
[R, t] = decomposeEssentialMatrix(E,inliers_a,inliers_b,K);
P1 = K * [eye(3), [0; 0; 0]];
P2 = K * [R,t];
pts3D = algebraicTriangulation(inliers_a,inliers_b,P1,P2);
pts3D = pts3D ./ repmat(pts3D(4,:), 4, 1);
figure;
% plotCameraFrustum(P1,'red',0.02);
% hold on;
% plotCameraFrustum(P2,'blue',0.02);
scatter3(pts3D(1,:),pts3D(2,:),pts3D(3,:),'filled');
%%% Displaying values
norm_F = norm_F ./norm_F(3,3);
disp('The Fundamental Matrix is:');
disp(norm_F);
disp('Rotation  matrix is given as:');
disp(R);
disp('Translation matrix is given as:');
disp(t);