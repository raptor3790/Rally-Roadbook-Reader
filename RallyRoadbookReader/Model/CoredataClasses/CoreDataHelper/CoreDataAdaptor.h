//
//  CoreDataWrapper.h
//  NIPLiOSFramework
//
//  Created by C218 on 25/08/16.
//  Copyright © 2016 C218. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDRoute.h"
#import "CDRoutes.h"
#import "CDFolders.h"


@interface CoreDataAdaptor : NSObject

+ (void)SaveDataInCoreDB:(NSDictionary *)dict forEntity:(NSString *)entityname;
+ (void)deleteAllDataInCoreDB:(NSString *)entityname;
+ (void)deleteDataInCoreDB:(NSString *)entityname withCondition:(NSString *)condition;
+ (NSArray *)fetchAllRecordForEntityName:(NSString *)strEntityname;
+ (NSArray *)fetchAllRecordsForEntity:(NSString *)strEntityname withCondition:(NSString *)condition;

+ (NSArray *)fetchDataFromLocalDB:(NSString *)condition
                   sortDescriptor:(NSSortDescriptor*)sortDescriptor
                        forEntity:(NSString *)entityname;

+ (id)fetchData1FromLocalDB:(NSString *)condition
             sortDescriptor:(NSSortDescriptor*)sortDescriptor
                  forEntity:(NSString *)entityname;

+ (NSInteger)getCountOfSyncData:(NSString *)condition
                   sortDescriptor:(NSSortDescriptor*)sortDescriptor
                        forEntity:(NSString *)entityname;

+ (NSArray *)distinctValueFromEntity:(Class)entityClass
                       withPredicate:(NSPredicate *)predicate
                       attributeName:(NSString*)attributeName
                               error:(NSError **)error;

@end
