// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDRoute.m instead.

#import "_CDRoute.h"

@implementation CDRouteID
@end

@implementation _CDRoute

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDRoute" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDRoute";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDRoute" inManagedObjectContext:moc_];
}

- (CDRouteID*)objectID {
	return (CDRouteID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"endLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"endLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"folderIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"folderId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"fuelRangeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fuelRange"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lengthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"length"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"routeIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"routeIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sharingLevelValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sharingLevel"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"userIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"waypointCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"waypointCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic currentStyle;

@dynamic data;

@dynamic deletedAt;

@dynamic endAddress;

@dynamic endLatitude;

- (double)endLatitudeValue {
	NSNumber *result = [self endLatitude];
	return [result doubleValue];
}

- (void)setEndLatitudeValue:(double)value_ {
	[self setEndLatitude:@(value_)];
}

- (double)primitiveEndLatitudeValue {
	NSNumber *result = [self primitiveEndLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveEndLatitudeValue:(double)value_ {
	[self setPrimitiveEndLatitude:@(value_)];
}

@dynamic endLongitude;

- (double)endLongitudeValue {
	NSNumber *result = [self endLongitude];
	return [result doubleValue];
}

- (void)setEndLongitudeValue:(double)value_ {
	[self setEndLongitude:@(value_)];
}

- (double)primitiveEndLongitudeValue {
	NSNumber *result = [self primitiveEndLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveEndLongitudeValue:(double)value_ {
	[self setPrimitiveEndLongitude:@(value_)];
}

@dynamic folderId;

- (double)folderIdValue {
	NSNumber *result = [self folderId];
	return [result doubleValue];
}

- (void)setFolderIdValue:(double)value_ {
	[self setFolderId:@(value_)];
}

- (double)primitiveFolderIdValue {
	NSNumber *result = [self primitiveFolderId];
	return [result doubleValue];
}

- (void)setPrimitiveFolderIdValue:(double)value_ {
	[self setPrimitiveFolderId:@(value_)];
}

@dynamic fuelRange;

- (double)fuelRangeValue {
	NSNumber *result = [self fuelRange];
	return [result doubleValue];
}

- (void)setFuelRangeValue:(double)value_ {
	[self setFuelRange:@(value_)];
}

- (double)primitiveFuelRangeValue {
	NSNumber *result = [self primitiveFuelRange];
	return [result doubleValue];
}

- (void)setPrimitiveFuelRangeValue:(double)value_ {
	[self setPrimitiveFuelRange:@(value_)];
}

@dynamic length;

- (double)lengthValue {
	NSNumber *result = [self length];
	return [result doubleValue];
}

- (void)setLengthValue:(double)value_ {
	[self setLength:@(value_)];
}

- (double)primitiveLengthValue {
	NSNumber *result = [self primitiveLength];
	return [result doubleValue];
}

- (void)setPrimitiveLengthValue:(double)value_ {
	[self setPrimitiveLength:@(value_)];
}

@dynamic lock;

@dynamic name;

@dynamic routeDescription;

@dynamic routeIdentifier;

- (double)routeIdentifierValue {
	NSNumber *result = [self routeIdentifier];
	return [result doubleValue];
}

- (void)setRouteIdentifierValue:(double)value_ {
	[self setRouteIdentifier:@(value_)];
}

- (double)primitiveRouteIdentifierValue {
	NSNumber *result = [self primitiveRouteIdentifier];
	return [result doubleValue];
}

- (void)setPrimitiveRouteIdentifierValue:(double)value_ {
	[self setPrimitiveRouteIdentifier:@(value_)];
}

@dynamic sharingLevel;

- (double)sharingLevelValue {
	NSNumber *result = [self sharingLevel];
	return [result doubleValue];
}

- (void)setSharingLevelValue:(double)value_ {
	[self setSharingLevel:@(value_)];
}

- (double)primitiveSharingLevelValue {
	NSNumber *result = [self primitiveSharingLevel];
	return [result doubleValue];
}

- (void)setPrimitiveSharingLevelValue:(double)value_ {
	[self setPrimitiveSharingLevel:@(value_)];
}

@dynamic startAddress;

@dynamic startLatitude;

- (double)startLatitudeValue {
	NSNumber *result = [self startLatitude];
	return [result doubleValue];
}

- (void)setStartLatitudeValue:(double)value_ {
	[self setStartLatitude:@(value_)];
}

- (double)primitiveStartLatitudeValue {
	NSNumber *result = [self primitiveStartLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveStartLatitudeValue:(double)value_ {
	[self setPrimitiveStartLatitude:@(value_)];
}

@dynamic startLongitude;

- (double)startLongitudeValue {
	NSNumber *result = [self startLongitude];
	return [result doubleValue];
}

- (void)setStartLongitudeValue:(double)value_ {
	[self setStartLongitude:@(value_)];
}

- (double)primitiveStartLongitudeValue {
	NSNumber *result = [self primitiveStartLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveStartLongitudeValue:(double)value_ {
	[self setPrimitiveStartLongitude:@(value_)];
}

@dynamic token;

@dynamic units;

@dynamic updatedAt;

@dynamic userId;

- (double)userIdValue {
	NSNumber *result = [self userId];
	return [result doubleValue];
}

- (void)setUserIdValue:(double)value_ {
	[self setUserId:@(value_)];
}

- (double)primitiveUserIdValue {
	NSNumber *result = [self primitiveUserId];
	return [result doubleValue];
}

- (void)setPrimitiveUserIdValue:(double)value_ {
	[self setPrimitiveUserId:@(value_)];
}

@dynamic waypointCount;

- (double)waypointCountValue {
	NSNumber *result = [self waypointCount];
	return [result doubleValue];
}

- (void)setWaypointCountValue:(double)value_ {
	[self setWaypointCount:@(value_)];
}

- (double)primitiveWaypointCountValue {
	NSNumber *result = [self primitiveWaypointCount];
	return [result doubleValue];
}

- (void)setPrimitiveWaypointCountValue:(double)value_ {
	[self setPrimitiveWaypointCount:@(value_)];
}

@end

@implementation CDRouteAttributes 
+ (NSString *)currentStyle {
	return @"currentStyle";
}
+ (NSString *)data {
	return @"data";
}
+ (NSString *)deletedAt {
	return @"deletedAt";
}
+ (NSString *)endAddress {
	return @"endAddress";
}
+ (NSString *)endLatitude {
	return @"endLatitude";
}
+ (NSString *)endLongitude {
	return @"endLongitude";
}
+ (NSString *)folderId {
	return @"folderId";
}
+ (NSString *)fuelRange {
	return @"fuelRange";
}
+ (NSString *)length {
	return @"length";
}
+ (NSString *)lock {
	return @"lock";
}
+ (NSString *)name {
	return @"name";
}
+ (NSString *)routeDescription {
	return @"routeDescription";
}
+ (NSString *)routeIdentifier {
	return @"routeIdentifier";
}
+ (NSString *)sharingLevel {
	return @"sharingLevel";
}
+ (NSString *)startAddress {
	return @"startAddress";
}
+ (NSString *)startLatitude {
	return @"startLatitude";
}
+ (NSString *)startLongitude {
	return @"startLongitude";
}
+ (NSString *)token {
	return @"token";
}
+ (NSString *)units {
	return @"units";
}
+ (NSString *)updatedAt {
	return @"updatedAt";
}
+ (NSString *)userId {
	return @"userId";
}
+ (NSString *)waypointCount {
	return @"waypointCount";
}
@end

