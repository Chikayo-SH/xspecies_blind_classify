% compare_valid_features_ch005_vs_ch017_byID.m

%% 1. v2 ファイルをロード
cd("C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\hctsa_subtractMean_removeLineNoise\macaque\George");

file5_v2   = "macaque_George_ch005_hctsa_v2.mat";
file17_v2  = "macaque_George_ch017_tapers5-19_hctsa_v2.mat";

S5   = load(file5_v2,  "TS_DataMat", "valid_features", "Operations");
S17  = load(file17_v2, "TS_DataMat", "valid_features", "Operations");

TS5   = S5.TS_DataMat;           % 60 x 7770
vf5   = S5.valid_features(:)';   % 1 x 7770
Ops5  = S5.Operations;
ID5   = Ops5.ID;

TS17  = S17.TS_DataMat;          % 60 x 7710
vf17  = S17.valid_features(:)';  % 1 x 7710
Ops17 = S17.Operations;
ID17  = Ops17.ID;

%% 2. IDベースで共通 / 片側だけを分類
IDs_common   = intersect(ID5, ID17);   % 両方に存在する feature
IDs_only5    = setdiff(ID5, ID17);     % ch005 のみに存在
IDs_only17   = setdiff(ID17, ID5);     % ch017 のみに存在

fprintf("Total features ch005: %d\n", numel(ID5));
fprintf("Total features ch017: %d\n", numel(ID17));
fprintf("Common features     : %d\n", numel(IDs_common));
fprintf("Only in ch005       : %d\n", numel(IDs_only5));
fprintf("Only in ch017       : %d\n\n", numel(IDs_only17));

%% 3. 共通IDを index にマッピング
[~, loc5]  = ismember(IDs_common, ID5);   % IDs_common → Ops5 の行 index
[~, loc17] = ismember(IDs_common, ID17);  % IDs_common → Ops17 の行 index

% 念のためチェック
if any(loc5 == 0) || any(loc17 == 0)
    error("Some common IDs could not be mapped back to indices.");
end

vf5_common  = vf5(loc5);      % 共通featureにおける ch005 の validフラグ
vf17_common = vf17(loc17);    % 共通featureにおける ch017 の validフラグ

%% 4. パターンごとのカウント

vf_common       = vf5_common & vf17_common;
vf_only005      = vf5_common & ~vf17_common;   % ch005でのみvalid
vf_only017      = vf17_common & ~vf5_common;   % ch017でのみvalid
vf_bothInvalid  = ~vf5_common & ~vf17_common;  % 両方invalid

nCommon      = numel(IDs_common);
nCommonValid = nnz(vf_common);
nOnly005     = nnz(vf_only005);
nOnly017     = nnz(vf_only017);
nBothInvalid = nnz(vf_bothInvalid);

fprintf("Among common features (%d):\n", nCommon);
fprintf("  valid in both        : %d\n", nCommonValid);
fprintf("  valid only in ch005  : %d\n", nOnly005);
fprintf("  valid only in ch017  : %d\n", nOnly017);
fprintf("  invalid in both      : %d\n\n", nBothInvalid);

%% 5. 実際に「ch005でのみvalid（ch017ではinvalid）」なfeature一覧

IDs_only005_valid = IDs_common(vf_only005);   % ID のリスト
mask_only005      = ismember(ID5, IDs_only005_valid);
Ops_only005       = Ops5(mask_only005, :);

nList = height(Ops_only005);
fprintf("Features valid in ch005 but invalid in ch017 (common IDs): %d\n", nList);

% 代表的な最初の10件だけ表示
nShow = min(10, nList);
fprintf("\n---- First %d features: valid ch005 / invalid ch017 ----\n", nShow);
for k = 1:nShow
    j = find(mask_only005, 1, 'first') + (k-1);  % シンプルに先頭n行を取る
    fprintf("#%d: ID=%d, Name=%s, Keywords=%s\n", ...
        j, Ops_only005.ID(k), string(Ops_only005.Name(k)), string(Ops_only005.Keywords(k)));
end

%% 6. CSV に書き出して詳細を外部で見る
outCsv = "ch005_valid_ch017_invalid_commonFeatures.csv";
writetable(Ops_only005, outCsv);
fprintf("\nExported full list to %s\n", outCsv);
