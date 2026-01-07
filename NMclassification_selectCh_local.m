%
% One-pair local reproducer for Fig2 panels (A + downstream panels)
% Based on Daisuke's NMclassification_selectCh.m with minimal compatibility fixes.
%

%% Local settings
param.ncv   = 10;
param.alpha = 0.05;
param.q     = 0.05;

dirPref = getpref("cosProject","dirPref");

htcsaType = "TS_DataMat";
preprocessSuffix = "_subtractMean_removeLineNoise";

species_train    = "macaque";
subject_train    = "George";
species_validate = "human";
subject_validate = "376";

refCodeStrings = {"DN_rms", ...
    "MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1"};

% initial (may be auto-fixed)
condNames = ["awake","unconscious"];

%% Directories
load_dir_train     = fullfile(dirPref.rootDir, "preprocessed", species_train, subject_train);
hctsa_dir_train    = fullfile(dirPref.rootDir, "hctsa" + preprocessSuffix, species_train, subject_train);
load_dir_validate  = fullfile(dirPref.rootDir, "preprocessed", species_validate, subject_validate);
hctsa_dir_validate = fullfile(dirPref.rootDir, "hctsa" + preprocessSuffix, species_validate, subject_validate);

save_dir = fullfile(dirPref.rootDir, "results" + preprocessSuffix);
save_dir_char = char(save_dir);
if ~exist(save_dir_char, "dir"); mkdir(save_dir_char); end

%% Fixed single channel pair
ch_train = 17;
ch_validate = 157;

out_file = fullfile(save_dir, sprintf("%s_train_%s_%s_ch%03d_validate_%s_%s_ch%03d_accuracy", ...
    htcsaType, species_train, subject_train, ch_train, species_validate, subject_validate, ch_validate));
out_file = char(out_file);

%% Load v2 HCTSA
file_string_train = fullfile(hctsa_dir_train, ...
    sprintf("%s_%s_ch%03d_tapers5-19_hctsa_v2", species_train, subject_train, ch_train));
trainMat = char(string(file_string_train) + ".mat");
assert(exist(trainMat,"file")==2, "train mat not found");

file_string_validate = fullfile(hctsa_dir_validate, ...
    sprintf("%s_%s_ch%03d_hctsa_v2", species_validate, subject_validate, ch_validate));
valMat = char(string(file_string_validate) + ".mat");
assert(exist(valMat,"file")==2, "validate mat not found");

trainData = load(trainMat, "Operations", "TS_DataMat", "TimeSeries", "TS_Normalised", "valid_features");
validateData = load(valMat, "Operations", "TS_DataMat", "TimeSeries", "TS_Normalised", "valid_features");

%% (Optional) prevent parpool noise during debugging
p = gcp("nocreate");
if ~isempty(p); delete(p); end

%% Train classifier
[classifier_cv, fig_cv] = NMclassifier_cv(trainData, validateData, param.ncv, [], htcsaType);
set(fig_cv, "Position", [0 0 1000 500]);
saveas(fig_cv, [out_file "_NMclassifier_cv.png"]);
close(fig_cv);

%% Prepare shared variables
validFeatures = find(classifier_cv.validFeatures);
order_f = validFeatures(clusterFeatures(trainData.(htcsaType)(:, validFeatures)));

data_all = [trainData.(htcsaType); validateData.(htcsaType)];
TimeSeries_all = [trainData.TimeSeries; validateData.TimeSeries];

% Subject split by concatenation order (robust)
nTrain = size(trainData.(htcsaType), 1);
nVal   = size(validateData.(htcsaType), 1);
subjectEpochs = cell(1,2);
subjectEpochs{1} = 1:nTrain;
subjectEpochs{2} = (nTrain+1):(nTrain+nVal);

%% Auto-fix condition names if needed (uses getCondTrials itself)
nAwake = sum(getCondTrials(TimeSeries_all, condNames(1)) == 1);
nUncon = sum(getCondTrials(TimeSeries_all, condNames(2)) == 1);

if nAwake > 0 && nUncon == 0
    % Try candidates for "unconscious"
    cand = ["uncon","unconsciousness","unresponsive","anesthesia","anaesthesia","sedation","sedated", ...
            "propofol","ketamine","isoflurane","iso","loss","loc","sleep"];
    found = "";
    for c = cand
        try
            n = sum(getCondTrials(TimeSeries_all, c) == 1);
        catch
            n = 0;
        end
        if n > 0
            found = c;
            break;
        end
    end
    if found ~= ""
        disp("condNames(2) replaced: unconscious -> " + found);
        condNames(2) = found;
        nUncon = sum(getCondTrials(TimeSeries_all, condNames(2)) == 1);
    else
        disp("WARNING: could not find unconscious-like label; condition-split panels may be skipped.");
    end
end

disp(["nAwake=" + string(nAwake), "nCond2=" + string(nUncon)]);

%% Compute epoch order
order_e_all = clusterFeatures(data_all(:, validFeatures)');

order_e = cell(2,2);
for itv = 1:2
    for icond = 1:2
        % If condition label exists, use it; otherwise fall back to all epochs for that subject
        if icond == 1 && nAwake > 0
            condIdx = find(getCondTrials(TimeSeries_all, condNames(1)) == 1);
            theseEpochs = intersect(subjectEpochs{itv}, condIdx);
        elseif icond == 2 && nUncon > 0
            condIdx = find(getCondTrials(TimeSeries_all, condNames(2)) == 1);
            theseEpochs = intersect(subjectEpochs{itv}, condIdx);
        else
            theseEpochs = subjectEpochs{itv};
        end

        [~, order_e{itv, icond}] = sort(order_e_all(theseEpochs));
    end
end

%% Fig 2A: HCTSA barcodes (train/validate)
fig_t = showHCTSAbarcodes(data_all(subjectEpochs{1}, :), TimeSeries_all(subjectEpochs{1}, :), order_f, order_e(1, :), ...
    classifier_cv.operations.CodeString, refCodeStrings);
fig_v = showHCTSAbarcodes(data_all(subjectEpochs{2}, :), TimeSeries_all(subjectEpochs{2}, :), order_f, order_e(2, :), ...
    classifier_cv.operations.CodeString, refCodeStrings);

savePaperFigure(fig_t, [out_file "_HCTSA_barcode_t"]);
savePaperFigure(fig_v, [out_file "_HCTSA_barcode_v"]);
close all

%% Single trial panel (optional)
try
    fig = figure("position", [0 0 1000 50]);
    ax(1) = subplot(121);
    imagesc(data_all(subjectEpochs{1}(1), order_f));
    ax(2) = subplot(122);
    imagesc(data_all(subjectEpochs{2}(1), order_f));
    colormap(inferno);
    linkcaxes(ax(:), [0 1]); set(ax, "tickdir","out","ytick",[]);
    savePaperFigure(fig, [out_file "_HCTSA_barcode_single"]);
    close(fig);
catch me
    disp("WARNING: single-trial panel skipped: " + string(me.message));
end

%% Probability histograms (only if both conditions exist)
if nAwake > 0 && nUncon > 0
    ff_rc = pdensity_awakeUnconscious(data_all, TimeSeries_all, classifier_cv.operations.CodeString, ...
        refCodeStrings{1}, cellstr(["train","validate"]), cellstr(condNames), "log", 20);
    savePaperFigure(ff_rc, [out_file "_" replace(refCodeStrings{1}, {"_", "."}, "-")]);

    ff_rc = pdensity_awakeUnconscious(data_all, TimeSeries_all, classifier_cv.operations.CodeString, ...
        refCodeStrings{2}, cellstr(["train","validate"]), cellstr(condNames), [], 20);
    savePaperFigure(ff_rc, [out_file "_" replace(refCodeStrings{2}, {"_", "."}, "-")]);
else
    disp("WARNING: density panels skipped because condition labels are incomplete.");
end

%% Accuracy barcode (this should work even without condition split)
try
    fig = figure("position", [0 0 1000 50]);
    ax(1) = subplot(121);
    imagesc(mean(classifier_cv.accuracy_train(order_f,:), 2)');
    ax(2) = subplot(122);
    imagesc(mean(classifier_cv.accuracy_validate(order_f,:), 2)');
    colormap(1-gray);
    linkcaxes(ax(:), [0.5 1]); set(ax(:), "tickdir","out","ytick",[]);
    drawnow(); mcolorbar;
    savePaperFigure(fig, [out_file "_barcode"]);
    close(fig);
catch me
    disp("WARNING: accuracy barcode skipped: " + string(me.message));
end

disp("DONE: onepair local panels generated (some may be skipped if labels missing).");
