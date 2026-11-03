function HIGH()

    % --- Load and filter audio ---
    filePath = 'C:\Users\USER\Downloads\hp\Design and Implementation of a LowpassHighpass Filter for Enhancing the Quality of Speech Signal Captured in Noisy Environment\New folder\test01_20s.wav';
    [x, fs] = audioread(filePath);

    fc = 1000;
    order = 6;
    [b, a] = butter(order, fc/(fs/2), 'high');
    y = filter(b, a, x);
    y = y / max(abs(y));

    t = (0:length(x)-1) / fs;

    % --- Create figure ---
    hFig = figure('Name', 'Real-Time Audio Viewer', 'Position', [100 100 800 400]);

    % --- Plot axis ---
    hAx = axes('Parent', hFig, 'Position', [0.08 0.3 0.85 0.65]);
    ylim(hAx, [-1 1]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(hAx, 'Audio Signal');
    grid on;

    % --- Buttons ---
    uicontrol('Style', 'pushbutton', 'String', 'Play Original', ...
        'Position', [150 30 100 30], 'Callback', @(~,~) playAudio(x, 'Original'));

    uicontrol('Style', 'pushbutton', 'String', 'Play Filtered', ...
        'Position', [300 30 100 30], 'Callback', @(~,~) playAudio(y, 'Filtered'));

    uicontrol('Style', 'pushbutton', 'String', 'Pause', ...
        'Position', [450 30 100 30], 'Callback', @(~,~) pauseAudio());

    % --- Persistent objects ---
    persistent player timerObj

    % === PLAY FUNCTION ===
    function playAudio(data, type)

        % Stop previous timer safely
        if ~isempty(timerObj) && isvalid(timerObj)
            stop(timerObj);
            delete(timerObj);
        end

        player = audioplayer(data, fs);

        timerObj = timer('ExecutionMode', 'fixedRate', ...
                         'Period', 0.05, ...
                         'TimerFcn', @updatePlot);

        title(hAx, [type ' Audio Signal']);
        play(player);
        start(timerObj);

        % === UPDATE PLOT SAFELY (ERROR-FREE) ===
        function updatePlot(~, ~)
            if isplaying(player)
                idx = get(player, 'CurrentSample');

                if idx <= 1
                    return;
                end

                windowSize = round(fs * 0.2);
                startIdx = max(1, idx - windowSize);

                % Safe & sorted axis limits (NO MORE ERRORS!)
                plot(hAx, t(startIdx:idx), data(startIdx:idx), 'r');
                xlim(hAx, sort([t(startIdx) t(idx)]));

            else
                stop(timerObj);
            end
        end
    end

    % === PAUSE FUNCTION ===
    function pauseAudio()
        if ~isempty(player)
            pause(player);
        end
    end

end

