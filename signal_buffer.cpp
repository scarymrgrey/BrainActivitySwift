#include "signal_buffer.h"
#include <stdlib.h>
#include <new>
#include <cstring>

SignalBuffer::SignalBuffer(uint32_t size)
{
    _bufferSize = size;
	//Allocating memory on heap for circular buffer
	//There is possibility that memory won't be allocated, so we have to 
	//check this case and throw an exception if we have null pointer
	buffer = static_cast<SIGNAL_SAMPLE*>(malloc(sizeof(SIGNAL_SAMPLE)*size));
	if (buffer == nullptr)
		throw std::bad_alloc();

   	//Address of head (or first sample of data) of circular buffer
	//is initially equal to buffer's physical address
	head = buffer;

	//While we have no data (data length is equal to 0) in circular buffer 
	//its tail is on the same position as head
	tail = head;
	data_length = 0;
    _overallLength = 0;

	//physical end of buffer
	buffer_end = buffer + _bufferSize - 1;
}


SignalBuffer::~SignalBuffer()
{
	//Free memory allocated for circular buffer
	free(buffer);
}

int32_t SignalBuffer::append(const SIGNAL_SAMPLE *data, size_t length)
{
    if (length <= 0)
        return INVALID_PARAM;

	//if data length is greater than buffer maximum size
	//we should shift start position of data to write 
	//last RING_BUFFER_SIZE samples from input array to buffer
	if (length > _bufferSize)
	{
		data += length - _bufferSize;
		length = _bufferSize;
	}

	SIGNAL_SAMPLE *new_head = head;
	SIGNAL_SAMPLE *new_tail = tail!=head ? tail + length : tail + length - 1;
	
	//Situation where appended data don't exceed buffer at end
	//Tail still is to the left from the end
	//Just adding data from old tail to new
	if (new_tail <= buffer_end)
    {
        memcpy(tail!=head ? tail + 1 : tail, data, length * sizeof(SIGNAL_SAMPLE));

        //Now we must check were is old head relative to old tail
        //If head to the right from the tail it means that tail is
        //one position before head, because if tail exceeded buffer size
        //in the past, it's moved head to position after itself,
        //and now we have same situation, we must move head to position
        //1 sample after tail
        if (tail < head)
        {
            new_head = new_tail + 1;
        }
    }
	//In case when new tail exceeds buffer end position in memory,
	//we should move it to start of buffer with offset equals to 
	//exceeded samples count. 
	else
	{
		ptrdiff_t overflow = new_tail - buffer_end;
		ptrdiff_t before_buffer_end = length - overflow;

		new_tail = buffer + overflow - 1;

		if (before_buffer_end > 0)
			memcpy(tail + 1, data, before_buffer_end*sizeof(SIGNAL_SAMPLE));

		memcpy(buffer, data + before_buffer_end, overflow*sizeof(SIGNAL_SAMPLE));

		//Head can't be before tail in this case 
		new_head = new_tail + 1;
	}
	tail = new_tail;
	head = new_head;

    data_length += length;
    _overallLength += length;
    if (data_length > _bufferSize) data_length = _bufferSize;

	return (int32_t)length;
}

int32_t SignalBuffer::getData(SIGNAL_SAMPLE* out_buffer, uint32_t offset, size_t length)
{
    if (out_buffer == nullptr)
		return OUT_BUFFER_IS_NULL;

    if (length <= 0)
        return INVALID_PARAM;

	if (data_length == 0)
		return SIGNAL_BUFFER_IS_EMPTY;

    if (offset >= data_length)
        return OFFSET_OUT_OF_RANGE;

    if (offset+length > data_length)
        return NOT_ENOUGH_DATA;

    SIGNAL_SAMPLE *read_start = head + offset;
	if (read_start > buffer_end)
    {
        ptrdiff_t from_end = read_start - buffer_end;
        read_start = buffer + from_end - 1;
        memcpy(out_buffer, read_start, length * sizeof(SIGNAL_SAMPLE));
    }
    else
    {
        SIGNAL_SAMPLE *read_end = read_start + length - 1;
        if (read_end > buffer_end)
        {
            ptrdiff_t from_end = read_end - buffer_end;
            ptrdiff_t before_buffer_end = length - from_end;
            memcpy(out_buffer, read_start, before_buffer_end * sizeof(SIGNAL_SAMPLE));
            memcpy(out_buffer + before_buffer_end, buffer, from_end * sizeof(SIGNAL_SAMPLE));
        }
        else
        {
            memcpy(out_buffer, read_start, length * sizeof(SIGNAL_SAMPLE));
        }
    }

	return SIGNAL_BUFF_NO_ERR;
}

int32_t SignalBuffer::getAllData(SIGNAL_SAMPLE* out_buffer)
{
    if (out_buffer == nullptr)
        return OUT_BUFFER_IS_NULL;

    if (data_length == 0)
        return SIGNAL_BUFFER_IS_EMPTY;

    if (tail < head)
	{
		size_t to_end = buffer_end - head + 1;
		size_t to_tail = tail - buffer + 1;
		memcpy(out_buffer, head, to_end * sizeof(SIGNAL_SAMPLE));
		memcpy(out_buffer + to_end, buffer, to_tail * sizeof(SIGNAL_SAMPLE));
	}
    else
    {
        memcpy(out_buffer, head, data_length * sizeof(SIGNAL_SAMPLE));
    }

	return (uint32_t)data_length;
}

int32_t SignalBuffer::getRawBuffer(SIGNAL_SAMPLE* out_buffer)
{
    if (out_buffer == nullptr)
        return OUT_BUFFER_IS_NULL;

    if (data_length == 0)
        return SIGNAL_BUFFER_IS_EMPTY;

    memcpy(out_buffer, buffer, _bufferSize * sizeof(SIGNAL_SAMPLE));

	return SIGNAL_BUFF_NO_ERR;
}

size_t SignalBuffer::getDataLength() const
{
	return data_length;
}

uint32_t SignalBuffer::getBufferSize() const
{
    return _bufferSize;
}

uint32_t SignalBuffer::getOverallLength() const
{
    return _overallLength;
}




