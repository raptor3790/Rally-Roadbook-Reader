// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDFolders.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CDFoldersID : NSManagedObjectID {}
@end

@interface _CDFolders : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDFoldersID *objectID;

@property (nonatomic, strong, nullable) NSString* folderName;

@property (nonatomic, strong, nullable) NSString* folderType;

@property (nonatomic, strong, nullable) NSNumber* foldersIdentifier;

@property (atomic) double foldersIdentifierValue;
- (double)foldersIdentifierValue;
- (void)setFoldersIdentifierValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* parentId;

@property (atomic) double parentIdValue;
- (double)parentIdValue;
- (void)setParentIdValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* routesCounts;

@property (atomic) double routesCountsValue;
- (double)routesCountsValue;
- (void)setRoutesCountsValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* subfoldersCount;

@property (atomic) double subfoldersCountValue;
- (double)subfoldersCountValue;
- (void)setSubfoldersCountValue:(double)value_;

@end

@interface _CDFolders (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveFolderName;
- (void)setPrimitiveFolderName:(nullable NSString*)value;

- (nullable NSString*)primitiveFolderType;
- (void)setPrimitiveFolderType:(nullable NSString*)value;

- (nullable NSNumber*)primitiveFoldersIdentifier;
- (void)setPrimitiveFoldersIdentifier:(nullable NSNumber*)value;

- (double)primitiveFoldersIdentifierValue;
- (void)setPrimitiveFoldersIdentifierValue:(double)value_;

- (nullable NSNumber*)primitiveParentId;
- (void)setPrimitiveParentId:(nullable NSNumber*)value;

- (double)primitiveParentIdValue;
- (void)setPrimitiveParentIdValue:(double)value_;

- (nullable NSNumber*)primitiveRoutesCounts;
- (void)setPrimitiveRoutesCounts:(nullable NSNumber*)value;

- (double)primitiveRoutesCountsValue;
- (void)setPrimitiveRoutesCountsValue:(double)value_;

- (nullable NSNumber*)primitiveSubfoldersCount;
- (void)setPrimitiveSubfoldersCount:(nullable NSNumber*)value;

- (double)primitiveSubfoldersCountValue;
- (void)setPrimitiveSubfoldersCountValue:(double)value_;

@end

@interface CDFoldersAttributes: NSObject 
+ (NSString *)folderName;
+ (NSString *)folderType;
+ (NSString *)foldersIdentifier;
+ (NSString *)parentId;
+ (NSString *)routesCounts;
+ (NSString *)subfoldersCount;
@end

NS_ASSUME_NONNULL_END
