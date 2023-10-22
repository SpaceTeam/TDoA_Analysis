# TDoA Analysis
Time Difference of Arrival Analysis for LoRa measurements

The purpose of this project is to provide a solution for passive positioning of radio transmitters by using several receivers with accurate timing (GNSS, ...) placed at different known positions. Originally this software was used for passively tracking experimental rockets equipped with LoRa transmitters. By using 433 MHz LoRa transmitters and receivers a longitude/latitude accuracy in the order of 100 m is possible.

## Receiver hardware / firmware
For this project the interrupt pin of Semtech SX LoRa chips was used to measure the reception time of LoRa packets. A GNSS module provides an accurate time reference by using it´s pulse per second (PPS) output. The timer of modern microcontollers can be configured to measure the time between the last PPS pulse and LoRa interrupts. As the microcontroller clock can drift significantly over time, the actual clock frequency has to be measured by configuring a second timer to count the clock cycles between consecutive PPS pulses. For every interrupt event the measured time, the receiver position and clock frequency is stored.

## Matlab TDoA Analysis
