# NIBS: Transcranial Ultrasound Stimulation section.

## 1. Detailed overview of data structure

### 1.1 `*_coordsystem.json` — Coordinate Metadata

A _coordsystem.json file is used to specify the fiducials, the location of anatomical landmarks, and the coordinate system and units in which the position of landmarks or tUS stimulation targets is expressed. 
Anatomical landmarks are locations on a research subject such as the nasion (for a detailed definition see the coordinate system appendix).
The _coordsystem.json file is REQUIRED for navigated tUS stimulation datasets. If a corresponding anatomical MRI is available, the locations of anatomical landmarks in that scan should also be stored in the _T1w.json file which accompanies the tUS data.

```
| Field                                           | Type    | Description                                                                                                                                                                                                                                                                     | Units / Levels                      |
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
#### TUS-specific transducer coordinate metadata fields (*_coordsystem.json)

These optional fields are recommended for transcranial ultrasound stimulation (TUS) datasets when the spatial position and/or orientation of the ultrasound transducer is known or fixed (e.g., in neuronavigated or modeled setups). 
They complement the standard NIBSCoordinateSystem fields, which typically describe the focus location.
Optional QC metric (in mm) representing the root-mean-square deviation of the ultrasound transducer's actual position and/or orientation from its intended location.
This may be computed from optical tracking, neuronavigation logs, or mechanical fixation assessment.

```
| Field                                         | Type    | Description                                                                                                                                                                                                                                                                     | Units / Levels                      |
| ----------------------------------------------| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 				| ----------------------------------- |
| `TransducerCoordinateSystem					| string  | Name of the coordinate system used to define the transducer's position (e.g., IndividualMRI, CT, DeviceSpace, etc.).
| `TransducerCoordinateUnits					| string  | Units of measurement for transducer coordinates (typically mm).
| `TransducerCoordinateSystemDescription		| string  | Textual description of how the transducer coordinate system was defined and aligned with anatomy.
| `TransducerCoordinates						| object  | Dictionary with spatial coordinates (e.g., X, Y, Z ) and optionally 4×4 affine transformation matrix for transducer orientation.
| `TransducerCoordinatesDescription				| string  | Free-text explanation of what the coordinates represent (e.g., transducer center, entry point, beam axis, etc.).
| `TransducerRmsDeviation`						| string  | Root-mean-square deviation (in millimeters) of the ultrasound transducer’s actual position and/or orientation from the planned or intended placement, typically computed across time or repeated trials.
| `TransducerRmsDeviationUnits`   				| string  | Units used to express the RMS deviation value. Must be consistent with the spatial coordinate system units (e.g., "mm").
| `TransducerRmsDeviationDescription`			| string  | Free-text description of how the deviation was calculated, including what was measured (e.g., position, angle), over what time frame, and using which method (e.g., optical tracking, neuronavigation, manual estimate).
```
*These fields enable reproducible modeling, visualization, and interpretation of TUS targeting and acoustic beam propagation when precise transducer positioning is known.

#### Optional Headshape Files (*_headshape.<extension>)

This file is RECOMMENDED.

3D digitized head points  that describe the head shape and/or EEG electrode locations can be digitized and stored in separate files. 
These files are typically used to improve the accuracy of co-registration between the stimulation target, anatomical data, etc. 

** For example:**

```
sub-<label>/
   └─ ses-<label>/
		└── nibs/
			└── sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>]_acq-HEAD_headshape.pos 

```
These files supplement the DigitizedHeadPoints, DigitizedHeadPointsUnits, and DigitizedHeadPointsDescription fields in the corresponding _coordsystem.json file. Their inclusion is especially useful when sharing datasets intended for advanced spatial analysis or electric field modeling.

### 1.2 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

```
| Field                	| Type   | Description                                                                                                 			
| -------------------- 	| ------ | ------------------------------------------------------------------------------------------------------- 				
| `stim_id`			   	| string | Unique identifier for each marker. This column must appear first in the file.                           				
| `marker_name`   	   	| string | Name of the cortical target, anatomical label, or stimulation site (M1_hand, DLPFC, etc.).
| `target_x`           	| number | X-coordinate of the target point in millimeters.                                                        					
| `target_y`           	| number | Y-coordinate of the target point in millimeters.                                                        
| `target_z`           	| number | Z-coordinate of the target point in millimeters. 
| `entry_x`				| number | X-coordinate of the scalp entry point where the ultrasound beam penetrates the head.
| `entry_y`				| number | Y-coordinate of the scalp entry point where the ultrasound beam penetrates the head.
| `entry_z`				| number | Z-coordinate of the scalp entry point where the ultrasound beam penetrates the head.
| `transducer_x`		| number | X-coordinate of the transducer's physical reference point (e.g., geometric center or coupling surface).
| `transducer_y`		| number | Y-coordinate of the transducer's physical reference point (e.g., geometric center or coupling surface).
| `transducer_z`		| number | Z-coordinate of the transducer's physical reference point (e.g., geometric center or coupling surface).
| `normal_x`			| number | X-coordinate component of the unit vector normal to the scalp surface at the entry point, defining the intended beam orientation.
| `normal_y`			| number | Y-coordinate component of the unit vector normal to the scalp surface at the entry point, defining the intended beam orientation.
| `normal_z`			| number | Z-coordinate component of the unit vector normal to the scalp surface at the entry point, defining the intended beam orientation.
| `beam_x`				| number | X-coordinate of unit vector representing the actual direction of the ultrasound beam propagation. Used when beam axis differs from the normal vector.
| `beam_y`				| number | Y-coordinate of unit vector representing the actual direction of the ultrasound beam propagation. Used when beam axis differs from the normal vector.
| `beam_z`				| number | Z-coordinate of unit vector representing the actual direction of the ultrasound beam propagation. Used when beam axis differs from the normal vector.
| `transducer_transform`| array  | Optional: 4×4 affine transformation matrix representing the transducer’s spatial pose in the coordinate system. This field should be included only when the transducer was repositioned across different stimulation points, such that a single transformation in *_coordsystem.json would not adequately describe all locations.
```

* target_x/y/z: "Coordinates of the acoustic focus — the point where the ultrasound energy is concentrated and stimulation is intended to occur."
* entry_x/y/z: "Scalp entry point of the ultrasound beam — where it penetrates the skin and skull en route to the target."
* transducer_x/y/z: "Coordinates of the ultrasound transducer’s physical reference point — typically its geometric center or coupling interface."
* normal_x/y/z: "Unit vector normal to the scalp at the entry point, defining the intended beam axis direction."
* beam_x/y/z: "Unit vector defining the direction of the ultrasound beam propagation from the transducer. Used if the beam axis differs from the scalp surface normal vector (normal_x/y/z)."
* transducer_transform: "Optional 4×4 affine transformation matrix describing the transducer’s spatial pose (position and orientation) relative to the coordinate system defined in *_coordsystem.json. Used in setups with tracked transducers or navigation systems."

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

Additionally, the _nibs.json file introduces a dedicated hardware block called "TransducerSet".
TransducerSet provides a structured, machine-readable description of one or more transcranial ultrasound transducers used in the dataset.
Each transducer is defined as an object with a unique transducer_id, which is referenced from the *_nibs.tsv file.
This structure mirrors the approach used in 'CoilSet' (TMS-section) and includes key physical and acoustic properties of each transducer, such as center frequency, focus depth, aperture diameter, and intensity-related parameters.

* Each entry in 'TransducerSet' is an object with the following fields:
```
Field									Type	Description
transducer_id							string	Unique identifier for the transducer, referenced from *_nibs.tsv.
TransducerType							string	Physical configuration: single-element, phased-array, planar, or custom.
FocusType								string	Acoustic focus shape: point, line, volume, or swept.
CarrierFrequency						number	Nominal center frequency of the ultrasound wave (Hz).
FocalDepth								number	Distance from the transducer surface to the acoustic focus (mm).
ApertureDiameter						number	Diameter of the ultrasound-emitting surface (mm).
PeakNegativePressure					number	Peak negative pressure in the focus (MPa).
MechanicalIndex							number	Safety-relevant mechanical index (dimensionless).
ContactMedium							string	Coupling method between the transducer and the scalp, such as gel, membrane, water bag, or dry contact.
```

** Example:**
```
"TransducerSet": [
  {
    "transducer_id": "tr_1",
    "TransducerType": "single-element",
    "FocusType": "point",
    "CarrierFrequency": {
      "Value": 500000,
      "Units": "Hz",
      "Description": "Nominal center frequency of the ultrasound wave"
    },
    "FocalDepth": {
      "Value": 30,
      "Units": "mm",
      "Description": "Distance from the transducer surface to the acoustic focus"
    },
    "ApertureDiameter": {
      "Value": 15,
      "Units": "mm",
      "Description": "Diameter of the active transducer aperture"
    },
    "PeakNegativePressure": {
      "Value": 0.6,
      "Units": "MPa",
      "Description": "Peak negative pressure at the acoustic focus"
    },
    "MechanicalIndex": {
      "Value": 0.8,
      "Units": "dimensionless",
      "Description": "MI = Pneg / sqrt(frequency), safety-relevant indicator"
    },
	"ContactMedium": "ultrasound gel"
  }
]
```

### 1.4 `*_nibs.tsv` — Stimulation Parameters

This section describes all possible fields that may appear in *_nibs.tsv files. 
The fields are grouped into logical sections based on their function and purpose. 
All fields are optional unless stated otherwise, but some are strongly recommended.
The order of parameters in _nibs.tsv follows a hierarchical structure based on their variability during an experiment and their role in defining the stimulation process. 
Parameters are grouped into three logical blocks.

**Stimulator Device & Configurations**

```
| Field                        	| Type    | Description                                                                                    | Units / Levels                              |
| ----------------------------	| ------- | --------------------------------------
| `transducer_id`				| string  | Identifier for the ultrasound transducer used in this stimulation configuration. Corresponds to a detailed transducer entry in the *_nibs.json file.
| `targeting_method`			| string  | Method used to guide targeting of the stimulation site (e.g., MRI-based neuronavigation, anatomical template, robotic arm, freehand placement).
| `tus_stim_mode`				| string  | Type of transcranial ultrasound stimulation protocol used (e.g., tFUS, LIFU, AM-tFUS, burstTUS).
| `focus_type`					| string  | Type of acoustic focus generated by the transducer. Indicates the spatial profile of the ultrasound energy deposition. Typical values include: point (tightly focused), line (elongated focal zone), volume (broader area), swept (dynamic focus across space).
```

**Protocol Metadata** 

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
| `protocol_name`       |string | Name of the stimulation protocol or experimental condition associated with this stimulation configuration (e.g., theta, working_memory, burst_40Hz, sham).
```

**Stimulation Timing Parameters**

```
| Field                        	| Type    | Description                                                                                    | Units / Levels                              |
| ---------------------------- 	| ------- | --------------------------------------
| `waveform`					| string  | sine, square, burst, AM, FM, custom
| `carrier_frequency`			| number  | Frequency of the continuous or pulsed ultrasound carrier
| `duty_cycle`					| number  | Percentage of time the ultrasound is active (on) within each pulse or burst cycle. Expressed as a number between 0 and 100.
| `pulse_width`					| number  | Duration of a single ultrasound pulse
| `inter_trial_interval`		| number  | Time between repeated trials or blocks
| `inter_pulse_interval`		| number  | Time between pulses within a burst
| `burst_pulses_number`			| number  |	Number of pulses per burst
| `burst_duration`				| number  | Duration of a single burst block
| `pulse_rate`					| number  | Repetition rate of pulses within a burst (PRF equivalent)
| `train_pulses`				| number  | Number of pulses in a full train (e.g. 100 pulses = 10 bursts of 10 pulses)
| `repetition_rate`				| number  | How often the burst is repeated (can be inverse of InterTrialInterval)
| `inter_repetition_interval`   | number  | Time between start of burst N and N+1.
| `train_duration`              | number  | Duration of the full train.                                                                    | msec                                        |
| `train_number`                | number  | Number of trains in sequence.                                                                  | —                                           |
| `inter_train_interval`        | number  | Time from last pulse of one train to first of next.                                            | msec                                        |
| `inter_train_interval_delay`  | number  | Optional per-train delay override.      
| `train_ramp_up` 				| number  | Proportional ramping factor or amplitude increment per train (e.g., in % of max intensity)
| `train_ramp_up_number` 		| number  | Number of initial trains during which ramp-up is applied
| `stimulation_duration`		| number  | Total duration of the stimulation block
| `ramp_up_duration`			| number  | Duration of ramp-up (fade-in) at onset
| `ramp_down_duration`			| number  | Duration of ramp-down (fade-out) at offset
```

**Spatial & Targeting Information**

```
| Field                        | Type    | Description                                                                                    | Units / Levels                              |
| ---------------------------- | ------- | --------------------------------------
| `stim_id`                    | string  | Identifier of stimulation target or target group.       
| `marker_name`                | string  | (Optional) Human-readable name or anatomical label of the stimulation site (e.g., M1_hand, left_DLPFC, anterior_insula).
| `stim_count`    		       | number  | (Optional) Number of stimulation steps or repetitions delivered at this spatial location.
```

**Amplitude & Thresholds**

```
| Field                        	| Type    | Description                                                                                    | Units / Levels                              |
| ----------------------------	| ------- | --------------------------------------
| `pulse_intensity`            	| number  | (Optional) Absolute acoustic intensity of the stimulation pulse, expressed in physical units such as mW/cm² (ISPTA or ISPPA), MPa (peak pressure), or dB.
| `acoustic_intensity` 			| number  | (Optional) Estimated acoustic intensity delivered to the target region, commonly reported as spatial-peak temporal-average (ISPTA) in mW/cm².
| `mechanical_index`			| number  | (Optional) Mechanical Index (MI), calculated as the peak negative pressure (in MPa) divided by the square root of the frequency (in MHz).
| `peak_negative_pressure`		| number  | (Optional) Peak negative pressure at the focus, in megapascals (MPa). Important for evaluating safety and cavitation risk.
| `threshold_type` 				| string  | (Optional) Method used to determine the individual stimulation threshold. Typical values include: behavioral, physiological, subjective, or none.
| `threshold_intensity`			| number  | (Optional) Individually determined stimulation threshold, expressed in the same units as PulseIntensity.
| `pulse_intensity_threshold`	| number  | (Optional) Stimulation intensity expressed as a percentage of the individual threshold (e.g., 90% of threshold).
| `stim_validation`             | string  | Was the stimulation verified / observed.
```

**Derived / Device-Generated Parameters**

```
|Field						|Type   | Description	
|---------------------------|-------|-----------------------------------
| `system_status`			|string | (Optional) Device-reported status during or after stimulation. Examples: ok, overload, error.
| `subject_feedback`		|string | (Optional) Participant-reported experience or sensation during stimulation (e.g., none, pain, tingling, heat).
| `measured_pulse_intensity`|number | (Optional) Actual measured intensity of the stimulation pulse, in the same units as PulseIntensity. Used if different from the planned value.
| `transducer_rms_deviation`|number | (Optional) Root-mean-square deviation of the transducer position during stimulation, in millimeters.
| `timestamp`               |string | (Optional) Timestamp in ISO 8601 format. 
```