#include "data_source.h"

using namespace std;
#ifndef _PERF_CPLUSPLUS_
#define _PERF_CPLUSPLUS_
class NeuroSystem
{
public:
    NeuroSystem();
    ~NeuroSystem();
public:
    /**
     * Returns full duration of survey made by specified data source
     * Note that there can be no data for timings before circular buffer start time
     */
	float getDuration(DS_ID source) const;

    /**
     * Appends data source to EEG system
     */
	DS_ID attachDataSource(DataSourceInfo source_info);

    /**
     * Removes data source from system
     */
	void detachDataSource(DS_ID source);

    /**
     * Returns pointer to data source with specified ID
     */
	DataSource* getSource(DS_ID source) const;
private:
    map<DS_ID, DataSource*> _dataSources;
};
#endif
