/*
 * Copyright (c) 2017-2020 Arm Limited and affiliates.
 * SPDX-License-Identifier: Apache-2.0
 */

#include "mbed.h"
#include <chrono>
#include <cmath>
#include <cstdio>

// Initialize a pins to perform analog input and digital output functions
AnalogIn   ain(A0);
DigitalOut dout(LED1);
Timer t1;
using namespace std::chrono;
int datapoint = 0;
int numPoints = 0;
bool onPeak = false; /* keep track of whether or not we are above the threshold or not */
int oldMaxIndex = 0;  /*keep track of the index of our peak*/
int newMaxIndex = 0; /* keep track of the old max index */
bool calculated = true; /* keep track of whether or not we've calculated IHR for a given peak */
int maxPoint = 0; /* value of max point */
int threshold = 50000;

BufferedSerial pc(USBTX,USBRX); // add baud rate as an optional arg
char buff[6]; // largest value is 65535, new line
float heartRate;

Ticker sample;

float ihr ( float t1, float t2) { 
    return 1/(t2 - t1)*60;
}

void sampleADC(){
    unsigned short value = ain.read_u16();

    buff[0] = value/10000 + 0x30;
    value = value - (buff[0]-0x30)*10000;
    
    buff[1] = value/1000 + 0x30;
    value = value - (buff[1]-0x30)*1000;
    
    buff[2] = value/100 + 0x30;
    value = value - (buff[2]-0x30)*100;
    
    buff[3] = value/10 + 0x30;
    value = value - (buff[3]-0x30)*10;
    
    buff[4] = value/1 + 0x30;
    
    pc.write(&buff,6);
}

void displayHeartRate(){
    unsigned short value = ain.read_u16();
    datapoint = value;
    numPoints++;
            if (value > threshold){
                calculated = true;
                if (onPeak == true){
                    if (maxPoint<datapoint){
                        maxPoint = datapoint;
                        newMaxIndex = numPoints;
                    }
                    if (oldMaxIndex !=0) {
                        calculated = true;
                    }
            } else {
                  onPeak = true; 
                  maxPoint = datapoint; 
                  newMaxIndex = numPoints; 
            }
            }else{
            // if our signal is below the threshold, update onPeak, calculated
            //  accordingly, and decide whether or not to plot and calculate IHR
                onPeak = false; 
                maxPoint = 0;
                if (calculated == true) {
                    if ((oldMaxIndex !=0) && (newMaxIndex !=0)) {   
                        heartRate = ihr(oldMaxIndex,newMaxIndex);
                        printf("%.3f \n", heartRate);
                    }
                    // oldMaxIndex = newMaxIndex; 
                    // calculated= false;
                    // buff[0] = heartRate/10000 + 0x30;
                    // heartRate = heartRate - (buff[0]-0x30)*10000;
                    
                    // buff[1] = heartRate/1000 + 0x30;
                    // heartRate = heartRate - (buff[1]-0x30)*1000;
                    
                    // buff[2] = heartRate/100 + 0x30;
                    // heartRate = heartRate - (buff[2]-0x30)*100;
                    
                    // buff[3] = heartRate/10 + 0x30;
                    // heartRate = heartRate - (buff[3]-0x30)*10;
                    
                    // buff[4] = heartRate/1 + 0x30;
                    
                    // pc.write(&buff,6);

                }
            }

}



int main(void)
{
    // needed to use thread_sleep_for in debugger
    // your board will get stuck without it :(
    #if defined(MBED_DEBUG) && DEVICE_SLEEP
        HAL_DBGMCU_EnableDBGSleepMode();
    #endif
    buff[5] = '\n';

    sample.attach(&displayHeartRate,10ms);

    while (1) {
        thread_sleep_for(10);
    }
}
