%CREATETIFFSTACKS  Create TIFF stacks from ImageXpress data
%
%  This script will combine imaging data from the ImageXpress to generate
%  a TIFF stack that can then be analyzed in Fiji using the TrackMate
%  algorithm.
%
%  Note: To begin, you should combine all the timepoints into a single
%  folder by copy and pasting the folders from day 1 into the day 2 folder.
%  Check that the final folder has subfolders named TimePoint_1 to
%  TimePoint_N where N is the number of frames acquired.
%
%  Note 2: The output folder must be empty and not contain any files. If
%  the folder is not empty, the code will throw an error. In that case,
%  either select a different directory or delete the files that currently
%  exist.

clearvars
clc

%Parameters
dataFolder = 'H:\NG HaCaT 06-10-2022\2022-06-12\6675';
outputFolder = 'H:\NG HaCaT 06-10-2022\stacks';

%% Begin code

%Verify that output folder is empty
if exist(outputFolder, 'dir')
    outputFiles = dir(outputFolder);
    
    outputFiles(ismember({outputFiles.name}, {'.', '..'})) = [];

    if ~isempty(outputFiles)
        error('Output folder is not empty.')
    end
end


%Parse the data folder to determine the number of timepoints
timepointFolders = dir(fullfile(dataFolder));

%Skip any files that are not directories
timepointFolders(~[timepointFolders.isdir]) = [];

%Remove the '.' and '..' directories
timepointFolders(ismember({timepointFolders.name}, {'.', '..'})) = [];

%Extract the timepoint data
timepointStr = regexp({timepointFolders.name}, 'TimePoint_(\d+)', 'tokens');

timepointMat = zeros(1, numel(timepointStr));
for ii = 1:numel(timepointStr)
    timepointMat(ii) = str2double(timepointStr{ii}{1}{1});
end

%Determine maximum timepoint
numTimepoints = max(timepointMat);

%Parse each timepoint folder and create TIFF stacks
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder)
end

%Display a message
msg = sprintf('%s (%.0f/%.0f)...', ...
    timepointFolders(1).name, 1, numTimepoints);
fprintf('Processing folder %s', msg);

for iTP = 1:numTimepoints

    %Get list of images in current timepoint folder
    currTPfolderIdx = find(ismember({timepointFolders.name}, ['TimePoint_', int2str(iTP)]));

    if isempty(currTPfolderIdx)
        error('Missing data for timepoint %0.0f', iTP)
    end

    images = dir(fullfile(timepointFolders(currTPfolderIdx).folder, ...
        timepointFolders(currTPfolderIdx).name));

    %Display a message
    fprintf(repmat('\b', 1, numel(msg)));
    msg = sprintf('%s (%.0f/%.0f)...', ...
        timepointFolders(currTPfolderIdx).name, iTP, numTimepoints);
    fprintf('%s', msg);

    %Parse each image and create a new TIFF stack in the designated output
    %folder
    for iImg = 1:numel(images)

        %Skip any images that have "thumb" in filename as these are
        %thumbnails of the actual images
        isThumbnail = ~isempty(regexp(images(iImg).name, '_thumb', 'once'));

        if isThumbnail
            continue
        end

        %Find the well name
        wellLocToken = regexp(images(iImg).name, '\d+-\d+-\d+_(\D\d\d)_s(\d)', 'tokens');

        %Skip files that do not conform to the naming pattern
        if ~isempty(wellLocToken)
            wellLoc = wellLocToken{1}{1};
        else
            continue
        end

        %Generate the image name
        iSite = wellLocToken{1}{2};
        currOutputFN = [wellLoc, '_', iSite, '.tif'];

        %If file doesn't exist, create it. Otherwise append image.
        currI = imread(fullfile(images(iImg).folder, images(iImg).name));

        %PROCESSING


        if ~exist(fullfile(outputFolder, currOutputFN), 'file')
            imwrite(currI, fullfile(outputFolder, currOutputFN), 'Compression', 'none');
        else
            imwrite(currI, fullfile(outputFolder, currOutputFN), 'Compression', 'none', 'writemode', 'append');
        end

    end

end
fprintf('DONE\n');










