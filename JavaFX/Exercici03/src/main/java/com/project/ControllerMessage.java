package com.project;

import java.io.File;
import java.util.Objects;

import javafx.fxml.FXML;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import javafx.geometry.Insets;

public class ControllerMessage {

    @FXML private ImageView profilePicture;
    @FXML private VBox textPanel;
    @FXML private Text username, textMessage;

    public void setProfilePicture(String imagePath) {
        try {
            Image image = new Image(Objects.requireNonNull(getClass().getResourceAsStream(imagePath)));
            this.profilePicture.setImage(image);
        } catch (NullPointerException e) {
            System.err.println("Error carregant imatge: " + imagePath);
            e.printStackTrace();
        }
    }
    public void addPicture(String imagePath) {
        try {
            Image image;
            File file = new File(imagePath);
            if (file.exists()) {
                image = new Image(file.toURI().toString());
            } else {
                throw new NullPointerException();
            }
            ImageView imageView = new ImageView(image);
            
            imageView.setFitHeight(200);
            imageView.setFitWidth(300);
            imageView.setPreserveRatio(true);
            imageView.setSmooth(true);

            VBox.setMargin(imageView, new Insets(5, 0, 0, 0));
            this.textPanel.getChildren().add(imageView);
        } catch (NullPointerException e) {
            System.err.println("Error carregant imatge: " + imagePath);
            e.printStackTrace();
        }
    }

    public void setUsername(String name) {
        this.username.setText(name);
    }
    public void setTextMessage(String message) {
        this.textMessage.setText(message);
    }
    public String getTextMessage() {
        return this.textMessage.getText();
    }

}
