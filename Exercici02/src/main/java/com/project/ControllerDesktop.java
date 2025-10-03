package com.project;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ResourceBundle;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;

import javafx.scene.control.ChoiceBox;
import javafx.scene.image.ImageView;
import javafx.scene.text.Text;

import javafx.fxml.Initializable;
import java.net.URL;
import org.json.JSONArray;

public class ControllerDesktop implements Initializable {

    @FXML
    private ChoiceBox<String> choiceBox;
    @FXML
    private ImageView itemImage;
    @FXML
    private Text itemTitle;
    @FXML
    private Text itemDescription;

    private String[] categories = {"Jocs", "Consoles", "Personatges"};

    private JSONArray jsonGames, jsonConsoles, jsonCharacters;

    @Override
    public void initialize(URL url, ResourceBundle rb) {

        choiceBox.getItems().addAll(categories);
        choiceBox.setValue(categories[0]);
        // choiceBox.setOnAction((event) -> {
        // choiceLabel.setText(choiceBox.getSelectionModel().getSelectedItem());
        // });

        try {
            // Obtenir els fitxers JSON
            URL jsonFileURL = getClass().getResource("/resources/data/games.json");
            Path path = Paths.get(jsonFileURL.toURI());
            String content = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
            jsonGames = new JSONArray(content);

            jsonFileURL = getClass().getResource("/resources/data/consoles.json");
            path = Paths.get(jsonFileURL.toURI());
            content = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
            jsonConsoles = new JSONArray(content);

            jsonFileURL = getClass().getResource("/resources/data/characters.json");
            path = Paths.get(jsonFileURL.toURI());
            content = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
            jsonCharacters = new JSONArray(content);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}