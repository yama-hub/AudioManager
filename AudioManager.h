//
//  AudioManager.h
//
//  Created by Yamamoto Gota on 12/12/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioManager : NSObject

+ (AudioManager *)sharedManager;

- (void)stopPlayers;
- (void)removePlayer:(AVAudioPlayer *)player;

- (AVAudioPlayer *)playerWithURL:(NSURL *)url
                         success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
                         failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

- (AVAudioPlayer *)playerWithPath:(NSString *)path
                          success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
                          failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

- (void)playerWithURL:(NSURL *)url
              prepare:(void(^)(AVAudioPlayer *audioPlayer))prepare
              success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
              failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

- (void)playerWithPath:(NSString *)path
               prepare:(void(^)(AVAudioPlayer *audioPlayer))prepare
               success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
               failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

- (void)playerContinuousWithPath:(NSArray *)paths
                         prepare:(void(^)(AVAudioPlayer *audioPlayer))prepare
                         process:(void(^)(AVAudioPlayer *audioPlayer, NSString *path, BOOL *stop))process
                         success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
                         failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

@end
