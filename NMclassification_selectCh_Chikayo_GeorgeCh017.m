function repro_fig2A_human_ch157_v2()
% Fig2A-like HCTSA barcode for human 376 ch157 (clean version)

    %% 1. Settings
    hctsaFile = "C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\hctsa_subtractMean_removeLineNoise\human\376\human_376_ch157_hctsa_v2.mat";

    condNames      = ["awake","unconscious"];
    refCodeStrings = ["DN_rms", ...
        "MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1"];

    %% 2. Load HCTSA data
    S = load(hctsaFile, "TS_DataMat", "TS_Quality", "TimeSeries", "Operations", "valid_features");

    data = S.TS_DataMat;   % [epoch × feature]
    ts   = S.TimeSeries;
    ops  = S.Operations;

    % validFeatures
    if isfield(S, "valid_features")
        validFeatures = find(S.valid_features);
    else
        validFeatures = getValidFeatures(data, S.TS_Quality);
    end

    % ★おもちゃテストしたいときだけ有効化
    % validFeatures = intersect(validFeatures, 1:50);

    %% 3. Feature ordering (order_f)
    order_f_sub = clusterFeatures(data(:, validFeatures));
    order_f     = validFeatures(order_f_sub);

    %% 4. Epoch ordering (order_e) for awake / unconscious
    data_all = data;
    ts_all   = ts;

    % 1ファイル=1被験者として扱う
    subjectEpochs{1} = (1:size(data_all, 1))';

    % 条件ごとの epoch index
    condIdx = cell(1, numel(condNames));
    for icond = 1:numel(condNames)
        condIdx{icond} = find(getCondTrials(ts_all, condNames(icond)) == 1);
    end

    % epoch 間クラスタリング
    order_e_all = clusterFeatures(data_all(:, validFeatures)');

    % 各条件ごとの並び順（相対index）
    order_e = cell(1, numel(condNames));
    for icond = 1:numel(condNames)
        theseEpochs = intersect(subjectEpochs{1}, condIdx{icond});
        [~, order_e{icond}] = sort(order_e_all(theseEpochs));
    end

    %% 5. Call showHCTSAbarcodes and decorate
    fig = showHCTSAbarcodes( ...
        data_all(subjectEpochs{1}, :), ...
        ts_all(subjectEpochs{1}, :), ...
        order_f, ...
        order_e, ...
        ops.CodeString, ...
        cellstr(refCodeStrings) ...
    );

    % 図全体に inferno カラーマップとカラーバーを適用
    colormap(fig, inferno);
    mcolorbar;

    % 適当なaxesにタイトルを付ける（上側サブプロットを想定）
    ax = findall(fig, "Type", "axes");
    if ~isempty(ax)
        title(ax(1), "Human 376 ch157 – HCTSA barcode (awake vs unconscious)");
    end
end
