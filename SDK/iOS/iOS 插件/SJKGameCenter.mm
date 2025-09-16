//
//  SJKGameCenter.m
//  Unity-iPhone
//
//  Created by clyde on 2020/4/30.
//


#import "SJKGameOC.h"
#import "SJKGameCenter.h"
const char * _maskcpy(const char *ch)
{
    if (ch==nil) {
        return nil;
    }
    char*str = (char*)malloc(strlen(ch)+1);
    strcpy(str, ch);
    return str;
}
#if defined(__cplusplus)
extern "C"{
#endif
extern void _InitSDK(const char * gameObjectName, const char * UnityFunctionName,const char * sdkFunctionName, const char * sdkJsonParamKey);
extern void _CallSDKFunction(int funType, const char *json);
extern const char * _GetSDK(int funType);
#if defined(__cplusplus)
}
#endif

void _InitSDK(const char * gameObjectName, const char * UnityFunctionName,const char * sdkFunctionName, const char * sdkJsonParamKey)
{
    NSString* UnityGameObject=[NSString stringWithUTF8String:_maskcpy(gameObjectName)];
    NSString* MethodName=[NSString stringWithUTF8String:UnityFunctionName];
    NSString* FunctionName=[NSString stringWithUTF8String:sdkFunctionName];
    NSString* JsonDatakey=[NSString stringWithUTF8String:sdkJsonParamKey];
    NSLog(@"%@,%@,%@,%@",UnityGameObject,MethodName,FunctionName,JsonDatakey);
    [[SJKGameOC instance] IntSdk:UnityGameObject param1:MethodName param2:FunctionName param3:JsonDatakey ];
}

void _CallSDKFunction(int funType, const char *json)
{
   NSString *str=[NSString stringWithUTF8String:json];
   bool isvalid=[NSJSONSerialization isValidJSONObject:str];

   if(isvalid)
   {
       NSData *data=[NSJSONSerialization dataWithJSONObject:str options:NSJSONReadingAllowFragments  error:nil];
       NSLog(@"%@\t%@",str,data);
   }
   else{
       str = @"{\"id\":\"xiaoming\" ,\"num\":101}";
       NSDictionary* dic = [SJKGameOC getJsonDic:str];
       NSString *name = [[dic objectForKey:@"id"] stringValue];
       NSInteger num = [[dic objectForKey:@"num"] integerValue];
       if (num==Init_FunctionType) {
           NSLog(@"字典转换调用测试----------------------");
       }
       NSLog(@"pay--C#toIOS：%@",str);
       NSLog(@"-------------------------回调C#---------------------------");
       NSString *sh=[[NSNumber numberWithInt:funType] description];
       
       [[SJKGameOC instance] SendMessage:Init_FunctionType json:[NSString stringWithFormat:@"{\"id\":678 ,\"funType\":%@}",sh]];
   }
    
}

const char * _GetSDK(int funType)
{
    NSString *sh=[[NSNumber numberWithInt:funType] description];
    NSString *shResult = [NSString stringWithFormat:@"{\"funType\":%@}",sh];
    const char *ch = [shResult UTF8String];
    return _maskcpy(ch);
}

