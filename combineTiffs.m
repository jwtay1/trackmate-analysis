clearvars
clc

inputDir = 'D:\Projects\ALMC Tickets\TXXX-Gary\data\Raw';
outputDir = 'D:\Projects\ALMC Tickets\TXXX-Gary\data\stacks';


%% Begin code

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%Get list of subfolders (wells)
wellList = dir(inputDir);

for iWell = 1:numel(wellList)

    %Skip the '.' and '..' directories
    if strcmpi(wellList(iWell).name, '.') || strcmpi(wellList(iWell).name, '..')
        continue
    end

    %Get the current well location
    wellLocStr = regexp(wellList(iWell).name, 'well ([A-Z]\d+)', 'tokens');
    wellLocStr = wellLocStr{1}{1};

    %Get list of image files
    imageFiles = dir(fullfile(wellList(iWell).folder, wellList(iWell).name));

    %Determine number of sites
    allFilenames = {imageFiles.name};

    siteStr = regexp(allFilenames, 'site (\d+) t(\d+)', 'tokens');

    siteNumbers = [];
    timepoints = [];
    %Concatenate site numbers
    for ii = 1:numel(siteStr)

        if ~isempty(siteStr{ii})

            siteNumbers(end + 1) = str2double(siteStr{ii}{1}{1});
            timepoints(end + 1) = str2double(siteStr{ii}{1}{2});

        end

    end

    siteNumbers = unique(siteNumbers);
    maxFrame = max(unique(timepoints)); %Maximum expected frame number
    
    %Process each site - output filename should be WELLLOC_site.tif
    for iSite = 1:siteNumbers

        outputFN = ['wellLocStr_' int2str(iSite), '.tif'];

        for iT = 1:maxFrame

            currI = imread(fullfile(wellList(iWell).folder, wellList(iWell).name, ...
                sprintf('site %.0f t%02.0f.tif', iSite, iT)));
    
            
            %Processing code - TBD


            %Write to file
            
            if iT == 1
                imwrite(currI, fullfile(outputDir, outputFN), 'Compression', 'none');
            else
                imwrite(currI, fullfile(outputDir, outputFN), 'Compression', 'none', 'Writemode', 'append');
            end


         end

    end


    


end


















