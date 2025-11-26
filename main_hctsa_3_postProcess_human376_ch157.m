% main_hctsa_3_postProcess_human376_ch157.m
% Human 376, ch157 用 HCTSA 後処理
%
% ・TS_Quality を使って TS_DataMat に NaN / Inf を戻す
% ・getValidFeatures で valid_features を決める
% ・BF_NormalizeMatrix('mixedSigmoid') で TS_Normalised を作成
%
% 前提：
%   cd("...\00_repos");
%   setup_cosProject_local;
%   setup_paths_local;
% を実行済みで、path に HCTSA が通っていること。

%% Settings
dirPref = getpref('cosProject','dirPref');   % setup_cosProject_local で設定済み

species = 'human';
subject = '376';
channel = 157;
preprocessSuffix = '_subtractMean_removeLineNoise';

% hctsa ファイルの場所（_1_init で作り、_2_compute で埋めたもの）
save_dir = fullfile(dirPref.rootDir, ['hctsa' preprocessSuffix], species, subject);
file_string = fullfile(save_dir, sprintf('%s_%s_ch%03d_hctsa.mat', species, subject, channel));

fprintf('Post-processing HCTSA file:\n  %s\n', file_string);

%% matfile を Writable で開く
tic;
hctsa = matfile(file_string, 'Writable', true);

TS_DataMat = hctsa.TS_DataMat;
TS_Quality = hctsa.TS_Quality;

% --- TS_Quality に応じて TS_DataMat に special 値を戻す ---
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

% 必要なら他のコードもここで確認できる：
% if any(TS_Quality(:) > 6)
%     disp('TS_Quality has unexpected codes:');
%     disp(unique(TS_Quality(:))');
% end

% 上書き保存
hctsa.TS_DataMat = TS_DataMat;
hctsa.TS_Quality = TS_Quality;

%% 有効 feature の判定 & 正規化

% 1) 有効 feature のインデックス（NaN/Inf なし＆非定数など）
valid_features = getValidFeatures(TS_DataMat);
hctsa.valid_features = valid_features;

fprintf('Valid features: %d / %d\n', nnz(valid_features), size(TS_DataMat,2));

% 2) mixedSigmoid で正規化
TS_Normalised = BF_NormalizeMatrix(TS_DataMat, 'mixedSigmoid');
hctsa.TS_Normalised = TS_Normalised;

toc;
fprintf('Post-processing complete for %s\n', file_string);
