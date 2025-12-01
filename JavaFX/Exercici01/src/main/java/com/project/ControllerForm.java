package com.project;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;

import javafx.scene.control.TextField;
import javafx.scene.control.Button;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;

public class ControllerForm {

    @FXML
    private TextField fieldName, fieldAge;
    @FXML
    private Button buttonNext;

    @FXML
    public void initialize() {
        // Listener per activar el botó quan s'hi introdueix un nom i una edat vàlids
        ChangeListener<String> listener = (ObservableValue<? extends String> obs, String oldVal, String newVal) -> {
            String nom = fieldName.getText();
            String edat = fieldAge.getText();
            boolean valid = nom.matches("\\w+( ?\\w+)*") && edat.matches("\\d+");
            buttonNext.setDisable(!valid);
        };
        fieldName.textProperty().addListener(listener);
        fieldAge.textProperty().addListener(listener);
    }
    @FXML
    private void toViewHello(ActionEvent event) {
        Main.nom = fieldName.getText();
        Main.edat = fieldAge.getText();
        UtilsViews.setView("ViewHello");

        ControllerDesktop ctrlHello = (ControllerDesktop) UtilsViews.getController("ViewHello");
        ctrlHello.setLabelText();
    }
}