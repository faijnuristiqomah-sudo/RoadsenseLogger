package com.roadsense.logger.core.utils

object StaCalculator {
    
    fun formatSta(distance: Float): String {
        val km = distance.toInt() / 1000
        val m = distance.toInt() % 1000
        return "${km}+${String.format("%03d", m)}"
    }
    
    fun parseSta(sta: String): Float {
        return try {
            val parts = sta.split("+")
            if (parts.size == 2) {
                val km = parts[0].toFloat() * 1000
                val m = parts[1].toFloat()
                km + m
            } else {
                0f
            }
        } catch (e: Exception) {
            0f
        }
    }
    
    fun calculateChainage(startSta: String, currentSta: String): Float {
        val start = parseSta(startSta)
        val current = parseSta(currentSta)
        return current - start
    }
}
