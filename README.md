# NIBS-BIDS (BEP037)

The NIBS-BIDS repository contains supporting files for the NIBS-BIDS extension proposal.

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

### 3. Offline prefrontal iTBS experiment
iTBS applied to prefrontal cortex. Working memory performance (no neural recordings)
assessed before and after stimulation. Coil position recorded using neuronavigation.

* Resting motor threshold (no recorded data) 
* Pre working memory task (beh file)
* iTBS (70% RMT, 600 pulses, standard parameters)
* Post working memory task (beh file)

### 4. (TMS-BIDS team): Multimodal TMS Experiment During Product Preference Decision-Making
In this neuro-marketing study, participants evaluate product preferences (Brand A vs Brand B) while undergoing brain stimulation.
During the decision-making task, the following data are collected simultaneously:
- EEG (to monitor cognitive responses),
- fNIRS (to track prefrontal cortex activation),
- Behavioral data — including response times and button presses,
- TMS is applied to the dorsolateral prefrontal cortex (dlPFC) during evaluation phases to modulate decision-related activity.

* Protocol: Single-pulse TMS
* Target: dlPFC 
* Intensity: 110% of RMT
* Total Pulses: 60 (10 pulses per block, 6 blocks total)
* Neuronavigation: Yes, coil position recorded for each pulse

### 5. (TMS-BIDS team): Combined TMS Motor Study — Mixed Online/Offline Stimulation
This example demonstrates a realistic multi-session experiment combining both offline and online transcranial magnetic stimulation (TMS) protocols targeting the motor cortex and parietal regions.

* Three lab visits on separate days
- Day 1 cTBS over inferior parietal cortex
- Day 2 cTBS over M1
- Day 3 Sham cTBS

* Within each day
- Block A SICI, ICF, single-pulse (SP) baseline with EMG MEPs
- Block B Action-observation task with single-pulse TMS during video observation, EMG MEPs recorded
- Block C SICI, ICF, SP post

  ### 6. TMS-EMG plasticity study

  * Protocol
  - RMT
  - 10 trials single pulse MEP (EMG) - S1mV
  - iTBS (standard; 70% RMT)
  - 10 trials single pulse MEP (EMG) - S1mV
