# NIBS: Transcranial Electrical Stimulation section.

## 1. Detailed overview of data structure

### 1.1 `*_coordsystem.json` — Coordinate Metadata

A _coordsystem.json file is used to specify the fiducials, the location of anatomical landmarks, and the coordinate system and units in which the position of landmarks or tES stimulation targets is expressed. 
Anatomical landmarks are locations on a research subject such as the nasion (for a detailed definition see the coordinate system appendix).
The _coordsystem.json file is REQUIRED for navigated tES stimulation datasets. If a corresponding anatomical MRI is available, the locations of anatomical landmarks in that scan should also be stored in the _T1w.json file which accompanies the tES data.

```
| Field                                           | Type    | Description                                                                                                                                                                                                                                                                     				| Units / Levels                      |
| ----------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 				| ----------------------------------- |
| `ImageData`                                     | string  | Description of the anatomical data used for co-registration. Includes Levels: DICOM, NIFTI, MR-less.                                                                                                                                                                            				| Levels: `DICOM`, `NIFTI`, `MR-less` |
| `IntendedFor`                                   | string  | Path to the anatomical file this coordinate system refers to. BIDS-style path. (example: `bids::sub-01/ses-01/anat/sub-01_T1w.nii.gz`)                                                                                                                                          				| BIDS path                           |
| `NIBSCoordinateSystem`						  | string  | Name of the coordinate system used to define the spatial location of stimulation targets. Common values for TUS include: IndividualMRI, MNI152NLin2009cAsym, or CapTrak.																														|									  |	
| `NIBSCoordinateUnits`							  | string  | Units used to express spatial coordinates in *_markers.tsv. Typically mm (millimeters) for MRI-based spaces.																																													|									  |
| `NIBSCoordinateSystemDescription`				  | string  | Free-text description providing details on how the coordinate system was defined. This may include registration methods (e.g., neuronavigation, manual annotation), whether coordinates represent the ultrasound focus or entry point, and how the space aligns with anatomical references.	|									  |
| `AnatomicalLandmarkCoordinateSystem`            | string  | Defines the coordinate system for the anatomical landmarks. See the Coordinate Systems Appendix for a list of restricted keywords for coordinate systems. If "Other", provide definition of the coordinate system in `AnatomicalLandmarkCoordinateSystemDescription`.           				| —                                   |
| `AnatomicalLandmarkCoordinateSystemUnits`       | string  | Units of the coordinates of Anatomical Landmark Coordinate System. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                              				| `"m"`, `"mm"`, `"cm"`, `"n/a"`      |
| `AnatomicalLandmarkCoordinateSystemDescription` | string  | Free-form text description of the coordinate system. May also include a link to a documentation page or paper describing the system in greater detail.                                                                                                                          				| Free text                           |
| `AnatomicalLandmarkCoordinates`                 | object  | Key-value pairs of the labels and 3-D digitized locations of anatomical landmarks, interpreted following the `AnatomicalLandmarkCoordinateSystem`. Each array MUST contain three numeric values corresponding to x, y, and z axis of the coordinate system in that exact order.			    | 3D coordinates                      |
| `AnatomicalLandmarkCoordinatesDescription`      | string  | `[x, y, z]` coordinates of anatomical landmarks. NAS — nasion, LPA — left preauricular point, RPA — right preauricular point                                                                                                                                                    				| —                                   |
| `DigitizedHeadPoints`                           | string  | Relative path to the file containing the locations of digitized head points collected during the session. (for example, `"sub-01_headshape.pos"`)                                                                                                                               				| File path or `"n/a"`                |
| `DigitizedHeadPointsNumber`                     | integer | Number of digitized head points during co-registration.                                                                                                                                                                                                                       			    | count                               |
| `DigitizedHeadPointsDescription`                | string  | Free-form description of digitized points.                                                                                                                                                                                                                                      				| —                                   |
| `DigitizedHeadPointsUnits`                      | string  | Unit type. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                                                                                      				| `"m"`, `"mm"`, `"cm"`, `"n/a"`      |
| `AnatomicalLandmarkRmsDeviation`                | object  | `{"RMS":[],"NAS":[],"LPA":[],"RPA":[]}` — deviation values per landmark                                                                                                                                                                                                         				| values per marker                   |
| `AnatomicalLandmarkRmsDeviationUnits`           | string  | Unit of RMS deviation values.                                                                                                                                                                                                                                               				    | `"m"`, `"mm"`, `"cm"`, `"n/a"`      |
| `AnatomicalLandmarkRmsDeviationDescription`     | string  | Description of how RMS deviation is calculated and for which markers.                                                                                                                                                                                                         			    | —                                   |
```

#### Optional Headshape Files (*_headshape.<extension>)

This file is RECOMMENDED.

3D digitized head points that describe the head shape, markers and/or tES electrode locations can be digitized and stored in separate files. 
These files are typically used to improve the accuracy of co-registration between the stimulation target, anatomical data, etc. 

** For example:**

```
sub-<label>/
   └─ ses-<label>/
		└── nibs/
			└── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>]_acq-channels_headshape.pos 
```
These files supplement the DigitizedHeadPoints, DigitizedHeadPointsUnits, and DigitizedHeadPointsDescription fields in the corresponding _coordsystem.json file. Their inclusion is especially useful when sharing datasets intended for advanced spatial analysis or electric field modeling.

### 1.2 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates. Supports multiple navigation systems via flexible fields. 

```
| Field                | Type   | Description                                                                                             | Units    |
| -------------------- | ------ | ------------------------------------------------------------------------------------------------------- | -------- |
| `StimID`             | string | Unique identifier for each marker. This column must appear first in the file.                           | —        |
| `ChannelName` 	   | string | Optional (tES-specific). Human-readable name of the electrode/channel (e.g., AF3, Fp2, Ch7).
| `target_x`           | number | X-coordinate of the target point in millimeters.                                                        | `mm`     |
| `target_y`           | number | Y-coordinate of the target point in millimeters.                                                        | `mm`     |
| `target_z`           | number | Z-coordinate of the target point in millimeters.                                                        | `mm`     |
| `entry_x`            | number | X-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `entry_y`            | number | Y-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `entry_z`            | number | Z-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `ElectricFieldMax_x` | number | X coordinate of max electric field point.                                                               | `mm`     |
| `ElectricFieldMax_y` | number | Y coordinate of max electric field point.                                                               | `mm`     |
| `ElectricFieldMax_z` | number | Z coordinate of max electric field point.                                                               | `mm`     |
| `Timestamp`          | string | Timestamp of the stimulation event in ISO 8601 format.                                                  | ISO 8601 |
```

### 1.3 `*_nibs.json` — Sidecar JSON 

The _nibs.json file is a required sidecar accompanying the _nibs.tsv file. 
It serves to describe the columns in the tabular file, define units and levels for categorical variables, and—crucially—provide structured metadata about the stimulation device, task, and context of the experiment.

Like other BIDS modalities, this JSON file includes:

**Task information:**

- TaskName, TaskDescription, Instructions

**Institutional context:**

- InstitutionName, InstitutionAddress, InstitutionalDepartmentName

**Device metadata:**

- Manufacturer, ManufacturersModelName, SoftwareVersion, DeviceSerialNumber, StimulationSystemName, NavigationSystemName

Additionally, the _nibs.json file introduces a dedicated hardware block called 'ElectrodeSet', which captures detailed physical and electromagnetic parameters of one or more stimulation electrodes used in the session. 
This structure allows precise modeling, reproducibility, and harmonization of electrode-related effects across studies.

* Each entry in 'ElectrodeSet' is an object with the following fields:
```
Field									Type	Description
ElectrodeID								string	Unique identifier for this electrode type (e.g., "el1"), referenced in *_nibs.tsv.
ElectrodeType							string	Type of electrode: pad, HD, ring, custom, etc.
ElectrodeShape							string	Physical shape: rectangular, circular, ring, segmented, etc.
ElectrodeSize							string	Structured field: surface area of the electrode (e.g., 25 cm²).
ElectrodeThickness						string	Structured field: total thickness of the electrode (mm), including any conductive interface (e.g., sponge).
ElectrodeMaterial						string	Material in direct contact with skin: AgCl, rubber, carbon, etc.
ContactMedium							string	Interface material: gel, saline, paste, dry, etc.
Notes									string	(Optional) Free-text description or comments on usage, e.g., "used for return electrode".
```
** Example:**
```
"ElectrodeSet": [
  {
    "ElectrodeID": "el_1",
    "ElectrodeType": "pad",
    "ElectrodeShape": "rectangular",
    "ElectrodeSize": {
      "Value": 25,
      "Units": "cm^2",
      "Description": "Electrode surface area"
    },
    "ElectrodeThickness": {
      "Value": 3,
      "Units": "mm",
      "Description": "Thickness of the electrode including sponge/gel"
    },
    "ElectrodeMaterial": "AgCl",
    "ContactMedium": "saline-soaked sponge",
    "Notes": "Standard rectangular TES pad for M1/SO montage"
  }
]
```

### 1.4 `*_nibs.tsv` — Stimulation Parameters

This section describes all possible fields that may appear in *_nibs.tsv files. 
The fields are grouped into logical sections based on their function and purpose. 
All fields are optional unless stated otherwise, but some are strongly recommended.
The order of parameters in _nibs.tsv follows a hierarchical structure based on their variability during an experiment and their role in defining the stimulation process. Parameters are grouped into three logical blocks:
Grouping fields this way improves readability and aligns with practical data collection workflows.

**Stimulator Device & Configuration**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`ElectrodeID`			|string	| Unique identifier for this electrode type (e.g., "el1"), referenced in *_nibs.ts
|`TesStimMode`			|string	| Type of stimulation mode (tDCS, tACS, tRNS,tPCS (transcranial Pulsed Current Stimulation))
|`ControlMode			|string	| Stimulator control mode: what we stabilize. (current-controlled, voltage-controlled)
```

**Protocol Metadata** 

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
| `ProtocolName`        |string | Name of stimulation protocol (e.g. theta, alpha, working_memory, etc.)
```

**Stimulation Timing Parameters tACS/tDCS**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`Waveform`				|string | Type of waveform (sine, square, pulse, custom)
|`WaveformFrequency`	|number | Frequency of waveform (for tACS) (Hz)
|`NoiseType`			|string | Type of noise (for tRNS) (white, pink, band-limited, custom)
|`StimulationDuration`  |number | Total stimulation time (seconds)
|`RampUpDuration` 		|number | Time to ramp current up (seconds)
|`RampDownDuration`		|number | Time to ramp current down (seconds)
```

**Stimulation Timing Parameters tPCS (transcranial Pulsed Current Stimulation)**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`PulseWidth`			|number | Width of each current pulse (ms)
|`BurstPulsesNumber`	|number | Pulses per burst (if grouped)
|`BurstDuration`        |number | Duration of a single burst block          
|`PulseRate`			|number | Repetition rate (1/InterPulseInterval)

```


**Spatial & Targeting Information**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
| `StimID`              |string	| Identifier of stimulation target. 
| `ChannelName`			|string	| Name of cahnnel/electrode according 10-20 system (AF3, Ch1)
| `ChannelType			|string	| Channel function (anode, cathode, return, ground)
| `StimStepCount`       |number | (Optional) Number of stimulation steps or repetitions delivered at this spatial location.
```

**Amplitude & Thresholds**

```
|Field						|Type   | Description	
|---------------------------|-------|-----------------------------------
|`CurrentIntensity			|number | Current applied through the electrode (mA)
|`CurrentDensity 			|number | Current per unit surface area (mA/cm²)
|`VoltageIntensity			|number | Peak voltage applied (if voltage-controlled) (V)
|`ThresholdType				|number | Type of physiological or behavioral threshold used for defining ThresholdIntensity. Optional (motor, phosphene, perceptual, pain, none, other).
|`ThresholdIntensity		|number | Subject-specific threshold used for scaling (mA or V)
|`PulseIntensityThreshold	|number | Stimulation intensity expressed as % of threshold (%)
```

**Derived / Device-Generated Parameters**
```
|Field						|Type   | Description	
|-----------------------	|-------|-----------------------------------
|`Impedance					|number	| (Optional) Measured impedance per channel (kΩ)
|`EstimatedFieldStrength	|number | (Optional) Computed or simulated electric field strength at target (V/m)
|`SystemStatus				|string | (Optional) Device-detected QC status. Suggested levels: ok, impedance_high, unstable_contact, channel_fail, n/a
|`SubjectFeedback			|string | (Optional) Participant-reported perception or discomfort. Suggested levels: none, tingling, itching, burning, pain, unpleasant, other.
|`MeasuredCurrentIntensity	|number	| (Optional) Current measured by the device during stimulation in voltage-controlled mode. May vary across pulses or be averaged. (mA)
|`CurrentStatistics			|string | (Optional) Summary of current over session: e.g., mean=0.8;max=1.2;min=0.4
|`Timestamp					|string | (Optional) ISO 8601 timestamp for the event or setting
```

