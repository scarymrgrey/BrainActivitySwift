#include "signal_reader.h"
#include <string>
#include <list>

using std::string;
using std::list;

/**
 * Screen buffer constants
 */
#define SB_DEFAULT_SAMPLES_COUNT 300
#define SB_DEFAULT_DURATION 5.0f


class ScreenBuffer
{
public:
    ScreenBuffer(uint8_t channel_index, SignalReader* reader);
    ~ScreenBuffer();

    void setScreenDuration(float duration);
    void setSamplesCount(uint32_t samples_count);
    void getScreenData(vector<SIGNAL_SAMPLE> &outBuffer, float time);
private:
    uint8_t _index;
    SignalReader *_dataReader;
    list<SIGNAL_SAMPLE> _screenBuffer;
    uint32_t _samplesCount = SB_DEFAULT_SAMPLES_COUNT;
    uint32_t _step;
    float _duration = SB_DEFAULT_DURATION;
    float _currentStartTime = 0.0f;
};
