#ifndef DATA_SOURCE_H
#define DATA_SOURCE_H

#include "channel.h"
#include <map>
#include <mutex>
#include <vector>
#include <list>

using std::map;
using std::mutex;
using std::vector;
using std::list;

/**
 * Data source types
 */
#define DS_BRAINBIT 0
#define DS_COLIBRI 1


/**
 * Data source type
 */
typedef uint8_t DS_TYPE;


/**
 * ID of data source in neuro system
 */
typedef uint16_t DS_ID;


/**
 * Struct describing data source
 * Contains type of source and pointers to functions
 * that send commands to data source
 */
typedef struct
{
    DS_TYPE type;
    uint8_t internal_type_id;
    void (*sendCommand) (uint8_t device_type, char* command, size_t size);
}DataSourceInfo;


/**
 * Abstract class for all possible data sources
 * Provides interface for common access and control of data sources
 * Inherit this class to create your own data source
 */
class DataSource
{
public:
    virtual  ~DataSource(){};

    /**
     * Sends start receive command to device
     */
    virtual void sendStartReceive() = 0;


    /**
     * Sends stop receive command to device
     */
    virtual void sendStopReceive() = 0;


    /**
     * Appends to raw buffer new data received from device
     */
    virtual void appendData(char* data, size_t length) = 0;

    /**
     * Returns buffer with samples optimized to draw on screen
     */
    Channel* getChannel(string channel);

    void setAllScreenBuffersDuration(float duration);

    void setAllScreenBuffersSamplesCount(uint32_t samples_count);

    /**
     * Returns sampling frequency of data in source
     */
    uint16_t getFSampling() const;


    /**
     * Returns channel count of data source
     */
    uint16_t getChCount() const;

    /**
     * Returns full duration of signal in seconds from start of survey
     */
    float getSurveyDuration() const;


    /**
     * Returns list of data source channels
     */
    vector<string> getChannels() const;


    /**
     * Buffer duration in seconds
     */
    uint32_t getBufferDuration() const;


    /**
     * Size of pre-buffer ordered map
     */
    size_t getSampleMapSize() const;


    /**
     * Returns total count of samples been put in data buffer
     */
    uint32_t getFullDataLength() const;

    /**
     * Sets size of input reordering buffer
     * Note that big size of this buffer entails
     * appropriate delays of signal in output buffers
     */
    void setSampleMapSize(size_t size);

    void setInfo(DataSourceInfo info);

protected:
    DataSource(size_t sampleMapSize);
    uint32_t _packetNumberPreValue;
    DataSourceInfo _info;

    map<string, Channel*> _channels;

    SignalBuffer *_signalBuffer;

    SignalReader *_signalReader;

    /**
     * Input samples map
     * is used to order received samples by their numbers
     */
    map<uint32_t, SIGNAL_SAMPLE*> _sampleMap;

    /**
     * Mutex for concurrent access to pre-buffer map
     */
    mutex _mapMutex;

    /**
     * Mutex for data buffer access
     */
    mutex _bufferMutex;

    /**
     * Size of input samples map
     */
    size_t _sampleMapSize;
};

#endif


