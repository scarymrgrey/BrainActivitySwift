#include "colibri_source.h"

ColibriReader::ColibriReader(SignalBuffer *signal_buffer, mutex* buffer_mutex):
        SignalReader(signal_buffer, buffer_mutex)
{
}

ColibriReader::~ColibriReader()
{

}

vector<SIGNAL_SAMPLE> ColibriReader::readDataForChannel(uint8_t channel_index, float time,
                                                        float duration)
{
    return std::vector<SIGNAL_SAMPLE>();
}

float ColibriReader::getBufferStartTime() const
{
    return 0;
}

uint32_t ColibriReader::getBufferDuration() const
{
    return 0;
}












