//
//  Setting.h
//  Aion Status
//
//  Created by Thomas Hajcak on 11/13/12.
//  Copyright (c) 2012 Mavens Consulting, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Setting : NSManagedObject

@property (nonatomic, retain) NSNumber * abyssOpacity;
@property (nonatomic, retain) NSNumber * region;
@property (nonatomic, retain) NSNumber * openInFacebook;
@property (nonatomic, retain) NSNumber * openInTwitter;

@end
