#include "ofApp.h"

#define FRAMES_PER_BUFFER 256
#define BUFFER_LENGTH 441000 // 10 seconds
#define NUM_BYTES_PER_FLOAT 4
//--------------------------------------------------------------
void ofApp::setup(){
    ofSetLogLevel(OF_LOG_VERBOSE);
    phase = 0;
        player.load("sounds/CC01.mp3");
        player.stop();
    ofSoundStreamSetup(1, 1);
    soundRecorder* recorder1 = new soundRecorder();
    soundRecorder* recorder2 = new soundRecorder();
    recorders.push_back(recorder1);
    recorders.push_back(recorder2);
    
    player.setPaused(false);
    player.play();
    player.setVolume(0.1);
    
    for(int i = 0; i < recorders.size(); i++) {
        mixer.addRecorder(recorders[i]);
    }
    
    mixer.addPlayer(&player);
    
    //ofSoundBuffer buffer;
    //recorder = new soundRecorder();
//    buffer.allocate(BUFFER_LENGTH, 1);
//    buffer.fillWithTone();
//    cout<<buffer.getNumFrames()<<endl;
//    recPos = 0;
//    playPos = 0;
}

//--------------------------------------------------------------
void ofApp::update(){
    
}

//--------------------------------------------------------------
void ofApp::draw(){
	
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    if(touch.numTouches == 2) {
        recorders[0]->record();
        cout<<"Recording 1..."<<endl;
    }
    else if(touch.numTouches == 3 ) {
        recorders[1]->record();
        cout<<"Recording 2..."<<endl;

    } else if(touch.numTouches == 4) {
        recorders[0]->play();
        recorders[1]->play();
        cout<<"Playing 1 & 2..."<<endl;
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    //player.setPaused(true);
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    if(player.isPlaying()) {
        player.setPaused(true);
    } else {
        player.setPaused(false);
    }
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
//--------------------------------------------------------------
void ofApp::audioIn( float * input, int bufferSize, int nChannels ) {
    if(recorders.size() == 2) {
        recorders[0]->fillRecording(input, bufferSize, nChannels);
        recorders[1]->fillRecording(input, bufferSize, nChannels);
    }
}

//--------------------------------------------------------------
void ofApp::audioOut( float * output, int bufferSize, int nChannels ) {
    if(recorders.size() == 2) {
        mixer.outputMix(output, bufferSize, nChannels);
//        for(int i = 0; i < bufferSize*nChannels; i++) {
//            //output[i] += 0.1;
//        }
//        recorders[0]->outputRecording(output, bufferSize, nChannels);
//        recorders[1]->outputRecording(output, bufferSize, nChannels);
    }
}

//void PrintFloatDataFromAudioFile() {
//    
//    NSString *  name = @"Filename";  //YOUR FILE NAME
//    NSString * source = [[NSBundle mainBundle] pathForResource:name ofType:@"m4a"]; // SPECIFY YOUR FILE FORMAT
//    
//    const char *cString = [source cStringUsingEncoding:NSASCIIStringEncoding];
//    
//    CFStringRef str = CFStringCreateWithCString(
//                                                NULL,
//                                                cString,
//                                                kCFStringEncodingMacRoman
//                                                );
//    CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(
//                                                          kCFAllocatorDefault,
//                                                          str,
//                                                          kCFURLPOSIXPathStyle,
//                                                          false
//                                                          );
//    
//    ExtAudioFileRef fileRef;
//    ExtAudioFileOpenURL(inputFileURL, &fileRef);
//    
//    
//    AudioStreamBasicDescription audioFormat;
//    audioFormat.mSampleRate = 44100;   // GIVE YOUR SAMPLING RATE
//    audioFormat.mFormatID = kAudioFormatLinearPCM;
//    audioFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat;
//    audioFormat.mBitsPerChannel = sizeof(Float32) * 8;
//    audioFormat.mChannelsPerFrame = 1; // Mono
//    audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(Float32);  // == sizeof(Float32)
//    audioFormat.mFramesPerPacket = 1;
//    audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame; // = sizeof(Float32)
//    
//    // 3) Apply audio format to the Extended Audio File
//    ExtAudioFileSetProperty(
//                            fileRef,
//                            kExtAudioFileProperty_ClientDataFormat,
//                            sizeof (AudioStreamBasicDescription), //= audioFormat
//                            &audioFormat);
//    
//    int numSamples = 1024; //How many samples to read in at a time
//    UInt32 sizePerPacket = audioFormat.mBytesPerPacket; // = sizeof(Float32) = 32bytes
//    UInt32 packetsPerBuffer = numSamples;
//    UInt32 outputBufferSize = packetsPerBuffer * sizePerPacket;
//    
//    // So the lvalue of outputBuffer is the memory location where we have reserved space
//    UInt8 *outputBuffer = (UInt8 *)malloc(sizeof(UInt8 *) * outputBufferSize);
//    
//    
//    
//    AudioBufferList convertedData ;//= malloc(sizeof(convertedData));
//    
//    convertedData.mNumberBuffers = 1;    // Set this to 1 for mono
//    convertedData.mBuffers[0].mNumberChannels = audioFormat.mChannelsPerFrame;  //also = 1
//    convertedData.mBuffers[0].mDataByteSize = outputBufferSize;
//    convertedData.mBuffers[0].mData = outputBuffer; //
//    
//    UInt32 frameCount = numSamples;
//    float *samplesAsCArray;
//    int j =0;
//    double floatDataArray[882000]   ; // SPECIFY YOUR DATA LIMIT MINE WAS 882000 , SHOULD BE EQUAL TO OR MORE THAN DATA LIMIT
//    
//    while (frameCount > 0) {
//        ExtAudioFileRead(
//                         fileRef,
//                         &frameCount,
//                         &convertedData
//                         );
//        if (frameCount > 0)  {
//            AudioBuffer audioBuffer = convertedData.mBuffers[0];
//            samplesAsCArray = (float *)audioBuffer.mData; // CAST YOUR mData INTO FLOAT
//            
//            for (int i =0; i<1024 /*numSamples */; i++) { //YOU CAN PUT numSamples INTEAD OF 1024
//                
//                floatDataArray[j] = (double)samplesAsCArray[i] ; //PUT YOUR DATA INTO FLOAT ARRAY
//                printf("\n%f",floatDataArray[j]);  //PRINT YOUR ARRAY'S DATA IN FLOAT FORM RANGING -1 TO +1
//                j++;
//                
//                
//            }
//        }
//    }}
