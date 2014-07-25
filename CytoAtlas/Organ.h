//
//  Organ.h
//  CytoDb
//
//  Created by Bobby on 3/17/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Condition;

@interface Organ : NSManagedObject

@property (nonatomic, retain) NSString * organName;
@property (nonatomic, retain) NSSet *conditions;
@end

@interface Organ (CoreDataGeneratedAccessors)

- (void)addConditionsObject:(Condition *)value;
- (void)removeConditionsObject:(Condition *)value;
- (void)addConditions:(NSSet *)values;
- (void)removeConditions:(NSSet *)values;

@end
