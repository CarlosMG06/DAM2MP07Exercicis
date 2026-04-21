package com.clientFX.Controllers;

import java.lang.ModuleLayer.Controller;
import java.net.URL;
import java.util.ArrayList;
import java.util.ResourceBundle;

import org.json.JSONArray;
import org.json.JSONObject;

import com.clientFX.UtilsViews;
import com.clientFX.Main;

import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.Label;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.control.Alert;
import javafx.scene.control.ButtonType;

public class CtrlLobby implements Initializable {

    @FXML
    private Label txtId;

    @FXML
    private TextArea txtArea;

    @FXML
    private ChoiceBox<String> choiceUser;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
       choiceUser.getItems().clear();
    }

    @FXML
    private void setViewPost() {
        UtilsViews.setViewAnimating("ViewPost");
    }

    @FXML
    private void setViewUpload() {
        UtilsViews.setViewAnimating("ViewUpload");
    }

    @FXML
    private void sendInvite() {
        String dest = choiceUser.getValue();
        if (dest != null && !dest.isBlank()) {
            JSONObject messageObj = new JSONObject();
            messageObj.put("type", "invite");
            messageObj.put("destination", dest);
            Main.wsClient.safeSend(messageObj.toString());

            CtrlWaiting ctrl = (CtrlWaiting) UtilsViews.getController("Waiting");
            ctrl.dest = choiceUser.getValue();
            toWaitingView();
        }
    }

    // Main wsClient calls this method when receiving a message
    public void receiveMessage (JSONObject messageObj) {
        System.out.println("Receive WebSocket: " + messageObj.toString());
        String type = messageObj.getString("type");

        // Update clients choiceBox list
        if (type.equals("clients")) {
            JSONArray JSONlist = messageObj.getJSONArray("list");
            ArrayList<String> list = new ArrayList<>();
            String id = messageObj.getString("id");
         
            for (int i = 0; i < JSONlist.length(); i++) {
                String value = JSONlist.getString(i);
                if (!value.equals(id)) { 
                    list.add(value);
                }
            }
        
            txtId.setText(id);
            choiceUser.getItems().clear();
            if (!list.isEmpty()) {
                choiceUser.getItems().addAll(list);
                choiceUser.setValue(list.get(0));
            }
        } else if (type.equals("invite")) {
            String origin = messageObj.getString("origin");
            Platform.runLater(() -> {
                Alert alert = new Alert(Alert.AlertType.CONFIRMATION, "Invitació de " + origin, ButtonType.YES, ButtonType.NO);
                alert.setTitle("Invitació");
                alert.setHeaderText("Acceptar invitació de " + origin + "?");
                alert.showAndWait().ifPresent(response -> {
                    JSONObject responseObj = new JSONObject();
                    if (response == ButtonType.YES) {
                        responseObj.put("type", "invite_accept");
                    } else {
                        responseObj.put("type", "invite_decline");
                    }
                    responseObj.put("destination", origin);
                    Main.wsClient.safeSend(responseObj.toString());
                });
            });
        } else if (type.equals("invite_accepted")) {
            Platform.runLater(() -> {
                CtrlCountdown ctrlCountdown = (CtrlCountdown) UtilsViews.getController("ViewCountdown");
                ctrlCountdown.onShow();
                UtilsViews.setView("ViewCountdown");
            });
        } else if (type.equals("invite_declined")) {
            String message = messageObj.optString("message", "L'usuari ha declinat la invitació.");
            Platform.runLater(() -> {
                Alert alert = new Alert(Alert.AlertType.INFORMATION, message, ButtonType.OK);
                alert.setTitle("Invitació rebutjada");
                alert.setHeaderText(null);
                alert.showAndWait();
            });
        // } else if (type.equals("invite_cancelled")) {
        //     String message = messageObj.optString("message", "L'usuari ha cancel·lat la invitació.");
        //     Platform.runLater(() -> {
        //         Alert alert = new Alert(Alert.AlertType.INFORMATION, message, ButtonType.OK);
        //         alert.setTitle("Invitació cancel·lada");
        //         alert.setHeaderText(null);
        //         alert.showAndWait();
        //     });
        // } else if (type.equals("confirmation")) {
        //     String message = messageObj.getString("message");
        //     Platform.runLater(() -> {
        //         Alert alert = new Alert(Alert.AlertType.INFORMATION, message, ButtonType.OK);
        //         alert.setTitle("Confirmació");
        //         alert.setHeaderText(null);
        //         alert.showAndWait();
        //     });
        }
    }

    public void toWaitingView() {
        UtilsViews.setView("Waiting");
    }
}