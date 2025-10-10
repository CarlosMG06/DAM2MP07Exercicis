package com.project;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.beans.property.SimpleIntegerProperty;


public class Main extends Application {

    final int MIN_WINDOW_WIDTH = 250;
    final int WIDTH_THRESHOLD = 500;
    final int WINDOW_WIDTH = 715;
    final int WINDOW_HEIGHT = 540;
    public static SimpleIntegerProperty windowWidthProperty = new SimpleIntegerProperty(715);

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage stage) throws Exception {

        UtilsViews.addView(getClass(), "Desktop", "/assets/DesktopView.fxml");
        UtilsViews.addView(getClass(), "Mobile", "/assets/MobileView.fxml");

        Scene scene = new Scene(UtilsViews.parentContainer);

        // Listen to window width changes
        scene.widthProperty().addListener((ChangeListener<? super Number>) new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldWidth, Number newWidth) {
                if (newWidth.intValue() < WIDTH_THRESHOLD) {
                    UtilsViews.setView("Mobile");
                } else {
                    UtilsViews.setView("Desktop");
                }
                windowWidthProperty.set(newWidth.intValue());
            }
        });

        stage.setScene(scene);
        stage.setTitle("Exercici 02 - Nintendo DB");
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