import pygame
import random

# 初始化pygame
pygame.init()

# 设置窗口大小
WIDTH, HEIGHT = 400, 500
TILE_SIZE = 100
GRID_PADDING = 10
TOP_MARGIN = 100

# 颜色定义
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
BACKGROUND_COLOR = (187, 173, 160)
EMPTY_TILE_COLOR = (205, 193, 180)
TILE_COLORS = {
    2: (238, 228, 218),
    4: (237, 224, 200),
    8: (242, 177, 121),
    16: (245, 149, 99),
    32: (246, 124, 95),
    64: (246, 94, 59),
    128: (237, 207, 114),
    256: (237, 204, 97),
    512: (237, 200, 80),
    1024: (237, 197, 63),
    2048: (237, 194, 46),
}

# 创建游戏窗口
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("2048 Game")

# 字体设置
font = pygame.font.SysFont(None, 55)

def draw_tile(x, y, value):
    color = TILE_COLORS.get(value, (0, 0, 0))
    pygame.draw.rect(screen, color, (x, y, TILE_SIZE, TILE_SIZE), border_radius=10)
    if value != 0:
        text = font.render(str(value), True, BLACK if value < 16 else WHITE)
        text_rect = text.get_rect(center=(x + TILE_SIZE // 2, y + TILE_SIZE // 2))
        screen.blit(text, text_rect)

def draw_grid(grid):
    for i in range(4):
        for j in range(4):
            x = GRID_PADDING + j * (TILE_SIZE + GRID_PADDING)
            y = TOP_MARGIN + GRID_PADDING + i * (TILE_SIZE + GRID_PADDING)
            draw_tile(x, y, grid[i][j])

def add_new_tile(grid):
    empty_tiles = [(i, j) for i in range(4) for j in range(4) if grid[i][j] == 0]
    if empty_tiles:
        i, j = random.choice(empty_tiles)
        grid[i][j] = 2 if random.random() < 0.9 else 4

def move(grid, direction):
    def stack():
        new_grid = [[0] * 4 for _ in range(4)]
        for i in range(4):
            fill_position = 0
            for j in range(4):
                if grid[i][j] != 0:
                    new_grid[i][fill_position] = grid[i][j]
                    fill_position += 1
        return new_grid

    def combine():
        for i in range(4):
            for j in range(3):
                if grid[i][j] == grid[i][j + 1] and grid[i][j] != 0:
                    grid[i][j] *= 2
                    grid[i][j + 1] = 0

    if direction == 'up':
        grid = [list(col) for col in zip(*grid)]
        grid = stack()
        combine()
        grid = stack()
        grid = [list(col) for col in zip(*grid)]
    elif direction == 'down':
        grid = [list(col) for col in zip(*grid)]
        grid = [row[::-1] for row in grid]
        grid = stack()
        combine()
        grid = stack()
        grid = [row[::-1] for row in grid]
        grid = [list(col) for col in zip(*grid)]
    elif direction == 'left':
        grid = stack()
        combine()
        grid = stack()
    elif direction == 'right':
        grid = [row[::-1] for row in grid]
        grid = stack()
        combine()
        grid = stack()
        grid = [row[::-1] for row in grid]

    return grid

def main():
    grid = [[0] * 4 for _ in range(4)]
    add_new_tile(grid)
    add_new_tile(grid)

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_UP:
                    grid = move(grid, 'up')
                elif event.key == pygame.K_DOWN:
                    grid = move(grid, 'down')
                elif event.key == pygame.K_LEFT:
                    grid = move(grid, 'left')
                elif event.key == pygame.K_RIGHT:
                    grid = move(grid, 'right')
                add_new_tile(grid)

        screen.fill(BACKGROUND_COLOR)
        draw_grid(grid)
        pygame.display.flip()

    pygame.quit()

if __name__ == "__main__":
    main()