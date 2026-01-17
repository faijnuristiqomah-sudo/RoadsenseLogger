package com.roadsense.logger.core.data.repository

import com.roadsense.logger.core.data.database.RoadsenseDatabase
import com.roadsense.logger.core.data.models.Project
import com.roadsense.logger.core.data.models.RoadSegment
import com.roadsense.logger.core.data.models.SurveyData
import com.roadsense.logger.core.data.models.toEntity  // Import extension functions
import com.roadsense.logger.core.data.models.toModel  // Import extension functions
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
}