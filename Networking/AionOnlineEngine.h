//
//  AionOnlineEngine.h
//  Aion Status
//
//  Created by Thomas Hajcak Jr on 4/10/12.
//  Copyright (c) 2012 Simple Ink All rights reserved.
//

#import "MKNetworkEngine.h"

@interface AionOnlineEngine : MKNetworkEngine

typedef void (^CharacterSearchBlock)(NSArray *results);
typedef void (^LegionSearchBlock)(NSArray *results);

typedef void (^CharacterDetailsBlock)(NSDictionary *results);
typedef void (^LegionDetailsBlock)(NSDictionary *results);
typedef void (^EquipmentDetailsBlock)(NSDictionary *results);

typedef void (^CountsDetailsBlock)(NSDictionary *results);

typedef void (^PvPOwnershipBlock)(NSDictionary *results);
typedef void (^PvPStatsBlock)(NSDictionary *results);

typedef void (^FacebookBlock)(NSArray *results);
typedef void (^TwitterBlock)(NSArray *results);
typedef void (^CommunityBlock)(NSArray *results);

- (MKNetworkOperation *)searchForCharacterNamed:(NSString *)characterName onServer:(NSInteger)serverId onCompletion:(CharacterSearchBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;
- (MKNetworkOperation *)searchForLegionNamed:(NSString *)legionName onServer:(NSInteger)serverId onCompletion:(LegionSearchBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;

- (MKNetworkOperation *)detailsForCharacterId:(NSString *)characterId onServer:(NSInteger)serverId onCompletion:(CharacterDetailsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;
- (MKNetworkOperation *)detailsForLegionId:(NSString *)characterId onServer:(NSInteger)serverId onCompletion:(LegionDetailsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;
- (MKNetworkOperation *)equipmentInformationForCharacterId:(NSString *)characterId serverId:(NSString *)serverId nameId:(NSString *)nameId positionName:(NSString *)positionName onCompletion:(EquipmentDetailsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;

- (MKNetworkOperation *)countsForCharacterId:(NSString *)characterId onServer:(NSInteger)serverId onCompletion:(CountsDetailsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;

- (MKNetworkOperation *)pvpOwnershipInformation:(PvPOwnershipBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;
- (MKNetworkOperation *)pvpStats:(PvPStatsBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;

- (MKNetworkOperation *)getFacebookFeed:(FacebookBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;
- (MKNetworkOperation *)getTwitterFeed:(TwitterBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;
- (MKNetworkOperation *)getCommunityFeed:(CommunityBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;

@end
