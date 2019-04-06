// Brick properties.
private static final int BRICK_X_GRID = 5;
private static final int BRICK_Y_GRID = 3;
private static final int BRICK_HEIGHT = 50;
// Beam properties.
private static final int BEAM_WIDTH = 100;
private static final int BEAM_HEIGHT = 25;
// Ball properties.
private static final int BALL_DIAMETER = 20;
// Toolbar properties.
private static final int TOOLBAR_HEIGHT = 40;

// Game states.
private static final int GAME_STATE_INITIAL = 0;
private static final int GAME_STATE_PLAYING = 1;
private static final int GAME_STATE_PAUSED = 2;
private static final int GAME_STATE_WON = 3;
private static final int GAME_STATE_GAME_OVER = 4;

float ballLocationX = 0;
float ballLocationY = 0;
float ballVelocityX = 2;
float ballVelocityY = -2;
Brick bricks[];
PlayerBeam playerBeam = new PlayerBeam();
int gameState = GAME_STATE_INITIAL;
Button playButton, resumeButton, quitButton, pauseButton, scoreButton, gameOverButton, wonButton;
int score = 0;

//****************SCENE SETUP*******************//

void setup() {
  // Canvas size.
  size(800, 600);
  
  // Setup scene.
  setupPlayerBeam();
  setupBall();
  setupBricks();
  setupButtons();
}

void setupPlayerBeam() {
  // Initially, beam will be center aligned horizontally.
  playerBeam.x = (width / 2) - (BEAM_WIDTH / 2);
  playerBeam.y = height - BEAM_HEIGHT;
  playerBeam.height = BEAM_HEIGHT;
  playerBeam.width = BEAM_WIDTH;
}

void setupBall() {
  // Initially, ball will be one top of player beam and center aligned horizontally.
  ballLocationX = width / 2 - BALL_DIAMETER / 2;
  ballLocationY = height - (BEAM_HEIGHT + BALL_DIAMETER);
  ballVelocityX = 2;
  ballVelocityY = -2;
}

void setupBricks() {
  int brickWidth = width / BRICK_X_GRID;
  Brick[] bricks = new Brick[BRICK_X_GRID * BRICK_Y_GRID];
  
  for (int i = 0; i < bricks.length; i ++) {
    int row = i / BRICK_X_GRID;
    int column = i % BRICK_X_GRID;
    Brick brick = new Brick();
    brick.x = column * brickWidth;
    brick.y = TOOLBAR_HEIGHT + row * BRICK_HEIGHT;
    brick.width = brickWidth;
    brick.height = BRICK_HEIGHT;
    brick.visible = true;
    bricks[i] = brick;
  }
  
  this.bricks = bricks;
}

void setupButtons() {
  playButton = new Button("PLAY", 32, CENTER, width / 2f, height / 2f, new Color(255, 255, 255), true, this);

  resumeButton = new Button("RESUME", 32, CENTER, width / 2f, height / 2f, new Color(255, 255, 255), true, this);

  quitButton = new Button("QUIT", 32, CENTER, width / 2f, height / 2f, new Color(255, 255, 255), true, this);

  gameOverButton = new Button("GAME OVER, RESTART?", 32, CENTER, width / 2f, height / 2f, new Color(255, 255, 255), true, this);

  wonButton = new Button("YOU WON, RESTART?", 32, CENTER, width / 2f, height / 2f, new Color(255, 255, 255), true, this);

  pauseButton = new Button("PAUSE", 20, LEFT, 10, TOOLBAR_HEIGHT, new Color(255, 255, 255), true, this);
  pauseButton.y = TOOLBAR_HEIGHT / 2f + pauseButton.textHeight / 2;

  scoreButton = new Button("SCORE: ",20, LEFT, width, TOOLBAR_HEIGHT / 2f, new Color(255, 255, 255), false, this);
  scoreButton.y = TOOLBAR_HEIGHT / 2f + scoreButton.textHeight / 2;
  scoreButton.x -= (scoreButton.textWidth + 10);
}

//****************SCENE SETUP END*******************//


//****************GAME LOGIC*******************//

void draw() {
  background(0,0,0);
  handleGameState(gameState);
}

void keyPressed() {
  if (gameState != GAME_STATE_PLAYING) {
    return;
  }
  
  if (key == CODED) {
    if (keyCode == LEFT) {
      // Player presses left arrow key.
      movePlayer(playerBeam.x - 30);
    } else if (keyCode == RIGHT) {
      // Player presses right arrow key.
      movePlayer(playerBeam.x + 30);
    }
  } else {
    if (key == ' ') {
      if (Math.abs(ballVelocityX) == 2) {
        ballVelocityX = 5 * ballVelocityX/Math.abs(ballVelocityX);
        ballVelocityY = 5 * ballVelocityY/Math.abs(ballVelocityY);
      } else {
        ballVelocityX = 2 * ballVelocityX/Math.abs(ballVelocityX);
        ballVelocityY = 2 * ballVelocityY/Math.abs(ballVelocityY);
      }
    }
  }
}

void mouseClicked() {
  if (gameState == GAME_STATE_INITIAL && playButton.isMouseInBounds(mouseX, mouseY)) {
    System.out.println("Play button clicked");
    invalidateScore();
    this.gameState = GAME_STATE_PLAYING;
  } else if (gameState != GAME_STATE_PLAYING && quitButton.isMouseInBounds(mouseX, mouseY)) {
    System.out.println("Quit button clicked");
    exit();    
  } else if (gameState == GAME_STATE_PLAYING && pauseButton.isMouseInBounds(mouseX, mouseY)) {
    System.out.println("Pause button clicked");
    this.gameState = GAME_STATE_PAUSED;
  } else if (gameState == GAME_STATE_PAUSED && resumeButton.isMouseInBounds(mouseX, mouseY)) {
    System.out.println("Resume button clicked");
    this.gameState = GAME_STATE_PLAYING;
  } else if (gameState == GAME_STATE_GAME_OVER && gameOverButton.isMouseInBounds(mouseX, mouseY)) {
    System.out.println("Game over button clicked");
    setup();
    invalidateScore();
    this.gameState = GAME_STATE_PLAYING;
  } else if (gameState == GAME_STATE_WON && wonButton.isMouseInBounds(mouseX, mouseY)) {
    System.out.println("Won button clicked");
    setup();
    invalidateScore();
    this.gameState = GAME_STATE_PLAYING;
  }
}

void handleGameState(int gameState) {
  setAllButtonsInvisible();
  if (gameState == GAME_STATE_INITIAL) {
    onInit();
  } else if (gameState == GAME_STATE_PLAYING) {
    onPlay();
  } else if (gameState == GAME_STATE_PAUSED) {
    onPause();
  } else if (gameState == GAME_STATE_WON) {
    onWon();
  } else if (gameState == GAME_STATE_GAME_OVER) {
    onGameOver();
  }
}

void onInit() {
  drawButton(playButton);
  quitButton.y = 10 + playButton.y + playButton.textHeight; 
  drawButton(quitButton);
}

void onPlay() {
  if (score == bricks.length) {
    this.gameState = GAME_STATE_WON;
    return;
  }
  fill(255, 255, 255);
  drawBricks();
  drawPlayerBeam();
  drawBall();
  drawToolBar();
  animateBall();
  checkForBallCollision();
}

void onPause() {
  drawButton(resumeButton);
  quitButton.y = 10 + resumeButton.y + resumeButton.textHeight;
  drawButton(quitButton);
}

void onWon() {
  drawButton(wonButton);
  quitButton.y = 10 + wonButton.y + wonButton.textHeight;
  drawButton(quitButton);
}

void onGameOver() {
  drawButton(gameOverButton);
  quitButton.y = 10 + gameOverButton.y + gameOverButton.textHeight;
  drawButton(quitButton);
}

void invalidateScore() {
  score = 0;
}

void setAllButtonsInvisible() {
  playButton.visible = false;
  resumeButton.visible = false;
  quitButton.visible = false;
  pauseButton.visible = false;
  scoreButton.visible = false;
  gameOverButton.visible = false;
  wonButton.visible = false;
}

void movePlayer(float xPosition) {
  if (xPosition > 0 && (xPosition + playerBeam.width) < width) {
    // Valid move, update player location.
    playerBeam.x = xPosition;
  }
}

void drawButton(Button button) {
  button.visible = true;
  textSize(button.textSize);
  textAlign(button.alignment);
  fill(button.buttonColor.r, button.buttonColor.g, button.buttonColor.b);
  text(button.text, button.x, button.y);
  fill(255, 255, 255);
  
  // Highlight button if mouse is hovered over it.
  if (button.isMouseInBounds(mouseX, mouseY) && button.shouldHighlight) {
    System.out.println("Highlighting button with text: " + button.text);
    button.buttonColor.update(125, 125, 125);
  } else {
    button.buttonColor.update(255, 255, 255);
  }
}

void drawToolBar() {
  drawButton(pauseButton);
  scoreButton.calculateBounds("SCORE: " + score, this);
  scoreButton.x = width - (scoreButton.textWidth + 10);
  drawButton(scoreButton);
  stroke(255, 255, 255);
  line(0, TOOLBAR_HEIGHT, width, TOOLBAR_HEIGHT);
  stroke(0, 0, 0);
}

void drawBricks() {
  for (int i = 0; i < bricks.length; i ++) {
    Brick brick = bricks[i];
    if (brick.visible) {
      drawBrick(brick.x, brick.y, brick.width, brick.height);
    }
  }
}

// Draw a single brick.
void drawBrick(float x, float y, float width, float height) {
  rect(x, y, width, height);
}

void drawPlayerBeam() {
  // The beam will always stick to bottom of the canvas.
  rect(playerBeam.x, playerBeam.y, playerBeam.width, playerBeam.height);
}

void drawBall() {
  rect(ballLocationX, ballLocationY, BALL_DIAMETER, BALL_DIAMETER);
}

void animateBall() {
  ballLocationX += ballVelocityX;
  ballLocationY += ballVelocityY;
}

void reverseVelocityX() {
  ballVelocityX = -ballVelocityX;
}

void reverseVelocityY() {
  ballVelocityY = -ballVelocityY;
}

boolean shouldCheckForPlayerBeamCollision() {
  return ballLocationY + BALL_DIAMETER >= height - TOOLBAR_HEIGHT;
}

boolean shouldCheckForBrickCollision() {
  return ballLocationY <= (BRICK_Y_GRID * BRICK_HEIGHT) + TOOLBAR_HEIGHT;
}

boolean checkForBallCollision() {
  // The ball touches the bottom horizontal wall. GAME OVER!
  if (ballLocationY + BALL_DIAMETER >= height) {
    this.gameState = GAME_STATE_GAME_OVER;
    //return true;
  }
  
  boolean touchesVerticalWall = false;
  boolean touchesHorizontalWall = false;
  if (ballLocationX <= 0 || ballLocationX + BALL_DIAMETER >= width) {
    System.out.println("Touched the vertical wall");
    touchesVerticalWall = true;
  }
  
  // The ball touches the top horizontal wall.
  if (ballLocationY <= TOOLBAR_HEIGHT) {
    System.out.println("Touched the top horizontal wall");
    touchesHorizontalWall = true;
  }
  
  if (touchesVerticalWall && touchesHorizontalWall) {
    reverseVelocityX();
    reverseVelocityY();
  } else if (touchesVerticalWall) {
    reverseVelocityX();
  } else if (touchesHorizontalWall) {
    reverseVelocityY();
  }
  
  // The ball touches the player beam.
  if (shouldCheckForPlayerBeamCollision()) {
    int playerBeamBoundary = playerBeam.isTouchingBoundary(ballLocationX, ballLocationY, BALL_DIAMETER, BALL_DIAMETER, ballVelocityX, ballVelocityY);
    if (playerBeamBoundary == Shape.VERTICAL_BOUNDARY) {
        // The ball touches the vertical brick.
        // Reverse the x velocity.
        System.out.println("Touched the vertical boundary of playerBeam");
        reverseVelocityX();
        return true;
    } else if (playerBeamBoundary == Shape.HORIZONTAL_BOUNDARY) {
        // The ball touches the horuzontal brick.
        // Reverse the y velocity.
        System.out.println("Touched the horizonal boundary of playerBeam");
        reverseVelocityY();
        return true;
    }
  }
  
  if (shouldCheckForBrickCollision()) {
    for (int i = 0 ; i < bricks.length; i ++) {
      Brick brick = bricks[i];
      if (!brick.visible) {
        continue;
      }
      int boundary = brick.isTouchingBoundary(ballLocationX, ballLocationY, BALL_DIAMETER, BALL_DIAMETER, ballVelocityX, ballVelocityY);
      if (boundary == Shape.VERTICAL_BOUNDARY) {
        // The ball touches the vertical brick.
        // Reverse the x velocity.
        System.out.println("Touched the vertical boundary of brick at index: " + i);
        reverseVelocityX();
        // Remove the brick.
        brick.visible = false;
        score += 1;
        return true;
      } else if (boundary == Shape.HORIZONTAL_BOUNDARY) {
        // The ball touches the horuzontal brick.
        // Reverse the y velocity.
        System.out.println("Touched the horizonal boundary of brick at index: " + i);
        reverseVelocityY();
        // Remove the brick.
        brick.visible = false;
        score += 1;
        return true;
      }
    }
  }
  
  return false;
}

static class Brick extends Shape {
  String getName() {
    return "Brick";
  }
}

static class Ball extends Shape {
  String getName() {
    return "Ball";
  }
}

static class PlayerBeam extends Shape {
  String getName() {
    return "PlayerBeam";
  }
}

static class Shape {
  static int NO_BOUNDARY = -1;
  static int VERTICAL_BOUNDARY = 0;
  static int HORIZONTAL_BOUNDARY = 1;
  
  float x;
  float y;
  float width;
  float height;
  boolean visible;
  
  int isTouchingBoundary(float x, float y, float width, float height, float xVelocity, float yVelocity) {
    boolean touchesVerticalBoundary = false;
    boolean touchesHorizontalBoundary = false;
    if ((this.x > x && this.x - (x + width) <= 0) || ((x + width) > (this.x + this.width)) && (x - (this.x + this.width) <= 0)) {
      if ((this.y <= y && y <= (this.y + this.height)) || (this.y <= (y + height) && (y + height) <= (this.y + this.height))) {
        touchesVerticalBoundary = true;
      }
    }
    
    if ((this.y > y && this.y - (y + height) <= 0) || ((y + height) > (this.y + this.height)) && (y - (this.y + this.height) <= 0)) {
      if ((this.x <= x && x <= (this.x + this.width)) || (this.x <= (x + width) && (x + width) <= (this.x + this.width))) {
        touchesHorizontalBoundary = true;
      }
    }
    
    if (touchesVerticalBoundary && touchesHorizontalBoundary) {
      float heightIntersect = 0;
      float widthIntersect = 0;
      if (y <= this.y && y + height >= this.y + this.height) {
        heightIntersect = this.height;
      } else if (y <= this.y) {
        heightIntersect = (y + height) - this.y;
      } else if (y + height >= this.y + this.height) {
        heightIntersect = y - (this.y + height);
      }
      if (x <= this.x && x + width >= this.x + this.width) {
        widthIntersect = this.width;
      } else if (x <= this.x) {
        widthIntersect = (x + width) - this.x;
      } else if (x + width >= this.x + this.width) {
        widthIntersect = x - (this.x + width);
      }
      
      int quadrant = -1;
      if (xVelocity < 0 && yVelocity > 0) {
        quadrant = 0;
      } else if (xVelocity > 0 && yVelocity > 0) {
        quadrant = 1;
      } else if (xVelocity > 0 && yVelocity < 0) {
        quadrant = 2;
      } else if (xVelocity < 0 && yVelocity < 0) {
        quadrant = 3;
      }
      
      if (x < this.x && y < this.y) {
        // First corner.
        switch(quadrant) {
          case 0: return HORIZONTAL_BOUNDARY; 
          case 1: return heightIntersect > widthIntersect ? VERTICAL_BOUNDARY : HORIZONTAL_BOUNDARY;
          case 2: return VERTICAL_BOUNDARY;
        }
      } else if ((x + width) > (this.x + this.width) && y < this.y) {
        // Second corner.
        switch(quadrant) {
          case 0: return heightIntersect > widthIntersect ? VERTICAL_BOUNDARY : HORIZONTAL_BOUNDARY;
          case 1: return HORIZONTAL_BOUNDARY;
          case 3: return VERTICAL_BOUNDARY;
        }
      } else if (x < this.x && (y + height) > (this.y + this.height)) {
        // Third corner.
        switch(quadrant) {
          case 1: return VERTICAL_BOUNDARY; 
          case 2: return heightIntersect > widthIntersect ? VERTICAL_BOUNDARY : HORIZONTAL_BOUNDARY;
          case 3: return HORIZONTAL_BOUNDARY;
        }
      } else if ((x + width) > (this.x + this.width) && (y + height) > (this.y + this.height)) {
        // Fourth corner.
        switch(quadrant) {
          case 0: return VERTICAL_BOUNDARY; 
          case 2: return HORIZONTAL_BOUNDARY;
          case 3: return heightIntersect > widthIntersect ? VERTICAL_BOUNDARY : HORIZONTAL_BOUNDARY;
        }
      }
    } else if (touchesVerticalBoundary) {
      return VERTICAL_BOUNDARY;
    } else if (touchesHorizontalBoundary) {
      return HORIZONTAL_BOUNDARY;
    }
    
    return NO_BOUNDARY;
  }
  
  String getName() {
    return "Shape";
  }
}

static class Button {
  boolean visible;
  String text;
  int textSize, alignment;
  float x, y, textWidth, textHeight;
  Color buttonColor;
  boolean shouldHighlight;
  
  Button (String text, int textSize, int alignment, float x, float y, Color buttonColor, boolean shouldHighlight, PApplet pa) {
    this.textSize = textSize;
    this.alignment = alignment;
    this.x = x;
    this.y = y;
    this.buttonColor = buttonColor;
    this.shouldHighlight = shouldHighlight;
    
    calculateBounds(text, pa);
  }
  
  void calculateBounds(String text, PApplet pa) {
    this.text = text;
    pa.textSize(textSize);
    pa.textAlign(alignment);
    textWidth = pa.textWidth(text);
    textHeight = pa.textAscent() * 0.8;
  }
  
  boolean isMouseInBounds(float mouseX, float mouseY) {
    if (!visible) {
      return false;
    }
    
    if (alignment == CENTER) {
      return x - textWidth / 2 <= mouseX
      && mouseX <= x + textWidth / 2
      && y - textHeight <= mouseY
      && mouseY <= y;
    } else {
      return x <= mouseX
      && mouseX <= x + textWidth
      && y - textHeight <= mouseY
      && mouseY <= y;
    }
  }
}

static class Color {
  int r, g, b;
  
  Color(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  void update(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}

//****************GAME LOGIC EMD*******************//
