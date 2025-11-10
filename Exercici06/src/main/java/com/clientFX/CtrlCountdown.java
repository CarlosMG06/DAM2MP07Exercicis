package com.clientFX;

import java.net.URL;
import java.util.ResourceBundle;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.application.Platform;

public class CtrlCountdown implements Initializable {

    @FXML
    private Label labelCountdown;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
    }

    public void onShow() {
        startCountdown();  
    }

    private void startCountdown() {
        new Thread(() -> {
            try {
                Thread.sleep(1000);
                for (int i = 3; i >= 0; i--) {
                    final int count = i;
                    Platform.runLater(() -> {
                        if (count == 0) {
                            labelCountdown.setText("GO!");
                        } else {
                            labelCountdown.setText(String.valueOf(count));
                        }
                        labelCountdown.setStyle("-fx-font-size: " + (60 * (Math.pow(1.25, 3 - count)) + "px;"));
                    });
                    Thread.sleep(1000);
                }
                Platform.runLater(() -> UtilsViews.setView("ViewGame"));
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }).start();
    }

}