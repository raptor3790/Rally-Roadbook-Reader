// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDFolders.m instead.

#import "_CDFolders.h"

@implementation CDFoldersID
@end

@implementation _CDFolders

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDFolders" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDFolders";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDFolders" inManagedObjectContext:moc_];
}

- (CDFoldersID*)objectID {
	return (CDFoldersID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"foldersIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"foldersIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"parentIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"parentId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"routesCountsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"routesCounts"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"subfoldersCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"subfoldersCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic folderName;

@dynamic folderType;

@dynamic foldersIdentifier;

- (double)foldersIdentifierValue {
	NSNumber *result = [self foldersIdentifier];
	return [result doubleValue];
}

- (void)setFoldersIdentifierValue:(double)value_ {
	[self setFoldersIdentifier:@(value_)];
}

- (double)primitiveFoldersIdentifierValue {
	NSNumber *result = [self primitiveFoldersIdentifier];
	return [result doubleValue];
}

- (void)setPrimitiveFoldersIdentifierValue:(double)value_ {
	[self setPrimitiveFoldersIdentifier:@(value_)];
}

@dynamic parentId;

- (double)parentIdValue {
	NSNumber *result = [self parentId];
	return [result doubleValue];
}

- (void)setParentIdValue:(double)value_ {
	[self setParentId:@(value_)];
}

- (double)primitiveParentIdValue {
	NSNumber *result = [self primitiveParentId];
	return [result doubleValue];
}

- (void)setPrimitiveParentIdValue:(double)value_ {
	[self setPrimitiveParentId:@(value_)];
}

@dynamic routesCounts;

- (double)routesCountsValue {
	NSNumber *result = [self routesCounts];
	return [result doubleValue];
}

- (void)setRoutesCountsValue:(double)value_ {
	[self setRoutesCounts:@(value_)];
}

- (double)primitiveRoutesCountsValue {
	NSNumber *result = [self primitiveRoutesCounts];
	return [result doubleValue];
}

- (void)setPrimitiveRoutesCountsValue:(double)value_ {
	[self setPrimitiveRoutesCounts:@(value_)];
}

@dynamic subfoldersCount;

- (double)subfoldersCountValue {
	NSNumber *result = [self subfoldersCount];
	return [result doubleValue];
}

- (void)setSubfoldersCountValue:(double)value_ {
	[self setSubfoldersCount:@(value_)];
}

- (double)primitiveSubfoldersCountValue {
	NSNumber *result = [self primitiveSubfoldersCount];
	return [result doubleValue];
}

- (void)setPrimitiveSubfoldersCountValue:(double)value_ {
	[self setPrimitiveSubfoldersCount:@(value_)];
}

@end

@implementation CDFoldersAttributes 
+ (NSString *)folderName {
	return @"folderName";
}
+ (NSString *)folderType {
	return @"folderType";
}
+ (NSString *)foldersIdentifier {
	return @"foldersIdentifier";
}
+ (NSString *)parentId {
	return @"parentId";
}
+ (NSString *)routesCounts {
	return @"routesCounts";
}
+ (NSString *)subfoldersCount {
	return @"subfoldersCount";
}
@end

