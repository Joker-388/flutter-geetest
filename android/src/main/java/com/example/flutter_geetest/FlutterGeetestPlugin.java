package com.example.flutter_geetest;

import android.app.Activity;


import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterGeetestPlugin */
public class FlutterGeetestPlugin implements MethodCallHandler {
    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_geetest");
        channel.setMethodCallHandler(new FlutterGeetestPlugin(registrar.activity()));
    }

    private Activity            mActivity;
    private GeetestPluginHelper mHelper;

    private FlutterGeetestPlugin(Activity activity) {
        mActivity = activity;
        mHelper = new GeetestPluginHelper(mActivity);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if(mHelper == null) mHelper = new GeetestPluginHelper(mActivity);
        String method = call.method;
        LogUtil.log("onMethodCall: method="+method);
        // getPlatformVersion
        if(method.equals("getPlatformVersion")) {
            result.success(mHelper.sdkVersion());
        }
        // launchGeetest
        /// String [api1]: api1,SDK代处理的第一次验证接口 <br></br>
        /// String [api2]: api2,SDK代处理的第二次验证接口 <br></br>
        /// String [gt]: gt，自行处理api1获取的参数 <br></br>
        /// String [challenge]: challenge，自行处理api1获取的参数 <br></br>
        /// String [success]: success，自行处理api1获取的参数 <br></br>
        else if(method.equals("launchGeetest")) {
            String api1      = call.hasArgument("api1") ? (String) call.argument("api1") : "";
            String api2      = call.hasArgument("api2") ? (String) call.argument("api2") : "";
            String gt        = call.hasArgument("gt") ? (String) call.argument("gt") : "";
            String challenge = call.hasArgument("challenge") ? (String) call.argument("challenge") : "";
            int    success   = call.hasArgument("success") ? (int) call.argument("success") : -1;
            mHelper.launchGeetest(api1, api2, gt, challenge, success, result);
        }
       /* // initGeeTest
        /// String [api1]: 注册接口，如果自定义注册步骤，可以忽略，否则必须传。
        /// String [api2]: 二次验证接口，如果自定义二次验证步骤，可以忽略，否则必须传。
        /// bool [customRegisterAPI]: 默认true，是否自定义注册步骤。如果需要使用极验默认的注册步骤，必须传false。
        /// bool [customSecondaryValidate]:  默认true，是否自定义二次验证步骤。如果需要使用极验默认的二次验证步骤，必须传false。
        else if(method.equals("initGeeTest")) {
            String  api1                    = call.hasArgument("api1") ? (String) call.argument("api1") : "";
            String  api2                    = call.hasArgument("api2") ? (String) call.argument("api2") : "";
            boolean customRegisterAPI       = call.hasArgument("customRegisterAPI") ? (boolean) call.argument("customRegisterAPI") : true;
            boolean customSecondaryValidate = call.hasArgument("customSecondaryValidate") ? (boolean) call.argument("customSecondaryValidate") : true;
            mHelper.initGeeTest(api1, api2, customRegisterAPI, customSecondaryValidate, result);
        }
        // configureGeeTest
        /// 如果自定义注册步骤，必须调用此接口，将api1接口返回的相应字段传入。
        /// String [publicKey]: 来自api1接口返回。
        /// String [challenge]: 来自api1接口返回。
        /// String [successCode]: 来自api1接口返回。
        /// String [api2]: 如果需要使用极验默认的二次验证，必须传入api2。如果使用自定义的二次验证，忽略参数。
        else if(method.equals("configureGeeTest")) {
            String publicKey   = call.hasArgument("publicKey") ? (String) call.argument("publicKey") : "";
            String challenge   = call.hasArgument("challenge") ? (String) call.argument("challenge") : "";
            String successCode = call.hasArgument("successCode") ? (String) call.argument("successCode") : "";
            String api2        = call.hasArgument("api2") ? (String) call.argument("api2") : "";
            mHelper.configureGeeTest(publicKey, challenge, successCode, api2, result);
        }
        // startGTCaptcha
        /// bool [animation]: 是否使用动画
        else if(method.equals("startGTCaptcha")) {
            boolean animation = call.hasArgument("animation") ? (boolean) call.argument("animation") : true;
            mHelper.startGTCaptcha(animation, result);
        }*/
        //else
        else {
            result.notImplemented();
        }
    }
}
