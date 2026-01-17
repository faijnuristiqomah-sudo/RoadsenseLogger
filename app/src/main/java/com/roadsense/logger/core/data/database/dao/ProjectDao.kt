package com.roadsense.logger.core.data.database.dao

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
}
