package com.example.login_test_flutter;

import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.json.JSONException;
import org.json.JSONObject;
import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.mosip.registration.clientmanager.constant.AuditEvent;
import io.mosip.registration.clientmanager.constant.Components;
import io.mosip.registration.clientmanager.dto.http.ResponseWrapper;
import io.mosip.registration.clientmanager.dto.http.ServiceError;
import io.mosip.registration.clientmanager.exception.InvalidMachineSpecIDException;
import io.mosip.registration.clientmanager.service.LoginService;
import io.mosip.registration.clientmanager.spi.AuditManagerService;
import io.mosip.registration.clientmanager.spi.JobManagerService;
import io.mosip.registration.clientmanager.spi.JobTransactionService;
import io.mosip.registration.clientmanager.spi.MasterDataService;
import io.mosip.registration.clientmanager.spi.PacketService;
import io.mosip.registration.clientmanager.spi.RegistrationService;
import io.mosip.registration.clientmanager.spi.SyncRestService;
import io.mosip.registration.clientmanager.util.SyncRestUtil;
import io.mosip.registration.keymanager.spi.ClientCryptoManagerService;
import io.mosip.registration.clientmanager.config.AppModule;
import io.mosip.registration.clientmanager.config.NetworkModule;
import io.mosip.registration.clientmanager.config.RoomModule;
import io.mosip.registration.clientmanager.util.UserInterfaceHelperService;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import org.mvel2.MVEL;
import org.mvel2.integration.VariableResolverFactory;
import org.mvel2.integration.impl.MapVariableResolverFactory;
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_LOGIN = "com.flutter.dev/clientmanager.login";
    private static final String CHANNEL_TEST = "com.flutter.dev/keymanager.test-machine";
    private static final String CALL_APP_COMP = "com.flutter.dev/app-component";
    private static final String CHANNEL_SYNC = "com.flutter.dev/clientmanager.master-data-sync";
    private static final String VALIDATE_MVEL = "com.flutter.dev/clientmanager.evaluate-mvel";
    private static final String MVEL_CONTEXT_KEY = "identity";
    private static final String TAG = UserInterfaceHelperService.class.getSimpleName();

    @Inject
    ClientCryptoManagerService clientCryptoManagerService;

    @Inject
    SyncRestUtil syncRestFactory;

    @Inject
    SyncRestService syncRestService;

    @Inject
    LoginService loginService;

    @Inject
    AuditManagerService auditManagerService;

    @Inject
    MasterDataService masterDataService;

    @Inject
    RegistrationService registrationService;

    @Inject
    PacketService packetService;

    @Inject
    JobTransactionService jobTransactionService;


    @Inject
    JobManagerService jobManagerService;
    String login_response = "";
    Map<String, String> responseMap = new HashMap<>();
    JSONObject object;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    private boolean validateLogin(String username, String password) {
        if(username == null || username.trim().length() == 0){
            Log.e(getClass().getSimpleName(), "username incorrect");
            return false;
        }
        if(password == null || password.trim().length() == 0){
            Log.e(getClass().getSimpleName(), "password incorrect");
            return false;
        }
        if(!loginService.isValidUserId(username)) {
            Log.e(getClass().getSimpleName(), "user not present");
            return false;
        }
        return true;
    }

    public static boolean evaluateMvel(String expression, HashMap<String, Object> dataContext) {
        try {

//            VariableResolverFactory resolverFactory = new MapVariableResolverFactory(context);
            return MVEL.evalToBoolean(expression, dataContext);
        } catch (Throwable t) {
            Log.e(TAG, "Failed to evaluate mvel expression", t);
        }
        return false;
    }

    private void doLogin(final String username, final String password, MethodChannel.Result result){
        //TODO check if the machine is online, if offline check password hash locally
        Call<ResponseWrapper<String>> call = syncRestService.login(syncRestFactory.getAuthRequest(username, password));

        call.enqueue(new Callback<ResponseWrapper<String>>() {
            @Override
            public void onResponse(Call call, Response response) {
                ResponseWrapper<String> wrapper = (ResponseWrapper<String>) response.body();
                System.out.println("Username and password");
                System.out.println("Wrapper Response: " + wrapper.getResponse());
                if(response.isSuccessful()) {
                    ServiceError error = SyncRestUtil.getServiceError(wrapper);
                    if(error == null) {
                        try {
                            loginService.saveAuthToken(wrapper.getResponse());
                            login_response = wrapper.getResponse();
                            responseMap.put("isLoggedIn", "true");
                            responseMap.put("login_response", login_response);
                            object = new JSONObject(responseMap);
                            result.success(object);
                            return;
                        } catch (InvalidMachineSpecIDException e) {
                            error = new ServiceError("", e.getMessage());
                            Log.e(getClass().getSimpleName(), "Failed to save auth token", e);
                        } catch (Exception e) {
                            error = new ServiceError("", e.getMessage());
                            Log.e(getClass().getSimpleName(), "Failed to save auth token", e);
                        }
                    }

                    Log.e(getClass().getSimpleName(), "Some error occurred! " + error);
                    login_response = error == null ? "Login Failed! Try Again" : "Error: " + error.getMessage();
                    responseMap.put("isLoggedIn", "false");
                    responseMap.put("login_response", login_response);
                    object = new JSONObject(responseMap);
                    result.success(object.toString());
                    return;
                }
                login_response = "Login Failed! Try Again";
                responseMap.put("isLoggedIn", "false");
                responseMap.put("login_response", login_response);
                object = new JSONObject(responseMap);
                result.success(object.toString());
            }

            @Override
            public void onFailure(Call call, Throwable t) {
                Log.e(getClass().getSimpleName(), "Login Failure! ");
                result.error("404", "Custom error", null);
            }
        });
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CALL_APP_COMP)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("callComponent")) {
                                AppComponent appComponent = DaggerAppComponent.builder()
                                        .application(getApplication())
                                        .networkModule(new NetworkModule(getApplication()))
                                        .roomModule(new RoomModule(getApplication()))
                                        .appModule(new AppModule(getApplication()))
                                        .build();

                                appComponent.inject(this);

                            }
                        }
                );


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_TEST)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("testMachine")) {
                                Map<String, String> details =
                                        clientCryptoManagerService.getMachineDetails();

                                if(details.get("name") == null) {
                                    result.error("ERR-INITIALIZATION-FAILED",
                                            "Machine details could not be fetched!",
                                            "Failed to initialize the machine. Try to clear the app data and cache before reinstalling the app.");
                                }

                                JSONObject jsonObject = new JSONObject(details);

                                try {
                                    jsonObject.put("version", "Alpha");
                                } catch (JSONException e) {
                                    Log.e(getClass().getSimpleName(), e.getMessage(), e);
                                    result.error("JSON-ERROR",
                                            "Machine details could not be fetched!",
                                            "Failed to initialize the machine. Try to clear the app data and cache before reinstalling the app.");
                                }
                                result.success(jsonObject.toString());

                            } else {
                                result.notImplemented();
                            }
                        }
                );


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_LOGIN)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("login")) {
                                String username = call.argument("username");
                                String password = call.argument("password");


                                auditManagerService.audit(AuditEvent.LOGIN_WITH_PASSWORD, Components.LOGIN);
                                //validate form
                                if(validateLogin(username, password)){
                                    doLogin(username, password, result);



                                } else {
                                    result.error("VALIDATION_FAILED","User validation failed!", null);
                                }
                                jobManagerService.refreshAllJobs();
                                auditManagerService.audit(AuditEvent.LOADED_LOGIN, Components.LOGIN);
                            } else {
                                result.notImplemented();
                            }
                        }
                );

                new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), VALIDATE_MVEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("evaluateMvel")) {
                                HashMap<String, Object> dataContext = new HashMap<String, Object>();
                                String mvelExpressionFromChannel = call.argument("mvelExpression");
                                dataContext = call.argument("dataContext");

                                System.out.println("DataContext: " + dataContext);
                                System.out.println("MVEL Expression is: {" + mvelExpressionFromChannel + "} and MVEL Response is: " + evaluateMvel(mvelExpressionFromChannel, dataContext));
                                result.success(dataContext);
                            } else {
                                result.notImplemented();
                            }
                        }
                );

//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_SYNC)
//                .setMethodCallHandler(
//                        (call, result) -> {
//                            if(call.method.equals("masterDataSync")) {
//
//                            } else {
//                                result.notImplemented();
//                            }
//                        }
//                );
    }
}
