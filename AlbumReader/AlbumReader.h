//
//  AlbumReader.h
//  AlbumReaderDemo
//
//  Created by ervinchen on 16/6/23.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^AlbumReaderAuthorizedSuccessBlock)(ALAuthorizationStatus status);
typedef void (^AlbumReaderAuthorizedFailureBlock)(NSError *error);

typedef void (^AlbumReaderReadPhotosSuccessBlock)(NSArray* photos);
typedef void (^AlbumReaderReadPhotosFailureBlock)(NSError *error);

@interface AlbumReader : NSObject

+ (instancetype)reader;

- (void)requestAuthorization:(AlbumReaderAuthorizedSuccessBlock)success
                     failure:(AlbumReaderAuthorizedFailureBlock)failure;

- (void)readPhotos:(AlbumReaderReadPhotosSuccessBlock)success
           failure:(AlbumReaderReadPhotosFailureBlock)failure;

@end
