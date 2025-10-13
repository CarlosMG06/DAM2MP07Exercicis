package com.project;

import java.util.Objects;

import javafx.fxml.FXML;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.control.Label;

public class ControllerMessage {

    @FXML private ImageView profilePicture;
    @FXML private Label username, textMessage;

    public void setProfilePicture(String imagePath) {
        try {
            Image image = new Image(Objects.requireNonNull(getClass().getResourceAsStream(imagePath)));
            this.profilePicture.setImage(image);
        } catch (NullPointerException e) {
            System.err.println("Error loading image asset: " + imagePath);
            e.printStackTrace();
        }
    }
    public void setUsername(String name) {
        this.username.setText(name);
    }
    public void setTextMessage(String message) {
        this.textMessage.setText(message);
    }

}
