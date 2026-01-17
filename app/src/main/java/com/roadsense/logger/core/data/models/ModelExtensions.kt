package com.roadsense.logger.core.data.models

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
}