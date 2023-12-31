# TDoA Analysis
Time Difference of Arrival Analysis for LoRa measurements

The purpose of this project is to provide a solution for passive positioning of radio transmitters by using several receivers with accurate timing (GNSS, ...) placed at different known positions. Originally this software was used for passively tracking experimental rockets equipped with LoRa transmitters. By using 433 MHz LoRa transmitters and receivers a longitude/latitude accuracy in the order of 100 m is possible.

## Receiver hardware / firmware
For this project the interrupt pin of Semtech SX LoRa chips was used to measure the reception time of LoRa packets. A GNSS module provides an accurate time reference by using it´s pulse per second (PPS) output. The timer of modern microcontollers can be configured to measure the time between the last PPS pulse and LoRa interrupts. As the microcontroller clock can drift significantly over time, the actual clock frequency has to be measured by configuring a second timer to count the clock cycles between consecutive PPS pulses. For every interrupt event the measured time, the receiver position and clock frequency is stored in a file. For every entry an new line is added to this half binary text file. Every line begins with an ASCII sync pattern which is followed by the binary data and ended with a line feed.
The byte order is as follows:

Bytes 0 to 4: ASCII sync pattern: 'data:'<br>
Bytes 5 to 8: Latitude multiplied by 10^7 (32 bit signed integer)<br>
Bytes 9 to 12: Longitude multiplied by 10^7 (32 bit signed integer)<br>
Bytes 13 to 14: Altitude in m (16 bit signed integer)<br>
Byte 15: Year minus 2000 (8 bit unsigned integer)<br>
Byte 16: Month (8 bit unsigned integer)<br>
Byte 17: Day (8 bit unsigned integer)<br>
Byte 18: Hour (8 bit unsigned integer)<br>
Byte 19: Minute (8 bit unsigned integer)<br>
Byte 20: Second (8 bit unsigned integer)<br>
Byte 21 to 24: Clock cycles since last PPS pulse (32 bit unsigned integer)<br>
Byte 25 to 28: Clock cycles per second / actual clock frequency (32 bit unsigned integer)<br>
Byte 29: Line feed<br>

## Matlab TDoA Analysis
First open the *main.m* script and define the number of used receivers by setting *num_receivers* accordingly. Then the number of different channels per receiver by setting *num_loras*. The recorded TDoA files have to be copied into the *tdoa_data* folder. The naming of the TDoA files has to follow a strict rule. Each file name begins with the receiver number, is followed by '*_LORA*' and then the channel number. Hence, for example for channel 2 of receiver 3 use *3_LORA2.txt*. Running *main.m* should now calculate the transmitter positions according to the TDoA data. After finishing, these positions are exported in the *KML* format into the *export* folder. There will be a *KML* track for each channel/transmitter.
