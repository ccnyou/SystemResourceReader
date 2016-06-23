//
//  ViewController.m
//  LocationDemo
//
//  Created by ccnyou on 16/6/20.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import "ViewController.h"
#import "LocationReader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testLocationReader];
}

- (void)testLocationReader {
    LocationReader* reader = [LocationReader reader];
    [reader requestAuthorization:LocationReaderAuthorizationBoth success:^(CLAuthorizationStatus status) {
        [reader startUpdatingLocation:^(CLLocation *location) {
            NSLog(@"%s %d location = %@", __FUNCTION__, __LINE__, location);
            [reader stopUpdatingLocation];
        } failure:^(NSError *error) {
            NSLog(@"%s %d error = %@", __FUNCTION__, __LINE__, error);
        }];
    } failure:^(NSError *error) {
        NSLog(@"%s %d error = %@", __FUNCTION__, __LINE__, error);
    }];
    
    [[NSRunLoop mainRunLoop] run];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
