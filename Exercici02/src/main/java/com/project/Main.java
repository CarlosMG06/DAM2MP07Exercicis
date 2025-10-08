package com.project;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

public class Main extends Application {

    public static String nom = "";
    public static String edat = "";
    final int MIN_WINDOW_WIDTH = 200;
    final int WINDOW_WIDTH = 715;
    final int WINDOW_HEIGHT = 540;

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage stage) throws Exception {

        UtilsViews.addView(getClass(), "DesktopView", "/assets/DesktopView.fxml");
        //UtilsViews.addView(getClass(), "MobileView", "/assets/MobileView.fxml");

        Scene scene = new Scene(UtilsViews.parentContainer);

        stage.setScene(scene);
        stage.setTitle("Exercici 02 - Nntendo DB");
        stage.setMinWidth(MIN_WINDOW_WIDTH);
        stage.setMinHeight(WINDOW_HEIGHT);
        stage.setMaxWidth(WINDOW_WIDTH);
        stage.setMaxHeight(WINDOW_HEIGHT);
        stage.setResizable(true);
        stage.show();

        // Add icon only if not Mac
        if (!System.getProperty("os.name").contains("Mac")) {
            Image icon = new Image("file:/icons/icon.png");
            stage.getIcons().add(icon);
        }
    }
}