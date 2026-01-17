package com.roadsense.logger.core.data.database

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
}
