function VidIdx = playVid(startPosixT,endPosixT,returnDir,disp_flag,prevVidIdx)
% PLAYVID Plays video from startPosixT to endPosixT
% If start and end times belong to different video, only the video that
% contains start timestamp will be played
%
% [Caution] unixTimeStamp should be from rlog! 
% For general usage, need to fix hour gap, second gap.
% In our Sejong Dataset, unix timestamp has 9 hour and 10 seconds
% difference with true unix timestamp.
% Step 1: Find date folder
% Step 2: Find rlog folder
% Step 3: Find video folder
% Step 4: Find starting frame and collect video frames
% Step 5: Play video
    DT_start = datetime(startPosixT,'ConvertFrom','posixtime');
    year_start = DT_start.Year; month_start = DT_start.Month; day_start = DT_start.Day;
    % disp([year_start, month_start, day_start])
    % disp([DT_start.Hour+9, DT_start.Minute, DT_start.Second])
    DT_end = datetime(endPosixT,'ConvertFrom','posixtime');
    year_end = DT_end.Year; month_end = DT_end.Month; day_end = DT_end.Day;
    
    if seconds(DT_end - DT_start) > 60
        error('Current queried video length is over 1 minute. Please check if the start and end Posix timestamps are set correctly')
    end

    search_str_start = GetSearchString(year_start,month_start,day_start);
    search_str_end = GetSearchString(year_end,month_end,day_end);
    if ispc
        cd('/SJ_Dataset/2023/');
    elseif isunix
        cd('/mnt/hdd1/SJ_Dataset/2023/')
    end
    folders = dir;
    flag = false;
    for i=1:length(folders)
        folder_name= folders(i).name;
        if strcmp(search_str_start,folder_name)
            flag = true;
            
            cd([folder_name,'/rlog/']);
            
            folders2 = dir;
            j = 1;
            prevPosixT = 0;
            
            delIdxs = [];
            for j=1:length(folders2)
                folder_name2 = folders2(j).name;
                if length(folder_name2) < 3
                    delIdxs = [delIdxs, j];
                elseif strcmp(folder_name2(end-2:end),'mat')
                    delIdxs = [delIdxs, j];
                elseif strcmp(folder_name2,'ErrorFiles')
                    delIdxs = [delIdxs, j];
                end
            end
            folders2(delIdxs) = [];

            j = 1;
            while j <= length(folders2)
                % Format
                %   Y  M  D   H  MI S
                % XXXX-XX-XX--XX-XX-XX
                folder_name2 = folders2(j).name;
                % disp(length(folder_name2))
                if length(folder_name2) == 20
                    Y = str2double(folder_name2(1:4));
                    M = str2double(folder_name2(6:7));
                    D = str2double(folder_name2(9:10));
                    H = str2double(folder_name2(13:14)) - 9; % 9 Hour Gap
                    MI = str2double(folder_name2(16:17));
                    S = str2double(folder_name2(19:20)); % 10 seconds Gap
    
                    folderT = datetime(Y,M,D,H,MI,S);
                    % disp(folderT)
                    folderPosixT = posixtime(folderT);
                    
                    if folderPosixT > startPosixT && prevPosixT < startPosixT
                        break;
                    else
                        prevPosixT = folderPosixT;
                        j = j + 1;
                    end
                else
                    j = j + 1;
                end
            end
            
            % if j == length(folders2) + 1
            % 
            %     % error('No matched data. Please check if the timestamp of data is correct');
            % end
            
            % Folder with folder_name(j-1).name is the matched folder
            cd(folders2(j-1).name);
            folder_name2 = folders2(j-1).name;

            folders3 = dir;
            folder_names = [];
            for j=1:length(folders3)
                folder_name3 = folders3(j).name;
                if ~strcmp(folder_name3,'qcamera.m3u8') && ~isnan(str2double(folder_name3))
                    folder_names = [folder_names, convertCharsToStrings(folder_name3)];
                end
            end

            folder_names = natsort(folder_names);

            folderPosixT = prevPosixT;
            dt_start = startPosixT - folderPosixT;
            dt_end = endPosixT - folderPosixT;

            % disp(['Time Displacement: ',num2str(dt)])
            if isempty(prevVidIdx)
                dt_sample = 0;
                j = 1;
            else
                dt_sample = 60*prevVidIdx;
                j = prevVidIdx+1;
            end

            while j <= length(folder_names)
                folder_name3 = convertStringsToChars(folder_names(j));
                % disp(['Searching Folder: ',folder_name3])
                cd(folder_name3);
                vid = VideoReader('qcamera.ts');
                % dt_sample = dt_sample + vid.Duration;
                dt_sample = dt_sample + 60;
                % disp(vid.Duration)  %cho
                %  vid.Duration

                if dt_sample > dt_start
                    disp(['Video found at folder /SJ_Dataset/2023/',folder_name,'/rlog/',folder_name2,'/',folder_name3])
                    % cd('/SJ_Dataset/MatlabFiles/github/');
                    % return %cho

                    if dt_sample > dt_end
                        % disp([dt_start,dt_end,dt_sample])
                        disp(['Video found at folder /SJ_Dataset/2023/',folder_name,'/rlog/',folder_name2,'/',folder_name3])
                        if disp_flag
                            
                        end
                        end_flag = true;
                    else
                        warning(['Video found at folder /SJ_Dataset/2023/',folder_name,'/rlog/',folder_name2,'/',folder_name3,' , but queried end time is at different video. Playing current video till the end'])
                        end_flag = false;
                    end
                    VidIdx = str2double(folder_name3);
                    break;                    
                else
                    cd('..')
                    j = j + 1;
                end  
            end

            if j == length(folders3) + 1
                error('No matched data. Please check if the timestamp of data is correct')
            end
            
            % dt_sample = dt_sample - vid.Duration;
            dt_sample = dt_sample - 60;


            vidStartT = dt_start - dt_sample;
            vidEndT = dt_end - dt_sample;
            
            disp(vidStartT)
            % disp([vidStartT,vidEndT])
            % disp([vid.Duration,vid.NumFrames/vid.FrameRate])
            % disp(['Queried time in video: ',num2str(vidT)])

            numFrames = vid.NumFrames;
            fps = numFrames/60;
            % fps = vid.FrameRate;
            disp(numFrames)
            
            vidWidth = vid.Width; vidHeight = vid.Height;
            % disp(vidStartT)
            startFrame = floor(fps * vidStartT); 
            endFrame = floor(fps * vidEndT);

            j = 1;
            while j < startFrame
                readFrame(vid);
                j = j + 1;
            end

            mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);
            if ~end_flag
                % If queried end time belongs to different video, only the 
                % video that contains start time will be played till the
                % end.
                j = 1;
                while hasFrame(vid)
                    mov(j).cdata = readFrame(vid);
                    j = j + 1;
                end
            else
                % If queried end time belongs to the same video as start
                % time, 
                while j <= endFrame
                    mov(j-startFrame+1).cdata = readFrame(vid);
                    j = j + 1;
                end
            end
            
            hf = figure(100);
            % vidWidth = 1440; vidHeight = 960;
            set(hf,'position',[1000,500,vidWidth,vidHeight]);
            movie(hf,mov,1,fps);
        end
    end
    
    if ~flag
        error('No matched data. Please check if the timestamp of data is correct')
    end
    
    % Return back to original folder
    if strcmp(returnDir,'Github')
        if ispc
            cd('/SJ_Dataset/MatlabFiles/github/');
        elseif isunix
            cd('/mnt/hdd1/SJ_Dataset/MatlabFiles/github/');
        end
    elseif strcmp(returnDir,'Damper')
        cd D:\2023\'연구실 과제'\Damper\'2차년도 연구'\
    end
end

%% Get Search String
function search_str = GetSearchString(year,month,day)
    if month < 10
        month_str = ['0',num2str(month)];
    else
        month_str = num2str(month);
    end

    if day < 10
        day_str = ['0',num2str(day)];
    else
        day_str = num2str(day);
    end
    search_str = [num2str(year),'-',month_str,'-',day_str];
end