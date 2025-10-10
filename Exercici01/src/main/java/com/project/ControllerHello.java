package com.project;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.Button;

public class ControllerDesktop {

    @FXML
    private Label labelHello;
    @FXML
    private Button buttonBack;

    @FXML
    public void setLabelText() {
        labelHello.setText("Hola " + Main.nom + ", tens " + Main.edat + " anys!");
    }
    @FXML
    private void toViewForm(javafx.event.ActionEvent event) {
        UtilsViews.setView("ViewForm");
    }
}