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

@property (strong, nonatomic, readonly) CLLocation *currentLocation;
@property (strong, nonatomic, readonly) Conditions *currentConditions;
@property (strong, nonatomic, readonly) NSArray *hourlyForecast;
@property (strong, nonatomic, readonly) NSArray *dailyForecast;

//will refresh the location or current weather
-(void)findCurrentLocation;

@end
