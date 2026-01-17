package com.roadsense.logger.core.data.database.dao

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
}
