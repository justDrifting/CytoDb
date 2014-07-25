//
//  Features.h
//  CytoDb
//
//  Created by Bobby on 4/9/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Condition;

@interface Features : NSManagedObject

@property (nonatomic, retain) NSString * featureName;
@property (nonatomic, retain) NSString * featureDescription;
@property (nonatomic, retain) NSNumber * featureOrder;
@property (nonatomic, retain) Condition *condition;

@end
