package com.reflextimer.game.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.reflextimer.game.data.Difficulty
import com.reflextimer.game.data.SessionStats
import com.reflextimer.game.ui.theme.ReflexAmber
import com.reflextimer.game.ui.theme.ReflexGreen
import com.reflextimer.game.ui.theme.ReflexRed
import com.reflextimer.game.viewmodel.GameUiState
import com.reflextimer.game.viewmodel.GamePhase
import com.reflextimer.game.viewmodel.GameViewModel

@Composable
fun ReflexApp(viewModel: GameViewModel) {
    val state by viewModel.uiState.collectAsState()
    val safePadding = WindowInsets.safeDrawing.asPaddingValues()

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background,
    ) {
        GameScreen(
            state = state,
            safePadding = safePadding,
            onTap = viewModel::onScreenTap,
            onDifficulty = viewModel::setDifficulty,
            onRoundsChange = viewModel::setTargetRounds,
            onReset = viewModel::resetSession,
        )
    }
}

@Composable
private fun GameScreen(
    state: GameUiState,
    safePadding: PaddingValues,
    onTap: () -> Unit,
    onDifficulty: (Difficulty) -> Unit,
    onRoundsChange: (Int) -> Unit,
    onReset: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(safePadding),
    ) {
        Header(
            state = state,
            onReset = onReset,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 12.dp),
        )

        TapSurface(
            state = state,
            onTap = onTap,
            modifier = Modifier
                .weight(1f)
                .padding(horizontal = 16.dp),
        )

        Footer(
            state = state,
            onDifficulty = onDifficulty,
            onRoundsChange = onRoundsChange,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp),
        )
    }
}

@Composable
private fun Header(
    state: GameUiState,
    onReset: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Reflex Timer",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground,
                modifier = Modifier.weight(1f),
            )
            if (state.rounds.isNotEmpty() || state.phase !is GamePhase.Idle) {
                TextButton(onClick = onReset) {
                    Text("Reset")
                }
            }
        }
        Spacer(Modifier.height(4.dp))
        Text(
            text = "Round ${minOf(state.currentRoundIndex + 1, state.targetRounds)} of ${state.targetRounds}",
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            style = MaterialTheme.typography.bodyMedium,
        )
    }
}

@Composable
private fun TapSurface(
    state: GameUiState,
    onTap: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val color = when (state.phase) {
        GamePhase.Idle -> MaterialTheme.colorScheme.primary
        GamePhase.Waiting -> ReflexRed
        is GamePhase.Go -> ReflexGreen
        is GamePhase.TooSoon -> ReflexAmber
        is GamePhase.RoundComplete -> MaterialTheme.colorScheme.primaryContainer
        is GamePhase.SessionComplete -> MaterialTheme.colorScheme.primaryContainer
    }
    Box(
        modifier = modifier
            .fillMaxSize()
            .clip(RoundedCornerShape(28.dp))
            .background(color)
            .pointerInput(state.phase) {
                detectTapGestures(onPress = { onTap() })
            },
        contentAlignment = Alignment.Center,
    ) {
        SurfaceContent(state = state)
    }
}

@Composable
private fun SurfaceContent(state: GameUiState) {
    when (val phase = state.phase) {
        GamePhase.Idle -> CenterText(
            title = "Tap to start",
            subtitle = "When the screen turns green, tap as fast as you can.",
            titleColor = Color.White,
        )
        GamePhase.Waiting -> CenterText(
            title = "Wait for green…",
            subtitle = "Don't tap yet!",
            titleColor = Color.White,
        )
        is GamePhase.Go -> CenterText(
            title = "TAP!",
            subtitle = null,
            titleColor = Color.White,
            titleSize = 80,
        )
        is GamePhase.TooSoon -> CenterText(
            title = "Too soon!",
            subtitle = "Tap to try this round again.",
            titleColor = Color.Black,
        )
        is GamePhase.RoundComplete -> CenterText(
            title = "${phase.reactionMs} ms",
            subtitle = "Tap for next round",
            titleColor = Color.White,
            titleSize = 56,
        )
        is GamePhase.SessionComplete -> SessionSummary(
            stats = phase.stats,
            newBestReaction = phase.newBestReaction,
            newBestAverage = phase.newBestAverage,
            bestEverReactionMs = state.allTimeBestReactionMs,
            bestEverAverageMs = state.allTimeBestAverageMs,
        )
    }
}

@Composable
private fun CenterText(
    title: String,
    subtitle: String?,
    titleColor: Color,
    titleSize: Int = 44,
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
        modifier = Modifier.padding(24.dp),
    ) {
        Text(
            text = title,
            color = titleColor,
            fontWeight = FontWeight.ExtraBold,
            fontSize = titleSize.sp,
            textAlign = TextAlign.Center,
        )
        if (subtitle != null) {
            Spacer(Modifier.height(12.dp))
            Text(
                text = subtitle,
                color = titleColor.copy(alpha = 0.85f),
                fontSize = 16.sp,
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun SessionSummary(
    stats: SessionStats,
    newBestReaction: Boolean,
    newBestAverage: Boolean,
    bestEverReactionMs: Long?,
    bestEverAverageMs: Long?,
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
        modifier = Modifier.padding(24.dp),
    ) {
        Text(
            text = "Session complete",
            color = Color.White,
            fontWeight = FontWeight.Bold,
            fontSize = 28.sp,
        )
        Spacer(Modifier.height(16.dp))
        StatRow(label = "Average", valueMs = stats.averageMs, highlight = newBestAverage)
        Spacer(Modifier.height(8.dp))
        StatRow(label = "Best", valueMs = stats.bestMs, highlight = newBestReaction)
        Spacer(Modifier.height(20.dp))
        if (bestEverReactionMs != null || bestEverAverageMs != null) {
            Text(
                text = buildString {
                    append("All-time best ")
                    if (bestEverReactionMs != null) append("reaction: ${bestEverReactionMs}ms")
                    if (bestEverReactionMs != null && bestEverAverageMs != null) append(" · ")
                    if (bestEverAverageMs != null) append("avg: ${bestEverAverageMs}ms")
                },
                color = Color.White.copy(alpha = 0.7f),
                fontSize = 14.sp,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(20.dp))
        }
        Text(
            text = "Tap to play again",
            color = Color.White,
            fontSize = 16.sp,
        )
    }
}

@Composable
private fun StatRow(label: String, valueMs: Long?, highlight: Boolean) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(
            text = "$label:",
            color = Color.White.copy(alpha = 0.8f),
            fontSize = 18.sp,
        )
        Spacer(Modifier.width(8.dp))
        Text(
            text = if (valueMs != null) "${valueMs} ms" else "—",
            color = if (highlight) ReflexAmber else Color.White,
            fontWeight = if (highlight) FontWeight.ExtraBold else FontWeight.SemiBold,
            fontSize = 22.sp,
        )
        if (highlight) {
            Spacer(Modifier.width(8.dp))
            Text(
                text = "NEW",
                color = ReflexAmber,
                fontWeight = FontWeight.Black,
                fontSize = 14.sp,
            )
        }
    }
}

@Composable
private fun Footer(
    state: GameUiState,
    onDifficulty: (Difficulty) -> Unit,
    onRoundsChange: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    val controlsEnabled = state.phase is GamePhase.Idle ||
        state.phase is GamePhase.SessionComplete ||
        state.phase is GamePhase.TooSoon

    Column(modifier = modifier.fillMaxWidth()) {
        Text(
            text = "Difficulty",
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
        )
        Spacer(Modifier.height(6.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Difficulty.entries.forEach { diff ->
                FilterChip(
                    selected = state.difficulty == diff,
                    onClick = { if (controlsEnabled) onDifficulty(diff) },
                    enabled = controlsEnabled,
                    label = { Text(diff.displayName) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = MaterialTheme.colorScheme.primary,
                        selectedLabelColor = Color.White,
                    ),
                )
            }
        }
        Spacer(Modifier.height(14.dp))
        Text(
            text = "Rounds per session",
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            fontSize = 13.sp,
            fontWeight = FontWeight.SemiBold,
        )
        Spacer(Modifier.height(6.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf(3, 5, 10).forEach { rounds ->
                FilterChip(
                    selected = state.targetRounds == rounds,
                    onClick = { if (controlsEnabled) onRoundsChange(rounds) },
                    enabled = controlsEnabled,
                    label = { Text(rounds.toString()) },
                )
            }
        }
        if (state.allTimeBestReactionMs != null || state.allTimeBestAverageMs != null) {
            Spacer(Modifier.height(14.dp))
            Text(
                text = buildString {
                    append("Best (${state.difficulty.displayName}) — ")
                    val best = state.allTimeBestReactionMs
                    val avg = state.allTimeBestAverageMs
                    if (best != null) append("reaction: ${best}ms")
                    if (best != null && avg != null) append(" · ")
                    if (avg != null) append("avg: ${avg}ms")
                },
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontSize = 13.sp,
            )
        }
    }
}
