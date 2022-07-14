%REORGANIZEIMAGES  Reorganize images from ImageXpress into a folder
%
%  This script reorganizes the images from ImageXpress into individual
%  folders. For each identified well, the code will create a subfolder with
%  t

clearvars
clc

dirToReorganize = 'H:\NGHaCaT06-10-2022\2022-06-12\6675';

%Get subfolders

subfolders = dir(dirToReorganize);

for iSF = 1:numel(subfolders)

    fprintf('Processing folder %s...', subfolders(iSF).name)

    %Find the timepoint
    S = regexp(subfolders(iSF).name, 'TimePoint_(\d+)', 'tokens');

    if isempty(S)
        %Folder name does not match the pattern, so skip
        continue
    else
        timepoint = str2double(S{1}{1});
    end

    %Enter the folder and sort out images into wells
    images = dir(fullfile(subfolders(iSF).folder, subfolders(iSF).name, '*.tif'));

    wellsWritten = {};

    for iImg = 1:numel(images)

        %Find the well name
        wellLocToken = regexp(images(iImg).name, '\d+-\d+-\d+_(\D\d\d)', 'tokens');

        if ~isempty(wellLocToken)
            wellLoc = wellLocToken{1}{1};
        else
            continue
        end

        %Generate the well folder name
        wellFolder = fullfile(dirToReorganize, ['well ' wellLoc]);

        %Generate the image name
        iSite = 1;
        currOutputFN = ['site ' int2str(iSite) ' t' sprintf('%02.0f', timepoint) '.tif'];
        while exist(fullfile(wellFolder, currOutputFN), 'file')
            iSite = iSite + 1;            
            currOutputFN = ['site ' int2str(iSite) ' t' sprintf('%02.0f', timepoint) '.tif'];
        end

        %Create folders if necessary
        if ~exist(wellFolder, 'dir')
            mkdir(wellFolder);
        end

        %Copy and rename the image file
        status = copyfile(fullfile(images(iImg).folder, images(iImg).name), ...
            fullfile(wellFolder, currOutputFN));

    end

    fprintf('DONE. \n');

end