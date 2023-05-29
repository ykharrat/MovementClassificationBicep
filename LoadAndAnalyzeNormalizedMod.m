% Table = readtable('C:\Users\yUPouss\OneDrive\Desktop\E90\Data\data-up.txt');
% x= Table(1:1000,1);
% %height = height(x); 
% stackedplot(x);
% yUP= flip(table2arrayUP(x));
function [yUP, featuresTest, Class] = LoadAndAnalyzeNormalizedMod(filename, Class,featuresTest)
load(filename,"datapoints");
load(filename,"feat");
yUP = datapoints(1,2:length(datapoints));

yUP = yUP';
meanV = mean(yUP);
% stdV = std(yUP); 
yUP = (yUP - meanV); 
% Enhanced Mean Absolute Value
f1 = jfemg('emav', yUP); 
% Average Amplitude Change
f2 = jfemg('aac', yUP); 
% Waveform Length
f3 = jfemg('wl', yUP); 
% Maximum Fractal Length 
f4 = jfemg('mfl', yUP); 
% Root Mean Square
f5 = jfemg('rms', yUP); 
% Zeros Crossing
opts.thres = 0.01;
f6 = ZeroCrossing(yUP, opts); 
hzP10 = bandpower(yUP,200,[1,10]);
hzP20 = bandpower(yUP,200,[10,20]);
hzP30 = bandpower(yUP,200,[20,30]);
hzP50 =  bandpower(yUP,200,[30,50]);
hzP60 =  bandpower(yUP,200,[50,60]);
hzP100 =  bandpower(yUP,200,[60,99]);
totalPower = bandpower(yUP,200,[1,99]);

% Feature vector
% featuresTest = [length(yUP), f1, f2, f3, f4, f5, f6, hzP10/totalPower, hzP20/totalPower, hzP30/totalPower, hzP50/totalPower, hzP60/totalPower, hzP100/totalPower];
%featuresTest = [];
firstIndex = 0; 
lastIndex = 0;
endSize = 7; %size of the inactive points for the end of the signals
buffSize = 100; %size of the moving window 
buff = zeros(buffSize,1);
indexBuff=mod(-1,buffSize) ;
total = 0;
average = 0;
diff=0;
confLevel = 2 / sqrt(buffSize);

thresholdHigh = 2000;
thresholdLow = -2000;
counting = false;
plotting = false; 
printed=0;
totalPower = 0;
 
or= 1;



% hold on;
 plot(yUP);

for j = 1:length(yUP)
    if (((yUP(j)> thresholdHigh) || (yUP(j)<thresholdLow)) && (counting == false)) 
        firstIndex = j;
        buff = zeros(buffSize,1);
        counting = true;
        indexBuff = 1;
        average = 0; 
        diff = 0; 
        full = false;
    end
    
    if (counting==true)
          average = average - buff(indexBuff)./buffSize + yUP(j)./buffSize;
          buff(indexBuff) = yUP(j);
          if (indexBuff == buffSize)
            full = true;
          end
          indexBuff = mod((indexBuff),buffSize) + 1;
        closeCondition = true;
        if (full)
            for s = 1:endSize
                if ( ( yUP(j-s) < (-250) )||( yUP(j-s) > (250)) )
                    closeCondition = false;
                end
            end
        end
          

        if ( full && closeCondition)
            or = or * -1;
            counting = false; 
            lastIndex = j;
%           plotting = true;
            firstIndex
            lastIndex
            hold on
            plot(firstIndex:lastIndex,yUP(firstIndex:lastIndex,1));
            hold off
            % Enhanced Mean Absolute Value
            f1 = jfemg('emav', yUP(firstIndex:lastIndex,1)); 
            % Average Amplitude Change
            f2 = jfemg('aac', yUP(firstIndex:lastIndex,1)); 
            % Waveform Length
            f3 = jfemg('wl', yUP(firstIndex:lastIndex,1)); 
            % Maximum Fractal Length 
            f4 = jfemg('mfl', yUP(firstIndex:lastIndex,1)); 
            % Root Mean Square
            f5 = jfemg('rms', yUP(firstIndex:lastIndex,1)); 
            % Zeros Crossing
            opts.thres = 0.01;
            f6 = jfemg('zc', yUP(firstIndex:lastIndex,1), opts);
            % LogTeagerKaiserEnergyOperator
            f7 = jfemg('ltkeo', yUP(firstIndex:lastIndex,1));

            
            % Feature vector
            totalPower = bandpower(yUP(firstIndex:lastIndex,1),200,[1,99]); 
            hzP10 = bandpower(yUP(firstIndex:lastIndex,1),200,[1,10]);
            hzP20 = bandpower(yUP(firstIndex:lastIndex,1),200,[10,20]);
            hzP50 =  bandpower(yUP(firstIndex:lastIndex,1),200,[30,50]);
            hzP60 =  bandpower(yUP(firstIndex:lastIndex,1),200,[50,60]);
            hzP100 =  bandpower(yUP(firstIndex:lastIndex,1),200,[60,99]);
            featuresTest = [featuresTest ;lastIndex - firstIndex ,f1, f2, f3, f4, f5, f6,f7, hzP10/totalPower, hzP20/totalPower, hzP30/totalPower, hzP50/totalPower, hzP60/totalPower, hzP100/totalPower];
            Class = [Class; "SIDE"];
        end
    end
    
%     if (plotting == true)
%         printed = printed + 1;
%         subPlot = yUP(firstIndex:lastIndex, 1);
%         plot(subPlot, 'o');
%         plotting = false;
%     end


% Apply wavelet transform
% level = 4; % level of decomposition
% wname = 'db4'; % type of wavelet
% [coeffs, l] = wavedec(emg_data, level, wname);
% 
% % Extract features
% features = zeros(1, (2^level)-1); % initialize feature vector
% for i = 1:(2^level)-1
%     subband_coeffs = coeffs(l(i)+1:l(i+1));
%     features(i) = std(subband_coeffs); % example feature: standard deviation of subband coefficients
% end
 
end


% FOURIER ANALyUPSIS

fourierY = yUP.';
Fs = 200;            % Sampling frequencyUP                    
T = 1/Fs;             % Sampling period       
L = length(fourierY);             % Length of signal
t = (0:L-1)*T;        % Time vector

yUP1 = fft(fourierY);
fourierY = yUP1(2:end);
P2 = abs(fourierY/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
% figure('Name','power normalized')
% plot(f,P1) 
% title("Single-Sided Amplitude Spectrum of X(t)")
% xlabel("f (Hz)")
% ylabel("|P1(f)|")

% downTable = arrayUP2table(featuresTest);
% Default heading for the columns will be A1, A2 and so on. 
% yUPou can assign the specific headings to yUPour table in the following manner
%  downTable.Properties.VariableNames(1:14) = ["length in points","Enhanced Mean Absolute Value",	"Average Amplitude Change",	"WaveFormLength", "Maximum Fractal Length", "Root Mean Square",	"Zeros Crossing","LogTeagerKaiserEnergyOperator", "PowerHz[1,10]","PowerHz[10,20]",	"PowerHz[20,30]", "PowerHz[30,50]",	"PowerHz[50,60]",	"PowerHz[60,99]"];
% downTable = addvars(downTable,Class,'Before',"length in points");
% totalTable = [setVariable; setVariable1];
% plot(yUP) 

% fast = fft(yUP);
% 
% n = length(yUP);          % number of samples
% f = (2:n-1)*(200/n);     % frequencyUP range
% fast1= fast(2:129,1);  
% power = abs(fast1).^2/n;    % power of the DFT
% 
% plot(f,power)
% xlabel('FrequencyUP')
% yUPlabel('Power')

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



