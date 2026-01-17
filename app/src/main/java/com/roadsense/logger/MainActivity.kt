package com.roadsense.logger

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
        
        Timber.d("MainActivity created with Navigation")

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
                    Timber.d("Home tab selected")
                    true
                }
                R.id.navigation_survey -> {
                    Timber.d("Survey tab selected")
                    true
                }
                R.id.navigation_results -> {
                    Timber.d("Results tab selected")
                    true
                }
                R.id.navigation_reports -> {
                    Timber.d("Reports tab selected")
                    true
                }
                else -> false
            }
        }
        
        // Pass Bluetooth handler to application context
        (application as? RoadsenseApplication)?.bluetoothHandler = bluetoothHandler
    }
    
    override fun onDestroy() {
        super.onDestroy()
        bluetoothHandler.cleanup()
    }
}