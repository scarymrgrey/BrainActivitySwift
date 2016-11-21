//Error codes of buffer operations
#define SIGNAL_BUFF_NO_ERR 0
#define SIGNAL_BUFFER_IS_EMPTY -1
#define OUT_BUFFER_IS_NULL -2
#define OFFSET_OUT_OF_RANGE -3
#define NOT_ENOUGH_DATA -4
#define INVALID_PARAM -5

#include <stdint.h>
#include <stddef.h>

typedef double SIGNAL_SAMPLE; //Determines signal sample type

/** EEG data buffer class
* Represents channel data buffer in EEG system
* This buffer only stores EEG samples. It doesn't know anything about sampling frequency,
* full data length, channel type or name. Getting of data through sample numbers in buffer.
* You can get data in raw buffer representation (just samples as they lay in memory)
* or in terms of head(start) and tail(end) of buffer, where head has 0 index in circular buffer,
* tail has [dataLength-1] index.
*/
class SignalBuffer
{
public:
	SignalBuffer(uint32_t size);
	~SignalBuffer();

	/**
	* Appends raw data to the channel buffer
	* @param pointer to eeg data samples array
	* @param length of eeg data array
	* @return count of appended samples or negative error code
	*/
	int32_t append(const SIGNAL_SAMPLE* data, size_t length);

	/**
	* Gets data from buffer
	* @param output buffer for EEG data. Must be allocated before passing to this method
	* @param offset in samples
	* @param data length in samples
	* @return error code
	*/
	int32_t getData(SIGNAL_SAMPLE* out_buffer, uint32_t offset, size_t length);

	/**
	* Gets all data from buffer
	* @param output buffer for EEG data. Must be allocated before passing to this method045
	* @return error code
	*/
	int32_t getAllData(SIGNAL_SAMPLE* out_buffer);

	/**
	* Gets all samples of buffer in order they laying in memory
	* @param output buffer for EEG data. Must be allocated before passing to this method
	* @return error code
	*/
	int32_t getRawBuffer(SIGNAL_SAMPLE* out_buffer);

	/**
	* Gets length of data stored in buffer
	* @return length of data stored in buffer
	*/
	size_t getDataLength() const;

	/**
	 * Gets buffer size in samples
	 * @return buffer size
	 */
	uint32_t getBufferSize() const;

	/**
	 * Returns data length appended to buffer from first added sample
	 */
	uint32_t getOverallLength() const;

private:
	/**
	* Circular buffer for channel data
	*/
	SIGNAL_SAMPLE *buffer;

	/**
	* Address of physical end of buffer
	*/
	SIGNAL_SAMPLE *buffer_end;

	/**
	* Pointer to first sample of data in circular buffer
	*/
	SIGNAL_SAMPLE *head;
	
	/**
	* Pointer to the last sample of data in circular buffer
	*/
	SIGNAL_SAMPLE *tail;

	/**
	* Current length of data stored in circular buffer
	*/
	size_t data_length;

	/**
	 * Circular buffer size in samples
	 */
	uint32_t _bufferSize;

	/**
	 * Total data length appended to buffer from first added sample
	 */
	uint32_t _overallLength;
};

