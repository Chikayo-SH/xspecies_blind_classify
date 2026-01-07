function fig = showBarcodeLocal(data_subj, order_f, awake_idx, uncon_idx, order_e_awake, order_e_uncon, refPos, figTitle, cax)
% data_subj: (nEpoch x nFeat) for one subject
% order_f: feature order indices
% awake_idx/uncon_idx: row indices within subject
% order_e_awake/order_e_uncon: ordering within each subset (1..numel(subset))
% refPos: positions in feature-order space to mark
% figTitle: title string/char
% cax: [lo hi] for shared color axis (optional)

awake_idx = awake_idx(:)';
uncon_idx = uncon_idx(:)';
order_e_awake = order_e_awake(:)';
order_e_uncon = order_e_uncon(:)';

na = numel(awake_idx);
nu = numel(uncon_idx);
if na == 0; error("awake_idx is empty"); end
if nu == 0; error("uncon_idx is empty"); end

order_e_awake = order_e_awake(order_e_awake >= 1 & order_e_awake <= na);
order_e_uncon = order_e_uncon(order_e_uncon >= 1 & order_e_uncon <= nu);
if numel(order_e_awake) ~= na; order_e_awake = 1:na; end
if numel(order_e_uncon) ~= nu; order_e_uncon = 1:nu; end

A = data_subj(awake_idx(order_e_awake), order_f);
U = data_subj(uncon_idx(order_e_uncon), order_f);

% sanitize BEFORE normalization
A(~isfinite(A)) = NaN;
U(~isfinite(U)) = NaN;
A = fillmissing(A, "constant", 0);
U = fillmissing(U, "constant", 0);

if exist("BF_NormalizeMatrix","file") == 2
    A = BF_NormalizeMatrix(A, 'mixedSigmoid');
    U = BF_NormalizeMatrix(U, 'mixedSigmoid');
end

A = min(max(A, 0), 1);
U = min(max(U, 0), 1);

% compute default cax if not provided
if nargin < 9 || isempty(cax)
    vals = [A(:); U(:)];
    cax = [prctile(vals,1) prctile(vals,99)];
    if ~(isfinite(cax(1)) && isfinite(cax(2)) && cax(2) > cax(1))
        cax = [0 1];
    end
end

fig = figure("position", [0 0 1200 600], "Name", "HCTSA barcode");

ax1 = subplot(2,1,1);
imagesc(A);
caxis(ax1, cax);
title("awake");
set(ax1, "tickdir", "out", "ytick", []);

ax2 = subplot(2,1,2);
imagesc(U);
caxis(ax2, cax);
title("unconscious");
set(ax2, "tickdir", "out", "ytick", []);

colormap(inferno);

for k = 1:numel(refPos)
    x = refPos(k);
    if ~isnan(x) && x >= 1
        xline(ax1, x, "LineWidth", 1.5);
        xline(ax2, x, "LineWidth", 1.5);
    end
end

sgtitle(string(figTitle));
drawnow;
end
