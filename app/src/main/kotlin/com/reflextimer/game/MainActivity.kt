package com.reflextimer.game

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import com.reflextimer.game.ui.ReflexApp
import com.reflextimer.game.ui.theme.ReflexTimerTheme
import com.reflextimer.game.viewmodel.GameViewModel

class MainActivity : ComponentActivity() {

    private val viewModel: GameViewModel by viewModels { GameViewModel.Factory(application) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            ReflexTimerTheme {
                ReflexApp(viewModel = viewModel)
            }
        }
    }
}
