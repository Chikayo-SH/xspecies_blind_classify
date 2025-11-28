% main_hctsa_1_init_macaqueGeorge_ch005_local.m
% Macaque George, ch5, 30x30 epoch 用 HCTSA 初期化

% 前提:
%   ・別途コマンドウィンドウで
%       cd('C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify')
%       setup_cosProject_local;
%       setup_paths_local;
%     を一度実行しておく（dirPref と hctsa パスが通っている状態）

%% 1) dirPref を取得
dirPref = getpref('cosProject','dirPref');   % struct (rootDir などを含む)

%% 2) 対象の条件
species = 'macaque';
subject = 'George';
channel = 5;   % ★ ここを追加：代表 frontal ch = 5
preprocessSuffix = '_subtractMean_removeLineNoise';

%% 3) HCTSA 入力ファイル
inputFile =  fullfile(dirPref.rootDir, ...
    'preprocessed','macaque','George', ...
    'HCTSA_macaqueGeorge_ch005_30x30.mat');

%% 4) HCTSA の出力ディレクトリとファイル名
save_dir = fullfile(dirPref.rootDir, ...
    ['hctsa' preprocessSuffix], species, subject);
if ~exist(save_dir,'dir')
    mkdir(save_dir);
end

hctsaFile = fullfile(save_dir, ...
    sprintf('%s_%s_ch%03d_hctsa.mat', species, subject, channel));
% 例: ...\hctsa_subtractMean_removeLineNoise\macaque\George\macaque_George_ch005_hctsa.mat

%% 5) TS_Init を実行
tic;
TS_Init(inputFile, 'hctsa', [false, false, false], hctsaFile);
toc;

disp(['HCTSA init complete: ' hctsaFile]);
