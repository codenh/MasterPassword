//
//  MPElementEntities.h
//  MasterPassword-iOS
//
//  Created by Maarten Billemont on 31/05/12.
//  Copyright (c) 2012 Lyndir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPElementEntity.h"
#import "MPElementStoredEntity.h"
#import "MPElementGeneratedEntity.h"
#import "MPUserEntity.h"
#import "MPAlgorithm.h"

#define MPAvatarCount 19

@interface NSManagedObjectContext(MP)

- (BOOL)saveToStore;

@end

@interface MPElementEntity(MP)

@property(assign) MPElementType type;
@property(readonly) NSString *typeName;
@property(readonly) NSString *typeShortName;
@property(readonly) NSString *typeClassName;
@property(readonly) Class typeClass;
@property(assign) NSUInteger uses;
@property(assign) NSUInteger version;
@property(assign) BOOL requiresExplicitMigration;
@property(readonly) id<MPAlgorithm> algorithm;

- (NSUInteger)use;
- (BOOL)migrateExplicitly:(BOOL)explicit;
- (NSString *)resolveContentUsingKey:(MPKey *)key;
- (void)resolveContentUsingKey:(MPKey *)key result:(void (^)(NSString *))result;

@end

@interface MPElementGeneratedEntity(MP)

@property(assign) NSUInteger counter;

@end

@interface MPUserEntity(MP)

@property(assign) NSUInteger avatar;
@property(assign) BOOL saveKey;
@property(assign) MPElementType defaultType;
@property(readonly) NSString *userID;

+ (NSString *)idFor:(NSString *)userName;

@end
