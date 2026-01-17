# Save as: fix_activity_layout.ps1
Write-Host "Fixing MainActivity layout and references..." -ForegroundColor Green

# 1. Create activity_main.xml
$layoutDir = ".\app\src\main\res\layout"
New-Item -ItemType Directory -Force -Path $layoutDir | Out-Null

$activityLayout = @'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout 
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <fragment
        android:id="@+id/nav_host_fragment_activity_main"
        android:name="androidx.navigation.fragment.NavHostFragment"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        app:defaultNavHost="true"
        app:layout_constraintBottom_toTopOf="@+id/nav_view"
        app:layout_constraintLeft_toLeftOf="parent"
        app:layout_constraintRight_toRightOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:navGraph="@navigation/mobile_navigation" />

    <com.google.android.material.bottomnavigation.BottomNavigationView
        android:id="@+id/nav_view"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="0dp"
        android:layout_marginEnd="0dp"
        android:background="?android:attr/windowBackground"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintLeft_toLeftOf="parent"
        app:layout_constraintRight_toRightOf="parent"
        app:menu="@menu/bottom_nav_menu" />

</androidx.constraintlayout.widget.ConstraintLayout>
'@

$activityLayoutPath = "$layoutDir\activity_main.xml"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($activityLayoutPath, $activityLayout, $utf8NoBom)
Write-Host "Created activity_main.xml" -ForegroundColor Green

# 2. Update MainActivity.kt
$mainActivityPath = ".\app\src\main\java\com\roadsense\logger\MainActivity.kt"

$mainActivityCode = @'
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
'@

[System.IO.File]::WriteAllText($mainActivityPath, $mainActivityCode, $utf8NoBom)
Write-Host "Updated MainActivity.kt" -ForegroundColor Green

# 3. Ensure Navigation and Menu files exist
Write-Host "`nChecking navigation resources..." -ForegroundColor Yellow

$navDir = ".\app\src\main\res\navigation"
$menuDir = ".\app\src\main\res\menu"

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path $navDir | Out-Null
New-Item -ItemType Directory -Force -Path $menuDir | Out-Null

# Check if mobile_navigation.xml exists
$navFile = "$navDir\mobile_navigation.xml"
if (-not (Test-Path $navFile)) {
    $navXml = @'
<?xml version="1.0" encoding="utf-8"?>
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/mobile_navigation"
    app:startDestination="@id/navigation_home">
    
    <fragment
        android:id="@+id/navigation_home"
        android:name="com.roadsense.logger.ui.home.HomeFragment"
        android:label="@string/title_home"
        tools:layout="@layout/fragment_home" />
        
    <fragment
        android:id="@+id/navigation_survey"
        android:name="com.roadsense.logger.ui.survey.SurveyFragment"
        android:label="@string/title_survey"
        tools:layout="@layout/fragment_survey" />
        
    <fragment
        android:id="@+id/navigation_results"
        android:name="com.roadsense.logger.ui.results.ResultsFragment"
        android:label="@string/title_results"
        tools:layout="@layout/fragment_results" />
        
    <fragment
        android:id="@+id/navigation_reports"
        android:name="com.roadsense.logger.ui.reports.ReportsFragment"
        android:label="@string/title_reports"
        tools:layout="@layout/fragment_reports" />
        
</navigation>
'@
    
    [System.IO.File]::WriteAllText($navFile, $navXml, $utf8NoBom)
    Write-Host "Created mobile_navigation.xml" -ForegroundColor Green
} else {
    Write-Host "mobile_navigation.xml already exists" -ForegroundColor Yellow
}

# Check if bottom_nav_menu.xml exists
$menuFile = "$menuDir\bottom_nav_menu.xml"
if (-not (Test-Path $menuFile)) {
    $menuXml = @'
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    
    <item 
        android:id="@+id/navigation_home" 
        android:title="@string/title_home" />
        
    <item 
        android:id="@+id/navigation_survey" 
        android:title="@string/title_survey" />
        
    <item 
        android:id="@+id/navigation_results" 
        android:title="@string/title_results" />
        
    <item 
        android:id="@+id/navigation_reports" 
        android:title="@string/title_reports" />
        
</menu>
'@
    
    [System.IO.File]::WriteAllText($menuFile, $menuXml, $utf8NoBom)
    Write-Host "Created bottom_nav_menu.xml" -ForegroundColor Green
} else {
    Write-Host "bottom_nav_menu.xml already exists" -ForegroundColor Yellow
}

# 4. Check strings.xml
$valuesDir = ".\app\src\main\res\values"
$stringsFile = "$valuesDir\strings.xml"

if (Test-Path $stringsFile) {
    $content = Get-Content $stringsFile -Raw
    if (-not $content.Contains("title_home")) {
        $newStrings = @'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Roadsense Logger</string>
    <string name="title_home">Raw Data</string>
    <string name="title_survey">Survey</string>
    <string name="title_results">Results</string>
    <string name="title_reports">Reports</string>
</resources>
'@
        
        [System.IO.File]::WriteAllText($stringsFile, $newStrings, $utf8NoBom)
        Write-Host "Updated strings.xml" -ForegroundColor Green
    } else {
        Write-Host "strings.xml already has navigation titles" -ForegroundColor Yellow
    }
} else {
    Write-Host "strings.xml not found" -ForegroundColor Red
}

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Layout and Navigation Fixed!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nNext Steps:" -ForegroundColor White
Write-Host "1. Build project: .\gradlew build" -ForegroundColor Gray
Write-Host "2. Sync project in Android Studio" -ForegroundColor Gray
Write-Host "3. Run app to test navigation" -ForegroundColor Gray