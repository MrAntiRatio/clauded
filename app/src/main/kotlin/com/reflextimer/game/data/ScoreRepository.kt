package com.reflextimer.game.data

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import com.reflextimer.game.reflexDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class ScoreRepository(private val context: Context) {

    private fun bestKey(difficulty: Difficulty) =
        longPreferencesKey("best_${difficulty.name}")

    private fun avgKey(difficulty: Difficulty) =
        longPreferencesKey("avg_${difficulty.name}")

    fun bestReactionFlow(difficulty: Difficulty): Flow<Long?> =
        context.reflexDataStore.data.map { prefs ->
            prefs[bestKey(difficulty)]?.takeIf { it > 0 }
        }

    fun bestAverageFlow(difficulty: Difficulty): Flow<Long?> =
        context.reflexDataStore.data.map { prefs ->
            prefs[avgKey(difficulty)]?.takeIf { it > 0 }
        }

    suspend fun maybeUpdateScores(
        difficulty: Difficulty,
        sessionBest: Long?,
        sessionAverage: Long?,
    ) {
        context.reflexDataStore.edit { prefs ->
            sessionBest?.let { value ->
                val current = prefs[bestKey(difficulty)] ?: Long.MAX_VALUE
                if (value < current) prefs[bestKey(difficulty)] = value
            }
            sessionAverage?.let { value ->
                val current = prefs[avgKey(difficulty)] ?: Long.MAX_VALUE
                if (value < current) prefs[avgKey(difficulty)] = value
            }
        }
    }
}
