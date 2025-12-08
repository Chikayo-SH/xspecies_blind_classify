function plot_featureAcc_human376_ch157_cv_simple()
% Plot CDF and histogram of 10-fold CV accuracies
% computed by compute_feature_accuracies_human376_ch157_cv_simple.

    dirPref = getpref("cosProject", "dirPref");
    inFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_cv_simple.mat");

    S = load(inFile, "acc_cv_pct");
    acc_pct = S.acc_cv_pct;   % 0–100

    %% CDF
    figure;
    cdfplot(acc_pct);
    hold on;
    xline(50, "--r", "Chance", "LabelOrientation", "horizontal");
    hold off;

    xlim([0 100]);
    xticks(0:10:100);
    xlabel("classification accuracy (%)");
    ylabel("cumulative proportion of features");
    title("Human 376 ch157: 10-fold CV accuracies (CDF, simple)");

    outFile_cdf = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_cv_simple_CDF.png");
    exportgraphics(gcf, outFile_cdf, "Resolution", 300);

    %% Histogram
    figure;
    histogram(acc_pct, 20);
    hold on;
    xline(50, "--r", "Chance", "LabelOrientation", "horizontal");
    hold off;

    xlim([0 100]);
    xticks(0:10:100);
    xlabel("classification accuracy (%)");
    ylabel("number of features");
    title("Human 376 ch157: 10-fold CV accuracies (histogram, simple)");

    outFile_hist = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise", "human", "376", ...
        "human_376_ch157_featureAcc_cv_simple_hist.png");
    exportgraphics(gcf, outFile_hist, "Resolution", 300);

    fprintf("Saved CDF to:\n  %s\n", outFile_cdf);
    fprintf("Saved histogram to:\n  %s\n", outFile_hist);
end
