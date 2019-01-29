function [norm_F,T1_final,T2_final,inliers_a,inliers_b] = estimateFundamentalMatrixRANSAC(corresponding_pts1, corresponding_pts2)
n = 8;
inliers = 0;
%%% Threshold error
error_thresh = 0.0005;
norm_F = zeros(3,3);
s1 = size(corresponding_pts1,1);
%%% Homogeneous Representaion
corresponding_pts1(:,3) = ones(s1,1);
corresponding_pts2(:,3) = ones(s1,1);

%%% RANSAC Loop
for i = 1:20000
    %%% Random 8 Points
    ind = randi(s1, [n,1]);
    %%% normalizing those 8 points
    [norm2Dpts1 , T1] = normalize2DPoints(corresponding_pts1(ind,:));
    [norm2Dpts2 , T2] = normalize2DPoints(corresponding_pts2(ind,:));
    %%% Estimating F from the selected 8 points
    F_Estimate = Normalized_Estimate_F_Matrix(norm2Dpts1,norm2Dpts2);
    F_Estimate = T2'* F_Estimate * T1;
    %%% Checking error from computed F
    err = sum((corresponding_pts2 .* (F_Estimate * corresponding_pts1')'),2);
    current_inliers = size( find(abs(err) <= error_thresh) , 1);
    if (current_inliers > inliers)
        norm_F = F_Estimate;
        T1_final = T1;
        T2_final = T2;
        inliers = current_inliers;
    end
end
disp(inliers);
err = sum((corresponding_pts2 .* (norm_F * corresponding_pts1')'),2);
[Y,I]  = sort(abs(err),'ascend');
inliers_a = corresponding_pts1(I(1:250),1:2);
inliers_b = corresponding_pts2(I(1:250),1:2);
end