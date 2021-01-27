function MultipleDisplay(TileShape,IM,txtTitle,t)
%MULTIPLEDISPLAY Summary of this function goes here
%   Detailed explanation goes here
t.Format = 'mm:ss';

% fig = uifigure;
fig = figure;
htilelayout = tiledlayout(fig,TileShape(1),TileShape(2));
htilelayout.TileSpacing = 'compact';
htilelayout.Padding = 'compact';
ax = gobjects(prod(TileShape,1));
for idx = 1:length(ax)
    ax(idx) = nexttile(htilelayout,idx);
    ax(idx).Units = 'normalized';
end

him = gobjects(prod(TileShape),1);
for idx = 1:length(ax)    
    him(idx) = imshow(IM{idx}(:,:,1),[min(IM{idx}(:)) max(IM{idx}(:))],'parent',ax(idx));    
end
linkaxes(ax)
drawnow

for idx = 1:length(ax)  
    title(ax(idx),txtTitle{idx});
end

% hFramCtrlSlider = uislider(fig);
% hFramCtrlSlider.Limits = [1 size(IM{1},3)];
% hFramCtrlSlider.MajorTicks = [];
% hFramCtrlSlider.Value = 1;
% hFramCtrlSlider.ValueChangingFcn = @cbk_Slider;
% hFramCtrlSlider.Position(1:3) = [0 0 fig.Position(3)];
hFramCtrlSlider = uicontrol(fig,'Style','slider','Unit','normalize');
hFramCtrlSlider.Position(1) = ax(1).Position(1);
hFramCtrlSlider.Position(3) = ax(end).Position(1)+ax(end).Position(3)-ax(1).Position(1);
% hFramCtrlSlider.Position = [0 0 fig.Position(3)];
hFramCtrlSlider.Value = 1;
hFramCtrlSlider.Min   = 1;
hFramCtrlSlider.Max   = size(IM{1},3);
hFramCtrlSlider.SliderStep = [1 100]./(size(IM{1},3)-1);


hFrameNB   = uicontrol(fig,'Style','text','Unit','normalize');
hFrameTime = uicontrol(fig,'Style','text','Unit','normalize');

hFrameNB.Position(2) = 0;%hFramCtrlSlider.Position(2)+hFramCtrlSlider.Position(4);
hFrameTime.Position(2) =0;% hFramCtrlSlider.Position(2)+hFramCtrlSlider.Position(4);
% hFrameTime.Position(1) = hFramCtrlSlider.Position(1)+hFramCtrlSlider.Position(3);
align([hFramCtrlSlider hFrameNB],'left','none')
align([hFramCtrlSlider hFrameTime],'right','none')


hFrameNB.String = '1';
hFrameTime.String = char(t(1));

% hFramCtrlSlider.Position(1) = ax(1).Position(1);
% hFramCtrlSlider.Position(3) = ax(2).Position(1)+ax(2).Position(3)-ax(1).Position(1);


addlistener(hFramCtrlSlider,'ContinuousValueChange',@(src,evnt)cbk_Slider(src,evnt));

    function cbk_Slider(src,evnt)   
        idxFrame = round(src.Value);
        hFrameNB.String = num2str(idxFrame);
        hFrameTime.String =char(t(idxFrame));
        for idx = 1:length(ax)
            him(idx).CData = IM{idx}(:,:,idxFrame);
        end
    end
end

