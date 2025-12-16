function h = hline(y, varargin)
% hline  Draw horizontal line(s) at y on current axes.
%
%   h = hline(y)
%   h = hline(y, 'PropertyName', PropertyValue, ...)
%
%   例:
%     hline(0.5, 'Color', 'r', 'LineWidth', 1.5);

    if nargin < 1
        error('hline:NotEnoughInputs', 'y 座標を少なくとも1つ指定してください。');
    end

    ax = gca;
    xl = xlim(ax);

    y = y(:)';  % row ベクトルにして複数対応
    h = gobjects(1, numel(y));
    for k = 1:numel(y)
        h(k) = line(ax, xl, [y(k) y(k)], varargin{:});
    end
end
