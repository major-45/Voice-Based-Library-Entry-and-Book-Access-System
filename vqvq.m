%% train id
clear; clc;close all;

id_dir='train_ids';

items=ls(id_dir);
items=items(3:end,:);
fs = 44100;
ID={};
tic
for ii=1:size(items,1)
    id=items(ii,1:7);
    audiofile=[id_dir, '\', items(ii,:)];
    x=audioread(audiofile);
%     x=WienerNoiseReduction(x,44100,50e-3*44100);
%     x = bandpass(x, [300 3400], fs);
    g=project_mfcc(x); g=g';
    ID{ii,1}=vqsplit(g,8);  ID{ii,2}=id;
    disp([ii size(items,1)]);
end

% now save the extracted features
save_dir='vq_books_train';
idmat=[save_dir '\' 'ID.mat'];

save(idmat, 'ID');
toc
disp('DONE EXTRACTION!!!');

%% test id
% clear;
% fs = 44100;
% % ID feature extraction for test
% id_dir='test_ids';
% items=ls(id_dir);
% items=items(3:end,:);
% ID={};
% tic
% for ii=1:size(items,1)
%     id=items(ii,1:7);
%     audiofile=[id_dir, '\', items(ii,:)];
%     x=audioread(audiofile);
% %     x=WienerNoiseReduction(x);
% %     x = bandpass(x, [300 3400], fs);
%     g=project_mfcc(x); g=g';
%     ID{ii,1}=vqsplit(g,8);  ID{ii,2}=id;
%     disp([ii size(items,1)]);
% end
% % now save the extracted features
% test_dir='vq_books_test';
% idmat=[test_dir '\' 'ID.mat'];
% save(idmat, 'ID');
% toc
% disp('DONE EXTRACTION!!!');

%% train names
clear; clc;close all;

name_dir='train_names';

items=ls(name_dir);
items=items(3:end,:);
fs = 44100;
NAME={};
tic
for ii=1:size(items,1)
    id=items(ii,1:7);
    audiofile=[name_dir, '\', items(ii,:)];
    x=audioread(audiofile);
%     x=WienerNoiseReduction(x,44100,50e-3*44100);
%     x = bandpass(x, [300 3400], fs);
    g=project_mfcc(x); g=g';
    NAME{ii,1}=vqsplit(g,8);  NAME{ii,2}=id;
    disp([ii size(items,1)]);
end

% now save the extracted features
train_dir='vq_books_train';
namemat=[train_dir '\' 'NAME.mat'];
save(namemat, 'NAME');
toc
disp('DONE EXTRACTION!!!');

%% test names
% clear;
% fs = 44100;
% % name feature extraction for test
% name_dir='test_names';
% items=ls(name_dir);
% items=items(3:end,:);
% NAME={};
% tic
% for ii=1:size(items,1)
%     id=items(ii,1:7);
%     audiofile=[name_dir, '\', items(ii,:)];
%     x=audioread(audiofile);
% %     x=WienerNoiseReduction(x);
% %     x = bandpass(x, [300 3400], fs);
%     g=project_mfcc(x); g=g';
%     NAME{ii,1}=vqsplit(g,8);  NAME{ii,2}=id;
%     disp([ii size(items,1)]);
% end
% 
% % now save the extracted features
% test_dir='vq_books_test';
% namemat=[test_dir '\' 'NAME.mat'];
% 
% save(namemat, 'NAME');
% toc
% disp('DONE EXTRACTION!!!');
