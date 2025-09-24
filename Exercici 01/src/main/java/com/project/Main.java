package com.project;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

public class Main extends Application {

    public static String nom = "";
    public static String edat = "";
    final int WIDOW_WIDTH = 400;
    final int WINDOW_HEIGHT = 300;

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage stage) throws Exception {

        UtilsViews.parentContainer.setStyle("-fx-font: 14 arial;");
        UtilsViews.addView(getClass(), "ViewForm", "/assets/Form.fxml");
        UtilsViews.addView(getClass(), "ViewHello", "/assets/Hello.fxml");

        Scene scene = new Scene(UtilsViews.parentContainer);

        stage.setScene(scene);
        stage.setTitle("Exercici 01 - Vistes");
        stage.setMinWidth(WIDOW_WIDTH);
        stage.setMinHeight(WINDOW_HEIGHT);
        stage.show();

        // Add icon only if not Mac
        if (!System.getProperty("os.name").contains("Mac")) {
            Image icon = new Image("file:/icons/icon.png");
            stage.getIcons().add(icon);
        }
    }
}