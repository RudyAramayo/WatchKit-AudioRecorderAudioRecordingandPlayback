/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Handles application configuration logic and information.
*/

#import "AAPLAppConfiguration.h"

/*!
 The \c SAMPLE_BUNDLE_PREFIX_STRING preprocessor macro is used below to concatenate the value of the
 \c SAMPLE_BUNDLE_PREFIX user-defined build setting with other strings. This avoids the need for developers
 to edit both SAMPLE_BUNDLE_PREFIX and the code below. \c SAMPLE_BUNDLE_PREFIX_STRING is equal to
 \c @"SAMPLE_BUNDLE_PREFIX", i.e. an \c NSString literal for the value of \c SAMPLE_BUNDLE_PREFIX. (Multiple
 \c NSString literals can be concatenated at compile-time to create a new string literal.)
 */
NSString *const AAPLAppConfigurationApplicationGroupsPrimary = @"group."SAMPLE_BUNDLE_PREFIX_STRING@".WatchKitAudioRecorder";
