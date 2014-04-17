//
//  BBTableModel.m
//  BassBlog
//
//  Created by Alexandr Zagorsky on 23.09.10.
//  Updated by Evgeny Sivko on 16.12.12.
//
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTableModel.h"


@interface BBTableModel ()

@property (nonatomic, strong) NSMutableDictionary *sectionIDToCellsArrayDictionary;
@property (nonatomic, strong) NSMutableArray *sectionIDsArray;

@property (nonatomic, strong) NSMutableDictionary *cellKeyToSectionIDDeleteDictionary;
@property (nonatomic, assign) BOOL isFlushing;

@end

@implementation BBTableModel

#warning TODO: use default properties...

@synthesize sectionIDToCellsArrayDictionary;
@synthesize sectionIDsArray;
@synthesize cellKeyToSectionIDDeleteDictionary;
@synthesize isFlushing;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        sectionIDsArray = [NSMutableArray new];
        sectionIDToCellsArrayDictionary = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    
    BBTableModel *tableModel = [[[self class] allocWithZone:zone] init];
    
    NSMutableDictionary *dictionary =
    [NSMutableDictionary dictionaryWithCapacity:self.sectionIDToCellsArrayDictionary.count];
    
    [self.sectionIDToCellsArrayDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [dictionary setObject:[obj mutableCopy] forKey:key];
    }];
    
    tableModel.sectionIDToCellsArrayDictionary = dictionary;
    
    tableModel.sectionIDsArray = [self.sectionIDsArray mutableCopy];
    
    tableModel.cellKeyToSectionIDDeleteDictionary = [self.cellKeyToSectionIDDeleteDictionary mutableCopy];
    
    tableModel.isFlushing = self.isFlushing;
    
    return tableModel;
}

#pragma mark - Cleanup

- (void)cleanup
{
	[sectionIDToCellsArrayDictionary removeAllObjects];
    [sectionIDsArray removeAllObjects];
    
    cellKeyToSectionIDDeleteDictionary = nil;
}

- (BOOL)isEmpty
{
    return ![self numberOfSections]
        || ![self numberOfRowsInSection:0];
}

#pragma mark - Section

#pragma mark * info

- (NSInteger)numberOfSections
{
	return sectionIDsArray.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	return [self numberOfRowsInSectionID:[self IDOfSection:section]];
}

- (NSInteger)numberOfRowsInSectionID:(NSInteger)ID
{	
	return [self cellKeysInSectionID:ID].count;
}

- (NSMutableArray *)cellKeysInSection:(NSInteger)section
{
    return [self cellKeysInSectionID:[self IDOfSection:section]];
}

- (NSMutableArray *)cellKeysInSectionID:(NSInteger)ID
{
    NSNumber *numberID = [NSNumber numberWithInteger:ID];
    
    NSMutableArray *cellKeysArray =
    [sectionIDToCellsArrayDictionary objectForKey:numberID];
    
    if (cellKeyToSectionIDDeleteDictionary.count)
	{
		isFlushing = YES;
		
		[cellKeyToSectionIDDeleteDictionary enumerateKeysAndObjectsUsingBlock:
         ^(id key, NSNumber *sectionIDNumber, BOOL *stop)
        {
            [self removeCellKey:key fromSectionID:[sectionIDNumber integerValue]];
        }];
        
        cellKeyToSectionIDDeleteDictionary = nil;
        
		isFlushing = NO;
	}
    
    return cellKeysArray;
}

- (NSInteger)sectionOfID:(NSInteger)ID
{
    return [sectionIDsArray indexOfObject:[NSNumber numberWithInteger:ID]];
}

- (NSInteger)IDOfSection:(NSInteger)section
{
	NSUInteger count = [self numberOfSections];
    if ((section < 0) || (section >= count))
    {
        ERR(@"\"section\" (%d) is out of bounds [0, %u)", section, count);
        
        return NSNotFound;
    }
    
    return [[sectionIDsArray objectAtIndex:section] integerValue];
}

- (NSInteger)sectionIDAtIndexPath:(NSIndexPath *)indexPath
{
	return [self IDOfSection:indexPath.section];
}

#pragma mark * management

- (void)removeSectionID:(NSInteger)ID
{
	if (sectionIDsArray.count)
    {
        NSNumber *numberID = [NSNumber numberWithInteger:ID];
        
        [sectionIDsArray removeObject:numberID];
        [sectionIDToCellsArrayDictionary removeObjectForKey:numberID];
    }
}

- (void)moveSectionID:(NSInteger)ID toIndex:(NSInteger)index
{
    NSInteger currentIndex = [self sectionOfID:ID];
    if ((currentIndex == index) || (currentIndex == NSNotFound))
    {
        return;
    }
    
    NSUInteger numberOfSections = [self numberOfSections];
    if (index < 0 || index >= numberOfSections)
    {
        ERR(@"\"index\" (%d) is out of bounds [0, %d)", index, numberOfSections);
        
        return;
    }
    
    [sectionIDsArray exchangeObjectAtIndex:currentIndex
                         withObjectAtIndex:index];
}

- (NSInteger)addSectionID:(NSInteger)ID
{
	NSNumber *numberID = [NSNumber numberWithInteger:ID];
	
	NSUInteger index = [sectionIDsArray indexOfObject:numberID];
	if (index == NSNotFound)
	{
		[sectionIDsArray addObject:numberID];
		index = sectionIDsArray.count - 1;
	}
	
	return index;
}

- (NSInteger)insertSectionID:(NSInteger)ID atIndex:(NSInteger)index
{
	NSInteger count = [self numberOfSections];
    if ((index < 0) || (index > count))
    {
        ERR(@"\"index\" (%d) is out of bounds [0, %d]", index, count);
        
        return NSNotFound;
    }
    
    NSNumber *numberID = [NSNumber numberWithInteger:ID];
    if ([sectionIDsArray indexOfObject:numberID] == NSNotFound)
    {
        [sectionIDsArray insertObject:numberID atIndex:index];
    }
	
	return index;
}

#pragma mark - Cell

#pragma mark * info

- (id)cellKeyAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section;
    NSUInteger count = sectionIDsArray.count;
    if (index >= count)
    {
        ERR(@"\"indexPath.section\" (%d) is out of bounds [0, %u]", index, count);
        
        return nil;
    }
    
    NSNumber *numberID = [sectionIDsArray objectAtIndex:index];
	if (!numberID)
    {
		return nil;
	}
    
	NSArray *sectionCellsArray =
    [sectionIDToCellsArrayDictionary objectForKey:numberID];
	
	index = indexPath.row;
    count = sectionCellsArray.count;
    if (index >= count)
    {
        ERR(@"\"indexPath.row\" (%d) is out of bounds [0, %u)", index, count);
    
        return nil;
    }
    
    return [sectionCellsArray objectAtIndex:index];
}

- (NSInteger)cellIDAtIndexPath:(NSIndexPath*)indexPath
{
    id object = [self cellKeyAtIndexPath:indexPath];
    
    return object ? [object integerValue] : NSNotFound;
}

- (NSIndexPath *)indexPathOfCellKey:(id)key
{
    __block NSIndexPath *result = nil;
	
    [sectionIDToCellsArrayDictionary enumerateKeysAndObjectsUsingBlock:
     ^(NSNumber *numberID, NSArray *cellsArray, BOOL *stop)
    {
        NSInteger index = [cellsArray indexOfObject:key];
        if (index != NSNotFound)
        {
            NSInteger section = [sectionIDsArray indexOfObject:numberID];
            result = [NSIndexPath indexPathForRow:index inSection:section];
            
            *stop = YES;
        }
    }];
    
	return result;
}

- (NSIndexPath *)indexPathOfCellID:(NSInteger)ID
{
	return [self indexPathOfCellKey:[NSNumber numberWithInteger:ID]];
}

#pragma mark * management

- (NSIndexPath *)addCellKey:(id)key toSectionID:(NSInteger)ID
{
	NSNumber* numberID = [NSNumber numberWithInteger:ID];
	
	if ([sectionIDsArray indexOfObject:numberID] == NSNotFound)
    {
		[self addSectionID:ID];
	}
    
	NSMutableArray *cellsArray =
    [sectionIDToCellsArrayDictionary objectForKey:numberID];
	
    if (cellsArray == nil)
	{
		cellsArray = [NSMutableArray arrayWithObject:key];
		
		[sectionIDToCellsArrayDictionary setObject:cellsArray forKey:numberID];
	}
	else if ([cellsArray indexOfObject:key] == NSNotFound)
	{
		[cellsArray addObject:key];
	}
	
	return [self indexPathOfCellKey:key];
}

- (NSIndexPath *)addCellID:(NSInteger)cellID toSectionID:(NSInteger)sectionID
{		
	NSNumber *numberCellID  = [NSNumber numberWithInteger:cellID];
    
    return [self addCellKey:numberCellID toSectionID:sectionID];
}

- (NSIndexPath *)insertCellKey:(id)key toSectionID:(NSInteger)ID atIndex:(NSInteger)index
{
    NSIndexPath *result = nil;
    
	if (!sectionIDToCellsArrayDictionary.count)
    {
        return result;
    }
    
    NSNumber *numberID  = [NSNumber numberWithInteger:ID];
    NSMutableArray *sectionCellsArray =
    [sectionIDToCellsArrayDictionary objectForKey:numberID];
    
    if (!sectionCellsArray)
    {
        return result;
    }
    
    NSUInteger count = sectionCellsArray.count;
    if ((index < 0) || (index > count))
    {
        ERR(@"index(%d) is out of bounds [0, %u]", index, count);
        
        return result;
    }
    
    if ([sectionCellsArray indexOfObject:key] == NSNotFound)
    {
        [sectionCellsArray insertObject:key atIndex:index];
        
        result = [self indexPathOfCellKey:key];
    }
	
	return result;
}

- (NSIndexPath *)insertCellID:(NSInteger)cellID toSectionID:(NSInteger)sectionID atIndex:(NSInteger)index
{	
	NSNumber *numberCellID = [NSNumber numberWithInteger:cellID];

	return [self insertCellKey:numberCellID toSectionID:sectionID atIndex:index];
}

- (NSIndexPath *)removeCellKey:(id)key {
    
    NSIndexPath *indexPath = [self indexPathOfCellKey:key];
    if (indexPath) {
        
        [self removeCellAtIndexPath:indexPath];
    }
    
    return indexPath;
}

- (NSIndexPath *)removeCellKey:(id)key fromSectionID:(NSInteger)ID
{
    NSIndexPath *result = nil;
	
	if (!sectionIDToCellsArrayDictionary.count)
	{
        return result;
    }
    
    NSNumber *numberID = [NSNumber numberWithInteger:ID];
    NSMutableArray *sectionCellsArray =
    [sectionIDToCellsArrayDictionary objectForKey:numberID];
    
    if (!sectionCellsArray)
    {
        return result;
    }
    
    result = [self indexPathOfCellKey:key];
    
    if (isFlushing)
    {
        [sectionCellsArray removeObject:key];
    }
    else if (result)
    {
        if (!cellKeyToSectionIDDeleteDictionary)
        {
            cellKeyToSectionIDDeleteDictionary = [NSMutableDictionary new];
        }
        
        [cellKeyToSectionIDDeleteDictionary setObject:numberID forKey:key];
    }
    
	return result;
}

- (NSIndexPath *)removeCellID:(NSInteger)cellID fromSectionID:(NSInteger)sectionID
{	
    NSNumber *numberCellID = [NSNumber numberWithInteger:cellID];
    
    return [self removeCellKey:numberCellID fromSectionID:sectionID];
}

-(void)moveCellAtIndexPath:(NSIndexPath*)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	id key = [self cellKeyAtIndexPath:indexPath];
	
	isFlushing = YES;
	[self removeCellAtIndexPath:indexPath];
	isFlushing = NO;
	
	NSInteger index = toIndexPath.row;
    NSInteger sectionID = [self sectionIDAtIndexPath:toIndexPath];
	
    [self insertCellKey:key toSectionID:sectionID atIndex:index];
}

-(void)removeCellAtIndexPath:(NSIndexPath*)indexPath
{
	id key = [self cellKeyAtIndexPath:indexPath];
	NSInteger sectionId = [self sectionIDAtIndexPath:indexPath];
	
	[self removeCellKey:key fromSectionID:sectionId];
}

@end
