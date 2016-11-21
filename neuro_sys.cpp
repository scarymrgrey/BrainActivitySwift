#include "neuro_sys.h"
#include "source_factory.h"

NeuroSystem::NeuroSystem()
{

}

NeuroSystem::~NeuroSystem()
{
    for (auto &ds_pair: _dataSources)
    {
        delete ds_pair.second;
    }
    _dataSources.clear();
}

DS_ID NeuroSystem::attachDataSource(DataSourceInfo source_info)
{
	auto newSource = DataSourceFactory::createSource(source_info);
	DS_ID newId = 0;

	if (!_dataSources.empty())
	{
		newId = (DS_ID)(_dataSources.rbegin()->first + 1);
	}

	_dataSources.insert(pair<DS_ID, DataSource*>(newId, newSource));

	return newId;
}

void NeuroSystem::detachDataSource(DS_ID source)
{
	auto it = _dataSources.find(source);
	if (it == _dataSources.end()) return;

    delete it->second;
	_dataSources.erase(it);
}

float NeuroSystem::getDuration(DS_ID source) const
{
	auto ds = getSource(source);
	if (ds == nullptr) return 0.0f;

	return ds->getSurveyDuration();
}

DataSource *NeuroSystem::getSource(DS_ID source) const
{
	auto it = _dataSources.find(source);
	if (it == _dataSources.end()) return nullptr;

	return it->second;
}





















