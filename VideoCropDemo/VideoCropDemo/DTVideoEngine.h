//
//  DTVideoEngine.h
//  Vmei
//
//  Created by DT on 16/1/19.
//  Copyright © 2016年 com.vmei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCRecorder.h"

/*!
 *  @author DT
 *
 *  @brief 视频操作引擎
 */
@interface DTVideoEngine : NSObject

/*!
 *  @author DT
 *
 *  @brief 根据视频url获取视频对象
 *
 *  @param url 视频url
 *
 *  @return 视频对象
 */
+(AVURLAsset*)getUrlAsset:(NSURL*)url;

/*!
 *  @author DT
 *
 *  @brief 消除声音
 */
+(void)removeVolume:(NSURL*)url item:(AVPlayerItem*)item;

/*!
 *  @author DT
 *
 *  @brief 恢复声音
 */
+(void)recoverVolume:(NSURL*)url item:(AVPlayerItem*)item;

/*!
 *  @author DT
 *
 *  @brief 创建视频播放界面
 *
 *  @param url     视频url
 *  @param superview 父类
 *  @param isPlay    是否播放
 *
 *  @return SCPlayer对象
 */
+(SCPlayer*)createVideo:(NSURL*)url superView:(UIView*)superview isPlay:(BOOL)isPlay;

/*!
 *  @author DT
 *
 *  @brief 创建视频播放界面
 *
 *  @param url     视频url
 *  @param superview 父类
 *  @param frame    
 *
 *  @return SCPlayer对象
 */
+(SCPlayer*)createVideo:(NSURL*)url superView:(UIView*)superview frame:(CGRect)frame;

/*!
 *  @author DT
 *
 *  @brief 获取视频总时长
 *
 *  @param url 视频url
 *
 *  @return 时长
 */
+(int64_t)getTotalDurationWithVideo:(NSURL*)url;

/*!
 *  @author DT
 *
 *  @brief 获取视频总帧数
 *
 *  @param url 视频url
 *
 *  @return 时长
 */
+(int64_t)getTotalFramesWithVideo:(NSURL*)url;

/*!
 *  @author DT
 *
 *  @brief 获取视频每秒帧数
 *
 *  @param url 视频url
 *
 *  @return 时长
 */
+(int32_t)getTotalTimescaleWithVideo:(NSURL*)url;

/*!
 *  @author DT
 *
 *  @brief 获取视频方向(角度)
 *
 *  @param url 视频url
 *
 *  @return <#return value description#>
 */
+ (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url;

/*!
 *  @author DT
 *
 *  @brief 获取视频分辨率
 *
 *  @param url 视频url
 *
 *  @return 分辨率大小
 */
+(CGSize)getResolutionWithVideo:(NSURL*)url;

/*!
 *  @author DT
 *
 *  @brief 获取视频指定时间的缩略图集合
 *
 *  @param url          视频url
 *  @param maximumSize  获取图片的size
 *  @param startTime    开始时间
 *  @param durationTime 结束时间
 *  @param block        UIImage对象集合
 */
+(void)thumbnailImagesForVideo:(NSURL *)url maximumSize:(CGSize)maximumSize startTime:(CMTime)startTime durationTime:(CMTime)durationTime block:(void(^)(NSArray *results)) block;

/*!
 *  @author DT
 *
 *  @brief 获取视频缩略图
 *
 *  @param url 视频url
 *  @param maximumSize  获取图片的size
 *  @param actualTime  CMTime时间
 *
 *  @return UIImage对象
 */
+(UIImage*)thumbnailImageForVideo:(NSURL *)url maximumSize:(CGSize)maximumSize actualTime:(CMTime)time;

/*!
 *  @author DT
 *
 *  @brief 视频裁剪
 *
 *  @param url        视频url
 *  @param renderSize 视频大小
 *  @param transform  偏移量
 *  @param block      新的url
 */
+(void)CropVideoSquare:(NSURL*)url renderSize:(CGSize)renderSize transform:(CGAffineTransform)transform block:(void(^)(NSString *resultUrl,BOOL status)) block;

/*!
 *  @author DT
 *
 *  @brief 视频裁剪
 *
 *  @param url        视频url
 *  @param timeRange  裁剪时间
 *  @param block      新的url
 */
+(void)CropVideoSquare:(NSURL*)url timeRange:(CMTimeRange)timeRange block:(void(^)(NSString *resultUrl,BOOL status)) block;

@end
