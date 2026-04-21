package com.clientFX.Controllers;

import java.net.URL;
import java.util.ResourceBundle;

import com.clientFX.*;
import com.clientFX.Controllers.CtrlGame;
import com.shared.GameObject;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.canvas.Canvas;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.paint.Color;

public class CtrlGame implements Initializable {

    public static boolean winner = false;

    public static final int ROWS = 6;
    public static final int COLS = 7;
    public final String[][] board = new String[ROWS][COLS];
    public int currentPlayer = 1;
    public boolean block = false;

    @FXML private Canvas canvas;
    @FXML private Label turnLabel;
    @FXML private Label playerNameLabel;

    private GraphicsContext gc;
    
    public double dragStartX, dragStartY;
    public boolean isDragging = false;
    public GameObject draggedPiece = null;

    private Animator animator;
    private MouseEventListener mouseListener;
    public PlayGrid playGrid;
    private PlayTimer animationTimer;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        this.gc = canvas.getGraphicsContext2D();
        mouseListener = new MouseEventListener(this);

        // Listeners de tamaño
        UtilsViews.parentContainer.heightProperty().addListener((o, ov, nv) -> onSizeChanged());
        UtilsViews.parentContainer.widthProperty().addListener((o, ov, nv) -> onSizeChanged());

        // Eventos mouse
        canvas.setOnMouseMoved(mouseListener::onMouseMoved);
        canvas.setOnMousePressed(mouseListener::onMousePressed);
        canvas.setOnMouseDragged(mouseListener::onMouseDragged);
        canvas.setOnMouseReleased(mouseListener::onMouseReleased);

        playGrid = new PlayGrid(25, 25, 80, ROWS, COLS);

        // Gestor de animaciones
        animator = new Animator((int) playGrid.getCellSize(), playGrid.getStartX(), playGrid.getStartY());

        // Timer
        animationTimer = new PlayTimer(this::run, this::draw, 60);
        animationTimer.start();

        // Inicializar tablero
        for (int r = 0; r < ROWS; r++) {
            for (int c = 0; c < COLS; c++) {
                board[r][c] = "";
            }
        }
    }

    private void onSizeChanged() {
        double width = UtilsViews.parentContainer.getWidth();
        double height = UtilsViews.parentContainer.getHeight();
        canvas.setWidth(width);
        canvas.setHeight(height);
    }

    // --- Lógica del timer ---
    private void run(double fps) {
        animator.run(fps);
    }

    // --- Dibujar ---
    public void draw() {
        if (gc == null) return;

        // Limpiar fondo
        gc.clearRect(0, 0, canvas.getWidth(), canvas.getHeight());

        // Dibujar tablero y fichas colocadas
        BoardRenderer.drawBoard(gc, playGrid, ROWS, COLS,board);

        // Dibujar clientes
        BoardRenderer.drawClients(gc, playGrid, Main.clients);

        // Dibujar objetos (fichas en mano)
        BoardRenderer.drawObjects(gc, Main.objects);

        // Dibujar animación
        animator.draw(gc);
    }

    public static javafx.scene.paint.Color getColor(String colorName) {
        switch (colorName.toLowerCase()) {
            case "red": return Color.RED;
            case "yellow": return Color.GOLD;
            case "blue": return Color.BLUE;
            case "green": return Color.GREEN;
            case "orange": return Color.ORANGE;
            case "purple": return Color.PURPLE;
            case "pink": return Color.PINK;
            case "brown": return Color.BROWN;
            case "gray": return Color.GRAY;
            case "black": return Color.BLACK;
            default: return Color.LIGHTGRAY;
        }
    }

}