## Mock experiments for NIBS-BIDS examples

Below are some basic TMS experiments to test the current NIBS-BIDS framework.
Outcome data files are described which should be converted into BIDS format
for a single participant (sub001). Hardware and pulse shape are dealers choice.

### 1. Online motor TMS-EMG experiment

TMS applied during EMG recording. No neuronavigation.

* Resting motor threshold (no recorded data) 
* Active motor threshold (no recorded data)
* Intensity required for MEP of 1 mV (no recorded data)
* Single pulse MEPs (input-output curve) - 10 trials at 90%, 100%, 110% and 120% RMT, interleaved
* SICI (2 ms ISI) - 10 trials single pulse, 10 trials paired pulse, interleaved. Conditioning pulse = 80% AMT, Test pulse = S1mV.

### 2. Online prefrontal TMS-EEG experiment
TMS applied to prefrontal cortex during EEG recording. Coil position recorded using neuronavigation
with each trial. 

* Resting motor threshold (no recorded data) 
* Single pulse TEPs (120% RMT) - 100 trials