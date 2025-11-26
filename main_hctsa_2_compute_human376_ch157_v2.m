% main_hctsa_2_compute_human376_ch157.m
% Human 376, ch157, 30x30 epoch 用 HCTSA feature 計算 (local)

% 前提：
%  - コマンドウィンドウ側で先に
%       cd("...\00_repos");
%       setup_cosProject_local;
%       setup_paths_local;
%    を実行しておくこと。

%% Settings
dirPref = getpref('cosProject','dirPref');   % setup_cosProject_local で設定済み

species = 'human';
subject = '376';
channel = 157;
preprocessSuffix = '_subtractMean_removeLineNoise';

% HCTSA ファイルの場所（init で作ったやつ）
save_dir = fullfile(dirPref.rootDir, ['hctsa' preprocessSuffix], species, subject);
hctsaName = fullfile(save_dir, ...
    sprintf('%s_%s_ch%03d_hctsa_v2.mat', species, subject, channel));

% %% parallel 設定（元のコードを踏襲）
% nCores = feature('numcores');
% p = gcp('nocreate');
% if isempty(p)
%     parpool(nCores);
% end

%% （簡易版）parallel は使わず、直列で TS_Compute を実行

% HCTSA の toolbox パスを追加
%add_toolbox;  % 必要ならそのまま利用

tic;
TS_Compute(false, [], [], [], hctsaName);  % ★ 第1引数を false に
t = toc;

disp(['TS_Compute finished for ' hctsaName ', elapsed time: ' num2str(t) ' s']);

