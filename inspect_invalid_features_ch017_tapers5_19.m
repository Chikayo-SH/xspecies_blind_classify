% inspect_invalid_features_ch017_tapers5_19.m

%% 1. ファイルを読み込み
cd("C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\hctsa_subtractMean_removeLineNoise\macaque\George");

file_v2 = "macaque_George_ch017_tapers5-19_hctsa_v2.mat";

S = load(file_v2, "TS_DataMat", "valid_features", "Operations");

TS  = S.TS_DataMat;          % 60 x 7710
vf  = S.valid_features(:)';  % 1 x 7710 logical
Ops = S.Operations;          % table

nTotal = numel(vf);
nValid = nnz(vf);
nInvalid = nTotal - nValid;

fprintf("ch017 (postProcess): valid = %d / %d, invalid = %d\n", ...
    nValid, nTotal, nInvalid);

%% 2. invalid feature の index と名前を取り出す
idx_invalid = find(~vf);                 % invalid な feature のID
Ops_invalid = Ops(idx_invalid, :);       % その行だけ抜き出し

% 代表的な最初の10個だけ表示
nShow = min(10, numel(idx_invalid));
fprintf("\n---- First %d invalid features (ID / Name / Keywords) ----\n", nShow);
for k = 1:nShow
    j = idx_invalid(k);
    fprintf("#%d: ID=%d, Name=%s, Keywords=%s\n", ...
        j, Ops.ID(j), string(Ops.Name(j)), string(Ops.Keywords(j)));
end

%% 3. 除外理由のざっくり分類（NaN / Inf / 定数など）
hasNaN = any(isnan(TS), 1);        % 列ごと NaN を含むか
hasInf = any(isinf(TS), 1);        % 列ごと Inf(±) を含むか
isConst = std(TS, 0, 1) == 0;      % 列ごと標準偏差ゼロ（完全な定数）

% invalid の中でそれぞれ何個あるか
nNaN_invalid   = nnz(~vf & hasNaN);
nInf_invalid   = nnz(~vf & ~hasNaN & hasInf);   % NaN ではないが Inf を含む
nConst_invalid = nnz(~vf & ~hasNaN & ~hasInf & isConst);

fprintf("\nInvalid breakdown (ch017):\n");
fprintf("  with NaN          : %4d\n", nNaN_invalid);
fprintf("  with Inf(+/-)     : %4d\n", nInf_invalid);
fprintf("  constant features : %4d\n", nConst_invalid);

% 必要なら「その他」（NaNでもInfでも定数でもないが弾かれている）があれば確認
nOther_invalid = nInvalid - (nNaN_invalid + nInf_invalid + nConst_invalid);
fprintf("  other (by getValidFeatures logic): %4d\n", nOther_invalid);
