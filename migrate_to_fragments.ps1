# Save as: migrate_to_fragments.ps1
Write-Host "Migrating to Fragment Architecture..." -ForegroundColor Green

# 1. Create new MainActivity with Navigation
$mainActivity = 'package com.roadsense.logger

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.roadsense.logger.core.bluetooth.BluetoothHandler
import com.roadsense.logger.core.bluetooth.PermissionHelper
import com.roadsense.logger.databinding.ActivityMainBinding
import timber.log.Timber

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var bluetoothHandler: BluetoothHandler
    private lateinit var permissionHelper: PermissionHelper

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        Timber.d("🎬 MainActivity created with Navigation")

        // Initialize Bluetooth components
        permissionHelper = PermissionHelper(this)
        bluetoothHandler = BluetoothHandler(this, permissionHelper)

        // Setup Bottom Navigation
        val navView: BottomNavigationView = binding.navView
        val navController = findNavController(R.id.nav_host_fragment_activity_main)
        
        val appBarConfiguration = AppBarConfiguration(
            setOf(
                R.id.navigation_home,
                R.id.navigation_survey,
                R.id.navigation_results,
                R.id.navigation_reports
            )
        )
        
        setupActionBarWithNavController(navController, appBarConfiguration)
        navView.setupWithNavController(navController)
        
        // Setup navigation item selection listener
        navView.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.navigation_home -> {
                    Timber.d("🏠 Home tab selected")
                    true
                }
                R.id.navigation_survey -> {
                    Timber.d("📊 Survey tab selected")
                    true
                }
                R.id.navigation_results -> {
                    Timber.d("📈 Results tab selected")
                    true
                }
                R.id.navigation_reports -> {
                    Timber.d("📋 Reports tab selected")
                    true
                }
                else -> false
            }
        }
        
        // Pass Bluetooth handler to application context
        (application as RoadsenseApplication).bluetoothHandler = bluetoothHandler
    }
    
    override fun onDestroy() {
        super.onDestroy()
        bluetoothHandler.cleanup()
    }
}'

# Save the new MainActivity
$mainActivityPath = ".\app\src\main\java\com\roadsense\logger\MainActivity.kt"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($mainActivityPath, $mainActivity, $utf8NoBom)
Write-Host "✅ Created new MainActivity with Navigation" -ForegroundColor Green

# 2. Update RoadsenseApplication to hold BluetoothHandler
$appClass = 'package com.roadsense.logger

import android.app.Application
import com.roadsense.logger.core.bluetooth.BluetoothHandler
import timber.log.Timber

class RoadsenseApplication : Application() {
    
    var bluetoothHandler: BluetoothHandler? = null
    
    override fun onCreate() {
        super.onCreate()
        Timber.plant(Timber.DebugTree())
        Timber.d("🚀 Application started")
    }
}'

$appPath = ".\app\src\main\java\com\roadsense\logger\RoadsenseApplication.kt"
[System.IO.File]::WriteAllText($appPath, $appClass, $utf8NoBom)
Write-Host "✅ Updated RoadsenseApplication" -ForegroundColor Green

# 3. Create SharedViewModel
$viewModelDir = ".\app\src\main\java\com\roadsense\logger\ui\viewmodels"
New-Item -ItemType Directory -Force -Path $viewModelDir | Out-Null

$sharedViewModel = 'package com.roadsense.logger.ui.viewmodels

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
}'

$sharedViewModelPath = "$viewModelDir\SharedViewModel.kt"
[System.IO.File]::WriteAllText($sharedViewModelPath, $sharedViewModel, $utf8NoBom)
Write-Host "✅ Created SharedViewModel" -ForegroundColor Green

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Migration Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nNext Steps:" -ForegroundColor White
Write-Host "1. Update HomeFragment with Bluetooth UI" -ForegroundColor Gray
Write-Host "2. Update fragment_home.xml layout" -ForegroundColor Gray
Write-Host "3. Build and test: .\gradlew assembleDebug" -ForegroundColor Gray