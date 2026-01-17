package com.roadsense.logger.core.data.database.entities

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
)
