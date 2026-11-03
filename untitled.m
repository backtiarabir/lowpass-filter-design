function playAudio(data, type)
        if ~isempty(timerObj) && isvalid(timerObj)
            stop(timerObj);
        end
        player = audioplayer(data, fs);
        timerObj = timer('ExecutionMode', 'fixedRate', ...
                         'Period', 0.05, ...
                         'TimerFcn', @updatePlot);

        title(hAx, [type ' Audio Signal']);
        play(player);
        start(timerObj);

        function updatePlot(~, ~)
            if isplaying(player)
                idx = get(player, 'CurrentSample');
                if idx > 0
                    windowSize = fs * 0.2;
                    startIdx = max(1, idx - windowSize);
                    plot(hAx, t(startIdx:idx), data(startIdx:idx), 'r');
                    xlim(hAx, [t(startIdx), t(idx)]);
                end
            else
                stop(timerObj);
            end
        end
    end

    function pauseAudio()
        if ~isempty(player)
            pause(player);
        end
    end
end 
