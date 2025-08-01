% record_test_audio.m
clc; clear;

% Parameters
Fs = 8000;  % Sampling frequency
recDuration = 2;  % Seconds
numSamplesPerBook = 8;  % Number of test samples per book

% List of books 
bookList = {
    'Power Systems', 'Computer Networks', 'Macroeconomics', ...
    'Power Electronics', 'Vector Analysis', 'Electric Machine', ...
    'Communication System', 'Differential Equations', 'Linear Algebra', ...
    'Signal Processing', 'Digital Design', 'Fluid Mechanics'
};

% Create folder if it doesn't exist
testFolder = 'test_audio';
if ~exist(testFolder, 'dir')
    mkdir(testFolder);
end

% Select book name from list
disp('Book List:');
for i = 1:length(bookList)
    fprintf('%2d. %s\n', i, bookList{i});
end

bookIndex = input('Enter the number corresponding to the book: ');
if bookIndex < 1 || bookIndex > length(bookList)
    error('Invalid book number!');
end
bookName = bookList{bookIndex};

% Record samples
disp(['Recording for: ', bookName]);
for i = 1:numSamplesPerBook
    recObj = audiorecorder(Fs, 16, 1);
    fprintf('Speak now (Sample %d of %d)...\n', i, numSamplesPerBook);
    pause(0.5);
    recordblocking(recObj, recDuration);
    y = getaudiodata(recObj);
    
    % Normalize audio
    y = y / max(abs(y));
    
    % Save with structured filename
    fileName = sprintf('%s/%s_%d.wav', testFolder, bookName, i);
    audiowrite(fileName, y, Fs);
    
    fprintf('Saved: %s\n\n', fileName);
end

disp('All recordings completed!');
 