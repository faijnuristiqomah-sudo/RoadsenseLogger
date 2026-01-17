package com.roadsense.logger.core.data.models

import java.util.UUID

data class SurveyData(
    val id: String = UUID.randomUUID().toString(),
    val segmentId: String,
    val timestamp: Long = System.currentTimeMillis(),
    val sta: String,
    val chainage: Float,
    val speed: Float,
    val vibrationZ: Float,
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val packetCount: Int = 0
)
