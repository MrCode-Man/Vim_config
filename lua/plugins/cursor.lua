return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy", -- Carrega logo após a inicialização para não atrasar o boot
  opts = {
    stiffness = 0.95,              -- Velocidade de resposta (0.1 a 1.0)
    trailing_stiffness = 0.3,     -- Quão "preso" o rastro fica
    distance_stop_animating = 0.1, -- Distância mínima para parar a animação
  },
}
