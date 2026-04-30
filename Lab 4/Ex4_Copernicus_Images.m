%% EX 4 - Copernicus Images (post-processing and timelapse)
% Lab 4 - Cartography
% Satellite Systems for Positioning and Maps - 01VTEWY
%
% This script helps complete EX4 after exporting data from:
% https://browser.dataspace.copernicus.eu/
%
% Expected local structure (example):
%   copernicus_data/
%       2020/
%           ndvi_2020.png
%           air_quality_2020.png
%           true_color_2020.png
%           false_color_2020.png
%       2025/
%           ndvi_2025.png
%           air_quality_2025.png
%           true_color_2025.png
%           false_color_2025.png
%       timelapse/
%           ndvi/        (>= 6 yearly images)
%           true_color/  (>= 6 yearly images)
%
% Output:
%   - Side-by-side comparison figures for 2020 vs 2025
%   - 2 timelapse videos (one per theme folder inside timelapse/)

clc; clear; close all;

script_dir = fileparts(mfilename('fullpath'));
data_dir = fullfile(script_dir, 'copernicus_data');
output_dir = fullfile(script_dir, 'copernicus_results');

if ~isfolder(data_dir)
    error('Folder not found: %s\nCreate it and add exported Copernicus images.', data_dir);
end

if ~isfolder(output_dir)
    mkdir(output_dir);
end

%% --- Products to compare between 2020 and 2025 ---
product_specs = {
    'NDVI',        {'ndvi'};
    'Air_Quality', {'air', 'co2', 'methane'};
    'True_Color',  {'true', 'color', 'rgb'};
    'False_Color', {'false', 'color'}
};

years = {'2020', '2025'};

for p = 1:size(product_specs, 1)
    product_name = product_specs{p, 1};
    keywords = lower(product_specs{p, 2});

    images = cell(1, numel(years));
    paths = cell(1, numel(years));

    for y = 1:numel(years)
        year_dir = fullfile(data_dir, years{y});
        if ~isfolder(year_dir)
            error('Missing folder: %s', year_dir);
        end

        candidate = find_image_by_keywords(year_dir, keywords);
        if isempty(candidate)
            error('No image found for %s in %s', product_name, year_dir);
        end

        paths{y} = candidate;
        images{y} = imread(candidate);
    end

    fig = figure('Color', 'w', 'Name', product_name);
    tl = tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
    title(tl, sprintf('%s comparison (2020 vs 2025)', strrep(product_name, '_', ' ')));

    for y = 1:numel(years)
        nexttile;
        imshow(images{y});
        title(sprintf('%s - %s', strrep(product_name, '_', ' '), years{y}), 'Interpreter', 'none');
    end

    out_png = fullfile(output_dir, sprintf('comparison_%s.png', lower(product_name)));
    exportgraphics(fig, out_png, 'Resolution', 200);
    close(fig);

    fprintf('Saved comparison: %s\n', out_png);
    fprintf('  2020 source: %s\n', paths{1});
    fprintf('  2025 source: %s\n', paths{2});
end

%% --- Timelapse creation (at least 2 themes, >= 6 images each) ---
timelapse_root = fullfile(data_dir, 'timelapse');
if ~isfolder(timelapse_root)
    error('Missing timelapse folder: %s', timelapse_root);
end

theme_dirs = dir(timelapse_root);
theme_dirs = theme_dirs([theme_dirs.isdir]);
theme_dirs = theme_dirs(~ismember({theme_dirs.name}, {'.', '..'}));

if numel(theme_dirs) < 2
    error('Add at least 2 theme folders in %s', timelapse_root);
end

for k = 1:numel(theme_dirs)
    theme_name = theme_dirs(k).name;
    theme_path = fullfile(timelapse_root, theme_name);
    image_files = dir(fullfile(theme_path, '*.png'));

    if numel(image_files) < 6
        error('Theme "%s" has only %d images. At least 6 are required.', ...
            theme_name, numel(image_files));
    end

    [~, idx] = sort({image_files.name});
    image_files = image_files(idx);

    video_path = fullfile(output_dir, sprintf('timelapse_%s.mp4', lower(theme_name)));
    writer = VideoWriter(video_path, 'MPEG-4');
    writer.FrameRate = 2;
    open(writer);

    for i = 1:numel(image_files)
        frame_path = fullfile(theme_path, image_files(i).name);
        frame_img = imread(frame_path);
        writeVideo(writer, frame_img);
    end
    close(writer);

    fprintf('Saved timelapse: %s (%d frames)\n', video_path, numel(image_files));
end

fprintf('\nEX4 post-processing completed.\n');

function file_path = find_image_by_keywords(folder_path, keywords)
% Return first image whose filename contains at least one keyword.

all_images = [dir(fullfile(folder_path, '*.png')); ...
              dir(fullfile(folder_path, '*.jpg')); ...
              dir(fullfile(folder_path, '*.jpeg')); ...
              dir(fullfile(folder_path, '*.tif')); ...
              dir(fullfile(folder_path, '*.tiff'))];

file_path = '';
for i = 1:numel(all_images)
    name_low = lower(all_images(i).name);
    has_match = false;
    for k = 1:numel(keywords)
        if contains(name_low, keywords{k})
            has_match = true;
            break;
        end
    end
    if has_match
        file_path = fullfile(folder_path, all_images(i).name);
        return;
    end
end
end
