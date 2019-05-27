package com.example.flutter_geetest;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.geetest.sdk.GT3ConfigBean;
import com.geetest.sdk.GT3ErrorBean;
import com.geetest.sdk.GT3GeetestUtils;
import com.geetest.sdk.GT3Listener;


import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import io.flutter.plugin.common.MethodChannel;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import org.json.JSONObject;

/**
 * function:GeetestPluginHelper
 *
 * <p></p>
 * Created by Leo on 2019/5/17.
 */
@SuppressWarnings("ConstantConditions")
class GeetestPluginHelper {
    private Activity        mActivity;
    private GT3GeetestUtils gt3GeetestUtils;
    private GT3ConfigBean   gt3ConfigBean;
    private Handler         mHandler = new Handler(Looper.getMainLooper());
    private ProgressDialog  mLoading;

    GeetestPluginHelper(Activity activity) {
        this.mActivity = activity;
    }

    String sdkVersion() {
        return GT3GeetestUtils.getVersion();
    }

    //    private MethodChannel.Result mResult;
    private String mApi2;

    //场景1(代处理接口模式): api1,api2都不为空，使用SDK处理，api1请求获取json(包含gt,challenge,success)启动弹窗验证，完成后请求api2二次验证，完成后回调
    //场景2(自处理接口模式)：gt,challenge,success都不为空，SDK启动弹窗验证，完成后返回进行要求二次验证
    //场景3：api1,api2之一为空字符串，则校验场景2，场景2仍然存在空字符串，返回失败提示参数异常信息
    void launchGeetest(final String api1, String api2, String gt, String challenge, int success, final MethodChannel.Result result) {
        try {
            if(mActivity == null) {
                result.success(errorString("Host activity has been destroy."));
                return;
            }
            gt3GeetestUtils = new GT3GeetestUtils(mActivity);
            //            this.mResult = result;
            this.mApi2 = api2;
            //api1 不为空，SDK代处理api1的请求
            if(api1 != null && api1.length() > 0) {
                //配置参数
                initConfigBean(result);
                //请求api1接口并拉起弹窗
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        LogUtil.log("request api1 start");
                        final String api1Result = requestGet(api1);
                        LogUtil.log("response api1: "+api1Result);
                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                JSONObject jsonObject = null;
                                try {jsonObject = new JSONObject(api1Result); } catch(Exception ignored) { }
                                if(jsonObject == null) {
                                    gt3GeetestUtils.showFailedDialog();
                                    result.success(errorString("api1 request error."));
                                } else {
                                    // SDK可识别格式为
                                    // {"success":1,"challenge":"06fbb267def3c3c9530d62aa2d56d018","gt":"019924a82c70bb123aae90d483087f94"}
                                    gt3ConfigBean.setApi1Json(jsonObject);
                                    gt3GeetestUtils.getGeetest();
                                }
                            }
                        });
                    }
                }).start();
            }
            //api1结果参数 不为空，SDK直接唤起验证弹窗
            else if(gt.length() > 0 && challenge.length() > 0 && success != -1) {
                //配置参数
                initConfigBean(result);
                //直接拉起弹窗
                // SDK可识别格式为 {"success":1,"challenge":"06fbb267def3c3c9530d62aa2d56d018","gt":"019924a82c70bb123aae90d483087f94"}
                new JSONObject();
                try {
                    JSONObject parmas = new JSONObject();
                    parmas.put("gt", gt);
                    parmas.put("challenge", challenge);
                    parmas.put("success", success);
                    gt3ConfigBean.setApi1Json(parmas);
                    gt3GeetestUtils.getGeetest();
                } catch(Exception ignored) {}
            }
            //参数有误
            else {
                result.success(errorString("参数错误，请检查传参"));
            }
        } catch(Exception e) {
            LogUtil.log(e.getMessage());
            result.success(errorString((e.getMessage())));
        }
    }


    private void initConfigBean(final MethodChannel.Result resultCallback) {
        // 配置bean文件，也可在oncreate初始化
        gt3ConfigBean = new GT3ConfigBean();
        // 设置验证模式，1：bind，2：unbind
        gt3ConfigBean.setPattern(1);
        // 设置点击灰色区域是否消失，默认不消失
        gt3ConfigBean.setCanceledOnTouchOutside(false);
        // 设置debug模式，开代理可调试 
        gt3ConfigBean.setDebug(false);
        // 设置语言，如果为null则使用系统默认语言
        gt3ConfigBean.setLang(null);
        // 设置加载webview超时时间，单位毫秒，默认10000，仅且webview加载静态文件超时，不包括之前的http请求
        gt3ConfigBean.setTimeout(10000);
        // 设置webview请求超时(用户点选或滑动完成，前端请求后端接口)，单位毫秒，默认10000
        gt3ConfigBean.setWebviewTimeout(10000);
        // 设置回调监听
        gt3ConfigBean.setListener(new GT3Listener() {
            /**
             * api1结果回调
             */
            @Override
            public void onApi1Result(String result) {
                LogUtil.log("GT3BaseListener-->onApi1Result-->"+result);
            }

            /**
             * 验证码加载完成
             * @param duration 加载时间和版本等信息，为json格式
             */
            @Override
            public void onDialogReady(String duration) {
                LogUtil.log("GT3BaseListener-->onDialogReady-->"+duration);
            }

            /**
             * 验证结果
             */
            @Override
            public void onDialogResult(final String result) {
                LogUtil.log("GT3BaseListener-->onDialogResult-->"+result);
                if(!TextUtils.isEmpty(mApi2)) {
                    if(mLoading == null) mLoading = ProgressDialog.show(mActivity, null, "加载中");
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            LogUtil.log("request api2 start");
                            final String api2Result = requestPost(mApi2, result);
                            LogUtil.log("response api2: "+api2Result);
                            mHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    mLoading.dismiss(); mLoading = null;
                                    if(!TextUtils.isEmpty(api2Result)) {
                                        try {
                                            JSONObject jsonObject = new JSONObject(api2Result);
                                            String     status     = jsonObject.getString("status");
                                            if("success".equals(status)) {
                                                gt3GeetestUtils.showSuccessDialog();
                                                resultCallback.success(successString(null, null, null));
                                            } else {
                                                gt3GeetestUtils.showFailedDialog();
                                                resultCallback.success(errorString(jsonObject.toString()));
                                            }
                                        } catch(Exception e) {
                                            gt3GeetestUtils.showFailedDialog();
                                            resultCallback.success(errorString(e.getMessage()));
                                        }
                                    } else {
                                        gt3GeetestUtils.showFailedDialog();
                                        resultCallback.success(errorString("api2 request error."));
                                    }
                                }
                            });
                        }
                    }).start();
                } else {
                    try {
                        JSONObject jsonObject       = new JSONObject(result);
                        String     geetestChallenge = jsonObject.getString("geetest_challenge");
                        String     geetestSeccode   = jsonObject.getString("geetest_seccode");
                        String     geetestValidate  = jsonObject.getString("geetest_validate");
                        gt3GeetestUtils.showSuccessDialog();
                        resultCallback.success(successString(geetestChallenge, geetestSeccode, geetestValidate));
                    } catch(Exception e) {
                        gt3GeetestUtils.showFailedDialog();
                        resultCallback.success(errorString("验证结果参数错误. e:"+e.getMessage()));
                    }
                }
            }

            /**
             * api2回调
             */
            @Override
            public void onApi2Result(String result) {
                LogUtil.log("GT3BaseListener-->onApi2Result-->"+result);
            }

            /**
             * 统计信息，参考接入文档
             */
            @Override
            public void onStatistics(String result) {
                LogUtil.log("GT3BaseListener-->onStatistics-->"+result);
            }

            /**
             * 验证码被关闭
             * @param num 1 点击验证码的关闭按钮来关闭验证码, 2 点击屏幕关闭验证码, 3 点击返回键关闭验证码
             */
            @Override
            public void onClosed(int num) {
                LogUtil.log("GT3BaseListener-->onClosed-->"+num);
            }

            /**
             * 验证成功回调
             */
            @Override
            public void onSuccess(String result) {
                LogUtil.log("GT3BaseListener-->onSuccess-->"+result);
            }

            /**
             * 验证失败回调
             * @param errorBean 版本号，错误码，错误描述等信息
             */
            @Override
            public void onFailed(GT3ErrorBean errorBean) {
                LogUtil.log("GT3BaseListener-->onFailed-->"+errorBean.toString());
            }

            @Override
            public void onButtonClick() { }
        });
        gt3GeetestUtils.init(gt3ConfigBean);
        // 开启验证
        gt3GeetestUtils.startCustomFlow();
    }


    private String errorString(String msg) {
        try {
            JSONObject result = new JSONObject();
            result.put("code", 3);
            result.put("msg", msg);
            return result.toString();
        } catch(Exception ignored) {}
        return "";
    }

    private String successString(String geetest_challenge, String geetest_seccode, String geetest_validate) {
        try {
            JSONObject result = new JSONObject();
            result.put("code", 2);
            if(!TextUtils.isEmpty(geetest_challenge)) result.put("geetest_challenge", geetest_challenge);
            if(!TextUtils.isEmpty(geetest_seccode)) result.put("geetest_seccode", geetest_seccode);
            if(!TextUtils.isEmpty(geetest_validate)) result.put("geetest_validate", geetest_validate);
            return result.toString();
        } catch(Exception ignored) {}
        return "";
    }


    private static String requestPost(String urlString, String postParam) {
        MediaType   mediaType   = MediaType.parse("application/json");
        RequestBody requestBody = RequestBody.create(mediaType, postParam);
        Request     request     = new Request.Builder().post(requestBody).url(urlString).build();
        try {
            Response response = httpClient().newCall(request).execute();
            return response.body().string();
        } catch(Exception ignored) {}
        return null;
    }

    private static String requestGet(String urlString) {
        Request request = new Request.Builder().url(urlString).build();
        try {
            Response response = httpClient().newCall(request).execute();
            return response.body().string();
        } catch(Exception ignored) {}
        return null;
    }

    private static OkHttpClient httpClient() {
        OkHttpClient.Builder builder = new OkHttpClient.Builder();
        builder.followRedirects(true);
        builder.followSslRedirects(true);
        builder.retryOnConnectionFailure(false);
        builder.connectTimeout(30, TimeUnit.SECONDS);
        builder.readTimeout(30, TimeUnit.SECONDS);
        builder.writeTimeout(30, TimeUnit.SECONDS);
        try {
            SSLContext                 sc              = SSLContext.getInstance("TLS");
            AllTrustedX509TrustManager trustAllManager = new AllTrustedX509TrustManager();
            sc.init(null, new TrustManager[]{trustAllManager}, new SecureRandom());
            builder.sslSocketFactory(sc.getSocketFactory(), trustAllManager);
            builder.hostnameVerifier(new AllTrustedHostnameVerifier());
        } catch(Exception ignored) { }
        return builder.build();
    }

    private static class AllTrustedHostnameVerifier implements HostnameVerifier {
        @SuppressLint("BadHostnameVerifier")
        @Override
        public boolean verify(String hostname, SSLSession session) {
            return true;
        }
    }

    private static class AllTrustedX509TrustManager implements X509TrustManager {
        @SuppressLint("TrustAllX509TrustManager")
        @Override
        public void checkClientTrusted(X509Certificate[] chain, String authType) {}

        @SuppressLint("TrustAllX509TrustManager")
        @Override
        public void checkServerTrusted(X509Certificate[] chain, String authType) {}

        @Override
        public X509Certificate[] getAcceptedIssuers() {return new X509Certificate[0];}
    }
}
