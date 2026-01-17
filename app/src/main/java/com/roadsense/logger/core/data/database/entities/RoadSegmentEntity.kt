package com.roadsense.logger.core.data.database.entities

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
)
