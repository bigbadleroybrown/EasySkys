//
//  WeatherManager.h
//  
//
//  Created by Eugene Watson on 6/30/14.
//
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "Conditions.h"


@interface WeatherManager : NSObject
<CLLocationManagerDelegate>

+(instancetype)sharedManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) Conditions *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;


-(void)findCurrentLocation;

@end
