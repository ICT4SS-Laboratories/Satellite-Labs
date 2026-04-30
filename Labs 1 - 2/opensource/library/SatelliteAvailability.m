%% Plot and return the satellite availability per epoch
function availability = SatelliteAvailability(gnssMeas, min_satellites)

% Number of epochs
numEpochs = length(gnssMeas.FctSeconds);

% Count the number of visible satellite per epoch
visiblePerEpoch = zeros(numEpochs,1);
for i = 1:numEpochs
    % See if there are available measures
    visiblePerEpoch(i) = sum(~isnan(gnssMeas.PrM(i,:)));
end

% Availability condition per epoch
isAvailable = visiblePerEpoch >= min_satellites;

visibilityPlot = figure;

tiledlayout(4,1)

%% ---- Plot 1: Satellite visibility ----
nexttile([3 1])
plot(1:numEpochs, visiblePerEpoch, 'LineWidth', 1.5)

xlabel('Epoch');
ylabel('Number of visible satellites');
title('Satellite visibility per Epoch');

grid on
ylim([min(visiblePerEpoch) - 1, max(visiblePerEpoch) + 1])


%% ---- Plot 2: Measurement availability ----
nexttile

% Create two series separate (NaN where not applicable)
availSeries = NaN(numEpochs, 1);
unavailSeries = NaN(numEpochs, 1);

availSeries(isAvailable) = 1;
unavailSeries(~isAvailable) = 0;

% Plot them with stairs for a step-like timeline
hold on
stairs(1:numEpochs, availSeries, 'LineWidth', 1.5, 'Color', 'b')
stairs(1:numEpochs, unavailSeries, 'LineWidth', 1.5, 'Color', 'r')
hold off

xlabel('Epoch');
title('Measurement availability')

yticks([0 1])
yticklabels({'Unavailable','Available'})
ylim([-0.2 1.2])

grid on

% --- Add percentage text ---
availability = sum(isAvailable) / numEpochs * 100;
xPos = numEpochs*0.99;
yPos = 0.6;
text(xPos, yPos, sprintf('%.2f%% Available', availability), ...
     'HorizontalAlignment', 'right', ...
     'VerticalAlignment', 'top', ...
     'FontWeight', 'bold', 'FontSize', 10, ...
     'Color', 'k')

end