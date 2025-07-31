% --- Configuration ---
excelFileName = 'speech_database.xlsx';
fs = 16000; % Sampling frequency (Hz)
nBits = 16;  % Bits per sample
nChannels = 1; % Mono audio
recordDuration = 3; % Seconds
numCoeffs = 13; % Number of MFCCs to extract (excluding 0th coefficient)

% --- Main Program Loop ---
while true
    choice = menu('Speech Recognition System', ...
                  '1. Enroll New User', ...
                  '2. Verify User', ...
                  '3. View Stored Data', ...
                  '4. Exit');

    switch choice
        case 1 % Enroll New User
            enrollUser(excelFileName, fs, nBits, nChannels, recordDuration, numCoeffs);
        case 2 % Verify User
            verifyUser(excelFileName, fs, nBits, nChannels, recordDuration, numCoeffs);
        case 3 % View Stored Data
            viewData(excelFileName);
        case 4 % Exit
            disp('Exiting program.');
            break;
        otherwise
            disp('Invalid choice. Please try again.');
    end
end

% --- Function Definitions ---

function enrollUser(fileName, fs, nBits, nChannels, duration, numCoeffs)
    rollNo = input('Enter Roll Number: ', 's');
    if isempty(rollNo)
        disp('Roll Number cannot be empty. Enrollment cancelled.');
        return;
    end

    fprintf('Prepare to speak for Roll Number: %s\n', rollNo);
    pause(1); % Give user a moment to prepare

    % Record Audio
    fprintf('Recording for %d seconds...\n', duration);
    recObj = audiorecorder(fs, nBits, nChannels);
    recordblocking(recObj, duration);
    fprintf('Recording finished.\n');
    audioData = getaudiodata(recObj);

    % Playback for confirmation (optional)
    % disp('Playing back recorded audio...');
    % soundsc(audioData, fs);
    % pause(duration + 0.5);

    % Feature Extraction (MFCCs)
    try
        % Use audioFeatureExtractor for a more robust way to get MFCCs
        aFE = audioFeatureExtractor('SampleRate', fs, ...
                                    'mfcc', true, ...
                                    'mfccDelta', false, ... % Keep it simple for now
                                    'mfccDeltaDelta', false); % Keep it simple
        % Set the number of coefficients if default is not numCoeffs+1 (for 0th)
        % This is a bit tricky as audioFeatureExtractor might have its own default
        % For simplicity, we'll extract default and take the first 'numCoeffs'
        
        features = extract(aFE, audioData);
        % features will be Frames x (NumCoeffs_from_aFE)
        % We usually take coefficients 1 to numCoeffs (ignoring 0th, which is energy)
        if size(features, 2) > numCoeffs
            mfccs = features(:, 1:numCoeffs); % Take the desired number of coefficients
        else
            mfccs = features; % Use what's available if less than requested
        end

        % Take the mean of MFCCs over all frames as a representative vector
        avgMfcc = mean(mfccs, 1);
    catch ME
        disp('Error extracting MFCCs. Make sure Audio Toolbox is installed and working.');
        disp(ME.message);
        return;
    end

    % Prepare data for Excel
    newEntry = {rollNo, mfccVectorToString(avgMfcc)};

    % Read existing data or create new table
    if exist(fileName, 'file')
        try
            opts = detectImportOptions(fileName);
            % Ensure RollNo is read as string, and MFCCs as string
            opts = setvartype(opts, 'RollNumber', 'string');
            opts = setvartype(opts, 'MFCC_Vector', 'string');
            T = readtable(fileName, opts);

            % Check if Roll Number already exists
            if any(strcmpi(T.RollNumber, rollNo))
                overwrite = input(sprintf('Roll Number %s already exists. Overwrite? (y/n): ', rollNo), 's');
                if lower(overwrite) == 'y'
                    T(strcmpi(T.RollNumber, rollNo), :) = []; % Remove old entry
                    disp('Overwriting existing entry.');
                else
                    disp('Enrollment cancelled.');
                    return;
                end
            end
        catch ME_read
            disp(['Error reading existing Excel file: ', ME_read.message]);
            disp('Creating a new table structure.');
            T = table('Size', [0, 2], 'VariableTypes', {'string', 'string'}, ...
                      'VariableNames', {'RollNumber', 'MFCC_Vector'});
        end
    else
        T = table('Size', [0, 2], 'VariableTypes', {'string', 'string'}, ...
                  'VariableNames', {'RollNumber', 'MFCC_Vector'});
    end

    % Append new data
    T = [T; cell2table(newEntry, 'VariableNames', {'RollNumber', 'MFCC_Vector'})];

    % Write to Excel
    try
        writetable(T, fileName);
        fprintf('Roll Number %s enrolled successfully with MFCC features.\n', rollNo);
    catch ME_write
        disp(['Error writing to Excel file: ', ME_write.message]);
        disp('Please ensure the file is not open in another program or you have write permissions.');
    end
end

function verifyUser(fileName, fs, nBits, nChannels, duration, numCoeffs)
    if ~exist(fileName, 'file')
        disp('Database file not found. Please enroll users first.');
        return;
    end

    fprintf('Prepare to speak for verification...\n');
    pause(1);

    % Record Audio
    fprintf('Recording for %d seconds...\n', duration);
    recObj = audiorecorder(fs, nBits, nChannels);
    recordblocking(recObj, duration);
    fprintf('Recording finished.\n');
    testAudioData = getaudiodata(recObj);

    % Feature Extraction (MFCCs) for test audio
    try
        aFE = audioFeatureExtractor('SampleRate', fs, 'mfcc', true, 'mfccDelta', false, 'mfccDeltaDelta', false);
        features = extract(aFE, testAudioData);
        if size(features, 2) > numCoeffs
            testMfccs = features(:, 1:numCoeffs);
        else
            testMfccs = features;
        end
        avgTestMfcc = mean(testMfccs, 1);
    catch ME
        disp('Error extracting MFCCs for test audio.');
        disp(ME.message);
        return;
    end

    % Load database
    try
        opts = detectImportOptions(fileName);
        opts = setvartype(opts, 'RollNumber', 'string');
        opts = setvartype(opts, 'MFCC_Vector', 'string');
        T_db = readtable(fileName, opts);
    catch ME_read
        disp(['Error reading database file: ', ME_read.message]);
        return;
    end
    
    if isempty(T_db)
        disp('Database is empty. Please enroll users first.');
        return;
    end

    minDist = inf;
    identifiedRollNo = 'Unknown';
    
    fprintf('Comparing with stored voices...\n');
    for i = 1:height(T_db)
        storedRollNo = T_db.RollNumber{i};
        storedMfccStr = T_db.MFCC_Vector{i};
        storedMfccVec = mfccStringToVector(storedMfccStr);

        if isempty(storedMfccVec) || length(storedMfccVec) ~= length(avgTestMfcc)
            fprintf('Warning: Skipping entry for Roll No %s due to MFCC format mismatch or error.\n', storedRollNo);
            continue;
        end
        
        % Euclidean Distance
        dist = sqrt(sum((avgTestMfcc - storedMfccVec).^2));
        fprintf('  Distance to %s: %.4f\n', storedRollNo, dist);

        if dist < minDist
            minDist = dist;
            identifiedRollNo = storedRollNo;
        end
    end

    % Verification Decision (Simple Thresholding)
    % THIS THRESHOLD IS CRITICAL AND EMPIRICAL. YOU MUST TUNE IT.
    verificationThreshold = 1.5; % Example: Adjust based on your tests!
                                 % Lower means stricter matching.

    if minDist < verificationThreshold
        fprintf('\nVerification successful!\n');
        fprintf('Speaker identified as: Roll Number %s (Distance: %.4f)\n', identifiedRollNo, minDist);
    else
        fprintf('\nVerification failed.\n');
        fprintf('Closest match was Roll Number %s (Distance: %.4f), but it exceeds the threshold (%.2f).\n', ...
                 identifiedRollNo, minDist, verificationThreshold);
        disp('Speaker not recognized or voice differs significantly.');
    end
end

function viewData(fileName)
    if exist(fileName, 'file')
        try
            opts = detectImportOptions(fileName);
            opts = setvartype(opts, 'RollNumber', 'string');
            opts = setvartype(opts, 'MFCC_Vector', 'string');
            T = readtable(fileName, opts);
            if isempty(T)
                disp('Database is empty.');
            else
                disp('Stored Data:');
                disp(T);
            end
        catch ME
            disp(['Error reading Excel file: ', ME.message]);
        end
    else
        disp('Database file not found.');
    end
end


% --- Helper Functions for MFCC String Conversion ---
function str = mfccVectorToString(vec)
    % Converts a numeric vector to a comma-separated string
    str = strjoin(arrayfun(@(x) sprintf('%.6f', x), vec, 'UniformOutput', false), ',');
end

function vec = mfccStringToVector(str)
    % Converts a comma-separated string back to a numeric vector
    try
        parts = strsplit(str, ',');
        vec = str2double(parts);
        if any(isnan(vec)) % Check if conversion failed for any part
            disp(['Warning: Could not convert MFCC string to vector properly: ', str]);
            vec = []; % Return empty if there's an issue
        end
    catch
        disp(['Error converting MFCC string to vector: ', str]);
        vec = [];
    end
end