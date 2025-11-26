function plot_awake_raw_vs_preproc(data_raw, params, ...
                                   thisCh, save_dir, savedata_prefix)
% data_raw : time x trial x condition （condition 1 = awake）
% params   : spectral analysis parameters (Fs, tapers, pad, etc.)
% thisCh   : channel number (for title)
% save_dir : directory to save figure
% savedata_prefix : filename prefix (e.g., 'human_376_ch130')

    %------------------------------
    % 1. awake 条件だけ取り出す
    %------------------------------
    awake_data = data_raw(:,:,1);  % time x trial

    %------------------------------
    % 2. raw のスペクトル
    %   s_subtractMean = 0, s_lineNoise = 0
    %   → powers_before / after とも raw
    %------------------------------
    [~, ~, powers_raw, ~, faxis_raw, ~] = ...
        preprocessOneCh(awake_data, params, 0, 0);

    %------------------------------
    % 3. mean subtraction だけ
    %   s_subtractMean = 1, s_lineNoise = 0
    %   → powers_after が「mean subtraction 後」
    %------------------------------
    [~, ~, ~, powers_meanOnly, faxis_meanOnly, ~] = ...
        preprocessOneCh(awake_data, params, 1, 0);

    %------------------------------
    % 4. mean subtraction + line noise removal
    %   s_subtractMean = 1, s_lineNoise = 1
    %   → powers_after が「フル前処理後」
    %------------------------------
    [~, ~, ~, powers_full, faxis_full, ~] = ...
        preprocessOneCh(awake_data, params, 1, 1);

    % 周波数軸（基本どれも同じはず）
    faxis = faxis_raw;

    %------------------------------
    % 5. trial 平均 log(power) をとる
    %   powers_* は [freq x trial] を想定
    %------------------------------
    mean_logP_raw      = squeeze(mean(log(powers_raw),      2)); % freq x 1
    mean_logP_meanOnly = squeeze(mean(log(powers_meanOnly), 2));
    mean_logP_full     = squeeze(mean(log(powers_full),     2));

    %------------------------------
    % 6. 描画
    %------------------------------
    figure;
    hold on;
    plot(faxis, mean_logP_raw,      'r', 'DisplayName', 'raw');
    plot(faxis, mean_logP_meanOnly, 'b', 'DisplayName', 'raw + mean subtraction');
    plot(faxis, mean_logP_full,     'k', 'DisplayName', 'raw + mean subtraction + line noise removal');
    hold off;

    xlim([1 120]);
    xlabel('Frequency (Hz)');
    ylabel('log(power)');
    title(sprintf('Awake only (condition 1), ch %d', thisCh));
    legend('Location','best');
    grid on;

    %------------------------------
    % 7. 図を保存
    %------------------------------
    figFile = fullfile(save_dir, [savedata_prefix, '_awake_raw_mean_lineNoise.png']);
    try
        exportgraphics(gcf, figFile, "Resolution", 150);
    catch
        saveas(gcf, figFile);
    end

    close(gcf);
end
