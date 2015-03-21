//
//  APIAccessPoint.h
//  Template v.1 Single Call Variant
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
//  Make this class global by #import it to your prefix header file $[yourAppName]-Prefix.pch
//
//  Created by Angelo Lesano on 20/2/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APIAccessPoint : NSObject <UIAlertViewDelegate>
@property (strong, nonatomic)   NSString        *url;
@property (strong, nonatomic)   NSDictionary    *postParam;
@property (strong, nonatomic)   UIImage         *postImage;
@property (strong, nonatomic)   NSString        *httpMethod;
@property (strong, nonatomic)   NSString        *loadingMessage;
@property (nonatomic)           BOOL            willShowCustomLoadingIndicator;
@property (nonatomic)           BOOL            isLoading;

- (void)connectWithCompletion:(void (^)(NSArray *response)) completion;
- (void)alert:(NSString*)title message:(NSString*)message;

@end
// ----- METHOD TYPES ---- //
#define kAPI_METHOD_POST        @"POST"
#define kAPI_METHOD_GET         @"GET"

// ----- LOAD URL HERE ---- //
//Base URL
#define kURL_Base               @"http://google.com"

//GET

//POST
#define kURL_POST_Mail            [kURL_Base stringByAppendingString:@"/mail"]



















