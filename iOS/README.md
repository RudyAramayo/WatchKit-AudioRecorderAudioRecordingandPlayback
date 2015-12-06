# WatchKitAudioRecorder: Audio Recording and Playback

This sample demonstrates how to use WKInterfaceController to perform an audio recording. Refer to this sample if you want to learn how to present an AudioRecordingViewController to record and save audio and/or see how to present a MediaPlaybackController for playback of an asset. This project also use new features in WatchKit 2.0 including WatchConnectivity's file transfer capabilities to move the audio file recorded on your Apple Watch back to the paired iOS device, as well as WKInterfacePicker to display the different audio recording settings. In order to get WatchConnectivity working with your sample modify the SAMPLE_BUNDLE_PREFIX in the project to match your bundle identifier.

    1. Make a provisioning profile with a bundle identifier for your app
    2. GOTO the Project settings tab and then goto build settings. at the bottom is a User-Defined section with the dictionary key SAMPLE_BUNDLE_PREFIX... make sure you change that key to the bundle id you created in the provisioning portal.
    3. GOTO the "capabilities" tab of project settings and make sure you refresh each of the groups now that your bundle id has changed... i found that I had to uncheck and then recheck each group
    4. Switch to the other two targets for the watchkit extension and the watchkit app and make sure you do the same for the SAMPLE_BUNDLE_PREFIX as well as the capabilities tab for the app-group


## Requirements

### Build

Xcode 7.0, iOS 9.0 SDK, watchOS 2.0 SDK

### Runtime

watchOS 2.0

Copyright (C) 2015 Apple Inc. All rights reserved.
