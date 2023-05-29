% Table = readtable('C:\Users\youss\OneDrive\Desktop\E90\Data\data-up.txt');
% x= Table(1:1000,1);
% %height = height(x); 
% stackedplot(x);
% y= flip(table2array(x));
function [y, features] = LoadAndAnalyze(filename)
load(filename,"datapoints");
load(filename,"feat");
y = datapoints(1,2:length(datapoints));

y = y';
% Enhanced Mean Absolute Value
f1 = jfemg('emav', y); 
% Average Amplitude Change
f2 = jfemg('aac', y); 
% Waveform Length
f3 = jfemg('wl', y); 
% Maximum Fractal Length 
f4 = jfemg('mfl', y); 
% Root Mean Square
f5 = jfemg('rms', y); 
% Zeros Crossing
opts.thres = 0.01;
f6 = ZeroCrossing(y, opts); 
hzP10 = bandpower(y,200,[1,10]);
hzP20 = bandpower(y,200,[10,20]);
hzP30 = bandpower(y,200,[20,30]);
hzP50 =  bandpower(y,200,[30,50]);
hzP60 =  bandpower(y,200,[50,60]);
hzP100 =  bandpower(y,200,[60,99]);
totalPower = bandpower(y,200,[1,99]);

% Feature vector
features = [length(y), f1, f2, f3, f4, f5, f6, hzP10/totalPower, hzP20/totalPower, hzP30/totalPower, hzP50/totalPower, hzP60/totalPower, hzP100/totalPower];

firstIndex = 0; 
lastIndex = 0;
buffSize = 150; %size of the moving window 
buff = zeros(buffSize,1);
indexBuff=mod(-1,buffSize) ;
total = 0;
average = 0;
diff=0;
confLevel = 2 / sqrt(buffSize);
meanV = mean(y);
thresholdHigh = meanV + 2000;
thresholdLow = meanV - 2000;
counting = false;
plotting = false; 
printed=0;
totalPower = 0;
 




% hold on;
% plot(y);

for j = 1:length(y)
    if (((y(j)> thresholdHigh) || (y(j)<thresholdLow)) && (counting == false)) 
        firstIndex = j;
        buff = zeros(buffSize,1);
        counting = true;
        indexBuff = 1;
        average = 0; 
        diff = 0; 
        full = false;
    end
    
    if (counting==true)
          average = average - buff(indexBuff)./buffSize + y(j)./buffSize;
          buff(indexBuff) = y(j);
          if (indexBuff == buffSize)
            full = true;
          end
          indexBuff = mod((indexBuff),buffSize) + 1;
          

        if ((average > (meanV - 200)) && (average < (meanV + 200))  && full)
            counting = false; 
            lastIndex = j;
%           plotting = true;
            firstIndex
            lastIndex
            hold on
            plot(firstIndex:lastIndex,datapoints(1,firstIndex:lastIndex));
            hold off
            % Enhanced Mean Absolute Value
            f1 = jfemg('emav', y(firstIndex:lastIndex,1)); 
            % Average Amplitude Change
            f2 = jfemg('aac', y(firstIndex:lastIndex,1)); 
            % Waveform Length
            f3 = jfemg('wl', y(firstIndex:lastIndex,1)); 
            % Maximum Fractal Length 
            f4 = jfemg('mfl', y(firstIndex:lastIndex,1)); 
            % Root Mean Square
            f5 = jfemg('rms', y(firstIndex:lastIndex,1)); 
            % Zeros Crossing
             f6 = ZeroCrossing(y(firstIndex:lastIndex,1), opts);
%             zcd = dsp.ZeroCrossingDetector;
%             f6 = zcd(y(firstIndex:lastIndex,1));
            % Feature vector
            totalPower = bandpower(y(firstIndex:lastIndex,1),200,[1,99]); 
            hzP10 = bandpower(y(firstIndex:lastIndex,1),200,[1,10]);
            hzP20 = bandpower(y(firstIndex:lastIndex,1),200,[10,20]);
            hzP50 =  bandpower(y(firstIndex:lastIndex,1),200,[30,50]);
            hzP60 =  bandpower(y(firstIndex:lastIndex,1),200,[50,60]);
            hzP100 =  bandpower(y(firstIndex:lastIndex,1),200,[60,99]);
            features = [features ;lastIndex - firstIndex ,f1, f2, f3, f4, f5, f6, hzP10/totalPower, hzP20/totalPower, hzP30/totalPower, hzP50/totalPower, hzP60/totalPower, hzP100/totalPower];
             
            
        end
    end    
end


% FOURIER ANALYSIS

fourierY = y.';
Fs = 200;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(fourierY);             % Length of signal
t = (0:L-1)*T;        % Time vector

Y1 = fft(fourierY);
Y = Y1(2:end);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
% figure();
% plot(f,P1) 
% title("Single-Sided Amplitude Spectrum of X(t)")
% xlabel("f (Hz)")
% ylabel("|P1(f)|")


% plot(y) 

% fast = fft(y);
% 
% n = length(y);          % number of samples
% f = (2:n-1)*(200/n);     % frequency range
% fast1= fast(2:129,1);  
% power = abs(fast1).^2/n;    % power of the DFT
% 
% plot(f,power)
% xlabel('Frequency')
% ylabel('Power')

% hold off;
end


function ZC = ZeroCrossing(X,opts)
% Parameter
thres = 0.01;    % threshold
if isfield(opts,'thres'), thres = opts.thres; end
N  = length(X); 
ZC = 0;
for k = 1 : N - 1
  if ((X(k) > 20000  &&  X(k+1) < 20000)  ||  (X(k) < 20000  &&  X(k+1) > 20000)) ...
      && (abs(X(k) - X(k+1)) >= thres)
    
    ZC = ZC + 1;
  end
end
end



