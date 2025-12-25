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

## 7. Design & Philosophy

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
| `PulseIntensityScalingReference`		|string	| Specifies which per-instance intensity field is used as the reference value for applying PulseIntensityScalingVector when pulse-specific intensities differ within a stimulus atom.(Allowed values: base, threshold). base - scaling is applied to the device-level intensity recorded in *_nibs.tsv. threshold - scaling is applied to the absolute threshold intensity recorded in *_nibs.tsv (e.g., RMT/AMT/phosphene threshold expressed in device units).  
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
	  "PulseIntensityScalingReference": "base",
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
	  "PulseIntensityScalingReference": "threshold",
      "PulseIntensityScalingDescription": "Pulse-specific intensities are computed by adding the corresponding offset to the threshold pulse intensity in *_nibs.tsv (ordered by pulse occurrence within the stimulus). Vector length MUST match StimulusPulsesNumber.",
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

* Rule for `threshold_pulse_intensity`: 
	
If `PulseIntensityScalingVector` is present and `PulseIntensityScalingReference` = `threshold_reference_intensity`, then `threshold_pulse_intensity` SHOULD be omitted, since pulse-specific threshold-relative intensities are fully determined by `threshold_reference_intensity` and the scaling vector.
If `PulseIntensityScalingVector` is not present, `threshold_pulse_intensity` MAY be used to encode a single intensity value relative to the chosen threshold.

* Notes

	(2) When threshold-based dosing is used, `threshold_pulse_intensity` specifies the stimulation intensity relative to the threshold defined by `threshold_type`, while `base_pulse_intensity` stores the corresponding absolute stimulator output value.
	(3) If both `threshold_pulse_intensity` and `base_pulse_intensity` are provided, they MUST be numerically consistent with `threshold_reference_intensity`.
	
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

### 1.4 `*_nibs.json` & `*_nibs.tsv` Hierarchy logic

Legend:

  stim_id  -> references a StimulusSet entry in *_nibs.json
  atom     -> smallest repeating stimulation unit defined by stim_id
  row      -> one row in *_nibs.tsv = one stimulation instance (≤ one train)

Hierarchy (structure + repetition):

StimulusSet (in *_nibs.json)
  └─ stim_id = "stim_A"
       └─ stimulus atom
            ├─ pulses inside the atom: StimulusPulsesNumber = N
            ├─ within-atom pulse spacing: stimulus_pulse_interval (TSV, if N > 1)
            └─ pulse properties: waveform / pulse_width / current_direction / scaling rules

Within one stimulation instance (one row in *_nibs.tsv)
  └─ train (≤ 1 per row)
       └─ burst (optional grouping)
            ├─ number of repeated atoms: burst_stimuli_number = B
            ├─ atom-to-atom spacing:     burst_stimuli_interval (or burst_stimuli_rate)
            └─ (each atom is the same stim_id structure, repeated B times)		

Between stimulation instances (across rows)
  ├─ inter_trial_interval (row-to-row onset spacing, if periodic)
  └─ onsets/time-locking recorded in *_events.tsv (recommended for delivered instances)





## Appendix A: Examples of “protocol recipes”:

### Example 1 — Single-pulse TMS (manual or externally triggered)

* Conceptual meaning

A stimulation instance corresponds to the delivery of one single TMS pulse.
Each delivered pulse is treated as an independent stimulation instance and is represented by one row in *_nibs.tsv.

Stimulus definition (*_nibs.json → StimulusSet)
This example defines a single-pulse stimulus atom.

```
"StimulusSet": [
  {
    "StimulusID": "stim_1",
    "StimulusType": "single_pulse",
    "Waveform": "monophasic",
    "PulseWidth": {
      "Value": 0.2,
      "Units": "ms",
      "Description": "Pulse duration measured from onset to offset"
    },
    "StimulusPulsesNumber": 1,
    "PulseCurrentDirection": "normal",
    "PulseCurrentDirectionDescription": "Defined according to manufacturer-specific coil orientation convention"
  }
]

```

* Interpretation

	- StimulusID defines the stimulus atom.
	- The atom contains exactly one pulse (StimulusPulsesNumber = 1).
	- All pulse-internal properties are fixed and therefore belong in JSON.

* Stimulation instances (*_nibs.tsv)

Each row corresponds to one delivered single pulse.

```
stim_id   stim_count  base_pulse_intensity  threshold_type  threshold_reference_intensity  threshold_pulse_intensity  inter_trial_interval
stim_1    1           55                    resting_motor   50             				   110                        5
stim_1    2           55                    resting_motor   50              			   110                        5
stim_1    3           55                    resting_motor   50               			   110                        5
```

* Timing note

	- If pulses are manually triggered or irregular, onsets SHOULD be recorded in *_events.tsv, and inter_trial_interval MAY be omitted.
	- If pulses are delivered periodically, inter_trial_interval or trial_rate MAY be used.

### Example 2 — Paired-pulse TMS (e.g., SICI / ICF)

* Conceptual meaning

A stimulation instance corresponds to the delivery of one paired-pulse stimulus, consisting of two pulses delivered with a fixed onset-to-onset interval.
Each paired-pulse delivery is treated as one stimulation instance and represented by one row in *_nibs.tsv.

* Stimulus definition (*_nibs.json → StimulusSet)

This example defines a paired-pulse stimulus atom.

```
"StimulusSet": [
  {
    "StimulusID": "stim_1",
    "StimulusType": "paired_pulse",
	"StimulusPulsesNumber": 2,
    "Waveform": "biphasic",
    "PulseWidth": {
      "Value": 0.2,
      "Units": "ms",
      "Description": "Pulse duration measured from onset to offset"
    },
	"PulseIntensityScalingType": "multiplicative",
    "PulseIntensityScalingVector": [0.8, 1.1],
	"PulseIntensityScalingReference": "threshold",
	"PulseIntensityScalingDescription": "Conditioning pulse at 80% of threshold, test pulse at 110% of threshold",
    "PulseCurrentDirection": "normal",
    "PulseCurrentDirectionDescription": "Defined according to manufacturer-specific coil orientation convention"
  }
]
```

* Interpretation

 - StimulusID = stim_1 defines the stimulus atom.
 - The atom contains two pulses (StimulusPulsesNumber = 2).
 - Pulse-internal properties (waveform, width, direction) are fixed and belong in JSON.
 - No timing between pulses is defined here — timing belongs to *_nibs.tsv.

* Stimulation instances (*_nibs.tsv)

Each row corresponds to one delivered paired-pulse stimulation instance.

```
stim_id  stim_count  stimulus_pulse_interval  threshold_type      threshold_reference_intensity  inter_trial_interval
stim_1   1           0.003                    resting_motor       55               			     6
stim_1   2           0.003                    resting_motor       55              			     6
stim_1   3           0.003                    resting_motor       55               			     6

```

* Timing note

- The paired-pulse structure is fully defined by:

	- StimulusPulsesNumber = 2 (JSON)
	- stimulus_pulse_interval (TSV)

If paired-pulse stimuli are delivered irregularly or task-triggered, onsets SHOULD be recorded in *_events.tsv.




### 3. Burst-based stimulation (e.g., TBS-like constructs)

### 4. Threshold-based dosing using non-motor thresholds

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