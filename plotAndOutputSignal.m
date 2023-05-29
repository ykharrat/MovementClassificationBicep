function plotAndOutputSignal(portIn, Fs, windowWidth)
%plotAndOutputIHR Plot Incoming ECG Waveform and Output Instantaneous Heart
% Rate. Fs in Hz (set to 1/Ticker period) and windowWidth in seconds.

    port = serialport(portIn,14400); % initialize serial port

    datapoints = []; % array of data
    time = []; % array of times
    numPoints = 0; % counting number of points
    feat = []; % keeping track of different features of each signal


    xWidth = Fs*windowWidth; % calculate windowWidth in indices using Fs

    figure % new figure each time, can comment out

    % loop forever, hit ctrl+c in MATLAB window to cancel
    
    firstIndex = 0; 
    lastIndex = 0;
    buffSize = 100; %size of the moving window 
    buff = zeros(buffSize,1);
    indexBuff=mod(-1,buffSize) ;
    average = 0;
    confLevel = 2 / sqrt(buffSize);

    thresholdHigh = 22000;
    thresholdLow = 18000;
    counting = false;



    while(true)
        datapoint = str2double(port.readline); % get datapoint, one per line
        
        datapoints = [datapoints,datapoint]; % save datapoint
        time = [time,numPoints*1/(Fs)]; % update time array

        numPoints = numPoints + 1; % increment number of points



        % adjust to window width
        if (xWidth < numPoints)
            xlim([time(numPoints - xWidth) time(numPoints)])
        else
            xlim([0 windowWidth]);
        end
        
        % maintain full y axis range, feel free to adjust
        ylim([0 70000]);

        
        if (((datapoint> thresholdHigh) || (datapoint<thresholdLow)) && (counting == false)) 
            firstIndex = numPoints;
            buff = zeros(buffSize,1);
            counting = true;
            indexBuff = 1;
            average = 0; 
            full = false;
        end
    
    if (counting==true)
          average = average - buff(indexBuff)./buffSize + datapoint./buffSize;
          buff(indexBuff) = datapoint;
          if (indexBuff == buffSize)
            full = true;
          end
          indexBuff = mod((indexBuff),buffSize) + 1;

        if (((average > 19800) && (average < 20200))  && full)
            counting = false; 
            lastIndex = numPoints;
%           plotting = true;
            firstIndex
            lastIndex
                    % plot
            hold on
            plot(time(1,firstIndex:lastIndex),datapoints(1,firstIndex:lastIndex));
            hold off
            % Enhanced Mean Absolute Value
            f1 = jfemg('emav', datapoints(1,firstIndex:lastIndex)); 
            % Average Amplitude Change
            f2 = jfemg('aac', datapoints(1,firstIndex:lastIndex)); 
            % Waveform Length
            f3 = jfemg('wl', datapoints(1,firstIndex:lastIndex)); 
            % Maximum Fractal Length 
            f4 = jfemg('mfl', datapoints(1,firstIndex:lastIndex)); 
            % Root Mean Square
            f5 = jfemg('rms', datapoints(1,firstIndex:lastIndex)); 
            % Zeros Crossing
            opts.thres = 0.01;
            f6 = jfemg('zc', datapoints(1,firstIndex:lastIndex), opts); 
            % Feature vector
            feat = [feat ; firstIndex, lastIndex, f1, f2, f3, f4, f5, f6];
            
        end
    end
        
%         % plot peaks
%         hold on
%         plot(peakTimes,peaks,'Color','red','Marker','o','LineStyle','none');
%         hold off
        

        % Code seems to slow down a lot with these on...feel free to try it
        % xlabel('Time (seconds');
        % ylabel('ADC count');
         save('testDataAt200Hz14400Baud-side-2','datapoints','feat');
    end


end