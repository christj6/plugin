import std.math;
import dplug.core, dplug.client, dplug.vst;

// This create the DLL entry point
mixin(DLLEntryPoint!());

// This create the VST entry point
mixin(VSTEntryPoint!MyFirstPlugin);

enum : int
{
    paramOnOff
}

/// Simplest VST plugin you could make.
final class MyFirstPlugin : dplug.client.Client
{
public:

    override PluginInfo buildPluginInfo()
    {
        PluginInfo info;
        info.vendorName = "No Name Audio";
        info.vendorUniqueID = CCONST('N', 'o', 'A', 'u');
        info.pluginName = "My First Plugin";
        info.pluginUniqueID = CCONST('N', 'A', 'm', 's');
        info.pluginVersion = PluginVersion(1, 0, 0);
        info.isSynth = false;
        info.hasGUI = false;
        return info;
    }

    override Parameter[] buildParameters()
    {
        return [ new BoolParameter(paramOnOff, "on/off", true) ];
    }

    override LegalIO[] buildLegalIO()
    {
        return [ LegalIO(2, 2) ];
    }

    override void reset(double sampleRate, int maxFrames, int numInputs, int numOutputs) nothrow @nogc
    {
    }

    // challenge: can you make the parameter affect timing, too? What I mean is, when the switch is ON, can you
    // make the plugin alternate between playing through the left channel alone and then the right channel alone?
    override void processAudio(const(float*)[] inputs, float*[]outputs, int frames, TimeInfo info) nothrow @nogc
    {
        // note: SQRT1_2 appears frequently here. Google says that "SQRT1_2" is sqrt(1/2). Or, approximately, 0.707
        if (readBoolParamValue(paramOnOff)) // if the switch is on:
        {
            /*
            // makes signal only come out through the LEFT channel
            outputs[0][0..frames] = ( (inputs[0][0..frames] + inputs[1][0..frames]) ) * SQRT1_2;
            outputs[1][0..frames] = ( (inputs[0][0..frames] - inputs[1][0..frames]) ) * SQRT1_2;
            */

            // makes signal only come out through the RIGHT channel
            for (int j = 0; j < frames; j++)
            {
                outputs[0][j] = ( (inputs[0][j] - inputs[1][j]) ) * SQRT1_2;
                outputs[1][j] = ( (inputs[0][j] + inputs[1][j]) ) * SQRT1_2;
            }
        }
        else // if switch is off
        {
            // signal comes out normally, through BOTH channels
            for (int i = 0; i < 2; i++) // 0 == left, 1 == right (or perhaps it's the other way around)
            {
                for (int j = 0; j < frames; j++)
                {
                    outputs[i][j] = inputs[i][j];
                }
            }   
        }
    }
}
