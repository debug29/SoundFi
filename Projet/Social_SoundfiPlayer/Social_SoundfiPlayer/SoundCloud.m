//
//  SoundCloud.m
//  Social_SoundfiPlayer
//
//  Created by Evernet on 06/08/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//



#import "SoundCloud.h"
#import "JSONKit.h"


@implementation SoundCloud
{
    BOOL hasBeenLoggedIn;
}

- (id)init {
    self = [super init];
    if (self) {
        if(!self.scToken)
        {
            if(![self login])
            {
                return nil;
            }
        }
    }
    return self;
}


//Logon to SoundCloud with the users account
-(BOOL) login {
    //check if we have the token stored in userprefs
    self.scToken=[[NSUserDefaults standardUserDefaults] objectForKey:SC_TOKEN];
    if(self.scToken && self.scToken.length>0) {
        //we are already logged in
        return true;
    }
    else {
        self.scCode=[[NSUserDefaults standardUserDefaults] objectForKey:SC_CODE];
        if(self.scCode) {
            [self doOauthWithCode:self.scCode];
            return true;
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://soundcloud.com/connect?client_id=%@&redirect_uri=%@&response_type=code",CLIENT_ID,REDIRECT_URI]]];
            });
            return false;
        }
    }
}


- (void)doOauthWithCode: (NSString *)code {
    
    NSURL *url = [NSURL URLWithString:@"https://api.soundcloud.com/oauth2/token/"];
    NSString *postString =[NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",CLIENT_ID,CLIENT_SECRET,REDIRECT_URI,code];
    NSLog(@"post string: %@",postString);
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    NSString *responseBody = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"response body; %@",responseBody);
    
    NSMutableDictionary *resultJSON =[responseBody objectFromJSONString];
    self.scToken=[resultJSON objectForKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:self.scToken forKey:SC_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

// [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/me.json?oauth_token=%@",self.scToken]

- (void)loadUserInfo:(void (^)(NSDictionary *userInfo))success failure:(void (^)(NSError *error))failure {
    if(!self.scToken)
    {
        if(![self login])
        {
            failure(nil);
        }
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/me.json?oauth_token=%@",self.scToken]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"%@", responseObject);
         success(responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"error: %@", error);
         failure(error);
     }];
    
    [operation start];

}

- (void)loadUserFavTracks:(void (^)(NSArray *userFavTracks))success failure:(void (^)(NSError *error))failure {
    if(!self.scToken)
    {
        if(![self login])
        {
            failure(nil);
        }
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/me/favorites.json?oauth_token=%@",self.scToken]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"%@", responseObject);
         success(responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"error: %@", error);
         failure(error);
     }];
    
    [operation start];
    
}


-(void) loginCallback :(NSString *) token {
    if(token !=nil)
    {
        hasBeenLoggedIn=true;
        self.scToken = token;
    }
    
}

//Get list with full user tracks
// [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/me/tracks.json?oauth_token=%@

- (void)loadUserTrack:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
}

// Search for music with the given query
// [NSURL URLWithString:[NSString stringWithFormat:@"%@/tracks.json?oauth_token=%@&client_id=%@&q=%@",SC_API_URL,self.scToken,CLIENT_ID,query]

- (void) searchForTracksWithQuery: (NSString *)query {
    
}



//Return the data from the selected track url
//This can be directly played in an AVAudioPlayer without any modification
-(NSData *) downloadTrackData :(NSString *)songURL {
    
    NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@",songURL, self.scToken]]];
    
    return data;
}

@end
