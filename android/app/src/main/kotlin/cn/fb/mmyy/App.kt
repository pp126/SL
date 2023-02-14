package cn.fb.dryy

import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.NotificationFoldStyle
import com.netease.nimlib.sdk.SDKOptions
import com.netease.nimlib.sdk.StatusBarNotificationConfig
import io.flutter.app.FlutterApplication

class App : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        val options = SDKOptions().apply {
            statusBarNotificationConfig = StatusBarNotificationConfig().apply {
                notificationFoldStyle = NotificationFoldStyle.CONTACT
            }
        }

        NIMClient.init(this, null, options)
        NIMClient.toggleNotification(true)
    }
}
