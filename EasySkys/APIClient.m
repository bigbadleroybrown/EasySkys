//
//  APIClient.m
//  EasySkys
//
//  Created by Eugene Watson on 6/30/14.
//  Copyright (c) 2014 Eugene Watson. All rights reserved.
//

#import "APIClient.h"
#import "Conditions.h"
#import "DailyForecast.h"

@interface APIClient ()

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation APIClient


//creating the NSURLSession

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@",url.absoluteString);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    [subscriber sendNext:json];
                }
                else {
                    [subscriber sendError:jsonError];
                }
            }
            else {
                [subscriber sendError:error];
            }
            
            [subscriber sendCompleted];
        }];
        
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        return [MTLJSONAdapter modelOfClass:[Conditions class] fromJSONDictionary:json error:nil];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[DailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        RACSequence *list = [json[@"list"] rac_sequence];
        
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[Conditions class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}


//-(RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
//{
//    //gets the object longitude and latitude
//    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial", coordinate.latitude, coordinate.longitude];
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
//        //turns JSON into a Conditions object
//        NSLog(@"%@", json);
//        return [MTLJSONAdapter modelOfClass:[Conditions class] fromJSONDictionary:json error:nil];
//    }];
//    
//}



//-(RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
//{
//    
//    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12", coordinate.latitude, coordinate.longitude];
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
//        RACSequence *list = [json[@"list"] rac_sequence];
//    
//        return [[list map:^(NSDictionary *item) {
//            //JSON into Conditions object
//            return [MTLJSONAdapter modelOfClass:[Conditions class] fromJSONDictionary:item error:nil];
//        }]array];
//    }];
//}


// @"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7"


//-(RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
//{
//    
//    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7", coordinate.latitude, coordinate.longitude];
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
//        RACSequence *list = [json[@"list"] rac_sequence];
//        
//        return [[list map:^(NSDictionary *item) {
//            return [MTLJSONAdapter modelOfClass:[DailyForecast class] fromJSONDictionary:item error:nil];
//        }]array];
//    }];
//}


//exact same call as above with different URL





@end
