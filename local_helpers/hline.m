function h = hline(y, varargin)
% Minimal hline: draw horizontal line(s) at y in current axes.
%
% Usage:
%   h = hline(0)
%   h = hline([0 1], "LineStyle", "--")

ax = gca;

if nargin < 1 || isempty(y)
    y = 0;
end
y = y(:)';

xl = xlim(ax);

holdState = ishold(ax);
hold(ax, "on");

h = gobjects(numel(y), 1);
for i = 1:numel(y)
    h(i) = line(ax, xl, [y(i) y(i)], varargin{:});
end

if ~holdState
    hold(ax, "off");
end
end
