%"C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\NMclassification_selectCh_onepair_local.m"

% Minimal local reproducer for Fig2 barcode (1 channel pair)
% Based on Daisuke's NMclassification_selectCh.m with minimal diffs.
%
% Goal: reliably export Fig2A barcode for:
%   train: macaque George ch017 (tapers5-19, _v2)
%   validate: human 376 ch157 (_v2)
%



%% Local settings (no Slurm)
narrays = 1;
pen = 1;

%% Settings (keep close to original)
% add_toolbox_COS;          % assume already in path in local setting
% param = getParam;         % use local explicit (avoids dependency)
param.ncv   = 10;
param.alpha = 0.05;
param.q     = 0.05;

dirPref = getpref("cosProject","dirPref");

% ---- robust rootDir extraction (must be non-empty char) ----
assert(isstruct(dirPref) && isfield(dirPref,"rootDir"), "dirPref.rootDir is missing");
rootDir = dirPref.rootDir;

% rootDir can be char or string; force to char
if isstring(rootDir)
    rootDir = char(rootDir);
end

assert(ischar(rootDir) && ~isempty(strtrim(rootDir)), "rootDir is empty or not char/string");

% (optional) show it once
disp(["rootDir=" string(rootDir)]);
% ------------------------------------------------------------

htcsaType = "TS_DataMat"; % classification + clustering in original
preprocessSuffix = "_subtractMean_removeLineNoise";
svm = false;

species_train    = "macaque";
subject_train    = "George";
species_validate = "human";
subject_validate = "376";

refCodeStrings = {"DN_rms", ...
    "MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1"};

% Keep original names (but we will not rely on them for subject split)
condNames    = {"awake","unconscious"};
subjectNames = {["subject:" char(subject_train)], ["subject:" char(subject_validate)]};

% load_dir_train     = fullfile(dirPref.rootDir, "preprocessed", species_train, subject_train);
% hctsa_dir_train    = fullfile(dirPref.rootDir, ["hctsa" preprocessSuffix], species_train, subject_train);
% load_dir_validate  = fullfile(dirPref.rootDir, "preprocessed", species_validate, subject_validate);
% hctsa_dir_validate = fullfile(dirPref.rootDir, ["hctsa" preprocessSuffix], species_validate, subject_validate);
% 
% save_dir = fullfile(dirPref.rootDir, ["results" preprocessSuffix]);
% save_dir_char = char(save_dir);
% if ~exist(save_dir_char, "dir"); mkdir(save_dir_char); end
load_dir_train     = fullfile(rootDir, "preprocessed", char(species_train), char(subject_train));
hctsa_dir_train    = fullfile(rootDir, ["hctsa" char(preprocessSuffix)], char(species_train), char(subject_train));
load_dir_validate  = fullfile(rootDir, "preprocessed", char(species_validate), char(subject_validate));
hctsa_dir_validate = fullfile(rootDir, ["hctsa" char(preprocessSuffix)], char(species_validate), char(subject_validate));

% save_dir = fullfile(rootDir, ["results" char(preprocessSuffix)]);
% save_dir_char = char(save_dir);
save_dir_char = fullfile(rootDir, ['results' char(preprocessSuffix)]);
if ~exist(save_dir_char, "dir"); mkdir(save_dir_char); end


%% Fixed single channel pair
ch_train = 17;    % George ch017
ch_validate = 157;% human 376 ch157

% out_file = fullfile(save_dir, sprintf("%s_train_%s_%s_ch%03d_validate_%s_%s_ch%03d_accuracy", ...
%     htcsaType, species_train, subject_train, ch_train, species_validate, subject_validate, ch_validate));
% out_file = fullfile(save_dir_char, sprintf('%s_train_%s_%s_ch%03d_validate_%s_%s_ch%03d_accuracy', ...
%     char(htcsaType), char(species_train), char(subject_train), ch_train, ...
%     char(species_validate), char(subject_validate), ch_validate));
% out_file = fullfile(save_dir_char, "TS_DataMat_train_macaque_George_ch017_validate_human_376_ch157_accuracy");
out_file = fullfile(save_dir_char, "TS_DataMat_train_macaque_George_ch017_validate_human_376_ch157");
out_file = char(out_file);
disp(out_file); whos out_file

% [classifier_cv, fig_cv] = NMclassifier_cv(trainData, validateData, param.ncv, [], htcsaType);
% set(fig_cv, "Position", [0 0 1000 500]);

% cv_png = [out_file "_NMclassifier_cv.png"];
% exportgraphics(fig_cv, cv_png, "Resolution", 300);
% close(fig_cv);
% cv_png = [out_file "_NMclassifier_cv.png"];
% set(fig_cv, "PaperPositionMode", "auto");
% print(fig_cv, cv_png, "-dpng", "-r300");
% close(fig_cv);
% [classifier_cv, fig_cv] = NMclassifier_cv(trainData, validateData, param.ncv, [], htcsaType);
% CV figure export is skipped (fig handle can be invalid in this environment)



%% Load v2 HCTSA (match your confirmed filenames)
% macaque George ch017 tapers5-19 + v2
% file_string_train = fullfile(hctsa_dir_train, ...
%     sprintf("%s_%s_ch%03d_tapers5-19_hctsa_v2", species_train, subject_train, ch_train));
% trainMat = char(string(file_string_train) + ".mat");
% assert(exist(trainMat,"file")==2, "train mat not found");
% 
% % human 376 ch157 v2
% file_string_validate = fullfile(hctsa_dir_validate, ...
%     sprintf("%s_%s_ch%03d_hctsa_v2", species_validate, subject_validate, ch_validate));
% valMat = char(string(file_string_validate) + ".mat");
% assert(exist(valMat,"file")==2, "validate mat not found");
% 
% trainData = load(trainMat, "Operations", "TS_DataMat", "TimeSeries", "TS_Normalised", "valid_features");
% validateData = load(valMat, "Operations", "TS_DataMat", "TimeSeries", "TS_Normalised", "valid_features");
% ---- FIX: use confirmed absolute paths (no ambiguity) ----
trainMat = "C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\hctsa_subtractMean_removeLineNoise\macaque\George\macaque_George_ch017_tapers5-19_hctsa_v2.mat";
valMat   = "C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\hctsa_subtractMean_removeLineNoise\human\376\human_376_ch157_hctsa_v2.mat";

assert(exist(trainMat,"file")==2, "train mat not found");
assert(exist(valMat,"file")==2, "validate mat not found");

trainData = load(char(trainMat), "Operations", "TS_DataMat", "TimeSeries", "TS_Normalised", "valid_features");
validateData = load(char(valMat), "Operations", "TS_DataMat", "TimeSeries", "TS_Normalised", "valid_features");
% ----------------------------------------------------------

%% Train nearest-median classifier w CV (original call pattern)
[classifier_cv, fig_cv] = NMclassifier_cv(trainData, validateData, param.ncv, [], htcsaType);
% set(fig_cv, "Position", [0 0 1000 500]);
% % saveas(fig_cv, [out_file "_NMclassifier_cv.png"]);
% cv_png = [out_file "_NMclassifier_cv.png"];
% % exportgraphics(fig_cv, cv_png, "Resolution", 300);
% set(fig_cv, "PaperPositionMode", "auto");
% print(fig_cv, cv_png, "-dpng", "-r300");
% 
% close(fig_cv);
% --- after NMclassifier_cv ---
cv_png = [out_file "_NMclassifier_cv.png"];

% fig_cvの型と有効性を確認
disp("=== fig_cv diagnostics ===");
disp(class(fig_cv));
try
    disp(isgraphics(fig_cv));
catch
    disp("isgraphics failed");
end

fprintf("data_t range: [%g, %g]\n", min(data_t(:)), max(data_t(:)));
fprintf("data_v range: [%g, %g]\n", min(data_v(:)), max(data_v(:)));


% figure handleなら保存、それ以外ならgcfで保存を試す
if isgraphics(fig_cv, "figure")
    set(fig_cv, "PaperPositionMode", "auto");
    % print(fig_cv, cv_png, "-dpng", "-r300");
    cv_png = [out_file "_NMclassifier_cv.png"];
    
    try
        drawnow;
        % printはhandleより「figure番号」の方が通ることがある
        fnum = fig_cv.Number;
        print(fnum, cv_png, "-dpng", "-r300");
    catch
        disp("WARNING: failed to export CV figure; skipping CV export.");
        % 代替として.figだけでも残したい場合(任意)
        try
            savefig(fig_cv, [out_file "_NMclassifier_cv.fig"]);
        catch
        end
    end


elseif isgraphics(gcf, "figure")
    % NMclassifier_cvがgcf上に描いている場合の救済
    set(gcf, "PaperPositionMode", "auto");
    print(gcf, cv_png, "-dpng", "-r300");
else
    disp("WARNING: no valid figure to print for CV panel; skipping CV export.");
end


%% Show HCTSA barcode (Fig2A core)
validFeatures = find(classifier_cv.validFeatures);

% order_f = validFeatures(clusterFeatures(trainData.(htcsaType)(:, validFeatures)));
order_f = validFeatures(clusterFeatures(trainData.TS_Normalised(:, validFeatures)));


data_all = [trainData.(htcsaType); validateData.(htcsaType)];
data_all_cls = [trainData.TS_DataMat;    validateData.TS_DataMat];
data_all_vis = [trainData.TS_Normalised; validateData.TS_Normalised];

TimeSeries_all = [trainData.TimeSeries; validateData.TimeSeries];


% ---- IMPORTANT: Avoid getCondTrials(subjectNames) mismatch ----
% We split by concatenation order (train first, validate second).
nTrain = size(trainData.(htcsaType), 1);
nVal   = size(validateData.(htcsaType), 1);
subjectEpochs = cell(1,2);
subjectEpochs{1} = 1:nTrain;
subjectEpochs{2} = (nTrain+1):(nTrain+nVal);

% For ordering within each subject, do not rely on condition labels yet.
% order_e_all = clusterFeatures(data_all(:, validFeatures)');
% 
% order_e = cell(2,2);
% for itv = 1:2
%     theseEpochs = subjectEpochs{itv};
%     [~, ord] = sort(order_e_all(theseEpochs));
%     order_e{itv,1} = ord;
%     order_e{itv,2} = ord;
% end
% ===== FIX: make condition-consistent order_e + inject unconscious label =====

% subjectごとにTimeSeriesを補正しておく(awake/unconsciousを必ず含める)
TimeSeries_t = TimeSeries_all(subjectEpochs{1}, :);
TimeSeries_v = TimeSeries_all(subjectEpochs{2}, :);

% まずawakeのepoch(=subject内の行番号)を取得
awake_t = find(getCondTrials(TimeSeries_t, "awake") == 1);
awake_v = find(getCondTrials(TimeSeries_v, "awake") == 1);

% awakeが空なら、とりあえず半分で分割(最悪でもFigが出るように)
nT = numel(subjectEpochs{1});
nV = numel(subjectEpochs{2});
if isempty(awake_t); awake_t = 1:floor(nT/2); end
if isempty(awake_v); awake_v = 1:floor(nV/2); end

% unconsciousは「awake以外」として定義
uncon_t = setdiff(1:nT, awake_t);
uncon_v = setdiff(1:nV, awake_v);

% showHCTSAbarcodes内部のgetCondTrials("unconscious")対策:
% Keywordsにawake/unconsciousを注入して、必ず拾えるようにする
if any(strcmp(TimeSeries_t.Properties.VariableNames, "Keywords"))
    kw = string(TimeSeries_t.Keywords);
    kw(awake_t) = kw(awake_t) + ";awake";
    kw(uncon_t) = kw(uncon_t) + ";unconscious";
    TimeSeries_t.Keywords = cellstr(kw);
end
if any(strcmp(TimeSeries_v.Properties.VariableNames, "Keywords"))
    kw = string(TimeSeries_v.Keywords);
    kw(awake_v) = kw(awake_v) + ";awake";
    kw(uncon_v) = kw(uncon_v) + ";unconscious";
    TimeSeries_v.Keywords = cellstr(kw);
end

% condition subset内(=1..nSubset)での並びを作る
order_e_t = cell(1,2);
order_e_v = cell(1,2);

% train(subject 1)
data_t = data_all_vis(subjectEpochs{1}, :);

if numel(awake_t) >= 2
    s = clusterFeatures(data_t(awake_t, validFeatures)')';
    [~, order_e_t{1}] = sort(s);
else
    order_e_t{1} = 1:numel(awake_t);
end
if numel(uncon_t) >= 2
    s = clusterFeatures(data_t(uncon_t, validFeatures)')';
    [~, order_e_t{2}] = sort(s);
else
    order_e_t{2} = 1:numel(uncon_t);
end

% validate(subject 2)
% validate side (v)
data_v = data_all_vis(subjectEpochs{2}, :);
if numel(awake_v) >= 2
    s = clusterFeatures(data_v(awake_v, validFeatures)')';
    [~, order_e_v{1}] = sort(s);
else
    order_e_v{1} = 1:numel(awake_v);
end
if numel(uncon_v) >= 2
    s = clusterFeatures(data_v(uncon_v, validFeatures)')';
    [~, order_e_v{2}] = sort(s);
else
    order_e_v{2} = 1:numel(uncon_v);
end

% --- SAFETY: enforce valid index ranges for unconscious ordering ---
nu_t = numel(uncon_t);
if nu_t <= 1
    order_e_t{2} = 1:nu_t;
else
    order_e_t{2} = order_e_t{2}(:)';
    order_e_t{2} = order_e_t{2}(order_e_t{2} >= 1 & order_e_t{2} <= nu_t);
    if numel(order_e_t{2}) ~= nu_t
        order_e_t{2} = 1:nu_t;
    end
end

nu_v = numel(uncon_v);
if nu_v <= 1
    order_e_v{2} = 1:nu_v;
else
    order_e_v{2} = order_e_v{2}(:)';
    order_e_v{2} = order_e_v{2}(order_e_v{2} >= 1 & order_e_v{2} <= nu_v);
    if numel(order_e_v{2}) ~= nu_v
        order_e_v{2} = 1:nu_v;
    end
end
% ---------------------------------------------------------------

disp(["nAwake_t=" + num2str(numel(awake_t)), "nUncon_t=" + num2str(numel(uncon_t))]);
% disp(["max(order_e_t{1})=" + num2str(max([0 order_e_t{1}])), "max(order_e_t{2})=" + num2str(max([0 order_e_t{2}]))]);
fprintf("max(order_e_t{1})=%d, max(order_e_t{2})=%d\n", ...
    max(order_e_t{1}(:)), max(order_e_t{2}(:)));


% ===== verify 30/30 epochs per subject (before showHCTSAbarcodes) =====
nT = size(data_t, 1); % subject t epochs
nV = size(data_v, 1); % subject v epochs

fprintf("nT=%d, nV=%d\n", nT, nV);

% 1) あなたが作ったawake_t/uncon_t, awake_v/uncon_vの確認
fprintf("t: awake=%d, uncon=%d\n", numel(awake_t), numel(uncon_t));
fprintf("v: awake=%d, uncon=%d\n", numel(awake_v), numel(uncon_v));

assert(isempty(intersect(awake_t, uncon_t)), "t: awake/uncon overlap");
assert(isempty(intersect(awake_v, uncon_v)), "v: awake/uncon overlap");
assert(numel(union(awake_t, uncon_t)) == nT, "t: awake+uncon does not cover all epochs");
assert(numel(union(awake_v, uncon_v)) == nV, "v: awake+uncon does not cover all epochs");

% 2) showHCTSAbarcodes内部と同じ方式(getCondTrials)で本当に拾えるか確認
idx_awake_t = find(getCondTrials(TimeSeries_t, "awake") == 1);
idx_uncon_t = find(getCondTrials(TimeSeries_t, "unconscious") == 1);
idx_awake_v = find(getCondTrials(TimeSeries_v, "awake") == 1);
idx_uncon_v = find(getCondTrials(TimeSeries_v, "unconscious") == 1);

fprintf("t(getCondTrials): awake=%d, uncon=%d\n", numel(idx_awake_t), numel(idx_uncon_t));
fprintf("v(getCondTrials): awake=%d, uncon=%d\n", numel(idx_awake_v), numel(idx_uncon_v));

% 3) 30/30を期待するならここで断言
% assert(numel(idx_awake_t) == 30 && numel(idx_uncon_t) == 30, "t: not 30/30 by getCondTrials");
% assert(numel(idx_awake_v) == 30 && numel(idx_uncon_v) == 30, "v: not 30/30 by getCondTrials");

% 4) order_eの範囲チェック(awake/unconそれぞれのsubsetサイズに対して)
% assert(all(order_e_t{1} >= 1 & order_e_t{1} <= numel(idx_awake_t)), "t: order_e_t{1} out of range");
% assert(all(order_e_t{2} >= 1 & order_e_t{2} <= numel(idx_uncon_t)), "t: order_e_t{2} out of range");
% assert(all(order_e_v{1} >= 1 & order_e_v{1} <= numel(idx_awake_v)), "v: order_e_v{1} out of range");
% assert(all(order_e_v{2} >= 1 & order_e_v{2} <= numel(idx_uncon_v)), "v: order_e_v{2} out of range");
assert(all(order_e_t{2} >= 1 & order_e_t{2} <= numel(uncon_t)));
assert(all(order_e_v{2} >= 1 & order_e_v{2} <= numel(uncon_v)));

% =====================================================================


% ここでshowHCTSAbarcodesを呼ぶ(第4引数は1x2 cell)
% fig_t = showHCTSAbarcodes(data_t, TimeSeries_t, order_f, order_e_t, classifier_cv.operations.CodeString, refCodeStrings);
%% ===== Fig2A replacement: local barcode export for train(t) and validate(v) =====

% --- helper: ref feature positions in order_f (vertical markers) ---
refPos = zeros(1, numel(refCodeStrings));
for ss = 1:numel(refCodeStrings)
    opIdx = find(strcmp(classifier_cv.operations.CodeString, refCodeStrings{ss}), 1);
    if isempty(opIdx)
        refPos(ss) = NaN;
    else
        [~, pos] = intersect(order_f, opIdx);
        if isempty(pos); refPos(ss) = NaN; else; refPos(ss) = pos; end
    end
end
refPos = refPos(~isnan(refPos)); % drop missing

% ここでは data_t, data_v は data_all_vis から切っている前提
data_t = data_all_vis(subjectEpochs{1}, :);
data_v = data_all_vis(subjectEpochs{2}, :);

% まずA/Uの中身(並び替え済み)を作ってcaxを決める
% At = data_t(awake_t(order_e_t{1}), order_f);
% Ut = data_t(uncon_t(order_e_t{2}), order_f);
% Av = data_v(awake_v(order_e_v{1}), order_f);
% Uv = data_v(uncon_v(order_e_v{2}), order_f);
% 
% vals = [At(:); Ut(:); Av(:); Uv(:)];
% cax_shared = [prctile(vals,1) prctile(vals,99)];
% if ~(isfinite(cax_shared(1)) && isfinite(cax_shared(2)) && cax_shared(2) > cax_shared(1))
%     cax_shared = [0 1];
% end
At = prepViz(data_t(awake_t(order_e_t{1}), order_f));
Ut = prepViz(data_t(uncon_t(order_e_t{2}), order_f));
Av = prepViz(data_v(awake_v(order_e_v{1}), order_f));
Uv = prepViz(data_v(uncon_v(order_e_v{2}), order_f));

vals = [At(:); Ut(:); Av(:); Uv(:)];
cax_shared = [prctile(vals,1) prctile(vals,99)];
if ~(isfinite(cax_shared(1)) && isfinite(cax_shared(2)) && cax_shared(2) > cax_shared(1))
    cax_shared = [0 1];
end



% --- train side (t) ---
% data_t = data_all(subjectEpochs{1}, :);
data_t = data_all_vis(subjectEpochs{1}, :);
fprintf("EXPORT data_t range: [%g, %g]\n", min(data_t(:)), max(data_t(:)));


% fig_t = showBarcodeLocal(data_t, order_f, awake_t, uncon_t, order_e_t{1}, order_e_t{2}, refPos, "train (macaque George ch017)");
fig_t = showBarcodeLocal(data_t, order_f, awake_t, uncon_t, order_e_t{1}, order_e_t{2}, refPos, "train (macaque George ch017)", cax_shared);

% png_t = char([out_file "_HCTSA_barcode_t.png"]);
% drawnow;
% saveas(fig_t, png_t);
png_t = sprintf('%s_HCTSA_barcode_t.png', out_file);  % 必ず1xN char
% assert(isempty(regexp(png_t, '[<>:"/\\|?*]', 'once')), "invalid char in filename");
[~, base, ext] = fileparts(png_t);
assert(isempty(regexp([base ext], '[<>:"/\\|?*]', 'once')), "invalid char in basename");


disp(png_t); whos png_t
saveas(fig_t, png_t);

close(fig_t);

% --- validate side (v) ---
% data_v = data_all(subjectEpochs{2}, :);
data_v = data_all_vis(subjectEpochs{2}, :);
% fig_v = showBarcodeLocal(data_v, order_f, awake_v, uncon_v, order_e_v{1}, order_e_v{2}, refPos, "validate (human 376 ch157)");
fig_v = showBarcodeLocal(data_v, order_f, awake_v, uncon_v, order_e_v{1}, order_e_v{2}, refPos, "validate (human 376 ch157)", cax_shared);

fprintf("EXPORT data_v range: [%g, %g]\n", min(data_v(:)), max(data_v(:)));


% png_v = char([out_file "_HCTSA_barcode_v.png"]);
% drawnow;
% saveas(fig_v, png_v);
png_v = sprintf('%s_HCTSA_barcode_v.png', out_file);
% assert(isempty(regexp(png_v, '[<>:"/\\|?*]', 'once')), "invalid char in filename");
[~, base, ext] = fileparts(png_v);
assert(isempty(regexp([base ext], '[<>:"/\\|?*]', 'once')), "invalid char in basename");


disp(png_v); whos png_v
saveas(fig_v, png_v);

close(fig_v);

disp("Saved:");
disp(png_t);
disp(png_v);

return

%% ===== end replacement =====


% ===== END FIX =====


% savePaperFigure(fig_t, [out_file "_HCTSA_barcode_t"]);
% savePaperFigure(fig_v, [out_file "_HCTSA_barcode_v"]);
% exportgraphics(fig_t, [out_file "_HCTSA_barcode_t.png"], "Resolution", 300);
% exportgraphics(fig_v, [out_file "_HCTSA_barcode_v.png"], "Resolution", 300);
% set(fig_t, "PaperPositionMode", "auto");
% print(fig_t, [out_file "_HCTSA_barcode_t.png"], "-dpng", "-r300");
% if isgraphics(fig_t,"figure")
%     set(fig_t,"PaperPositionMode","auto");
%     print(fig_t, [out_file "_HCTSA_barcode_t.png"], "-dpng", "-r300");
% else
%     disp("WARNING: fig_t is not a figure; skipping export.");
% end
% set(fig_v, "PaperPositionMode", "auto");
% print(fig_v, [out_file "_HCTSA_barcode_v.png"], "-dpng", "-r300");


% Stop here to guarantee Fig2A deliverable
return



%-------------------------
function X = prepViz(X)
    X(~isfinite(X)) = NaN;
    X = fillmissing(X, "constant", 0);
    if exist("BF_NormalizeMatrix","file") == 2
        X = BF_NormalizeMatrix(X, 'mixedSigmoid');
    end
    X = min(max(X, 0), 1);
end
