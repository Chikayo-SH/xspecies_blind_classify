function export_barcode_from_accuracy_orders()
% Export Fig2A barcode using order_f/order_e stored in an accuracy.mat
%
% Input:
%   - accuracy.mat with fields: order_f, order_e, classifier_cv
%   - corresponding train/validate HCTSA mats exist under repoRoot/hctsa_subtractMean_removeLineNoise/...
%
% Output:
%   - *_HCTSA_barcode_t.png, *_HCTSA_barcode_v.png next to accuracy.mat

    % --------- 0) Paths ----------
    matPath = "C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify_rezaLocal\TS_DataMat_train_macaque_George_ch017_validate_human_376_ch140_accuracy.mat";
    assert(exist(matPath,"file")==2, "accuracy.mat not found: " + matPath);

    repoRoot = fileparts(matPath); % accuracy.matがrepo直下にある前提
    cd(repoRoot);
    addpath(genpath(pwd));
    rehash;

    % --------- 1) Load accuracy.mat ----------
    S = load(matPath);
    mustHave = ["order_f","order_e","classifier_cv"];
    for k = 1:numel(mustHave)
        assert(isfield(S, mustHave(k)), "missing field in accuracy.mat: " + mustHave(k));
    end

    order_f = S.order_f;
    order_e = S.order_e;
    classifier_cv = S.classifier_cv;

    % --------- 2) Parse train/validate info from filename (no guessing) ----------
    info = parse_from_filename(matPath);

    % --------- 3) Locate corresponding HCTSA mats (prefer v2 if available) ----------
    preprocessSuffix = "_subtractMean_removeLineNoise";
    trainMat = find_hctsa_mat(repoRoot, preprocessSuffix, info.species_train, info.subject_train, info.ch_train);
    valMat   = find_hctsa_mat(repoRoot, preprocessSuffix, info.species_validate, info.subject_validate, info.ch_validate);

    % Load TS_Normalised + TimeSeries + Operations (barcode display is safer in normalized space)
    trainData = load(trainMat, "Operations", "TS_DataMat", "TS_Normalised", "TimeSeries");
    validateData = load(valMat, "Operations", "TS_DataMat", "TS_Normalised", "TimeSeries");

    % --------- 4) Build data_all + TimeSeries_all ----------
    % Daisuke code passes data_all = [trainData.(htcsaType); validateData.(htcsaType)].
    % For barcode display, use TS_Normalised if present, else fall back to TS_DataMat.
    if isfield(trainData,"TS_Normalised") && isfield(validateData,"TS_Normalised")
        data_all = [trainData.TS_Normalised; validateData.TS_Normalised];
        data_all = prepViz(data_all); % ensure [0,1] and finite
    else
        data_all = [trainData.TS_DataMat; validateData.TS_DataMat];
        data_all = prepViz(data_all);
    end
    TimeSeries_all = [trainData.TimeSeries; validateData.TimeSeries];

    % --------- 5) Reconstruct subjectEpochs the same way as NMclassification_selectCh ----------
    condNames = {"awake","unconscious"};
    subjectNames = { "subject:" + info.subject_train, "subject:" + info.subject_validate };

    subj1 = find(getCondTrials(TimeSeries_all, subjectNames(1))==1);
    subj2 = find(getCondTrials(TimeSeries_all, subjectNames(2))==1);

    % Fail-fast if subject tags are missing (do not guess)
    assert(~isempty(subj1), "No epochs found for subjectNames{1}=" + subjectNames{1} + ". TimeSeries_all likely lacks subject tags.");
    assert(~isempty(subj2), "No epochs found for subjectNames{2}=" + subjectNames{2} + ". TimeSeries_all likely lacks subject tags.");

    subjectEpochs = cell(1,2);
    subjectEpochs{1} = subj1;
    subjectEpochs{2} = subj2;

    % --------- 6) Verify condition counts match order_e (do not guess) ----------
    for itv = 1:2
        TSsub = TimeSeries_all(subjectEpochs{itv}, :);
        for ic = 1:2
            idx = find(getCondTrials(TSsub, condNames(ic))==1);
            n_expected = numel(order_e{itv,ic});
            assert(numel(idx)==n_expected, ...
                sprintf("Mismatch: itv=%d ic=%d cond=%s has %d epochs, but order_e has %d. Fix TimeSeries labels before using order_e.", ...
                itv, ic, condNames{ic}, numel(idx), n_expected));
        end
    end

    % --------- 7) ref feature positions (optional markers) ----------
    refCodeStrings = {"DN_rms", "MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1"};
    refPos = get_refPos(order_f, classifier_cv.operations.CodeString, refCodeStrings);

    % --------- 8) Export barcode (prefer showHCTSAbarcodes to match Daisuke) ----------
    [outDir, base, ~] = fileparts(matPath);
    out_file = fullfile(outDir, base);

    if exist("showHCTSAbarcodes","file")==2
        fig_t = showHCTSAbarcodes( ...
            data_all(subjectEpochs{1},:), TimeSeries_all(subjectEpochs{1},:), ...
            order_f, order_e(1,:), classifier_cv.operations.CodeString, refCodeStrings);
        saveFig(fig_t, out_file + "_HCTSA_barcode_t");
        close(fig_t);

        fig_v = showHCTSAbarcodes( ...
            data_all(subjectEpochs{2},:), TimeSeries_all(subjectEpochs{2},:), ...
            order_f, order_e(2,:), classifier_cv.operations.CodeString, refCodeStrings);
        saveFig(fig_v, out_file + "_HCTSA_barcode_v");
        close(fig_v);

    else
        % Fallback: use showBarcodeLocal (needs awake/uncon indices within each subject)
        assert(exist("showBarcodeLocal","file")==2, "Neither showHCTSAbarcodes nor showBarcodeLocal is available on path.");

        % shared caxis (optional)
        cax_shared = compute_shared_cax_from_orders(data_all, TimeSeries_all, subjectEpochs, condNames, order_f, order_e);

        % train
        TSsub = TimeSeries_all(subjectEpochs{1}, :);
        awake = find(getCondTrials(TSsub, condNames(1))==1);
        uncon = find(getCondTrials(TSsub, condNames(2))==1);
        fig_t = showBarcodeLocal(data_all(subjectEpochs{1},:), order_f, awake, uncon, order_e{1,1}, order_e{1,2}, refPos, "train", cax_shared);
        saveFig(fig_t, out_file + "_HCTSA_barcode_t");
        close(fig_t);

        % validate
        TSsub = TimeSeries_all(subjectEpochs{2}, :);
        awake = find(getCondTrials(TSsub, condNames(1))==1);
        uncon = find(getCondTrials(TSsub, condNames(2))==1);
        fig_v = showBarcodeLocal(data_all(subjectEpochs{2},:), order_f, awake, uncon, order_e{2,1}, order_e{2,2}, refPos, "validate", cax_shared);
        saveFig(fig_v, out_file + "_HCTSA_barcode_v");
        close(fig_v);
    end

    disp("Done. Exported barcode PNGs next to:");
    disp(matPath);
end

% ---------- helpers ----------

function info = parse_from_filename(matPath)
    [~, name, ~] = fileparts(matPath);
    % Example:
    % TS_DataMat_train_macaque_George_ch017_validate_human_376_ch140_accuracy
    expr = "train_(?<speciesT>[A-Za-z0-9]+)_(?<subjectT>[A-Za-z0-9]+)_ch(?<chT>\d+)_validate_(?<speciesV>[A-Za-z0-9]+)_(?<subjectV>[A-Za-z0-9]+)_ch(?<chV>\d+)";
    tok = regexp(name, expr, "names");
    assert(~isempty(tok), "Cannot parse train/validate info from filename: " + name);

    info.species_train = string(tok.speciesT);
    info.subject_train = string(tok.subjectT);
    info.ch_train = str2double(tok.chT);

    info.species_validate = string(tok.speciesV);
    info.subject_validate = string(tok.subjectV);
    info.ch_validate = str2double(tok.chV);
end

function matFile = find_hctsa_mat(repoRoot, preprocessSuffix, species, subject, ch)
    hdir = fullfile(repoRoot, "hctsa" + preprocessSuffix, char(species), char(subject));
    assert(exist(hdir,"dir")==7, "HCTSA dir not found: " + string(hdir));

    pat_v2 = sprintf("*_%s_ch%03d*_hctsa_v2.mat", char(subject), ch);
    pat_v1 = sprintf("*_%s_ch%03d*_hctsa.mat", char(subject), ch);

    d = dir(fullfile(hdir, pat_v2));
    if ~isempty(d)
        matFile = fullfile(hdir, d(1).name);
        return;
    end

    d = dir(fullfile(hdir, pat_v1));
    assert(~isempty(d), "No HCTSA mat found for " + species + "/" + subject + " ch" + num2str(ch) + " under " + string(hdir));
    matFile = fullfile(hdir, d(1).name);
end

function refPos = get_refPos(order_f, codeStrings, refCodeStrings)
    refPos = [];
    for i = 1:numel(refCodeStrings)
        opIdx = find(strcmp(codeStrings, refCodeStrings{i}), 1);
        if isempty(opIdx); continue; end
        [~, pos] = intersect(order_f, opIdx);
        if ~isempty(pos)
            refPos(end+1) = pos; %#ok<AGROW>
        end
    end
end

function saveFig(fig, outBase)
    if exist("savePaperFigure","file")==2
        savePaperFigure(fig, outBase);
    else
        exportgraphics(fig, outBase + ".png", "Resolution", 300);
    end
end

function X = prepViz(X)
    X(~isfinite(X)) = NaN;
    X = fillmissing(X, "constant", 0);
    if exist("BF_NormalizeMatrix","file")==2
        X = BF_NormalizeMatrix(X, "mixedSigmoid");
    end
    X = min(max(X, 0), 1);
end

function cax = compute_shared_cax_from_orders(data_all, TimeSeries_all, subjectEpochs, condNames, order_f, order_e)
    % Compute caxis from the ordered blocks (1-99 percentile)
    vals = [];
    for itv = 1:2
        TSsub = TimeSeries_all(subjectEpochs{itv}, :);
        for ic = 1:2
            idx = find(getCondTrials(TSsub, condNames(ic))==1);
            if isempty(idx); continue; end
            ord = order_e{itv,ic};
            ord = ord(:)';
            ord = ord(ord>=1 & ord<=numel(idx));
            idx = idx(ord);
            block = data_all(subjectEpochs{itv}(idx), order_f);
            vals = [vals; block(:)]; %#ok<AGROW>
        end
    end
    vals = vals(isfinite(vals));
    if isempty(vals)
        cax = [0 1];
        return;
    end
    cax = [prctile(vals,1) prctile(vals,99)];
    if ~(isfinite(cax(1)) && isfinite(cax(2)) && cax(2) > cax(1))
        cax = [0 1];
    end
end
