//
//  SJKGameOC.m
//  Unity-iPhone
//
//  Created by clyde on 2020/4/30.
//

#import <Foundation/Foundation.h>
@interface SJKGameOC : NSObject
typedef NS_ENUM(NSInteger, SdkFunctionCallType) {
     //init SDK
     Init_FunctionType = 101,//初始化
     InitSucces_FunctionType = 102,
     InitFail_FunctionType = 103,

     //login SDK
     Login_FunctionType = 201,
     LoginSucces_FunctionType = 202,
     LoginFail_FunctionType = 203,
     LoginCancel_FunctionType = 204,

     //bind SDK
     BindAccount_FunctionType = 301,
     BindAccountSucces_FunctionType = 302,
     BindAccountFail_FunctionType = 303,
     BindAccountCancel_FunctionType = 304,

     //pay SDK
     Pay_FunctionType = 401,
     PaySucces_FunctionType = 402,
     PayFail_FunctionType = 403,
     PayCancel_FunctionType = 404,

     //logout sdk
     Logout_FunctionType = 501,
     LogoutSucces_FunctionType = 502,
     LogoutFail_FunctionType = 503,

     //ad init
     AdInit_FunctionType = 701,
     AdInitSucces_FunctionType = 702,
     AdInitFail_FunctionType = 703,

     //ad fectch
     AdRewardFetch_FunctionType = 711,
     AdRewardSucces_FunctionType = 712,
     AdRewardFail_FunctionType = 713,
     AdLoadFail_FunctionType = 714,

     //other
     UpdateLanguage_FunctionType = 2001,
     UserAgreement_FunctionType = 2003,
     CustomsEventUp_FunctionType = 2004,
};

 +(SJKGameOC*) instance;
 +(NSDictionary*)getJsonDic:(NSString*)jsonString;
 +(NSString*)arrayToJson:(NSMutableDictionary *)dic;
 -(void) SendMessage:(SdkFunctionCallType)funType json:(NSString *)jsonData;
 -(void) IntSdk:(NSString*)objectName param1:(NSString *)functionName param2:(NSString *)callFunckey param3:(NSString *)jsonkey;
@end

static NSString *UnityGameObject=@"";
//find method name  is on gameobject
static NSString *MethodName=@"";

//is same the name with C# by side
static NSString *FunctionName=@"";
static NSString *JsonDatakey=@"";
