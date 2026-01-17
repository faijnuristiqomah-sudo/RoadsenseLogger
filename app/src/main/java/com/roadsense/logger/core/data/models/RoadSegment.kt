package com.roadsense.logger.core.data.models

import java.util.*

data class RoadSegment(
    val id: String = UUID.randomUUID().toString(),
    val projectId: String,
    val name: String,
    val designLength: Float,
    var actualLength: Float = 0f,
    val startSta: String = "0+000",
    var endSta: String = "0+000",
    val startTime: Long = System.currentTimeMillis(),
    var endTime: Long = 0L,
    val surveyor: String = "",
    val weather: String = "",
    val notes: String = "",
    var isCompleted: Boolean = false
) {
    val lengthDifference: Float get() = actualLength - designLength
    val differencePercentage: Float get() = if (designLength > 0) (lengthDifference / designLength) * 100 else 0f
}
