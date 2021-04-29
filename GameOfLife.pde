import de.bezier.guido.*;

public final static int NUM_COLS = 20;
public final static int NUM_ROWS = 20;
private Life[][] buttons; //2d array of Life buttons each representing one cell
private boolean[][] buffer; //2d array of booleans to store state of buttons array
private boolean running = true; //used to start and stop program
private boolean nextFrame = true; //used to start the program for one frame
public boolean mineswept = false;
public void setup () {
  size(400, 400);
  frameRate(6);
  // make the manager
  Interactive.make( this );

  //your code to initialize buttons goes here
  buttons = new Life[NUM_ROWS][NUM_COLS];
  for (int r = 0; r < NUM_ROWS; r++) { 
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c] = new Life(r, c);
    }
  }
  buffer = new boolean[NUM_ROWS][NUM_COLS];
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buffer[r][c] = buttons[r][c].getLife();
    }
  }
}

public void draw () {
  background(200);
  if (!running && !nextFrame) //pause the program
    return;
  if (!mineswept && (nextFrame || running)) {
    nextFrame = false;
    copyFromButtonsToBuffer();
    copyFromBufferToButtons();
  }
}

public void keyPressed() {
  if (keyCode == 20) {
    running = !running;
  }
  if (keyCode == 32) {
    nextFrame = true;
  }
  if (key == 'r') {
    for (int r = 0; r < NUM_ROWS; r++) { 
      for (int c = 0; c < NUM_COLS; c++) {
        buttons[r][c].setLife(false);
      }
    }
  }
  if (key == 'm') {
    mineswept = !mineswept;
    for (int r = 0; r < NUM_ROWS; r++) { 
      for (int c = 0; c < NUM_COLS; c++) {
        buttons[r][c].setLife(false);
        buttons[r][c].init();
      }
    }
  }
}

public void copyFromButtonsToBuffer() {
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buffer[r][c] = isValid(r, c);
    }
  }
}

public void copyFromBufferToButtons() {
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c].setLife(buffer[r][c]);
    }
  }
}

public boolean isValid(int r, int c) {
  boolean isAlive = buttons[r][c].getLife();
  boolean valid = false;
  int neighbors = countNeighbors(r, c);
  if (isAlive && (neighbors == 3||neighbors == 2)) {
    valid = true;
  } else if (!isAlive && neighbors == 3) {
    valid = true;
  }
  return valid;
}

public int countNeighbors(int row, int col) {
  int neighbors = 0;
  for (int j = -1; j <= 1; j++) {
    for (int i = -1; i <= 1; i++) {
      if (-1 < row+j && row+j < NUM_ROWS && -1 < col+i && col+i < NUM_COLS) {
        if (buttons[row+j][col+i].getLife() == true) {
          neighbors++;
        }
      }
    }
  }
  if (buttons[row][col].getLife() == true) {
    neighbors--;
  }
  return neighbors;
}

public class Life {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean alive, visible, scanned;
  private color myColor;

  public Life (int row, int col) {
    visible = true;
    scanned = false;
    width = 400/NUM_COLS;
    height = 400/NUM_ROWS;
    myRow = row;
    myCol = col; 
    x = myCol*width;
    y = myRow*height;
    alive = Math.random() < .5; // 50/50 chance cell will be alive
    myColor = 200;
    Interactive.add( this ); // register it with the manager
  }
  public void init() {
    visible = false;
    scanned = false;
    alive = (Math.random() < .15);
  }
  // called by manager
  public void mousePressed () {
    if (mouseButton == LEFT) {
      if (!mineswept) {
        alive = !alive; //turn cell on and off with mouse press
      }
      if (mineswept) {
        if (alive) {
          visible = true;
          for (int r = 0; r < NUM_ROWS; r++) {
            for (int c = 0; c < NUM_COLS; c++) {
              if (buttons[r][c].getLife()) {
                buttons[r][c].setVisibility(true);
              }
            }
          }
        } else {
          clearSection(myRow, myCol);
        }
      }
    }
    if (mouseButton == RIGHT) {
      if (myColor != color(200, 0, 255)) {
        myColor = color(200, 0, 255);
      } else {
        myColor = color(200);
      }
    }
  }
  public void draw () {   
    stroke(0);
    if (visible) {
      if (alive) {
        stroke(0);
        fill(0);
        rect(x, y, width, height);
        fill(255);
      } else {
        stroke(255);
        fill(255);
        rect(x, y, width, height);
        fill(0);
      }
      textSize(10);
      int neighbors = countNeighbors(myRow, myCol);
      if (mineswept && neighbors != 0 && !alive) {
        text(neighbors, x+7, y+15);
      } else if (!mineswept && (neighbors != 0 || alive)) {
        text(neighbors, x+7, y+15);
      }
    } else {
      stroke(myColor);
      fill(myColor);
      rect(x, y, width, height);
    }
    //fill(alive ? 200 : 100);
  }
  public boolean getLife() {
    return alive;
  }
  public void setLife(boolean living) {
    alive = living;
  }
  public void setVisibility(boolean v_) {
    visible = v_;
  }
  public void setScan(boolean s_) {
    scanned = s_;
  }
  public boolean isScanned() {
    return scanned;
  }
}

public void clearSection(int row, int col) {
  if (buttons[row][col].isScanned()) {
    return;
  } else if (countNeighbors(row, col) == 0 && !buttons[row][col].getLife()) {
    buttons[row][col].setScan(true);
    buttons[row][col].setVisibility(true);
    if (col < NUM_COLS - 1) {
      clearSection(row, col+1);
    }
    if (row < NUM_ROWS - 1) {
      clearSection(row+1, col);
    }
    if (col > 0) {
      clearSection(row, col-1);
    }
    if (row > 0) {
      clearSection(row-1, col);
    }
    if (row > 0 && col > 0) {
      clearSection(row-1, col-1);
    }
    if (row > 0 && col < NUM_COLS - 1) {
      clearSection(row-1, col+1);
    }
    if (col > 0 && row < NUM_COLS - 1) {
      clearSection(row+1, col-1);
    }
    if (row < NUM_COLS - 1 && col < NUM_COLS - 1) {
      clearSection(row+1, col+1);
    }
  } else if (!buttons[row][col].getLife()) {
    buttons[row][col].setScan(true);
    buttons[row][col].setVisibility(true);
  }
}
