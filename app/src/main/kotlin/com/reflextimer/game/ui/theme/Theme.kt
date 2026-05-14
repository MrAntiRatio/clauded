package com.reflextimer.game.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColors = darkColorScheme(
    primary = ReflexBlue,
    onPrimary = Color.White,
    primaryContainer = ReflexBlueDark,
    onPrimaryContainer = Color.White,
    secondary = ReflexAmber,
    onSecondary = Color.Black,
    background = ReflexBackground,
    onBackground = ReflexOnSurface,
    surface = ReflexSurface,
    onSurface = ReflexOnSurface,
    surfaceVariant = ReflexSurface,
    onSurfaceVariant = ReflexOnSurfaceMuted,
    error = ReflexRed,
    onError = Color.White,
)

private val LightColors = lightColorScheme(
    primary = ReflexBlue,
    secondary = ReflexAmber,
    error = ReflexRed,
)

@Composable
fun ReflexTimerTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit,
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColors
        else -> LightColors
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content,
    )
}
