function plotAndOutputIHR(portIn, Fs, windowWidth)
%plotAndOutputIHR Plot Incoming ECG Waveform and Output Instantaneous Heart
% Rate. Fs in Hz (set to 1/Ticker period) and windowWidth in seconds.

    port = serialport(portIn,9600); % initialize serial port

    datapoints = []; % array of data
    time = []; % array of times
    numPoints = 0; % counting number of points
    

    % peak arrays and times
    peaks = [];
    peakTimes = [];

    xWidth = Fs*windowWidth; % calculate windowWidth in indices using Fs

    figure % new figure each time, can comment out

    % loop forever, hit ctrl+c in MATLAB window to cancel
    t1 = -1; % initialize time to a negative number to show it is unused
    onPeak = false; % keep track of whether or not we are above the threshold or not
    oldMaxIndex = 1; % keep track of the index of our peak
    newMaxIndex = 1; % keep track of the old max index
    calculated = true; % keep track of whether or not we've calculated IHR for a given peak
    maxPoint = 0; % value of max point
    threshold = 57000;
    hold on

    while(true)
        datapoint = str2double(port.readline); % get datapoint, one per line
        
        datapoints = [datapoints,datapoint]; % save datapoint
        time = [time,numPoints*1/(Fs)]; % update time array

        numPoints = numPoints + 1; % increment number of points

        % plot
        plot(time,datapoints);

        % addatapointust to window width
        if (xWidth < numPoints)
            xlim([time(numPoints - xWidth) time(numPoints)])
        else
            xlim([0 windowWidth]);
        end
        
        % maintain full y axis range, feel free to addatapointust
        ylim([0 70000]);

        % Peak detector example: output when value is over 40k. 
        % YOUR datapointOB: update this so that peaks and peakTimes only get added
        % to for an actual R peak.
        if (datapoint > 40000)
            peaks = [peaks,datapoint];
            peakTimes = [peakTimes,time(end)];
        end
        
        

            % if our signal is above the threshold, update maxIndex, onPeak,
            % calculated accordingly
%             if (datapoint > threshold)
%                 calculated = true;
% 
%                 % YOUR CODE HERE
%                 if (onPeak == true)
%                     if (maxPoint<datapoint)
%                         maxPoint = datapoint;
%                         newMaxIndex = numPoints;
%                     end
%                     if (oldMaxIndex ~=1)
%                         calculated = true;
%                     end
% 
%                 else 
%                   onPeak = true; 
%                   maxPoint = datapoint; 
%                   newMaxIndex = numPoints; 
% 
% 
%                 end
% 
% 
%             % if our signal is below the threshold, update onPeak, calculated
%             % accordingly, and decide whether or not to plot and calculate IHR
%             else
% 
%             % YOUR CODE HERE
%                 onPeak = false; 
%                 if (calculated == true)
%                     if ((oldMaxIndex ~=1) && (newMaxIndex ~=1))    
%                         heartRate = ihr(time(oldMaxIndex),time(newMaxIndex))
%                         plot(time(oldMaxIndex),datapoints(oldMaxIndex),'o')
%                     end
%                     oldMaxIndex = newMaxIndex; 
%                     calculated= false;
%                 else 
% 
%                 end
% 
%             end
        
        % plot peaks
        plot(peakTimes,peaks,'Color','red','Marker','o','LineStyle','none')
        

        % Code seems to slow down a lot with these on...feel free to try it
        % xlabel('Time (seconds');
        % ylabel('ADC count');
    end


end

function heartRate = ihr(t1,t2)
    heartRate = 1/(t2 - t1)*60;
end

