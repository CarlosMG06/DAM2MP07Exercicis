package com.clientFX;

import java.net.URL;
import java.util.ResourceBundle;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;

public class CtrlWaiting implements Initializable {

    @Override
    public void initialize(URL url, ResourceBundle rb) {
    }

    public void toCountdownView() {
        UtilsViews.setView("ViewCountdown");
    }
}