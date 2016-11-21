#ifndef BRAINBIT_SOURCE_H
#define BRAINBIT_SOURCE_H

#include <condition_variable>
#include <atomic>
#include "data_source.h"

using std::condition_variable;
using std::atomic;

/**
 * BrainBit configuration values and constants
 */
#define BRAINBIT_CMD_START_RECEIVE 0
#define BRAINBIT_CMD_STOP_RECEIVE 1
#define BRAINBIT_PACKET_SIZE 20
#define BRAINBIT_MAX_PACKET_NUMBER USHRT_MAX
#define BRAINBIT_MAX_PACKET_DELAY 60000
#define BRAINBIT_SORT_MAP_SIZE 50 //matches 200 ms delay in output buffers
#define BRAINBIT_T3_CHANNEL_INDEX 0
#define BRAINBIT_O1_CHANNEL_INDEX 1
#define BRAINBIT_T4_CHANNEL_INDEX 2
#define BRAINBIT_O2_CHANNEL_INDEX 3

//Eeg state determination constants
#define RHYTHM_CALC_WINDOW_DURATION 5.f //seconds
#define RHYTHM_BASE_NORMAL_COUNT 6u
#define ALPHA_START_FREQ 8.f //Hz
#define ALPHA_STOP_FREQ 14.f //HZ
#define ALPHA_BANDWIDTH (ALPHA_STOP_FREQ - ALPHA_START_FREQ)

#define BETA_START_FREQ 14.f //Hz
#define BETA_STOP_FREQ 34.f //Hz
#define BETA_BANDWIDTH (BETA_STOP_FREQ - BETA_START_FREQ)

#define THETA_START_FREQ 4.f //Hz
#define THETA_STOP_FREQ 8.f //Hz
#define THETA_BANDWIDTH (THETA_STOP_FREQ - THETA_START_FREQ)

#define RHYTHM_MINIMAL_BANDWIDTH THETA_BANDWIDTH

#define ALPHA_NORMAL_CFC (RHYTHM_MINIMAL_BANDWIDTH/ALPHA_BANDWIDTH)
#define BETA_NORMAL_CFC (RHYTHM_MINIMAL_BANDWIDTH/BETA_BANDWIDTH)
#define THETA_NORMAL_CFC (RHYTHM_MINIMAL_BANDWIDTH/THETA_BANDWIDTH)

//Relax and meditation conditional params
#define RELAX_INCLUDE_BETA_BOTTOM_THRESHOLD 20
#define RELAX_INCLUDE_BETA_TOP_THRESHOLD 100
#define RELAX_INCLUDE_BETA_HITS_COUNT 5

#define MEDIT_INCLUDE_BETA_BOTTOM_THRESHOLD 20
#define MEDIT_INCLUDE_BETA_TOP_THRESHOLD 100
#define MEDIT_INCLUDE_BETA_HITS_COUNT 5

//Eeg state limits
#define PX1 1.3f
#define PX2 1.45f
#define PX3 1.55f
#define PX4 1.7f
#define NX1 .65f
#define NX2 .45f
#define NX3 .2f
#define NX4 .0f
#define PY1 .9f
#define PY2 .85f
#define PY3 .8f
#define PY4 .7f
#define NY1 1.1f
#define NY2 1.15f
#define NY3 1.25f
#define NY4 1.3f

//Eeg state values
//intermediate state values does not have explicit names
//but could be used in different analysis
#define STATE_SLEEP 10
#define STATE_DEEP_RELAX 8
#define STATE_RELAX 4
#define STATE_NEUTRAL 0
#define STATE_NORMAL_ACTIVATION -4
#define STATE_EXCITEMENT -8
#define STATE_DEEP_EXCITEMENT -10

#define STATE_STRESS_HITS_COUNT 10
#define STATE_ATTENTION_HITS_COUNT 10

/**
 * Represents two-byte BrainBit data sample
 * as byte array and short value
 */
typedef union
{
    int16_t shortValue;
    char bytes[2];
} BrainBitData;


typedef struct rhythmValues
{
    double alpha;
    double beta;
    double theta;

    struct rhythmValues& operator+=(const rhythmValues& rhs)
    {
        alpha += rhs.alpha;
        beta += rhs.beta;
        theta += rhs.theta;
        return *this;
    }

    struct rhythmValues& operator+=(const double& k)
    {
        alpha += k;
        beta += k;
        theta += k;
        return *this;
    }

    struct rhythmValues operator/(const double& k)
    {
        return rhythmValues{alpha/k, beta/k, theta/k};
    }

    rhythmValues operator+(const rhythmValues& rhs)
    {
        return rhythmValues{rhs.alpha + alpha, rhs.beta + beta, rhs.theta + theta};
    }

    rhythmValues& operator=(const double& v)
    {
        alpha = v;
        beta = v;
        theta = v;
        return *this;
    }
} EegRhythmValues;

typedef struct
{
    void (*stateCallback)(int32_t state);
    void (*stressCallback)(int32_t stress_value);
    void (*attentionCallback)(int32_t attention_value);
    void (*prRelaxCallback)(int32_t relax_value);
    void (*meditationCallback)(int32_t meditation_value);
} EegStateCallback;

class EegStateCalculator
{
public:
    EegStateCalculator(map<string, Channel*>& channels);
    ~EegStateCalculator();

    /**
     * Starts EEG state calculation. Calculates several base average values
     * before starting calculate states. Every RHYTHM_CALC_WINDOW_DURATION seconds
     * states are ready and callback function will be called
     */
    void startCalculateEegState(EegStateCallback es_callback);

    /**
     * Stops EEG states calculation. Blocks until all module threads are stopped
     */
    void stopCalculateEegState();

    /**
     * Do not call this method. For internal usage.
     * Clocks state calculation module
     */
    void onSurveyDurationChanged(float new_duration);
private:
    map<string, Channel*>& _channels;
    float _currentSurveyDuration;

    //Calculation clock sync variables
    mutex _calculationClockMutex;
    condition_variable _calculationCondition;

    //Stop calculation sync variables
    atomic<bool> _eegStateCalcOn;
    condition_variable _stopCalcStateCondition;
    mutex _stopCalcStateMutex;


    void stateCalculationWorker(EegStateCallback es_callback);
    EegRhythmValues calculateRhythmAverageValues(float time, float duration);
    int32_t calculateStateIndex(double x, double y, double _x0, double _y0);
    int32_t calculateAttention(list<int32_t>& state_indexes);
    int32_t calculateStress(list<int32_t>& state_indexes);
    int32_t calculateProductiveRelax(EegRhythmValues& base, EegRhythmValues& current, bool use_beta);
    int32_t calculateMeditation(EegRhythmValues& base, EegRhythmValues& current, bool use_beta);
};

class BrainBitSource: public DataSource
{
public:
    BrainBitSource();

    ~BrainBitSource();

    void appendData(char *data, size_t length);

    void sendStartReceive();

    void sendStopReceive();

    EegStateCalculator* getStateCalculator() const;

private:
    static constexpr double _vRef = 2.4 / 6.0 / 32.0;
    static constexpr double k = 1000000000 * _vRef / 0x7FFF;

    EegStateCalculator* _stateCalculator;
};

#endif