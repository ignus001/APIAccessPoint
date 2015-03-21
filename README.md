# APIAccessPoint
Objective-C

Useage
(Assuming that textfields have passed validation (not empty; correct expected data), and that this class has properly been imported to your class)

        if ([self guestDidPassValidation]) {        
                accesspoint.willShowCustomLoadingIndicator = YES;
                accesspoint.url = kURL_POST_BaseCreateAcct;
                accesspoint.httpMethod = @"POST";
                accesspoint.postImage = [UIImage imageNamed:@"image.png"];
                accesspoint.postParam = @{      @"fullname"       :  fullname,
                                                @"username"       :  username,
                                                @"phnno"          :  phoneNum,
                                                @"email"          :  emailAdd,
                                                @"country"        :  country,
                                                @"password"       :  password,
                                                @"countryCode"    :  countyCode,
                                                @"contactNumber"  :  contactNum};
        
                [accesspoint connectWithCompletion:^(NSArray *response) {
                        NSLog(@"response:%@", response);
                }];
        }

Where;

accesspoint.url = kURL_POST_BaseCreateAcct; is the URL

accesspoint.httpMethod = @"POST"; is the http method. CASE SENSITIVE: use @"GET" or @"POST" only

accesspoint.postImage = [UIImage imageNamed:@"image.png"]; if your post parameter includes an image

accesspoint.postParam = @{}; Are the main parameters of the POST

accesspoint.willShowCustomLoadingIndicator will show custom loading view if YES. This view will force the user to wait for the api to end before doing anything in the app. Good for controlling the USER's action and not spamming the API. If this is NO, you need to call the action indicator on the status bar.



Connect

The connect function will do most of the things for you. Check internet connection, handle (some) failures, and log the progress of your call. You only need to catch the response by simply;

        [accesspoint connectWithCompletion:^(NSArray *response) {
                NSLog(@"response:%@", response);
        }];

Put all your statements inside the block as it will only be called when the API Call is completed. Handle success and failure response within.
