//
//  ViewController.m
//  AlbumReaderDemo
//
//  Created by ervinchen on 16/6/23.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import "ViewController.h"
#import "AlbumReader.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_onTestTouched:(id)sender {
    AlbumReader* reader = [AlbumReader reader];
    [reader requestAuthorization:^(ALAuthorizationStatus status) {
        [reader readPhotos:^(NSArray *photos) {
            
        } failure:^(NSError *error) {
            
        }];
    } failure:^(NSError *error) {
        NSLog(@"%s %d error = %@", __FUNCTION__, __LINE__, error);
    }];
}

#pragma mark - UIColloectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, CGRectGetHeight(collectionView.frame));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TestCell" forIndexPath:indexPath];
    return cell;
}

@end
