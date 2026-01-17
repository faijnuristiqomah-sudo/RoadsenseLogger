package com.roadsense.logger

import android.app.Application
import com.roadsense.logger.core.bluetooth.BluetoothHandler
import timber.log.Timber

class RoadsenseApplication : Application() {
    
    var bluetoothHandler: BluetoothHandler? = null
    
    override fun onCreate() {
        super.onCreate()
        Timber.plant(Timber.DebugTree())
        Timber.d("ðŸš€ Application started")
    }
}