#include "data_source.h"

DataSource::DataSource(size_t samplMapSize):_sampleMapSize(samplMapSize)
{

}

uint16_t DataSource::getFSampling() const { return _signalReader->getFSampling(); }

uint16_t DataSource::getChCount() const { return (uint16_t)_channels.size(); }

uint32_t DataSource::getBufferDuration() const { return _signalReader->getBufferDuration(); }

size_t DataSource::getSampleMapSize() const { return _sampleMapSize; }

void DataSource::setSampleMapSize(size_t size) { _sampleMapSize = size; }

uint32_t DataSource::getFullDataLength() const  { return _signalReader->getOverallLength(); }

void DataSource::setInfo(DataSourceInfo info){ _info = info; }

vector<string> DataSource::getChannels() const
{
    std::vector<std::string> channels;
    for (auto it = _channels.begin(); it != _channels.end(); ++it)
    {
        channels.push_back(it->first);
    }
    return channels;
}

Channel *DataSource::getChannel(string channel)
{
    auto it = _channels.find(channel);
    if (it == _channels.end()) return nullptr;

    return it->second;
}

void DataSource::setAllScreenBuffersDuration(float duration)
{
    for (auto &channelPair: _channels)
    {
        auto screenBuffer = channelPair.second->getScreenBuffer();
        screenBuffer->setScreenDuration(duration);
    }
}

void DataSource::setAllScreenBuffersSamplesCount(uint32_t samples_count)
{
    for (auto &channelPair: _channels)
    {
        auto screenBuffer = channelPair.second->getScreenBuffer();
        screenBuffer->setSamplesCount(samples_count);
    }
}

float DataSource::getSurveyDuration() const
{
    return (float)_signalBuffer->getOverallLength() / getChCount() / getFSampling();
}



































