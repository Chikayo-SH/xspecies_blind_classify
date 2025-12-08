function compute_feature_accuracies_human376_ch157_cv_simple()
% Compute 10-fold CV accuracies of nearest-median classifier
% for human subject 376, channel 157 (HCTSA v2, minimal filter).
%
% INPUT:
%   - Requires human_376_ch157_hctsa_v2.mat under:
%       hctsa_subtractMean_removeLineNoise/human/376/
%   - Uses:
%       TS_DataMat (nEpoch x nFeature)
%       valid_features (logical, nFeature x 1)
%       TimeSeries.Keywords ("awake"/"unconscious")
%
% OUTPUT:
%   - Saves human_376_ch157_featureAcc_cv_simple.mat in the same folder:
%       acc_cv        : CV accuracy (0–1) for valid features only
%       acc_cv_pct    : CV accuracy in percent (0–100)
%       valid_features: original logical mask (7770 x 1)
%       nFold, nEpoch, nFeatures

    %% 1. パスとファイル名
    dirPref = getpref("cosProject", "dirPref");
    hctsaFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_hctsa_v2.mat");

    S = load(hctsaFile, "TS_DataMat", "valid_features", "TimeSeries");

    TS_DataMat     = S.TS_DataMat;          % 60 x 7770
    valid_features = logical(S.valid_features(:)); % 7770 x 1
    TSinfo         = S.TimeSeries;

    %% 2. ラベルベクトルの作成（1 = awake, 2 = unconscious）
    keywords = string(TSinfo.Keywords);
    nEpoch   = numel(keywords);

    classLabels = zeros(nEpoch, 1);
    classLabels(keywords == "awake")       = 1;
    classLabels(keywords == "unconscious") = 2;

    if any(classLabels == 0)
        error("Unexpected Keywords: some epochs are neither 'awake' nor 'unconscious'.");
    end

    %% 3. valid feature だけに絞ったデータ行列
    Xall = TS_DataMat(:, valid_features);   % nEpoch x nValidFeat
    [nEpoch, nFeatValid] = size(Xall);

    %% 4. 10-fold stratified CV のセットアップ
    nFold = 10;
    cv = cvpartition(classLabels, "KFold", nFold);  % ラベルを保ったまま分割

    % 精度計算用のカウンタ
    totalCorrect = zeros(nFeatValid, 1);
    totalCount   = 0;

    %% 5. 各 fold で最近傍中央値分類器を評価
    for k = 1:cv.NumTestSets

        trainIdx = training(cv, k);  % logical (nEpoch x 1)
        testIdx  = test(cv, k);      % logical

        Xtrain = Xall(trainIdx, :);       % nTrain x nFeatValid
        ytrain = classLabels(trainIdx);   % nTrain x 1

        Xtest = Xall(testIdx, :);         % nTest x nFeatValid
        ytest = classLabels(testIdx);     % nTest x 1
        nTest = numel(ytest);

        % 5-1. 条件ごとの中央値（train データのみ）
        medAwake = median(Xtrain(ytrain == 1, :), 1);  % 1 x nFeatValid
        medUncon = median(Xtrain(ytrain == 2, :), 1);  % 1 x nFeatValid

        % 5-2. test データとの距離を計算
        %      distAwake(i,f) = |Xtest(i,f) - medAwake(f)|
        distAwake = abs(Xtest - medAwake);
        distUncon = abs(Xtest - medUncon);

        % 5-3. 各 feature について、どちらの中央値に近いかでラベルを決定
        pred = ones(nTest, nFeatValid);           % デフォルトは 1 (awake)
        pred(distUncon < distAwake) = 2;          % unconscious のほうが近ければ 2

        % 5-4. 正答数をカウント
        ytestMat = repmat(ytest, 1, nFeatValid);  % nTest x nFeatValid
        correctMat = (pred == ytestMat);          % logical

        totalCorrect = totalCorrect + sum(correctMat, 1).'; % nFeatValid x 1
        totalCount   = totalCount + nTest;
    end

    %% 6. feature ごとの CV 精度を計算
    acc_cv = totalCorrect / totalCount;    % 0–1
    acc_cv_pct = acc_cv * 100;            % 0–100 (%)

    %% 7. 結果を保存
    outFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_cv_simple.mat");

    nFeatures = nFeatValid;

    save(outFile, "acc_cv", "acc_cv_pct", ...
        "valid_features", "nFold", "nEpoch", "nFeatures");

    fprintf("Saved simple 10-fold CV accuracies to:\n  %s\n", outFile);
end
