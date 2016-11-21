#include "screen_buffer.h"

ScreenBuffer::ScreenBuffer(uint8_t channel_index, SignalReader* signal_reader ):
                                                                _dataReader(signal_reader),
                                                                _index(channel_index)
{
}

ScreenBuffer::~ScreenBuffer()
{
    _screenBuffer.clear();
}

void ScreenBuffer::setScreenDuration(float duration)
{
    _duration = duration;
    _screenBuffer.clear();
}

void ScreenBuffer::setSamplesCount(uint32_t samples_count)
{
    _samplesCount = samples_count;
    _screenBuffer.clear();
}

void ScreenBuffer::getScreenData(vector<SIGNAL_SAMPLE> &outBuffer, float time)
{
    outBuffer.clear();

    if (_screenBuffer.size() > 0)
    {
        if (time>_currentStartTime)
        {
            auto rawData = _dataReader->readDataForChannel(_index, _currentStartTime + _duration,
                                             time - _currentStartTime);
            for (auto i = 0; i < rawData.size()/_step; ++i)
            {
                _screenBuffer.pop_front();
                _screenBuffer.push_back(rawData[i*_step]);
            }
        }
        else if (time < _currentStartTime)
        {
            //if we scroll screen backward
        }
        _currentStartTime = time;
    }
    else
    {
        //Screen buffer is empty, need to read data for full duration
        auto rawData = _dataReader->readDataForChannel(_index, time, _duration);
        _step = (uint32_t)rawData.size()/_samplesCount;
        if (_step == 0)
        {
            _step = 1;
            for (auto i = 0; i < rawData.size(); ++i)
            {
                _screenBuffer.push_back(rawData[i]);
            }
        }
        else
        {
            for (auto i = 0; i < _samplesCount; ++i)
            {
                _screenBuffer.push_back(rawData[i * _step]);
            }
        }
        _currentStartTime = time;
    }
    copy(_screenBuffer.begin(), _screenBuffer.end(), back_inserter(outBuffer));
}









