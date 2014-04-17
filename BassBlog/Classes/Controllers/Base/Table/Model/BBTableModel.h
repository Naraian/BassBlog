//
//  BBTableModel.h
//  BassBlog
//
//  Created by Alexandr Zagorsky on 23.09.10.
//  Updated by Evgeny Sivko on 16.12.12.
//
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@interface BBTableModel : NSObject <NSMutableCopying>

#pragma mark - Cleanup

- (void)cleanup;

- (BOOL)isEmpty;

#pragma mark - Section

#pragma mark * info

- (NSInteger)numberOfSections;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfRowsInSectionID:(NSInteger)ID;

- (NSMutableArray *)cellKeysInSection:(NSInteger)section;
- (NSMutableArray *)cellKeysInSectionID:(NSInteger)ID;

- (NSInteger)sectionOfID:(NSInteger)ID;
- (NSInteger)IDOfSection:(NSInteger)section;

- (NSInteger)sectionIDAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark * management

- (void)removeSectionID:(NSInteger)ID;

- (void)moveSectionID:(NSInteger)ID toIndex:(NSInteger)index;

- (NSInteger)addSectionID:(NSInteger)ID;

- (NSInteger)insertSectionID:(NSInteger)ID atIndex:(NSInteger)index;

#pragma mark - Cell

#pragma mark * info

- (id)cellKeyAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)cellIDAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathOfCellKey:(id)key;
- (NSIndexPath *)indexPathOfCellID:(NSInteger)ID;

#pragma mark * management

- (NSIndexPath *)addCellKey:(id)key toSectionID:(NSInteger)sectionID;
- (NSIndexPath *)addCellID:(NSInteger)cellID toSectionID:(NSInteger)sectionID;

- (NSIndexPath *)insertCellKey:(id)key toSectionID:(NSInteger)sectionID atIndex:(NSInteger)index;
- (NSIndexPath *)insertCellID:(NSInteger)cellID toSectionID:(NSInteger)sectionID atIndex:(NSInteger)index;

- (NSIndexPath *)removeCellKey:(id)key;
- (NSIndexPath *)removeCellKey:(id)key fromSectionID:(NSInteger)sectionID;
- (NSIndexPath *)removeCellID:(NSInteger)cellID fromSectionID:(NSInteger)sectionID;

- (void)moveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

- (void)removeCellAtIndexPath:(NSIndexPath *)indexPath;

@end
