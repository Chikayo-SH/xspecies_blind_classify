function compute_feature_accuracies_human376_ch157_cv()
% Compute nearest-median classification accuracy with 10-fold CV
% for human subject 376, frontal channel ch157 (HCTSA v2).
%
% INPUT:
%   - Requires human_376_ch157_hctsa_v2.mat under:
%       hctsa_subtractMean_removeLineNoise/human/376/
%   - Requires NMclassifier_cv.m and its dependencies on the MATLAB path.
%
% OUTPUT:
%   - Saves human_376_ch157_featureAcc_cv.mat in the same folder, containing:
%       maccuracy_train, maccuracy_validate, maccuracy_validate_rand,
%       validFeatures, acc_cv, acc_cv_rand.

    % 1. プロジェクトルートと HCTSA ファイルのパス
    dirPref = getpref("cosProject", "dirPref");
    hctsaFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_hctsa_v2.mat");

    % 2. 必要なフィールドだけ読み込む
    S = load(hctsaFile, ...
        "Operations", "TS_DataMat", "TS_Normalised", "TimeSeries");

    % 3. NMclassifier_cv 用の構造体を準備（trainData = validateData）
    trainData = struct();
    trainData.Operations    = S.Operations;
    trainData.TS_DataMat    = S.TS_DataMat;
    trainData.TS_Normalised = S.TS_Normalised;
    trainData.TimeSeries    = S.TimeSeries;

    validateData = trainData;

    % 4. 10-fold CV の設定
    ncv       = 10;
    condNames = {"awake", "unconscious"};
    % RR の記述に合わせて、非正規化の TS_DataMat を使う
    hctsaType = "TS_DataMat";

    % 5. Daisuke repo の NMclassifier_cv を使って CV を実行
    [classifier_result, ~] = NMclassifier_cv( ...
        trainData, validateData, ncv, condNames, hctsaType);

    % 6. fold 平均の精度を計算（feature ごと）
    maccuracy_train         = mean(classifier_result.accuracy_train, 2);          % nFeat x 1
    maccuracy_validate      = mean(classifier_result.accuracy_validate, 2);       % nFeat x 1
    maccuracy_validate_rand = mean(classifier_result.accuracy_validate_rand, 2);  % nFeat x 1

    % 7. validFeatures（NaN/Inf/定数除外済み feature）と、
    %    それで絞った精度ベクトルを作る
    validFeatures = classifier_result.validFeatures;

    acc_cv      = maccuracy_validate(validFeatures);
    acc_cv_rand = maccuracy_validate_rand(validFeatures);

    % 8. 結果を保存
    outFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_cv.mat");

    save(outFile, "maccuracy_train", "maccuracy_validate", ...
        "maccuracy_validate_rand", "validFeatures", ...
        "acc_cv", "acc_cv_rand");

    fprintf("Saved CV accuracies to:\n  %s\n", outFile);
end
