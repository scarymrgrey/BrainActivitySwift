#include <cstdint>

class CommonAlgorithms
{
public:
    static void FFTAnalysis(double *AVal, double *FTvl, int Nvl, int Nft);

    static double RhythmSpectrumPower(double *spectrum, float frequency_step, float start_freq,
                                      float stop_freq, float normalization_coefficient);

    static const double TwoPi;
};
