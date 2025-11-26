function compute_feature_accuracies_human376_ch157_v2()
% compute_feature_accuracies_human376_ch157_v2
%   Human LGD 376 ch157, 30x30 epochs の HCTSA (v2) から、
%   valid_features だけを使って feature ごとの nearest-median
%   分類精度を計算し、CDF とヒストグラムを描画する。
%
% 前提:
%   - main_hctsa_1/2/3_postProcess_human376_ch157_v2 を実行済み
%   - hctsa ファイルに TS_DataMat, valid_features, TimeSeries が入っている
%
% 出力:
%   - 図 (CDF, histogram)
%   - acc ベクトルを *_accuracy.mat として保存

    %% 1. HCTSA ファイルを読み込み
    dirPref = getpref("cosProject", "dirPref");

    hctsaFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_hctsa_v2.mat");

    S = load(hctsaFile, "TS_DataMat", "valid_features", "TimeSeries");

    TS_DataMat     = S.TS_DataMat;        % 60 x 7770
    valid_features = logical(S.valid_features(:)).';  % 1 x 7770
    TimeSeries     = S.TimeSeries;

    [nTS, nFeat] = size(TS_DataMat);
    fprintf("Loaded TS_DataMat: %d time series x %d features\n", nTS, nFeat);
    fprintf("Valid features (from getValidFeatures): %d / %d\n", ...
        nnz(valid_features), nFeat);

    % valid な feature だけに絞る
    X = TS_DataMat(:, valid_features);    % 60 x nValidFeat
    nValidFeat = size(X, 2);
    fprintf("Using %d valid features for classification.\n", nValidFeat);

    %% 2. クラスラベル (1: awake, 2: unconscious) を作成
    keywords = string(TimeSeries.Keywords);  % 60 x 1 string

    classLabels = zeros(nTS, 1);
    classLabels(keywords == "awake")       = 1;
    classLabels(keywords == "unconscious") = 2;

    if any(classLabels == 0)
        error("classLabels に 0 (未割当) が含まれています。Keywords を確認してください。");
    end

    %% 3. featureごとの nearest-median classifier 精度を計算
    acc = compute_nearest_median_accuracies(X, classLabels);  % 0–100[%], nValidFeat x 1

    % summary を表示
    fprintf("Accuracy summary (%%): median = %.1f, mean = %.1f, 90th = %.1f\n", ...
        median(acc), mean(acc), prctile(acc, 90));
    fprintf("Features above chance (50%%): %d / %d\n", ...
        sum(acc > 50), numel(acc));

    %% 4. 図を描画 (CDF + histogram)
    % CDF
    figure;
    cdfplot(acc);
    hold on;
    xline(50, "r--");
    hold off;
    xlabel("Classification Accuracy (%)");
    ylabel("Cumulative Percentage of Features");
    title("LGD 376 ch157 v2: CDF of Feature Accuracies (valid features)");
    xlim([0 100]);              % ★ 横軸を 0–100 に固定

    % ★ ここで保存
cdfFile = fullfile(dirPref.rootDir, ...
    "hctsa_subtractMean_removeLineNoise","human","376", ...
    "lgd376_ch157_v2_featureAcc_CDF.png");
exportgraphics(gcf, cdfFile, "Resolution", 300);
fprintf("Saved CDF figure to:\n  %s\n", cdfFile);

    % Histogram
    figure;
    histogram(acc, 20);
    hold on;
    xline(50, "r--");
    hold off;
    xlabel("Classification Accuracy (%)");
    ylabel("Number of Features");
    title("LGD 376 ch157 v2: Feature Accuracy Distribution (valid features)");

    % ★ ここで保存
histFile = fullfile(dirPref.rootDir, ...
    "hctsa_subtractMean_removeLineNoise","human","376", ...
    "lgd376_ch157_v2_featureAcc_hist.png");
exportgraphics(gcf, histFile, "Resolution", 300);
fprintf("Saved histogram figure to:\n  %s\n", histFile);

    %% 5. 結果を .mat に保存 (任意)
    outFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_v2.mat");
    save(outFile, "acc", "valid_features");
    fprintf("Saved accuracies to:\n  %s\n", outFile);
end


function acc = compute_nearest_median_accuracies(X, classLabels)
% compute_nearest_median_accuracies
%   X: nTS x nFeat の行列
%   classLabels: nTS x 1, 1 or 2
%   acc: nFeat x 1, 各featureの分類精度 [%]

    nFeat = size(X, 2);
    acc   = nan(nFeat, 1);

    awakeIdx = (classLabels == 1);
    unconIdx = (classLabels == 2);

    for f = 1:nFeat
        x_f = X(:, f);

        med_awake = median(x_f(awakeIdx));
        med_uncon = median(x_f(unconIdx));

        dist_awake = abs(x_f - med_awake);
        dist_uncon = abs(x_f - med_uncon);

        y_pred = ones(size(classLabels));
        y_pred(dist_uncon < dist_awake) = 2;

        acc(f) = mean(y_pred == classLabels);
    end

    acc = acc * 100;  % 0–1 → 0–100[%]
end
