% main_hctsa_1_init_macaqueGeorge_ch017_tapers5_19_repro.m
% Macaque George ch017, tapers[5 19], rezaLocal 用 HCTSA 初期化

%% 0. path 前提（セッション開始時に1回だけ）
% restoredefaultpath; rehash toolboxcache;
% addpath(genpath('C:\Users\chikayo\lab\hctsa_proj\00_repos\hctsa'));
% addpath(genpath('C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal'));

%% 1. 入力となる 30x30 のファイルを指定
inpFile = ...
  'C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\preprocessed\macaque\George\HCTSA_macaqueGeorge_ch017_tapers5-19_30x30.mat';

% sanity check 用（なくても OK）
S          = load(inpFile, 'TS_DataMat', 'TimeSeries');
tsData     = S.TS_DataMat;     % 60 x 200
TimeSeries = S.TimeSeries;     % table（ラベルやキーワード付き）


fprintf('Loaded INP_ts: TS_DataMat [%d %d], TimeSeries %d rows\n', ...
    size(tsData,1), size(tsData,2), height(TimeSeries));

%% 2. 出力する HCTSA ファイル名（ch017, tapers5-19）
outDir = ...
  'C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\hctsa_subtractMean_removeLineNoise\macaque\George';

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

outFile = fullfile(outDir, 'macaque_George_ch017_tapers5-19_hctsa.mat');

% %% 3. 使う operations 定義ファイル（公式 INP_mops / INP_ops）
% hctsaDir = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\hctsa';
% mopsFile = fullfile(hctsaDir, 'Database', 'INP_mops.txt');
% opsFile  = fullfile(hctsaDir, 'Database', 'INP_ops.txt');
% 
% featureSet = {mopsFile, opsFile};   % whatFeatureSet 用
% 
% 
% 
% %% 4. TS_Init を help に沿った 4 引数スタイルで実行
% beVocal = [1 1 1];  % 進捗をすべて表示（静かにしたければ [0 0 0]）
% 
% TS_Init(inpFile, featureSet, beVocal, outFile);

%% 3. feature セットの指定（ch005と同じく 'hctsa' を使う）
whatFeatureSet = 'hctsa';      % ★ 第2引数は 'hctsa' に統一
beVocal        = [false false false];  % ログを抑えたいなら ch005 に合わせて false,false,false

%% 4. TS_Init を ch005 と同じ呼び方で実行
TS_Init(inpFile, whatFeatureSet, beVocal, outFile);
