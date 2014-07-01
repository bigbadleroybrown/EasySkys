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

@property (nonatomic, strong, readwrite) Conditions *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) APIClient *client;

@end

@implementation WeatherManager


+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
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

- (id)init {
    if (self = [super init]) {

        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        

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
                                         subtitle:@"There was an error retrieving the current weather, please try again"
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    

    if (location.horizontalAccuracy > 0) {
        // 3
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(Conditions *condition) {
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}



@end
