function compute_feature_accuracies_human376_ch159_cv()
% Compute nearest-median classification accuracy with 10-fold CV
% for human subject 376, frontal channel ch130 (HCTSA v2).

    % 1. プロジェクトルートの取得
    dirPref = getpref("cosProject", "dirPref");
    hctsaFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch130_hctsa_v2.mat");

    % 2. HCTSA データの読み込み
    S = load(hctsaFile, ...
        "Operations", "TS_DataMat", "TS_Normalised", "TimeSeries");

    % 3. trainData / validateData 構造体の作成
    trainData = struct();
    trainData.Operations    = S.Operations;
    trainData.TS_DataMat    = S.TS_DataMat;
    trainData.TS_Normalised = S.TS_Normalised;
    trainData.TimeSeries    = S.TimeSeries;

    % 今回は同一データセット内での CV なので validateData = trainData
    validateData = trainData;

    % 4. 10-fold CV nearest-median classifier の実行
    ncv       = 10;
    condNames = {"awake", "unconscious"};
    hctsaType = "TS_DataMat";  % RR の記述に合わせて非正規化値を使用

    [classifier_result, ~] = NMclassifier_cv( ...
        trainData, validateData, ncv, condNames, hctsaType);

    % 5. feature ごとの平均精度（fold 平均）を計算
    maccuracy_train          = mean(classifier_result.accuracy_train, 2);           % nFeat x 1
    maccuracy_validate       = mean(classifier_result.accuracy_validate, 2);        % nFeat x 1
    maccuracy_validate_rand  = mean(classifier_result.accuracy_validate_rand, 2);   % nFeat x 1

    % 6. validFeatures で絞ったベクトル（こちらを Fig.2B/CDF 用に使う想定）
    validFeatures = classifier_result.validFeatures;
    acc_cv        = maccuracy_validate(validFeatures);        % 有効 feature だけ
    acc_cv_rand   = maccuracy_validate_rand(validFeatures);

    % 7. 結果の保存
    outFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch130_featureAcc_cv.mat");

    save(outFile, "maccuracy_train", "maccuracy_validate", ...
        "maccuracy_validate_rand", "validFeatures", ...
        "acc_cv", "acc_cv_rand");
end
