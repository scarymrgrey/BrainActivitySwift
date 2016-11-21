#include "data_source.h"

#define COLIBRI_SORT_MAP_SIZE 250
#define COLIBRI_BUFFER_SIZE 60000 //equals to 60 sec on 1kHz samplig frequency

typedef unsigned char COLIBRI_COMMAND;

class ColibriSource: public DataSource
{
public:
    ColibriSource();
    ~ColibriSource();

    void appendData(char* data, size_t length);
    void sendStartReceive();
    void sendStopReceive();
    float getBufferStartTime() const;

private:
    ;
};
