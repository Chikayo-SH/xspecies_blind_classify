function refvarrow(ax, xpos, color)
% refvarrow(ax, xpos, color)
%   指定したaxesに、x = xpos の位置に色付きの縦線を引く簡易版
%
%   ax   : axesハンドル
%   xpos : x方向の位置（列インデックス）
%   color: [r g b]

    axes(ax); %#ok<LAXES> % 対象axesをアクティブに
    yl = ylim(ax);
    line([xpos xpos], yl, "Color", color, "LineWidth", 1.5);
end
