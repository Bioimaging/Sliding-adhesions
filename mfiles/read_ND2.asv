function data = read_ND2(FolderPath,FileName)
%READ_ND2 Summary of this function goes here
%
%   Nicolas Liaudet
%   Bioimaging Core Facility - UNIGE
%   https://www.unige.ch/medecine/bioimaging/en/bioimaging-core-facility/
% 
%   v1.0 16-May-2019 NL

reader = bfGetReader();
reader = loci.formats.Memoizer(reader, 0);
reader.setId([FolderPath filesep FileName])


omeMeta = reader.getMetadataStore();
NBImage = omeMeta.getImageCount();
if NBImage ~=1
    data = [];
    return    
end
idxImage = 1;

data = struct('Name',cell(NBImage,1),...
    'DimX',cell(NBImage,1),...
    'DimY',cell(NBImage,1),...
    'DimZ',cell(NBImage,1),...
    'DimC',cell(NBImage,1),...
    'DimT',cell(NBImage,1),...
    'ResX',cell(NBImage,1),...
    'ResY',cell(NBImage,1),...
    'ResZ',cell(NBImage,1),...
    'ResT',cell(NBImage,1),...
    'SpatialUnit',cell(NBImage,1),...
    'TimeUnit',cell(NBImage,1),...
    't',cell(NBImage,1),...   
    'PixelType',cell(NBImage,1),...
    'ChannelName',cell(NBImage,1),...
    'OriginalStack',cell(NBImage,1));


hwb = waitbar(0,'','Name',['Reading ' FileName],...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
set(hwb.Children, 'Units', 'Normalized')
hwb.Position(3) = hwb.Position(3)+30;
setappdata(hwb,'canceling',0);
htmp = findobj(hwb,'type','Axes');
htmp.Title.Interpreter = 'none';
htmp.Title.FontSize = 10;
last_time = clock;
init_time = last_time;


waitbar(0,hwb,'Parsing metadata...')
                
data(idxImage).Name = char(omeMeta.getImageName(idxImage-1));

data(idxImage).DimX = omeMeta.getPixelsSizeX(idxImage-1).getValue();
data(idxImage).DimY = omeMeta.getPixelsSizeY(idxImage-1).getValue();
data(idxImage).DimZ = omeMeta.getPixelsSizeZ(idxImage-1).getValue();
data(idxImage).DimC = omeMeta.getPixelsSizeC(idxImage-1).getValue();
data(idxImage).DimT = omeMeta.getPixelsSizeT(idxImage-1).getValue();

data(idxImage).ResX = double(omeMeta.getPixelsPhysicalSizeX(idxImage-1).value);
data(idxImage).ResY = double(omeMeta.getPixelsPhysicalSizeY(idxImage-1).value);
if data(idxImage).DimZ == 1
    data(idxImage).ResZ = double(omeMeta.getPixelsPhysicalSizeZ(idxImage-1));
else
    data(idxImage).ResZ = double(omeMeta.getPixelsPhysicalSizeZ(idxImage-1).value);
end

for idxC = 1:data.DimC
    data(idxImage).ChannelName{idxC} = char(omeMeta.getChannelName(idxImage-1,idxC-1));
end

data(idxImage).PixelType = char(omeMeta.getPixelsType(idxImage-1));

data(idxImage).SpatialUnit = char(omeMeta.getPixelsPhysicalSizeX(idxImage-1).unit.getSymbol);
data(idxImage).TimeUnit    = char(omeMeta.getPlaneDeltaT(idxImage-1,0).unit.getSymbol);
t = zeros(data(idxImage).DimT,1);
%     z = zeros(data(idxImage).DimT,1);
for idxT = 1:data(idxImage).DimC*data(idxImage).DimZ*data(idxImage).DimT
    t(idxT) = omeMeta.getPlaneDeltaT(idxImage-1,idxT-1).value;
    %         z(idxT) = omeMeta.getPlanePositionZ(0,idxT-1).value;
end
%     plot(z)
t = seconds(t);
t = t-t(1);
t = t(1:data(idxImage).DimC*data(idxImage).DimZ:end);

t.Format = data(idxImage).TimeUnit;

data(idxImage).t = t;
data(idxImage).ResT = mean(diff(data(idxImage).t));


stack = zeros(data(idxImage).DimY,...
    data(idxImage).DimX,...
    data(idxImage).DimT,...
    data(idxImage).DimC,...
    data(idxImage).DimZ,...
    data(idxImage).PixelType);
reader.setSeries(idxImage-1)
for idxZ=1:data(idxImage).DimZ
    for idxC=1:data(idxImage).DimC
        for idxT=1:data(idxImage).DimT
            
            if etime(clock,last_time) >= 0.1
                progress = idxT/data(idxImage).DimT;
                elap = etime(clock,init_time);
                sec_remain = elap*(1/progress-1);
                r_mes = datestr(sec_remain/86400,'HH:MM:SS');
                waitbar(progress,hwb,{['Time point: ',...
                    num2str(idxT) '/' num2str(data(idxImage).DimT)];...
                    ['Remaining time: ' r_mes]})
                last_time = clock;
            end
            if getappdata(hwb,'canceling')
                data = [];               
                delete(hwb)
                return
            end
            
            
            iplane = loci.formats.FormatTools.getIndex(reader,...
                idxZ-1,idxC-1,idxT-1)+1;
            stack(:,:,idxT,idxC,idxZ) = bfGetPlane(reader, iplane);
        end
    end
end

stack = squeeze(stack);
data(idxImage).OriginalStack = stack;

delete(hwb)

reader.close();

end

