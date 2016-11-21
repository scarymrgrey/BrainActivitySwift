#include "signal_reader.h"

SignalReader::SignalReader(SignalBuffer *signal_buffer, mutex* buffer_mutex):
        _signalBuffer(signal_buffer),
        _bufferMutex(buffer_mutex)
{
}

uint16_t SignalReader::getFSampling() const
{
    return _fSampling;
}

uint32_t SignalReader::getOverallLength() const
{
    return _signalBuffer->getOverallLength();
}




