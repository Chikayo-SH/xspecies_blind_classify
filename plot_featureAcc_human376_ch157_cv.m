function plot_featureAcc_human376_ch157_cv()
% Plot CDF and histogram of 10-fold CV accuracies
% for human subject 376, channel 157, using maccuracy_validate.

    % 1. パスとファイルを指定
    dirPref = getpref("cosProject", "dirPref");
    inFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_cv.mat");

    S = load(inFile, "maccuracy_validate", "validFeatures");

    % 全 feature の fold 平均精度
    maccuracy_validate = S.maccuracy_validate;  % nFeat x 1
    validFeatures      = S.validFeatures;       % logical (nFeat x 1)

    % 有効 feature だけに絞る
    acc = maccuracy_validate(validFeatures);

    % --- スケール自動判定（0〜1 or 0〜100） ---
    maxAcc = max(acc);
    if maxAcc <= 1.0001
        acc_plot = acc * 100;   % 割合 → %
    else
        acc_plot = acc;         % すでに %
    end

    %% 2. CDF プロット
    figure;
    cdfplot(acc_plot);
    hold on;
    xline(50, "--r", "Chance", "LabelOrientation", "horizontal");
    hold off;

    xlim([0 100]);
    xticks(0:10:100);
    xlabel("classification accuracy (%)");
    ylabel("cumulative proportion of features");
    title("Human 376 ch157: 10-fold CV accuracies (CDF)");

    outFile_cdf = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_cv_CDF.png");
    exportgraphics(gcf, outFile_cdf, "Resolution", 300);

    %% 3. ヒストグラム
    figure;
    histogram(acc_plot, 20);
    hold on;
    xline(50, "--r", "Chance", "LabelOrientation", "horizontal");
    hold off;

    xlim([0 100]);
    xticks(0:10:100);
    xlabel("classification accuracy (%)");
    ylabel("number of features");
    title("Human 376 ch157: 10-fold CV accuracies (histogram)");

    outFile_hist = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_cv_hist.png");
    exportgraphics(gcf, outFile_hist, "Resolution", 300);

    fprintf("Saved CDF to:\n  %s\n", outFile_cdf);
    fprintf("Saved histogram to:\n  %s\n", outFile_hist);
end
