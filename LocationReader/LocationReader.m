//
//  LocationReader.m
//
//  Created by ccnyou on 16/3/1.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import "LocationReader.h"
#import <UIKit/UIKit.h>

@interface LocationReader () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager* manager;
@property (nonatomic, strong) LocationReaderAuthorizedSuccessBlock authorizedSuccessBlock;
@property (nonatomic, strong) LocationReaderAuthorizedFailureBlock authorizedFailureBlock;
@property (nonatomic, strong) LocationReaderUpdateSuccessBlock updateSuccessBlock;
@property (nonatomic, strong) LocationReaderUpdateFailureBlock updateFailureBlock;
@end

@implementation LocationReader

+ (instancetype)reader {
    static LocationReader* sharedInstance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedInstance = [[LocationReader alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    _manager.desiredAccuracy = kCLLocationAccuracyBest;
    _manager.distanceFilter = 0;
    
    return self;
}

- (void)requestAuthorization:(LocationReaderAuthorization)authorization
                     success:(LocationReaderAuthorizedSuccessBlock)success
                     failure:(LocationReaderAuthorizedFailureBlock)failure
{
    self.authorizedSuccessBlock = success;
    self.authorizedFailureBlock = failure;

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self _requestAuthorization:authorization];
    } else {
        [self _authorizedWithStatus:status];
    }
}

- (void)_requestAuthorization:(LocationReaderAuthorization)authorization {
    if (authorization == LocationReaderAuthorizationBoth
        || authorization == LocationReaderAuthorizationAlways) {
        if ([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.manager requestAlwaysAuthorization];
        }
    }
    
    if (authorization == LocationReaderAuthorizationBoth
        || authorization == LocationReaderAuthorizationWhenInUse) {
        if ([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.manager requestWhenInUseAuthorization];
        }
    }
}

- (void)startUpdatingLocation:(LocationReaderUpdateSuccessBlock)success
                      failure:(LocationReaderUpdateFailureBlock)failure
{
    self.updateSuccessBlock = success;
    self.updateFailureBlock = failure;
    
    [self.manager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [self.manager stopUpdatingLocation];
}

// 根据经纬度反向得出位置城市信息
- (void)queryLocationCity:(CLLocation *)location
                  success:(void (^)(NSString *city))successBlock
                  failure:(void (^)(NSError *eror))failureBlock
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *currentCity = placeMark.locality;
            if (successBlock) {
                successBlock(currentCity);
            }
        } else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
}

#pragma mark - Private

- (void)_authorizedWithStatus:(CLAuthorizationStatus)status {
    if (status <= kCLAuthorizationStatusDenied) {
        if (self.authorizedFailureBlock) {
            NSError* error = [NSError errorWithDomain:@"com.error.locationreader"
                                                 code:-1
                                             userInfo:@{@"CLAuthorizationStatus": @(status)}];
            self.authorizedFailureBlock(error);
            self.authorizedFailureBlock = nil;
        }
    } else {
        if (self.authorizedSuccessBlock) {
            self.authorizedSuccessBlock(status);
            self.authorizedSuccessBlock = nil;
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    UIDevice* device = [UIDevice currentDevice];
    CGFloat systemVersion = [[device systemVersion] floatValue];
    if (systemVersion >= 8.0) {
        [self _authorizedWithStatus:status];
    } else {
        if (self.authorizedSuccessBlock) {
            self.authorizedSuccessBlock(status);
            self.authorizedSuccessBlock = nil;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation* location = [locations lastObject];
    if (![location isKindOfClass:[CLLocation class]]) {
        return;
    }
    
    if (self.updateSuccessBlock) {
        self.updateSuccessBlock(location);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.updateFailureBlock) {
        self.updateFailureBlock(error);
    }
}

@end
