//
//  Condition.h
//  CytoDb
//
//  Created by Bobby on 3/17/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Organ, Slide;

@interface Condition : NSManagedObject

@property (nonatomic, retain) NSString * conditionName;
@property (nonatomic, retain) NSString * conditionDescription;
@property (nonatomic, retain) NSString * conditionDifferentialGroup;
@property (nonatomic, retain) Organ *organ;
@property (nonatomic, retain) NSSet *slides;
@end

@interface Condition (CoreDataGeneratedAccessors)

- (void)addSlidesObject:(Slide *)value;
- (void)removeSlidesObject:(Slide *)value;
- (void)addSlides:(NSSet *)values;
- (void)removeSlides:(NSSet *)values;

@end
