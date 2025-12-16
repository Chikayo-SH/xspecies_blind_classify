% main_hctsa_3_postProcess_macaqueGeorge_ch017_tapers5_19_local.m
% Macaque George ch017 用 HCTSA 後処理 (tapers[5 19])
%
% ・TS_Quality を使って TS_DataMat に NaN / Inf を戻す
% ・getValidFeatures で valid_features を決める
% ・BF_NormalizeMatrix('mixedSigmoid') で TS_Normalised を作成
% ・処理時間と MATLAB メモリ使用量をログとして残す
%
% 前提：
%   cd("...\00_repos\xspecies_blind_classify_rezaLocal");
%   setup_cosProject_local;
%   setup_paths_local;
% を実行済みで、path に HCTSA と getValidFeatures が通っていること。

%% Settings
dirPref = getpref('cosProject', 'dirPref');   % setup_cosProject_local で設定済み

species          = 'macaque';
subject          = 'George';
ch               = 17;           % ch017
preprocessSuffix = '_subtractMean_removeLineNoise';
taperLabel       = 'tapers5-19';

% 入出力ファイルの場所
base_dir = fullfile(dirPref.rootDir, ...
    ['hctsa' preprocessSuffix], species, subject);

orig_file = fullfile(base_dir, ...
    sprintf('%s_%s_ch%03d_%s_hctsa.mat', species, subject, ch, taperLabel));

v2_file = fullfile(base_dir, ...
    sprintf('%s_%s_ch%03d_%s_hctsa_v2.mat', species, subject, ch, taperLabel));

fprintf('Post-processing HCTSA file (v2 output):\n');
fprintf('  input : %s\n', orig_file);
fprintf('  output: %s\n', v2_file);

if ~exist(orig_file, 'file')
    error('Input HCTSA file not found: %s', orig_file);
end

%% 元ファイルを読み込み & 計測開始
memBefore   = memory;
memBeforeMB = memBefore.MemUsedMATLAB / 1e6;
tStart      = tic;

% 必要な変数だけ読んでもよいが、ここでは一括ロード
S = load(orig_file);

if ~isfield(S, 'TS_DataMat') || ~isfield(S, 'TS_Quality')
    error('TS_DataMat or TS_Quality not found in %s', orig_file);
end

TS_DataMat = S.TS_DataMat;
TS_Quality = S.TS_Quality;

%% TS_Quality に応じて TS_DataMat に special 値を戻す
% Fatal errors → NaN
TS_DataMat(TS_Quality == 1) = NaN;
% Special value NaN
TS_DataMat(TS_Quality == 2) = NaN;
% Special value +Inf
TS_DataMat(TS_Quality == 3) = Inf;
% Special value -Inf
TS_DataMat(TS_Quality == 4) = -Inf;
% Special value complex
TS_DataMat(TS_Quality == 5) = NaN;
% Special value empty
TS_DataMat(TS_Quality == 6) = NaN;

% 構造体 S を更新
S.TS_DataMat = TS_DataMat;
S.TS_Quality = TS_Quality;

%% 有効 feature の判定 & 正規化

% 1) 有効 feature のインデックス（NaN/Inf なし＆非定数など）
%    getValidFeatures は TS_DataMat を入力に取り、logical ベクトルを返す想定
[valid_features, nExclude, ids_per_stage] = getValidFeatures(TS_DataMat);
S.valid_features        = valid_features;
S.valid_features_detail = struct( ...
    'nExclude',        nExclude, ...
    'ids_per_stage',   ids_per_stage);

fprintf('Valid features (ch%03d): %d / %d\n', ...
    ch, nnz(valid_features), size(TS_DataMat, 2));

% 2) mixedSigmoid で正規化（全列に対して実行）
TS_Normalised = BF_NormalizeMatrix(TS_DataMat, 'mixedSigmoid');
S.TS_Normalised = TS_Normalised;

%% v2 ファイルとして保存（元ファイルはそのまま）
save(v2_file, '-struct', 'S', '-v7.3');

tElapsed   = toc(tStart);
memAfter   = memory;
memAfterMB = memAfter.MemUsedMATLAB / 1e6;
memDeltaMB = memAfterMB - memBeforeMB;

fprintf('Post-processing complete. Saved v2 file.\n');
fprintf('  elapsed time   : %.2f sec\n', tElapsed);
fprintf('  MemUsedMATLAB  : before = %.1f MB, after = %.1f MB (delta = %.1f MB)\n', ...
    memBeforeMB, memAfterMB, memDeltaMB);

%% ログファイルに追記
logFile = fullfile(base_dir, 'PostProcess_ch017_tapers5-19_log.txt');
fid = fopen(logFile, 'a');
if fid > 0
    fprintf(fid, '%s ch%03d postProcess tapers[5 19]\n', ...
        datestr(now, 'yyyy-mm-dd HH:MM:SS'), ch);
    fprintf(fid, '  orig_file: %s\n', orig_file);
    fprintf(fid, '  v2_file  : %s\n', v2_file);
    fprintf(fid, '  elapsed  : %.2f sec\n', tElapsed);
    fprintf(fid, '  MemUsedMATLAB: before = %.1f MB, after = %.1f MB (delta = %.1f MB)\n', ...
        memBeforeMB, memAfterMB, memDeltaMB);
    fprintf(fid, '  valid features: %d / %d\n\n', ...
        nnz(valid_features), size(TS_DataMat,2));
    fclose(fid);
end
