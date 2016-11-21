#include "signal_reader.h"
#include <cmath>

using std::fill_n;

BrainBitReader::BrainBitReader(SignalBuffer *signal_buffer, mutex* buffer_mutex):
        SignalReader(signal_buffer, buffer_mutex)
{
    _fSampling = BRAINBIT_SAMPLE_FREQ;
}

BrainBitReader::~BrainBitReader()
{
    delete[] requestBuffer;
}


vector<SIGNAL_SAMPLE> BrainBitReader::readDataForChannel(uint8_t channel_index, float time, float duration)
{
    int32_t outSamplesCount = (int32_t)(duration*_fSampling);
    int32_t rawSamplesCount = outSamplesCount * BRAINBIT_CHANNELS_COUNT;
    //Prevents cache from overwriting during reading from another thread
    //to exclude situations were we entered here with one time/duration
    //and got information for another time/duration from cache because of
    //another thread re-requested cache from ring buffer
    _cacheMutex.lock();
    //if we already read data for that timings, we can read channel data from cached buffer
    if (fabs(time - lastTime) > 0.00001 || fabs(duration - lastDuration) > 0.00001
        || requestBuffer == nullptr || requestBufferLength < rawSamplesCount)
    {
        //there is no cached data for given time/duration
        //so we read them from ring buffer

        //Clear if needed old request buffer
        //And create new
        if (requestBuffer != nullptr)
        {
            delete[] requestBuffer;
        }
        requestBuffer = new SIGNAL_SAMPLE[rawSamplesCount];

        //saving new request buffer length
        requestBufferLength = rawSamplesCount;

        //Reading data from ring buffer
        _bufferMutex->lock();
        auto bufferStartTime = getBufferStartTime();

        //Here we must load data from external storage, but now we just fill out buffer with zeros
        // because we have no external storage yet. It could be internet service or hard drive
        if (time + duration > bufferStartTime && time < bufferStartTime + BRAINBIT_BUFFER_DURATION)
        {
            auto offset = (int32_t)((time - bufferStartTime)*_fSampling)*BRAINBIT_CHANNELS_COUNT;
            SIGNAL_SAMPLE *start = requestBuffer;
            size_t count = (size_t)rawSamplesCount;
            if (offset < 0)
            {
                fill_n(requestBuffer, -offset, 0.0);
                start += -offset;
                count -= -offset;
                offset = 0;
            }
            if (time + duration > bufferStartTime + BRAINBIT_BUFFER_DURATION)
            {
                auto overflow = (int32_t)((time + duration - bufferStartTime - BRAINBIT_BUFFER_DURATION)*_fSampling)*BRAINBIT_CHANNELS_COUNT;
                count -= overflow;
                fill_n(requestBuffer + rawSamplesCount - overflow, overflow, 0.0);
            }

            _signalBuffer->getData(start, (uint32_t)offset, count);
        }
        else
        {
            fill_n(requestBuffer, rawSamplesCount, 0.0);
        }
        _bufferMutex->unlock();

        lastTime = time;
        lastDuration = duration;

    }

    vector<SIGNAL_SAMPLE> outBuffer;
    //Parsing data from cached buffer to output
    for (auto i = 0; i < outSamplesCount; ++i)
    {
        outBuffer.push_back(requestBuffer[i * BRAINBIT_CHANNELS_COUNT + channel_index]);
    }

    _cacheMutex.unlock();

    return outBuffer;
}

float BrainBitReader::getBufferStartTime() const
{
    auto startTime = ((float)_signalBuffer->getOverallLength()/BRAINBIT_CHANNELS_COUNT)
                     /_fSampling-BRAINBIT_BUFFER_DURATION;

    return startTime < 0 ? 0 : startTime;
}

uint32_t BrainBitReader::getBufferDuration() const
{
    return BRAINBIT_BUFFER_DURATION;
}








