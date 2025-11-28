% main_hctsa_2_compute_macaqueGeorge_ch005_local.m
% Macaque George, ch5, 30x30 epoch 用 HCTSA feature 計算 (local)

% 前提：
%  - コマンドウィンドウ側で先に
%       cd("C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify");
%       setup_cosProject_local;
%       setup_paths_local;
%    を実行しておくこと。
%  - main_hctsa_1_init_macaqueGeorge_ch005_local により
%    macaque_George_ch005_hctsa.mat が初期化済みであること。

%% Settings
dirPref = getpref('cosProject','dirPref');   % setup_cosProject_local で設定済み

species = 'macaque';
subject = 'George';
channel = 5;
preprocessSuffix = '_subtractMean_removeLineNoise';

% HCTSA ファイルの場所（init で作ったやつ）
save_dir = fullfile(dirPref.rootDir, ['hctsa' preprocessSuffix], species, subject);
hctsaName = fullfile(save_dir, ...
    sprintf('%s_%s_ch%03d_hctsa.mat', species, subject, channel));

fprintf('TS_Compute target file: %s\n', hctsaName);

% 必要なら parallel を有効化する（ここではコメントのまま）
% nCores = feature('numcores');
% p = gcp('nocreate');
% if isempty(p)
%     parpool(nCores);
% end

%% （簡易版）parallel は使わず、直列で TS_Compute を実行
tic;
TS_Compute(false, [], [], [], hctsaName);  % 第1引数=falseで TS_DataMat を埋めるモード
t = toc;

disp(['TS_Compute finished for ' hctsaName ', elapsed time: ' num2str(t) ' s']);
