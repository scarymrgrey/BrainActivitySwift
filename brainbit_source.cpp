#include <cmath>
#include "brainbit_source.h"
using std::pair;

BrainBitSource::BrainBitSource(): DataSource(BRAINBIT_SORT_MAP_SIZE)
{
    _packetNumberPreValue = 0;

    _signalBuffer = new SignalBuffer(BRAINBIT_BUFFER_DURATION *
                                     BRAINBIT_CHANNELS_COUNT *
                                     BRAINBIT_SAMPLE_FREQ);

    _signalReader = new BrainBitReader(_signalBuffer, &_bufferMutex);

    //Creating BrainBit channels
    _channels.insert(pair<string, Channel *>("T3", new Channel("T3", BRAINBIT_T3_CHANNEL_INDEX,
                                                               _signalReader)));
    _channels.insert(pair<string, Channel *>("O1", new Channel("O1", BRAINBIT_O1_CHANNEL_INDEX,
                                                               _signalReader)));
    _channels.insert(pair<string, Channel *>("T4", new Channel("T4", BRAINBIT_T4_CHANNEL_INDEX,
                                                               _signalReader)));
    _channels.insert(pair<string, Channel *>("O2", new Channel("O2", BRAINBIT_O2_CHANNEL_INDEX,
                                                               _signalReader)));

    _stateCalculator = new EegStateCalculator(_channels);
}

BrainBitSource::~BrainBitSource()
{
    delete _stateCalculator;
    for (auto &channel_pair: _channels)
    {
        delete channel_pair.second;
    }
    _channels.clear();
    delete _signalReader;
    delete _signalBuffer;
}

void BrainBitSource::appendData(char* data, size_t length)
{
    if (length != BRAINBIT_PACKET_SIZE) throw "Wrong brainbit data packet size";

    uint32_t packetNumber = (uint32_t)(data[0]<<8) | data[1];

    _mapMutex.lock();
    auto smallestKey = _sampleMap.begin()->first;
    _mapMutex.unlock();

    //we don't add packets, which too late for our pre buffer, because we can't order them right
    //but we have maximum estimated delay of packet which tells us that this is most likely next round of packet
    //and not late packet. This is done because we can't relay on max uint16 value because of possible packet loss
    //so value of BRAINBIT_MAX_PACKET_DELAY says about our estimation of maximum packet loss
    // as closer to 65535-mapSize then as smaller packet loss rate we're estimating
    packetNumber += _packetNumberPreValue;
    if (packetNumber < smallestKey)
    {
        if (smallestKey - packetNumber > BRAINBIT_MAX_PACKET_DELAY)
        {
            //next cycle of packet numbers
            _packetNumberPreValue += BRAINBIT_MAX_PACKET_NUMBER - 1;
            packetNumber += BRAINBIT_MAX_PACKET_NUMBER - 1;
        }
        else return;
    }

    BrainBitData bbSample;
    auto firstSample = new SIGNAL_SAMPLE[BRAINBIT_CHANNELS_COUNT];
    auto secondSample = new SIGNAL_SAMPLE[BRAINBIT_CHANNELS_COUNT];

    for (auto i = 0; i < BRAINBIT_CHANNELS_COUNT; ++i)
    {
        bbSample.bytes[0] = data[i*2+4];
        bbSample.bytes[1] = data[i*2+3];
        firstSample[i] = ((SIGNAL_SAMPLE)bbSample.shortValue) * k;

        bbSample.bytes[0] = data[i*2+13];
        bbSample.bytes[1] = data[i*2+12];
        secondSample[i] = ((SIGNAL_SAMPLE)bbSample.shortValue) * k;
    }

    _mapMutex.lock();

    _sampleMap.insert(pair<uint32_t, SIGNAL_SAMPLE*>(packetNumber, firstSample));
    _sampleMap.insert(pair<uint32_t, SIGNAL_SAMPLE*>(packetNumber + 1, secondSample));


    while (_sampleMap.size() > _sampleMapSize)
    {
        auto it = _sampleMap.begin();

        //Here we could optimize append process
        //We can accumulate all samples on map output and push them to buffer once
        //But we will have +1 allocation here
        _bufferMutex.lock();
        _signalBuffer->append(it->second, BRAINBIT_CHANNELS_COUNT);
        _bufferMutex.unlock();

        delete[] it->second;
        _sampleMap.erase(it);
    }

    _mapMutex.unlock();

    //State calculator module must be clocked someway, so we tell it
    //that new data arrived and calculate survey duration for it
    _stateCalculator->onSurveyDurationChanged(getSurveyDuration());
}

void BrainBitSource::sendStartReceive()
{
    char startCommand[1] = {BRAINBIT_CMD_START_RECEIVE};
    _info.sendCommand(_info.internal_type_id, startCommand, 1);
}

void BrainBitSource::sendStopReceive()
{
    char stopCommand[1] = { BRAINBIT_CMD_STOP_RECEIVE };
    _info.sendCommand(_info.internal_type_id, stopCommand, 1);
}

EegStateCalculator *BrainBitSource::getStateCalculator() const
{
    return _stateCalculator;
}
