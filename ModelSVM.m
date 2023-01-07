%% importing dataset
%csv = readtable('C:\Users\FURKAN\Desktop\MAtlab makine öğrenmesi çalışma\data.csv');
%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: C:\Users\FURKAN\Desktop\MAtlab makine öğrenmesi çalışma\data.csv
%
% Auto-generated by MATLAB on 17-Dec-2022 02:34:37

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 33);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["id", "diagnosis", "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean", "compactness_mean", "concavity_mean", "concavePoints_mean", "symmetry_mean", "fractal_dimension_mean", "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concavePoints_se", "symmetry_se", "fractal_dimension_se", "radius_worst", "texture_worst", "perimeter_worst", "area_worst", "smoothness_worst", "compactness_worst", "concavity_worst", "concavePoints_worst", "symmetry_worst", "fractal_dimension_worst", "VarName33"];
opts.VariableTypes = ["double", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "VarName33", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["diagnosis", "VarName33"], "EmptyFieldRule", "auto");

% Import the data
data = readtable("C:\Users\FURKAN\Desktop\MAtlab makine öğrenmesi çalışma\data.csv", opts);

% Gereksiz kolonları model doğruluğunu bozmaması için çıkardık.
data.VarName33 = [];
data.id = [];
% Clear temporary variables
clear opts
%%
% Veriyi normalize ettik.
dataNorm = normalize(data,'scale',"DataVariables",vartype("numeric"));
histogram(dataNorm.diagnosis);

%% En yüksek başarı değerimizi bulmak için algoritmamızı 30 defa çalıştırdık
% ve score değerlerini kaydettik.
score_list = {};
 for c = 1:30
     cv = cvpartition(dataNorm.diagnosis,"HoldOut",0.3);
     %Train ve test verilerini değişkenlerimizin içerisine atadık
     bcTrain = dataNorm(training(cv),:);
     bcTest = dataNorm(test(cv),:);
     bcTest_Y = bcTest.diagnosis;
     tempSVM = fitcsvm(bcTrain,"diagnosis");
     tempPredictionSVM = predict(tempSVM,bcTest);
     tempIscorrectSVM = (tempPredictionSVM==bcTest.diagnosis);
     tempAccuracySVM = sum(tempIscorrectSVM)/numel(tempIscorrectSVM);
     score_list = [score_list,tempAccuracySVM];
end
 accuracySVM15 = max(cell2mat(score_list));
%% Algoritma
% Veri setimizi böldük
cv = cvpartition(dataNorm.diagnosis,"HoldOut",0.3);
cv15 = cvpartition(dataNorm.diagnosis,"HoldOut",0.15);

% Train ve test verilerini değişkenlerimizin içerisine atadık
bcTrain = dataNorm(training(cv),:);
bcTest = dataNorm(test(cv),:);

bcTrain15 = dataNorm(training(cv15),:);
bcTest15 = dataNorm(test(cv15),:);
%head(bcTrain);
%head(bcTest);

% SVM algoritmamıza uyguladık ve diagnosis sütununu bağımlı değişken
% olarak aldık.
svmModel = fitcsvm(bcTrain,"diagnosis");
svmModel15 = fitcsvm(bcTrain15,"diagnosis");

% ROC Curve
[labels, score] = resubPredict(tempSVM);
whos score
whos
[X1, Y1] = perfcurve(svmModel.Y,score(:,1),'B');
length(unique(score(:,1)));
plot(X1,Y1);
[X2, Y2] = perfcurve(svmModel.Y,score(:,2),'M');
length(unique(score(:,2)));
figure
plot(X1,Y1);
hold on
plot(X2,Y2);
title('ROC Curve');
legend({'B','M'},'Location','northeast');


% Eksik veri olup olmadığını test ettik.
% missingTrain = min(sum(ismissing(bcTrain)));
% missingTest = min(sum(ismissing(bcTest)));

% loss fonksiyonu yardımıyla hata payımızı ölçtük
fault = loss(svmModel,bcTest);
fault15 = loss(svmModel15,bcTest15);

% Gerçek verimiz ile test verimizi karşılaştırdık ve tahmin değişkenine
% atadık
predictionSVM = predict(svmModel,bcTest);
predictionSVM15 = predict(svmModel15,bcTest15);
% [predictionDT,bcTest.diagnosis]= ;

% Sonucu analiz etmek adına confusionchart fonksiyonu ile confison
% chart'ımızı yazdırdık.
bcTest_Y = bcTest.diagnosis;
confusionchart(predictionSVM,bcTest_Y);

bcTest15_Y = bcTest.diagnosis;
confusionchart(predictionSVM15,bcTest15_Y);


% Tahmin edilen diagnosis değerleri ile Test verimizi karşılaştırdık ve
% sonucu iscorrectDT değişkenine atadık.
iscorrectSVM = (predictionSVM==bcTest.diagnosis);
iscorrectSVM15 = (predictionSVM15==bcTest15.diagnosis);

% Accuarcy değerini hesapladık
accuracySVM = sum(iscorrectSVM)/numel(iscorrectSVM);
accuracySVM15 = sum(iscorrectSVM15)/numel(iscorrectSVM15);
%disp("Hata Payı : " + fault);
%disp("Accuracy Değeri : "+ accuracyDT);
