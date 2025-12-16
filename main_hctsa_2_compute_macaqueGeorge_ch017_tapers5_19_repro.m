% main_hctsa_2_compute_macaqueGeorge_ch017_tapers5_19_repro.m
% Macaque George ch017, tapers[5 19], rezaLocal 用 TS_Compute スクリプト

% %% Settings
% addDirPrefs_COS;
% dirPref = getpref('cosProject','dirPref');  % rootDir は rezaLocal を指している前提
%% Settings

% ★ addDirPrefs_COS は使わず、自前で dirPref をセットする
try
    dirPref = getpref('cosProject','dirPref');
catch
    dirPref.rootDir = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal';
    dirPref.rawDir  = 'C:\Users\chikayo\lab\hctsa_proj\11_data_raw';
    setpref('cosProject','dirPref', dirPref);
end


species = 'macaque';
subject = 'George';

% HCTSA ファイルの保存先ディレクトリ
save_dir = fullfile(dirPref.rootDir, ...
    'hctsa_subtractMean_removeLineNoise', species, subject);

% 念のためディレクトリがあるか確認
if ~exist(save_dir, 'dir')
    error('save_dir does not exist: %s', save_dir);
end

%% 今回は ch017 だけを計算
tgtChannels = 17;

%% parallel 設定（ch005 版のまま）
% nCores = feature('numcores');
% p = gcp('nocreate');
% if isempty(p)
%     parpool(nCores);
% end
% add_toolbox;  % hctsa 用の path 追加（Daisuke コードのまま）

%% TS_Compute 実行
for ich = 1:numel(tgtChannels)
    disp([num2str(ich), '/' num2str(numel(tgtChannels))]);

    thisCh = tgtChannels(ich);

    % ch017, tapers5-19 用 HCTSA ファイル名
    hctsaName = fullfile(save_dir, ...
        'macaque_George_ch017_tapers5-19_hctsa.mat');

    if ~exist(hctsaName, 'file')
        error('HCTSA file not found: %s', hctsaName);
    end

    tic;
    TS_Compute(false, [], [], [], hctsaName);
    t = toc;

    fprintf('TS_Compute finished for ch%03d in %.2f seconds\n', thisCh, t);
end
