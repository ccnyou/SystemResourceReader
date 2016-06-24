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

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray* photos;
@property (nonatomic, strong) AlbumReader* reader;

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

- (void)_readPhotosSuccess:(NSArray *)photos {
    self.photos = photos;
    [self.collectionView reloadData];
}

- (IBAction)_onTestTouched:(id)sender {
    self.reader = [AlbumReader reader];
    
    id failure = ^(NSError *error) {
        NSLog(@"%s %d error = %@", __FUNCTION__, __LINE__, error);
    };
    
    id success = ^(ALAuthorizationStatus status) {
        [self.reader readPhotos:^(NSArray *photos) {
            [self _readPhotosSuccess:photos];
        } failure:failure];
    };
    
    [self.reader requestAuthorization:success failure:failure];
}

#pragma mark - UIColloectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(200, CGRectGetHeight(collectionView.frame));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TestCell" forIndexPath:indexPath];
    UIImageView* imageView = [cell viewWithTag:1000];
    id photo = [self.photos objectAtIndex:indexPath.row];
    [self.reader imageOfPhoto:photo option:AlbumReaderImageOptionFullScreen success:^(UIImage *image) {
        imageView.image = image;
    } failure:^(NSError *error) {
        NSLog(@"%s %d error = %@", __FUNCTION__, __LINE__, error);
    }];
    
    return cell;
}

@end
