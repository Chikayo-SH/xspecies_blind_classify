function linkcaxes(ax, clim)
% linkcaxes(ax, clim)
%   全てのaxesのcaxisを同じ範囲に揃える簡易版
%
%   ax  : axesハンドル配列
%   clim: [cmin cmax]（省略時は全axのcaxisから自動決定）

    if nargin < 2 || isempty(clim)
        cmin = Inf;
        cmax = -Inf;
        for a = ax(:)'
            c = caxis(a);
            cmin = min(cmin, c(1));
            cmax = max(cmax, c(2));
        end
        clim = [cmin cmax];
    end

    for a = ax(:)'
        caxis(a, clim);
    end
end
