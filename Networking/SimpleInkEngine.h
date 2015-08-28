//
//  SimpleInkEngine.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/11/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "MKNetworkEngine.h"

@interface SimpleInkEngine : MKNetworkEngine

typedef void (^AvailableServersBlock)(void);
typedef void (^ServerStatusBlock)(NSDictionary *serverStatuses);
typedef void (^AlertsBlock)(void);

- (MKNetworkOperation *)getAvailableServers:(AvailableServersBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;
- (MKNetworkOperation *)getServerStatus:(ServerStatusBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;
- (MKNetworkOperation *)getAlerts:(AlertsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;

@end
