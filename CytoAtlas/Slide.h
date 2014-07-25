//
//  Slide.h
//  CytoDb
//
//  Created by Bobby on 3/17/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Condition;

@interface Slide : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * slideImagePath;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * slideMag;
@property (nonatomic, retain) NSNumber * slideMark;
@property (nonatomic, retain) NSString * slideDescription;
@property (nonatomic, retain) NSNumber * slideOrder;
@property (nonatomic, retain) NSString * slideStain;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSString * slideName;
@property (nonatomic, retain) Condition *condition;

@end
