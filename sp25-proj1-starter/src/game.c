#include "game.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include "asserts.h"
#include "snake_utils.h"


/* Helper function definitions */
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_t *game, unsigned int snum);
static char next_square(game_t *game, unsigned int snum);
static void update_tail(game_t *game, unsigned int snum);
static void update_head(game_t *game, unsigned int snum);

/* Task 1 */
game_t *create_default_game() {
  // TODO: Implement this function.
  game_t *new_game;
  new_game = malloc(sizeof(game_t));
  // Init snake
  new_game->snakes = malloc(sizeof(snake_t));
  new_game->snakes->live = true;
  new_game->snakes->head_row = 2;
  new_game->snakes->head_col = 4;
  new_game->snakes->tail_row = 2;
  new_game->snakes->tail_col = 2;
  new_game->num_snakes = 1;
  // Init board
  new_game->num_rows = 18;
  new_game->board = malloc(18 * sizeof(char*));
  for (int i = 0; i < 18; i++) {
    new_game->board[i] = malloc(22 * sizeof(char));
    if (i == 0 || i == 17){
      const char* tmp = "####################\n\0";
      strcpy(new_game->board[i], tmp);
    } else {
      const char* tmp = "#                  #\n\0";
      strcpy(new_game->board[i], tmp);
    }
  }
  new_game->board[2][2] = 'd';
  new_game->board[2][3] = '>';
  new_game->board[2][4] = 'D';
  new_game->board[2][9] = '*';

  return new_game;
}

/* Task 2 */
void free_game(game_t *game) {
  // TODO: Implement this function.
  for (int i = 0; i < game->num_rows; i++) {
    free(game->board[i]);
  }
  free(game->board);
  free(game->snakes);
  free(game);
  return;
}

/* Task 3 */
void print_board(game_t *game, FILE *fp) {
  // TODO: Implement this function.
  for (int row = 0; row < game->num_rows; row++) {
    fprintf(fp, "%s", game->board[row]);
  }
  return;
}

/*
  Saves the current game into filename. Does not modify the game object.
  (already implemented for you).
*/
void save_board(game_t *game, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(game, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_t *game, unsigned int row, unsigned int col) { return game->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch) {
  game->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  if (c == 'w' || c == 'a' || c == 's' || c == 'd') {
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  if (c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x') {
    return true;
  }
  return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  if (is_head(c) || is_tail(c) || c == '<' || c == '>' || c == '^' || c == 'v') {
    return true;
  }
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  if (c == '^') return 'w';
  else if (c == 'v') return 's';
  else if (c == '<') return 'a';
  else if (c == '>') return 'd';
  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  if (c == 'W') return '^';
  else if (c == 'S') return 'v';
  else if (c == 'A') return '<';
  else if (c == 'D') return '>';
  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  return (c == 'v' || c == 's' || c == 'S') ? cur_row + 1 : (c == '^' || c == 'w' || c == 'W' ? cur_row - 1 : cur_row);
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  return (c == '>' || c == 'd' || c == 'D') ? cur_col + 1 : (c == '<' || c == 'a' || c == 'A' ? cur_col - 1 : cur_col);
}

/*
  Task 4.2

  Helper function for update_game. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  // Find the snum'th snake
  unsigned int head_row = game->snakes[snum].head_row;
  unsigned int head_col = game->snakes[snum].head_col;
  unsigned int next_row = get_next_row(head_row, get_board_at(game, head_row, head_col));
  unsigned int next_col = get_next_col(head_col, get_board_at(game, head_row, head_col));
  char trace = get_board_at(game, next_row, next_col);

  return trace;
}

/*
  Task 4.3

  Helper function for update_game. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int head_row = game->snakes[snum].head_row;
  unsigned int head_col = game->snakes[snum].head_col;
  char head_char = get_board_at(game, head_row, head_col);
  char body_char = head_to_body(head_char);
  set_board_at(game, head_row, head_col, body_char);

  unsigned int new_head_row = get_next_row(head_row, head_char);
  unsigned int new_head_col = get_next_col(head_col, head_char);
  set_board_at(game, new_head_row, new_head_col, head_char);
  game->snakes[snum].head_row = new_head_row;
  game->snakes[snum].head_col = new_head_col;

  return;
}

/*
  Task 4.4

  Helper function for update_game. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int row = game->snakes[snum].tail_row;
  unsigned int col = game->snakes[snum].tail_col;
  char tail_char = get_board_at(game, row, col);
  set_board_at(game, row, col, ' ');
  unsigned int new_tail_row = get_next_row(row, tail_char);
  unsigned int new_tail_col = get_next_col(col, tail_char);
  char new_tail_char = body_to_tail(get_board_at(game, new_tail_row, new_tail_col));
  set_board_at(game, new_tail_row, new_tail_col, new_tail_char);
  game->snakes[snum].tail_row = new_tail_row;
  game->snakes[snum].tail_col = new_tail_col;
  return;
}

/* Task 4.5 */
void update_game(game_t *game, int (*add_food)(game_t *game)) {
  // TODO: Implement this function.
  for (unsigned int snum = 0; snum < game->num_snakes; snum++) {
    if (!game->snakes[snum].live) {
      continue;
    }
    char next = next_square(game, snum);
    if (next == ' '){
      update_head(game, snum);
      update_tail(game, snum);
    } else if (next == '*') {
      update_head(game, snum);
      // Do not update tail
      add_food(game);
    } else {
      // Snake dies
      game->snakes[snum].live = false;
      // Remove snake from board
      unsigned int head_row = game->snakes[snum].head_row;
      unsigned int head_col = game->snakes[snum].head_col;
      set_board_at(game, head_row, head_col, 'x');
    }
  }
  return;
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  // TODO: Implement this function.
  if (fp == NULL) return NULL;
  unsigned int size = 128;
  unsigned int len = 0;
  char *line = malloc(128 * sizeof(char));
  if (line == NULL) {
    free(line);
    return NULL;
  }

  int c;
  while ((c = fgetc(fp)) != EOF) {
    if (len + 1 > size) {
      size *= 2;
      line = realloc(line, size);
      if (line == NULL) {
        free(line);
        return NULL;
      }
    }
    line[len] = (char)c;
    len += 1;
    if (c == '\n') break;
  }
  if (line == NULL || len == 0 || c == EOF) {
    free(line);
    return NULL;
  } 
  line = realloc(line, len + 1);
  line[len] = '\0';
  return line;
}

/* Task 5.2 */
game_t *load_board(FILE *fp) {
  // TODO: Implement this function.
  if (fp == NULL) return NULL;
  unsigned int size = 30;
  unsigned int row = 0;
  char **board = malloc(size * sizeof(char *));
  if (board == NULL) {
    free(board);
    return NULL;
  }

  char* line;
  while ((line = read_line(fp)) != NULL) {
    if (row + 1 > size) {
      size *= 2;
      board = realloc(board, size * sizeof(char *));
      if (board == NULL) {
        free(board);
        return  NULL;
      }
    }
    board[row] = line;
    row += 1;
  }
  if (row == 0 || board == NULL) {
    free(board);
    return NULL;
  }
  game_t *game = create_default_game();
  free(game->board);
  game->board = realloc(board, row * sizeof(char *));
  game->num_rows = row;
  if (game->board == NULL) {
    free_game(game);
    return NULL;
  }
  return game;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int cur_row = game->snakes[snum].tail_row;
  unsigned int cur_col = game->snakes[snum].tail_col;
  char cur_char = get_board_at(game, cur_row, cur_col);
  while (!is_head(cur_char)) {
    cur_row = get_next_row(cur_row, cur_char);
    cur_col = get_next_col(cur_col, cur_char);
    cur_char = get_board_at(game, cur_row, cur_col);
  }
  game->snakes[snum].head_row = cur_row;
  game->snakes[snum].head_col = cur_col;
  return;
}

/* Task 6.2 */
game_t *initialize_snakes(game_t *game) {
  game->snakes = malloc(sizeof(snake_t) * 1024);
  if (game->snakes == NULL) {
    return NULL;
  }
  snake_t* snakes = game->snakes;
  unsigned int snake_count = 0;
  for (unsigned int row = 0; row < game->num_rows; row++) {
    for (unsigned int col = 0; col < strlen(game->board[row]); col++) {
      char cur_char = get_board_at(game, row, col);
      if (is_tail(cur_char)) {
        snakes[snake_count].tail_row = row;
        snakes[snake_count].tail_col = col;
        snakes[snake_count].live = true;
        find_head(game, snake_count);
        snake_count++;
      }
    }
  }
  game->snakes = realloc(snakes, sizeof(snake_t) * snake_count);
  game->num_snakes = snake_count;
  return game;
}
