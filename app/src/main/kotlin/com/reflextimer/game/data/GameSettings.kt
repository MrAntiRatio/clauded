package com.reflextimer.game.data

enum class Difficulty(
    val displayName: String,
    val minDelayMs: Long,
    val maxDelayMs: Long,
) {
    EASY("Easy", 1500, 4500),
    NORMAL("Normal", 1000, 3500),
    HARD("Hard", 700, 2500),
    INSANE("Insane", 400, 1800);
}

data class RoundResult(val reactionMs: Long)

data class SessionStats(
    val rounds: List<RoundResult>,
    val targetRounds: Int,
) {
    val isComplete: Boolean get() = rounds.size >= targetRounds
    val averageMs: Long? get() = if (rounds.isEmpty()) null else rounds.sumOf { it.reactionMs } / rounds.size
    val bestMs: Long? get() = rounds.minOfOrNull { it.reactionMs }
}
