//
//  AlbumReader.m
//  AlbumReaderDemo
//
//  Created by ervinchen on 16/6/23.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import "AlbumReader.h"

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

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    return _assetsLibrary;
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
    
    for (ALAssetsGroup* group in groups) {
        if (![group isKindOfClass:[ALAssetsGroup class]]) {
            continue;
        }
        
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            NSLog(@"%s %d result = %@, stop = %@", __FUNCTION__, __LINE__, result, @(*stop));
        }];
    }
}

- (void)readPhotos:(AlbumReaderReadPhotosSuccessBlock)success failure:(AlbumReaderReadPhotosFailureBlock)failure {
    self.readPhotosSuccessBlock = success;
    self.readPhotosFailureBlock = failure;
    
    NSMutableArray* groups = [[NSMutableArray alloc] init];
    void (^enumGroupBlock)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop) {
        NSLog(@"%s %d group = %@, stop = %@", __FUNCTION__, __LINE__, group, @(*stop));
        if (group) {
            [groups addObject:group];
        } else if (*stop) {
            [self _enumGroups:groups];
        } else if (failure) {
            NSError* error = [NSError errorWithDomain:kAlbumReaderErrorDomain
                                                 code:-1
                                             userInfo:@{@"msg": @"enumerateGroupsWithTypes fail"}];
            failure(error);
            *stop = YES;
        }
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:enumGroupBlock
                                    failureBlock:failure];
}

@end
