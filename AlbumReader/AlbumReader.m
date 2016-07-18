//
//  AlbumReader.m
//  AlbumReaderDemo
//
//  Created by ervinchen on 16/6/23.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import "AlbumReader.h"
#import <CommonCrypto/CommonDigest.h>

@interface AlbumReaderPhoto ()

@property (nonatomic, readonly) NSURL* url;

- (instancetype)initWithUrl:(NSURL *)url;

@end


@interface AlbumReader ()

@property (nonatomic, strong) ALAssetsLibrary* assetsLibrary;
@property (nonatomic,   copy) AlbumReaderReadPhotosSuccessBlock readPhotosSuccessBlock;
@property (nonatomic,   copy) AlbumReaderReadPhotosFailureBlock readPhotosFailureBlock;

@end

@implementation AlbumReader

static NSString* const kAlbumReaderErrorDomain = @"com.albumreader.error";

+ (instancetype)reader {
    return [[AlbumReader alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _initMembers];
    }
    
    return self;
}

- (void)requestAuthorization:(AlbumReaderAuthorizedSuccessBlock)success
                     failure:(AlbumReaderAuthorizedFailureBlock)failure
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        if (success) {
            success(status);
        }
    } else if (status == ALAuthorizationStatusAuthorized) {
        if (success) {
            success(status);
        }
    } else {
        if (failure) {
            NSError* error = [NSError errorWithDomain:kAlbumReaderErrorDomain
                                                 code:-1
                                             userInfo:@{@"status": @(status)}];
            failure(error);
        }
    }
}

- (void)readPhotos:(AlbumReaderReadPhotosSuccessBlock)success failure:(AlbumReaderReadPhotosFailureBlock)failure {
    self.readPhotosSuccessBlock = success;
    self.readPhotosFailureBlock = failure;
    
    NSMutableArray* groups = [[NSMutableArray alloc] init];
    void (^enumGroupBlock)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [groups addObject:group];
        } else {
            [self _enumGroups:groups];
        }
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:enumGroupBlock
                                    failureBlock:failure];
}

- (void)imageOfPhoto:(AlbumReaderPhoto *)photo
              option:(AlbumReaderImageOption)option
             success:(void (^)(UIImage *image))success
             failure:(void (^)(NSError *))failure
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ALAssetsLibrary* assetsLibrary = self.assetsLibrary;
        [assetsLibrary assetForURL:photo.url resultBlock:^(ALAsset *asset) {
            UIImage* image = nil;
            CGImageRef imageRef = NULL;
            if (option == AlbumReaderImageOptionFullScreen) {
                ALAssetRepresentation* presentation = [asset defaultRepresentation];
                imageRef = [presentation fullScreenImage];
                image = [UIImage imageWithCGImage:imageRef];
            } else if (option == AlbumReaderImageOptionOriginal) {
                ALAssetRepresentation* presentation = [asset defaultRepresentation];
                imageRef = [presentation fullResolutionImage];
                image = [UIImage imageWithCGImage:imageRef];
            } else if (option == AlbumReaderImageOptionThumbnail) {
                imageRef = [asset thumbnail];
                image = [UIImage imageWithCGImage:imageRef];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(image);
            });
        } failureBlock:failure];
    });
}

#pragma mark - Private

- (void)_initMembers {
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
}

- (void)_addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_onMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

- (void)_removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_onMemoryWarning:(id)notification {
    NSLog(@"%s %d memory warning", __FUNCTION__, __LINE__);
}

- (void)_enumGroups:(NSArray *)groups {
    if (groups.count <= 0) {
        if (self.readPhotosFailureBlock) {
            NSError* error = [NSError errorWithDomain:kAlbumReaderErrorDomain
                                                 code:-1
                                             userInfo:@{@"msg": @"no group found"}];
            self.readPhotosFailureBlock(error);
        }
        
        return;
    }
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    for (ALAssetsGroup* group in groups) {
        if (![group isKindOfClass:[ALAssetsGroup class]]) {
            continue;
        }
        
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                NSURL* url = [[result defaultRepresentation] url];
                AlbumReaderPhoto* photo = [[AlbumReaderPhoto alloc] initWithUrl:url];
                [results addObject:photo];
            } else {
                if (self.readPhotosSuccessBlock) {
                    self.readPhotosSuccessBlock(results);
                    self.assetsLibrary = nil;
                }
            }
        }];
    }
}

@end

@implementation AlbumReaderPhoto

- (instancetype)initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
    }
    
    return self;
}

@end
