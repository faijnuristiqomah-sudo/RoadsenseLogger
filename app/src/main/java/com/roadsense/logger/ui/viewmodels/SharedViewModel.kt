package com.roadsense.logger.ui.viewmodels

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.roadsense.logger.core.bluetooth.BluetoothHandler
import kotlinx.coroutines.launch

class SharedViewModel : ViewModel() {
    
    // Bluetooth connection state
    private val _connectionStatus = MutableLiveData<String>("Disconnected")
    val connectionStatus: LiveData<String> = _connectionStatus
    
    private val _deviceName = MutableLiveData<String>("No Device")
    val deviceName: LiveData<String> = _deviceName
    
    private val _isConnected = MutableLiveData<Boolean>(false)
    val isConnected: LiveData<Boolean> = _isConnected
    
    private val _speed = MutableLiveData<Float>(0f)
    val speed: LiveData<Float> = _speed
    
    private val _odometer = MutableLiveData<Float>(0f)
    val odometer: LiveData<Float> = _odometer
    
    private val _tripDistance = MutableLiveData<Float>(0f)
    val tripDistance: LiveData<Float> = _tripDistance
    
    // Bluetooth handler instance
    private var bluetoothHandler: BluetoothHandler? = null
    
    fun initializeBluetoothHandler(handler: BluetoothHandler) {
        bluetoothHandler = handler
        bluetoothHandler?.setCallback(object : BluetoothHandler.BluetoothCallback {
            override fun onConnectionStateChanged(state: Int) {
                viewModelScope.launch {
                    val connected = state == BluetoothHandler.STATE_CONNECTED
                    _isConnected.value = connected
                    _connectionStatus.value = if (connected) "Connected" else "Disconnected"
                }
            }
            
            override fun onDataReceived(data: BluetoothHandler.RoadsenseData) {
                viewModelScope.launch {
                    _speed.value = data.speedKmh
                    _odometer.value = data.odometerM
                    _tripDistance.value = data.tripDistanceM
                }
            }
            
            override fun onDeviceConnected(deviceName: String) {
                viewModelScope.launch {
                    _deviceName.value = deviceName
                }
            }
            
            override fun onMessageReceived(message: String) {
                // Handle messages
            }
            
            override fun onError(errorMessage: String) {
                // Handle errors
            }
        })
    }
    
    fun connectToESP32() {
        bluetoothHandler?.connectToESP32()
    }
    
    fun disconnect() {
        bluetoothHandler?.disconnect()
    }
    
    fun startLogging() {
        bluetoothHandler?.startLogging()
    }
    
    fun stopLogging() {
        bluetoothHandler?.stopLogging()
    }
    
    fun pauseLogging() {
        bluetoothHandler?.pauseLogging()
    }
    
    fun resetTrip() {
        bluetoothHandler?.resetTrip()
    }
    
    override fun onCleared() {
        super.onCleared()
        bluetoothHandler?.cleanup()
    }
}