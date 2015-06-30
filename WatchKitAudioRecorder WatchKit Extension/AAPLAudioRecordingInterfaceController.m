/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	'AAPLAudioRecordingInterfaceController' implements audio recording based on a preset that the user has chosen, saves the recording, and plays back the last recording that was made.
 */

@import WatchConnectivity;
#import "AAPLAudioRecordingInterfaceController.h"
#import "AAPLAppConfiguration.h"

@interface AAPLAudioRecordingInterfaceController () <WCSessionDelegate>

@property (weak, nonatomic) IBOutlet WKInterfacePicker *picker;

@property NSArray <WKPickerItem *> *pickerItems;

@property NSURL *lastRecordingURL;

@property WKPickerItem *selectedItem;

@property NSUInteger numberOfRecordings;

@end


@implementation AAPLAudioRecordingInterfaceController

- (instancetype)init {
	self = [super init];

	if (self) {
		// Create Picker Items fro our Picker.
		WKPickerItem *narrowBand = [[WKPickerItem alloc] init];
		narrowBand.title = @"Narrow Band";

        WKPickerItem *wideBand = [[WKPickerItem alloc] init];
		wideBand.title = @"Wide Band";
		
        WKPickerItem *highQuality = [[WKPickerItem alloc] init];
		highQuality.title = @"High Quality";
		
        // Activate the session on both sides to enable communication.
        [WCSession defaultSession].delegate = self;
        [[WCSession defaultSession] activateSession];
		
		// Keep track of the picker items to know which one has been selected.
		_pickerItems = @[narrowBand, wideBand, highQuality];
		
		// Set the picker items on the picker.
		[_picker setItems:self.pickerItems];
		
		_numberOfRecordings = 0;
	}
	
	return self;
}

#pragma mark - IBActions

- (IBAction)pickerValueSelected:(NSInteger)value {
	self.selectedItem = self.pickerItems[value];
}

- (IBAction)startRecording {
	WKAudioRecordingPreset preset = [self audioRecordingPresetForPickerItem:self.selectedItem];

	NSLog(@"preset: %d", preset);
	
	// Get the directory from the app group.
	NSURL *directory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:AAPLAppConfigurationApplicationGroupsPrimary];
	NSUInteger timeAtRecording = (NSUInteger)[NSDate timeIntervalSinceReferenceDate];
	__block NSString *recordingName = [NSString stringWithFormat:@"AudioRecording-%d.mp4", timeAtRecording];
	__block NSURL * outputURL = [directory URLByAppendingPathComponent:recordingName];
	__weak AAPLAudioRecordingInterfaceController *weakSelf = self;
	
	[self presentAudioRecordingControllerWithOutputURL:outputURL preset:preset maximumDuration:30 actionTitle:nil completion:^(BOOL didSave, NSError * __nullable error) {
        __strong AAPLAudioRecordingInterfaceController *strongSelf = weakSelf;
        
        if (!strongSelf) {
            return;
        }
        
		if (didSave) {
			/*
                After saving we need to move the file to our documents directory
                so that WatchConnectivity can transfer it.
            */
			NSURL *extensionDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
			
            NSURL *outputExtensionURL = [extensionDirectory URLByAppendingPathComponent:recordingName];
			
            NSError *moveError;
			
            NSLog(@"outputURL: %@", outputURL);
			NSLog(@"outputExtensionURL: %@", outputExtensionURL);
			
            // Move the file.
			BOOL success = [[NSFileManager defaultManager] copyItemAtURL:outputURL toURL:outputExtensionURL error:&moveError];
			
            if (!success) {
				NSLog(@"Failed to move the outputURL to the extension's documents direcotry: %@", error);
			}
            else {
				strongSelf.lastRecordingURL = outputURL;
				NSLog(@"lastRecordingURL: %@.", strongSelf.lastRecordingURL);
				
				// Activate the session before transferring the file.
				[[WCSession defaultSession] transferFile:outputExtensionURL metadata:nil];
			}
			
			self.numberOfRecordings++;
		}

        if (error) {
			NSLog(@"There was an error with the audio recording: %@.", error);
		}
	}];
}

- (IBAction)playLastRecording {
	// Present the media player controller for the last recorded URL.
    NSDictionary *options = @{
        WKMediaPlayerControllerOptionsAutoplayKey : @YES
    };
	
    [self presentMediaPlayerControllerWithURL:self.lastRecordingURL options:options completion:^(BOOL didPlayToEnd, NSTimeInterval endTime, NSError * __nullable error) {
		if (!didPlayToEnd) {
			NSLog(@"The player did not play all the way to the end. The player only played until time - %.2f.", endTime);
		}
		
		if (error) {
			NSLog(@"There was an error with playback: %@.", error);
		}
	}];
}

#pragma mark - Audio Preset Helpers

- (WKAudioRecordingPreset)audioRecordingPresetForPickerItem:(WKPickerItem *)pickerItem {
	// Get the audio recording preset from the picker item.
	NSString *title = pickerItem.title;

    WKAudioRecordingPreset preset = WKAudioRecordingPresetHighQualityAudio;

    if ([title isEqualToString:@"Narrow Band"]) {
		preset = WKAudioRecordingPresetNarrowBandSpeech;
	}
    else if ([title isEqualToString:@"Wide Band"]) {
		preset = WKAudioRecordingPresetWideBandSpeech;
	}
	
	return preset;
}

#pragma mark - WCSessionDelegate

- (void)session:(nonnull WCSession *)session didFinishFileTransfer:(nonnull WCSessionFileTransfer *)fileTransfer error:(nullable NSError *)error {
	// This method is called on the sending side when the file has successfully transfered.
	if (error) {
		NSLog(@"There was an error transferring the file: %@", error);
	}
    else {
		NSLog(@"The file was transfered succesfully!");
	}
}

@end
