package com.roadsense.logger.core.data.database.dao

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
}
