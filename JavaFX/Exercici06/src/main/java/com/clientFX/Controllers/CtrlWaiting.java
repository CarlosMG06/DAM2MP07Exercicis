package com.clientFX.Controllers;

import java.net.URL;
import java.util.ResourceBundle;

import com.clientFX.UtilsViews;
import com.clientFX.Main;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.control.Alert;
import javafx.scene.control.ButtonType;
import javafx.application.Platform;
import org.json.JSONObject;

public class CtrlWaiting implements Initializable {

    public String dest = "";

    @Override
    public void initialize(URL url, ResourceBundle rb) {
    }

    public void receiveMessage(JSONObject messageObj) {
        String type = messageObj.optString("type", "");
        if (type.equals("invite_accepted")) {
            CtrlCountdown ctrlCountdown = (CtrlCountdown) UtilsViews.getController("ViewCountdown");
            ctrlCountdown.onShow();
            UtilsViews.setView("ViewCountdown");
        } else if (type.equals("invite_declined")) {
            String message = messageObj.getString("message");
            Platform.runLater(() -> {
                Alert alert = new Alert(Alert.AlertType.INFORMATION, message, ButtonType.OK);
                alert.setTitle("Invitació rebutjada");
                alert.setHeaderText(null);
                alert.showAndWait();
            });
        } else if (type.equals("invite_cancelled")) {
            String message = messageObj.getString("message");
            Platform.runLater(() -> {
                Alert alert = new Alert(Alert.AlertType.INFORMATION, message, ButtonType.OK);
                alert.setTitle("Invitació cancel·lada");
                alert.setHeaderText(null);
                alert.showAndWait();
            });
        }
    }

    @FXML
    private void cancelInvitation() {
        JSONObject obj = new JSONObject();
        obj.put("type", "invite_cancel");
        Main.wsClient.safeSend(obj.toString());
        UtilsViews.setView("ViewLobby");
    }
}