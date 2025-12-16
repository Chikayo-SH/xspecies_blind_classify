function repro_fig2A_human_ch157_minimal()
% Minimal Fig2A-like HCTSA barcode for human 376 ch157

    %% 1. Settings
    hctsaFile = "C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\hctsa_subtractMean_removeLineNoise\human\376\human_376_ch157_hctsa_v2.mat";

    % 条件ラベル
    condNames = ["awake","unconscious"];

    % Feature X / Y の CodeString（本番用）
    refCodeStrings_all = ["DN_rms", ...
        "MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1"];

    %% 2. Load HCTSA data
    S = load(hctsaFile, "TS_DataMat", "TS_Quality", "TimeSeries", "Operations", "valid_features");

    data = S.TS_DataMat;       % [epoch × feature]
    ts   = S.TimeSeries;       % table
    ops  = S.Operations;       % table

    % validFeatures の取得
    if isfield(S, "valid_features")
        validFeatures = find(S.valid_features);
    else
        validFeatures = getValidFeatures(data, S.TS_Quality);
    end

    % ★おもちゃテスト用：feature を 先頭50個に絞る
    validFeatures = intersect(validFeatures, 1:50);

    %% 2.5 refCodeStrings を「order_f に存在するものだけ」に絞る準備
    % （まずは仮で全部入れておいて、後でフィルタする）
    refCodeStrings = cellstr(refCodeStrings_all); % cell 配列にしておく

    %% 3. Feature ordering (order_f)
    order_f_sub = clusterFeatures(data(:, validFeatures));
    order_f     = validFeatures(order_f_sub);

    %% 3.5 refCodeStrings を order_f に存在するものだけに絞る
    opCodes = ops.CodeString;
    refCodeStrings_present = {};
    for ss = 1:numel(refCodeStrings)
        idx = find(strcmp(opCodes, refCodeStrings{ss}));
        if any(ismember(order_f, idx))
            refCodeStrings_present{end+1} = refCodeStrings{ss}; %#ok<AGROW>
        end
    end
    % 最終的に showHCTSAbarcodes に渡すのはこちら
    refCodeStrings = refCodeStrings_present;

    %% 4. Epoch ordering (order_e) for awake / unconscious
    data_all = data;
    ts_all   = ts;

    subjectEpochs{1} = (1:size(data_all, 1))';  % 1ファイル=1被験者

    % 条件ごとの epoch index
    condIdx = cell(1, numel(condNames));
    for icond = 1:numel(condNames)
        condIdx{icond} = find(getCondTrials(ts_all, condNames(icond)) == 1);
    end

    % epoch 間クラスタリング
    order_e_all = clusterFeatures(data_all(:, validFeatures)');

    % 各条件ごとの並び順
    order_e = cell(1, numel(condNames));
    for icond = 1:numel(condNames)
        theseEpochs = intersect(subjectEpochs{1}, condIdx{icond});
        [~, order_e{icond}] = sort(order_e_all(theseEpochs));
    end

    %% 5. Plot HCTSA barcode (Fig2A-like panel)
    f = figure("Position", [100 100 1000 400]);

    % ★refCodeStrings が空でも OK（showHCTSAbarcodes 側で for ループがスキップされる想定）
    showHCTSAbarcodes( ...
        data_all(subjectEpochs{1}, :), ...
        ts_all(subjectEpochs{1}, :), ...
        order_f, ...
        order_e, ...
        ops.CodeString, ...
        refCodeStrings ...
    );

    colormap(inferno);
    colorbar;
    title("Human 376 ch157 – HCTSA barcode (awake vs unconscious)");

end
