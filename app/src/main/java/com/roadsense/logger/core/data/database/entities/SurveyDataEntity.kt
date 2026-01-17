package com.roadsense.logger.core.data.database.entities

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
)
