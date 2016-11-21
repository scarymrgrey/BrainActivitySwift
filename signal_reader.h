#include "signal_buffer.h"
#include <vector>
#include <mutex>

using std::mutex;

using std::vector;

#define BRAINBIT_CHANNELS_COUNT 4
#define BRAINBIT_BUFFER_DURATION 60 //in seconds
#define BRAINBIT_SAMPLE_FREQ 250

class SignalReader
{
public:
    SignalReader(SignalBuffer* signal_buffer, mutex* buffer_mutex);
    virtual ~SignalReader(){};
    virtual vector<SIGNAL_SAMPLE> readDataForChannel(uint8_t channel_index, float time, float duration) = 0;
    virtual float getBufferStartTime() const = 0;
    virtual uint32_t getBufferDuration() const = 0;

    uint16_t getFSampling() const;
    uint32_t getOverallLength() const;
protected:
    uint16_t _fSampling;
    SignalBuffer *_signalBuffer;
    mutex *_bufferMutex;
};

class BrainBitReader: public SignalReader
{
public:
    BrainBitReader(SignalBuffer* signal_buffer, mutex* buffer_mutex);
    ~BrainBitReader();
    vector<SIGNAL_SAMPLE> readDataForChannel(uint8_t channel_index, float time, float duration);
    float getBufferStartTime() const;
    uint32_t getBufferDuration() const;
private:
    int32_t requestBufferLength;
    float lastTime;
    float lastDuration;
    mutex _cacheMutex;
    SIGNAL_SAMPLE *requestBuffer = nullptr;
};

class ColibriReader: public SignalReader
{
public:
    ColibriReader(SignalBuffer* signal_buffer, mutex* buffer_mutex);
    ~ColibriReader();
    vector<SIGNAL_SAMPLE> readDataForChannel(uint8_t channel_index, float time, float duration);
    float getBufferStartTime() const;
    uint32_t getBufferDuration() const;
};
