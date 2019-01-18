// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDRoutes.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CDRoutesID : NSManagedObjectID {}
@end

@interface _CDRoutes : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDRoutesID *objectID;

@property (nonatomic, strong, nullable) NSString* crossCountryHighlightPdf;

@property (nonatomic, strong, nullable) NSNumber* editable;

@property (atomic) int64_t editableValue;
- (int64_t)editableValue;
- (void)setEditableValue:(int64_t)value_;

@property (nonatomic, strong, nullable) NSNumber* folderId;

@property (atomic) double folderIdValue;
- (double)folderIdValue;
- (void)setFolderIdValue:(double)value_;

@property (nonatomic, strong, nullable) NSString* highlightRoadRally;

@property (nonatomic, strong, nullable) NSNumber* length;

@property (atomic) double lengthValue;
- (double)lengthValue;
- (void)setLengthValue:(double)value_;

@property (nonatomic, strong, nullable) NSString* name;

@property (nonatomic, strong, nullable) NSString* pdf;

@property (nonatomic, strong, nullable) NSString* roadRallyPdf;

@property (nonatomic, strong, nullable) NSNumber* routesIdentifier;

@property (atomic) double routesIdentifierValue;
- (double)routesIdentifierValue;
- (void)setRoutesIdentifierValue:(double)value_;

@property (nonatomic, strong, nullable) NSString* type;

@property (nonatomic, strong, nullable) NSString* units;

@property (nonatomic, strong, nullable) NSString* updatedAt;

@property (nonatomic, strong, nullable) NSNumber* waypointCount;

@property (atomic) double waypointCountValue;
- (double)waypointCountValue;
- (void)setWaypointCountValue:(double)value_;

@end

@interface _CDRoutes (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveCrossCountryHighlightPdf;
- (void)setPrimitiveCrossCountryHighlightPdf:(nullable NSString*)value;

- (nullable NSNumber*)primitiveEditable;
- (void)setPrimitiveEditable:(nullable NSNumber*)value;

- (int64_t)primitiveEditableValue;
- (void)setPrimitiveEditableValue:(int64_t)value_;

- (nullable NSNumber*)primitiveFolderId;
- (void)setPrimitiveFolderId:(nullable NSNumber*)value;

- (double)primitiveFolderIdValue;
- (void)setPrimitiveFolderIdValue:(double)value_;

- (nullable NSString*)primitiveHighlightRoadRally;
- (void)setPrimitiveHighlightRoadRally:(nullable NSString*)value;

- (nullable NSNumber*)primitiveLength;
- (void)setPrimitiveLength:(nullable NSNumber*)value;

- (double)primitiveLengthValue;
- (void)setPrimitiveLengthValue:(double)value_;

- (nullable NSString*)primitiveName;
- (void)setPrimitiveName:(nullable NSString*)value;

- (nullable NSString*)primitivePdf;
- (void)setPrimitivePdf:(nullable NSString*)value;

- (nullable NSString*)primitiveRoadRallyPdf;
- (void)setPrimitiveRoadRallyPdf:(nullable NSString*)value;

- (nullable NSNumber*)primitiveRoutesIdentifier;
- (void)setPrimitiveRoutesIdentifier:(nullable NSNumber*)value;

- (double)primitiveRoutesIdentifierValue;
- (void)setPrimitiveRoutesIdentifierValue:(double)value_;

- (nullable NSString*)primitiveUnits;
- (void)setPrimitiveUnits:(nullable NSString*)value;

- (nullable NSString*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(nullable NSString*)value;

- (nullable NSNumber*)primitiveWaypointCount;
- (void)setPrimitiveWaypointCount:(nullable NSNumber*)value;

- (double)primitiveWaypointCountValue;
- (void)setPrimitiveWaypointCountValue:(double)value_;

@end

@interface CDRoutesAttributes: NSObject 
+ (NSString *)crossCountryHighlightPdf;
+ (NSString *)editable;
+ (NSString *)folderId;
+ (NSString *)highlightRoadRally;
+ (NSString *)length;
+ (NSString *)name;
+ (NSString *)pdf;
+ (NSString *)roadRallyPdf;
+ (NSString *)routesIdentifier;
+ (NSString *)type;
+ (NSString *)units;
+ (NSString *)updatedAt;
+ (NSString *)waypointCount;
@end

NS_ASSUME_NONNULL_END
