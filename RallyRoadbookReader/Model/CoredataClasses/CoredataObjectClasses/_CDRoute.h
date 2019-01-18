// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDRoute.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CDRouteID : NSManagedObjectID {}
@end

@interface _CDRoute : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDRouteID *objectID;

@property (nonatomic, strong, nullable) NSString* currentStyle;

@property (nonatomic, strong, nullable) NSString* data;

@property (nonatomic, strong, nullable) NSString* deletedAt;

@property (nonatomic, strong, nullable) NSString* endAddress;

@property (nonatomic, strong, nullable) NSNumber* endLatitude;

@property (atomic) double endLatitudeValue;
- (double)endLatitudeValue;
- (void)setEndLatitudeValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* endLongitude;

@property (atomic) double endLongitudeValue;
- (double)endLongitudeValue;
- (void)setEndLongitudeValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* folderId;

@property (atomic) double folderIdValue;
- (double)folderIdValue;
- (void)setFolderIdValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* fuelRange;

@property (atomic) double fuelRangeValue;
- (double)fuelRangeValue;
- (void)setFuelRangeValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* length;

@property (atomic) double lengthValue;
- (double)lengthValue;
- (void)setLengthValue:(double)value_;

@property (nonatomic, strong, nullable) NSString* lock;

@property (nonatomic, strong, nullable) NSString* name;

@property (nonatomic, strong, nullable) NSString* routeDescription;

@property (nonatomic, strong, nullable) NSNumber* routeIdentifier;

@property (atomic) double routeIdentifierValue;
- (double)routeIdentifierValue;
- (void)setRouteIdentifierValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* sharingLevel;

@property (atomic) double sharingLevelValue;
- (double)sharingLevelValue;
- (void)setSharingLevelValue:(double)value_;

@property (nonatomic, strong, nullable) NSString* startAddress;

@property (nonatomic, strong, nullable) NSNumber* startLatitude;

@property (atomic) double startLatitudeValue;
- (double)startLatitudeValue;
- (void)setStartLatitudeValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* startLongitude;

@property (atomic) double startLongitudeValue;
- (double)startLongitudeValue;
- (void)setStartLongitudeValue:(double)value_;

@property (nonatomic, strong, nullable) NSString* token;

@property (nonatomic, strong, nullable) NSString* units;

@property (nonatomic, strong, nullable) NSString* updatedAt;

@property (nonatomic, strong, nullable) NSNumber* userId;

@property (atomic) double userIdValue;
- (double)userIdValue;
- (void)setUserIdValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* waypointCount;

@property (atomic) double waypointCountValue;
- (double)waypointCountValue;
- (void)setWaypointCountValue:(double)value_;

@end

@interface _CDRoute (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveCurrentStyle;
- (void)setPrimitiveCurrentStyle:(nullable NSString*)value;

- (nullable NSString*)primitiveData;
- (void)setPrimitiveData:(nullable NSString*)value;

- (nullable NSString*)primitiveDeletedAt;
- (void)setPrimitiveDeletedAt:(nullable NSString*)value;

- (nullable NSString*)primitiveEndAddress;
- (void)setPrimitiveEndAddress:(nullable NSString*)value;

- (nullable NSNumber*)primitiveEndLatitude;
- (void)setPrimitiveEndLatitude:(nullable NSNumber*)value;

- (double)primitiveEndLatitudeValue;
- (void)setPrimitiveEndLatitudeValue:(double)value_;

- (nullable NSNumber*)primitiveEndLongitude;
- (void)setPrimitiveEndLongitude:(nullable NSNumber*)value;

- (double)primitiveEndLongitudeValue;
- (void)setPrimitiveEndLongitudeValue:(double)value_;

- (nullable NSNumber*)primitiveFolderId;
- (void)setPrimitiveFolderId:(nullable NSNumber*)value;

- (double)primitiveFolderIdValue;
- (void)setPrimitiveFolderIdValue:(double)value_;

- (nullable NSNumber*)primitiveFuelRange;
- (void)setPrimitiveFuelRange:(nullable NSNumber*)value;

- (double)primitiveFuelRangeValue;
- (void)setPrimitiveFuelRangeValue:(double)value_;

- (nullable NSNumber*)primitiveLength;
- (void)setPrimitiveLength:(nullable NSNumber*)value;

- (double)primitiveLengthValue;
- (void)setPrimitiveLengthValue:(double)value_;

- (nullable NSString*)primitiveLock;
- (void)setPrimitiveLock:(nullable NSString*)value;

- (nullable NSString*)primitiveName;
- (void)setPrimitiveName:(nullable NSString*)value;

- (nullable NSString*)primitiveRouteDescription;
- (void)setPrimitiveRouteDescription:(nullable NSString*)value;

- (nullable NSNumber*)primitiveRouteIdentifier;
- (void)setPrimitiveRouteIdentifier:(nullable NSNumber*)value;

- (double)primitiveRouteIdentifierValue;
- (void)setPrimitiveRouteIdentifierValue:(double)value_;

- (nullable NSNumber*)primitiveSharingLevel;
- (void)setPrimitiveSharingLevel:(nullable NSNumber*)value;

- (double)primitiveSharingLevelValue;
- (void)setPrimitiveSharingLevelValue:(double)value_;

- (nullable NSString*)primitiveStartAddress;
- (void)setPrimitiveStartAddress:(nullable NSString*)value;

- (nullable NSNumber*)primitiveStartLatitude;
- (void)setPrimitiveStartLatitude:(nullable NSNumber*)value;

- (double)primitiveStartLatitudeValue;
- (void)setPrimitiveStartLatitudeValue:(double)value_;

- (nullable NSNumber*)primitiveStartLongitude;
- (void)setPrimitiveStartLongitude:(nullable NSNumber*)value;

- (double)primitiveStartLongitudeValue;
- (void)setPrimitiveStartLongitudeValue:(double)value_;

- (nullable NSString*)primitiveToken;
- (void)setPrimitiveToken:(nullable NSString*)value;

- (nullable NSString*)primitiveUnits;
- (void)setPrimitiveUnits:(nullable NSString*)value;

- (nullable NSString*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(nullable NSString*)value;

- (nullable NSNumber*)primitiveUserId;
- (void)setPrimitiveUserId:(nullable NSNumber*)value;

- (double)primitiveUserIdValue;
- (void)setPrimitiveUserIdValue:(double)value_;

- (nullable NSNumber*)primitiveWaypointCount;
- (void)setPrimitiveWaypointCount:(nullable NSNumber*)value;

- (double)primitiveWaypointCountValue;
- (void)setPrimitiveWaypointCountValue:(double)value_;

@end

@interface CDRouteAttributes: NSObject 
+ (NSString *)currentStyle;
+ (NSString *)data;
+ (NSString *)deletedAt;
+ (NSString *)endAddress;
+ (NSString *)endLatitude;
+ (NSString *)endLongitude;
+ (NSString *)folderId;
+ (NSString *)fuelRange;
+ (NSString *)length;
+ (NSString *)lock;
+ (NSString *)name;
+ (NSString *)routeDescription;
+ (NSString *)routeIdentifier;
+ (NSString *)sharingLevel;
+ (NSString *)startAddress;
+ (NSString *)startLatitude;
+ (NSString *)startLongitude;
+ (NSString *)token;
+ (NSString *)units;
+ (NSString *)updatedAt;
+ (NSString *)userId;
+ (NSString *)waypointCount;
@end

NS_ASSUME_NONNULL_END
