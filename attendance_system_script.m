function attendance_system_cmd_v3_single_voice()
    % Main command-line attendance system with Roll Number
    % Uses ONE voice sample for verification.
    % More robust Excel saving.

    % --- Constants ---
    fs = 44100; % Sampling frequency

    % --- Initialize data storage if not present ---
    initialize_data_files_v3();

    % --- Main Menu Loop ---
    while true
        disp(newline);
        disp('Hall Dining Entry Management System (Command Line - v3 Single Voice)');
        disp('------------------------------------------------------------------');
        disp('1. New Entry (Register User with Roll & Single Voice Sample)');
        disp('2. Test Entry (Verify User)');
        disp('3. View Attendance Sheet');
        disp('4. Export Attendance to Excel');
        disp('5. Exit');
        choice = input('Enter your choice (1-5): ','s');

        switch str2double(choice)
            case 1
                new_entry_cmd_v3(fs);
            case 2
                test_entry_cmd_v3(fs);
            case 3
                view_attendance_cmd_v3();
            case 4
                export_attendance_to_excel_v3();
            case 5
                disp('Exiting system. Goodbye!');
                break;
            otherwise
                disp('Invalid choice. Please try again.');
        end
        pause(0.5);
    end
end

% --- Helper function to initialize data files (v3) ---
function initialize_data_files_v3()
    disp('Checking and initializing data files (v3)...');
    if ~exist('data', 'dir'), mkdir('data'); disp('Created directory: data'); end
    if ~exist('vq_books_train', 'dir'), mkdir('vq_books_train'); disp('Created directory: vq_books_train'); end

    % User profiles (UserID, RollNumber)
    if ~exist('user_profiles_v3.mat', 'file')
        user_profiles = cell(0,2); % {UserID, RollNumber}
        save('user_profiles_v3.mat', 'user_profiles');
        disp('Initialized: user_profiles_v3.mat');
    end

    % Single Voice Codebooks
    if ~exist(fullfile('vq_books_train', 'voice_codebooks_v3.mat'), 'file')
        voice_codebooks = cell(0,2); % {UserID, CodebookForVoice}
        save(fullfile('vq_books_train', 'voice_codebooks_v3.mat'), 'voice_codebooks');
        disp('Initialized: vq_books_train/voice_codebooks_v3.mat');
    end

    if ~exist('atsheet_v3.mat', 'file')
        attendsheet = cell(0,4); % {UserID, RollNumber, Timestamp, AccessStatus}
        save('atsheet_v3.mat', 'attendsheet');
        disp('Initialized: atsheet_v3.mat');
    end
    disp('Data file check complete.');
end

% --- Function for New Entry (v3) ---
function new_entry_cmd_v3(fs)
    disp(newline);
    disp('--- New Data Entry (v3 - Single Voice) ---');
    user_id_val = input('Enter a unique User ID (e.g., "john.doe"): ', 's');
    if isempty(user_id_val)
        disp('User ID cannot be empty. Aborting.'); return;
    end
    roll_number = input('Enter Roll Number: ', 's');
    if isempty(roll_number)
        disp('Roll Number cannot be empty. Aborting.'); return;
    end

    user_id_dir = matlab.lang.makeValidName(user_id_val);
    maindir = fullfile('data', user_id_dir);
    if ~exist(maindir, 'dir'), mkdir(maindir); end
    voicedir = fullfile(maindir, 'Voice_Recordings'); if ~exist(voicedir, 'dir'), mkdir(voicedir); end

    recobj = audiorecorder(fs, 16, 1);

    try
        load('user_profiles_v3.mat', 'user_profiles');
        load(fullfile('vq_books_train', 'voice_codebooks_v3.mat'), 'voice_codebooks');
    catch ME
        disp('Error loading existing data. Check files.'); disp(ME.message); return;
    end

    existing_user_idx = find(strcmp(user_profiles(:,1), user_id_val), 1);
    if ~isempty(existing_user_idx)
        choice = lower(input(['User ID "' user_id_val '" already exists. Overwrite profile (o), Add new voice samples (a), or Cancel (c)? [o/a/c]: '], 's'));
        if strcmp(choice, 'c'), disp('Cancelled.'); return;
        elseif strcmp(choice, 'o')
            disp('Overwriting user profile and associating new voice samples.');
            user_profiles{existing_user_idx, 2} = roll_number; % Update roll
            % Consider removing old voice_codebooks entries for this user_id_val for cleanliness
            voice_codebooks(strcmp(voice_codebooks(:,1), user_id_val), :) = [];
        elseif ~strcmp(choice, 'a')
            disp('Invalid choice. Cancelling.'); return;
        end
    else
        user_profiles{end+1, 1} = user_id_val;
        user_profiles{end, 2} = roll_number;
    end

    for p = 1:2 % Record two samples
        fprintf('\n--- Recording Voice Sample %d of 2 for User ID: %s ---\n', p, user_id_val);
        input(['Press Enter to start recording your designated voice phrase (e.g., speak your User ID or a passphrase) for 3 seconds...']);
        disp('Recording voice... Speak now!'); recordblocking(recobj, 3); disp('Finished.');
        audio_data_voice = getaudiodata(recobj);
        try
            features_voice = project_mfcc(audio_data_voice); features_voice = features_voice';
            CB_voice = vqsplit(features_voice, 8);
            voice_codebooks{end+1, 1} = user_id_val; voice_codebooks{end, 2} = CB_voice;
            audiowrite(fullfile(voicedir, [user_id_dir '_voice_sample_' num2str(p) '.wav']), audio_data_voice, fs);
            disp('Voice sample processed and saved.');
        catch ME_voice
            disp(['Error processing voice sample ' num2str(p) ': ' ME_voice.message]);
        end
    end

    try
        save('user_profiles_v3.mat', 'user_profiles');
        save(fullfile('vq_books_train', 'voice_codebooks_v3.mat'), 'voice_codebooks');
        disp('User profile and voice codebooks saved successfully.');
    catch ME_save
        disp('CRITICAL ERROR: Could not save updated data files.'); disp(ME_save.message);
    end
    disp(['Data Entry Complete for User ID: ' user_id_val ', Roll: ' roll_number]);
end

% --- Function for Test Entry (v3) ---
function test_entry_cmd_v3(fs)
    disp(newline);
    disp('--- Test Entry (Verification v3 - Single Voice) ---');
    recobj = audiorecorder(fs, 16, 1);

    input('Press Enter to start recording your designated voice phrase for 3 seconds...');
    disp('Recording voice... Speak now!'); recordblocking(recobj, 3); disp('Finished.');
    audio_test_voice = getaudiodata(recobj);
    try
        features_test_voice = project_mfcc(audio_test_voice); features_test_voice = features_test_voice';
    catch ME
        disp(['Error processing your voice input: ' ME.message]); return;
    end

    try
        load(fullfile('vq_books_train', 'voice_codebooks_v3.mat'), 'voice_codebooks_db');
        load('user_profiles_v3.mat', 'user_profiles_db');
    catch ME
        disp('Error loading database files for testing. Aborting.'); disp(ME.message); return;
    end

    if isempty(user_profiles_db) || isempty(voice_codebooks_db)
        disp('Database files are empty. Cannot perform test. Please register users first.'); return;
    end

    [matched_user_id, ~] = perform_matching_v3(features_test_voice, voice_codebooks_db);

    disp(newline);
    disp('--- Verification Results ---');
    fprintf('Voice sample matched User ID: %s\n', matched_user_id);

    verified_user_id_for_log = 'UNKNOWN';
    roll_to_log = 'N/A';
    access_granted = false;

    if ~strncmp(matched_user_id, 'unknown', 7)
        disp('>>> ACCESS GRANTED <<<');
        verified_user_id_for_log = matched_user_id;
        access_granted = true;
        profile_idx = find(strcmp(user_profiles_db(:,1), matched_user_id), 1);
        if ~isempty(profile_idx)
            roll_to_log = user_profiles_db{profile_idx, 2};
        end
    else
        disp('>>> ACCESS DENIED <<<');
        disp('Reason: Voice sample did not match any registered user.');
        verified_user_id_for_log = 'Access Denied (Unknown User)';
    end

    % Attendance Logging
    log_attendance_v3(verified_user_id_for_log, roll_to_log, access_granted);
end

% --- Helper function for matching (v3) ---
function [matched_id, min_dist] = perform_matching_v3(test_features, db_codebooks)
    min_dist = inf;
    matched_id = 'unknown (no match)';
    if isempty(db_codebooks) || size(db_codebooks,2) < 2, return; end

    for ii = 1:size(db_codebooks, 1)
        user_id_in_db = db_codebooks{ii, 1};
        current_codebook = db_codebooks{ii, 2};
        if isempty(current_codebook), continue; end
        try
            d = my_dist(test_features, current_codebook);
            if d < min_dist
                min_dist = d;
                matched_id = user_id_in_db;
            end
        catch ME_dist
             % Optional: disp(['Warning: Error in my_dist for user ' user_id_in_db ': ' ME_dist.message]);
        end
    end
end

% --- Helper function to log attendance ---
function log_attendance_v3(user_id, roll_number, status_granted)
    try
        load('atsheet_v3.mat', 'attendsheet');
    catch
        attendsheet = cell(0,4); % Initialize if load failed
        disp('Warning: atsheet_v3.mat not found or corrupted. Creating new.');
    end
    if isempty(attendsheet) || size(attendsheet,2) ~= 4 % Ensure 4 columns
        attendsheet = cell(0,4);
    end

    t_now = now;
    d_str = datestr(t_now, 'yyyy-mm-dd HH:MM:SS');
    status_str = iif(status_granted, 'Granted', 'Denied');

    attendsheet{end + 1, 1} = user_id;
    attendsheet{end, 2} = roll_number;
    attendsheet{end, 3} = d_str;
    attendsheet{end, 4} = status_str;

    try
        save('atsheet_v3.mat', 'attendsheet');
        disp('Attendance logged successfully to atsheet_v3.mat.');
    catch ME_save
        disp('CRITICAL ERROR: Could not save attendance to atsheet_v3.mat.');
        disp(ME_save.message);
    end
end

% --- Function to View Attendance (v3) ---
function view_attendance_cmd_v3()
    disp(newline);
    disp('--- Attendance Sheet (v3) ---');
    try
        load('atsheet_v3.mat', 'attendsheet');
        if isempty(attendsheet)
            disp('Attendance sheet is empty.'); return;
        end
        
        disp('User ID                | Roll Number     | Timestamp                | Status');
        disp('-----------------------|-----------------|--------------------------|---------');
        for i = 1:size(attendsheet, 1)
            uid = attendsheet{i,1}; if isempty(uid), uid = '(empty)'; end
            roll = attendsheet{i,2}; if isempty(roll), roll = '(N/A)'; end
            ts = attendsheet{i,3}; if isempty(ts), ts = '(empty)'; end
            stat = attendsheet{i,4}; if isempty(stat), stat = '(N/A)'; end
            fprintf('%-22s | %-15s | %-24s | %s\n', uid, roll, ts, stat);
        end
    catch ME
        disp('Error loading or displaying attendance sheet from atsheet_v3.mat.');
        disp(ME.message);
    end
end

% --- Function to Export Attendance to Excel (v3) ---
function export_attendance_to_excel_v3()
    disp(newline);
    disp('--- Exporting Attendance to Excel ---');
    excel_filename = 'Attendencebook_v3.xlsx';
    try
        load('atsheet_v3.mat', 'attendsheet');
        if isempty(attendsheet)
            disp('Attendance sheet (atsheet_v3.mat) is empty. Nothing to export.');
            return;
        end
    catch ME
        disp('Error loading atsheet_v3.mat. Cannot export.');
        disp(ME.message);
        return;
    end

    % Prepare header for Excel
    header = {'User ID', 'Roll Number', 'Timestamp', 'Status'};
    data_to_export = [header; attendsheet];

    try
        if exist('writecell', 'file') % Preferred for modern MATLAB
            writecell(data_to_export, excel_filename);
            disp(['Attendance successfully exported to: ' excel_filename]);
        elseif exist('xlswrite', 'file')
             % xlswrite can be problematic, especially with headers and non-Windows
            xlswrite(excel_filename, data_to_export);
            disp(['Attendance successfully exported to: ' excel_filename]);
            disp('Note: If using xlswrite, formatting might vary.');
        else
            disp('Neither writecell nor xlswrite function found. Cannot export to Excel.');
            disp('Please ensure you have a suitable MATLAB version or toolbox (e.g., Spreadsheet Link).');
            disp('Attendance data is saved in atsheet_v3.mat.');
            return; % Exit if no write function
        end
    catch ME_excel
        disp('-------------------------------------------------------------');
        disp('ERROR: Could not write to Excel file.');
        disp(['Attempted to write to: ' excel_filename]);
        disp('Possible reasons:');
        disp('  - Excel/Spreadsheet Link toolbox not available or configured.');
        disp('  - File is open and locked by another program (e.g., Excel itself).');
        disp('  - No write permission in the current directory.');
        disp('  - Corrupted Excel installation (if using COM).');
        disp('MATLAB Error Message:');
        disp(ME_excel.getReport('basic'));
        disp('-------------------------------------------------------------');
        disp('IMPORTANT: Attendance data IS still saved in atsheet_v3.mat');
    end
end

% --- Inline if function ---
function out = iif(condition, true_val, false_val)
    if condition, out = true_val; else, out = false_val; end
end