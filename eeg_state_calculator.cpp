#include <cmath>
#include <thread>
#include "brainbit_source.h"
#include "algorithm.h"

using std::thread;
using std::unique_lock;
using std::abs;

EegStateCalculator::EegStateCalculator(map<string, Channel *>& channels):_channels(channels)
{
    _currentSurveyDuration = .0f;
    _eegStateCalcOn.store(false);
}

EegStateCalculator::~EegStateCalculator()
{

}

void EegStateCalculator::onSurveyDurationChanged(float new_duration)
{
    unique_lock<mutex> lck(_calculationClockMutex);
    _currentSurveyDuration = new_duration;
    _calculationCondition.notify_all();
}


void EegStateCalculator::stateCalculationWorker(EegStateCallback es_callback)
{
    unique_lock<mutex> start_lck(_calculationClockMutex);
    auto lastCalcTime = _currentSurveyDuration;
    auto baseCount = 0;
    start_lck.unlock();

    //first of all calculate base values
    EegRhythmValues baseValues = {.0f, .0f, .0f};
    while (baseCount < RHYTHM_BASE_NORMAL_COUNT && _eegStateCalcOn.load())
    {
        //lock until we have 5 seconds signal duration since
        //last calculation or calculation start
        unique_lock<mutex> loop_lck(_calculationClockMutex);
        while (_currentSurveyDuration < lastCalcTime + RHYTHM_CALC_WINDOW_DURATION)
        {
            _calculationCondition.wait(loop_lck);
            if (!_eegStateCalcOn.load()) break;
        }
        auto savedSurveyDuration = _currentSurveyDuration;
        loop_lck.unlock();

        baseValues += calculateRhythmAverageValues(
                savedSurveyDuration - RHYTHM_CALC_WINDOW_DURATION, RHYTHM_CALC_WINDOW_DURATION) /
                      RHYTHM_BASE_NORMAL_COUNT;
        lastCalcTime = savedSurveyDuration;
        ++baseCount;
    }


    list<int32_t> stressHits, attentionHits;

    //Relax and meditation will include Beta rhythm only if alpha analysis
    //will give 20-100 percents several times
    bool useBetaForMeditation = false;
    bool useBetaForRelax = false;
    uint32_t meditationAlphaInRangeTimes = 0;
    uint32_t relaxAlphaInRangeTimes = 0;

    int32_t last_state = 0;
    //calculating state and other eeg params
    while (_eegStateCalcOn.load())
    {
        unique_lock<mutex> loop_lck(_calculationClockMutex);
        while (_currentSurveyDuration < lastCalcTime + RHYTHM_CALC_WINDOW_DURATION)
        {
            _calculationCondition.wait(loop_lck);
            if (!_eegStateCalcOn.load()) break;
        }

        auto savedSurveyDuration = _currentSurveyDuration;
        loop_lck.unlock();

        lastCalcTime = savedSurveyDuration;

        auto stateRhythmValues = calculateRhythmAverageValues(
                savedSurveyDuration - RHYTHM_CALC_WINDOW_DURATION,
                RHYTHM_CALC_WINDOW_DURATION);


        //getting eeg state index (-5.0, 5.0) with step (0.5)
        //to get values definitions see brainbit_source.h
        auto state = calculateStateIndex(stateRhythmValues.alpha,
                                         stateRhythmValues.beta,
                                         baseValues.alpha,
                                         baseValues.beta);


        //Notifying user code about new EEG state even it looks like artifact
        if (es_callback.stateCallback != nullptr)
        {
            //call callback function in different thread
            //because some blocking or long executing code could be
            //in user implementation
            thread callbackThread([=]
                                  {
                                      es_callback.stateCallback(state);
                                  });
            callbackThread.detach();
        }

        //sharp change in the state is probably a noise
        //Decreasing last_state value so if new state is stable, it could be used in calculations
        //after four steps. Artifacts won't be stable.
        if (last_state - state > 4)
        {
            --last_state;
            continue;
        }
        else if (state - last_state > 4)
        {
            ++last_state;
            continue;
        }
        last_state = state;

        //if stress callback is not passed than we shouldn't run stress algorithm
        if (es_callback.stressCallback != nullptr)
        {
            //calc stress
            stressHits.insert(stressHits.begin(), state);
            while (stressHits.size() > STATE_STRESS_HITS_COUNT)
                stressHits.pop_back();

            if (stressHits.size() == STATE_STRESS_HITS_COUNT)
            {
                auto stressIndex = calculateStress(stressHits);

                //call callback
                thread callbackThread([=]
                                      {
                                          es_callback.stressCallback(stressIndex);
                                      });
                callbackThread.detach();
            }
        }

        //if attention callback is not passed than we shouldn't run attention algorithm
        if (es_callback.attentionCallback != nullptr)
        {
            //calc attention
            if (state != 5 && state != 6)
            {
                attentionHits.insert(attentionHits.begin(), state);
                while (attentionHits.size() > STATE_ATTENTION_HITS_COUNT)
                    attentionHits.pop_back();

                if (attentionHits.size() == STATE_ATTENTION_HITS_COUNT)
                {
                    auto attentionIndex = calculateAttention(attentionHits);
                    //call callback
                    thread callbackThread([=]
                                          {
                                              es_callback.attentionCallback(attentionIndex);
                                          });
                    callbackThread.detach();
                }
            }
        }

        //if relax callback is not passed than we shouldn't run relax algorithm
        if (es_callback.prRelaxCallback != nullptr)
        {
            //calc productive relax
            auto relax = calculateProductiveRelax(baseValues, stateRhythmValues, useBetaForRelax);

            //Check condition for beta rhythm usage in relax calculations
            if (relax >= RELAX_INCLUDE_BETA_BOTTOM_THRESHOLD &&
                relax <= RELAX_INCLUDE_BETA_TOP_THRESHOLD)
                ++relaxAlphaInRangeTimes;
            else
                relaxAlphaInRangeTimes = 0;
            useBetaForRelax = relaxAlphaInRangeTimes >= RELAX_INCLUDE_BETA_HITS_COUNT;

            //call callback
            thread callbackThread([=]
                                  {
                                      es_callback.prRelaxCallback(relax);
                                  });
            callbackThread.detach();
        }

        //if meditation callback is not passed than we shouldn't run meditation algorithm
        if (es_callback.meditationCallback != nullptr)
        {
            //calc meditation
            auto meditation = calculateMeditation(baseValues, stateRhythmValues,
                                                  useBetaForMeditation);

            //Check condition for beta rhythm usage in meditation calculations
            if (meditation >= MEDIT_INCLUDE_BETA_BOTTOM_THRESHOLD &&
                meditation <= MEDIT_INCLUDE_BETA_TOP_THRESHOLD)
                ++meditationAlphaInRangeTimes;
            else
                meditationAlphaInRangeTimes = 0;
            useBetaForMeditation = meditationAlphaInRangeTimes >= MEDIT_INCLUDE_BETA_HITS_COUNT;

            //call callback
            thread callbackThread([=]
                                  {
                                      es_callback.meditationCallback(meditation);
                                  });
            callbackThread.detach();
        }
    }

    unique_lock<mutex> stopLock(_stopCalcStateMutex);
    _stopCalcStateCondition.notify_all();
}


int32_t EegStateCalculator::calculateStress(list<int32_t> &state_indexes)
{
    uint32_t de = 0, e = 0, na = 0, r = 0, dr = 0, s = 0;
    for (auto state: state_indexes)
    {
        switch (state)
        {
            case STATE_DEEP_EXCITEMENT:
                ++de;
                break;
            case STATE_EXCITEMENT:
            case -7:
            case -6:
            case -5:
                ++e;
                break;
            case STATE_NORMAL_ACTIVATION:
            case -3:
            case -2:
            case -1:
                ++na;
                break;
            case STATE_RELAX:
            case 3:
            case 2:
            case 1:
                ++r;
                break;
            case STATE_DEEP_RELAX:
            case 7:
            case 6:
            case 5:
                ++dr;
                break;
            case STATE_SLEEP:
                ++s;
                break;
        }
    }

    auto st = (int32_t) ((e + de - 0.33 * na - 0.5 * (r + dr) - s) / STATE_STRESS_HITS_COUNT *
                         100.0);
    if (st < 0) st = 0;
    else if (st > 100) st = 100;
    return st;
}

int32_t EegStateCalculator::calculateAttention(list<int32_t> &state_indexes)
{
    uint32_t na = 0, dr = 0, s = 0, n7 = 0, n8 = 0, n9 = 0;

    for (auto state: state_indexes)
    {
        switch (state)
        {
            case -6:
            case -5:
                ++n8;
                break;
            case STATE_NORMAL_ACTIVATION:
            case -3:
            case -2:
            case -1:
                ++na;
                break;
            case STATE_RELAX:
            case 3:
                ++n9;
                break;
            case 2:
            case 1:
                ++n7;
                break;
            case STATE_DEEP_RELAX:
            case 7:
            case 6:
            case 5:
                ++dr;
                break;
            case STATE_SLEEP:
                ++s;
                break;
        }
    }
    auto att = (int32_t) ((0.25 * n7 + 0.75 * na + n8 - dr - 0.5 * n9 - 2 * s) /
                          STATE_ATTENTION_HITS_COUNT * 100.0);
    if (att < 0) att = 0;
    else if (att > 100) att = 100;
    return att;
}

int32_t EegStateCalculator::calculateProductiveRelax(EegRhythmValues& base, EegRhythmValues& current, bool use_beta)
{
    auto X_0 = 1.3 * base.alpha;
    auto X_100 = 1.55 * base.alpha;
    auto Y_0 = 0.8 * base.beta;
    auto Y_100 = 0.65 * base.beta;

    int32_t n = 0;

    if (current.alpha >= X_0 && current.alpha <= X_100)
    {
        if (current.beta <= Y_0 && current.beta >= Y_100 && use_beta)
            n = (int32_t) ((current.alpha - X_0) / (X_100 - X_0) * 100 +
                           (current.beta - Y_0) / (Y_100 - Y_0) * 0.5 * 100);
        else
            n = (int32_t) ((current.alpha - X_0) / (X_100 - X_0) * 100);
    }
    else
    {
        n = 0;
    }

    if (n > 100)
        n = 100;
    else if (n < 0)
        n = 0;

    return n;
}

int32_t EegStateCalculator::calculateMeditation(EegRhythmValues& base, EegRhythmValues& current, bool use_beta)
{
    auto X_0 = 1.55 * base.alpha;
    auto X_100 = 1.9 * base.alpha;
    auto Y_0 = 0.65 * base.beta;
    auto Y_100 = 0.3 * base.beta;
    auto Z_0 = 1.25 * base.theta;
    auto Z_100 = 1.65 * base.theta;

    int32_t n = 0;
    if (current.alpha >= X_0 && current.alpha <= 140)
    {
        if (current.beta <= Y_0 && current.beta >= Y_100 && use_beta)
        {
            if (current.theta < Z_0)
            {
                n = (int32_t)((current.alpha - X_0) / (X_100 - X_0) * 100 +
                    (current.beta - Y_0) / (Y_100 - Y_0) * 0.5 * 100);
            }
            else
            {
                n = (int32_t)((current.alpha - X_0) / (X_100 - X_0) * 100 + (current.beta - Y_0) / (Y_100 - Y_0) * 0.5 * 100 +
                    ((current.theta - Z_0) / (
                            Z_100 - Z_0)) * 100);
            }
        }
        else
        {
            n = (int32_t)((current.alpha - X_0) / (X_100 - X_0) * 100);
        }
    }
    else
    {
        n = 0;
    }

    if (n > 100)
    n = 100;
    else if (n < 0)
    n = 0;
    return n;
}

void EegStateCalculator::startCalculateEegState(EegStateCallback es_callback)
{
    _eegStateCalcOn.store(true);
    thread eegStateCalcThread([=]
                              {
                                  stateCalculationWorker(es_callback);
                              });
    eegStateCalcThread.detach();
}

void EegStateCalculator::stopCalculateEegState()
{
    if (!_eegStateCalcOn.load()) return;
    unique_lock<mutex> stopLock(_stopCalcStateMutex);
    _eegStateCalcOn.store(false);
    _calculationCondition.notify_all();
    _stopCalcStateCondition.wait(stopLock);
}

EegRhythmValues EegStateCalculator::calculateRhythmAverageValues(float time, float duration)
{
    auto steps = trunc(duration / RHYTHM_CALC_WINDOW_DURATION);

    auto t3 = _channels.find("T3")->second;
    auto t4 = _channels.find("T4")->second;
    auto o1 = _channels.find("O1")->second;
    auto o2 = _channels.find("O2")->second;

    EegRhythmValues rtmValues = {.0f, .0f, .0f};

    while (duration >= RHYTHM_CALC_WINDOW_DURATION)
    {
        auto t3Spectrum = t3->calculateChannelSpectrum(time, RHYTHM_CALC_WINDOW_DURATION);
        auto t4Spectrum = t4->calculateChannelSpectrum(time, RHYTHM_CALC_WINDOW_DURATION);
        auto o1Spectrum = o1->calculateChannelSpectrum(time, RHYTHM_CALC_WINDOW_DURATION);
        auto o2Spectrum = o2->calculateChannelSpectrum(time, RHYTHM_CALC_WINDOW_DURATION);

        rtmValues.alpha += CommonAlgorithms::RhythmSpectrumPower(&o1Spectrum[0],
                                                         o1->hzPerSample(),
                                                         ALPHA_START_FREQ,
                                                         ALPHA_STOP_FREQ,
                                                         ALPHA_NORMAL_CFC) / steps / 2.f;
        rtmValues.alpha += CommonAlgorithms::RhythmSpectrumPower(&o2Spectrum[0],
                                                         o2->hzPerSample(),
                                                         ALPHA_START_FREQ,
                                                         ALPHA_STOP_FREQ,
                                                         ALPHA_NORMAL_CFC) / steps / 2.f;

        rtmValues.beta += CommonAlgorithms::RhythmSpectrumPower(&t3Spectrum[0],
                                                        t3->hzPerSample(),
                                                        BETA_START_FREQ,
                                                        BETA_STOP_FREQ,
                                                        BETA_NORMAL_CFC) / steps / 2.f;
        rtmValues.beta += CommonAlgorithms::RhythmSpectrumPower(&t4Spectrum[0],
                                                        t4->hzPerSample(),
                                                        BETA_START_FREQ,
                                                        BETA_STOP_FREQ,
                                                        BETA_NORMAL_CFC) / steps / 2.f;

        rtmValues.theta += CommonAlgorithms::RhythmSpectrumPower(&t3Spectrum[0],
                                                         t3->hzPerSample(),
                                                         THETA_START_FREQ,
                                                         THETA_STOP_FREQ,
                                                         THETA_NORMAL_CFC) / steps / 4.f;
        rtmValues.theta += CommonAlgorithms::RhythmSpectrumPower(&t4Spectrum[0],
                                                         t4->hzPerSample(),
                                                         THETA_START_FREQ,
                                                         THETA_STOP_FREQ,
                                                         THETA_NORMAL_CFC) / steps / 4.f;
        rtmValues.theta += CommonAlgorithms::RhythmSpectrumPower(&o1Spectrum[0],
                                                         o1->hzPerSample(),
                                                         THETA_START_FREQ,
                                                         THETA_STOP_FREQ,
                                                         THETA_NORMAL_CFC) / steps / 4.f;
        rtmValues.theta += CommonAlgorithms::RhythmSpectrumPower(&o2Spectrum[0],
                                                         o2->hzPerSample(),
                                                         THETA_START_FREQ,
                                                         THETA_STOP_FREQ,
                                                         THETA_NORMAL_CFC) / steps / 4.f;


        duration -= RHYTHM_CALC_WINDOW_DURATION;
        time += RHYTHM_CALC_WINDOW_DURATION;
    }

    return rtmValues;
}

int32_t EegStateCalculator::calculateStateIndex(double x, double y, double _x0, double _y0)
{
    auto xMin = _x0 * 0.1;

    if (x -_x0 > 0.05)
    {
        if (x <= PX1 * _x0)
        {
            if (y <= _y0 && y >= _y0 * PY1)
            {
                return 2;
            }
            else if (y > _y0)
            {
                return 1;
            }
            else
            {
                return 3;
            }
        }
        else if (x > PX1 * _x0 && x <= PX2 * _x0)
        {
            if (y <= _y0 && y >= _y0 * PY2)
            {
                return 4;
            }
            else if (y > _y0)
            {
                return 3;
            }
            else
            {
                return 5;
            }
        }
        else if (x > PX2 * _x0 && x <= PX3 * _x0)
        {
            if (y <= _y0 && y >= _y0 * PY3)
            {
                return 6;
            }
            else if (y > _y0)
            {
                return 5;
            }
            else
            {
                return 7;
            }
        }
        else if (x > PX3 * _x0 && x <= PX4 * _x0)
        {
            if (y <= _y0 && y >= _y0 * PY4)
            {
                return 8;
            }
            else if (y > _y0)
            {
                return 7;
            }
            else
            {
                return 9;
            }
        }
        else
        {
            return 10;
        }
    }
    else if (fabs(x - _x0) < 0.05)
    {
        return 0;
    }
    else
    {
        if (x > NX1 * (_x0 - xMin))
        {
            if (y <= NY1 * _y0 && y > _y0)
            {
                return -2;
            }
            else if (y > NY1 * _y0)
            {
                return -3;
            }
            else
            {
                return -1;
            }
        }
        else if (x <= NX1 * (_x0 - xMin) && x > NX2 * (_x0 - xMin))
        {
            if (y <= NY2 * _y0 && y > _y0)
            {
                return -4;
            }
            else if (y > NY2 * _y0)
            {
                return -5;
            }
            else
            {
                return -3;
            }
        }
        else if (x <= NX2 * (_x0 - xMin) && x > NX3 * (_x0 - xMin))
        {
            if (y <= NY3 * _y0 && y > _y0)
            {
                return -6;
            }
            else if (y > NY3 * _y0)
            {
                return -7;
            }
            else
            {
                return -5;
            }
        }
        else if (x <= NX3 * (_x0 - xMin) && x > NX4 * (_x0 - xMin))
        {
            if (y <= NY4 * _y0 && y > _y0)
            {
                return -8;
            }
            else if (y > NY4 * _y0)
            {
                return -9;
            }
            else
            {
                return -7;
            }
        }
        else
        {
            return -10;
        }
    }
}































