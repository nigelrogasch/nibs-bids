##  --------------- 28.10.2025  ---------------

### 1. MarkerID -> StimID

The term MarkerID originated from TMS use cases, where stimulation targets are typically discrete points defined in space. However, other NIBS modalities—such as tES and tUS—may use spatially extended or distributed stimulation, and sometimes do not rely on explicit “markers” at all. 
To unify these modalities under a common metadata framework, we propose introducing a general-purpose identifier:
StimID — Universal stimulation unit identifier
A **StimID** is a unique identifier referencing a unit of stimulation (e.g., a TMS pulse, a tES electrode/channel, a tUS focus) across BIDS NIBS files. 
It replaces MarkerID and allows for consistent referencing across modalities.

### 2. added parameter "MarkerName" in _nibs.tsv _markers.tsv for TMS section

### 3. TMS section, StimulusMode -> TmsStimMode

## --------------- 29.10.2025  ---------------

### 1. 

`NIBSCoordinateSystem` -> coordsystem.json
`NIBSCoordinateUnits` -> coordsystem.json
`NIBSCoordinateSystemDescription` -> coordsystem.json

### 2. 

`RmsDeviation` -> `AnatomicalLandmarkRmsDeviation`          
`RmsDeviationUnits` -> `AnatomicalLandmarkRmsDeviationUnits`             
`RmsDeviationDescription` -> `AnatomicalLandmarkRmsDeviationDescription`

### 3. 

`Matrix_4x4` -> `CoilTransform`

### 4. 

`CoilDriver` -> `TargetingMethod`

### 5.

`BurstDuration` -> _nibs.tsv (tms section)

### 6.

`StimulationDuration` -> nibs.tsv (tms section)
`RampUpDuration` -> nibs.tsv (tms section)
`RampDownDuration` -> nibs.tsv (tms section)

## --------------- 05.11.2025  ---------------

### 1. 

`Online vs Offline` -> README.md

### 2. 

`ElectrodeSet` -> _nibs.json

### 3.
 
`StimStepCount` -> `stim_count`

### 4.

`*_.tsv` -> `snake case`

### 5.

README_tUS.md -> merged with README.md
README_tES.md -> merged with README.md

## --------------- 08.12.2025  ---------------

### 1. 

`*_nibs.json` -> `CoilModelName`, `CoilSerialNumber`

### 2.

`marker_name` -> `target_name`

### 3.

`*_nibs.json`, `*_nibs.tsv` -> `coil_handle_direction`

### 4.

added "(Optional)" to descriptions

### 5.

added Appendix A: Examples

## --------------- 22.12.2025  ---------------

1. *rel-<label>* — Relationship to Data Acquisition -> README.md
2. `HeadMeasurements`, `HeadMeasurementsUnits`, `HeadMeasurementsDescription` - *_coordsystem.json -> README.md 
3. `pulse_width` - _nibs.tsv -> README.md 
4. `burst_duration` - _nibs.tsv -> DELETED
5. `train_pulses` -> `train_bursts_number`
6. `train_duration` - _nibs.tsv -> DELETED
7. `repetition_rate` -> `train_burst_rate`
8. `inter_train_interval` -> `inter_train_pulse_interval`
9. `ramp_up_duration` -> DELETED
10. `ramp_down_duration` -> DELETED
11. `stimulus_pulses_number` -> Added
12. `stim_id` -> `target_id`
13. `stim_id` -> NEW
14. `StimulationSystemName` -> `StimulationSystemType`
15. `StimulusSet` -> _nibs.json
16.`tms_stim_mode` -> `StimulusSet` -> _nibs.json
17. current_direction -> PulseCurrentDirection -> `StimulusSet` -> _nibs.json
18. `waveform` -> `StimulusSet` -> _nibs.json
19. `pulse_width` -> `StimulusSet` -> _nibs.json



