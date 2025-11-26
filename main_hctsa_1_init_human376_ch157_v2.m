% main_hctsa_1_init_human376_ch157.m
% Human 376, ch157, 30x30 epoch 用 HCTSA 初期化

% ここでは setup_* は呼ばない前提：
% コマンドウィンドウで先に
%   cd("...\00_repos"); setup_cosProject_local; setup_paths_local;
% を実行しておく。

% 1) dirPref を取得
dirPref = getpref('cosProject','dirPref');   % ← char

% 2) 対象の条件（全部 char にする）
species = 'human';
subject = '376';
channel = 157;
preprocessSuffix = '_subtractMean_removeLineNoise';

% 3) HCTSA 入力ファイル
inputFile = fullfile(dirPref.rootDir, ...
    'preprocessed', species, subject, ...
    'HCTSA_human376_ch157_30x30.mat');

% 4) HCTSA の出力ディレクトリとファイル名
save_dir = fullfile(dirPref.rootDir, ...
    ['hctsa' preprocessSuffix], species, subject);
if ~exist(save_dir,'dir')
    mkdir(save_dir);
end

hctsaFile = fullfile(save_dir, ...
    sprintf('%s_%s_ch%03d_hctsa_v2.mat', species, subject, channel));

% 5) TS_Init を実行（ここも char ベース）
tic;
TS_Init(inputFile, 'hctsa', [false, false, false], hctsaFile);
toc;

disp(['HCTSA init complete: ' hctsaFile]);
