package com.clientFX.Controllers;

import java.net.URL;
import java.util.ResourceBundle;

import com.clientFX.UtilsViews;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.control.Button;

public class CtrlResult implements Initializable {

    @FXML
    private Label labelResult;
    @FXML 
    private Button btnClose, btnToLobby;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        if (CtrlGame.winner) {
            labelResult.setText("You Win!");
        } else {
            labelResult.setText("You Lose...");
        }
    }

    @FXML
    public void closeApp() {
        System.exit(0);
    }

    @FXML
    public void toLobbyView() {
        UtilsViews.setView("ViewLobby");
    }
}