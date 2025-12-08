function plot_datamatrix_human376_ch157_v2()
% plot_datamatrix_human376_ch157_v2
%   Human LGD 376 ch157 (30x30 epochs) の
%   ・左: 波形スタック図
%   ・右: TS_Normalised (valid features) ヒートマップ
%   を描画して PNG で保存する。
%
% 前提:
%   - HCTSA_human376_ch157_30x30.mat が preprocessed\human\376 にある
%   - human_376_ch157_hctsa_v2.mat に TS_Normalised, valid_features, TimeSeries がある
%   - cd("...\00_repos"); setup_cosProject_local; setup_paths_local; 済み

    %% パス設定
    dirPref = getpref("cosProject","dirPref");

    % HCTSA 入力 (波形) ファイル
    inputFile = fullfile(dirPref.rootDir, ...
        "preprocessed","human","376", ...
        "HCTSA_human376_ch157_30x30.mat");

    % HCTSA v2 本体ファイル
    hctsaFile = fullfile(dirPref.rootDir, ...
        "hctsa_subtractMean_removeLineNoise","human","376", ...
        "human_376_ch157_hctsa_v2.mat");

    %% 1. 波形データを読み込む (左パネル用)
    S_in  = load(inputFile, "TS_DataMat", "TimeSeries");
    TS_ep = S_in.TS_DataMat;          % 60 x 201
    TSinfo = S_in.TimeSeries;

    [nTS, nSamples] = size(TS_ep);

    % awake / unconscious の順に並べ替え
    keywords = string(TSinfo.Keywords);
    awakeIdx = find(keywords == "awake");
    unconIdx = find(keywords == "unconscious");
    orderIdx = [awakeIdx; unconIdx];        % 30 awake → 30 unconscious

    TS_ep_ord = TS_ep(orderIdx, :);         % 並べ替え後の 60 x 201

    % 時間軸 (ms)
    duration_ms = 200;
    t = linspace(0, duration_ms, nSamples);

    %% 2. feature ヒートマップ用データを読み込む
    S_h = load(hctsaFile, "TS_Normalised", "valid_features", "TimeSeries");
    TS_Norm       = S_h.TS_Normalised;             % 60 x 7770
    valid_features = logical(S_h.valid_features);  % 1 x 7770 logical
    TSinfo2       = S_h.TimeSeries;

    % 念のため、TimeSeries の順番が同じかチェック（違えばエラー）
    if ~isequal(string(TSinfo2.Name), string(TSinfo.Name))
        warning("TimeSeries.Name が HCTSA入力と v2 で異なります。行の順序に注意してください。");
    end

    % awake/unconscious の順に行を並べ替え
    keywords2 = string(TSinfo2.Keywords);
    awakeIdx2 = find(keywords2 == "awake");
    unconIdx2 = find(keywords2 == "unconscious");

    % 左パネルと同じ順番にする：下=awake, 上=unconscious
    orderIdx2 = [awakeIdx2; unconIdx2];
    
    TS_Norm_ord = TS_Norm(orderIdx2, valid_features);  % 60 x nValidFeat

    %% 3. 図を描く
    figure('Position', [100 100 1600 600]);  % 横長

    % --- 左: 波形 ---
    subplot(1,2,1);
    hold on;
    offset = 5 * std(TS_ep_ord(:));  % 簡易オフセット
    for i = 1:nTS
        plot(t, TS_ep_ord(i,:) + (i-1)*offset, 'k');
    end
    hold off;
    set(gca, 'YTick', [15*offset, 45*offset], ...
             'YTickLabel', ["awake", "unconscious"]);
    xlabel("Time (ms)");
    ylabel("Epoch");
    title("Human LGD 376 ch157, 200 ms epochs");

    % 並べ替え済み TS_Norm_ord (60 x nFeat)
    nTS = size(TS_Norm_ord, 1);
    
    % ローカルでの awake / unconscious の行インデックス
    awake_rows = 1:30;       % 下側
    uncon_rows = 31:60;      % 上側
    
    % uncon の平均を feature ごとに計算
    mu_uncon = mean(TS_Norm_ord(uncon_rows, :), 1);   % 1 x nFeat
    
    % uncon 平均を引いた差分
    TS_plot = TS_Norm_ord - mu_uncon;   % 60 x nFeat
    
    % % 対称なカラースケール用の範囲（robustに ±3SD とかでもOK）
    % v = 3;    % ざっくり ±3 で
    % カラースケール用に 5th / 95th percentile を計算
    vals   = TS_plot(:);
    cmin5  = prctile(vals, 5);   % 下位5%
    cmax95 = prctile(vals, 95);  % 上位5%を除いた上限

    cabs = max(abs(cmin5), abs(cmax95));  % 絶対値の大きい方
    subplot(1,2,2);
    imagesc(TS_plot, [-cabs cabs]);       % 中心0で対称なカラースケール
    
    % --- ヒートマップ ---
    %subplot(1,2,2);
    % imagesc(TS_plot);
    % imagesc(TS_plot, [cmin5 cmax95]);   % ★ ここが trimmed colorbar

    
    axis tight;
    set(gca, "YDir", "normal");
    
    colormap(redblue_cmap);
    % v = 3;
    % clim([-v v]);
    
    cb = colorbar;
    ylabel(cb, "normalized value (awake > uncon = red)");
    
    
    ylabel("Epochs");
    xlabel("Operations");
    set(gca, "YTick", [15, 45], ...
             "YTickLabel", ["awake", "unconscious"]);  % 下=awake, 上=unconscious
    title(sprintf("Data matrix (%d \\times features)_5–95%%trimmed", size(TS_plot,2)));
        % % カラーバーラベル
        % cb = colorbar;
        % ylabel(cb, "normalized value (awake > uncon = red)");
    
        %% 4. 図を保存
        outFile = fullfile(dirPref.rootDir, ...
            "hctsa_subtractMean_removeLineNoise","human","376", ...
            "datamatrix_human_LGD_376_ch157_v2_trimmed.png");
        exportgraphics(gcf, outFile, "Resolution", 300);
        fprintf("Saved datamatrix figure to:\n  %s\n", outFile);
    end


function cmap = redblue_cmap(m)
% 簡易 Red–Blue カラーマップ (blue -> white -> red)
    if nargin < 1
        m = 256;
    end
    m2 = floor(m/2);

    % blue -> white
    r1 = linspace(0, 1, m2)';
    g1 = linspace(0, 1, m2)';
    b1 = ones(m2, 1);

    % white -> red
    r2 = ones(m - m2, 1);
    g2 = linspace(1, 0, m - m2)';
    b2 = linspace(1, 0, m - m2)';

    cmap = [r1 g1 b1; r2 g2 b2];
end
