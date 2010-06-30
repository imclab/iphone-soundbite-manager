#ifndef _EASWrapper_H__
#define _EASWrapper_H__

/* include the EAS public API header file */

#include <cstdlib> 
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "eas.h"
#include "juce.h"

class EASWrapper
{
public:
    EASWrapper ();
	~EASWrapper ();
	void EAS_Initalize(int bufferSize);
	void EAS_OpenMidiStream();
    void EAS_renderAudio(AudioSampleBuffer & juceBuffer, int numSamples, MidiBuffer & incomingMIDI);
	void EAS_setVolume(int newVolume);

private:
	EAS_DATA_HANDLE pEASData;
	EAS_PCM* audioBuffer;
	EAS_U8* midiBuffer;
	EAS_HANDLE pMIDIHandle;
	EAS_I32 count;
	int numBuffers;
	int synthNum;
	MidiOutput* midiOut;
	
	EAS_RESULT InitEASLibrary(int bufferSize);
	EAS_HANDLE OpenMidiStream();
	
};

#endif