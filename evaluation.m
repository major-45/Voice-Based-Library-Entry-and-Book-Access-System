% evaluate_book_classifier.m
clear; clc; close all;

% Load training templates
load('book_mfcc_templates.mat', 'featureBank', 'bookList');

% Parameters
fs = 8000;
numBooks = numel(bookList);
samplesPerBook = 8;  % Test samples per book

% Initialize label arrays
trueLabels = {};
predictedLabels = {};

fprintf('Starting evaluation...\n');

for bookIdx = 1:numBooks
    bookName = bookList{bookIdx};
    
    for sampleIdx = 1:samplesPerBook
        % Load test file
        fileName = sprintf('%s_%d.wav', bookName, sampleIdx);
        testFile = fullfile('test_audio', fileName);

        if ~isfile(testFile)
            warning('Missing test file: %s', testFile);
            continue;
        end
        
        % Read audio
        [audioIn, FsRead] = audioread(testFile);
        audioIn = mean(audioIn, 2);  % Convert to mono
        if FsRead ~= fs
            audioIn = resample(audioIn, fs, FsRead);
        end

        % Extract MFCC
        mfccTest = mfcc(audioIn, fs, ...
            'LogEnergy', 'ignore', ...
            'NumCoeffs', 10, ...
            'OverlapLength', round(fs * 0.015), ...
            'Window', hamming(round(fs * 0.020), 'periodic'));
        mfccTest(:,1) = [];  % Remove 0th coefficient
        mfccTest = mfccTest';

        % Match using DTW
        distances = zeros(1, numBooks);
        for k = 1:numBooks
            distSet = zeros(1, 8);  % 8 training samples
            for j = 1:8
                template = featureBank{j, k};
                try
                    distSet(j) = dtw(mfccTest, template');
                catch
                    distSet(j) = Inf;
                end
            end
            distances(k) = mean(distSet);
        end
        
        [~, bestIdx] = min(distances);
        predictedBook = bookList{bestIdx};

        % Store results
        trueLabels{end+1} = bookName;
        predictedLabels{end+1} = predictedBook;
    end
end

% Create confusion matrix
[C, order] = confusionmat(trueLabels, predictedLabels);
disp('Confusion Matrix (12x12):');
disp(array2table(C, 'VariableNames', order, 'RowNames', order));

% Compute overall accuracy
totalCorrect = sum(diag(C));
totalSamples = sum(C(:));
accuracy = totalCorrect / totalSamples;
fprintf('\nOverall Accuracy: %.2f%%\n', accuracy * 100);

% Per-class accuracy
classAcc = diag(C) ./ sum(C, 2);
[sortedAcc, idxSorted] = sort(classAcc, 'descend');
top3Idx = idxSorted(1:3);
worstIdx = idxSorted(end);

% 2x2 Confusion Matrices for Top 3 Books
fprintf('2x2 Confusion Matrices for Top 3 Classes:\n');
for i = 1:3
    idx = top3Idx(i);
    className = order{idx};
    TP = C(idx, idx);
    FN = sum(C(idx, :)) - TP;
    FP = sum(C(:, idx)) - TP;
    TN = totalSamples - (TP + FP + FN);
    
    M = [TP, FP; FN, TN];
    fprintf('Book: %s\n', className);
    disp(array2table(M, 'VariableNames', {'Pred_Pos', 'Pred_Neg'}, ...
                          'RowNames', {'True_Pos', 'True_Neg'}));
end

% 2x2 for Lowest Accuracy Book
fprintf('\n2x2 Confusion Matrix for Worst Performing Class:\n');
idx = worstIdx;
className = order{idx};
TP = C(idx, idx);
FN = sum(C(idx, :)) - TP;
FP = sum(C(:, idx)) - TP;
TN = totalSamples - (TP + FP + FN);
M = [TP, FP; FN, TN];
fprintf('\nBook: %s\n', className);
disp(array2table(M, 'VariableNames', {'Pred_Pos', 'Pred_Neg'}, ...
                      'RowNames', {'True_Pos', 'True_Neg'}));
%% Plot Full Confusion Matrix (12x12)
figure;
confChart = confusionchart(C, order, ...
    'Title', 'Book Classification Confusion Matrix (12x12)', ...
    'RowSummary','row-normalized', ...
    'ColumnSummary','column-normalized');
confChart.FontName = 'Segoe UI';
confChart.FontSize = 12;

% Set light colormap
confChart.Colormap = parula; % Light-friendly, good contrast
confChart.DiagonalColor = [0.7 0.9 0.7];        % Light green
confChart.OffDiagonalColor = [1 0.8 0.8];       % Light red
