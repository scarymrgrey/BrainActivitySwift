#include "colibri_source.h"
using std::pair;

ColibriSource::ColibriSource():DataSource(COLIBRI_SORT_MAP_SIZE)
{
    _signalBuffer = new SignalBuffer(COLIBRI_BUFFER_SIZE);
    _signalReader = new ColibriReader(_signalBuffer, &_bufferMutex);
    _channels.insert(pair<string, Channel *>("MIO", new Channel("MIO", 0, _signalReader)));
}

ColibriSource::~ColibriSource()
{
    for (auto &channel_pair: _channels)
    {
        delete channel_pair.second;
    }
    _channels.clear();
    delete _signalReader;
    delete _signalBuffer;
}

void ColibriSource::sendStopReceive()
{

}

void ColibriSource::sendStartReceive()
{

}

void ColibriSource::appendData(char *data, size_t length)
{
    //we should check if we received command or data.
    //here we parse packet to get base information from beacon
    
}

float ColibriSource::getBufferStartTime() const
{
    return 0;
}













