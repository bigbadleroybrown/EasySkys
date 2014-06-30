//
//  APIClient.h
//  EasySkys
//
//  Created by Eugene Watson on 6/30/14.
//  Copyright (c) 2014 Eugene Watson. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface APIClient : NSObject

-(RACSignal *)fetchJSONFromURL :(NSURL *)url;
-(RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
-(RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
-(RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
