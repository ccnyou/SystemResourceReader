//
//  LocationReader.h
//
//  Created by ccnyou on 16/3/1.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^LocationReaderAuthorizedSuccessBlock)(CLAuthorizationStatus status);
typedef void (^LocationReaderAuthorizedFailureBlock)(NSError *error);

typedef void (^LocationReaderUpdateSuccessBlock)(CLLocation *location);
typedef void (^LocationReaderUpdateFailureBlock)(NSError *error);

typedef NS_ENUM(NSInteger, LocationReaderAuthorization) {
    LocationReaderAuthorizationBoth,
    LocationReaderAuthorizationWhenInUse,
    LocationReaderAuthorizationAlways
};

@interface LocationReader : NSObject

+ (instancetype)reader;

- (void)requestAuthorization:(LocationReaderAuthorization)authorization
                     success:(LocationReaderAuthorizedSuccessBlock)success
                     failure:(LocationReaderAuthorizedFailureBlock)failure;

- (void)startUpdatingLocation:(LocationReaderUpdateSuccessBlock)success
                      failure:(LocationReaderUpdateFailureBlock)failure;

- (void)stopUpdatingLocation;

@end
