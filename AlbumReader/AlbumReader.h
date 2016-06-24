//
//  AlbumReader.h
//  AlbumReaderDemo
//
//  Created by ervinchen on 16/6/23.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

// 由于管理 ALAssets 有内存问题，所以封装一下统一由 reader 管理
@interface AlbumReaderPhoto : NSObject
@end

typedef void (^AlbumReaderAuthorizedSuccessBlock)(ALAuthorizationStatus status);
typedef void (^AlbumReaderAuthorizedFailureBlock)(NSError *error);

typedef void (^AlbumReaderReadPhotosSuccessBlock)(NSArray* photos);
typedef void (^AlbumReaderReadPhotosFailureBlock)(NSError *error);

typedef NS_ENUM(NSInteger, AlbumReaderImageOption) {
    AlbumReaderImageOptionFullScreen,   // 全屏图， 默认
    AlbumReaderImageOptionOriginal,     // 原图
    AlbumReaderImageOptionThumbnail     // 缩略图
};

@interface AlbumReader : NSObject

+ (instancetype)reader;

/* 
 * 请求/查询授权，这里只能确定是否被拒绝
 * success: 成功回调，如果是未授权状态也算成功
 * failure: 失败回调，如果是拒绝或者没有权限就算失败
 */
- (void)requestAuthorization:(AlbumReaderAuthorizedSuccessBlock)success
                     failure:(AlbumReaderAuthorizedFailureBlock)failure;

/*
 * 读取照片
 * success: 成功回调，返回的是读取到的照片列表
 * failure: 失败回调，有可能是用户拒绝或者读取失败
 */
- (void)readPhotos:(AlbumReaderReadPhotosSuccessBlock)success
           failure:(AlbumReaderReadPhotosFailureBlock)failure;

- (void)imageOfPhoto:(AlbumReaderPhoto *)photo
              option:(AlbumReaderImageOption)option
             success:(void (^)(UIImage *image))success
             failure:(void (^)(NSError *))failure;

@end


