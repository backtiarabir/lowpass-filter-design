clear; clc; close all;

if isfile('Crop_recommendation.csv')
    data = readtable('Crop_recommendation.csv');
else
    error('Dataset file "Crop_recommendation.csv" not found.');
end

data = rmmissing(data);
features = data{:, {'N','P','K','temperature','humidity','ph','rainfall'}};
labels = grp2idx(data.label);
cropNames = unique(data.label);

figure;
gscatter(data.ph, data.N, data.label);
xlabel('pH'); ylabel('Nitrogen');
title('pH vs Nitrogen across Crop Types');
grid on;

figure;
corrMatrix = corr(features);
heatmap(data.Properties.VariableNames(1:7), ...
        data.Properties.VariableNames(1:7), corrMatrix);
title('Feature Correlation Heatmap');

figure;
scatter3(data.N, data.P, data.K, 50, labels, 'filled');
xlabel('Nitrogen'); ylabel('Phosphorus'); zlabel('Potassium');
title('3D Nutrient Scatter by Crop Type');
grid on; colorbar;

cv = cvpartition(height(data), 'HoldOut', 0.2);
trainIdx = training(cv);
testIdx = test(cv);

Xtrain = features(trainIdx,:);
Ytrain = labels(trainIdx);
Xtest = features(testIdx,:);
Ytest = labels(testIdx);

Mdl = fitctree(Xtrain, Ytrain);
Ypred = predict(Mdl, Xtest);

accuracy = sum(Ypred == Ytest) / numel(Ytest);
fprintf('Decision Tree Accuracy: %.2f%%\n', accuracy * 100);

figure;
confusionchart(Ytest, Ypred);
title('Confusion Matrix - Decision Tree Model');

newSoil = [90, 42, 43, 20, 80, 6.5, 200];
predictedClass = predict(Mdl, newSoil);

fprintf('\nPredicted Suitable Crop: %s\n', cropNames{predictedClass});