//
//  Server.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 5/1/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Server : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * onAbyss;
@property (nonatomic, retain) NSNumber * onSearch;
@property (nonatomic, retain) NSNumber * isSelectedSearch;
@property (nonatomic, retain) NSNumber * isSelectedPvP;

@end
