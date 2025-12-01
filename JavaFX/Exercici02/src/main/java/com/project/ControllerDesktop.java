package com.project;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ResourceBundle;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;

import javafx.scene.control.ChoiceBox;
import javafx.scene.layout.VBox;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.text.Text;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Color;
import javafx.geometry.Insets;

import javafx.fxml.Initializable;
import java.net.URL;
import org.json.JSONArray;
import org.json.JSONObject;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;

public class ControllerDesktop implements Initializable {

    @FXML
    private ChoiceBox<String> choiceBox;
    @FXML
    private VBox itemsList;

    @FXML
    private VBox panelDetails;
    @FXML
    private ImageView itemImage;
    @FXML
    private Text itemName;
    @FXML
    private Rectangle itemColor;
    @FXML
    private Text itemDescription;

    private String[] categories = {"Jocs", "Consoles", "Personatges"};

    private JSONArray jsonGames, jsonConsoles, jsonCharacters;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        itemDescription.wrappingWidthProperty().bind(panelDetails.widthProperty().subtract(40));

        try {
            URL jsonFileURL = getClass().getResource("/data/games.json");
            Path path = Paths.get(jsonFileURL.toURI());
            String content = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
            jsonGames = new JSONArray(content);

            jsonFileURL = getClass().getResource("/data/consoles.json");
            path = Paths.get(jsonFileURL.toURI());
            content = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
            jsonConsoles = new JSONArray(content);

            jsonFileURL = getClass().getResource("/data/characters.json");
            path = Paths.get(jsonFileURL.toURI());
            content = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
            jsonCharacters = new JSONArray(content);
        } catch (Exception e) {
            e.printStackTrace();
        }

        choiceBox.getItems().addAll(categories);
        choiceBox.setValue(categories[0]);
        choiceBox.setOnAction((event) -> {
            loadItems(choiceBox.getValue());
        });
        loadItems(categories[0]);
    }

    private void loadItems(String category) {
        JSONArray items = null;
        switch (category) {
            case "Jocs":
                items = jsonGames;
                break;
            case "Consoles":
                items = jsonConsoles;
                break;
            case "Personatges":
                items = jsonCharacters;
                break;
        }

        // Limpiar la lista anterior
        itemsList.getChildren().clear();
        
        // Guardar referència a l'element seleccionat (per ressaltar-lo)
        final Parent[] selectedTemplate = {null};

        for (int i = 0; i < items.length(); i++) {
            JSONObject item = items.getJSONObject(i);
            String name = item.getString("name");
            String image = item.getString("image");
            String imagePath = "/data/images/" + image;
            String color = item.has("color") ? item.getString("color") : "#FFFFFF00";

            try {
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/assets/listItem.fxml"));
                Parent itemTemplate = loader.load();
                ControllerListItem itemController = loader.getController();

                itemController.setTitle(name);
                itemController.setImatge(imagePath);
                itemsList.getChildren().add(itemTemplate);

                // Mostrar detalls del primer element per defecte
                if (i == 0) {
                    showDetails(item, name, imagePath, color, category);
                    itemTemplate.setStyle("-fx-background-color: #e0e0e0;");
                    selectedTemplate[0] = itemTemplate;
                }

                // Event click per mostrar detalls i ressaltar
                itemTemplate.setOnMouseClicked(event -> {
                    showDetails(item, name, imagePath, color, category);
                    // Treure fons al anterior seleccionat
                    if (selectedTemplate[0] != null)
                        selectedTemplate[0].setStyle("");
                    // Posar fons al seleccionat
                    itemTemplate.setStyle("-fx-background-color: #e0e0e0;");
                    selectedTemplate[0] = itemTemplate;
                });
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        
    }

    // Mètode per mostrar els detalls de l'element seleccionat
    private void showDetails(JSONObject item, String name, String imagePath, String color, String category) {
        // Imatge
        try {
            Image img = new Image(getClass().getResourceAsStream(imagePath));
            itemImage.setImage(img);
        } catch (Exception e) {
            itemImage.setImage(null);
        }
        // Títol
        itemName.setText(name);
        // Color
        itemColor.setStyle("-fx-fill: " + color);
        if (color.equals("#FFFFFF00")) {
            panelDetails.setMargin(itemColor, new Insets(0, 0, 0, 0));
        } else {
            panelDetails.setMargin(itemColor, new Insets(10, 0, 10, 0));
        }
        if (color.equals("white")) {
            itemColor.setStroke(Color.BLACK);
            itemColor.setStrokeWidth(1);
        } else {
            itemColor.setStroke(null);
        }
        // Descripció
        String desc = "";
        switch (category) {
            case "Jocs":
                desc = item.optString("type", "") + " - " + item.optString("year", "");
                desc += "\n" + item.optString("plot", "");
                break;
            case "Personatges":
                desc = item.optString("game", "");
                break;
            case "Consoles":
                desc = "Data de llançament: " + item.optString("date", "");
                desc += "\nUnitats venudes: " + item.optString("units_sold", "");
                desc += "\nProcessador: " + item.optString("procesador", "");
                break;
        }
        itemDescription.setText(desc);
    }

}