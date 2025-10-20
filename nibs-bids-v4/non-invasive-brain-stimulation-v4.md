# Non-Invasive Brain Stimulation

Support for Non-Invasive Brain Stimulation (NIBS) was developed as a
[BIDS Extension Proposal](../extensions.md#bids-extension-proposals) [BEP037: Non-Invasive Brain Stimulation](https://bids.neuroimaging.io/extensions/beps/bep_037.html) .
Please see [Citing BIDS](../introduction.md#citing-bids)
on how to appropriately credit this extension when referring to it in the
context of the academic literature.

NIBS encompasses a group of techniques that stimulate the brain through the 
skull/scalp, including transcranial magnetic stimulation (TMS), transcranial
electrical stimulation (tES), and transcranial ultrasonic stimulation (TUS). 
NIBS methods are intervention-based and do not record brain 
activity, but they are often used alongside neuroimaging and neurophysiological 
techniques, such as electroencephalography (EEG), magnetoencephalography (MEG), 
magnetic resonance imaging (MRI), electromyography (EMG) etc. Therefore 
NIBS techniques do not introduce new brain recording data formats and can be 
conceptualized as stimuli in relation to brain imaging data. 
NIBS-BIDS aims to standardize the way NIBS metadata (i.e., simulation 
intensity, location, equipment etc.) are reported in a BIDS compliant format. 

!!! example "Example datasets"

Several [example NIBS datasets](https://bids-website.readthedocs.io/en/latest/datasets/examples.html)
have been formatted using this specification and can be used for practical 
guidance when curating a new dataset.

## Online vs Offline experiments.

NIBS can be applied either concurrently while recording neuroimaging and/or 
behavioural data, or in-between neuroimaging/behaviour data recordings. We 
therefore make the following definitions: 

* **ONLINE** \= NIBS delivered **while concurrently measuring neuroimaging and/or behavior**  
* **OFFLINE**\= NIBS delivered **without concurrently measuring neuroimaging and/or behavior**

For online NIBS experiments, NIBS is associated with existing data files within BIDS.
In contrast, offline NIBS experiments do not have corresponding data files. 
This poses a problem for BIDS formatting. To circumvent this issue, metadata from online
NIBS experiments SHOULD be stored within existing BIDS data files, whereas metadata from
offline NIBS experiments SHOULD be stored in a `nibs_intervention` directory.  

## Online NIBS experiments.

For online NIBS experiments, it is RECOMMENDED that information relating to 
NIBS are stored in the `*_events.tsv` and `*_events.json` files of the 
corresponding neural recording file accompanying stimulation. This level 
of description is useful when NIBS-related information can vary from stimulus 
to stimulus (e.g., if the coil/electrode/transducer position is being recorded 
using a neuronavigation system, or if the experiment involves stimuli of 
different intensity etc.). NIBS information MAY also be stored in other 
files describing the corresponding neural recording such as the `*_scans.tsv` 
and `*_scans.json` (e.g., if the details of stimulation are fixed throughout 
the recording and description at an individual stimulus level is not required).

Importantly, information relating to NIBS that could vary either between 
participants or between stimuli (or both), or is required in a machine-readable 
format for use in external software SHOULD be stored in TSV files (`*_events.tsv` or `_scans.tsv`).

Methodological and hardware details related to NIBS SHOULD be stored in 
`.json` files (`*_events.json` or `*_scans.json`). Notice that while 
a `.json` file should describe ALL all the columns present in the 
corresponding `.tsv` file, it can also contain other objects not directly 
linked to a column in the `.tsv` file for further details. 

### Online NIBS details (modified `*_events.json` or `*_scans.json`) 

The `*_events.json` or `*_scans.json` will follow the structure of the corresponding `.tsv` file i.e., describing each column present in the `.tsv`.   
In addition, it is RECOMMENDED to include the details of the NIBS device used in the experiment, even if this is not related to any specific column of the `.tsv`, similarly to what is done in [StimulusPresentation](https://bids-specification.readthedocs.io/en/stable/glossary.html#stimuluspresentation-metadata).

| Key name | Requirement Level | Data type | Description |
| :---- | :---- | :---- | :---- |
| NIBSDetails | RECOMMENDED | object or  object of objects | Object containing key-value pairs related to the NIBS device used to apply stimulation during the experiment. If multiple devices are used concurrently, then multiple objects can be used to describe the different devices (for example: `{“NIBSDetails”: {“Device 1”: {“NIBSType”: “TMS”}} {“Device 2”: {“NIBSType”: “tES”}}}` ). |

The object supplied for NIBSDetails SHOULD include the following key-value pairs.

| Key name | Requirement Level | Data type | Description |
| :---- | :---- | :---- | :---- |
| NIBSType | RECOMMENDED | string | Type of NIBS used. (e.g., `"TMS"`, `"tES"`, `"TUS"`). |
| NIBSDescription | RECOMMENDED | string | Free text description of the NIBS protocol. |
| Manufacturer | RECOMMENDED | string | Manufacturer of the NIBS device used in the experiment. Coil/electrodes/transducers manufacturer details should be included in the coil/electrodes/transducers details. |
| ManufactureModelName | RECOMMENDED | string | Manufacturer’s model name of the NIBS device used in the experiment. |
| ManufacturerSerialNumber | RECOMMENDED | string | Manufacturer’s serial number of the NIBS device used in the experiment. |
| SoftwareVersions | OPTIONAL | string | Manufacturer's designation of software version of the device that produced the stimulation. |
| CoilDetails | OPTIONAL | object of objects | Object of the TMS coils used in the experiment. Each key-value pair in the `.json` object is a name of the coil and an object in which its parameters are defined as key-value pairs (for example: `{“CoilDetails”: {“Coil 1”: {“ModelName”: “D70”, “SerialNumber”: “4150-00”}} {“Coil 2”: {“ModelName”: “DCC”, “SerialNumber”: “4610-00”}}}` ). |
| ElectrodeDetails | OPTIONAL | object of objects | Object of the tES electrodes used in the experiment. Each key-value pair in the `.json` object is a name of the electrode and an object in which its parameters are defined as key-value pairs (for example: `{“ElectrodeDetails”: {“Electrode 1”: {“Shape”: “Rect”, “Dimensions”: [50, 70], “Thickness”: [5, 2]}}{“Electrode 2”: “Shape”: “Ellipse”, “Dimensions”: [20, 20], “Thickness”: [5, 2]}}}`). |
| TransducerDetails | OPTIONAL | object of objects | Object of the TUS transducers used in the experiment. Each key-value pair in the `.json` object is a name of the transducer and an object in which its parameters are defined as key-value pairs (for example: `{“TransducerDetails”: {“Transducer 1”: {“Manufacturer”: “Brainsonix”, “ModelName”: “BX Pulsar 1002”, “SerialNumber”: 123, “Type”: “Spherical”,  “Elements”: 1, “FocalLengthType”: “Fixed”, “FocalLength”: 80 (mm), “CenterFrequency”: 650 (kHz), “Geometry”: [radius of curvature, aperture diameter, full width half maximum]}}`). |

#### **Example** (`*_events.tsv` for TMS)
```
onset       duration    trial_type      tms_rmt     tms_intensity_mso   tms_pos_centre      tms_pos_ydir  
4.013       0           TMS1            63          63                  Left M1             CP5  
9.154       0           TMS2            63          69                  Left M1             CP5  
14.984      0           TMS3            63          76                  Left M1             CP5
```

#### **Example**  (`*_events.json` for TMS)

```json
{  
    "NIBSDetails": {  
        "NIBSType": "TMS",  
        "NIBSDescription": "Input-output curve of single monophasic TMS pulses applied to the left primary motor cortex",  
        "Manufacturer": "Magstim",  
        "ManufactureModelName": "BiStim^2",  
        "ManufacturerSerialNumber": "3234-00",  
        "CoilDetails": {  
            "Coil 1": {  
                "ModelName": "D70",  
                "SerialNumber": "4150-00"  
            }  
        }  
    },  
    "onset": {  
        "LongName": "Event Onset",  
        "Description": "Time from the start of the recording when the event occurred.",  
        "Units": "seconds"  
    },  
    "duration": {  
        "LongName": "Event Duration",  
        "Description": "Duration of the event.",  
        "Units": "seconds"  
    },  
    "trial_type": {  
        "LongName": "Stimulation type",  
        "Description": "Type of stimulation that is applied to the participant.",  
        "Levels": {  
            "TMS1": "A single monophasic TMS pulse at RMT",  
            "TMS2": "A single monophasic TMS pulse at 110% RMT",  
            "TMS3": "A single monophasic TMS pulse at 120% RMT",  
        }  
    },  
    "tms_rmt": {  
        "LongName": "TMS Resting Motor Threshold",  
        "Description": "Lowest stimulation intensity required to evoke at least 5 out of 10 MEPs with a peak-to-peak amplitude > 0.05 mV, described as a percentage of maximum stimulator output (MSO). ",  
        "Units": "percent"  
    },  
    "tms_intensity_mso": {  
        "LongName": "TMS Stimulation Intensity",  
        "Description": "The intensity of the TMS pulse delivered as a percentage of maximum stimulator output (MSO).",  
        "Units": "percent"  
    },  
    "tms_pos_centre": {  
        "LongName": "Centre of the TMS coil",  
        "Description": "The position of the TMS coil center relative to the underlying target cortical area.",  
        "Levels": {  
            "Left M1": "Coil center positioned over Left M1 (primary motor cortex) identified using the hotspot method"  
        }  
    },  
    "tms_pos_ydir": {  
        "LongName": "TMS Coil Handle Direction",  
        "Description": "The  direction of the TMS coil handle relative to EEG electrode position.",  
    }  
}
```

### Online NIBS parameters (modified `*_events.tsv` or `*_scans.tsv`) 

In addition to the columns REQUIRED, RECOMMENDED or OPTIONAL in the 
[`events.tsv`](https://bids-specification.readthedocs.io/en/stable/modality-specific-files/task-events.html) 
or [`scans.tsv`](https://bids-specification.readthedocs.io/en/stable/modality-agnostic-files.html#scans-file) 
we suggest the following columns for each NIBS modality. Note that none of 
these columns are REQUIRED as with this BEP we intend to give guidelines on 
how to describe NIBS experiments in BIDS while allowing the maximum flexibility 
of the BIDS structure. 

#### Transcranial magnetic stimulation (TMS)

The following are OPTIONAL column headers relating to TMS which MAY be added to an `*_events.tsv` file (when it changes over events) or a `*_scans.tsv` file (when it remains constant over events). It is RECOMMENDED to include details of stimulation which can change on a trial-to-trial basis or between recording blocks (e.g., stimulation intensity, coil position etc). Additional columns are also allowed if required.  

| Column name | Requirement Level | Data type | Description |
| :---- | :---- | :---- | :---- |
| tms\_rmt | OPTIONAL | number | Resting motor threshold as a percentage of maximum stimulator output (MSO). Values are expressed as percent, not as fraction (so 80, not 0.80). |
| tms\_amt | OPTIONAL | number | Active motor threshold as a percentage of maximum stimulator output (MSO). |
| tms\_intensity\_mso | OPTIONAL | number | Stimulation intensity as a percentage of maximum stimulator output (MSO). |
| tms\_intensity\_didt | OPTIONAL | number | Rate of change of current in the coil (in A/s). In some stimulators, this value is given on the screen shortly after a pulse is given. |
| tms\_pos\_centre | OPTIONAL | string | Description of the center of the coil. For example, could be in relation to an EEG 10-10 electrode position (e.g., ‘C3’) or a free form description (‘over left primary motor cortex’). If the center of the coil is a coordinate, use tms\_pos\_centre\_x,tms\_pos\_centre\_y,tms\_pos\_centre\_z. |
| tms\_pos\_centre\_x | OPTIONAL | number | Center of the coil in relation to the x-axis coordinate (in mm).  |
| tms\_pos\_centre\_y | OPTIONAL | number | Center of the coil in relation to the y-axis coordinate (in mm).  |
| tms\_pos\_centre\_z | OPTIONAL | number | Center of the coil in relation to the z-axis coordinate (in mm).  |
| tms\_pos\_ydir | OPTIONAL | string | Description of the position along the coil’s y-axis (i.e., prolongation of the handle).  For example, could be in relation to an EEG 10-10 electrode position (e.g., ‘CP5’) or a free form description (‘45 degrees to the midline pointing posterior-lateral’).  If the center of the coil is a coordinate, use tms\_pos\_ydir\_x,tms\_pos\_ydir\_y,tms\_pos\_ydir\_z. |
| tms\_pos\_ydir\_x | OPTIONAL | number | Position along the coil’s y-axis (i.e., prolongation of the handle) in relation to the x-axis coordinate. |
| tms\_pos\_ydir\_y | OPTIONAL | number | Position along the coil’s y-axis (i.e., prolongation of the handle) in relation to the y-axis coordinate. |
| tms\_pos\_ydir\_z | OPTIONAL | number | Position along the coil’s y-axis (i.e., prolongation of the handle) in relation to the z-axis coordinate. |
| tms\_pos\_distance | OPTIONAL | number | Distance from the coil to the scalp (in mm). |
| tms\_pos\_r1\_c1 | OPTIONAL | number | Corresponds to the \[1,1\] row/column position in the affine transformation matrix. |
| tms\_pos\_r1\_c2 | OPTIONAL | number | Corresponds to the \[1,2\] row/column position in the affine transformation matrix. |
| tms\_pos\_r1\_c3 | OPTIONAL | number | Corresponds to the \[1,3\] row/column position in the affine transformation matrix. |
| tms\_pos\_r1\_c4 | OPTIONAL | number | Corresponds to the \[1,4\] row/column position in the affine transformation matrix. |
| tms\_pos\_r2\_c1 | OPTIONAL | number | Corresponds to the \[2,1\] row/column position in the affine transformation matrix. |
| tms\_pos\_r2\_c2 | OPTIONAL | number | Corresponds to the \[2,2\] row/column position in the affine transformation matrix. |
| tms\_pos\_r2\_c3 | OPTIONAL | number | Corresponds to the \[2,3\] row/column position in the affine transformation matrix. |
| tms\_pos\_r2\_c4 | OPTIONAL | number | Corresponds to the \[2,4\] row/column position in the affine transformation matrix. |
| tms\_pos\_r3\_c1 | OPTIONAL | number | Corresponds to the \[3,1\] row/column position in the affine transformation matrix. |
| tms\_pos\_r3\_c2 | OPTIONAL | number | Corresponds to the \[3,2\] row/column position in the affine transformation matrix. |
| tms\_pos\_r3\_c3 | OPTIONAL | number | Corresponds to the \[3,3\] row/column position in the affine transformation matrix. |
| tms\_pos\_r3\_c4 | OPTIONAL | number | Corresponds to the \[3,4\] row/column position in the affine transformation matrix. |
| tms\_pos\_r4\_c1 | OPTIONAL | number | Corresponds to the \[4,1\] row/column position in the affine transformation matrix. |
| tms\_pos\_r4\_c2 | OPTIONAL | number | Corresponds to the \[4,2\] row/column position in the affine transformation matrix. |
| tms\_pos\_r4\_c3 | OPTIONAL | number | Corresponds to the \[4,3\] row/column position in the affine transformation matrix. |
| tms\_pos\_r4\_c4 | OPTIONAL | number | Corresponds to the \[4,4\] row/column position in the affine transformation matrix. |
| **Additional Columns** | OPTIONAL | n/a | Additional columns are allowed. |

NOTE: Additional columns can be added for more detailed description. The coordinate system of the xyz coordinate and the path to the corresponding MRI (if used) will be specified in the corresponding `.json` file within the [Neuronavigation system](#2.5.-neuronavigation). 

NOTE: For simulations with simNIBS, the position of the coil SHOULD be specified with ONE of the following:

1. A text description of the coil center (tms_pos_centre), coil handle direction(tms_pos_ydir) and coil to scalp distance (tms_pos_distance);  
2. Coordinates of the coil centre (tms_pos_centre_x, tms_pos_centre_y, tms_pos_centre_z, handle direction (tms_pos_ydir_x, tms_pos_ydir_y, tms_pos_ydir_z) and coil to scalp distance (tms_pos_distance);  
3. A 4x4 affine transformation matrix (tms_pos_r1_c1, tms_pos_r1_c2,... etc.). If this method is used, the following details MUST also be stored under the NeuronavigationDetails key in the corresponding `.json` file:  
   1. Manufacturer  
   2. NeuronavigationCoordinateSystem  
   3. NeuronavigationCoordinateUnits

#### Transcranial electrical stimulation (tES) 

The following are OPTIONAL column headers relating to tES which MAY be added to an `*_events.tsv` file or a `*_scans.tsv` file. Additional columns are also allowed if required. 

| Column name | Requirement Level | Data type | Description |
| :---- | :---- | :---- | :---- |
| tes\_electrode1\_current | OPTIONAL | number | Current value (in Ampere). Positive values indicate anode (e.g., 0.001), negative values indicate cathode (e.g., \-0.001). Sum of current values with other electrodes MUST equal zero. |
| tes\_electrode1\_channelnr | OPTIONAL | number | Number of the channel this electrode is connected to.  |
| tes\_electrode2\_current | OPTIONAL | number | Current value (in Ampere). Positive values indicate anode (e.g., 0.001), negative values indicate cathode (e.g., \-0.001). Sum of current values with other electrodes MUST equal zero. |
| tes\_electrode2\_channelnr | OPTIONAL | number | Number of the channel this electrode is connected to.  |
| tes\_electrode1\_pos\_centre | OPTIONAL | string | Description of the center of the first electrode. For example, could be in relation to an EEG 10-10 electrode position (e.g., ‘C3’) or a free form description (‘over left primary motor cortex’). |
| tes\_electrode2\_pos\_centre | OPTIONAL | string | Description of the center of the second electrode. For example, could be in relation to an EEG 10-10 electrode position (e.g., ‘C3’) or a free form description (‘over left primary motor cortex’). |
| tes\_electrode1\_pos\_ydir | OPTIONAL | string | Position along the first electrode’s y-axis. For example, could be in relation to an EEG 10-10 electrode position (e.g., ‘F6’) or a free form description. |
| tes\_electrode2\_pos\_ydir | OPTIONAL | string | Position along the second electrode’s y-axis. For example, could be in relation to an EEG 10-10 electrode position (e.g., ‘F6’) or a free form description. |
| **Additional Columns** | OPTIONAL | n/a | Additional columns are allowed. |

NOTE: Additional columns can be added for more detailed description.

NOTE: Additional electrodes can be described using the above naming convention. Additional electrodes MUST use a unique number. For example, tes\_electrode3\_current, tes\_electrode3\_pos\_centre etc. 

NOTE: Electrode information (shape, dimensions, material etc.) are stored in the corresponding `.json` file under NIBSDetails \-\> ElectrodeDetails (2.3.2).

NOTE: Electrode position can also be described using an affine transformation matrix. See TMS (2.3.1.1) for an example.

#### Transcranial ultrasonic stimulation (TUS) 

The following are OPTIONAL column headers relating to TUS which MAY be added to an `*_events.tsv` file or a `*_scans.tsv` file. Additional columns are also allowed if required. 

| Column name | Requirement Level | Data type | Description |
| :---- | :---- | :---- | :---- |
| tus\_transducer\_pos\_x | OPTIONAL | number | Center of the transducer in relation to the x-axis coordinate (in mm) |
| tus\_transducer\_pos\_y | OPTIONAL | number | Center of the transducer in relation to the y-axis coordinate (in mm) |
| tus\_transducer\_pos\_z | OPTIONAL | number | Center of the transducer in relation to the z-axis coordinate (in mm) |
| pulse\_duration | OPTIONAL | number | The shortest continuous period of sonication in milliseconds (e.g., 50 ms). Note: equal to pulse train duration for continuous TUS |
| pulse\_repetition\_frequency | OPTIONAL | number | Frequency (number of pulses emitted in a second) of pulse delivery within the pulse train duration in Hz (e.g., 150 Hz) |
| pulse\_train\_duration | OPTIONAL | integer | The length of time a train of pulses is delivered in seconds (e.g., 30 s) |
| pulse\_train\_repetition\_interval | OPTIONAL | integer | The length of time between the onset of pulse trains in seconds (e.g., 30 s) |
| pulse\_train\_repetition\_interval\_count | OPTIONAL | integer | How many times the pulse train repetition interval is repeated (e.g., 10\) |
| spatial\_peak\_pulse\_avg\_intensity | OPTIONAL | integer | \-Isppa derated v non-derated \- Value |
| spatial\_peak\_temporal\_avg\_intensity | OPTIONAL | integer | \-Ispta derated v non-derated \- Value |
| mechanical\_index | OPTIONAL | structure | \-Name of index \-Integer of index |
| thermal\_index | OPTIONAL | structure | \-Name of index \-Integer of index |
| duty\_cycle | OPTIONAL | integer | Percentage of time sonication is delivered during the pulse repetition interval (e.g., 5%) |
| pulse\_repetition\_interval | OPTIONAL | integer | Time between the onset of two pulses within a train of pulses in milliseconds (e.g., 50 ms) |
| thermal\_dose | OPTIONAL | integer |  |
| **Additional Columns** | OPTIONAL | n/a | Additional columns are allowed. |

NOTE: Additional columns can be added for more detailed description.

NOTE: Transducer position can also be described using an affine transformation matrix. See TMS (2.3.1.1) for an example.


## 2.4. Offline NIBS experiments

As offline NIBS experiments do not have corresponding data recordings, a standalone directory and file type are required.

The details of offline NIBS interventions MAY be stored in the `nibs-intervention` directory using intervention files (`*_nibs-intervention.tsv` and `*_nibs-intervention.json`). Intervention files have the same format as event files, however do not require an onset and duration column,  MUST be labeled `*_nibs-intervention.tsv` and `_nibs-intervention.json`, and are not associated with a corresponding neural recording file. Basically, these files are equivalent to the [`beh.tsv` / `beh.json` pair](https://bids-specification.readthedocs.io/en/stable/modality-specific-files/behavioral-experiments.html) (i.e., behavioral experiments with no neural recordings), however are specifically for interventions designed to modulate neural activity in some way. Using a specific file for interventions instead of `beh` files ensures clarity on the experimental structure.

As with online NIBS protocols, details MAY be stored at either the `*_nibs-intervention.tsv` / `*_nibs-intervention.json` or the `*_scans.tsv` / `*_scans.json` level, although the `*_intervention.tsv` / `*_intervention.json` level is RECOMMENDED.

It is RECOMMENDED to store intervention data/information in the `.tsv` file when those are needed in a machine-readable format (i.e., that could be used for additional analyses, such as coil/electrode/transducer position and stimulation intensity).

Note that files stored in the `nibs-intervention` directory MAY store information from interventions other than NIBS which are also performed without neural recordings (e.g., pharmacological or behavioral interventions). We acknowledge the the presence in the BIDS standard of ways to describe pharmaceutical interventions during a scan (see for example the [pharmaceuticals](https://bids-specification.readthedocs.io/en/stable/modality-specific-files/positron-emission-tomography.html#pharmaceuticals) spec in PET-BIDS) or [electrical stimulation](https://bids-specification.readthedocs.io/en/stable/modality-specific-files/intracranial-electroencephalography.html#electrical-stimulation) during iEEG  sessions. However, we did not find a way already integrated in BIDS to describe events that happens between data recordings.

Template:
```
sub-<label>/  
    [ses-<label>/]  
        intervention/  
            sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_nibs-intervention.json  
            sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_nibs-intervention.tsv
```

### Intervention data files (`*_nibs-intervention.tsv`)

The same OPTIONAL columns as other NIBS-related files are pre-defined for intervention data files. Additional OPTIONAL columns for intervention data files include:

| Column name | Requirement Level | Data type | Description |
| :---- | :---- | :---- | :---- |
| intervention\_type | OPTIONAL | string | Primary categorisation if multiple interventions are administered. For example: it could take on values `"pharmacological"` and `"nibs"` if between neural recordings a drug was given followed by a NIBS intervention.  |
| **Additional Columns** | OPTIONAL | n/a | Additional columns are allowed. |

### Intervention sidecars (`*_nibs-intervention.json`)

It is RECOMMENDED to add the following metadata to the `.json` files of this directory.

| Key name | Requirement Level | Data type | Description |
| :---- | :---- | :---- | :---- |
| InterventionName | RECOMMENDED | string | Name of the intervention. No two interventions should have the same name. |
| InterventionDescription | RECOMMENDED | string | A longer description of the intervention. |

#### **Example**  
The following is an example of storing a TMS intervention, intermittent theta burst stimulation (iTBS), using the intervention framework. In this example, stimulation intensity and coil position information are stored in the `.tsv` file in a machine-readable format, enabling use with tools like SimNIBS to estimate the E-field. However, important details such as stimulation frequency are not included in the `.tsv` file but are stored in the accompanying `.json` file. This decision reflects the consensus that such details are not essential in a machine-readable format. That said, this is not a strict requirement, and researchers converting their datasets to BIDS format have the flexibility to decide whether to include additional information in the `.tsv` file.

#### **Example** (`nibs-intervention` directory structure for iTBS)
```
sub-001/  
    nibs-intervention/  
        sub-001_task-rest_acq-itbs_nibs-intervention.tsv   
        sub-001_task-rest_acq-itbs_nibs-intervention.json
```

#### **Example** (`*_nibs-intervention.tsv` for iTBS)
```
tms_rmt     tms_intensity_mso   tms_intensity_didt      tms_coil_pos_centre     tms_coil_pos_ydir  
64          45                  20000000                C3                      CP5                         	
```

#### **Example** (`*_nibs-intervention.json` for iTBS)

```json
{  
  "InterventionName": "Intermittent theta burst stimulation",  
  "InterventionDescription": "Intermittent theta burst stimulation (iTBS) was applied to the left primary motor cortex. Stimulation included 600 pulses with 3 stimuli bursts at 50 Hz repeated at 5 Hz. Stimuli were applied for 2 s followed by an 8 s interval in a repeating pattern. Stimuli were applied at 70% or resting motor threshold.",  
   "tms_rmt": {  
      "LongName": "Resting motor threshold",  
      "Description": "Lowest stimulation intensity required to evoke at least 5 out of 10 MEPs with a peak-to-peak amplitude \> 0.05 mV, described as a percentage of maximum stimulator output (MSO).",  
      "Units": "percent",        
      }
   "tms_intensity_mso": {  
      "LongName": "Stimulation intensity",  
      "Description": "Stimulation intensity expressed relative to maximum stimulator output",  
      "Units": "percent",        
      }  
   "tms_intensity_didt": {  
      "LongName": "Stimulation intensity",  
      "Description": "Stimulation intensity expressed as rate of change of current in the coil",  
      "Units": "A/s",        
      }  
   "tms_coil_pos_centre": {  
      "LongName": "Centre of the TMS coil",  
      "Description": "Centre of the TMS coil based on 10-10 EEG electrode positions",  
      }  
   "tms_coil_pos_ydir": {  
      "LongName": "Position along the coil’s y-axis",  
     "Description": "Position along the coil’s y-axis (i.e., prolongation of the handle) based on 10-10 EEG electrode positions",  
      }  
    "NIBSDetails": {  
        "NIBSType": "TMS",  
        "NIBSDescription": "Intermittent theta burst stimulation to the left primary motor cortex",  
        "Manufacturer": "Magstim",  
        "ManufactureModelName": "Rapid^2",  
        "ManufacturerSerialNumber": "3004-00",  
        "CoilDetails": {  
            "Coil 1": {  
                "ModelName": "D70 AFC",  
                "SerialNumber": "3910-00"  
            }  
        }  
    }  
}
```

## 2.5. Neuronavigation

If a neuronavigation system is used to track NIBS coil/electrode/transducer position, it is RECOMMENDED to include the hardware details of the neuronavigation device used in the experiment in the corresponding `*_events.json` file of the neural recording accompanying stimulation (online NIBS) or the corresponding `*_intervention.json` file (offline NIBS). Furthermore, if position coordinates are provided in the corresponding `.tsv` file, it is REQUIRED to include details of the coordinate system used to describe the coil/electrode/transducer position. 

Note that no new neuronavigation-specific file is added in this BEP, but might be worth exploring this path in future extensions.

**Hardware information**

| Key name | Requirement Level | Data type | Description |
| :---- | :---- | :---- | :---- |
| NeuronavigationDetails | REQUIRED (if coil/electrode/transducer coordinates reported) | object | Object containing key-value pairs related to the neuronavigation device used to track coil/electrode/transducer during the experiment. |

The object supplied for NeuronavigationDetails SHOULD include the following key-value pairs.

| **Key name**                                  | **Requirement Level** | **Data type** | **Description** |
| :----                                         | :----                 | :----         | :---- |
| Manufacturer                                  | RECOMMENDED           | string | Manufacturer of the neuronavigation device used in the experiment. |
| ManufactureModelName                          | RECOMMENDED           | string | Manufacturers model name of the neuronavigation device used in the experiment. |
| SoftwareVersions                              | OPTIONAL              | string | Manufacturer's designation of software version of the neuronavigation system. |
| IntendedFor                                   | OPTIONAL              | string or array | The paths to files for which the associated file is intended to be used. This identifies the MRI or CT scan associated with neuronavigation. |
| NeuronavigationCoordinateSystem               | REQUIRED (if coil/electrode/transducer coordinates reported) | string | Defines the coordinate system for the xyz coordinate provided in the corresponding `.tsv` file. See the Coordinate Systems Appendix for a list of restricted keywords for coordinate systems. If "Other", provide definition of the coordinate system in NeuronavigationCoordinateSystemDescription. For a list of valid values for this field, see the associated glossary entry. |
| NeuronavigationCoordinateUnits                | REQUIRED (if coil/electrode/transducer coordinates reported) | string | Units of the coordinates of NeuronavigationCoordinateSystem. Must be one of: `"m"`, `"mm"`, `"cm"`, `"n/a"`. |
| NeuronavigationCooridinateSystemDescription   | RECOMMENDED           | string | Free-form text description of the coordinate system. May also include a link to a documentation page or paper describing the system in greater detail. |
| NeuronavigationCoilCoordiateSystemDescription | RECOMMENDED | string | Free-form text description of the coordinate system. May also include a link to a documentation page or paper describing the system in greater detail. |


#### **Example** (`*_events.tsv` for neuronavigation)

```
onset       duration    trial_type  tms_pos_centre_x    tms_pos_centre_y    tms_pos_centre_z
4.013       0           TMS         -1.2                -15.8               116.0  
9.154       0           TMS         -1.1                -15.7               116.1  
14.984      0           TMS         -1.3                -15.6               115.9
```

#### **Example** (`*_events.json` for neuronavigation)

```json
{  
    "NIBSDetails": {  
        "NIBSType": "TMS",  
        "NIBSDescription": "Single monophasic TMS pulses applied to a targeted brain region",  
        "Manufacturer": "Magstim",  
        "ManufactureModelName": "BiStim^2",  
        "ManufacturerSerialNumber": "3234-00",  
        "CoilDetails": {  
            "Coil 1": {  
                "ModelName": "D70",  
                "SerialNumber": "4150-00"  
            }  
        }  
    },  
    "NeuronavigationDetails": {  
        "Manufacturer": "Brainsight",  
        "ManufactureModelName": "Brainsight TMS",  
        "SoftwareVersions": "Brainsight 2.5.4",  
        "IntendedFor": "bids::sub-001/ses-01/anat/sub-001_T1w.nii",  
        "NeuronavigationCoordinateSystem": "Other",  
        "NeuronavigationCoordinateUnits": "mm",  
        "NeuronavigationCoordinateSystemDescription": "RAS orientation: Origin halfway between LPA and RPA, positive x-axis towards RPA, positive y-axis orthogonal to x-axis through Nasion, z-axis orthogonal to xy-plane, pointing in superior direction.",  
        "NeuronavigationCoilCoordinateSystemDescription": "Origin is centre of the coil, positive x-axis towards the right of the coil, positive y-axis orthogonal to x-axis through and away from the coil handle, z-axis orthogonal to xy-plane along the planar surface of the coil, positive pointing up (i.e., away from the participant’s head) of the active side of the coil."  
    },  
    "onset": {  
        "LongName": "Event Onset",  
        "Description": "Time from the start of the recording when the event occurred.",  
        "Units": "seconds"  
    },  
    "duration": {  
        "LongName": "Event Duration",  
        "Description": "Duration of the event.",  
        "Units": "seconds"  
    },  
    "trial_type": {  
        "LongName": "Stimulation type",  
        "Description": "Type of stimulation that is applied to the participant.",  
        "Levels": {  
            "TMS": "A single monophasic TMS pulse"  
        }  
    },  
    "tms_pos_centre_x": {  
        "LongName": "TMS Coil Position X Coordinate",  
        "Description": "The x-coordinate of the TMS coil center in 3D space, relative to the head.",  
        "Units": "millimeters"  
    },  
    "tms_pos_centre_y": {  
        "LongName": "TMS Coil Position Y Coordinate",  
        "Description": "The y-coordinate of the TMS coil center in 3D space, relative to the head.",  
        "Units": "millimeters"  
    },  
    "tms_pos_centre_z": {  
        "LongName": "TMS Coil Position Z Coordinate",  
        "Description": "The z-coordinate of the TMS coil center in 3D space, relative to the head.",  
        "Units": "millimeters"  
    }  
}
```

## NIBS-EMG

EMG data are not directly supported in the BIDS standard yet, although the 
[BEP042](https://docs.google.com/document/d/1G5_Eu2OemcZXS9xOGINPA6SUTaZOml7LBmZCMnUhTXA/edit) 
is currently working on an EMG-BIDS proposal. Since NIBS-EMG experiments 
are very common here we provide some guidance on how to deal with this type 
of data. Currently, the best solution is to describe EMG data within the 
[EEG-BIDS](https://bids-specification.readthedocs.io/en/stable/modality-specific-files/electroencephalography.html) 
extension. An example of how to achieve this is provided using the fieldtrip 
data2bids converter [here](https://www.fieldtriptoolbox.org/example/bids_emg/).

## Decision tree

![NIBS-BIDS decision tree][https://github.com/nigelrogasch/nibs-bids/blob/master/nibs-bids_decision_flow_chart.png]

`.json` \=\> hardware/software details *and/or* fixed methodological details that are **NOT** required as machine readable (e.g., used as a record of methods, like the description of offline rTMS protocol).

`.tsv` \=\> stimulation parameters that can change between trials/participants *and/or* are required as machine readable (e.g., for use in another software system, like stimulation intensity, coil position, or motor threshold).

