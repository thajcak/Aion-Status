//
//  AionOnlineEngine.m
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/10/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "AionOnlineEngine.h"

#import "Server.h"

@implementation AionOnlineEngine

- (NSString *)cacheDirectoryName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:@"AionOnlineData"];
    return cacheDirectoryName;
}

#pragma mark - Character Search

- (MKNetworkOperation *)searchForCharacterNamed:(NSString *)characterName onServer:(NSInteger)serverId onCompletion:(CharacterSearchBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    NSString *path;
    
    if (serverId == 0) {
        path = [NSString stringWithFormat:@"/webservice/jsonSearch?query=%@&perPage=20&collection=character", characterName];
    }
    else {
        path = [NSString stringWithFormat:@"/webservice/jsonSearch?query=%@&perPage=20&collection=character&serverID=%i", characterName, serverId];
    }
    
    MKNetworkOperation *operation = [self operationWithPath:path
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSArray *responseResultsArray = [[completedOperation responseJSON] valueForKey:@"resultArray"];
         if (responseResultsArray) {
             NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[responseResultsArray count]];
             
             for (NSDictionary *result in responseResultsArray) {
                 NSMutableDictionary *newResult = [NSMutableDictionary dictionaryWithDictionary:result];
                 NSString *updatedName = [NSString stringWithFormat:@" %@", 
                                          [newResult valueForKey:@"name"]];
                 [newResult setValue:updatedName forKey:@"name"];
                 [results addObject:newResult];
             }
             
             if([completedOperation isCachedResponse]) {
                 //             DLog(@"Data from cache %@", [completedOperation responseJSON]);
             }
             else {
                 //             DLog(@"Data from server %@", [completedOperation responseString]);
             }
             
             completionBlock(results);
         } else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
         
     }
                    onError:^(NSError* error)
     {
         
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

- (MKNetworkOperation *)searchForLegionNamed:(NSString *)legionName onServer:(NSInteger)serverId onCompletion:(LegionSearchBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    NSString *path;
    
    if (serverId == 0) {
        path = [NSString stringWithFormat:@"/webservice/jsonSearch?query=%@&perPage=20&collection=legion", legionName];
    }
    else {
        path = [NSString stringWithFormat:@"/webservice/jsonSearch?query=%@&perPage=20&collection=legion&serverID=%i", legionName, serverId];
    }
    
    MKNetworkOperation *operation = [self operationWithPath:path
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSArray *responseResultsArray = [[[completedOperation responseJSON] objectForKey:@"Shoes"] objectForKey:@"Document"];
         if (responseResultsArray) {
             NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[responseResultsArray count]];
             
             for (NSDictionary *result in responseResultsArray) {
                 NSMutableDictionary *newResult = [NSMutableDictionary dictionaryWithDictionary:result];
                 NSString *updatedName = [NSString stringWithFormat:@" %@", 
                                          [newResult valueForKey:@"name"]];
                 [newResult setValue:updatedName forKey:@"name"];
                 [results addObject:newResult];
             }
             
             if([completedOperation isCachedResponse]) {
                 //             DLog(@"Data from cache %@", [completedOperation responseJSON]);
             }
             else {
                 //             DLog(@"Data from server %@", [completedOperation responseString]);
             }
             
             completionBlock(results);
         } else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
         
     }
                    onError:^(NSError* error)
     {
         
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

#pragma mark - Search Details

- (MKNetworkOperation *)detailsForCharacterId:(NSString *)characterId onServer:(NSInteger)serverId onCompletion:(CharacterDetailsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    NSString *path = [NSString stringWithFormat:@"/webservice/jsonCharacterLookup?characterID=%@&serverID=%i", characterId, serverId];
    
    MKNetworkOperation *operation = [self operationWithPath:path params:nil httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
//         NSLog(@"Response\n%@", [completedOperation responseJSON]);
         NSDictionary *responseDictionary = [completedOperation responseJSON];
         if (responseDictionary) {
             
             if([completedOperation isCachedResponse]) {
                 //             DLog(@"Data from cache %@", [completedOperation responseJSON]);
             }
             else {
                 //             DLog(@"Data from server %@", [completedOperation responseString]);
             }
             
             completionBlock(responseDictionary);
         } else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
         
     }
                    onError:^(NSError* error)
     {
         
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

- (MKNetworkOperation *)detailsForLegionId:(NSString *)legionId onServer:(NSInteger)serverId onCompletion:(LegionDetailsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    NSString *path = [NSString stringWithFormat:@"/webservice/jsonLegionDetails?guildID=%@&serverID=%i", legionId, serverId];
    
    MKNetworkOperation *operation = [self operationWithPath:path params:nil httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionaryWithDictionary:[completedOperation responseJSON]];
         
         NSMutableDictionary *membersDictionary = [[NSMutableDictionary alloc] init];
         
         for (NSDictionary *memberInformation in [responseDictionary objectForKey:@"memberList"]) {
             NSString *rankName = [memberInformation valueForKey:@"rankName"];
             
             NSMutableArray *rankArray = [membersDictionary objectForKey:rankName];
             if (nil == rankArray) {
                 rankArray = [[NSMutableArray alloc] init];
             }
             [rankArray addObject:memberInformation];
             
             [membersDictionary setObject:rankArray forKey:rankName];
         }
         
         [responseDictionary setObject:membersDictionary forKey:@"memberList"];
         
         if (responseDictionary) {
             
             if([completedOperation isCachedResponse]) {
                 //             DLog(@"Data from cache %@", [completedOperation responseJSON]);
             }
             else {
                 //             DLog(@"Data from server %@", [completedOperation responseString]);
             }
             
             completionBlock(responseDictionary);
         } else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
         
     }
                    onError:^(NSError* error)
     {
         
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

- (MKNetworkOperation *)equipmentInformationForCharacterId:(NSString *)characterId serverId:(NSString *)serverId nameId:(NSString *)nameId positionName:(NSString *)positionName onCompletion:(EquipmentDetailsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    NSString *path = [NSString stringWithFormat:@"/webservice/jsonEquippedItemLookup?charID=%@&serverID=%@&nameID=%@&position=%@", characterId, serverId, nameId, positionName];
    
    MKNetworkOperation *operation = [self operationWithPath:path params:nil httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *responseDictionary = [completedOperation responseJSON];
         if (responseDictionary) {
             responseDictionary = [responseDictionary objectForKey:@"item"];
             NSMutableDictionary *resultsDictionary = [[NSMutableDictionary alloc] init];
             
             for (NSString *dictionaryKey in [responseDictionary allKeys]) {
                 id sectionData = [responseDictionary objectForKey:dictionaryKey];
                 
                 NSMutableDictionary *sectionDictionary = [[NSMutableDictionary alloc] init];
                 
                 if ([sectionData isKindOfClass:[NSDictionary class]]) {
                     sectionData = [sectionData objectForKey:@"property"];
                     
                     if ([sectionData isKindOfClass:[NSArray class]]) {
                         for (NSDictionary *thisDictionary in sectionData) {
                             [sectionDictionary setValue:[thisDictionary valueForKey:@"value"] forKey:[thisDictionary valueForKey:@"key"]];
                         }
                         
                         // Reformat Data
                         // impossibleProperty formatting
                         if ([sectionDictionary valueForKey:@"impossibleProperty"]) {
                             NSArray *impossibleArray = [[sectionDictionary valueForKey:@"impossibleProperty"] componentsSeparatedByString:@","];
                             
                             NSInteger counter = 0;
                             for (NSString *impossibleValue in impossibleArray) {
                                 [sectionDictionary setValue:impossibleValue forKey:[NSString stringWithFormat:@"impossibleProperty_%i", counter]];
                                 counter++;
                             }
                         }
                         
                         // attack formatting
                         if ([sectionDictionary valueForKey:@"Minimum Attack"] && [sectionDictionary valueForKey:@"Maximum Attack"]) {
                             NSString *minAttack = [sectionDictionary valueForKey:@"Minimum Attack"];
                             NSString *maxAttack = [sectionDictionary valueForKey:@"Maximum Attack"];
                             NSString *enchantAttack = [sectionDictionary valueForKey:@"enchant_physical attack power"];
                             NSString *subAttack = [sectionDictionary valueForKey:@"sub_Physical Attack"];
                             
                             NSString *valueString = [NSString stringWithFormat:@"%@ - %@", minAttack, maxAttack];
                             if (enchantAttack.length > 0) {
                                 valueString = [valueString stringByAppendingFormat:@" (+%@)", enchantAttack];
                             }
                             if (subAttack.length > 0) {
                                 valueString = [valueString stringByAppendingFormat:@" (+%@)", subAttack];
                             }
                             
                             [sectionDictionary setValue:valueString forKey:@"Attack"];
                             [sectionDictionary removeObjectForKey:@"Minimum Attack"];
                             [sectionDictionary removeObjectForKey:@"Maximum Attack"];
                             [sectionDictionary removeObjectForKey:@"enchant_physical attack power"];
                             [sectionDictionary removeObjectForKey:@"sub_Physical Attack"];
                         }
                         
                         // magic boost formatting
                         if ([sectionDictionary valueForKey:@"Magic Boost"]) {
                             NSString *valueString = [sectionDictionary valueForKey:@"Magic Boost"];
                             NSString *enchantString = [sectionDictionary valueForKey:@"enchant_Magic Boost"];
                             NSString *subString = [sectionDictionary valueForKey:@"sub_Magic Boost"];
                             
                             if (enchantString.length > 0) {
                                 valueString = [valueString stringByAppendingFormat:@" (+%@)", enchantString];
                             }
                             if (subString.length > 0) {
                                 valueString = [valueString stringByAppendingFormat:@" (+%@)", subString];
                             }
                             
                             [sectionDictionary setValue:valueString forKey:@"Magic Boost"];
                             [sectionDictionary removeObjectForKey:@"enchant_Magic Boost"];
                             [sectionDictionary removeObjectForKey:@"sub_Magic Boost"];
                         }
                         
                         // physical defense
                         if ([sectionDictionary valueForKey:@"Physical Defense"]) {
                             NSString *valueString = [sectionDictionary valueForKey:@"Physical Defense"];
                             NSString *enchantString = [sectionDictionary valueForKey:@"enchant_Physical Defense"];
                             
                             if (enchantString.length > 0) {
                                 valueString = [valueString stringByAppendingFormat:@" (+%@)", enchantString];
                             }
                             
                             [sectionDictionary setValue:valueString forKey:@"Physical Defense"];
                             [sectionDictionary removeObjectForKey:@"enchant_Physical Defense"];
                         }
                         
                         // damage reduction
                         if ([sectionDictionary valueForKey:@"Damage Reduction"]) {
                             NSString *valueString = [sectionDictionary valueForKey:@"Damage Reduction"];
                             NSString *enchantString = [sectionDictionary valueForKey:@"enchant_Damage Reduction"];
                             
                             if (enchantString.length > 0) {
                                 valueString = [valueString stringByAppendingFormat:@" (+%@)", enchantString];
                             }
                             
                             [sectionDictionary setValue:valueString forKey:@"Damage Reduction"];
                             [sectionDictionary removeObjectForKey:@"enchant_Damage Reduction"];
                         }
                         
//                         NSLog(@"%@\n%@", dictionaryKey, sectionDictionary);
                     }
                     else if (sectionData != nil) {
                         [sectionDictionary setValue:[sectionData valueForKey:@"value"] forKey:[sectionData valueForKey:@"key"]];
                     }
                     
                     if ([dictionaryKey isEqualToString:@"set_effect"]) {
                         NSLog(@"Section Data\n%@", sectionData);
                         for (NSDictionary *itemSet in sectionData) {
                             NSLog(@"Item Set\n%@", itemSet);
                             
                             NSArray *valuesArray = [(NSString *)[itemSet valueForKey:@"value"] componentsSeparatedByString:@","];
                             NSLog(@"Bonuses\n%@", valuesArray);
                             
                             NSMutableDictionary *valuesDictionary = [[NSMutableDictionary alloc] init];
                             for (NSString *bonuses in [(NSString *)[itemSet valueForKey:@"value"] componentsSeparatedByString:@","]) {
                                 NSArray *bonusesArray = [bonuses componentsSeparatedByString:@"="];
                                 [valuesDictionary setValue:[bonusesArray objectAtIndex:1] forKey:[bonusesArray objectAtIndex:0]];
                             }
                             
//                             NSDictionary *bonusesDictionary = [[NSDictionary alloc] init];
                             [resultsDictionary setValue:valuesDictionary forKey:[NSString stringWithFormat:@"set_effect_%@", [itemSet valueForKey:@"key"]]];
                             
                         }
                     }
                     
                     [resultsDictionary setObject:sectionDictionary forKey:dictionaryKey];
                 }
                 else if (sectionData != nil) {
                     [resultsDictionary setObject:sectionData forKey:dictionaryKey];
                 }   
             }
             
             if ([completedOperation isCachedResponse]) {
                 
             }
             else {
                 
             }
             
             completionBlock(resultsDictionary);
         }
         else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
     }
                    onError:^(NSError *error)
     {
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

#pragma mark - Character Data

- (MKNetworkOperation *)countsForCharacterId:(NSString *)characterId onServer:(NSInteger)serverId onCompletion:(CountsDetailsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    NSString *path = [NSString stringWithFormat:@"/webservice/jsonCharacterItemCounts?serverID=%i&charID=%@", serverId, characterId];
    
    MKNetworkOperation *operation = [self operationWithPath:path params:nil httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *responseDictionary = [completedOperation responseJSON];
         if (responseDictionary) {
             
             if([completedOperation isCachedResponse]) {
                 //             DLog(@"Data from cache %@", [completedOperation responseJSON]);
             }
             else {
                 //             DLog(@"Data from server %@", [completedOperation responseString]);
             }
             
             completionBlock(responseDictionary);
         } else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
         
     }
                    onError:^(NSError* error)
     {
         
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

#pragma mark - Abyss

- (MKNetworkOperation *)pvpOwnershipInformation:(PvPOwnershipBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    CoreDataStore *dataStore = [CoreDataStore createStore];
    Server *selectedServer = [Server firstWithKey:@"isSelectedPvP" value:BOX_BOOL(YES) inStore:dataStore];
    
    MKNetworkOperation *operation = [self operationWithPath:[NSString stringWithFormat:@"/webservice/jsonGameServerAbyssStatus?serverID=%i", [selectedServer.id integerValue]]
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *pvpInformation = [[[completedOperation responseJSON] valueForKey:@"updateLayer"] valueForKey:@"World"];
         if (pvpInformation) {
             NSArray *fortresses = [pvpInformation valueForKey:@"Abyss"];
             NSMutableDictionary *fortressesDictionary = [[NSMutableDictionary alloc] init];
             for (NSDictionary *fortress in fortresses) {
                 if ([[fortress valueForKey:@"legion"] isKindOfClass:[NSDictionary class]]) {
                     NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithDictionary:fortress];
                     [tempDictionary setValue:@"" forKey:@"legion"];
                     [fortressesDictionary setObject:tempDictionary forKey:[fortress valueForKey:@"id"]];
                 } else {
                     [fortressesDictionary setObject:fortress forKey:[fortress valueForKey:@"id"]];
                 }
             }
             
             NSArray *artifacts = [pvpInformation valueForKey:@"Artifact"];
             NSMutableDictionary *artifactsDictionary = [[NSMutableDictionary alloc] init];
             for (NSDictionary *artifact in artifacts) {
                 if ([[artifact valueForKey:@"legion"] isKindOfClass:[NSDictionary class]]) {
                     NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithDictionary:artifact];
                     [tempDictionary setValue:@"" forKey:@"legion"];
                     [artifactsDictionary setObject:tempDictionary forKey:[artifact valueForKey:@"id"]];
                 } else {
                     [artifactsDictionary setObject:artifact forKey:[artifact valueForKey:@"id"]];
                 }
             }
             
             NSArray *resultsArray = [NSArray arrayWithObjects:fortressesDictionary, artifactsDictionary, nil];
             NSArray *resultsKeys = [NSArray arrayWithObjects:@"Fortresses", @"Artifacts", nil];
             NSDictionary *results = [NSDictionary dictionaryWithObjects:resultsArray forKeys:resultsKeys];
             
             completionBlock(results);
         } else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
         
     }
                    onError:^(NSError* error)
     {
         
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

- (MKNetworkOperation *)pvpStats:(PvPStatsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    MKNetworkOperation *operation = [self operationWithPath:[NSString stringWithFormat:@"/webservice/xmlGameServerAbyssRank"]
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation
     onCompletion:^(MKNetworkOperation *completedOperation) {
         RXMLElement *rootXML = [RXMLElement elementFromXMLData:[completedOperation responseData]];
         
         if (rootXML) {
             NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
             [rootXML iterate:@"gameServerList.gameServer" usingBlock:^(RXMLElement *server) {
                 NSDictionary *serverDictionary = [[NSMutableDictionary alloc] init];
                 
                 RXMLElement *control = [server child:@"controlPercent"];
                 [serverDictionary setValue:[control child:@"elyos"].text forKey:@"controlElyos"];
                 [serverDictionary setValue:[control child:@"balaur"].text forKey:@"controlBalaur"];
                 [serverDictionary setValue:[control child:@"asmodian"].text forKey:@"controlAsmodian"];
                 
                 RXMLElement *inflation = [server child:@"inflationPercent"];
                 [serverDictionary setValue:[inflation child:@"elyos"].text forKey:@"inflationElyos"];
                 [serverDictionary setValue:[inflation child:@"asmodian"].text forKey:@"inflationAsmodian"];
                 
                 RXMLElement *tax = [server child:@"taxPercent"];
                 [serverDictionary setValue:[tax child:@"elyos"].text forKey:@"taxElyos"];
                 [serverDictionary setValue:[tax child:@"asmodian"].text forKey:@"taxAsmodian"];
                 
                 [response setObject:serverDictionary forKey:[server child:@"serverName"].text];
             }];
             
             completionBlock(response);
         } else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
         
     }
                    onError:^(NSError* error)
     {
         
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

#pragma mark - Social

- (MKNetworkOperation *)getFacebookFeed:(FacebookBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    MKNetworkOperation *operation = [self operationWithPath:[NSString stringWithFormat:@"/webservice/jsonSocialNetworkFeeds?feed=facebook"]
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation 
     onCompletion:^(MKNetworkOperation *completedOperation) {
         NSArray *response = [[completedOperation responseJSON] valueForKey:@"facebookposts"];
         if (response) {
             NSMutableArray *filteredResponse = [NSMutableArray array];
             for (NSDictionary *thisPost in response) {
                 if (![[thisPost valueForKey:@"type"] isEqualToString:@"Photo"]) {
                     [filteredResponse addObject:thisPost];
                 }
             }
             
             completionBlock(filteredResponse);
         }
         else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
     }
     onError:^(NSError *error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return  operation;
}

- (MKNetworkOperation *)getTwitterFeed:(TwitterBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    MKNetworkOperation *operation = [self operationWithPath:[NSString stringWithFormat:@"/webservice/jsonSocialNetworkFeeds?feed=twitter"]
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation 
     onCompletion:^(MKNetworkOperation *completedOperation) {
         NSArray *response = [[completedOperation responseJSON] valueForKey:@"twitteruserstimeline"];
         if (response) {
             completionBlock(response);
         }
         else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             return;
         }
     }
     onError:^(NSError *error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return  operation;
}

- (MKNetworkOperation *)getCommunityFeed:(CommunityBlock)completionBlock onError:(MKNKErrorBlock)errorBlock
{
    MKNetworkOperation *operation = [self operationWithPath:[NSString stringWithFormat:@"/rss"]
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [operation
     onCompletion:^(MKNetworkOperation *completedOperation) {
         RXMLElement *rootXML = [RXMLElement elementFromXMLData:[completedOperation responseData]];
         
         if (rootXML) {
             NSMutableArray *response = [[NSMutableArray alloc] init];

             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd"];
             
             [rootXML iterate:@"entry" usingBlock:^(RXMLElement *entry) {
                 NSMutableArray *objectArray = [[NSMutableArray alloc] init];
                 NSMutableArray *keyArray = [[NSMutableArray alloc] init];
                 
                 [objectArray addObject:[entry child:@"title"].text];
                 [keyArray addObject:@"title"];
                 
                 [objectArray addObject:[entry child:@"summary"].text];
                 [keyArray addObject:@"summary"];
                 
                 if ([entry child:@"author"]) {
                     [objectArray addObject:[entry child:@"author"].text];
                     [keyArray addObject:@"author"];
                 }
                 
                 [objectArray addObject:[[entry child:@"category"] attribute:@"term"]];
                 [keyArray addObject:@"category"];
                 
                 [objectArray addObject:[entry child:@"content"].text];
                 [keyArray addObject:@"content"];
                 
                 NSString *dateString = [entry child:@"updated"].text;
                 dateString = [dateString stringByReplacingCharactersInRange:NSMakeRange(10, dateString.length-10) withString:@""];
                 [objectArray addObject:[dateFormatter dateFromString:dateString]];
                 [keyArray addObject:@"updated"];
                 
                 [objectArray addObject:[[entry child:@"link"] attribute:@"href"]];
                 [keyArray addObject:@"link"];
                 
                 NSDictionary *entryDictionary = [NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray];
                 [response addObject:entryDictionary];
             }];
             
             completionBlock(response);
         }
         else {
             NSString *responseString = [completedOperation responseString];
             if ([responseString contains:@"This site is temporarily unavailable due to scheduled maintenance"]) {
                 NSDictionary *errorDetails = [NSMutableDictionary dictionary];
                 [errorDetails setValue:@"Aion Online website is temporarily unavailable due to scheduled maintenance." 
                                 forKey:NSLocalizedDescriptionKey];
                 NSError *error = [[NSError alloc] initWithDomain:@"Maintenance"
                                                             code:100
                                                         userInfo:errorDetails];
                 errorBlock(error);
             }
             else {
                 
             }
             return;
         }
     }
     onError:^(NSError *error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:operation];
    
    return operation;
}

@end
