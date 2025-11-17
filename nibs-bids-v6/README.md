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

## 4. Online vs Offline Experiments

NIBS paradigms can be applied either concurrently with the acquisition of neuroimaging and/or behavioral data, or in a temporally separated (offline) manner.
To reflect this distinction in BIDS-compatible datasets, we recommend the use of acquisition labels:

*_acq-online_* — for online paradigms, where NIBS is delivered concurrently with behavioral and/or neuroimaging acquisition.

*_acq-offline_* — for offline paradigms, where NIBS is applied before or after other data recordings, but not during them.

These acquisition suffixes can be applied to any relevant BIDS modality (e.g., EEG, fMRI, MEG, NIRS, etc.) as well as to NIBS-related files such as *_nibs.tsv.

```
Example:
sub-01_ses-01_task-motor_stimsys-tms_acq-online_nibs.tsv
sub-01_ses-01_task-motor_stimsys-tes_acq-offline_nibs.tsv
```

This avoids the need for new fields in metadata files while maintaining clear, machine-readable semantics.

## 5. Synchronizing NIBS Data Across Modalities (*_events.tsv)

### Core Idea 

Every stimulation event recorded in `*_nibs.tsv` and spatially described in `*_markers.tsv` can be **referenced from other modalities** (e.g., `eeg/`, `nirs/`, `beh/`) using the following fields:

| Column Name      | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `stim_count`  | Corresponds to the unique stimulation row in `*_nibs.tsv`                   |
| `stim_id`       | One or more marker IDs from `*_markers.tsv` & `*_nibs.tsv` used in the event|

### Modality-Specific Considerations

| Modality | stim_id Usage                                   	 | Example Format            |
|----------|-----------------------------------------------------|---------------------------|
| `TMS`    | Typically **one marker** per stimulation            | `stim_1.1`               |
| `tES`    | **Multiple electrodes** involved in one stimulation | `stim_2.1; stim_2.2`    |
| `TUS`    | **Single target**, **multiple entry points**        | `stim_3.1; stim_3.2`    |

- stim_id's can be **semicolon-separated** to indicate multi-point involvement.
- This preserves **readability** and avoids complex hierarchical structures.

** Example: *_events.tsv**

``` 
onset	duration	trial_type	stim_count	stim_id
12.500	0.001	    stim_tms	1	        stim_1.1
17.300	0.001	    stim_tes	2	        stim_2.1; stim_2.2
23.700	0.001	    stim_tus	3	        stim_3.1; stim_3.2; stim_3.3
```

## 6. Scalable File Naming Convention

The following files are used to organize stimulation-related data:

* `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>]_nibs.tsv`
* `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>]_nibs.json`

  * Contains stimulation protocol and pulse parameters + metadata.

* `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>]_markers.tsv`
* `sub-<label>_task-<label>[_stimsys-<label>][_acq-<label>]_markers.json`

  * Contains 3D coordinates of stimulation points (entry, target, etc.), coil spatial orientation, and electric field vectors + metadata.	
  * Equivalent to similar `*_electrodes.tsv or _optodes.tsv`.
  
* `sub-<label>_task-<label>[_stimsys-<label>]_coordsystem.json`

  * Describes the coordinate system used in the stimulation session.
  * Equivalent to the former `*_coordsystem.json`.

## 7. Design Philosophy

* The structure is **modular**, **scalable**, and follows the BIDS principle of one `datatype` per modality.
* It avoids semantic overload and ambiguity by isolating stimulation metadata from behavioral, electrophysiological, and physiological datatypes.
* It enables consistent data discovery and analysis, even in complex multi-modal experiments.

Further elaboration and demonstration of these principles are provided in the accompanying example datasets and comparative analysis.

# Detailed overview of data structure

### `*_coordsystem.json` — Coordinate Metadata

A _coordsystem.json file is used to specify the fiducials, the location of anatomical landmarks, and the coordinate system and units in which the position of landmarks or TMS stimulation targets is expressed. 
Anatomical landmarks are locations on a research subject such as the nasion (for a detailed definition see the coordinate system appendix).
The _coordsystem.json file is REQUIRED for navigated TMS, tES, TUS stimulation datasets. If a corresponding anatomical MRI is available, the locations of anatomical landmarks in that scan should also be stored in the _T1w.json file which accompanies the TMS, tES, TUS data.

```
| Field                                           | Type    | Description                                                                                                                                                                                                                                                                     
| ----------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
| `IntendedFor`                                   | string  | Path to the anatomical file this coordinate system refers to. BIDS-style path. (example: `bids::sub-01/ses-01/anat/sub-01_T1w.nii.gz`)                                                                                                                                          			
| `NIBSCoordinateSystem`						  | string  | Name of the coordinate system used to define the spatial location of stimulation targets. Common values for TUS include: IndividualMRI, MNI152NLin2009cAsym, or CapTrak.																														
| `NIBSCoordinateUnits`							  | string  | Units used to express spatial coordinates in *_markers.tsv. Typically mm (millimeters) for MRI-based spaces.																																												
| `NIBSCoordinateSystemDescription`				  | string  | Free-text description providing details on how the coordinate system was defined. This may include registration methods (e.g., neuronavigation, manual annotation), whether coordinates represent the ultrasound focus or entry point, and how the space aligns with anatomical references.
| `AnatomicalLandmarkCoordinateSystem`            | string  | Defines the coordinate system for the anatomical landmarks. See the Coordinate Systems Appendix for a list of restricted keywords for coordinate systems. If "Other", provide definition of the coordinate system in `AnatomicalLandmarkCoordinateSystemDescription`.           	
| `AnatomicalLandmarkCoordinateSystemUnits`       | string  | Units of the coordinates of Anatomical Landmark Coordinate System. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                              	
| `AnatomicalLandmarkCoordinateSystemDescription` | string  | Free-form text description of the coordinate system. May also include a link to a documentation page or paper describing the system in greater detail.                                                                                                                          		
| `AnatomicalLandmarkCoordinates`                 | object  | Key-value pairs of the labels and 3-D digitized locations of anatomical landmarks, interpreted following the `AnatomicalLandmarkCoordinateSystem`. Each array MUST contain three numeric values corresponding to x, y, and z axis of the coordinate system in that exact order.			
| `AnatomicalLandmarkCoordinatesDescription`      | string  | `[x, y, z]` coordinates of anatomical landmarks. NAS — nasion, LPA — left preauricular point, RPA — right preauricular point                                                                                                                                                    				
| `DigitizedHeadPoints`                           | string  | Relative path to the file containing the locations of digitized head points collected during the session. (for example, `"sub-01_headshape.pos"`)                                                                                                                               	
| `DigitizedHeadPointsNumber`                     | integer | Number of digitized head points during co-registration.                                                                                                                                                                                                                       		
| `DigitizedHeadPointsDescription`                | string  | Free-form description of digitized points.                                                                                                                                                                                                                                      			
| `DigitizedHeadPointsUnits`                      | string  | Unit type. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                                                                                      		
| `AnatomicalLandmarkRmsDeviation`                | object  | `{"RMS":[],"NAS":[],"LPA":[],"RPA":[]}` — deviation values per landmark                                                                                                                                                                                                         		
| `AnatomicalLandmarkRmsDeviationUnits`           | string  | Unit of RMS deviation values.                                                                                                                                                                                                                                               			
| `AnatomicalLandmarkRmsDeviationDescription`     | string  | Description of how RMS deviation is calculated and for which markers.                                                                                                                                                                                                         		
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
  "AnatomicalLandmarkRmsDeviation": {
    "NAS": [0.7],
    "LPA": [0.3],
    "RPA": [0.4],
    "RMS": [0.5]
  },
  "AnatomicalLandmarkRmsDeviationUnits": "mm",
  "AnatomicalLandmarkRmsDeviationDescription": "Root Mean Square deviation for fiducial points"
}
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
These files supplement the DigitizedHeadPoints, DigitizedHeadPointsUnits, and DigitizedHeadPointsDescription fields in the corresponding _coordsystem.json file. 
Their inclusion is especially useful when sharing datasets intended for advanced spatial analysis or electric field modeling.

## NIBS: Transcranial Magnetic Stimulation section

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates and optional coil's orientation information. Supports multiple navigation systems (e.g., Localite, Nexstim) via flexible fields. 

```
| Field                		| Type   | Description                                                                                                 			
| --------------------------| ------ | ------------------------------------------------------------------------------------------------------- 				
| `stim_id`			   		| string | Unique identifier for each marker. This column must appear first in the file.                           				
| `marker_name`   	   		| string | Name of the cortical target, anatomical label, or stimulation site (M1_hand, DLPFC, etc.).
| `peeling_depth`       	| number | Depth “distance” from cortex surface to the target point OR from the entry marker to the target marker. 				
| `target_x`           		| number | X-coordinate of the target point in millimeters.                                                        					
| `target_y`           		| number | Y-coordinate of the target point in millimeters.                                                        
| `target_z`           		| number | Z-coordinate of the target point in millimeters.                                                        
| `entry_x`            		| number | X-coordinate of the entry point in millimeters.                                                         
| `entry_y`            		| number | Y-coordinate of the entry point in millimeters.                                                         
| `entry_z`            		| number | Z-coordinate of the entry point in millimeters.                                                         
| `coil_transform`      	| array  | 4x4 affine transformation matrix for the coil positioning (instrument markers of Localite systems).     
| `coil_x`             		| number | X component of coil's origin location.                                                                  
| `coil_y`             		| number | Y component of coil's origin location.                                                                  
| `coil_z`             		| number | Z component of coil's origin location.                                                                  
| `normal_x`           		| number | X component of coil normal vector.                                                                      
| `normal_y`           		| number | Y component of coil normal vector.                                                                      
| `normal_z`           		| number | Z component of coil normal vector.                                                                      
| `direction_x`        		| number | X component of coil direction vector.                                                                   
| `direction_y`        		| number | Y component of coil direction vector.                                                                  
| `direction_z`        		| number | Z component of coil direction vector.                                                                   
| `electric_field_max_x`	| number | X coordinate of max electric field point.                                                               
| `electric_field_max_y` 	| number | Y coordinate of max electric field point.                                                               
| `electric_field_max_z` 	| number | Z coordinate of max electric field point.                                                               
| `timestamp`          		| string | timestamp of the stimulation event in ISO 8601 format.                                                  
```

### Field Ordering Rationale

The _markers.tsv file defines the spatial locations and orientation vectors of stimulation targets used in TMS experiments. When designing this structure, we drew partial inspiration from existing BIDS files such as _electrodes.tsv (EEG), which capture electrode positions. 
However, no existing modality in BIDS explicitly supports the full specification required for navigated TMS — including stimulation coordinates, orientation vectors, and electric field estimates.
This makes _markers.tsv a novel file type, tailored to the specific needs of TMS. Fields are ordered to reflect their functional roles:
- Identification: stim_id appears first, enabling structured referencing in the _nibs.tsv file. May include not only a unique ID number but also a step count determines the stepping and number of pulses produced per mark.
- Spatial Coordinates: target_, entry_ and peeling_depth  describe the position of the stimulation point in the selected coordinate system. coil(x,y,z) describe the position of the TMS coil in the selected coordinate system.
- Orientation Vectors: normal_ and direction_ vectors or transformation matrix ("coil_transform") define the coil orientation in 3D space — a critical factor in modeling TMS effects.
- Electric Field (optional): electric_field_max_ defines where the electric field is maximized.

This design supports both minimal and advanced use cases: basic datasets can include just the spatial coordinates, while high-resolution multimodal studies can specify full coil orientation and field modeling parameters.

### 1.2 `*_nibs.json` — Sidecar JSON 

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
|Field									|Type   | Description	
|---------------------------------------|-------|-----------------------------------
|coil_id								|string	| Unique identifier for the coil, used to reference this entry from _tms.tsv.
|CoilType								|string	| Model/type of the coil (e.g., CB60, Cool-B65).
|CoilShape								|string	| Geometric shape of the coil windings (e.g., figure-of-eight, circular).
|CoilCooling							|string	| Cooling method (air, liquid, passive).
|CoilDiameter							|number	| Diameter of the outer winding (usually in mm).
|MagneticFieldPeak						|number	| Peak magnetic field at the surface of the coil (in Tesla).
|MagneticFieldPenetrationDepth			|number	| Penetration depth of the magnetic field at a reference intensity level (e.g., 70 V/m).
|MagneticFieldGradient					|number	| Gradient of the magnetic field at a specific depth (typically in kT/s).
```
** Example:**
```
"CoilSet": [
  {
    "coil_id": "coil_1",
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
```
The _nibs.json follows standard BIDS JSON conventions and is essential for validator support, automated parsing, and multimodal integration (e.g., aligning stimulation parameters with EEG or MRI metadata).

### 1.3 `*_nibs.tsv` — Stimulation Parameters

This section describes all possible fields that may appear in *_nibs.tsv files. 
The fields are grouped into logical sections based on their function and purpose. 
All fields are optional unless stated otherwise, but some are strongly recommended.
The order of parameters in _nibs.tsv follows a hierarchical structure based on their variability during an experiment and their role in defining the stimulation process. 
Parameters are grouped into three logical blocks.
This structure reflects the actual flow of TMS experimentation — from hardware configuration, through protocol design, to per-target application and physiological feedback. 
Grouping fields this way improves readability and aligns with practical data collection workflows.

**Stimulator Device & Coil Configuration**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`coil_id`				|string	| Coil identifier (e.g. coil\_1, coil\_2). Should be described in Hardware part in json sidecar `CoilID`.
|`targeting_method`		|string	| Method used to guide targeting of the coil positioning	(manual, fixed, cobot, robot0
|`tms_stim_mode`		|string	| Type of stimulation (single, twin, dual, burst, etc.) Depends on Stimulator options.
|`current_direction`	|string	| Direction of induced current	(e.g. normal, reverse).  
```

**Protocol Metadata** 

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
| `protocol_name`       |string | The protocol unique name (e.g. sici, lici, custom, etc).
```

**Stimulation Timing Parameters**

```
| Field                        | Type    | Description                                                                                   
| ---------------------------- | ------- | --------------------------------------
| `waveform`				   | string  | Pulse shape	(e.g. monophasic, biphasic, etc).      
| `inter_trial_interval`       | string  | Interval between simple trials 
| `inter_stimulus_interval`    | number  | (ISI)  Time from start of first to start of second pulse (twin or dual).                      
| `inter_pulse_interval`       | number  | Interval between pulses within a train.                                                      
| `burst_pulses_number`        | number  | Number of pulses in a burst. 
| `burst_duration`             | number  | Duration of a single burst block                          							         
| `pulse_rate`                 | number  | Number of pulses per second.                                                                   
| `train_pulses`               | number  | Number of pulses in each train.                                                                
| `repetition_rate`            | number  | Frequency of trains.                                                                           
| `inter_repetition_interval`  | number  | Time between start of burst N and N+1.                                                        
| `train_duration`             | number  | Duration of the full train.                                                                    
| `train_number`               | number  | Number of trains in sequence.                                                                 
| `inter_train_interval`       | number  | Time from last pulse of one train to first of next.                                            
| `inter_train_interval_delay` | number  | Optional per-train delay override.                                                             
| `train_ramp_up`              | number  | Gradual amplitude increase per train.                                                          
| `train_ramp_up_number`       | number  | Number of trains for ramp-up.
| `ramp_up_duration`		   | number  |(Optional) Time (in seconds) over which the stimulation amplitude is gradually increased at the start of a stimulation block or train.
| `train_ramp_down`            | number  | Gradual amplitude decrease per train.                                                         
| `train_ramp_down_number`     | number  | Number of trains for ramp-down.
| `ramp_down_duration`         | number  |(Optional) Time (in seconds) for decreasing stimulation amplitude at the end of a stimulation block or train.
| `stimulation_duration`	   | number  | Total duration of the stimulation block
```

**Spatial & Targeting Information**

```
| Field                        | Type    | Description                                                                                    
| ---------------------------- | ------- | --------------------------------------
| `stim_id`                    | string  | Identifier of stimulation target.       
| `marker_name`                | string  | (Optional) Name of the cortical target, anatomical label, or stimulation site (M1_hand, DLPFC, etc.)                        
| `stim_count`				   | integer | (Optional) Number of stimulation steps or repetitions delivered at this spatial location.
```

**Amplitude & Thresholds**

```
| Field                        | Type    | Description                                                                                                 
| ---------------------------- | ------- | --------------------------------------
| `pulse_intensity`            | number  | Intensity of the first or single pulse (% of maximum stimulator output).                      
| `second_pulse_intensity`     | number  | Intensity of the second pulse (dual mode).                                                  
| `pulse_intensity_ratio`      | number  | Amplitude ratio of two pulses (B/A).                                                           
| `rmt_intensity`              | number  | Resting motor threshold as a percentage of maximum stimulator output
| `amt_intensity`              | number  | Active motor threshold as a percentage of maximum stimulator output
| `pulse_intensity_rmt`        | number  | Intensity of first/single pulse as % of RMT.                                                   
| `second_pulse_intensity_rmt` | number  | Intensity of second pulse as % of RMT.                                                         
| `pulse_intensity_amt`        | number  | Intensity of first/single pulse as % of AMT.                                                
| `second_pulse_intensity_amt` | number  | Intensity of second pulse as % of AMT.   
| `stim_validation`            | string  | Was the stimulation verified / observed.
```

**Derived / Device-Generated Parameters**

```
| Field                        	| Type    | Description                                                                                   
| ------------------------------| ------- | --------------------------------------
| `current_gradient`           	| number  | (Optional) Measured gradient of coil current.                                                            
| `electric_field_target`      	| number  | (Optional) Electric field at stimulation target.                                                          
| `electric_field_max`         	| number  | (Optional) Peak electric field at any location.                                                        
| `motor_response`             	| number  | (Optional) Motor-evoked potential (MEP) amplitude.                                                      
| `latency`                    	| number  | (Optional) Delay between stimulation and response.                                                    
| `response_channel_name`      	| string  | (Optional) Name of recorded EMG/EEG/MEG channel.                                                         
| `response_channel_type`      	| string  | (Optional) Type of channel (e.g. emg, eeg).                                                              
| `response_channel_description`| string  | (Optional) Description of the response channel.                                                           
| `response_channel_reference`  | string  | (Optional) Reference channel name if applicable.                                                     
| `system_status`               | string  | (Optional) Data quality observed on the channel.                                               
| `subject_feedback`		    | string  | (Optional) Participant-reported perception or discomfort.
| `IntendedFor `               	| string  | (Optional) Path to the recorded file refers to. BIDS-style path. (example: `bids::sub-01/ses-01/eeg/sub-01_eeg.eeg`)
| `timestamp`                  	| string  | (Optional) timestamp in ISO 8601 format.       
```

## NIBS: Transcranial Electrical Stimulation section.

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates. Supports multiple navigation systems via flexible fields. 

```
| Field                	| Type   | Description                                                                                             | Units    |
| -------------------- 	| ------ | ------------------------------------------------------------------------------------------------------- | -------- |
| `stim_id`             | string | Unique identifier for each marker. This column must appear first in the file.                           |   —      |
| `channel_name` 	   	| string | (Optional)(tES-specific). Human-readable name of the electrode/channel (e.g., AF3, Fp2, Ch7).		   |		  |
| `target_x`           	| number | X-coordinate of the target point in millimeters.                                                        | `mm`     |
| `target_y`           	| number | Y-coordinate of the target point in millimeters.                                                        | `mm`     |
| `target_z`           	| number | Z-coordinate of the target point in millimeters.                                                        | `mm`     |
| `entry_x`            	| number | X-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `entry_y`            	| number | Y-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `entry_z`            	| number | Z-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `electric_field_max_x`| number | (Optional)X coordinate of max electric field point.                                                     | `mm`     |
| `electric_field_max_y`| number | (Optional)Y coordinate of max electric field point.                                                     | `mm`     |
| `electric_field_max_z`| number | (Optional)Z coordinate of max electric field point.                                                     | `mm`     |
| `timestamp`          	| string | (Optional)timestamp of the stimulation event in ISO 8601 format.                                        | ISO 8601 |
```

### 1.2 `*_nibs.json` — Sidecar JSON 

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
|Field									|Type   | Description	
|---------------------------------------|-------|-----------------------------------
|electrode_id							|string	| Unique identifier for this electrode type (e.g., "el1"), referenced in *_nibs.tsv.
|ElectrodeType							|string	| Type of electrode: pad, HD, ring, custom, etc.
|ElectrodeShape							|string	| Physical shape: rectangular, circular, ring, segmented, etc.
|ElectrodeSize							|string	| Structured field: surface area of the electrode (e.g., 25 cm²).
|ElectrodeThickness						|string	| Structured field: total thickness of the electrode (mm), including any conductive interface (e.g., sponge).
|ElectrodeMaterial						|string	| Material in direct contact with skin: AgCl, rubber, carbon, etc.
|ContactMedium							|string	| Interface material: gel, saline, paste, dry, etc.
```

** Example:**

```
"ElectrodeSet": [
  {
    "electrode_id": "el_1",
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
    "ContactMedium": "saline-soaked sponge"
  }
]
```

### 1.3 `*_nibs.tsv` — Stimulation Parameters

This section describes all possible fields that may appear in *_nibs.tsv files. 
The fields are grouped into logical sections based on their function and purpose. 
All fields are optional unless stated otherwise, but some are strongly recommended.
The order of parameters in _nibs.tsv follows a hierarchical structure based on their variability during an experiment and their role in defining the stimulation process. 
Parameters are grouped into three logical blocks. Grouping fields this way improves readability and aligns with practical data collection workflows.

**Stimulator Device & Configuration**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`electrode_id`			|string	| Unique identifier for this electrode type (e.g., "el1"), referenced in *_nibs.ts
|`tes_stim_mode`		|string	| Type of stimulation mode (tDCS, tACS, tRNS,tPCS (transcranial Pulsed Current Stimulation))
|`control_mode`			|string	| Stimulator control mode: what we stabilize. (current-controlled, voltage-controlled)
```

**Protocol Metadata** 

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`protocol_name`        |string | Name of stimulation protocol (e.g. theta, alpha, working_memory, etc.)
```

**Stimulation Timing Parameters tACS/tDCS**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`waveform`				|string | Type of waveform (sine, square, pulse, custom)
|`waveform_frequency`	|number | Frequency of waveform (for tACS) (Hz)
|`noise_type`			|string | Type of noise (for tRNS) (white, pink, band-limited, custom)
|`stimulation_duration` |number | Total stimulation time (seconds)
|`ramp_up_duration` 	|number | Time to ramp current up (seconds)
|`ramp_down_duration`	|number | Time to ramp current down (seconds)
```

**Stimulation Timing Parameters tPCS (transcranial Pulsed Current Stimulation)**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`pulse_width`			|number | Width of each current pulse (ms)
|`burst_pulses_number`	|number | Pulses per burst (if grouped)
|`burst_duration`       |number | Duration of a single burst block          
|`pulse_rate`			|number | Repetition rate (1/InterPulseInterval)
```

**Spatial & Targeting Information**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
|`stim_id`              |string	| Identifier of stimulation target. 
|`channel_name`			|string	| Name of cahnnel/electrode according 10-20 system (AF3, Ch1)
|`channel_type`			|string	| Channel function (anode, cathode, return, ground)
|`stim_count`  			|number | (Optional) Number of stimulation steps or repetitions delivered at this spatial location.
```

**Amplitude & Thresholds**

```
|Field						|Type   | Description	
|---------------------------|-------|-----------------------------------
|`current_intensity`		|number | Current applied through the electrode (mA)
|`current_density` 			|number | Current per unit surface area (mA/cm²)
|`voltage_intensity`		|number | Peak voltage applied (if voltage-controlled) (V)
|`threshold_type`			|number | Type of physiological or behavioral threshold used for defining ThresholdIntensity. Optional (motor, phosphene, perceptual, pain, none, other).
|`threshold_intensity`		|number | Subject-specific threshold used for scaling (mA or V)
|`pulse_intensity_threshold`|number | Stimulation intensity expressed as % of threshold (%)
```

**Derived / Device-Generated Parameters**
```
|Field							|Type   | Description	
|-------------------------------|-------|-----------------------------------
|`impedance`					|number	| (Optional) Measured impedance per channel (kΩ)
|`estimated_field_strength`		|number | (Optional) Computed or simulated electric field strength at target (V/m)
|`system_status`				|string | (Optional) Device-detected QC status. Suggested levels: ok, impedance_high, unstable_contact, channel_fail, n/a
|`subject_feedback`				|string | (Optional) Participant-reported perception or discomfort. Suggested levels: none, tingling, itching, burning, pain, unpleasant, other.
|`measured_current_intensity`	|number	| (Optional) Current measured by the device during stimulation in voltage-controlled mode. May vary across pulses or be averaged. (mA)
|`current_statistics`			|string | (Optional) Summary of current over session: e.g., mean=0.8;max=1.2;min=0.4
|`timestamp`					|string | (Optional) ISO 8601 timestamp for the event or setting
```

## NIBS: Transcranial Ultrasound Stimulation section.

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates. Supports multiple navigation systems via flexible fields. 

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
| `transducer_transform`| array  | (Optional) 4×4 affine transformation matrix representing the transducer’s spatial pose in the coordinate system. This field should be included only when the transducer was repositioned across different stimulation points, such that a single transformation in *_coordsystem.json would not adequately describe all locations.
```

* target_x/y/z: "Coordinates of the acoustic focus — the point where the ultrasound energy is concentrated and stimulation is intended to occur."
* entry_x/y/z: "Scalp entry point of the ultrasound beam — where it penetrates the skin and skull en route to the target."
* transducer_x/y/z: "Coordinates of the ultrasound transducer’s physical reference point — typically its geometric center or coupling interface."
* normal_x/y/z: "Unit vector normal to the scalp at the entry point, defining the intended beam axis direction."
* beam_x/y/z: "Unit vector defining the direction of the ultrasound beam propagation from the transducer. Used if the beam axis differs from the scalp surface normal vector (normal_x/y/z)."
* transducer_transform: "Optional 4×4 affine transformation matrix describing the transducer’s spatial pose (position and orientation) relative to the coordinate system defined in *_coordsystem.json. Used in setups with tracked transducers or navigation systems."

### 1.2 `*_nibs.json` — Sidecar JSON 

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

### 1.3 `*_nibs.tsv` — Stimulation Parameters

This section describes all possible fields that may appear in *_nibs.tsv files. 
The fields are grouped into logical sections based on their function and purpose. 
All fields are optional unless stated otherwise, but some are strongly recommended.
The order of parameters in _nibs.tsv follows a hierarchical structure based on their variability during an experiment and their role in defining the stimulation process. 
Parameters are grouped into three logical blocks. Grouping fields this way improves readability and aligns with practical data collection workflows.

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