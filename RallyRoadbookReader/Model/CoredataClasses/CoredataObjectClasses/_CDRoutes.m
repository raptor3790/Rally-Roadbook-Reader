// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDRoutes.m instead.

#import "_CDRoutes.h"

@implementation CDRoutesID
@end

@implementation _CDRoutes

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDRoutes" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDRoutes";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDRoutes" inManagedObjectContext:moc_];
}

- (CDRoutesID*)objectID {
	return (CDRoutesID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"editableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"editable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"folderIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"folderId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lengthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"length"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"routesIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"routesIdentifier"];
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

@dynamic crossCountryHighlightPdf;

@dynamic editable;

- (int64_t)editableValue {
	NSNumber *result = [self editable];
	return [result longLongValue];
}

- (void)setEditableValue:(int64_t)value_ {
	[self setEditable:@(value_)];
}

- (int64_t)primitiveEditableValue {
	NSNumber *result = [self primitiveEditable];
	return [result longLongValue];
}

- (void)setPrimitiveEditableValue:(int64_t)value_ {
	[self setPrimitiveEditable:@(value_)];
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

@dynamic highlightRoadRally;

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

@dynamic name;

@dynamic pdf;

@dynamic roadRallyPdf;

@dynamic routesIdentifier;

- (double)routesIdentifierValue {
	NSNumber *result = [self routesIdentifier];
	return [result doubleValue];
}

- (void)setRoutesIdentifierValue:(double)value_ {
	[self setRoutesIdentifier:@(value_)];
}

- (double)primitiveRoutesIdentifierValue {
	NSNumber *result = [self primitiveRoutesIdentifier];
	return [result doubleValue];
}

- (void)setPrimitiveRoutesIdentifierValue:(double)value_ {
	[self setPrimitiveRoutesIdentifier:@(value_)];
}

@dynamic units;

@dynamic updatedAt;

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

@implementation CDRoutesAttributes 
+ (NSString *)crossCountryHighlightPdf {
	return @"crossCountryHighlightPdf";
}
+ (NSString *)editable {
	return @"editable";
}
+ (NSString *)folderId {
	return @"folderId";
}
+ (NSString *)highlightRoadRally {
	return @"highlightRoadRally";
}
+ (NSString *)length {
	return @"length";
}
+ (NSString *)name {
	return @"name";
}
+ (NSString *)pdf {
	return @"pdf";
}
+ (NSString *)roadRallyPdf {
	return @"roadRallyPdf";
}
+ (NSString *)routesIdentifier {
	return @"routesIdentifier";
}
+ (NSString *)units {
	return @"units";
}
+ (NSString *)updatedAt {
	return @"updatedAt";
}
+ (NSString *)waypointCount {
	return @"waypointCount";
}
@end

