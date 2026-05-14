package com.reflextimer.game.viewmodel

import android.app.Application
import android.os.SystemClock
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.reflextimer.game.data.Difficulty
import com.reflextimer.game.data.RoundResult
import com.reflextimer.game.data.ScoreRepository
import com.reflextimer.game.data.SessionStats
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlin.random.Random

sealed interface GamePhase {
    data object Idle : GamePhase
    data object Waiting : GamePhase
    data class Go(val startElapsedRealtime: Long) : GamePhase
    data class TooSoon(val message: String) : GamePhase
    data class RoundComplete(val reactionMs: Long) : GamePhase
    data class SessionComplete(
        val stats: SessionStats,
        val newBestReaction: Boolean,
        val newBestAverage: Boolean,
    ) : GamePhase
}

data class GameUiState(
    val phase: GamePhase = GamePhase.Idle,
    val difficulty: Difficulty = Difficulty.NORMAL,
    val targetRounds: Int = 5,
    val rounds: List<RoundResult> = emptyList(),
    val allTimeBestReactionMs: Long? = null,
    val allTimeBestAverageMs: Long? = null,
) {
    val currentRoundIndex: Int get() = rounds.size
}

class GameViewModel(application: Application) : AndroidViewModel(application) {

    private val repo = ScoreRepository(application.applicationContext)

    private val _uiState = MutableStateFlow(GameUiState())
    val uiState: StateFlow<GameUiState> = _uiState.asStateFlow()

    private var waitJob: Job? = null

    init {
        observeBestScores(Difficulty.NORMAL)
    }

    private fun observeBestScores(difficulty: Difficulty) {
        viewModelScope.launch {
            val best = repo.bestReactionFlow(difficulty).first()
            val avg = repo.bestAverageFlow(difficulty).first()
            _uiState.value = _uiState.value.copy(
                allTimeBestReactionMs = best,
                allTimeBestAverageMs = avg,
            )
        }
    }

    fun setDifficulty(difficulty: Difficulty) {
        if (_uiState.value.difficulty == difficulty) return
        cancelPendingWait()
        _uiState.value = GameUiState(
            difficulty = difficulty,
            targetRounds = _uiState.value.targetRounds,
        )
        observeBestScores(difficulty)
    }

    fun setTargetRounds(rounds: Int) {
        cancelPendingWait()
        _uiState.value = _uiState.value.copy(
            targetRounds = rounds.coerceIn(1, 20),
            rounds = emptyList(),
            phase = GamePhase.Idle,
        )
    }

    fun onScreenTap() {
        val state = _uiState.value
        when (val phase = state.phase) {
            GamePhase.Idle, is GamePhase.TooSoon -> startWaitingForGo()
            GamePhase.Waiting -> handleTooSoon()
            is GamePhase.Go -> handleReaction(phase)
            is GamePhase.RoundComplete -> {
                if (state.rounds.size >= state.targetRounds) {
                    // shouldn't happen, but defensive
                    finishSession()
                } else {
                    startWaitingForGo()
                }
            }
            is GamePhase.SessionComplete -> resetSession()
        }
    }

    fun resetSession() {
        cancelPendingWait()
        _uiState.value = _uiState.value.copy(
            rounds = emptyList(),
            phase = GamePhase.Idle,
        )
    }

    private fun startWaitingForGo() {
        cancelPendingWait()
        _uiState.value = _uiState.value.copy(phase = GamePhase.Waiting)
        val diff = _uiState.value.difficulty
        val delayMs = Random.nextLong(diff.minDelayMs, diff.maxDelayMs)
        waitJob = viewModelScope.launch {
            delay(delayMs)
            if (_uiState.value.phase is GamePhase.Waiting) {
                _uiState.value = _uiState.value.copy(
                    phase = GamePhase.Go(SystemClock.elapsedRealtime())
                )
            }
        }
    }

    private fun handleTooSoon() {
        cancelPendingWait()
        _uiState.value = _uiState.value.copy(
            phase = GamePhase.TooSoon("Too soon! Tap to try again."),
        )
    }

    private fun handleReaction(phase: GamePhase.Go) {
        val reactionMs = SystemClock.elapsedRealtime() - phase.startElapsedRealtime
        val state = _uiState.value
        val newRounds = state.rounds + RoundResult(reactionMs)
        if (newRounds.size >= state.targetRounds) {
            _uiState.value = state.copy(rounds = newRounds)
            finishSession()
        } else {
            _uiState.value = state.copy(
                rounds = newRounds,
                phase = GamePhase.RoundComplete(reactionMs),
            )
        }
    }

    private fun finishSession() {
        val state = _uiState.value
        val stats = SessionStats(rounds = state.rounds, targetRounds = state.targetRounds)
        val previousBestReaction = state.allTimeBestReactionMs
        val previousBestAverage = state.allTimeBestAverageMs
        val newBestReaction = stats.bestMs != null &&
            (previousBestReaction == null || stats.bestMs!! < previousBestReaction)
        val newBestAverage = stats.averageMs != null &&
            (previousBestAverage == null || stats.averageMs!! < previousBestAverage)

        _uiState.value = state.copy(
            phase = GamePhase.SessionComplete(
                stats = stats,
                newBestReaction = newBestReaction,
                newBestAverage = newBestAverage,
            )
        )

        viewModelScope.launch {
            repo.maybeUpdateScores(
                difficulty = state.difficulty,
                sessionBest = stats.bestMs,
                sessionAverage = stats.averageMs,
            )
            val best = repo.bestReactionFlow(state.difficulty).first()
            val avg = repo.bestAverageFlow(state.difficulty).first()
            _uiState.value = _uiState.value.copy(
                allTimeBestReactionMs = best,
                allTimeBestAverageMs = avg,
            )
        }
    }

    private fun cancelPendingWait() {
        waitJob?.cancel()
        waitJob = null
    }

    override fun onCleared() {
        cancelPendingWait()
        super.onCleared()
    }

    class Factory(private val application: Application) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return GameViewModel(application) as T
        }
    }
}
