//
//  SimpleInkEngine.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/11/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "SimpleInkEngine.h"

#import "Server.h"

@implementation SimpleInkEngine

- (MKNetworkOperation *)getAvailableServers:(AvailableServersBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    MKNetworkOperation *operation = [self operationWithPath:@"aionstatus/as2servers"
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
    {
        NSArray *responseResultsArray = [[completedOperation responseJSON] valueForKey:@"servers"];
        if (responseResultsArray) {
            
            CoreDataStore *dataStore = [CoreDataStore createStore];
            
            for (Server *server in [dataStore allForEntity:@"Server" error:nil]) {
                server.onAbyss = BOX_BOOL(NO);
                server.onSearch = BOX_BOOL(NO);
            }
            
            for (NSDictionary *result in responseResultsArray) {
                Server *server = nil;
                server = [Server firstWithKey:@"name" value:[result valueForKey:@"name"] inStore:dataStore];
                
                if (server == nil) {
                    server = [Server createInStore:dataStore];
                }
                
                server.name = [result valueForKey:@"name"];
                server.id = [result valueForKey:@"id"] == 0 ? nil : [result valueForKey:@"id"];
                
                NSDictionary *visibility = [[result objectForKey:@"showOn"] objectAtIndex:0];
                server.onAbyss = BOX_BOOL([[visibility valueForKey:@"onAbyss"] boolValue]);
                server.onSearch = BOX_BOOL([[visibility valueForKey:@"onSearch"] boolValue]);
            }
            
            for (Server *server in [dataStore allForEntity:@"Server" error:nil]) {
                if (!server.onAbyss && !server.onSearch) {
                    [dataStore removeEntity:server];
                }
            }
            
            [dataStore save];
            
            if([completedOperation isCachedResponse]) {
                //             DLog(@"Data from cache %@", [completedOperation responseJSON]);
            }
            else {
                //             DLog(@"Data from server %@", [completedOperation responseString]);
            }
        }
        completionBlock();
    }
                    onError:^(NSError *error) 
    {
        errorBlock(error);
        DLog(@"%@", error)
    }];
    
    return operation;
}

- (MKNetworkOperation *)getServerStatus:(ServerStatusBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    MKNetworkOperation *operation = [self operationWithPath:@"aionstatus/serverStatus"
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *responseResultsDictionary = [completedOperation responseJSON];
         if (responseResultsDictionary) {
             
             
             if([completedOperation isCachedResponse]) {
                 //             DLog(@"Data from cache %@", [completedOperation responseJSON]);
             }
             else {
                 //             DLog(@"Data from server %@", [completedOperation responseString]);
             }
         }
         completionBlock(responseResultsDictionary);
     }
                    onError:^(NSError *error) 
     {
         errorBlock(error);
         DLog(@"%@", error)
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

- (MKNetworkOperation *)getAlerts:(AlertsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    MKNetworkOperation *operation = [self operationWithPath:@"aionstatus/as2alerts"
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *responseResultsDictionary = [completedOperation responseJSON];
         if (responseResultsDictionary) {
             
             
             if([completedOperation isCachedResponse]) {
                 //             DLog(@"Data from cache %@", [completedOperation responseJSON]);
             }
             else {
                 //             DLog(@"Data from server %@", [completedOperation responseString]);
             }
         }
         [userDefaults setObject:responseResultsDictionary forKey:@"as2alerts"];

     }
                    onError:^(NSError *error)
     {
         errorBlock(error);
         DLog(@"%@", error)
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

@end
