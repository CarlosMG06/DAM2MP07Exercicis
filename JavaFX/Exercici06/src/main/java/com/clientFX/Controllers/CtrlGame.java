package com.clientFX;

import java.net.URL;
import java.util.ResourceBundle;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;

public class CtrlGame implements Initializable {

    public static boolean winner = false;

    public static final int ROWS = 6;
    public static final int COLS = 7;
    public final String[][] board = new String[ROWS][COLS];
    public int currentPlayer = 1;

    @FXML private Canvas gameCanvas;
    @FXML private Pane piecesPanel;
    @FXML private Label turnLabel;
    @FXML private Label playerNameLabel;

    private GraphicsContext gc;
    
    private double dragStartX, dragStartY;
    private boolean isDragging = false;
    private PieceType draggedPiece = null;

    private BoardRenderer boardRenderer;
    private Animator animator;
    private MouseEventListener mouseListener;
    private PlayGrid playGrid;
    private PlayTimer playTimer;
    @Override
    public void initialize(URL url, ResourceBundle rb) {
    }
}