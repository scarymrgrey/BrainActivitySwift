#include "channel.h"
#include "algorithm.h"
#include <thread>


using std::thread;

Channel::Channel(string name, uint8_t index, SignalReader* signal_source):_name(name),
                                                                          _index(index),
                                                                          _signalSource(signal_source),
                                                                          _screenBuffer(new ScreenBuffer(index, signal_source))
{
    //Calculating optimal spectrum buffer size
    _spectrumSize = _signalSource->getFSampling()*SPECTRUM_SIZE_FREQUENCY_FACTOR;
    if (!checkPowerOfTwo(_spectrumSize))
        _spectrumSize = getNearestBiggerPowerOfTwo(_spectrumSize);
    
}

Channel::~Channel()
{
    delete _screenBuffer;
}

uint8_t Channel::getIndex() const
{
    return _index;
}

string Channel::getName() const
{
    return _name;
}

ScreenBuffer *Channel::getScreenBuffer()
{
    return _screenBuffer;
}

vector<SIGNAL_SAMPLE> Channel::readRawData(float time, float duration)
{
    return _signalSource->readDataForChannel(_index, time, duration);
}

vector<SIGNAL_SAMPLE> Channel::calculateChannelSpectrum(float time, float duration)
{
    auto data = readRawData(time, duration);

    auto dataLength = data.size();


    vector<SIGNAL_SAMPLE> spectrum(_spectrumSize, 0.0);

    //If count of data is less then spectrum calculation window
    //than just append zeros to the end of data vector to fit its size
    //to window size
    if (dataLength <= _spectrumSize)
    {
        data.insert(data.end(), _spectrumSize - dataLength, 0.0);
        CommonAlgorithms::FFTAnalysis(&data[0], &spectrum[0], _spectrumSize,
                         _spectrumSize);
    }
        //if
    else if (dataLength > _spectrumSize)
    {
        auto step_count = dataLength / _spectrumSize;
        if (dataLength % _spectrumSize != 0)
        {
            ++step_count;
            data.insert(data.end(), _spectrumSize * step_count - dataLength, 0.0);
        }
        uint32_t start_index = 0;
        for (auto step = 0; step < step_count; ++step)
        {
            vector<SIGNAL_SAMPLE> step_spectrum(_spectrumSize);
            CommonAlgorithms::FFTAnalysis(&data[start_index], &step_spectrum[0], _spectrumSize,
                             _spectrumSize);

            start_index+=_spectrumSize;

            for (auto i = 0; i < _spectrumSize; ++i)
            {
                spectrum[i] += step_spectrum[i]/step_count;
            }
        }
    }

    return spectrum;
}

void Channel::calculateChannelSpectrumAsync(float time, float duration,
                                                   void (*callbackFunc)(string, vector<SIGNAL_SAMPLE>))
{
    thread spectrumThread([=]
                          {
                              auto spectrum = calculateChannelSpectrum(time,
                                                                       duration);
                              callbackFunc(_name, spectrum);
                          });
    spectrumThread.detach();
}

float Channel::hzPerSample() const
{
    return (float)_signalSource->getFSampling()/_spectrumSize;
}

bool Channel::checkPowerOfTwo(uint32_t number)
{
    return number && !(number & (number - 1));
}

uint32_t Channel::getNearestBiggerPowerOfTwo(uint32_t number)
{
    // Divide by 2^k for consecutive doublings of k up to 32 and or the results
    number--;
    number |= number >> 1;
    number |= number >> 2;
    number |= number >> 4;
    number |= number >> 8;
    number |= number >> 16;
    number++;
    return number;
}

uint32_t Channel::setSpectrumSize(uint32_t spectrum_size)
{
    if (!checkPowerOfTwo(spectrum_size))
        _spectrumSize = getNearestBiggerPowerOfTwo(spectrum_size);
    else
        _spectrumSize = spectrum_size;
    return _spectrumSize;
}

uint32_t Channel::getSpectrumSize() const
{
    return _spectrumSize;
}

















