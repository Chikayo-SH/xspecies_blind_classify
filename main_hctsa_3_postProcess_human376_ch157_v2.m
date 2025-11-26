% main_hctsa_3_postProcess_human376_ch157_v2.m

dirPref = getpref('cosProject','dirPref');

species = 'human';
subject = '376';
channel = 157;
preprocessSuffix = '_subtractMean_removeLineNoise';

save_dir = fullfile(dirPref.rootDir, ['hctsa' preprocessSuffix], species, subject);
file_string = fullfile(save_dir, ...
    sprintf('%s_%s_ch%03d_hctsa_v2.mat', species, subject, channel));

fprintf('Post-processing HCTSA v2 file:\n  %s\n', file_string);

tic;
hctsa = matfile(file_string, 'Writable', true);

TS_DataMat = hctsa.TS_DataMat;
TS_Quality = hctsa.TS_Quality;

% --- TS_Quality に応じて TS_DataMat に special 値を戻す ---
TS_DataMat(TS_Quality == 1) = NaN;   % error
TS_DataMat(TS_Quality == 2) = NaN;   % special NaN
TS_DataMat(TS_Quality == 3) = Inf;   % +Inf
TS_DataMat(TS_Quality == 4) = -Inf;  % -Inf
TS_DataMat(TS_Quality == 5) = NaN;   % complex
TS_DataMat(TS_Quality == 6) = NaN;   % empty

hctsa.TS_DataMat = TS_DataMat;
hctsa.TS_Quality = TS_Quality;

% --- valid_features（NaN/Inf なし＋非定数） ---
valid_features = getValidFeatures(TS_DataMat);
hctsa.valid_features = valid_features;

fprintf('Valid features (v2): %d / %d\n', ...
    nnz(valid_features), size(TS_DataMat,2));

% --- mixedSigmoid で正規化（可視化用） ---
TS_Normalised = BF_NormalizeMatrix(TS_DataMat, 'mixedSigmoid');
hctsa.TS_Normalised = TS_Normalised;

toc;
fprintf('Post-processing v2 complete for %s\n', file_string);
