#include "brainbit_source.h"
#include "colibri_source.h"

class DataSourceFactory
{
public:
    /**
     * Creates new instance of data source from info struct
     */
    static DataSource* createSource(DataSourceInfo source_info)
    {
        DataSource *ds;
        switch (source_info.type)
        {
            case DS_BRAINBIT:
            {
                ds = new BrainBitSource();
                break;
            }
            case DS_COLIBRI:
            {
                ds = new ColibriSource();
                break;
            }
            default: throw;//TODO throw type not defined exception
        }
        ds->setInfo(source_info);
        return ds;
    }
};
