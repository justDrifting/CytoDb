//
//  CDBImageTransformer.m
//  CytoBaseProto
//
//  Created by Bobby on 2/27/14.
//  Copyright (c) 2014 Rifter. All rights reserved.
//

#import "CDBImageTransformer.h"

@implementation CDBImageTransformer

+(Class)transformedValueClass
{
    return[NSData class];
}

//Checks if "value is image and if its PNG returns a data transformation
-(id)transformedValue:(id)value
{
    if(!value){return nil;}
    if([value isKindOfClass:[NSData class]]) { return value;}
   
    return  UIImageJPEGRepresentation(value, 1);

}


//Creates an image from supplied data
- (id)reverseTransformedValue:(id)value
{
    return [UIImage imageWithData:value];
}


@end
