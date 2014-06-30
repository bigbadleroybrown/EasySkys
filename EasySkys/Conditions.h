
//  Conditions.h
//  EasySkys
//
//  Created by Eugene Watson on 6/30/14.
//  Copyright (c) 2014 Eugene Watson. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

@interface Conditions : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *humidity;
@property (strong, nonatomic) NSNumber *temperature;
@property (strong, nonatomic) NSNumber *highTemp;
@property (strong, nonatomic) NSNumber *lowTemp;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSDate *sunrise;
@property (strong, nonatomic) NSDate *sunset;
@property (strong, nonatomic) NSString *conditionDescription;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSNumber *windSpeed;
@property (strong, nonatomic) NSNumber *windBearing;
@property (strong, nonatomic) NSString *icon;

-(NSString *)imageName;



@end
