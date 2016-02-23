//
//  DTVideoEngine.m
//  Vmei
//
//  Created by DT on 16/1/19.
//  Copyright © 2016年 com.vmei. All rights reserved.
//

#import "DTVideoEngine.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation DTVideoEngine

+(AVURLAsset*)getUrlAsset:(NSURL*)url {
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    return urlAsset;
}

+(CGFloat)getVolumeValue
{
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    
    return [mpc volume];
}

+(void)removeVolume:(NSURL*)url item:(AVPlayerItem*)item
{
    CGFloat value = [self getVolumeValue];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults){
        [standardUserDefaults setDouble:value forKey:@"volume_slider_value"];
        [standardUserDefaults synchronize];
    }
    
    AVURLAsset *urlAsset = [self getUrlAsset:url];
    NSArray *audioTracks = [urlAsset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    [item setAudioMix:audioMix];
}

+(void)recoverVolume:(NSURL*)url item:(AVPlayerItem*)item;
{
    CGFloat value = [self getVolumeValue];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        value = [standardUserDefaults doubleForKey:@"volume_slider_value"];
    }
    
    AVURLAsset *urlAsset = [self getUrlAsset:url];
    NSArray *audioTracks = [urlAsset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:value atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    [item setAudioMix:audioMix];
}


+(SCPlayer*)createVideo:(NSURL*)url superView:(UIView*)superview isPlay:(BOOL)isPlay {
    AVURLAsset *asset;
    if (url)
        asset = [self getUrlAsset:url];
    
    SCPlayer *player = [SCPlayer player];
    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:player];
    playerView.tag = 9999;
    playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerView.frame = superview.bounds;
    playerView.autoresizingMask = superview.autoresizingMask;
    [superview addSubview:playerView];
    player.loopEnabled = YES;
    
    [player setItemByAsset:asset];
    if (isPlay) {
        [player play];
    }
    return player;
}

+(SCPlayer*)createVideo:(NSURL*)url superView:(UIView*)superview frame:(CGRect)frame {
    SCPlayer *player = [self createVideo:url superView:superview isPlay:NO];
    SCVideoPlayerView *playerView = [superview viewWithTag:9999];
    playerView.frame = frame;
    [player play];
    return player;
}

+(int64_t)getTotalDurationWithVideo:(NSURL*)url {
    AVURLAsset *asset = [self getUrlAsset:url];
    //value为  总帧数，timescale为  fps
    return asset.duration.value / asset.duration.timescale; // 获取视频总时长,单位秒
}


+(int64_t)getTotalFramesWithVideo:(NSURL*)url {
    AVURLAsset *asset = [self getUrlAsset:url];
    return asset.duration.value;
}

+(int32_t)getTotalTimescaleWithVideo:(NSURL*)url {
    AVURLAsset *asset = [self getUrlAsset:url];
    return asset.duration.timescale;
}

+(CGSize)getResolutionWithVideo:(NSURL*)url {
    AVURLAsset *asset = [self getUrlAsset:url];
    //创建视频轨道信息
//    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    NSArray *arr = [asset tracksWithMediaType:@"vide"];
    if (![arr isAbsoluteValid]) {
        return CGSizeMake(0, 0);
    }
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:@"vide"] objectAtIndex:0];
    NSInteger degress = [DTVideoEngine degressFromVideoFileWithURL:url];
    CGSize size = CGSizeMake(clipVideoTrack.naturalSize.width, clipVideoTrack.naturalSize.height);
    if (degress == 90 || degress == 180) {
        size = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width);
    }
    return size;
}

+ (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url {
    NSUInteger degress = 0;
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

+(void)thumbnailImagesForVideo:(NSURL *)url maximumSize:(CGSize)maximumSize startTime:(CMTime)startTime durationTime:(CMTime)durationTime block:(void(^)(NSArray *results)) block {
    
    int64_t count = 7;
    int64_t start_value = startTime.value;
    int64_t end_value = durationTime.value + startTime.value;
    int32_t scale = startTime.timescale;
    
    int64_t interval = (end_value - start_value)/count;
    NSMutableArray *arr = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        for (int64_t i=0; i< count; i++) {
            UIImage *image = [self thumbnailImageForVideo:url maximumSize:maximumSize actualTime:CMTimeMake(start_value+i*interval, scale)];
            [arr addObject:image];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            if (block) {
                block([NSArray arrayWithArray:arr]);
            }
        });
    });
}

+(UIImage*)thumbnailImageForVideo:(NSURL *)url maximumSize:(CGSize)maximumSize actualTime:(CMTime)time {
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:[self getUrlAsset:url]];
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    if (!CGSizeEqualToSize(maximumSize, CGSizeZero)) {
        imageGenerator.maximumSize = maximumSize;
    }
    NSError *error = nil;
    //缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    
    CMTime actucalTime; //缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
//        NSLog(@"截取视频图片失败:%@",error.localizedDescription);
    }
//    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}

+(void)CropVideoSquare:(NSURL*)url renderSize:(CGSize)renderSize transform:(CGAffineTransform)transform block:(void(^)(NSString *resultUrl,BOOL status)) block {
    AVAsset *asset = [self getUrlAsset:url];
    [self CropVideoSquare:url timeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) renderSize:renderSize transform:transform block:block];
}

+(void)CropVideoSquare:(NSURL*)url timeRange:(CMTimeRange)timeRange block:(void(^)(NSString *resultUrl,BOOL status)) block {
    //获取原视频
    AVAsset *asset = [self getUrlAsset:url];
    //创建裁剪后视频的存放路径
    NSString *exportPath = [self getExportPath];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality] ;
    exportSession.outputURL = exportUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.timeRange = timeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        BOOL status = NO;
        switch (exportSession.status) {
            case AVAssetExportSessionStatusUnknown:
//                NSLog(@"AVAssetExportSessionStatusUnknown");
                break;
            case AVAssetExportSessionStatusWaiting:
//                NSLog(@"AVAssetExportSessionStatusWaiting");
                break;
            case AVAssetExportSessionStatusExporting:
//                NSLog(@"AVAssetExportSessionStatusExporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                status = YES;
//                NSLog(@"AVAssetExportSessionStatusCompleted");
                break;
            case AVAssetExportSessionStatusFailed:
//                NSLog(@"AVAssetExportSessionStatusFailed");
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(exportPath,status);
            }
        });
    }];
}

+(void)CropVideoSquare:(NSURL*)url timeRange:(CMTimeRange)timeRange renderSize:(CGSize)renderSize transform:(CGAffineTransform)transform block:(void(^)(NSString *resultUrl,BOOL status)) block {
    
    //获取原视频
    AVAsset *asset = [self getUrlAsset:url];
    //创建视频轨道信息
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //创建视频分辨率等一些设置
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //设置渲染的宽高分辨率,均为视频的自然高度
    videoComposition.renderSize = renderSize;
    //创建视频的构造信息
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = timeRange;
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    NSInteger degress = [DTVideoEngine degressFromVideoFileWithURL:url];
    if (degress == 90 || degress == 180) {
        CGAffineTransform rotationTransform = CGAffineTransformConcat(clipVideoTrack.preferredTransform, transform);
        [transformer setTransform:rotationTransform atTime:kCMTimeZero];
    }else{
        [transformer setTransform:transform atTime:kCMTimeZero];
    }
    //先添加tranform层的构造信息，再添加分辨率信息
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    //创建裁剪后视频的存放路径
    NSString *exportPath = [self getExportPath];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    //开始进行导出视频
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = exportUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
//    exporter.timeRange = timeRange;
    
    // setup audio mix
//    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
//    exporter.audioMix = exportAudioMix;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        BOOL status = NO;
        switch (exporter.status) {
            case AVAssetExportSessionStatusUnknown:
//                NSLog(@"AVAssetExportSessionStatusUnknown");
                break;
            case AVAssetExportSessionStatusWaiting:
//                NSLog(@"AVAssetExportSessionStatusWaiting");
                break;
            case AVAssetExportSessionStatusExporting:
//                NSLog(@"AVAssetExportSessionStatusExporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                status = YES;
//                NSLog(@"AVAssetExportSessionStatusCompleted");
                break;
            case AVAssetExportSessionStatusFailed:
//                NSLog(@"AVAssetExportSessionStatusFailed");
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(exportPath,status);
            }
        });
    }];
}

/*!
 *  @author DT
 *
 *  @brief 获取视频沙盒保存路径
 *
 *  @return <#return value description#>
 */
+(NSString*)getExportPath {
    
//    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *documentsPath = NSTemporaryDirectory();
    NSString *exportPath = [documentsPath stringByAppendingFormat:@"/%@.mp4",[self getDateStringForNow]];
    return exportPath;
}

+(NSString*)getDateStringForNow
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyyMMddHHmmssSSS"];
    NSString *destDate= [dateFormatter stringFromDate:[NSDate date]];
    
    return [destDate stringByEncodingToMd5];
}

@end
