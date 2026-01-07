function fig = plot_fig2CD_likePaper(data_all, CodeString, epochIdx, outPng)
% 2x2 Fig2C/D-like plot with "whole figure visible" layout.
% - Uses tiledlayout (compact spacing)
% - Removes axis square (so panels are not shrunk)
% - Auto xlim based on max histogram probability across panels
% - Paper-like fixed axes are kept as COMMENTED block for later

if nargin < 4
    outPng = "";
end

CodeString = string(CodeString);

% ===== config =====
subjectLabels = ["subject:George","subject:376"];
featureX = "DN_rms";
featureY = "MF_GP_hyperparameters_covSEiso_covNoise_1_200_resample.logh1";

nEdgesX = 20;
nEdgesY = 20;

colAwake  = [1 0 1];  % magenta
colUnresp = [0 1 1];  % cyan

% ---- paper-like axes (enable later) ----
% xlimProb  = [0 0.20];
% xtickProb = 0:0.05:0.20;
% yTickExpStep = 0.4; % for log10 ticks
% ---------------------------------------

% ===== figure & layout (make it big and compact) =====
fig = figure("Units","pixels","Position",[50 50 1400 900]);
t = tiledlayout(fig, 2, 2, "Padding","compact", "TileSpacing","compact");

% ===== feature indices =====
ixX = find(CodeString == featureX, 1);
ixY = find(CodeString == featureY, 1);
assert(~isempty(ixX), "featureX not found in CodeString: " + featureX);
assert(~isempty(ixY), "featureY not found in CodeString: " + featureY);

% ===== ranges & bin edges =====
rangeX = prctile(data_all(:,ixX), [1 99]);
rangeY = prctile(data_all(:,ixY), [1 99]);

useLogY = all(rangeX > 0);

if useLogY
    edgesX = logspace(log10(rangeX(1)), log10(rangeX(2)), nEdgesX);
else
    edgesX = linspace(rangeX(1), rangeX(2), nEdgesX);
end
edgesY = linspace(rangeY(1), rangeY(2), nEdgesY);

% ===== medians for summary lines =====
medX = compute_medians(data_all(:,ixX), epochIdx);
medY = compute_medians(data_all(:,ixY), epochIdx);

% ===== plot panels =====
axC1 = nexttile(t, 1);
plot_one_panel(axC1, data_all(:,ixX), epochIdx, 1, edgesX, colAwake, colUnresp);
title(axC1, "C1");
ylabel(axC1, subjectLabels(1));

axC2 = nexttile(t, 2);
plot_one_panel(axC2, data_all(:,ixX), epochIdx, 2, edgesX, colAwake, colUnresp);
title(axC2, "C2");
ylabel(axC2, subjectLabels(2));

axD1 = nexttile(t, 3);
plot_one_panel(axD1, data_all(:,ixY), epochIdx, 1, edgesY, colAwake, colUnresp);
title(axD1, "D1");
ylabel(axD1, subjectLabels(1));
xlabel(axD1, "Probability");

axD2 = nexttile(t, 4);
plot_one_panel(axD2, data_all(:,ixY), epochIdx, 2, edgesY, colAwake, colUnresp);
title(axD2, "D2");
ylabel(axD2, subjectLabels(2));
xlabel(axD2, "Probability");

% ===== axis scaling: make whole thing visible =====
% 1) set y-scale
set([axC1 axC2], "YScale", ternary(useLogY, "log", "linear"));
set([axD1 axD2], "YScale", "linear");

% 2) y-limits (give a bit margin so nothing touches frame)
apply_ylim(axC1, rangeX, useLogY);
apply_ylim(axC2, rangeX, useLogY);
apply_ylim(axD1, rangeY, false);
apply_ylim(axD2, rangeY, false);

% 3) x-limits: auto from histogram max probability across all panels
drawnow; % ensure histogram Values are available
axs = [axC1 axC2 axD1 axD2];
maxProb = get_max_hist_prob(axs);
if maxProb > 0
    xlimCommon = [0, maxProb*1.15]; % 15% margin so bars never hit right frame
    set(axs, "XLim", xlimCommon);
end

% ===== summary lines =====
draw_summary_lines([axC1 axC2], medX);
draw_summary_lines([axD1 axD2], medY);

% ===== cosmetics: do NOT force square (this was shrinking panels) =====
set(axs, "TickDir","out", "Box","off");

% ---- paper-like fixed axes (enable later) ----
% set(axs, "XLim", xlimProb);
% set(axs, "XTick", xtickProb);
% if useLogY
%     yTickX = make_log_ticks(rangeX, yTickExpStep);
%     set([axC1 axC2], "YTick", yTickX);
%     set([axC1 axC2], "YTickLabel", arrayfun(@(v) sprintf("10^{%.1f}", log10(v)), yTickX, "UniformOutput", false));
% end
% ---------------------------------------------

% ===== save (optional) =====
if strlength(string(outPng)) > 0
    outPng = sanitize_path(outPng);
    set(fig, "PaperPositionMode", "auto");
    print(fig.Number, char(outPng), "-dpng", "-r300");
end

end

% ---------------- helpers ----------------

function med = compute_medians(values, epochIdx)
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
cla(ax); hold(ax, "on");
xAw = values(epochIdx{subj,1}); xAw = xAw(isfinite(xAw));
xUn = values(epochIdx{subj,2}); xUn = xUn(isfinite(xUn));

histogram(ax, xUn, "BinEdges", edges, "FaceColor", colUn, ...
    "Orientation","horizontal", "Normalization","probability");
histogram(ax, xAw, "BinEdges", edges, "FaceColor", colAw, ...
    "Orientation","horizontal", "Normalization","probability");
end

function apply_ylim(ax, range, isLog)
if ~(all(isfinite(range)) && range(2) > range(1))
    return;
end
if isLog
    if any(range <= 0); return; end
    % margin in log space
    lo = 10^(log10(range(1)) - 0.15);
    hi = 10^(log10(range(2)) + 0.15);
    ylim(ax, [lo hi]);
else
    pad = 0.10 * (range(2) - range(1));
    ylim(ax, [range(1)-pad, range(2)+pad]);
end
end

function m = get_max_hist_prob(axs)
m = 0;
for a = axs
    hs = findobj(a, "Type","histogram");
    for h = hs'
        try
            v = h.Values;
            if ~isempty(v)
                m = max(m, max(v));
            end
        catch
        end
    end
end
end

function draw_summary_lines(axs, med)
colAw = [1 0 1];
colUn = [0 1 1];
for ax = axs
    safeHline(ax, med(1,1), "-", colAw);
    safeHline(ax, med(2,1), ":", colAw);
    safeHline(ax, med(1,2), "-", colUn);
    safeHline(ax, med(2,2), ":", colUn);
    safeHline(ax, mean(med(1,:), "omitnan"), "-", [0 0 0]);
    safeHline(ax, mean(med(2,:), "omitnan"), ":", [0 0 0]);
end
end

function safeHline(ax, y, ls, col)
if ~isfinite(y); return; end
xl = xlim(ax); xl = xl(:)';
line(ax, xl, [y y], "LineStyle", ls, "Color", col, "LineWidth", 1);
end

function yTick = make_log_ticks(yRange, stepExp)
lo = log10(yRange(1)); hi = log10(yRange(2));
e0 = ceil(lo/stepExp)*stepExp;
e1 = floor(hi/stepExp)*stepExp;
exps = e0:stepExp:e1;
yTick = 10.^exps;
end

function s = sanitize_path(s)
s = string(s);
s = regexprep(s, "[\r\n\t]", "");
s = strtrim(s);
end

function out = ternary(cond, a, b)
if cond; out = a; else; out = b; end
end
