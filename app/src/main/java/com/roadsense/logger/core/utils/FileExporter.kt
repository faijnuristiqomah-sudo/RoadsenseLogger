package com.roadsense.logger.core.utils

import android.content.Context
import java.io.File

class FileExporter(private val context: Context) {
    
    fun exportToCsv(data: List<String>, filename: String): File {
        val file = File(context.getExternalFilesDir(null), filename)
        file.writeText(data.joinToString("\n"))
        return file
    }
    
    fun exportToPdf(data: List<String>, filename: String): File {
        val file = File(context.getExternalFilesDir(null), filename)
        file.writeText("PDF Export - Coming Soon\n\n" + data.joinToString("\n"))
        return file
    }
}
