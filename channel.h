#include "screen_buffer.h"

#define SPECTRUM_SIZE_FREQUENCY_FACTOR 8u //Spectrum resolution won't be less than 8 samples per Hz

class Channel
{
public:
    Channel(string name, uint8_t index, SignalReader* signal_source);
    ~Channel();

    ScreenBuffer* getScreenBuffer();
    vector<SIGNAL_SAMPLE> readRawData(float time, float duration);

    /**
     * Synchronous call of spectrum calculation
     */
    vector<SIGNAL_SAMPLE> calculateChannelSpectrum(float time, float duration);

    /**
     * Asynchronous call of spectrum calculation
     */
    void calculateChannelSpectrumAsync(float time, float duration, void(*callbackFunc)(string, vector<SIGNAL_SAMPLE>));

    /**
     * Returns spectrum samples step value
     */
    float hzPerSample() const;

    /**
     * Sets size of spectrum buffer
     * Must be power of 2
     * If @spectrum_size parameter is not a power of 2
     * method will set up buffer size to nearest bigger power of 2 value
     * Returns actually set value of buffer size
     */
    uint32_t setSpectrumSize(uint32_t spectrum_size);

    uint32_t getSpectrumSize() const;
    uint8_t getIndex() const;
    string getName() const;
private:
    string _name;
    uint8_t _index;
    uint32_t _spectrumSize;
    SignalReader *_signalSource;
    ScreenBuffer *_screenBuffer;
    bool checkPowerOfTwo(uint32_t number);
    uint32_t getNearestBiggerPowerOfTwo(uint32_t number);
};