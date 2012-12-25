//
//  AudioManager.h
//
//  Created by Yamamoto Gota on 12/12/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioManager : NSObject

+ (AudioManager *)sharedManager;

- (AVAudioPlayer *)playerWithURL:(NSURL *)url
                        complete:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))complete
                         failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

- (AVAudioPlayer *)playerWithPath:(NSString *)path
                         complete:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))complete
                          failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

- (void)playerWithURL:(NSURL *)url
                         success:(void(^)(AVAudioPlayer *audioPlayer))success
                        complete:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))complete
                         failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

- (void)playerWithPath:(NSString *)path
               success:(void(^)(AVAudioPlayer *audioPlayer))success
              complete:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))complete
               failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;

@end
