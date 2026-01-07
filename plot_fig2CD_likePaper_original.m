function fig = plot_fig2CD_likePaper(data_all, CodeString, epochIdx, outPng)
% Make Fig2C/D-like 2x2 plot with matched ticks across panels.
% Top row: Feature X (log y-axis), Bottom row: Feature Y (linear y-axis).
%
% data_all: Nepoch x Nfeat
% CodeString: Nfeat x 1 string
% epochIdx: 2x2 cell, global indices into rows of data_all
% outPng: optional output path for PNG (char or string). If empty, no save.

    if nargin < 4
        outPng = "";
    end

    % ===== settings you may tweak =====
    subjectLabels = ["subject:George","subject:376"];
    condLabels = ["Awake","Unresponsive"]; % label text only
    featureX = "DN_rms";
    featureY = "MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1";

% ===== paper-like axes (enable later) =====
% xlimProb = [0 0.20];
% xtickProb = 0:0.05:0.20;
% yTickX = make_log_ticks(rangeX, 0.4);
% yTickLabelX = arrayfun(@(v) sprintf("10^{%.1f}", log10(v)), yTickX, "UniformOutput", false);
% yTickY = make_linear_ticks(rangeY, 0.5);
% =========================================

    % histogram bins
    nEdgesX = 20;
    nEdgesY = 20;

    % colors (match Daisuke)
    colAwake = [1 0 1];        % magenta
    colUnresp = [0 1 1];       % cyan
    % ================================

    CodeString = string(CodeString);

    fig = figure("Position",[100 100 900 700]);

    % --- helper to compute feature column index ---
    ixX = find(CodeString == featureX, 1);
    ixY = find(CodeString == featureY, 1);
    assert(~isempty(ixX), "featureX not found in CodeString: " + featureX);
    assert(~isempty(ixY), "featureY not found in CodeString: " + featureY);

    % --- compute medians (per feature) for both subjects/conds ---
    medX = compute_medians(data_all(:,ixX), epochIdx);
    medY = compute_medians(data_all(:,ixY), epochIdx);

    % --- decide y-ranges from pooled data (1-99 percentile) ---
    rangeX = prctile(data_all(:,ixX), [1 99]);
    rangeY = prctile(data_all(:,ixY), [1 99]);

    % --- Feature X edges (log bins) ---
    % if <=0 exists, fall back to linear y (still aligned)
    useLogY = all(rangeX > 0);
    if useLogY
        edgesX = logspace(log10(rangeX(1)), log10(rangeX(2)), nEdgesX);
        yTickX = make_log_ticks(rangeX, 0.4); % 0.4 step -> 10^1.2,10^1.6,... style
        yTickLabelX = arrayfun(@(v) sprintf("10^{%.1f}", log10(v)), yTickX, "UniformOutput", false);
    else
        edgesX = linspace(rangeX(1), rangeX(2), nEdgesX);
        yTickX = [];
        yTickLabelX = {};
    end

    % --- Feature Y edges (linear bins) ---
    edgesY = linspace(rangeY(1), rangeY(2), nEdgesY);
    yTickY = make_linear_ticks(rangeY, 0.5); % 0.5 step default
    yTickLabelY = {};

    % ======== Panel C1 (subject 1, Feature X) ========
    axC1 = subplot(2,2,1);
    plot_one_panel(axC1, data_all(:,ixX), epochIdx, 1, edgesX, colAwake, colUnresp);
    % apply_axes(axC1, xlimProb, xtickProb, rangeX, useLogY, yTickX, yTickLabelX);
    
    axC1 = subplot(2,2,1);
    plot_one_panel(axC1, data_all(:,ixX), epochIdx, 1, edgesX, colAwake, colUnresp);
    ylabel(axC1, subjectLabels(1));
    title(axC1, "C1");


    ylabel(axC1, subjectLabels(1));
    title(axC1, "C1");

    % ======== Panel C2 (subject 2, Feature X) ========
    axC2 = subplot(2,2,2);
    plot_one_panel(axC2, data_all(:,ixX), epochIdx, 2, edgesX, colAwake, colUnresp);
    % apply_axes(axC2, xlimProb, xtickProb, rangeX, useLogY, yTickX, yTickLabelX);
    ylabel(axC2, subjectLabels(2));
    title(axC2, "C2");

    % ======== Panel D1 (subject 1, Feature Y) ========
    axD1 = subplot(2,2,3);
    plot_one_panel(axD1, data_all(:,ixY), epochIdx, 1, edgesY, colAwake, colUnresp);
    % apply_axes(axD1, xlimProb, xtickProb, rangeY, false, yTickY, yTickLabelY);
    ylabel(axD1, subjectLabels(1));
    xlabel(axD1, "Probability");
    title(axD1, "D1");

    % ======== Panel D2 (subject 2, Feature Y) ========
    axD2 = subplot(2,2,4);
    plot_one_panel(axD2, data_all(:,ixY), epochIdx, 2, edgesY, colAwake, colUnresp);
    % apply_axes(axD2, xlimProb, xtickProb, rangeY, false, yTickY, yTickLabelY);
    ylabel(axD2, subjectLabels(2));
    xlabel(axD2, "Probability");
    title(axD2, "D2");
    % ---- auto axes (make whole figure visible) ----
    apply_axes_auto(axC1, useLogY, rangeX);
    apply_axes_auto(axC2, useLogY, rangeX);
    apply_axes_auto(axD1, false,  rangeY);
    apply_axes_auto(axD2, false,  rangeY);


    % ======== Draw shared median/mean lines in all panels ========
    draw_summary_lines([axC1 axC2], medX, useLogY);
    draw_summary_lines([axD1 axD2], medY, false);

    % match x-axes across all
    linkaxes([axC1 axC2 axD1 axD2], "x");
    % match y-axes within rows
    linkaxes([axC1 axC2], "y");
    linkaxes([axD1 axD2], "y");

    % save (optional)
    if strlength(string(outPng)) > 0
        outPng = sanitize_path(outPng);
        set(fig, "PaperPositionMode", "auto");
        print(fig.Number, char(outPng), "-dpng", "-r300");
    end
end

function med = compute_medians(values, epochIdx)
    % med(2,2): subject x condition (1=awake,2=unresp)
    med = nan(2,2);
    for itv = 1:2
        for ic = 1:2
            x = values(epochIdx{itv,ic});
            x = x(isfinite(x));
            if ~isempty(x)
                med(itv,ic) = median(x);
            end
        end
    end
end

function plot_one_panel(ax, values, epochIdx, subj, edges, colAw, colUn)
    axes(ax); %#ok<LAXES>
    cla(ax); hold(ax, "on");

    xAw = values(epochIdx{subj,1});
    xUn = values(epochIdx{subj,2});
    xAw = xAw(isfinite(xAw));
    xUn = xUn(isfinite(xUn));

    histogram(ax, xUn, "BinEdges", edges, "FaceColor", colUn, ...
        "Orientation","horizontal", "Normalization","probability");
    histogram(ax, xAw, "BinEdges", edges, "FaceColor", colAw, ...
        "Orientation","horizontal", "Normalization","probability");

    axis(ax, "square");
    set(ax, "TickDir","out");
end

function apply_axes_auto(ax, useLogY, yRange)
    % まずは自動で全体が見える状態にする
    axis(ax, "tight");

    % logかlinearだけは指定(見た目の意図)
    if useLogY
        set(ax, "YScale","log");
        % logはaxis tightが効きにくいので,rangeだけ最低限入れる(必要なら)
        if all(isfinite(yRange)) && all(yRange > 0) && yRange(2) > yRange(1)
            ylim(ax, yRange);
        end
    else
        set(ax, "YScale","linear");
        if all(isfinite(yRange)) && yRange(2) > yRange(1)
            ylim(ax, yRange);
        end
    end

    set(ax, "TickDir","out");
end


function draw_summary_lines(axs, med, useLogY)
    % medians: subject1 solid, subject2 dotted
    % awake magenta, unresp cyan, mean black
    colAw = [1 0 1];
    colUn = [0 1 1];

    for ax = axs
        safeHline(ax, med(1,1), "-", colAw);
        safeHline(ax, med(2,1), ":", colAw);

        safeHline(ax, med(1,2), "-", colUn);
        safeHline(ax, med(2,2), ":", colUn);

        safeHline(ax, mean(med(1,:), "omitnan"), "-", [0 0 0]);
        safeHline(ax, mean(med(2,:), "omitnan"), ":", [0 0 0]);

        if useLogY
            % nothing special; already log scale axis
        end
    end
end

function safeHline(ax, y, ls, col)
    if ~isfinite(y)
        return;
    end
    xl = xlim(ax);
    xl = xl(:)'; % force 1x2
    line(ax, xl, [y y], "LineStyle", ls, "Color", col, "LineWidth", 1);
end

function yTick = make_log_ticks(yRange, stepExp)
    lo = log10(yRange(1));
    hi = log10(yRange(2));
    e0 = ceil(lo/stepExp)*stepExp;
    e1 = floor(hi/stepExp)*stepExp;
    exps = e0:stepExp:e1;
    yTick = 10.^exps;
end

function yTick = make_linear_ticks(yRange, step)
    lo = yRange(1); hi = yRange(2);
    t0 = ceil(lo/step)*step;
    t1 = floor(hi/step)*step;
    yTick = t0:step:t1;
end

function p = sanitize_path(p)
    p = string(p);
    p = regexprep(p, "[\r\n\t]", "");
    p = strtrim(p);
end
