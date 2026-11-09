enum TeamSide { red, blue }

enum GameMode { playerVsPlayer, playerVsAI }

enum GamePhase {
  idle,
  activeTurn,
  answerValidated,
  transition,
  roundOver,
  gameOver,
  paused,
}

enum AnimationState {
  idle, pull, strongPull, struggle, slip, fall, victory, defeat, powerUp
}