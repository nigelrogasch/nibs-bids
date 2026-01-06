# Framework for describing rTMS timing parameters - v2

The current methods for describing the timing of TMS interventions are often imprecise and ambiguous, meaning there are often multiple different interpretations of how the timing could be implemented.

Below I describe a method for accurately describing the timing of common rTMS paradigms. The structure is based on the ITRUSST recommendations for TUS which can also be applied to TMS and likely tES protocols. In this approach, a table is constructed which can describe simple and nested rTMS protocols.

The term 'burst' is deliberately avoided as this can be ambiguous. Frequency is also avoided as this can suffer from rounding errors and is therefore imprecise. Also, the number of pulses is avoided to avoid the potential for further ambiguity when describing protocols. This can instead be calculated form the interval and duration.

## **rTMS protocols with no nesting (e.g., 1 Hz)**

`pulse_duration` = time during which current is passed through the TMS coil (also called `pulse width`).

`pulse_reptition_interval` = time from the onset of the first pulse to the onset of the subsequent pulse.

`pulse_train_duration` = time to complete all pulses in train (including all intervals).


## **rTMS protocols with one level of nesting (e.g., 10 Hz, cTBS, QPS, iTMS)**

`pulse_train_repeat_interval` = time from the onset of the first train to the onset of the subsequent train.

`pulse_train_repeat_duration` = time to complete all trains in repeat 1 (including all intervals).

## **rTMS protocols with multiple levels of nesting (e.g., iTBS)**

`repeat2_interval` = time from the onset of repeat 1 to the onset of the subsequent repeat.

`repeat2_duration` = time to complete all repeats in repeat 2 (including all intervals).

## **Additional levels of nesting (if required)**

`repeat<n>_interval` = time from the onset of repeat `<n>` to the onset of the subsequent repeat.

`repeat<n>_duration` = time to complete all repeats in repeat <n> (including all intervals).

## **Derived measurements**

The following are additional parameters that can be derived from the above parameters that may be of interest to report:

`pulse_repetition_frequency` = 1/`pulse_reptition_interval`.

`pulse_train_repetition_frequency` = 1/`pulse_train_repeat_interval`.

`repeat1_frequency` = 1/`repeat2_interval`.

`total_pulses` = (`pulse_train_duration` / `pulse_reptition_interval`) * (`pulse_train_repeat_duration` * `pulse_train_repetition_interval`) *  ( `repeat2_duration` * `pulse_train_repeat_repetition_interval) etc.

## **Examples**

Here are the settings for some common protocols.

**Protocol:** 1 Hz rTMS

|             | **_duration**  | **_repetition_interval** |
|-------------|----------------|--------------------------|
| pulse       | 200 µs         | 1 s                      |
| pulse_train | 600 s          |                          |

**Protocol:** 10 Hz rTMS

|             | **_duration**  | **_repetition_interval** |
|-------------|----------------|--------------------------|
| pulse       | 200 µs         | 0.1 s                      |
| pulse_train | 4 s          |   30 s                       |
| pulse_train_repeat | 2,250 s        |                          |

**Protocol:** cTBS

|             | **_duration**  | **_repetition_interval** |
|-------------|----------------|--------------------------|
| pulse       | 200 µs         | 0.02 s                      |
| pulse_train | 0.06 s          |   0.2 s                       |
| pulse_train_repeat | 40 s        |                          |

**Protocol:** QPS (5 ms ISI)

|             | **_duration**  | **_repetition_interval** |
|-------------|----------------|--------------------------|
| pulse       | 200 µs         | 0.005 s                      |
| pulse_train | 0.02 s          |   5 s                       |
| pulse_train_repeat | 1800 s        |                          |


**Protocol:** iTBS 

|             | **_duration**  | **_repetition_interval** |
|-------------|----------------|--------------------------|
| pulse       | 200 µs         | 0.2 s                      |
| pulse_train | 0.06 s          |   0.2 s                       |
| pulse_train_repeat | 2 s        |  10 s                        |
| repeat_2 | 200 s        |                         |

## Additional ramping variables

Although not common in rTMS, ramping (i.e., a gradual increase and decreases in stimulation intensity) can also be described.

