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
