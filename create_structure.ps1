# Save as: create_structure.ps1
# Run: .\create_structure.ps1

Write-Host "Creating Roadsense Logger Folder Structure..." -ForegroundColor Green

# Base directory
$baseDir = ".\app\src\main\java\com\roadsense\logger"

# Create core directories
$coreDirs = @(
    "core\data\database\dao",
    "core\data\database\entities",
    "core\data\models",
    "core\data\repository",
    "core\bluetooth",
    "core\utils",
    "ui\home",
    "ui\survey", 
    "ui\results",
    "ui\reports",
    "ui\viewmodels",
    "ui\adapters"
)

foreach ($dir in $coreDirs) {
    $fullPath = Join-Path $baseDir $dir
    New-Item -ItemType Directory -Force -Path $fullPath | Out-Null
    Write-Host "Created: $dir" -ForegroundColor Cyan
}

# Create empty Kotlin files with package declarations
$files = @{
    "core\data\database\RoadsenseDatabase.kt" = 'package com.roadsense.logger.core.data.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.roadsense.logger.core.data.database.dao.ProjectDao
import com.roadsense.logger.core.data.database.dao.SegmentDao
import com.roadsense.logger.core.data.database.dao.SurveyDataDao
import com.roadsense.logger.core.data.database.entities.ProjectEntity
import com.roadsense.logger.core.data.database.entities.RoadSegmentEntity
import com.roadsense.logger.core.data.database.entities.SurveyDataEntity

@Database(
    entities = [ProjectEntity::class, RoadSegmentEntity::class, SurveyDataEntity::class],
    version = 1,
    exportSchema = false
)
abstract class RoadsenseDatabase : RoomDatabase() {
    
    abstract fun projectDao(): ProjectDao
    abstract fun segmentDao(): SegmentDao
    abstract fun surveyDataDao(): SurveyDataDao
    
    companion object {
        @Volatile
        private var INSTANCE: RoadsenseDatabase? = null
        
        fun getDatabase(context: Context): RoadsenseDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    RoadsenseDatabase::class.java,
                    "roadsense_database"
                )
                .fallbackToDestructiveMigration()
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
}'

    "core\data\database\dao\ProjectDao.kt" = 'package com.roadsense.logger.core.data.database.dao

import androidx.room.*
import com.roadsense.logger.core.data.database.entities.ProjectEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ProjectDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(project: ProjectEntity): Long
    
    @Update
    suspend fun update(project: ProjectEntity)
    
    @Delete
    suspend fun delete(project: ProjectEntity)
    
    @Query("SELECT * FROM projects ORDER BY createdDate DESC")
    fun getAllProjects(): Flow<List<ProjectEntity>>
    
    @Query("SELECT * FROM projects WHERE id = :id")
    suspend fun getProjectById(id: String): ProjectEntity?
    
    @Query("DELETE FROM projects WHERE id = :id")
    suspend fun deleteById(id: String)
}'

    "core\data\database\dao\SegmentDao.kt" = 'package com.roadsense.logger.core.data.database.dao

import androidx.room.*
import com.roadsense.logger.core.data.database.entities.RoadSegmentEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SegmentDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(segment: RoadSegmentEntity): Long
    
    @Update
    suspend fun update(segment: RoadSegmentEntity)
    
    @Query("SELECT * FROM road_segments WHERE projectId = :projectId ORDER BY startTime DESC")
    fun getSegmentsByProject(projectId: String): Flow<List<RoadSegmentEntity>>
    
    @Query("SELECT * FROM road_segments WHERE id = :id")
    suspend fun getSegmentById(id: String): RoadSegmentEntity?
    
    @Query("DELETE FROM road_segments WHERE id = :id")
    suspend fun deleteById(id: String)
    
    @Query("SELECT COUNT(*) FROM road_segments WHERE projectId = :projectId")
    suspend fun getSegmentCount(projectId: String): Int
}'

    "core\data\database\dao\SurveyDataDao.kt" = 'package com.roadsense.logger.core.data.database.dao

import androidx.room.*
import com.roadsense.logger.core.data.database.entities.SurveyDataEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SurveyDataDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(data: SurveyDataEntity)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(data: List<SurveyDataEntity>)
    
    @Query("SELECT * FROM survey_data WHERE segmentId = :segmentId ORDER BY chainage ASC")
    fun getBySegmentId(segmentId: String): Flow<List<SurveyDataEntity>>
    
    @Query("SELECT * FROM survey_data WHERE segmentId = :segmentId AND chainage BETWEEN :start AND :end")
    fun getBySegmentAndRange(segmentId: String, start: Float, end: Float): Flow<List<SurveyDataEntity>>
    
    @Query("DELETE FROM survey_data WHERE segmentId = :segmentId")
    suspend fun deleteBySegmentId(segmentId: String)
    
    @Query("SELECT COUNT(*) FROM survey_data WHERE segmentId = :segmentId")
    suspend fun getDataCount(segmentId: String): Int
}'

    "core\data\database\entities\ProjectEntity.kt" = 'package com.roadsense.logger.core.data.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "projects")
data class ProjectEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String = "",
    val location: String = "",
    val createdDate: Long = System.currentTimeMillis(),
    val lastModified: Long = System.currentTimeMillis()
)'

    "core\data\database\entities\RoadSegmentEntity.kt" = 'package com.roadsense.logger.core.data.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "road_segments",
    foreignKeys = [
        ForeignKey(
            entity = ProjectEntity::class,
            parentColumns = ["id"],
            childColumns = ["projectId"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
data class RoadSegmentEntity(
    @PrimaryKey
    val id: String,
    val projectId: String,
    val name: String,
    val designLength: Float,
    val actualLength: Float = 0f,
    val startSta: String = "0+000",
    val endSta: String = "0+000",
    val startTime: Long,
    val endTime: Long = 0L,
    val surveyor: String = "",
    val weather: String = "",
    val notes: String = "",
    val isCompleted: Boolean = false
)'

    "core\data\database\entities\SurveyDataEntity.kt" = 'package com.roadsense.logger.core.data.database.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "survey_data",
    foreignKeys = [
        ForeignKey(
            entity = RoadSegmentEntity::class,
            parentColumns = ["id"],
            childColumns = ["segmentId"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
data class SurveyDataEntity(
    @PrimaryKey
    val id: String,
    val segmentId: String,
    val timestamp: Long,
    val sta: String,
    val chainage: Float,
    val speed: Float,
    val vibrationZ: Float,
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val packetCount: Int = 0
)'

    "core\data\models\Project.kt" = 'package com.roadsense.logger.core.data.models

import java.util.*

data class Project(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val description: String = "",
    val location: String = "",
    val createdDate: Long = System.currentTimeMillis(),
    val lastModified: Long = System.currentTimeMillis()
)'

    "core\data\models\RoadSegment.kt" = 'package com.roadsense.logger.core.data.models

import java.util.*

data class RoadSegment(
    val id: String = UUID.randomUUID().toString(),
    val projectId: String,
    val name: String,
    val designLength: Float,
    var actualLength: Float = 0f,
    val startSta: String = "0+000",
    var endSta: String = "0+000",
    val startTime: Long = System.currentTimeMillis(),
    var endTime: Long = 0L,
    val surveyor: String = "",
    val weather: String = "",
    val notes: String = "",
    var isCompleted: Boolean = false
) {
    val lengthDifference: Float get() = actualLength - designLength
    val differencePercentage: Float get() = if (designLength > 0) (lengthDifference / designLength) * 100 else 0f
}'

    "core\data\models\SurveyData.kt" = 'package com.roadsense.logger.core.data.models

import java.util.UUID

data class SurveyData(
    val id: String = UUID.randomUUID().toString(),
    val segmentId: String,
    val timestamp: Long = System.currentTimeMillis(),
    val sta: String,
    val chainage: Float,
    val speed: Float,
    val vibrationZ: Float,
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val packetCount: Int = 0
)'

    "core\data\repository\RoadsenseRepository.kt" = 'package com.roadsense.logger.core.data.repository

import com.roadsense.logger.core.data.database.RoadsenseDatabase
import com.roadsense.logger.core.data.models.Project
import com.roadsense.logger.core.data.models.RoadSegment
import com.roadsense.logger.core.data.models.SurveyData
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class RoadsenseRepository(private val database: RoadsenseDatabase) {
    
    suspend fun createProject(project: Project): Long {
        val entity = project.toEntity()
        return database.projectDao().insert(entity)
    }
    
    fun getAllProjects(): Flow<List<Project>> {
        return database.projectDao().getAllProjects()
            .map { entities -> entities.map { it.toModel() } }
    }
    
    suspend fun getProjectById(id: String): Project? {
        return database.projectDao().getProjectById(id)?.toModel()
    }
    
    suspend fun createSegment(segment: RoadSegment): Long {
        val entity = segment.toEntity()
        return database.segmentDao().insert(entity)
    }
    
    fun getSegmentsByProject(projectId: String): Flow<List<RoadSegment>> {
        return database.segmentDao().getSegmentsByProject(projectId)
            .map { entities -> entities.map { it.toModel() } }
    }
    
    suspend fun updateSegment(segment: RoadSegment) {
        database.segmentDao().update(segment.toEntity())
    }
    
    suspend fun saveSurveyData(data: SurveyData) {
        database.surveyDataDao().insert(data.toEntity())
    }
    
    suspend fun saveSurveyDataBatch(data: List<SurveyData>) {
        database.surveyDataDao().insertAll(data.map { it.toEntity() })
    }
    
    fun getSurveyDataBySegment(segmentId: String): Flow<List<SurveyData>> {
        return database.surveyDataDao().getBySegmentId(segmentId)
            .map { entities -> entities.map { it.toModel() } }
    }
}'

    "core\data\models\ModelExtensions.kt" = 'package com.roadsense.logger.core.data.models

import com.roadsense.logger.core.data.database.entities.ProjectEntity
import com.roadsense.logger.core.data.database.entities.RoadSegmentEntity
import com.roadsense.logger.core.data.database.entities.SurveyDataEntity

fun Project.toEntity(): ProjectEntity {
    return ProjectEntity(
        id = id,
        name = name,
        description = description,
        location = location,
        createdDate = createdDate,
        lastModified = lastModified
    )
}

fun ProjectEntity.toModel(): Project {
    return Project(
        id = id,
        name = name,
        description = description,
        location = location,
        createdDate = createdDate,
        lastModified = lastModified
    )
}

fun RoadSegment.toEntity(): RoadSegmentEntity {
    return RoadSegmentEntity(
        id = id,
        projectId = projectId,
        name = name,
        designLength = designLength,
        actualLength = actualLength,
        startSta = startSta,
        endSta = endSta,
        startTime = startTime,
        endTime = endTime,
        surveyor = surveyor,
        weather = weather,
        notes = notes,
        isCompleted = isCompleted
    )
}

fun RoadSegmentEntity.toModel(): RoadSegment {
    return RoadSegment(
        id = id,
        projectId = projectId,
        name = name,
        designLength = designLength,
        actualLength = actualLength,
        startSta = startSta,
        endSta = endSta,
        startTime = startTime,
        endTime = endTime,
        surveyor = surveyor,
        weather = weather,
        notes = notes,
        isCompleted = isCompleted
    )
}

fun SurveyData.toEntity(): SurveyDataEntity {
    return SurveyDataEntity(
        id = id,
        segmentId = segmentId,
        timestamp = timestamp,
        sta = sta,
        chainage = chainage,
        speed = speed,
        vibrationZ = vibrationZ,
        latitude = latitude,
        longitude = longitude,
        packetCount = packetCount
    )
}

fun SurveyDataEntity.toModel(): SurveyData {
    return SurveyData(
        id = id,
        segmentId = segmentId,
        timestamp = timestamp,
        sta = sta,
        chainage = chainage,
        speed = speed,
        vibrationZ = vibrationZ,
        latitude = latitude,
        longitude = longitude,
        packetCount = packetCount
    )
}'

    "ui\home\HomeFragment.kt" = 'package com.roadsense.logger.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.roadsense.logger.databinding.FragmentHomeBinding

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}'

    "ui\home\HomeViewModel.kt" = 'package com.roadsense.logger.ui.home

import androidx.lifecycle.ViewModel

class HomeViewModel : ViewModel() {
    // TODO: Implement the ViewModel
}'

    "ui\survey\SurveyFragment.kt" = 'package com.roadsense.logger.ui.survey

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.roadsense.logger.databinding.FragmentSurveyBinding

class SurveyFragment : Fragment() {

    private var _binding: FragmentSurveyBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentSurveyBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}'

    "ui\survey\SurveyViewModel.kt" = 'package com.roadsense.logger.ui.survey

import androidx.lifecycle.ViewModel

class SurveyViewModel : ViewModel() {
    // TODO: Implement the ViewModel
}'

    "ui\results\ResultsFragment.kt" = 'package com.roadsense.logger.ui.results

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.roadsense.logger.databinding.FragmentResultsBinding

class ResultsFragment : Fragment() {

    private var _binding: FragmentResultsBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentResultsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}'

    "ui\results\ResultsViewModel.kt" = 'package com.roadsense.logger.ui.results

import androidx.lifecycle.ViewModel

class ResultsViewModel : ViewModel() {
    // TODO: Implement the ViewModel
}'

    "ui\reports\ReportsFragment.kt" = 'package com.roadsense.logger.ui.reports

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.roadsense.logger.databinding.FragmentReportsBinding

class ReportsFragment : Fragment() {

    private var _binding: FragmentReportsBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentReportsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}'

    "ui\reports\ReportsViewModel.kt" = 'package com.roadsense.logger.ui.reports

import androidx.lifecycle.ViewModel

class ReportsViewModel : ViewModel() {
    // TODO: Implement the ViewModel
}'

    "ui\viewmodels\SharedViewModel.kt" = 'package com.roadsense.logger.ui.viewmodels

import androidx.lifecycle.ViewModel

class SharedViewModel : ViewModel() {
    // Shared data between fragments
}'

    "core\utils\FileExporter.kt" = 'package com.roadsense.logger.core.utils

import android.content.Context
import java.io.File

class FileExporter(private val context: Context) {
    
    fun exportToCsv(data: List<String>, filename: String): File {
        val file = File(context.getExternalFilesDir(null), filename)
        file.writeText(data.joinToString("\n"))
        return file
    }
    
    fun exportToPdf(data: List<String>, filename: String): File {
        val file = File(context.getExternalFilesDir(null), filename)
        file.writeText("PDF Export - Coming Soon\n\n" + data.joinToString("\n"))
        return file
    }
}'

    "core\utils\StaCalculator.kt" = 'package com.roadsense.logger.core.utils

object StaCalculator {
    
    fun formatSta(distance: Float): String {
        val km = distance.toInt() / 1000
        val m = distance.toInt() % 1000
        return "${km}+${String.format("%03d", m)}"
    }
    
    fun parseSta(sta: String): Float {
        return try {
            val parts = sta.split("+")
            if (parts.size == 2) {
                val km = parts[0].toFloat() * 1000
                val m = parts[1].toFloat()
                km + m
            } else {
                0f
            }
        } catch (e: Exception) {
            0f
        }
    }
    
    fun calculateChainage(startSta: String, currentSta: String): Float {
        val start = parseSta(startSta)
        val current = parseSta(currentSta)
        return current - start
    }
}'
}

foreach ($file in $files.GetEnumerator()) {
    $filePath = Join-Path $baseDir $file.Key
    $directory = Split-Path $filePath
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $file.Value | Out-File -FilePath $filePath -Encoding UTF8
    Write-Host "Created file: $($file.Key)" -ForegroundColor Green
}

# Create layout directories
$layoutDirs = @("layout", "navigation", "menu")

foreach ($dir in $layoutDirs) {
    $fullPath = ".\app\src\main\res\$dir"
    New-Item -ItemType Directory -Force -Path $fullPath | Out-Null
    Write-Host "Created layout dir: $dir" -ForegroundColor Yellow
}

# Create XML files
$xmlFiles = @{
    "navigation\mobile_navigation.xml" = '<?xml version="1.0" encoding="utf-8"?>
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
</navigation>'

    "menu\bottom_nav_menu.xml" = '<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/navigation_home" android:icon="@drawable/ic_home" android:title="@string/title_home" />
    <item android:id="@+id/navigation_survey" android:icon="@drawable/ic_survey" android:title="@string/title_survey" />
    <item android:id="@+id/navigation_results" android:icon="@drawable/ic_results" android:title="@string/title_results" />
    <item android:id="@+id/navigation_reports" android:icon="@drawable/ic_reports" android:title="@string/title_reports" />
</menu>'

    "layout\fragment_home.xml" = '<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".ui.home.HomeFragment">
    <TextView android:layout_width="match_parent" android:layout_height="match_parent"
        android:text="Home Fragment - Raw Data Mode" android:gravity="center" android:textSize="24sp"/>
</FrameLayout>'

    "layout\fragment_survey.xml" = '<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".ui.survey.SurveyFragment">
    <TextView android:layout_width="match_parent" android:layout_height="match_parent"
        android:text="Survey Fragment - Professional Mode" android:gravity="center" android:textSize="24sp"/>
</FrameLayout>'

    "layout\fragment_results.xml" = '<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".ui.results.ResultsFragment">
    <TextView android:layout_width="match_parent" android:layout_height="match_parent"
        android:text="Results Fragment - Data View" android:gravity="center" android:textSize="24sp"/>
</FrameLayout>'

    "layout\fragment_reports.xml" = '<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".ui.reports.ReportsFragment">
    <TextView android:layout_width="match_parent" android:layout_height="match_parent"
        android:text="Reports Fragment - Summary" android:gravity="center" android:textSize="24sp"/>
</FrameLayout>'
}

foreach ($file in $xmlFiles.GetEnumerator()) {
    $filePath = ".\app\src\main\res\$($file.Key)"
    $directory = Split-Path $filePath
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $file.Value | Out-File -FilePath $filePath -Encoding UTF8
    Write-Host "Created XML: $($file.Key)" -ForegroundColor Magenta
}

# Update strings.xml
$stringsDir = ".\app\src\main\res\values"
$stringsPath = "$stringsDir\strings.xml"

New-Item -ItemType Directory -Force -Path $stringsDir | Out-Null

if (Test-Path $stringsPath) {
    $existingContent = Get-Content $stringsPath -Raw
    if (-not ($existingContent -match "title_home")) {
        $newStrings = "    <string name=`"title_home`">Raw Data</string>`n    <string name=`"title_survey`">Survey</string>`n    <string name=`"title_results`">Results</string>`n    <string name=`"title_reports`">Reports</string>"
        $updatedContent = $existingContent -replace '</resources>', "$newStrings`n</resources>"
        $updatedContent | Out-File -FilePath $stringsPath -Encoding UTF8
        Write-Host "Updated strings.xml" -ForegroundColor Green
    } else {
        Write-Host "strings.xml already updated" -ForegroundColor Yellow
    }
} else {
    $stringsContent = '<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Roadsense Logger</string>
    <string name="title_home">Raw Data</string>
    <string name="title_survey">Survey</string>
    <string name="title_results">Results</string>
    <string name="title_reports">Reports</string>
</resources>'
    $stringsContent | Out-File -FilePath $stringsPath -Encoding UTF8
    Write-Host "Created strings.xml" -ForegroundColor Green
}

Write-Host "`nFolder structure created successfully!" -ForegroundColor Green
Write-Host "Total directories: $($coreDirs.Count + $layoutDirs.Count)" -ForegroundColor Yellow
Write-Host "Total files: $($files.Count + $xmlFiles.Count)" -ForegroundColor Yellow
Write-Host "`nLocation: $baseDir" -ForegroundColor Cyan