%% VQ livetest
% clear; clc; close all;
% 
% recobj=audiorecorder(44100,16,1);
% fs=44100;
% disp('speak id in 3 sec...');
% pause(1);
% disp('now');
% recordblocking(recobj,3);
% disp('end');
% x =getaudiodata(recobj);
% % x = bandpass(x, [300 3400], fs);
% % sound(x,fs); pause(3);
% % x=awgn(x,30,'measured');
% % x=WienerNoiseReduction(x,44100,50e-3*44100);
% sound(x,fs); pause(4);
% g=project_mfcc(x); g=g';
% 
% disp('speak name in 3 sec...');
% pause(1);
% disp('now');
% recordblocking(recobj,3);
% disp('end');
% y =getaudiodata(recobj);
% % y = bandpass(y, [300 3400], fs);
% % y=awgn(y,30,'measured');
% % y=WienerNoiseReduction(y,44100,100e-3*44100);
% sound(y,fs);
% h=project_mfcc(y); h=h';
% 
% A=load('vq_books_train\ID.mat');
% ID=A.ID;
% A=load('vq_books_train\NAME.mat');
% NAME=A.NAME;
% dmin=inf;
% for ii=1:size(ID,1)
%     d=my_dist(g,ID{ii,1});
%     if d<dmin
%         dmin=d;
%         id1=ID{ii,2};
%     end
% end
% 
% dmin=inf;
% for ii=1:size(NAME,1)
%     d=my_dist(h,NAME{ii,1});
%     if d<dmin
%         dmin=d;
%         id2=NAME{ii,2};
%     end
% end
% 
% disp(id1); disp(id2);
% 
% if strcmp(id1,id2)==1
%     disp('access granted');
% else
%     disp('access denied');
% end
% 
% subplot(211); plot(x);
% subplot(212); plot(y);

% %% accuracy measure id
% clear;
% fs = 44100;
% A=load('vq_books_train\ID.mat');
% ID=A.ID;
% A=load('vq_books_train\NAME.mat');
% NAME=A.NAME;
% 
% list=ls('test_ids\');            % list=ls('test_ids_WN\');
% list=list(3:end,:);
% B=ID; n=0;
% for ii=1:size(list,1)
%     actual=list(ii,1:7);
%     f=['test_ids\' list(ii,:)];      % f=['test_ids_WN\' list(ii,:)];
%     x=audioread(f);
% %     x = bandpass(x, [300 3400], fs);
% %     x = awgn(x, 10,'measured');
% %     x=WienerNoiseReduction(x,fs,50e-3*fs);
%     g=project_mfcc(x); g=g';
%     dmin=inf;
%     for jj=1:size(B,1)
%         d=my_dist(g,B{jj,1});
%         if d<dmin
%             dmin=d;
%             guess=B{jj,2};
%         end
%     end
%     if strcmp(actual,guess)==1
%         acc=1; n=n+1;
%     else
%         acc=0;
%     end
%     disp([ii acc]);
% end
% disp(100*n/size(list,1));

%% accuracy measure name
clear;
fs = 44100;
A=load('vq_books_train\ID.mat');
ID=A.ID;
A=load('vq_books_train\NAME.mat');
NAME=A.NAME;

list=ls('test_names\');        % list=ls('test_names_WN\');
list=list(3:end,:);
B=NAME; n=0;
for ii=1:size(list,1)
    actual=list(ii,1:7);
    f=['test_names\' list(ii,:)];         % f=['test_names_WN\' list(ii,:)];
    x=audioread(f);
%     x = bandpass(x, [300 3400], fs);
%     x = awgn(x,10,'measured');
%     c_noise = audioread("classrom-talk_01-72871.mp3");
%     c_noise = reshape(c_noise, 1, [])';
%     c_noise = c_noise(1:length(x));
%     x = x + c_noise;
%     x = WienerNoiseReduction(x,fs,50e-3*fs);
    g=project_mfcc(x); g=g';
    dmin=inf;
    for jj=1:size(B,1)
        d=my_dist(g,B{jj,1});
        if d<dmin
            dmin=d;
            guess=B{jj,2};
        end
    end
    if strcmp(actual,guess)==1
        acc=1; n=n+1;
    else
        acc=0;
    end
    disp([ii acc]);
end
disp(100*n/size(list,1));


%% Testing Non-Enlisted
% clear; clc;
% fs = 44100;
% A=load('vq_books_train\ID.mat');
% ID=A.ID;
% A=load('vq_books_train\NAME.mat');
% NAME=A.NAME;
% 
% list=ls("false_data\");
% list=list(3:end,:);
% p=0; rr=0;
% for ii=1:size(list,1)
%     id=list(ii,:);
%     L1=ls(['false_data\' id '\ID\']); L1=L1(3:end,:);
%     L2=ls(['false_data\' id '\NAME\']); L2=L2(3:end,:);
%     n=min(size(L1,1), size(L2,1));
% 
%     for jj=1:n
%         f1=['false_data\' id '\ID\' L1(jj,:)];
%         f2=['false_data\' id '\NAME\' L2(jj,:)];
%         x=audioread(f1);  
% %         x = bandpass(x, [300 3400], fs);
%         y=audioread(f2);  
% %         y = bandpass(y, [300 3400], fs);
%         g=project_mfcc(x); g=g';
%         h=project_mfcc(y); h=h';
%         dmin=inf;
%         for kk=1:size(ID,1)
%             d=my_dist(g,ID{kk,1});
%             if d<=dmin
%                 dmin=d; id1=ID{kk,2};
%             end
%         end
%         dmin=inf;
%         for kk=1:size(NAME,1)
%             d=my_dist(h,NAME{kk,1});
%             if d<=dmin
%                 dmin=d; id2=NAME{kk,2};
%             end
%         end
%        
%         p=p+1;
%         if strcmp(id1,id2)==0
%             rr=rr+1;
%         end
%     end
%     ii
% end
% 
% disp(100*rr/p);

%% Reserve
% % id='1806abc'; n=0;
% % A=ID;
% % for ii=1:size(A,1)
% %     if strcmp(id,A{ii,2})==0
% %         id=A{ii,2};
% %         disp(id)
% %         n=n+1;
% %     end
% % end
% % n
% 
% %%
% % xn=awgn(x,20,'measured');
% % 
% % [p, q]=WienerNoiseReduction(xn,44100,27000);
% % 
% % figure(1); plot(xn);
% % figure(2); plot(p); 
% % figure(3); plot(q);
% % sound(xn,44100); pause(3);
% % sound(p,44100); pause(3);
% % sound(q,44100); pause(3);