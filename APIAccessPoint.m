//
//  APIAccessPoint.m
//  Template v.3.0.0 Variant 1
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Angelo Lesano. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Single Call Variant
//
//  To Self: This method is restricted to call only API until such call is completed regardless of the result (fail/succeed). The retry function WILL reconnect to the LAST called API. Before performing another call, make sure that the current call is finalized. In the future, you may need to asynchronouly call multiple API endpoints which this class cannot do. The best way that I can think of right now is to check first if the user is accessing the same endpoint and impose restriction if he is, so that the user cannot spam that particular endpoint. Any other endpoint besides the one the user is currently calling will be called and asynchronously loaded. Kthxbai -Angelo.past"
//
//  Created by Angelo Lesano on 20/2/14.
//

#import "APIAccessPoint.h"
#import "Constants.h"
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

@implementation APIAccessPoint{
    UIView          *loadingView;

}

#pragma mark - INIT Methods
- (id) init
{
    if (self = [super init])
    {
        self.isLoading = NO;
    }
    return self;
}

#pragma mark - Custom Methods
- (void)connectWithCompletion:(void (^)(NSArray *response)) completion{
    
    if ([self isInternetAvailable]!=0) {
        if (!self.isLoading) {
            self.isLoading = YES;
            __block NSArray *responseData = [[NSArray alloc] init];
            [self shouldPresentLoadingScreen:self.willShowCustomLoadingIndicator message:self.loadingMessage];
            
            
            NSLog(@"Attempting to connect to: %@", self.url);
            NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL : [NSURL URLWithString: self.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0f];
            [request setHTTPShouldHandleCookies:NO];
            [request setHTTPMethod: self.httpMethod];
            
            NSString *BoundaryConstant  = @"----------V2ymHFg03ehbqgZCaKO6jy";
            NSString* FileParamConstant = @"image";
            
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
            [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            NSMutableData *body = [NSMutableData data];
            
            for (NSString *param in self.postParam) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@\r\n", [self.postParam objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            NSData *imageData = UIImageJPEGRepresentation(self.postImage, 1.0);
            if (imageData) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:imageData];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
            
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:
             ^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                 NSInteger code = [httpResponse statusCode];
                 
                 NSLog(@"Status Code: %ld", (long)code);
                 [self shouldPresentLoadingScreen:NO message:nil];
                 self.isLoading = NO;
                 if (code == 200){
                     if (data !=nil) {
                         responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                         NSLog(@"API Connection established (%@)",self.httpMethod);
                         if(completion)
                         {
                             completion(responseData);
                         }
                     }
                 }else{
                     NSLog(@"API cannot establish connection (%@)",self.httpMethod);
                     if (error){
                         [self alert_ERROR:error];
                     }else{
                         [self alert_ERROR:@"There was a problem connecting with the service."];
                     }
                 }
             }];
        }else{
            //
        }
    }else{
        [self alert_NO_INTERNET];
    }
}

- (void)shouldPresentLoadingScreen:(BOOL)option message:(NSString*)loadingMessage{
    if (option) {
        //MAIN VIEW : FULLSCREEN
        //This will restrict the user from doing anything else when the api is being called. Makes sure that the event that called the API is not spammed.
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreen.size.width, kAppScreen.size.height)];
        [loadingView setBackgroundColor:[UIColor clearColor]];
        
        //CONTAINER
        static int containerW = 150;
        static int containerH = 150;
        int centerY     = ((kAppScreen.size.height/2) - (containerH/2));
        int centerX     = ((kAppScreen.size.width/2) - (containerW/2));
        
        UIView *container = [[UIView alloc]initWithFrame:CGRectMake(centerX, centerY, containerW, containerH)];
        [container setBackgroundColor:[UIColor blackColor]];
        
        [container.layer setCornerRadius:15.0f];
        [container.layer setShadowColor:[UIColor blackColor].CGColor];
        [container.layer setShadowOpacity:0.8];
        [container.layer setShadowRadius:3.0];
        [container.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        
        
        //ACTIVITY INDICATOR
        int spinnerW = 50;
        int spinnerH = 50;
        int spinnerX = (container.frame.size.width/2) - (spinnerW/2);
        int spinnerY = (container.frame.size.height/2) - (spinnerH/2);
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(spinnerX, spinnerY, spinnerW, spinnerH)];
        [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner startAnimating];
        
        //LABEL
        int labelW = container.frame.size.width;
        int labelH = 50;
        int labelX = 0;
        int labelY = spinner.frame.origin.y + spinner.frame.size.height;
        
        UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(labelX,labelY, labelW, labelH)];
        [prompt setFont:kFONT_AvenirCondensed_Regular(18)];
        [prompt setText:(loadingMessage) ? loadingMessage : @"Loading"];
        [prompt setTextAlignment:NSTextAlignmentCenter];
        [prompt setTextColor:[UIColor whiteColor]];
        [prompt setAdjustsFontSizeToFitWidth:YES];
        [prompt setMinimumScaleFactor:8.0f];
        
        [container addSubview:spinner];
        [container addSubview:prompt];
        [loadingView addSubview:container];
        [[UIApplication sharedApplication].keyWindow addSubview:loadingView];
    }else{
        [loadingView removeFromSuperview];
    }
}

#pragma mark - Utility Methods
- (void)alert_NO_INTERNET{

    [self shouldPresentLoadingScreen:NO message:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Required"
                                                        message:@"Some of the features of the application requires an Internet connection."
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)alert_ERROR:(id) error{
    NSString *title;
    NSString *message;
    
    if ([error isKindOfClass:[NSError class]]) {
        title = [error localizedDescription];
        message = [error localizedRecoverySuggestion];
    }else if ([error isKindOfClass:[NSString class]]){
        title = @"Error";
        message = error;
    }
    
    [self shouldPresentLoadingScreen:NO message:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)alert:(NSString*)title message:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:nil
                                         cancelButtonTitle:@"Okay"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Internet Checker
- (int)isInternetAvailable
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *) &zeroAddress);
    
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
        if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
            // if target host is not reachable
            return 0;
        }
        
        if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
            NSLog(@"Connection: Wifi");
            // if target host is reachable and no connection is required
            //  then we'll assume (for now) that your on Wi-Fi
            return 1; // This is a wifi connection.
        }
        
        
        if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0)
             ||(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
            // ... and the connection is on-demand (or on-traffic) if the
            //     calling application is using the CFSocketStream or higher APIs
            
            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
                // ... and no [user] intervention is needed
                NSLog(@"Connection: Wifi");
                return 1; // This is a wifi connection.
            }
        }
        
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
            // ... but WWAN connections are OK if the calling application
            //     is using the CFNetwork (CFSocketStream?) APIs.
            NSLog(@"Connection: Cellular");
            return 2; // This is a cellular connection.
        }
    }
    
    return 0;
}

#pragma mark - Delegate Methods
#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Retry"]) {
        NSLog(@"Retrying with url:%@", self.url);
        [self shouldPresentLoadingScreen:!self.willShowCustomLoadingIndicator message:nil];
        [self connectWithCompletion:^(NSArray *response) {
            //
        }];
    }else if (([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"View Details"])){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information"
                                                            message:@"In order to not spam the server with requests, server calls are restricted to single calls per app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil, nil];
        [alertView show];

    }
}


@end
