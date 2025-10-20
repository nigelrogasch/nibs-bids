# NIBS-BIDS proposal v.6 (Scalable Structure for Non-Invasive Brain Stimulation)

This document presents a concise overview of our proposed scalable structure for organizing **non-invasive brain stimulation (NIBS)** data in BIDS. 
It is designed to precede and accompany real-life examples and comparative demonstrations.

## 1. NIBS as a Dedicated `datatype`

* All data related to non-invasive brain stimulation is stored under a dedicated `nibs/` folder.
* This folder is treated as a standalone BIDS `datatype`, similar in role to `eeg/`, `pet/`, or `motion/`.
* This design allows coherent grouping of stimulation parameters, spatial data, and metadata.

### Template:
```
sub-<label>/
    └──[ses-<label>/]
        └──nibs/
			├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>]_coordsystem.json
			├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_nibs.tsv
            ├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_nibs.json
			├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_markers.tsv
            └──sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_acq-<label>][_run-<index>]_markers.json
```

## 2. Supported Stimulation Modalities

* The structure supports multiple types of NIBS techniques:

  * Transcranial Magnetic Stimulation (**TMS**)
  * Transcranial Electrical Stimulation (**tES**, e.g., tDCS, tACS)
  * Transcranial Ultrasound Stimulation (**TUS**)
* At this stage, the file templates and parameters are modeled based on **TMS**, while allowing future extensibility to other modalities.

## 3. Modality-Specific Suffix via `stimsys`

* To distinguish between different stimulation systems, we introduce the suffix `stimsys`, analogous to `tracksys` in the `motion/` datatype.
* The `stimsys` suffix can take values like `tms`, `tes`, or `tus`.

The stimsys-<label> entity can be used as a key-value pair to label _nibs.tsv and _nibs.json files. 
It can also be used to label _markers.tsv; _markers.tsv or _coordsystem.json files when they belong to a specific stimulation system.
This entity corresponds to the "StimulationSystemName" metadata field in a _nibs.json file. stimsys-<label> entity is a concise string whereas "StimulationSystemName" may be longer and more human readable.

## 4. Synchronizing NIBS Data Across Modalities (*_events.tsv)

### Core Idea 

Every stimulation event recorded in `*_nibs.tsv` and spatially described in `*_markers.tsv` can be **referenced from other modalities** (e.g., `eeg/`, `nirs/`, `beh/`) using the following fields:

| Column Name      | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `StimStepCount`  | Corresponds to the unique stimulation row in `*_nibs.tsv`                   |
| `MarkerID`       | One or more marker IDs from `*_markers.tsv` & `*_nibs.tsv` used in the event|

### Modality-Specific Considerations

| Modality | MarkerID Usage                                   	 | Example Format            |
|----------|-----------------------------------------------------|---------------------------|
| `TMS`    | Typically **one marker** per stimulation            | `marker1.1`               |
| `tES`    | **Multiple electrodes** involved in one stimulation | `marker2.1; marker2.2`    |
| `TUS`    | **Single target**, **multiple entry points**        | `marker3.1; marker3.2`    |

- MarkerIDs can be **semicolon-separated** to indicate multi-point involvement.
- This preserves **readability** and avoids complex hierarchical structures.

** Example: *_events.tsv**

``` 
onset	duration	trial_type	StimStepCount	MarkerID
12.500	0.001	    stim_tms	1	            marker1.1
17.300	0.001	    stim_tes	2	            marker2.1; marker2.2
23.700	0.001	    stim_tus	3	            marker3.1; marker3.2; marker3.3
```

## 5. Scalable File Naming Convention

The following files are used to organize stimulation-related data:

* `sub-<label>_task-<label>[_stimsys-<label>]_nibs.tsv`
* `sub-<label>_task-<label>[_stimsys-<label>]_nibs.json`

  * Contains stimulation protocol and pulse parameters + metadata.

* `sub-<label>_task-<label>[_stimsys-<label>]_markers.tsv`
* `sub-<label>_task-<label>[_stimsys-<label>]_markers.json`

  * Contains 3D coordinates of stimulation points (entry, target, etc.), coil spatial orientation, and electric field vectors + metadata.	
  * Equivalent to similar `*_electrodes.tsv or _optodes.tsv`.
  
* `sub-<label>_task-<label>[_stimsys-<label>]_coordsystem.json`

  * Describes the coordinate system used in the stimulation session.
  * Equivalent to the former `*_coordsystem.json`.

## 6. Design Philosophy

* The structure is **modular**, **scalable**, and follows the BIDS principle of one `datatype` per modality.
* It avoids semantic overload and ambiguity by isolating stimulation metadata from behavioral, electrophysiological, and physiological datatypes.
* It enables consistent data discovery and analysis, even in complex multi-modal experiments.

Further elaboration and demonstration of these principles are provided in the accompanying example datasets and comparative analysis.

# NIBS: Transcranial Magnetic Stimulation section

## 1. Detailed overview of data structure

### 1.1 `*_coordsystem.json` — Coordinate Metadata

A _coordsystem.json file is used to specify the fiducials, the location of anatomical landmarks, and the coordinate system and units in which the position of landmarks or TMS stimulation targets is expressed. Fiducials are objects with a well-defined location used to facilitate the localization of sensors and co-registration. Anatomical landmarks are locations on a research subject such as the nasion (for a detailed definition see the coordinate system appendix).
The _coordsystem.json file is REQUIRED for navigated TMS stimulation datasets. If a corresponding anatomical MRI is available, the locations of anatomical landmarks in that scan should also be stored in the _T1w.json file which accompanies the TMS data.

```
| Field                                           | Type    | Description                                                                                                                                                                                                                                                                     | Units / Levels                      |
| ----------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `ImageData`                                     | string  | Description of the anatomical data used for co-registration. Includes Levels: DICOM, NIFTI, MR-less.                                                                                                                                                                            | Levels: `DICOM`, `NIFTI`, `MR-less` |
| `IntendedFor`                                   | string  | Path to the anatomical file this coordinate system refers to. BIDS-style path. (example: `bids::sub-01/ses-01/anat/sub-01_T1w.nii.gz`)                                                                                                                                          | BIDS path                           |
| `AnatomicalLandmarkCoordinateSystem`            | string  | Defines the coordinate system for the anatomical landmarks. See the Coordinate Systems Appendix for a list of restricted keywords for coordinate systems. If "Other", provide definition of the coordinate system in `AnatomicalLandmarkCoordinateSystemDescription`.           | —                                   |
| `AnatomicalLandmarkCoordinateSystemUnits`       | string  | Units of the coordinates of Anatomical Landmark Coordinate System. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                              | `"m"`, `"mm"`, `"cm"`, `"n/a"`      |
| `AnatomicalLandmarkCoordinateSystemDescription` | string  | Free-form text description of the coordinate system. May also include a link to a documentation page or paper describing the system in greater detail.                                                                                                                          | Free text                           |
| `AnatomicalLandmarkCoordinates`                 | object  | Key-value pairs of the labels and 3-D digitized locations of anatomical landmarks, interpreted following the `AnatomicalLandmarkCoordinateSystem`. Each array MUST contain three numeric values corresponding to x, y, and z axis of the coordinate system in that exact order. | 3D coordinates                      |
| `AnatomicalLandmarkCoordinatesDescription`      | string  | `[x, y, z]` coordinates of anatomical landmarks. NAS — nasion, LPA — left preauricular point, RPA — right preauricular point                                                                                                                                                    | —                                   |
| `DigitizedHeadPoints`                           | string  | Relative path to the file containing the locations of digitized head points collected during the session. (for example, `"sub-01_headshape.pos"`)                                                                                                                               | File path or `"n/a"`                |
| `DigitizedHeadPointsNumber`                     | integer | Number of digitized head points during co-registration.                                                                                                                                                                                                                         | count                               |
| `DigitizedHeadPointsDescription`                | string  | Free-form description of digitized points.                                                                                                                                                                                                                                      | —                                   |
| `DigitizedHeadPointsUnits`                      | string  | Unit type. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                                                                                      | `"m"`, `"mm"`, `"cm"`, `"n/a"`      |
| `RmsDeviation`                                  | object  | `{"RMS":[],"NAS":[],"LPA":[],"RPA":[]}` — deviation values per landmark                                                                                                                                                                                                         | values per marker                   |
| `RmsDeviationUnits`                             | string  | Unit of RMS deviation values.                                                                                                                                                                                                                                                   | `"m"`, `"mm"`, `"cm"`, `"n/a"`      |
| `RmsDeviationDescription`                       | string  | Description of how RMS deviation is calculated and for which markers.                                                                                                                                                                                                           | —                                   |
```

** Example *_coordsystem.json:**

```
{
  "ImageData": "NIFTI",
  "IntendedFor": "bids::sub-01/ses-01/anat/sub-01_T1w.nii.gz",
  "AnatomicalLandmarkCoordinateSystem": "Individual",
  "AnatomicalLandmarkCoordinateSystemUnits": "mm",
  "AnatomicalLandmarkCoordinateSystemDescription": "RAS orientation: origin halfway between LPA and RPA; x-axis points to RPA, y-axis orthogonal through NAS, z-axis orthogonal to xy-plane.",
  "AnatomicalLandmarkCoordinates": {
    "NAS": [12.7, 21.3, 13.9],
    "LPA": [5.2, 11.3, 9.6],
    "RPA": [20.2, 11.3, 9.1]
  },
  "AnatomicalLandmarkCoordinatesDescription": "[x, y, z] coordinates of anatomical landmarks: NAS (nasion), LPA (left preauricular), RPA (right preauricular)",
  "DigitizedHeadPoints": "sub-01_acq-HEAD_headshape.pos",
  "DigitizedHeadPointsNumber": 1200,
  "DigitizedHeadPointsDescription": "Digitized head points collected during subject registration",
  "DigitizedHeadPointsUnits": "mm",
  "RmsDeviation": {
    "NAS": [0.7],
    "LPA": [0.3],
    "RPA": [0.4],
    "RMS": [0.5]
  },
  "RmsDeviationUnits": "mm",
  "RmsDeviationDescription": "Root Mean Square deviation for fiducial points"
}
```
### Optional Headshape Files (*_headshape.<extension>)

This file is RECOMMENDED.

3D digitized head points  that describe the head shape and/or EEG electrode locations can be digitized and stored in separate files. These files are typically used to improve the accuracy of co-registration between the stimulation target, anatomical data, etc. The acq-<label> entity can be used when more than one type of digitization in done for a session, for example when the head points are in a separate file from the EEG locations.

** For example:**

```
sub-<label>/
   └─ ses-<label>/
		└── nibs/
			└── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>]_acq-HEAD_headshape.pos 

```
These files supplement the DigitizedHeadPoints, DigitizedHeadPointsUnits, and DigitizedHeadPointsDescription fields in the corresponding _coordsystem.json file. Their inclusion is especially useful when sharing datasets intended for advanced spatial analysis or electric field modeling.


### 1.2 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates and optional coil's orientation information. Supports multiple navigation systems (e.g., Localite, Nexstim) via flexible fields. 

```
| Field                | Type   | Description                                                                                             | Units    |
| -------------------- | ------ | ------------------------------------------------------------------------------------------------------- | -------- |
| `MarkerID`           | string | Unique identifier for each marker. This column must appear first in the file.                           | —        |
| `PeelingDepth`       | number | Depth “distance” from cortex surface to the target point OR from the entry marker to the target marker. | `mm`     |
| `target_x`           | number | X-coordinate of the target point in millimeters.                                                        | `mm`     |
| `target_y`           | number | Y-coordinate of the target point in millimeters.                                                        | `mm`     |
| `target_z`           | number | Z-coordinate of the target point in millimeters.                                                        | `mm`     |
| `entry_x`            | number | X-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `entry_y`            | number | Y-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `entry_z`            | number | Z-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `Matrix_4x4`         | array  | 4x4 affine transformation matrix for the coil positioning (instrument markers of Localite systems).     |  —       |
| `coil_x`             | number | X component of coil's origin location.                                                                  | `mm`     |
| `coil_y`             | number | Y component of coil's origin location.                                                                  | `mm`     |
| `coil_z`             | number | Z component of coil's origin location.                                                                  | `mm`     |
| `normal_x`           | number | X component of coil normal vector.                                                                      | `mm`     |
| `normal_y`           | number | Y component of coil normal vector.                                                                      | `mm`     |
| `normal_z`           | number | Z component of coil normal vector.                                                                      | `mm`     |
| `direction_x`        | number | X component of coil direction vector.                                                                   | `mm`     |
| `direction_y`        | number | Y component of coil direction vector.                                                                   | `mm`     |
| `direction_z`        | number | Z component of coil direction vector.                                                                   | `mm`     |
| `ElectricFieldMax_x` | number | X coordinate of max electric field point.                                                               | `mm`     |
| `ElectricFieldMax_y` | number | Y coordinate of max electric field point.                                                               | `mm`     |
| `ElectricFieldMax_z` | number | Z coordinate of max electric field point.                                                               | `mm`     |
| `Timestamp`          | string | Timestamp of the stimulation event in ISO 8601 format.                                                  | ISO 8601 |
```
### Field Ordering Rationale

The _markers.tsv file defines the spatial locations and orientation vectors of stimulation targets used in TMS experiments. When designing this structure, we drew partial inspiration from existing BIDS files such as _electrodes.tsv (EEG), which capture electrode positions. 
However, no existing modality in BIDS explicitly supports the full specification required for navigated TMS — including stimulation coordinates, orientation vectors, and electric field estimates.
This makes _markers.tsv a novel file type, tailored to the specific needs of TMS. Fields are ordered to reflect their functional roles:
- Identification: MarkerID appears first, enabling structured referencing in the _tms.tsv file. May include not only a unique ID number but also a step count determines the stepping and number of pulses produced per mark.
- Spatial Coordinates: target_, entry_ and PeelingDepth  describe the position of the stimulation point in the selected coordinate system. coil(x,y,z) describe the position of the TMS coil in the selected coordinate system.
- Orientation Vectors: normal_ and direction_ vectors or transformation matrix ("Matrix4D") define the coil orientation in 3D space — a critical factor in modeling TMS effects.
- Electric Field (optional): ElectricFieldMax_ defines where the electric field is maximized.

This design supports both minimal and advanced use cases: basic datasets can include just the spatial coordinates, while high-resolution multimodal studies can specify full coil orientation and field modeling parameters.

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

Additionally, the _nibs.json file introduces a dedicated hardware block called 'CoilSet', which captures detailed physical and electromagnetic parameters of one or more stimulation coils used in the session. 
This structure allows precise modeling, reproducibility, and harmonization of coil-related effects across studies.

* Each entry in 'CoilSet' is an object with the following fields:
```
Field									Type	Description
CoilID									string	Unique identifier for the coil, used to reference this entry from _tms.tsv.
CoilType								string	Model/type of the coil (e.g., CB60, Cool-B65).
CoilShape								string	Geometric shape of the coil windings (e.g., figure-of-eight, circular).
CoilCooling								string	Cooling method (air, liquid, passive).
CoilDiameter.Value						number	Diameter of the outer winding (usually in mm).
CoilDiameter.Units						string	Units for the diameter (e.g., mm).
MagneticFieldPeak.Value					number	Peak magnetic field at the surface of the coil (in Tesla).
MagneticFieldPeak.Units					string	Units for magnetic field peak (Tesla).
MagneticFieldPenetrationDepth.Value		number	Penetration depth of the magnetic field at a reference intensity level (e.g., 70 V/m).
MagneticFieldGradient.Value				number	Gradient of the magnetic field at a specific depth (typically in kT/s).
```
** Example:**


"CoilSet": [
  {
    "CoilID": "1",
    "CoilType": "CB60",
    "CoilShape": "figure-of-eight",
    "CoilCooling": "air",
    "CoilDiameter": {
      "Value": 75,
      "Units": "mm",
      "Description": "Outer winding diameter"
    },
    "MagneticFieldPeak": {
      "Value": 1.9,
      "Units": "Tesla",
      "Description": "Peak magnetic field"
    },
    "MagneticFieldPenetrationDepth": {
      "Value": 18,
      "Units": "mm",
      "Description": "Depth at which field reaches 70 V/m"
    },
    "MagneticFieldGradient": {
      "Value": 160,
      "Units": "kT/s",
      "Description": "Gradient 20 mm below coil center"
    }
  }
]

The _nibs.json follows standard BIDS JSON conventions and is essential for validator support, automated parsing, and multimodal integration (e.g., aligning stimulation parameters with EEG or MRI metadata).

### 1.4 `*_nibs.tsv` — Stimulation Parameters

This section describes all possible fields that may appear in *_nibs.tsv files. 
The fields are grouped into logical sections based on their function and purpose. 
All fields are optional unless stated otherwise, but some are strongly recommended.
The order of parameters in _nibs.tsv follows a hierarchical structure based on their variability during an experiment and their role in defining the stimulation process. Parameters are grouped into three logical blocks:
This structure reflects the actual flow of TMS experimentation — from hardware configuration, through protocol design, to per-target application and physiological feedback. 
Grouping fields this way improves readability and aligns with practical data collection workflows.

**Stimulator Device & Coil Configuration**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`CoilDriver`			|string	| Control method for coil positioning	(manual, fixed, cobot, robot0
|`CoilID`				|string	| Coil identifier (e.g. coil\_1, coil\_2). Should be described in Hardware part in json sidecar.
|`StimulusMode`			|string	| Type of stimulation (single, twin, dual, burst, etc.) Depends on Stimulator options.
|`CurrentDirection`		|string	| Direction of induced current	(e.g. normal, reverse).
|`Waveform`				|string	| Pulse shape	(e.g. monophasic, biphasic, etc).        
```
**Protocol Metadata** 

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
| `ProtocolName`        |string | The sequence timing mode unique name (e.g. sici, lici, custom, etc).
```
**Stimulation Timing Parameters**

```
| Field                        | Type    | Description                                                                                    | Units / Levels                              |
| ---------------------------- | ------- | --------------------------------------
| `InterTrialInterval`         | string  | Interval between simple trials 
| `InterStimulusInterval`      | number  | (ISI)  Time from start of first to start of second pulse (twin or dual).                              | msec                                        |
| `InterPulseInterval`         | number  | Interval between pulses within a train.                                                        | msec                                        |
| `BurstPulsesNumber`          | integer | Number of pulses in a burst.                                                                   | —                                           |
| `PulseRate`                  | number  | Number of pulses per second.                                                                   | pps                                         |
| `TrainPulses`                | integer | Number of pulses in each train.                                                                | —                                           |
| `RepetitionRate`             | number  | Frequency of trains.                                                                           | pps                                         |
| `InterRepetitionInterval`    | number  | Time between start of burst N and N+1.                                                         | msec                                        |
| `TrainDuration`              | number  | Duration of the full train.                                                                    | msec                                        |
| `TrainNumber`                | integer | Number of trains in sequence.                                                                  | —                                           |
| `InterTrainInterval`         | number  | Time from last pulse of one train to first of next.                                            | msec                                        |
| `InterTrainIntervalDelay`    | number  | Optional per-train delay override.                                                             | msec                                        |
| `TrainRampUp`                | number  | Gradual amplitude increase per train.                                                          | —                                           |
| `TrainRampUpNumber`          | integer | Number of trains for ramp-up.
```
**Spatial & Targeting Information**

```
| Field                        | Type    | Description                                                                                    | Units / Levels                              |
| ---------------------------- | ------- | --------------------------------------
| `MarkerID`                   | string  | Identifier of stimulation target.                                                              | —                                           |
| `StimStepCount`              | integer | Number of pulses applied at the marker. 
```
**Amplitude & Thresholds**

```
| Field                        | Type    | Description                                                                                    | Units / Levels                              |
| ---------------------------- | ------- | --------------------------------------
| `PulseIntensity`             | number  | Intensity of the first or single pulse (% of maximum stimulator output).                           | %                                           |
| `SecondPulseIntensity`       | number  | Intensity of the second pulse (dual mode).                                                     | %                                           |
| `PulseIntensityRatio`        | number  | Amplitude ratio of two pulses (B/A).                                                           | —                                           |
| `RMTIntensity`               | number  | Resting motor threshold as a percentage of maximum stimulator output
| `AMTIntensity`               | number  | Active motor threshold as a percentage of maximum stimulator output
| `PulseIntensityRMT`          | number  | Intensity of first/single pulse as % of RMT.                                                   | %                                           |
| `SecondPulseIntensityRMT`    | number  | Intensity of second pulse as % of RMT.                                                         | %                                           |
| `PulseIntensityAMT`          | number  | Intensity of first/single pulse as % of AMT.                                                   | %                                           |
| `SecondPulseIntensityAMT`    | number  | Intensity of second pulse as % of AMT.   
| `StimValidation`             | string  | Was the stimulation verified / observed.
```
**Derived / Device-Generated Parameters**

```
| Field                        | Type    | Description                                                                                    | Units / Levels                              |
| ---------------------------- | ------- | --------------------------------------
| `CurrentGradient`            | number  | Measured gradient of coil current.                                                             | A/µs                                        |
| `ElectricFieldTarget`        | number  | Electric field at stimulation target.                                                          | V/m                                         |
| `ElectricFieldMax`           | number  | Peak electric field at any location.                                                           | V/m                                         |
| `MotorResponse`              | number  | Motor-evoked potential (MEP) amplitude.                                                        | µV                                          |
| `Latency`                    | number  | Delay between stimulation and response.                                                        | ms                                          |
| `ResponseChannelName`        | string  | Name of recorded EMG/EEG/MEG channel.                                                          | —                                           |
| `ResponseChannelType`        | string  | Type of channel (e.g. emg, eeg).                                                               | —                                           |
| `ResponseChannelDescription` | string  | Description of the response channel.                                                           | —                                           |
| `ResponseChannelReference`   | string  | Reference channel name if applicable.                                                          | —                                           |
| `Status`                     | string  | Data quality observed on the channel.                                                          | —                                           |
| `StatusDescription`          | string  | Freeform text description of noise or artifact affecting data quality on the channel.          | —                                           |
| `IntendedFor `               | string  | Path to the recorded file refers to. BIDS-style path. (example: `bids::sub-01/ses-01/eeg/sub-01_eeg.eeg`)
| `Timestamp`                  | string  | Timestamp in ISO 8601 format.       
```