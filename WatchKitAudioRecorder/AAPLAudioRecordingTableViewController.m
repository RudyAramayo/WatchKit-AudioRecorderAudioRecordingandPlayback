/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	'AAPLAudioRecordingTableViewController' implements a table view controller syncs audio files from an Apple Watch back to the iOS device. This class also plays back the audio recording using AVPlayerViewController.
 */

@import AVKit;
@import AVFoundation;
@import WatchConnectivity;

#import "AAPLAudioRecordingTableViewController.h"

NSString *const AAPLAudioRecordingCellReuseIdentifier = @"audioRecordingCellIdentifier";
NSString *const AAPLPlayerViewControllerSegue = @"playerViewControllerSegue";


@interface AAPLAudioRecordingTableViewController () <WCSessionDelegate>

@property NSMutableArray <NSURL *> *audioRecordingURLs;

@property NSURL *selectedURL;

@property WCSession *watchConnectivitySession;

@end


@implementation AAPLAudioRecordingTableViewController

#pragma mark - View did Load

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		_audioRecordingURLs = [[self previouslySavedAudioRecordings] mutableCopy];
	}

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // If WatchConnectivity is supported then setup the delegate and activate the session.
    if ([WCSession isSupported]) {
        self.watchConnectivitySession = [WCSession defaultSession];
        self.watchConnectivitySession.delegate = self;
        [self.watchConnectivitySession activateSession];
    }
}

- (NSArray *)previouslySavedAudioRecordings{
	NSMutableArray *audioRecordingURLs = [NSMutableArray array];
	NSFileManager *defaultManager = [NSFileManager defaultManager];
	
	// We are saving audio recording in our Documents directory.
	NSURL *directory = [defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;

	// Create a directory enumerator to enumerate the audio recordings that we have already saved.
	NSDirectoryEnumerator *audioRecordingEnumerator = [defaultManager enumeratorAtURL:directory includingPropertiesForKeys:@[NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL * __nonnull url, NSError * __nonnull error) {
		if (error) {
			NSLog(@"There was an error getting the previously saved audio recoring: %@", error);
			return NO;
		}

        return YES;
	}];
	
	for (NSURL *audioRecordingURL in audioRecordingEnumerator) {
		// If the file is an mp4 then we want to display it in our UI.
        if ([audioRecordingURL.lastPathComponent.pathExtension isEqualToString:@"mp4"]) {
            [audioRecordingURLs addObject:audioRecordingURL];
        }
	}
	
	return [audioRecordingURLs copy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.audioRecordingURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AAPLAudioRecordingCellReuseIdentifier forIndexPath:indexPath];

	// Fill cells with the audio recording name.
    NSURL *nextURL = self.audioRecordingURLs[indexPath.row];
    cell.textLabel.text = nextURL.lastPathComponent;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	self.selectedURL = self.audioRecordingURLs[indexPath.row];
	
	// If the tableViewCell is selected then push an AVPlayerViewController with the audio URL.
	[self performSegueWithIdentifier:AAPLPlayerViewControllerSegue sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:AAPLPlayerViewControllerSegue]) {
		
		// Create an AVPlayerViewController with the selected URL.
		AVPlayerViewController *playerViewController = segue.destinationViewController;
		
        NSLog(@"Selected URL: %@", self.selectedURL);

        playerViewController.player = [AVPlayer playerWithURL:self.selectedURL];
	}
}

#pragma mark - WCSessionDelegate

- (void)session:(nonnull WCSession *)session didReceiveFile:(nonnull WCSessionFile *)file {
	/*
        This method gets called when the session receives a file. Add the file URL 
        to the list of audio recordings.
    */
	
    NSURL *urlDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
	NSURL *destinationURL = [urlDirectory URLByAppendingPathComponent:file.fileURL.lastPathComponent];
	NSError *error = nil;
	
	// Copy the file to our documents directory so we can reference it later.
	BOOL success = [[NSFileManager defaultManager] copyItemAtURL:file.fileURL toURL:destinationURL error:&error];

    if (!success) {
		NSLog(@"There was an error copying the file to the destination URL: %@.", error);

        return;
	}
	
	[self.audioRecordingURLs addObject:destinationURL];
	
    // Ensure that any UI updates occur on the main queue.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
	NSLog(@"Session did receive file: %@.", file);
}

@end
