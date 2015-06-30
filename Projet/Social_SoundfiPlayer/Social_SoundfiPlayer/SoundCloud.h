//
//  SoundCloud.h
//  Social_SoundfiPlayer
//
//  Created by Evernet on 06/08/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface SoundCloud : NSObject

//Change these to your own apps values
#define CLIENT_ID @"a361e474afcfc2e0fe0bc97999d0ec23"
#define CLIENT_SECRET @"92411802be98fa39aba147302b768aeb"
#define REDIRECT_URI @"yourappname://oauth"//don't forget to change this in Info.plist as well

#define SC_API_URL @"https://api.soundcloud.com"
#define SC_TOKEN @"SC_TOKEN"
#define SC_CODE @"SC_CODE"

@property (strong, nonatomic)  NSMutableArray *scTrackResultList;
@property (nonatomic,retain) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic)  NSString *scToken;
@property (strong, nonatomic)  NSString *scCode;

-(BOOL) login;


- (void) searchForTracksWithQuery: (NSString *)query;
-(NSData *) downloadTrackData :(NSString *)songURL;


- (void)loadUserTrack:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)loadUserInfo:(void (^)(NSDictionary *userInfo))success failure:(void (^)(NSError *error))failure;
- (void)loadUserFavTracks:(void (^)(NSArray *userFavTracks))success failure:(void (^)(NSError *error))failure;

@end
