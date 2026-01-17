package com.roadsense.logger.core.data.models

import java.util.*

data class Project(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val description: String = "",
    val location: String = "",
    val createdDate: Long = System.currentTimeMillis(),
    val lastModified: Long = System.currentTimeMillis()
)
