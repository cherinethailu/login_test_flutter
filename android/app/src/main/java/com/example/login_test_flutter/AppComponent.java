package com.example.login_test_flutter;

import android.app.Application;

import javax.inject.Singleton;

import dagger.BindsInstance;
import dagger.Component;
import dagger.android.AndroidInjector;
import dagger.android.support.AndroidSupportInjectionModule;
import io.flutter.embedding.android.FlutterActivity;
import io.mosip.registration.clientmanager.config.AppModule;
import io.mosip.registration.clientmanager.config.NetworkModule;
import io.mosip.registration.clientmanager.config.RoomModule;

@Singleton
@Component(
        modules = {
                AndroidSupportInjectionModule.class,
                NetworkModule.class,
                RoomModule.class,
                AppModule.class
        }
)
public interface AppComponent  extends AndroidInjector<FlutterActivity> {

    void inject(MainActivity mainActivity);

    @Component.Builder
    interface Builder{
        @BindsInstance
        Builder application(Application application);
        Builder networkModule(NetworkModule networkModule);
        Builder roomModule(RoomModule roomModule);
        Builder appModule(AppModule appModule);
        //        Builder activityBuildersModule(ActivityBuildersModule activityBuildersModule);
        AppComponent build();
    }

}
