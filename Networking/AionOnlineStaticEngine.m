//
//  AionOnlineStaticEngine.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/29/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "AionOnlineStaticEngine.h"

@implementation AionOnlineStaticEngine

- (NSString *)cacheDirectoryName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:@"AionOnlineStaticImages"];
    return cacheDirectoryName;
}

@end
