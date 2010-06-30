
#include "EASWrapper.h"

/* Error codes for detected error conditions. The EAS Library uses 
 * negative values, so we will use positive values. Success is 
 * indicated by zero (EAS_SUCCESS). */
#define ERROR_BUFFER_ALLOCATION	1 
#define ERROR_BUFFER_UNDERRUN	2
#define ERROR_STREAM_CONSTRUCTION	3

static const S_EAS_LIB_CONFIG* pLibConfig = NULL;

/* Persistent variables that are needed for EAS API calls. You can
 * either create them as static data, as we have done here, or create
 * them as stack variables at the top level of the task stack. */


EASWrapper::EASWrapper ()
{
}

EASWrapper::~EASWrapper ()
{
}

void EASWrapper::EAS_Initalize(int bufferSize)
{
	InitEASLibrary(bufferSize);
}

void EASWrapper::EAS_OpenMidiStream()
{
	OpenMidiStream();
}

/******************************************************************** 
 * InitEASLibrary()*
 * This function initializes the EAS library and allocates a pair of
 * "ping-ping" buffers for audio rendering.
 *******************************************************************/

EAS_RESULT EASWrapper::InitEASLibrary(int bufferSize)
{
	
	Logger::outputDebugString("eas init");
	
	EAS_RESULT result;
	/* get the library configuration */
	pLibConfig = EAS_Config();
	/* initialize the library */
	if ((result = EAS_Init(&pEASData)) != EAS_SUCCESS)
	{
		Logger::outputDebugString("EAS failed to initialized : code " + String(float(result)));
		return result;
	}
	Logger::outputDebugString("EAS initialized");
	Logger::outputDebugString("polyphony: " + String((int)pLibConfig->maxVoices));
	Logger::outputDebugString("sampleCount: " + String((int)pLibConfig->mixBufferSize));
	Logger::outputDebugString("numChannels: " + String((int)pLibConfig->numChannels));
							  
	/* allocate the audio buffers */
	numBuffers = bufferSize / 128;
	Logger::outputDebugString("bufferSize: " + String(bufferSize));
	Logger::outputDebugString("numBuffers: " + String(numBuffers));
	
	// Allocate the audio Buffer
	audioBuffer = new EAS_PCM[pLibConfig->mixBufferSize * pLibConfig->numChannels * numBuffers];
	if (!audioBuffer) return ERROR_BUFFER_ALLOCATION;
	
	// TODO: Fix Memory Leak
	midiBuffer = new EAS_U8[1000];
	//midiBuffer = NULL;
	
	Logger::outputDebugString("done eas init");
	return EAS_SUCCESS;
}

/******************************************************************** * 
 OpenMidiStream() 
 * * This function opens a midi pipe to EAS
 *******************************************************************/

EAS_HANDLE EASWrapper::OpenMidiStream()
{
	/*
	 4.3.1 EAS_OpenMIDIStream
	 Opens a MIDI stream for real-time MIDI event processing.
	 Pass in pEASData, the handle that was obtained from EAS_Init call and an optional stream handle. 
	 Returns a new MIDI stream handle in the variable pointed to by pHandle. 
	 If streamHandle is NULL, a new instance of the synthesizer is created. 
	 If streamHandle is a handle returned by EAS_OpenFile, the real-time MIDI stream will use the same synthesizer as the file opened by EAS_OpenFile.
	 
	 EAS_RESULT EAS_OpenMIDIStream(EAS_DATA_HANDLE pEASData, EAS_HANDLE *pMIDIHandle, EAS_HANDLE streamHandle);
	 */
	EAS_RESULT result;
	if ((result = EAS_OpenMIDIStream(pEASData, &pMIDIHandle, NULL)) != EAS_SUCCESS)
	{
		Logger::outputDebugString("EAS MIDI stream failed to initialized : code " + String(float(result)));
	}
	Logger::outputDebugString("Midi initialized");
	
							  
	return EAS_SUCCESS;
}
/******************************************************************** * 
 EAS_renderAudio() 
 * Render audio from an EAS stream
 *******************************************************************/
void EASWrapper::EAS_renderAudio(AudioSampleBuffer & juceBuffer, int numSamples, MidiBuffer & incomingMIDI)
{
	
	EAS_RESULT result = EAS_SUCCESS;
	MidiBuffer::Iterator iter(incomingMIDI);
	int numBytesofMidiData = 0;
	int samplePosition = 0;
	const uint8* midiData;
	int midiCount = 0;
	// iterates through the buffer ..
	while (iter.getNextEvent(midiData, numBytesofMidiData, samplePosition))
	{
		// add to the uint Midibuffer
		for (int i = 0; i < numBytesofMidiData; i++)
		{
			midiBuffer[midiCount] = midiData[i];
			midiCount++;
		}
	}
	
	/*
	 4.3.2 EAS_WriteMIDIStream
	 Streams MIDI data into the rendering engine. Pass in pEASData, the handle obtained from EAS_Init, 
	 the stream handle obtained from OpenMIDIStream, pBuffer a pointer to the MIDI stream data, 
	 and count the number of bytes in the buffer.
	 
	 EAS_RESULT EAS_WriteMIDIStream(EAS_DATA_HANDLE pEASData, EAS_HANDLE midiHandle, EAS_U8 *pBuffer, EAS_I32 count);
	 */
	if (midiCount != 0)
		result = EAS_WriteMIDIStream(pEASData, pMIDIHandle, midiBuffer, midiCount); // count is total size in bytes
	
	
	/* Extra Reporting
	 if (result == EAS_SUCCESS) Logger::outputDebugString("midi processed - " + String(count));
	 else Logger::outputDebugString("midi error:" + String(float(result)) );*/
	/*
	 4.1.2 EAS_Render
	 This function performs the actual audio rendering via the synthesizer. 
	 The synth calls the appropriate file parser as needed. 
	 Call this repeatedly to render audio from the song file. 
	 Pass in pEASData obtained from EAS_Init, a pointer into the the host buffer at a particular offest,
	 the value of pConfig->mixBufferSize, and the address of a counter which will return the actual number of output samples rendered.
	 
	 EAS_RESULT EAS_Render(EAS_DATA_HANDLE pEASData, EAS_PCM *pOut, EAS_I32 numRequested, EAS_I32 *pNumGenerated);
	 */
	int num_output = 0;
	EAS_PCM* p = audioBuffer;
	for (int i = 0; i < numBuffers/2; i++)
	{
		result = EAS_Render(pEASData, p, pLibConfig->mixBufferSize, &count);
		p += count * pLibConfig->numChannels;
		num_output += count * pLibConfig->numChannels;
	}
	
	int currentSample = 0;
	int maxSample = juceBuffer.getNumSamples();
	for (int j = 0; j < num_output; j++)
	{
		if (currentSample + 1 > maxSample) break; // this should never happen, but does sometimes on simulator ...
			
		if (pLibConfig->numChannels == 1)
		{
			*juceBuffer.getSampleData(0, currentSample) = (audioBuffer[j])/float(32768);
			*juceBuffer.getSampleData(0, currentSample + 1) = (audioBuffer[j])/float(32768);
			*juceBuffer.getSampleData(1, currentSample) = (audioBuffer[j])/float(32768);
			*juceBuffer.getSampleData(1, currentSample + 1) = (audioBuffer[j])/float(32768);
			
			currentSample += 2;
		}
		else if (pLibConfig->numChannels == 2)
		{
			if ((j % 2) == 0)
			{
				*juceBuffer.getSampleData(0, currentSample) = (audioBuffer[j])/float(32768);
				*juceBuffer.getSampleData(0, currentSample + 1) = (audioBuffer[j])/float(32768);
			}
			if ((j % 2) == 1)
			{
				*juceBuffer.getSampleData(1, currentSample) = (audioBuffer[j])/float(32768);
				*juceBuffer.getSampleData(1, currentSample + 1) = (audioBuffer[j])/float(32768);
			}
			if ((j % 2) == 1) currentSample += 2;
		}
	}
}
void EASWrapper::EAS_setVolume(int newVolume)
{
	EAS_SetVolume(pEASData, NULL, newVolume);
	Logger::outputDebugString("volume: " + String((int)EAS_GetVolume(pEASData, NULL)));
}
