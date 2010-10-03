//
//  PrefReader.m
//  MGOV
//
//  Created by sodas on 2010/10/3.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import "PrefReader.h"

@implementation PrefReader

@synthesize prefDict, prefPlistPathInAppDocuments;

#pragma mark -
#pragma mark Method

+ (void)copyEmptyPrefPlistToDocumentsByRecover:(BOOL)recover {
	// Define File Path
	NSString *userInformationPlistPathInAppBundle = [[NSBundle mainBundle] pathForResource:kPrefPlistFileName ofType:@"plist"];
	NSString *userInformationPlistPathInAppDocuments = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kPrefPlistFileFullName];
	// Copy plist file
	if (recover) {
		[[NSFileManager defaultManager] removeItemAtPath:userInformationPlistPathInAppDocuments error:nil];
		[[NSFileManager defaultManager] copyItemAtPath:userInformationPlistPathInAppBundle toPath:userInformationPlistPathInAppDocuments error:nil];
	} else if (![[NSFileManager defaultManager] fileExistsAtPath:userInformationPlistPathInAppDocuments]) {
		[[NSFileManager defaultManager] copyItemAtPath:userInformationPlistPathInAppBundle toPath:userInformationPlistPathInAppDocuments error:nil];
	}
}

+ (id)readPrefByKey:(NSString *)key {
	PrefReader *tmp = [[[PrefReader alloc] init] autorelease];
	return [tmp.prefDict objectForKey:key];
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		self.prefPlistPathInAppDocuments = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kPrefPlistFileFullName];
		self.prefDict = [NSMutableDictionary dictionaryWithContentsOfFile:prefPlistPathInAppDocuments];
	}
	return self;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[super dealloc];
}

@end
