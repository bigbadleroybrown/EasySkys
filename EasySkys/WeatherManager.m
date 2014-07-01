//
//  WeatherManager.m
//  
//
//  Created by Eugene Watson on 6/30/14.
//
//

#import "WeatherManager.h"
#import "APIClient.h"
#import <TSMessages/TSMessage.h>

@interface WeatherManager ()

@property (strong, nonatomic, readwrite) Conditions *updateCurrentConditions;
@property (strong, nonatomic, readwrite) CLLocation *currentLocation;
@property (strong, nonatomic, readwrite) NSArray *updateHourlyForecast;
@property (strong, nonatomic, readwrite) NSArray *updateDailyForecast;

@property (strong, nonatomic) CLLocationManager *manager;
@property (nonatomic, assign) BOOL *isFirstUpdate;
@property (strong, nonatomic) APIClient *client;

@end

@implementation WeatherManager


+(instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc]init];
    });
        
        return _sharedManager;
}


//-(id)init {
//    if (self = [super init]){
//        _manager = [[CLLocationManager alloc]init];
//        _manager.delegate = self;
//        _client = [[APIClient alloc] init];
//        
//        [[[[RACObserve(self, currentLocation)
//            ignore:nil]
//           
//           flattenMap:^(CLLocation *newLocation) {
//               return [RACSignal merge:@[[self updateCurrentConditions],
//                                         [self updateDailyForecast],
//                                         [self updateHourlyForecast]
//                                         ]];
//           }] deliverOn:RACScheduler.mainThreadScheduler]
//         
//         subscribeError:^(NSError *error) {
//             [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was an error retrieving the current weather, please try again" type:TSMessageNotificationTypeError];
//         }];
//    }
//    return  self;
//}

-(id)init {
    if (self = [super init]) {
        
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        
        _client = [[APIClient alloc] init];
        
        [[[[RACObserve(self, currentLocation)

            ignore:nil]

           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];

           }] deliverOn:RACScheduler.mainThreadScheduler]

         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

-(void)findCurrentLocation
{
    
    self.isFirstUpdate = YES;
    [self.manager startUpdatingLocation];
    
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    if (location.horizontalAccuracy > 0) {
        self.currentLocation = location;
        [self.manager stopUpdatingLocation];
    }
}

-(RACSignal *)updateCurrentConditions
{
    
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate]
            doNext:^(Conditions *condition) {
                self.updateCurrentConditions = condition;
            }];
}


-(RACSignal *)updateHourlyForecast
{
    
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions) {
                self.updateHourlyForecast = conditions;
            }];
}

-(RACSignal *)updateDailyForecast
{
    
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions) {
                self.updateDailyForecast = conditions;
            }];

}



@end
