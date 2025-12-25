# NIBS-BIDS proposal v.6+ (Scalable Structure for Non-Invasive Brain Stimulation)

### This document presents a concise overview of our proposed scalable structure for organizing **non-invasive brain stimulation (NIBS)** data in BIDS. 

### It is designed to precede and accompany real-life examples and comparative demonstrations.


## 1. NIBS as a Dedicated `datatype`

* All data related to non-invasive brain stimulation is stored under a dedicated `nibs/` folder.
* This folder is treated as a standalone BIDS `datatype`, similar in role to `eeg/`, `pet/`, or `motion/`.
* This design allows coherent grouping of stimulation parameters, spatial data, and metadata.

### Template:

```
sub-<label>/
    └──[ses-<label>/]
        └──nibs/
			├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_rel-<label>]_coordsystem.json
			├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_rel-<label>][_acq-<label>][_run-<index>]_nibs.tsv
            ├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_rel-<label>][_acq-<label>][_run-<index>]_nibs.json
			├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_rel-<label>][_acq-<label>][_run-<index>]_markers.tsv
            ├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_rel-<label>][_acq-<label>][_run-<index>]_markers.json
			├─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_rel-<label>][_acq-<label>][_run-<index>]_events.tsv
            └─sub-<label>[_ses-<label>]_task-<label>[_stimsys-<label>][_rel-<label>][_acq-<label>][_run-<index>]_events.json
```


## 2. Supported Stimulation Modalities

* The structure supports multiple types of NIBS techniques:

  * Transcranial Magnetic Stimulation (**TMS**)
  * Transcranial Electrical Stimulation (**TES**, e.g., tDCS, tACS)
  * Transcranial Ultrasound Stimulation (**TUS**)
  `* Peripheral Nerve Stimulation (**PNS**) -> under development`
  
  
## 3. Modality-Specific Suffix via `stimsys`

* To distinguish between different stimulation systems, we introduce the suffix `stimsys` (kind of analogous to `tracksys` in the `/motion` datatype).
* The `stimsys` suffix can take values like `tms`, `tes`, `tus` or `pns`.

The `stimsys-<label>` entity can be used as a key-value pair to label `*_nibs.tsv` and `*_nibs.json` files. 
It can also be used to label `*_markers.tsv`; `*_markers.json` or `*_coordsystem.json` files when they belong to a specific stimulation system.
This entity corresponds to the `StimulationSystemType` metadata field in a `*_nibs.json` file. `stimsys-<label>` entity is a concise string whereas `StimulationSystemType` may be longer and more human readable.


## 4. Online vs Offline Experiments

NIBS paradigms can be applied either concurrently with the acquisition of neuroimaging and/or behavioral data, or in a temporally separated (offline) manner.
The distinction between online and offline stimulation is fundamental in NIBS research and widely used in the TMS and TES communities.
To reflect this distinction in BIDS-compatible datasets, we recommend the use of acquisition labels:

*rel-<label>* — Relationship to Data Acquisition

The 'rel-' entity specifies the temporal relationship between the delivery of non-invasive brain stimulation (NIBS) and the acquisition of neuroimaging and/or behavioral data.
This entity is intended to distinguish whether stimulation was applied concurrently with data acquisition or separately in time, without overloading the acq- entity, which is reserved for acquisition-specific parameters.

Allowed values:

*_rel-online_* — for online paradigms, where NIBS is delivered concurrently with behavioral and/or neuroimaging acquisition.

*_rel-offline_* — for offline paradigms, where NIBS is applied before or after other data recordings, but not during them.

The 'rel-' entity MUST only be used with files belonging to the nibs datatype (e.g., *_nibs.tsv).

```
Example:

	sub-01_ses-01_task-motor_stimsys-tms_rel-online_nibs.tsv
	sub-01_ses-01_task-motor_stimsys-tes_rel-offline_nibs.tsv
```

This avoids the need for new fields in metadata files while maintaining clear, machine-readable semantics.


## 5. Synchronizing NIBS Data Across Modalities (`*_events.tsv`)

### Core Idea 

Each row in a `*_nibs.tsv` file represents one stimulation instance, defined as a single delivered stimulation event or stimulation block applied to the participant.

Every single delivered stimulation event recorded in `*_nibs.tsv` might be spatially described in `*_markers.tsv` and can be **referenced from other modalities** (e.g., `eeg/`, `nirs/`, `beh/`).

```
| Column Name      | Description                                                                							   																																												|
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `stim_id`        | Identifier of a stimulation configuration or stimulation pattern. stim_id defines how stimulation is delivered, independently of where it is applied. 																																	|
| `target_id`	   | Identifier of a spatial stimulation target or target group. target_id links spatial information in `*_markers.tsv` (and its coordinate system in `*_coordsystem.json`) to stimulation records in `*_nibs.tsv` and time-locked annotations in `*_events.tsv` (Sessions with navigation).|
| `stim_count` 	   | Counter indicating the number of times a stimulation instance with the same stim_id has been delivered to the same target_id. 																																							|
```

#### `stim_id`

* Uniqueness and scope:

`stim_id` MUST be unique within the context of a given `*_nibs.json` description. The same `stim_id` MAY be reused across multiple rows in `*_nibs.tsv` when the same stimulation configuration is applied repeatedly.

* File usage 

`*_nibs.tsv`: stim_id is required for each stimulation instance.

`*_nibs.json`: stim_id is used to define stimulation configuration metadata associated with entries in `*_nibs.tsv`.

`*_events.tsv`: stim_id MAY be included to reference the stimulation configuration associated with an event.

#### `target_id`

* Uniqueness and scope:

`target_id` MUST be unique within a given coordinate-system context (i.e., the set of spatial targets defined under the same `*_coordsystem.json`). The same target_id MAY be reused across runs/sessions when the same spatial target definition applies.

* Grouping convention (optional):

`target_id` MAY use a dotted notation (e.g., target_1.1, target_1.2, …) to represent multiple spatial points belonging to the same target group.

* File usage 

`*_markers.tsv`: target_id is required (primary identifier for spatial entries).

`*_nibs.tsv`: target_id is required whenever stimulation is associated with a spatial target.

`*_events.tsv`: target_id is included when an event refers to a specific spatial target or target group.

#### `stim_count`

* Uniqueness and scope:

`stim_count` is interpreted within the context of a given (`stim_id`, `target_id`) combination. Values typically start at 1 and increment monotonically for successive deliveries of the same stimulation configuration to the same spatial target.

* File usage 

`*_nibs.tsv`: `stim_count` is optional, but RECOMMENDED when identical stimulation configurations are delivered repeatedly.

`*_events.tsv`: stim_count MAY be used to align stimulation instances with time-resolved events.


### Modality-Specific Considerations

| Modality | target_id Usage                                   	 | Example Format           |
|----------|-----------------------------------------------------|--------------------------|
| `TMS`    | Typically **one marker** per stimulation            | `target_1.1`             |
| `TES`    | **Multiple electrodes** involved in one stimulation | `target_2.1; target_2.2` |
| `TUS`    | **Single target**, **multiple entry points**        | `target_3.1; target_3.2` |
| `PNS`    | **Multiple electrodes** involved in one stimulation | `target_4.1; target_4.2` | -> UNDER DEVELOPMENT

- target_id's can be **semicolon-separated** to indicate multi-point involvement.
- This preserves **readability** and avoids complex hierarchical structures.

** Example: *_events.tsv**

``` 
onset	duration	trial_type	stim_id		target_id				stim_count
12.500	0.001	    stim_tms	stim_1		target_1.1				1
17.300	0.001	    stim_tes	stim_2      target_2.1;target_2.2	2
23.700	0.001	    stim_tus	stim_3      target_3.1;target_3.2	3
```

## 6. Scalable File Naming Convention

The following files are used to organize stimulation-related data:

** `sub-<label>_task-<label>[_stimsys-<label>][_rel-<label>]_nibs.tsv` **
** `sub-<label>_task-<label>[_stimsys-<label>][_rel-<label>]_nibs.json` **

  * Contains stimulation protocol and pulse parameters + metadata.

** `sub-<label>_task-<label>[_stimsys-<label>][_rel-<label>]_markers.tsv` **
** `sub-<label>_task-<label>[_stimsys-<label>][_rel-<label>]_markers.json` **

  * Contains 3D coordinates of stimulation points (entry, target, etc.), coil spatial orientation, and electric field vectors + metadata.	
  * Equivalent to similar `*_electrodes.tsv or _optodes.tsv`.
  
** `sub-<label>_task-<label>[_stimsys-<label>][_rel-<label>]_coordsystem.json` **

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
The _coordsystem.json file is REQUIRED for navigated TMS, TES, TUS stimulation datasets. If a corresponding anatomical MRI is available, the locations of anatomical landmarks in that scan should also be stored in the _T1w.json file which accompanies the TMS, TES, TUS data.

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
| `HeadMeasurements`							  | object  | Object containing one or more head measurement vectors relevant for 10–20–based navigation. Each value MUST be a numeric array.
| `HeadMeasurementsUnits`						  | string  | Units used for all values stored in HeadMeasurements (e.g., "mm").
| `HeadMeasurementsDescription`					  | string  | Free-form description of how HeadMeasurements were obtained (e.g., tape/geodesic along scalp vs. Euclidean), including any conventions (landmark definitions, repetitions, averaging).
| `DigitizedHeadPoints`                           | string  | Relative path to the file containing the locations of digitized head points collected during the session. (for example, `"sub-01_headshape.pos"`)                                                                                                                               	
| `DigitizedHeadPointsNumber`                     | integer | Number of digitized head points during co-registration.                                                                                                                                                                                                                       		
| `DigitizedHeadPointsDescription`                | string  | Free-form description of digitized points.                                                                                                                                                                                                                                      			
| `DigitizedHeadPointsUnits`                      | string  | Unit type. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`.                                                                                                                                                                                                                      		
| `AnatomicalLandmarkRmsDeviation`                | object  | `{"RMS":[],"NAS":[],"LPA":[],"RPA":[]}` — deviation values per landmark                                                                                                                                                                                                         		
| `AnatomicalLandmarkRmsDeviationUnits`           | string  | Unit of RMS deviation values.                                                                                                                                                                                                                                               			
| `AnatomicalLandmarkRmsDeviationDescription`     | string  | Description of how RMS deviation is calculated and for which markers.                                                                                                                                                                                                         		
```



### TUS-specific transducer coordinate metadata fields (*_coordsystem.json)

These optional fields are recommended for transcranial ultrasound stimulation (TUS) datasets when the spatial position and/or orientation of the ultrasound transducer is known or fixed (e.g., in neuronavigated or modeled setups). 
They complement the standard NIBSCoordinateSystem fields, which typically describe the focus location.
Optional QC metric (in mm) representing the root-mean-square deviation of the ultrasound transducer's actual position and/or orientation from its intended location.
This may be computed from optical tracking, neuronavigation logs, or mechanical fixation assessment.

```
| Field                                         | Type    | Description                                                                                                                                                                                                                                                                     | Units / Levels                      |
| ----------------------------------------------| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 				| ----------------------------------- |
| `TransducerCoordinateSystem`					| string  | Name of the coordinate system used to define the transducer's position (e.g., IndividualMRI, CT, DeviceSpace, etc.).
| `TransducerCoordinateUnits`					| string  | Units of measurement for transducer coordinates (typically mm).
| `TransducerCoordinateSystemDescription`		| string  | Textual description of how the transducer coordinate system was defined and aligned with anatomy.
| `TransducerCoordinates`						| object  | Dictionary with spatial coordinates (e.g., X, Y, Z ) and optionally 4×4 affine transformation matrix for transducer orientation.
| `TransducerCoordinatesDescription`			| string  | Free-text explanation of what the coordinates represent (e.g., transducer center, entry point, beam axis, etc.).
| `TransducerRmsDeviation`						| string  | Root-mean-square deviation (in millimeters) of the ultrasound transducer’s actual position and/or orientation from the planned or intended placement, typically computed across time or repeated trials.
| `TransducerRmsDeviationUnits`   				| string  | Units used to express the RMS deviation value. Must be consistent with the spatial coordinate system units (e.g., "mm").
| `TransducerRmsDeviationDescription`			| string  | Free-text description of how the deviation was calculated, including what was measured (e.g., position, angle), over what time frame, and using which method (e.g., optical tracking, neuronavigation, manual estimate).
```
*These fields enable reproducible modeling, visualization, and interpretation of TUS targeting and acoustic beam propagation when precise transducer positioning is known.

### Optional Headshape Files (*_headshape.<extension>)

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

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `*_markers.json` )

Stores stimulation target coordinates and optional coil's orientation information. Supports multiple navigation systems (e.g., Localite, Nexstim) via flexible fields. 

```
| Field                		| Type   | Description                                                                                                 			
| --------------------------| ------ | ------------------------------------------------------------------------------------------------------- 				
| `target_id`		   		| string | Unique identifier of a spatial stimulation target or target group. This column must appear first in the file.                           				
| `target_name`   	   		| string | (Optional) Name of the cortical target, anatomical label, or stimulation site (purely human-readable label such as: M1_hand, DLPFC, etc.).
| `peeling_depth`       	| number | (Optional )Depth “distance” from cortex surface to the target point OR from the entry marker to the target marker. 				
| `target_x`           		| number | X-coordinate of the target point in millimeters.                                                        					
| `target_y`           		| number | Y-coordinate of the target point in millimeters.                                                        
| `target_z`           		| number | Z-coordinate of the target point in millimeters.                                                        
| `entry_x`            		| number | X-coordinate of the entry point in millimeters.                                                         
| `entry_y`            		| number | Y-coordinate of the entry point in millimeters.                                                         
| `entry_z`            		| number | Z-coordinate of the entry point in millimeters.                                                         
| `coil_transform`      	| array  | (Optional) 4x4 affine transformation matrix for the coil positioning (instrument markers of Localite systems).     
| `coil_x`             		| number | X component of coil's origin location.                                                                  
| `coil_y`             		| number | Y component of coil's origin location.                                                                  
| `coil_z`             		| number | Z component of coil's origin location.                                                                  
| `normal_x`           		| number | X component of coil normal vector.                                                                      
| `normal_y`           		| number | Y component of coil normal vector.                                                                      
| `normal_z`           		| number | Z component of coil normal vector.                                                                      
| `direction_x`        		| number | X component of coil direction vector.                                                                   
| `direction_y`        		| number | Y component of coil direction vector.                                                                  
| `direction_z`        		| number | Z component of coil direction vector.                                                                   
| `electric_field_max_x`	| number | (Optional) X coordinate of max electric field point.                                                               
| `electric_field_max_y` 	| number | (Optional) Y coordinate of max electric field point.                                                               
| `electric_field_max_z` 	| number | (Optional) Z coordinate of max electric field point.                                                               
| `timestamp`          		| string | (Optional) timestamp of the stimulation event in ISO 8601 format.                                                  
```

* timestamp in _markers.tsv, when present, reflects the time at which spatial data were recorded or updated (e.g., neuronavigation update), not necessarily the time of stimulus delivery.

### Field Ordering Rationale

The _markers.tsv file defines the spatial locations and orientation vectors of stimulation targets used in TMS experiments. 
When designing this structure, we drew partial inspiration from existing BIDS files such as `*_electrodes.tsv` (/eeg), which capture electrode positions. 
However, no existing modality in BIDS explicitly supports the full specification required for navigated TMS — including stimulation coordinates, orientation vectors, and electric field estimates.

This makes _markers.tsv a novel file type, tailored to the specific needs of TMS. Fields are ordered to reflect their functional roles:

	- Identification: `target_id` appears first, enabling structured referencing in the `*_nibs.tsv` file. 
	- Spatial Coordinates:` target_`, `entry_` and `peeling_depth`  describe the position of the stimulation point in the selected coordinate system. `coil(x,y,z)` describe the position of the TMS coil in the selected coordinate system.
	- Orientation Vectors: `normal_` and `direction_` vectors or transformation matrix `coil_transform` define the coil orientation in 3D space — a critical factor in modeling TMS effects.
	- Electric Field (optional): `electric_field_max_` defines where the electric field is maximized.

This design is scalable and supports both minimal and advanced use cases: basic datasets can include just the spatial coordinates, while high-resolution multimodal studies can specify full coil orientation and field modeling parameters.

### 1.2 `*_nibs.json` — Sidecar JSON 

The `*_nibs.json` file is a required sidecar accompanying the `*_nibs.tsv` file. 
It serves to describe the columns in the tabular file, define units and levels for categorical variables, and—crucially—provide structured metadata about the stimulation device, task, and context of the experiment.

* Like other BIDS modalities, this JSON file includes:

**Task information**

- TaskName, TaskDescription, Instructions
 
**Institutional context**

- InstitutionName, InstitutionAddress, InstitutionalDepartmentName

**Device metadata**

- Manufacturer, ManufacturersModelName, SoftwareVersion, DeviceSerialNumber.

**Additional options**

- CoilSet, StimulusSet, StimulationSystemType, Navigation, NavigationModelName, NavigationSoftwareVersion.

The `*_nibs.json` file introduces a dedicated hardware block called `CoilSet`, which captures detailed physical and electromagnetic parameters of one or more stimulation coils used in the session. 

This structure allows precise modeling, reproducibility, and harmonization of coil-related effects across studies.

#### `CoilSet` 

```
|Field									|Type   | Description	
|---------------------------------------|-------|-----------------------------------
| `CoilID`								|string	| Unique identifier for the coil, used to reference this entry from _tms.tsv.
| `CoilType`							|string	| Model/type of the coil (e.g., CB60, Cool-B65).
| `CoilSerialNumber`					|string	| Coil serial number
| `CoilShape`							|string	| Geometric shape of the coil windings (e.g., figure-of-eight, circular).
| `CoilCooling`							|string	| Cooling method (air, liquid, passive).
| `CoilDiameter`						|number	| Diameter of the outer winding (usually in mm).
| `MagneticFieldPeak`					|number	| Peak magnetic field at the surface of the coil (in Tesla).
| `MagneticFieldPenetrationDepth`		|number	| Penetration depth of the magnetic field at a reference intensity level (e.g., 70 V/m).
| `MagneticFieldGradient`				|number	| Gradient of the magnetic field at a specific depth (typically in kT/s).
```

#### `CoilSet` description example

```
"CoilSet": [
  {
    "CoilID": "coil_1",
    "CoilType": "CB60",
    "CoilShape": "figure-of-eight",
	"CoilSerialNumber": "2H54-321",
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

#### `StimulusSet` 

`StimulusSet` defines reusable stimulation configurations referenced by `stim_id` in `*_nibs.tsv`.
Structural type of a single stimulation instance associated with stim_id (e.g., single-pulse, paired-pulse, multi-pulse, burst). This field replaces tms_stim_mode in `*_nibs.tsv`.
Each entry describes the internal structure of a stimulation instance, including the number of pulses and rules for interpreting pulse-specific parameters.
StimulusSet does not store trial-specific stimulation values, which remain in `*_nibs.tsv`.

```
|Field									|Type   | Description	
|---------------------------------------|-------|-----------------------------------
| `StimID`								|string	| Identifier of the stimulation configuration or stimulation pattern. (StimID/stim_id) defines how stimulation is delivered, independently of where it is applied.
| `StimulusType`						|string	| High-level structural type of stimulation (single, twin, dual, triple, quadruple, burst, sequence).
| `StimulusPulsesNumber`				|number	| Number of pulses contained in a single stimulus atom defined by stim_id. A stimulus atom is the smallest stimulation unit that may be repeated within bursts, trains, or sequences (e.g., single-pulse: 1; paired-pulse: 2; multi-pulse: N).
| `PulseWaveform`						|string	| Shape of the stimulation pulse waveform produced by the stimulator (e.g., monophasic, biphasic, custom). This field describes the pulse shape for the stimulation configuration referenced by stim_id.
| `PulseWidth`							|string	| (Optional) Duration of a single pulse, measured from pulse onset to pulse offset. This field describes the pulse width for the stimulation configuration referenced by stim_id.
| `PulseWidthUnits`						|string	| Units of PulseWidth (e.g., ms, µs).
| `PulseIntensityScalingType`			|string | Defines how pulse-specific intensities are derived from the base intensity specified in *_nibs.tsv. Type of scaling rule applied (multiplicative, additive). 
| `PulseIntensityScalingVector`			|string	| Vector of scaling coefficients, ordered by pulse occurrence within the stimulus.
| `PulseIntensityScalingUnits`			|string	| Units of the scaling vector when PulseIntensityScalingType is additive (i.e., offsets). If omitted, offsets are assumed to use the same units as the base pulse intensity in *_nibs.tsv. MUST be provided when PulseIntensityScalingType is `additive` and SHOULD be omitted when `multiplicative` scaling is used.
| `PulseIntensityScalingDescription`	|string	| Free-form description clarifying how scaling is applied and how pulse order is defined for the stimulation instance.
| `PulseCurrentDirection`				|string	| Direction of the induced current for the stimulation pulse (e.g., normal, reverse). The interpretation depends on the stimulator and coil model and how “normal/reverse” are defined by the device. Defined per stim_id within StimulusSet. PulseCurrentDirection is defined per stimulation configuration (stim_id) and therefore stored in StimulusSet, even if the same direction is reused across multiple stimulation instances.
| `PulseCurrentDirectionDescription`	|string	| Free-form text description specifying how PulseCurrentDirection is defined and interpreted for the given stimulator and coil configuration (e.g., reference orientation, polarity convention, or manufacturer-specific definition).
```

#### `StimulusSet` description example

```
"StimulusSet": [
    {
      "StimID": "stim_1",
      "StimulusType": "quadri",
      "StimulusPulsesNumber": 4,
	  "PulseWaveform": "monophasic",
	  "PulseWidth": "200",
	  "PulseWidthUnits": "µs",
      "PulseIntensityScalingType": "multiplicative",
      "PulseIntensityScalingVector": [1.0, 1.0, 1.0, 1.1],
      "PulseIntensityScalingDescription": "Pulse-specific intensities are derived by multiplying the base intensity in `*_nibs.tsv by` the corresponding scaling coefficient (ordered by pulse occurrence within the stimulus). The vector length MUST match StimulusPulsesNumber.",
      "PulseCurrentDirection": "normal",
	  "PulseCurrentDirectionDescription": "Free-form text description"
	  },
	{
      "StimID": "stim_2",
      "StimulusType": "triple",
      "StimulusPulsesNumber": 3,
	  "PulseWaveform": "biphasic",
	  "PulseWidth": "200",
	  "PulseWidthUnits": "µs",
      "PulseIntensityScalingType": "additive",
      "PulseIntensityScalingVector": [0.0, 0.0, 5.0],
      "PulseIntensityScalingUnits": "%MSO",
      "PulseIntensityScalingDescription": "Pulse-specific intensities are computed by adding the corresponding offset to the base pulse intensity in *_nibs.tsv (ordered by pulse occurrence within the stimulus). Vector length MUST match StimulusPulsesNumber.",
	  "PulseCurrentDirection": "normal",
	  "PulseCurrentDirectionDescription": "Free-form text description"
	 }
	]
```


The `*_nibs.json` follows standard BIDS JSON conventions and is essential for validator support, automated parsing, and multimodal integration (e.g., aligning stimulation parameters with EEG or MRI metadata).

### 1.3 `*_nibs.tsv` — Stimulation Parameters

* Conceptual definition

Each row in a `*_nibs.tsv` file represents one stimulation instance, defined as a single delivered execution of a stimulation command applied to the participant.

A stimulation instance corresponds to one execution of a stimulation configuration referenced by `stim_id`.
Depending on the protocol, a stimulation instance may consist of:

	- a single stimulus atom (e.g., single-pulse TMS),

	- a paired- or multi-pulse stimulus atom,

	- a burst- or train-based construct composed of repeated stimulus atoms delivered as a single programmed unit.

* A stimulus atom is the smallest repeating stimulation unit defined by `stim_id` and described in `StimulusSet` (e.g., single-pulse, paired-pulse, or multi-pulse structures).

Stimulation instances may be delivered:

	- manually by the experimenter,

	- automatically by the stimulation device,

	- or triggered externally (e.g., by experimental software, behavioral tasks, or physiological events).

All stimulation parameters recorded in a given row describe the configuration, timing, and properties of that specific stimulation instance.
Repeated delivery of the same stimulation configuration SHOULD be represented by multiple rows when individual deliveries are logged or time-locked (e.g., via `*_events.tsv`).
Alternatively, when stimulation is delivered as a predefined block without per-instance logging, a single row MAY be used to describe the entire stimulation block, provided that parameters remain constant across repetitions.

This section describes all possible fields that may appear in `*_nibs.tsv` files.
Fields are grouped into logical sections based on their functional role and expected variability during an experiment.
All fields are optional unless stated otherwise, but some are strongly recommended.

The order and grouping of parameters in `*_nibs.tsv` reflect a hierarchical organization of stimulation metadata, progressing from device and configuration parameters, through protocol and timing definitions, to spatial targeting and derived measures.
This structure mirrors practical stimulation workflows and supports both manual and automated data acquisition scenarios.

**Stimulator Device & Coil Configuration**

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
| `coil_id`				|string	| Coil identifier (e.g. coil\_1, coil\_2). Should be described in Hardware part in json sidecar `CoilID`.
| `targeting_method`	|string	| (Optional) Method used to guide targeting of the coil positioning	(manual, fixed, cobot, robot)
```

**Protocol Metadata** 

```
|Field					|Type   | Description	
|-----------------------|-------|-----------------------------------
| `protocol_name`       |string | The protocol unique name (e.g. sici, lici, custom, etc).
| `stim_id`             |string | Identifier of a stimulation configuration or stimulation pattern.     
```

**Stimulation Timing Parameters**

```
| Field                        		| Type    | Description                                                                                   
| --------------------------------- | ------- | --------------------------------------
| `inter_trial_interval`       		| number  | (Optional) Time from the onset (start) of one stimulation trial to the onset (start) of the next stimulation trial (start-to-start / onset-to-onset). A “trial” refers to one stimulation instance represented by a single row in *_nibs.tsv (which may contain a single pulse or a programmed multi-pulse construct). In the special case where each trial contains a single pulse, this corresponds to the pulse-to-pulse onset asynchrony.
| `trial_rate`				   		| number  | (Optional) Nominal repetition rate of stimulation trials, defined as the inverse of inter_trial_interval when trials are delivered periodically. Expressed in Hz. A trial corresponds to one stimulation instance represented by a single row in *_nibs.tsv.
| `stimulus_pulse_interval`    		| number  | (Optional) Within-stimulus paired-pulse spacing. Time from the onset (start) of the first pulse to the onset (start) of the second pulse within the same stimulus (start-to-start / onset-to-onset) for twin/paired/dual mode.                      
| `burst_stimuli_interval`     		| number  | (Optional) Within-burst stimulus-to-stimulus onset spacing. Time from the onset (start) of one stimulus atom to the onset (start) of the next stimulus atom within the same burst (start-to-start / onset-to-onset). This parameter describes spacing between repeated stimulus atoms (as defined by stim_id), regardless of how many pulses each atom contains.                                                      
| `burst_stimuli_number`       		| number  | (Optional) Number of stimulus atoms delivered within a single burst. Each stimulus atom is a repetition of the stimulation structure referenced by stim_id. 
| `burst_stimuli_rate`         		| number  | (Optional) Rate of stimulus atoms within a burst, defined as the inverse of burst_stimuli_interval when spacing is periodic. Expressed in Hz. If both burst_stimuli_rate and burst_stimuli_interval are provided, they MUST be mathematically consistent.
| `train_burst_number`         		| number  | (Optional) Number of bursts delivered within a single stimulation train.                                                                
| `train_burst_rate`           		| number  | (Optional) Burst repetition rate within a stimulation train, defined as the inverse of the onset-to-onset time between consecutive bursts (when periodic). Expressed in Hz.              
| `inter_burst_interval`  	 		| number  | (Optional) Time from the onset (start) of one burst to the onset (start) of the next burst within the same stimulation train (onset-to-onset).                                                                                                                          
| `train_number`               		| number  | (Optional) Total number of trains delivered in the stimulation sequence (count).                                                                 
| `inter_train_pulse_interval` 	    | number  | (Optional) Time from the onset (start) of the last pulse in one train to the onset (start) of the first pulse in the next train (onset-to-onset across train boundaries).                                            
| `inter_train_interval_delay` 		| number  | (Optional) Per-train additive offset applied to the nominal inter_train_pulse_interval, allowing non-uniform onset-to-onset timing between the last pulse of one train and the first pulse of the next train. The effective interval is computed as: effective interval = inter_train_pulse_interval + inter_train_interval_delay.                                                             
| `train_ramp_up`              		| number  | (Optional) Gradual increase of stimulation amplitude applied across successive trains at the beginning of a stimulation block (train-to-train ramping).                                                          
| `train_ramp_up_number`       		| number  | (Optional) Number of initial trains over which the ramp-up is applied.
| `train_ramp_down`            		| number  | (Optional) Gradual decrease of stimulation amplitude applied across successive trains at the end of a stimulation block (train-to-train ramping).
| `train_ramp_down_number`     		| number  | (Optional) Number of final trains over which the ramp-down is applied.
| `stimulation_duration`	   		| number  | (Optional) Total wall-clock duration of the stimulation block.
```     

* Timing hierarchy note

1. 

`*_nibs.tsv` distinguishes timing parameters across two hierarchical levels:

** Between stimulation instances (trials):
	
inter_trial_interval describes onset-to-onset timing between consecutive stimulation instances (i.e., between consecutive rows in *_nibs.tsv).

** Within a stimulation instance:

When a single stimulation instance contains multiple elements, onset-to-onset timing is described at the appropriate structural level:

	- stimulus_pulse_interval is used to describe pulse-to-pulse onset spacing within a single stimulus atom (e.g., paired- or multi-pulse stimuli without burst grouping).

	- burst_stimuli_interval is used to describe onset-to-onset spacing between repeated stimulus atoms within a burst.

Only the field(s) applicable to the stimulation structure referenced by stim_id SHOULD be populated.

2. 

Consistency rules apply when timing parameters are expressed in both interval and rate form:

	- When both trial_rate and inter_trial_interval are provided, they MUST be mathematically consistent. If stimulation instances are not delivered periodically, trial_rate SHOULD be omitted.

	- When both burst_stimuli_interval and burst_stimuli_rate are provided, they MUST be mathematically consistent.

3. 

In burst-based and train-based protocols, each row in *_nibs.tsv represents at most one train.
Pulse-level and stimulus-atom-level timing within the train is described parametrically using timing fields in *_nibs.tsv, while the timing of delivered trains (i.e., the onset of each stimulation instance) is recorded via *_events.tsv.
**Spatial & Targeting Information**

```
| Field                        | Type    | Description                                                                                    
| ---------------------------- | ------- | --------------------------------------
| `target_id`				   | string  | Identifier of a spatial stimulation target or target group.
| `target_name`                | string  | (Optional) Name of the cortical target, anatomical label, or stimulation site                       
| `coil_handle_direction`	   | string  | (Optional) Сoplanar handle direction (sometimes used in protocols without navigation). 
```

**Amplitude & Thresholds**

```
| Field                        		| Type    | Description                                                                                                 
| --------------------------------- | ------- | --------------------------------------
| `base_pulse_intensity`			| number  | Base pulse intensity expressed as percentage of maximum stimulator output (%MSO). For multi-pulse stimuli, pulse-specific intensities may be derived from this value as defined by stim_id in StimulusSet.                     
| `threshold_pulse_intensity`		| number  | Intensity of the stimulation pulse expressed relative to the threshold defined by threshold_type. Typically reported as a percentage of the threshold value (e.g., 110% of threshold). Units: percentage of the threshold value.
| `threshold_type`					| string  | Type of threshold used as a reference for stimulation dosing (e.g., resting motor threshold, active motor threshold, phosphene threshold, inhibition threshold, pain/discomfort threshold, active_isometric, active_movement, custom). This field defines what physiological or perceptual endpoint the threshold refers to.
| `threshold_reference_intensity`	| number  | Stimulator output value corresponding to the threshold defined by threshold_type. This value provides the reference intensity used for dosing or normalization within the run/session. SHOULD be defined consistently for the given stimulator/system (e.g., %MSO for TMS). If a different unit is used, this MUST be clearly stated in the dataset documentation or sidecar metadata.
| `threshold_criterion`				| string  | Criterion used to define the threshold endpoint (e.g., “1 mV MEP”, “0.2 mV MEP”, “visible twitch”, “perceptible phosphene”, “50% inhibition”, custom). This field specifies what counts as meeting the threshold.
| `threshold_algorithm`				| string  | Algorithm or procedure used to estimate the threshold (e.g., “5/10”, “10/20”, “76% probability (PEST)”, staircase, adaptive method, custom). This field specifies how the threshold was obtained from repeated trials.
| `threshold_measurement_method`	| string  | Measurement modality/method used to assess the response underlying the threshold (e.g., EMG-based MEP, visible twitch observation, participant report, behavioral endpoint, custom). This field clarifies how the threshold endpoint was measured.
```

* Notes

	(1) When threshold-based dosing is used, threshold_pulse_intensity specifies the stimulation intensity relative to the threshold defined by threshold_type, while base_pulse_intensity stores the corresponding absolute stimulator output value.
	(2) If both threshold_pulse_intensity and base_pulse_intensity are provided, they MUST be numerically consistent with threshold_reference_intensity.
	
**Derived / Device-Generated Parameters**

```
| Field                        	| Type    | Description                                                                                   
| ------------------------------| ------- | --------------------------------------
| `stim_count`				    | integer | (Optional) Number of stimulation steps or repetitions delivered at spatial location or total count.
| `stim_validation`             | string  | (Optional) Was the stimulation verified / observed.
| `current_gradient`           	| number  | (Optional) Measured gradient of coil current.                                                            
| `electric_field_target`      	| number  | (Optional) Electric field at stimulation target.                                                          
| `electric_field_max`         	| number  | (Optional) Peak electric field at any location.                                                        
| `motor_response`             	| number  | (Optional) Aggregate motor response metric reported by the stimulation system or experimenter and used for stimulation calibration (e.g., motor threshold determination). This value represents a summary measure of the motor-evoked response (e.g., amplitude or magnitude) as provided by the device or protocol, and does not describe the full EMG waveform. Units and computation method are device- or protocol-dependent and may be proprietary.                                                      
| `latency`                    	| number  | (Optional) Device- or procedure-reported delay between stimulus delivery and the detected motor response, as used during the experiment (e.g., for threshold estimation). This value reflects a summary timing measure and does not imply a standardized EMG onset detection method.                                                    
| `response_channel_name`      	| string  | (Optional) Name of recorded EMG/EEG/MEG channel.                                                         
| `response_channel_type`      	| string  | (Optional) Type of channel (e.g. emg, eeg).                                                              
| `response_channel_description`| string  | (Optional) Description of the response channel.                                                           
| `response_channel_reference`  | string  | (Optional) Reference channel name if applicable.                                                     
| `status`               		| string  | (Optional) Data quality observed on the channel.                                               
| `status_description`   		| string  | (Optional) Freeform text description of noise or artifact affecting data quality on the channel.                                               
| `subject_feedback`		    | string  | (Optional) Participant-reported perception or discomfort.
| `intended_for`               	| string  | (Optional) Path to the recorded file refers to. BIDS-style path. (example: `bids::sub-01/ses-01/eeg/sub-01_eeg.eeg`)
| `timestamp`                  	| string  | (Optional) timestamp in ISO 8601 format.       
```

* Motor response–related parameters in the NIBS-BIDS specification are intended to store procedure-level or device-reported summary values that were used during stimulation setup (e.g., motor threshold determination).
* They are not intended to replace or describe EMG recordings or waveform-level analyses, which should be represented using dedicated EMG data types and extensions when available.




## NIBS: Transcranial Electrical Stimulation section.

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates. Supports multiple navigation systems via flexible fields. 

```
| Field                		| Type   | Description                                                                                             | Units    |
| --------------------------| ------ | ------------------------------------------------------------------------------------------------------- | -------- |
| `stim_id`             	| string | Unique identifier for each marker. This column must appear first in the file.                           |   —      |
| `channel_name` 	   		| string | (Optional) (tES-specific). Human-readable name of the electrode/channel (e.g., AF3, Fp2, Ch7).		   |		  |
| `target_x`           		| number | X-coordinate of the target point in millimeters.                                                        | `mm`     |
| `target_y`           		| number | Y-coordinate of the target point in millimeters.                                                        | `mm`     |
| `target_z`           		| number | Z-coordinate of the target point in millimeters.                                                        | `mm`     |
| `entry_x`            		| number | X-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `entry_y`            		| number | Y-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `entry_z`            		| number | Z-coordinate of the entry point in millimeters.                                                         | `mm`     |
| `electric_field_max_x`	| number | (Optional) X coordinate of max electric field point.                                                     | `mm`     |
| `electric_field_max_y`	| number | (Optional) Y coordinate of max electric field point.                                                     | `mm`     |
| `electric_field_max_z`	| number | (Optional) Z coordinate of max electric field point.                                                     | `mm`     |
| `timestamp`          		| string | (Optional) timestamp of the stimulation event in ISO 8601 format.                                        | ISO 8601 |
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

- Manufacturer, ManufacturersModelName, SoftwareVersion, DeviceSerialNumber, Navigation, NavigationModelName, NavigationSoftwareVersion

Additionally, the _nibs.json file introduces a dedicated hardware block called 'ElectrodeSet', which captures detailed physical and electromagnetic parameters of one or more stimulation electrodes used in the session. 
This structure allows precise modeling, reproducibility, and harmonization of electrode-related effects across studies.

* Each entry in 'ElectrodeSet' is an object with the following fields:

```
| Field									| Type  | Description	
|---------------------------------------|-------|-----------------------------------
| `ElectrodeID`							|string	| Unique identifier for this electrode type (e.g., "el1"), referenced in *_nibs.tsv.
| `ElectrodeType`						|string	| Type of electrode: pad, HD, ring, custom, etc.
| `ElectrodeShape`						|string	| Physical shape: rectangular, circular, ring, segmented, etc.
| `ElectrodeSize`						|string	| Structured field: surface area of the electrode (e.g., 25 cm²).
| `ElectrodeThickness`					|string	| Structured field: total thickness of the electrode (mm), including any conductive interface (e.g., sponge).
| `ElectrodeMaterial`					|string	| Material in direct contact with skin: AgCl, rubber, carbon, etc.
| `ContactMedium`						|string	| Interface material: gel, saline, paste, dry, etc.
```

#### Electrode set description

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
| Field					| Type  | Description	
|-----------------------|-------|-----------------------------------
| `electrode_id`		|string	| Unique identifier for this electrode type (e.g., "el1"), referenced in *_nibs.ts
| `tes_stim_mode`		|string	| Type of stimulation mode (tDCS, tACS, tRNS,tPCS (transcranial Pulsed Current Stimulation))
| `control_mode`		|string	| Stimulator control mode: what we stabilize. (current-controlled, voltage-controlled)
```

**Protocol Metadata** 

```
| Field					| Type  | Description	
|-----------------------|-------|-----------------------------------
| `protocol_name`       |string | Name of stimulation protocol (e.g. theta, alpha, working_memory, etc.)
```

**Stimulation Timing Parameters tACS/tDCS**

```
| Field						| Type  | Description	
|---------------------------|-------|-----------------------------------
| `waveform`				|string | Type of waveform (sine, square, pulse, custom)
| `waveform_frequency`		|number | Frequency of waveform (for tACS) (Hz)
| `noise_type`				|string | (Optional) Type of noise (for tRNS) (white, pink, band-limited, custom)
| `stimulation_duration` 	|number | Total stimulation time (seconds)
| `ramp_up_duration` 		|number | Time to ramp current up (seconds)
| `ramp_down_duration`		|number | Time to ramp current down (seconds)
```

**Stimulation Timing Parameters tPCS (transcranial Pulsed Current Stimulation)**

```
| Field						| Type  | Description	
|---------------------------|-------|-----------------------------------
| `pulse_width`				|number | Width of each current pulse (ms)
| `burst_pulses_number`		|number | Pulses per burst (if grouped)
| `burst_duration`      	|number | Duration of a single burst block          
| `pulse_rate`				|number | Repetition rate (1/InterPulseInterval)
```

**Spatial & Targeting Information**

```
| Field					| Type  | Description	
|-----------------------|-------|-----------------------------------
| `stim_id`             |string	| Identifier of stimulation target. 
| `channel_name`		|string	| (Optional) Name of cahnnel/electrode according 10-20 system (AF3, Ch1)
| `channel_type`		|string	| (Optional) Channel function (anode, cathode, return, ground)
| `stim_count`  		|number | (Optional) Number of stimulation steps or repetitions delivered at this spatial location.
```

**Amplitude & Thresholds**

```
| Field							| Type  | Description	
|-------------------------------|-------|-----------------------------------
| `current_intensity`			|number | Current applied through the electrode (mA)
| `current_density` 			|number | (Optional) Current per unit surface area (mA/cm²)
| `voltage_intensity`			|number | (Optional) Peak voltage applied (if voltage-controlled) (V)
| `threshold_type`				|number | (Optional) Type of physiological or behavioral threshold used for defining ThresholdIntensity. Optional (motor, phosphene, perceptual, pain, none, other).
| `threshold_intensity`			|number | (Optional) Subject-specific threshold used for scaling (mA or V)
| `pulse_intensity_threshold`	|number | (Optional) Stimulation intensity expressed as % of threshold (%)
```

**Derived / Device-Generated Parameters**
```
| Field							| Type  | Description	
|-------------------------------|-------|-----------------------------------
| `impedance`					|number	| (Optional) Measured impedance per channel (kΩ)
| `estimated_field_strength`	|number | (Optional) Computed or simulated electric field strength at target (V/m)
| `system_status`				|string | (Optional) Device-detected QC status. Suggested levels: ok, impedance_high, unstable_contact, channel_fail, n/a
| `subject_feedback`			|string | (Optional) Participant-reported perception or discomfort. Suggested levels: none, tingling, itching, burning, pain, unpleasant, other.
| `measured_current_intensity`	|number	| (Optional) Current measured by the device during stimulation in voltage-controlled mode. May vary across pulses or be averaged. (mA)
| `current_statistics`			|string | (Optional) Summary of current over session: e.g., mean=0.8;max=1.2;min=0.4
| `timestamp`					|string | (Optional) ISO 8601 timestamp for the event or setting
```




## NIBS: Transcranial Ultrasound Stimulation section.

### 1.1 `*_markers.tsv` — Stimulation Site Coordinates (optional sidecar `_markers.json` )

Stores stimulation target coordinates. Supports multiple navigation systems via flexible fields. 

```
| Field                		| Type   | Description                                                                                                 			
| --------------------------| ------ | ------------------------------------------------------------------------------------------------------- 				
| `stim_id`			   		| string | Unique identifier for each marker. This column must appear first in the file.                           				
| `target_name`   	   		| string | (Optional) Name of the cortical target, anatomical label, or stimulation site (M1_hand, DLPFC, etc.).
| `target_x`           		| number | X-coordinate of the target point in millimeters.                                                        					
| `target_y`           		| number | Y-coordinate of the target point in millimeters.                                                        
| `target_z`           		| number | Z-coordinate of the target point in millimeters. 
| `entry_x`					| number | X-coordinate of the scalp entry point where the ultrasound beam penetrates the head.
| `entry_y`					| number | Y-coordinate of the scalp entry point where the ultrasound beam penetrates the head.
| `entry_z`					| number | Z-coordinate of the scalp entry point where the ultrasound beam penetrates the head.
| `transducer_x`			| number | X-coordinate of the transducer's physical reference point (e.g., geometric center or coupling surface).
| `transducer_y`			| number | Y-coordinate of the transducer's physical reference point (e.g., geometric center or coupling surface).
| `transducer_z`			| number | Z-coordinate of the transducer's physical reference point (e.g., geometric center or coupling surface).
| `normal_x`				| number | X-coordinate component of the unit vector normal to the scalp surface at the entry point, defining the intended beam orientation.
| `normal_y`				| number | Y-coordinate component of the unit vector normal to the scalp surface at the entry point, defining the intended beam orientation.
| `normal_z`				| number | Z-coordinate component of the unit vector normal to the scalp surface at the entry point, defining the intended beam orientation.
| `beam_x`					| number | X-coordinate of unit vector representing the actual direction of the ultrasound beam propagation. Used when beam axis differs from the normal vector.
| `beam_y`					| number | Y-coordinate of unit vector representing the actual direction of the ultrasound beam propagation. Used when beam axis differs from the normal vector.
| `beam_z`					| number | Z-coordinate of unit vector representing the actual direction of the ultrasound beam propagation. Used when beam axis differs from the normal vector.
| `transducer_transform`	| array  | (Optional) 4×4 affine transformation matrix representing the transducer’s spatial pose in the coordinate system. This field should be included only when the transducer was repositioned across different stimulation points, such that a single transformation in *_coordsystem.json would not adequately describe all locations.
```

** target_x/y/z: **

- "Coordinates of the acoustic focus — the point where the ultrasound energy is concentrated and stimulation is intended to occur."

** entry_x/y/z: **  

- "Scalp entry point of the ultrasound beam — where it penetrates the skin and skull en route to the target."

** transducer_x/y/z: ** 

- "Coordinates of the ultrasound transducer’s physical reference point — typically its geometric center or coupling interface."

** normal_x/y/z: ** 

- "Unit vector normal to the scalp at the entry point, defining the intended beam axis direction."

** beam_x/y/z: ** 

- "Unit vector defining the direction of the ultrasound beam propagation from the transducer. Used if the beam axis differs from the scalp surface normal vector (normal_x/y/z)."

** transducer_transform: ** 

- "Optional 4×4 affine transformation matrix describing the transducer’s spatial pose (position and orientation) relative to the coordinate system defined in *_coordsystem.json. Used in setups with tracked transducers or navigation systems."

### 1.2 `*_nibs.json` — Sidecar JSON 

The _nibs.json file is a required sidecar accompanying the _nibs.tsv file. 
It serves to describe the columns in the tabular file, define units and levels for categorical variables, and—crucially—provide structured metadata about the stimulation device, task, and context of the experiment.

Like other BIDS modalities, this JSON file includes:

**Task information:**

- TaskName, TaskDescription, Instructions

**Institutional context:**

- InstitutionName, InstitutionAddress, InstitutionalDepartmentName

**Device metadata:**

- Manufacturer, ManufacturersModelName, SoftwareVersion, DeviceSerialNumber, Navigation, NavigationModelName, NavigationSoftwareVersion

Additionally, the _nibs.json file introduces a dedicated hardware block called "TransducerSet".
TransducerSet provides a structured, machine-readable description of one or more transcranial ultrasound transducers used in the dataset.
Each transducer is defined as an object with a unique transducer_id, which is referenced from the *_nibs.tsv file.
This structure mirrors the approach used in 'CoilSet' (TMS-section) and includes key physical and acoustic properties of each transducer, such as center frequency, focus depth, aperture diameter, and intensity-related parameters.

* Each entry in 'TransducerSet' is an object with the following fields:
```
| Field							|  Type  | Description	
| ------------------------------| -----	 | --------------------------------------------------------------------------------------------------------- 				
| `TransducerID`				| string | Unique identifier for the transducer, referenced from *_nibs.tsv.
| `TransducerType`				| string | Physical configuration: single-element, phased-array, planar, or custom.
| `FocusType`					| string | Acoustic focus shape: point, line, volume, or swept.
| `CarrierFrequency`			| number | Nominal center frequency of the ultrasound wave (Hz).
| `FocalDepth`					| number | Distance from the transducer surface to the acoustic focus (mm).
| `ApertureDiameter`			| number | Diameter of the ultrasound-emitting surface (mm).
| `PeakNegativePressure`		| number | Peak negative pressure in the focus (MPa).
| `MechanicalIndex`				| number | Safety-relevant mechanical index (dimensionless).
| `ContactMedium`				| string | Coupling method between the transducer and the scalp, such as gel, membrane, water bag, or dry contact.
```

#### Transducer set description:

```
"TransducerSet": [
  {
    "TransducerID": "tr_1",
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
| Field							| Type  | Description	
|-------------------------------|-------|-----------------------------------
| `protocol_name`       		|string | Name of the stimulation protocol or experimental condition associated with this stimulation configuration (e.g., theta, working_memory, burst_40Hz, sham).
```

**Stimulation Timing Parameters**

```
| Field                        	| Type    | Description                                                                                    | Units / Levels                              |
| ---------------------------- 	| ------- | --------------------------------------
| `waveform`					| string  | sine, square, burst, AM, FM, custom
| `carrier_frequency`			| number  | Frequency of the continuous or pulsed ultrasound carrier
| `duty_cycle`					| number  | Percentage of time the ultrasound is active (on) within each pulse or burst cycle. Expressed as a number between 0 and 100.
| `pulse_width`					| number  | Duration of a single ultrasound pulse
| `inter_trial_interval`		| number  | (Optional) Time between repeated trials or blocks
| `inter_pulse_interval`		| number  | (Optional) Time between pulses within a burst
| `burst_pulses_number`			| number  |	(Optional) Number of pulses per burst
| `burst_duration`				| number  | (Optional) Duration of a single burst block
| `pulse_rate`					| number  | (Optional) Repetition rate of pulses within a burst (PRF equivalent)
| `train_pulses`				| number  | (Optional) Number of pulses in a full train (e.g. 100 pulses = 10 bursts of 10 pulses)
| `repetition_rate`				| number  | (Optional) How often the burst is repeated (can be inverse of InterTrialInterval)
| `inter_repetition_interval`   | number  | (Optional) Time between start of burst N and N+1.
| `train_duration`              | number  | (Optional) Duration of the full train.                                                                    | msec                                        |
| `train_number`                | number  | (Optional) Number of trains in sequence.                                                                  | —                                           |
| `inter_train_interval`        | number  | (Optional) Time from last pulse of one train to first of next.                                            | msec                                        |
| `inter_train_interval_delay`  | number  | (Optional) Per-train delay override.      
| `train_ramp_up` 				| number  | (Optional) Proportional ramping factor or amplitude increment per train (e.g., in % of max intensity)
| `train_ramp_up_number` 		| number  | (Optional) Number of initial trains during which ramp-up is applied
| `stimulation_duration`		| number  | (Optional) Total duration of the stimulation block
| `ramp_up_duration`			| number  | (Optional) Duration of ramp-up (fade-in) at onset
| `ramp_down_duration`			| number  | (Optional) Duration of ramp-down (fade-out) at offset
```

**Spatial & Targeting Information**

```
| Field                        | Type    | Description                                                                                    | Units / Levels                              |
| ---------------------------- | ------- | --------------------------------------
| `stim_id`                    | string  | Identifier of stimulation target or target group.       
| `target_name`                | string  | (Optional) Human-readable name or anatomical label of the stimulation site (e.g., M1_hand, left_DLPFC, anterior_insula).
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
| `stim_validation`             | string  | (Optional) Was the stimulation verified / observed.
```

**Derived / Device-Generated Parameters**

```
|Field							|Type   | Description	
|-------------------------------|-------|-----------------------------------
| `system_status`				|string | (Optional) Device-reported status during or after stimulation. Examples: ok, overload, error.
| `subject_feedback`			|string | (Optional) Participant-reported experience or sensation during stimulation (e.g., none, pain, tingling, heat).
| `measured_pulse_intensity`	|number | (Optional) Actual measured intensity of the stimulation pulse, in the same units as PulseIntensity. Used if different from the planned value.
| `transducer_rms_deviation`	|number | (Optional) Root-mean-square deviation of the transducer position during stimulation, in millimeters.
| `timestamp`               	|string | (Optional) Timestamp in ISO 8601 format. 
```



## Appendix A: Examples of “protocol recipes”:

### 1. Single-pulse TMS (manual/triggered)

** StimulusSet (*_nibs.json)

* Used to define the stimulation structure referenced by stim_id.

	- StimID = stim_01
	- StimulusType = single
	- StimulusPulsesNumber = 1
	- PulseWaveform = (monophasic/biphasic)
	- PulseWidth = (optional)
	- PulseCurrentDirection = (optional)

** `*_nibs.tsv`

* Each row corresponds to one delivered single pulse.

Typical fields:

	- stim_id
	- target_id (optional; if spatial targeting is used)
	- base_pulse_intensity
	- (optional threshold-based dosing)
		- threshold_type
		- threshold_reference_intensity
		- threshold_pulse_intensity
		- threshold_criterion
		- threshold_algorithm
		- threshold_measurement_method
	- inter_trial_interval (optional; if pulses are delivered periodically)

** `*_events.tsv`

* Used to record the timing of each delivered pulse (onset), linked via stim_id and target_id.

### 2. Paired-pulse TMS (e.g., SICI / ICF)

* Description

A paired-pulse stimulation protocol in which each delivered stimulation instance consists of two pulses separated by a fixed onset-to-onset interval. 
The paired-pulse stimulation may be repeated multiple times across a run.

** StimulusSet (*_nibs.json)

* Defines the paired-pulse structure.
	
	- StimID = stim_01
	- StimulusType = (paired/twin/dual)
	- StimulusPulsesNumber = 2
	- PulseWaveform = (monophasic/biphasic)
	- PulseWidth = (optional)
	- PulseCurrentDirection = (optional)
	- PulseIntensityScalingType = multiplicative
	- PulseIntensityScalingVector = [1.0, 1.1]
	(used to define relative intensities of the two pulses)

** `*_nibs.tsv`

* Each row represents one paired-pulse stimulation instance.

Typical fields:

	- stim_id
	- target_id
	- base_pulse_intensity
	(reference intensity to which scaling is applied)
	- stimulus_pulse_interval
	(onset-to-onset interval between the two pulses)
	- (optional threshold-based dosing)
		- threshold_type
		- threshold_reference_intensity
		- threshold_pulse_intensity
		- threshold_criterion
		- threshold_algorithm
		- threshold_measurement_method
	- inter_trial_interval (if paired-pulse trials are repeated)
	(onset-to-onset interval between consecutive paired-pulse trials, if periodic)

** `*_events.tsv`

* Used to record the timing (onset) of each delivered paired-pulse stimulation instance, linked via stim_id and target_id.

### 3. Burst-based stimulation (e.g., TBS-like constructs)

* Description

A burst-based stimulation protocol in which each delivered stimulation instance corresponds to a single train composed of one or more bursts. 
No per-burst or per-pulse logs are required.

** StimulusSet (*_nibs.json)

* Defines pulse-level properties common to all bursts.

	- StimID = stim_01
	- StimulusType = burst
	- StimulusPulsesNumber (optional; total pulses per stimulation atom instance)
	- PulseWaveform = (monophasic/biphasic)
	- PulseWidth = (optional)
	- PulseCurrentDirection = (optional)
	(optional) PulseIntensityScalingType / Vector
	(used if pulses within a burst have systematic relative intensity differences)

** `*_nibs.tsv`

* Each row represents one delivered train.

	- stim_id
	- target_id
	- base_pulse_intensity
	- burst_pulses_number
	(number of pulses per burst)
	- burst_stimuli_interval
	(onset-to-onset interval between pulses within a burst)
	- train_bursts_number
	(number of bursts within the train)
	- inter_train_pulse_interval
	(onset-to-onset interval between the last pulse of one train and the first pulse of the next train, if trains are repeated)
	- inter_train_interval_delay
	(optional additive delay applied to the base inter-train interval for a specific train)
	- threshold-related fields (if applicable)

** `*_events.tsv`

* Used to record the onset time of each delivered train. When multiple trains are delivered sequentially, each train is represented as a separate event linked via stim_id and target_id.

### 4. Threshold-based dosing using non-motor thresholds

*Description

Stimulation intensity is defined relative to a non-motor threshold (e.g., phosphene threshold, inhibition threshold).

** `*_nibs.tsv`

* Threshold definition and dosing are recorded explicitly.

Typical fields:

	- stim_id
	- target_id
	- base_pulse_intensity (optional; if absolute value is recorded)
	- threshold_type
	(e.g., phosphene, inhibition, pain, custom)
	- threshold_reference_intensity
	- threshold_pulse_intensity
	- threshold_criterion
	(e.g., perceptible phosphene, 50% inhibition)
	- threshold_algorithm
	(e.g., 5/10, PEST)
	- threshold_measurement_method
	(e.g., participant report, EMG-based MEP)

## Appendix B: Examples 

### Example *_coordsystem.json:

```

```

### Example *_markers.tsv (TMS-section):

```

```

### Examples *_nibs.json (TMS-section):

```

```

### Examples *_nibs.tsv (TMS-section):

```

```