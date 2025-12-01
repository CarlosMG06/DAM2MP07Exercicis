package com.clientFX;

import java.net.URL;
import java.util.ResourceBundle;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.control.Alert;
import javafx.scene.control.ButtonType;
import javafx.application.Platform;
import org.json.JSONObject;

public class CtrlWaiting implements Initializable {

    @Override
    public void initialize(URL url, ResourceBundle rb) {
    }

    public void receiveMessage(JSONObject messageObj) {
        String type = messageObj.optString("type", "");
        if (type.equals("invite_accept")) {
            CtrlCountdown ctrlCountdown = (CtrlCountdown) UtilsViews.getController("ViewCountdown");
            ctrlCountdown.onShow();
            UtilsViews.setView("ViewCountdown");
        } else if (type.equals("invite_decline") || type.equals("invite_cancelled")) {
            String msg = messageObj.optString("message", "La invitación ha sido rechazada o cancelada.");
            Platform.runLater(() -> {
                Alert alert = new Alert(Alert.AlertType.INFORMATION, msg, ButtonType.OK);
                alert.setTitle("Invitació rebutjada");
                alert.setHeaderText(null);
                alert.showAndWait();
                UtilsViews.setView("ViewLobby");
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