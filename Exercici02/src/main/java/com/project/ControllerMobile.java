package com.project;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ResourceBundle;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;

import javafx.scene.layout.VBox;
import javafx.scene.layout.HBox;
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

import javafx.animation.TranslateTransition;
import javafx.util.Duration;

public class ControllerMobile implements Initializable {

    @FXML
    private VBox panelCategories, panelList, panelDetails;
    @FXML
    private HBox titleCategories, titleList, titleDetails;
    @FXML
    private Text titleListText, titleDetailsText;

    @FXML
    private HBox btnJocs, btnConsoles, btnPersonatges;
    @FXML
    private HBox btnBackList, btnBackDetails;

    @FXML
    private VBox itemsList;

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

    private String currentCategory = "Jocs";

    @Override
    public void initialize(URL url, ResourceBundle rb) {    
    itemDescription.wrappingWidthProperty().bind(Main.windowWidthProperty.subtract(20));

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

        btnJocs.setOnMouseClicked(e -> showListPanel("Jocs"));
        btnConsoles.setOnMouseClicked(e -> showListPanel("Consoles"));
        btnPersonatges.setOnMouseClicked(e -> showListPanel("Personatges"));

        btnBackList.setOnMouseClicked(e -> showCategoriesPanel());
        btnBackDetails.setOnMouseClicked(e -> showListPanel(currentCategory));

        panelCategories.setVisible(true);
        panelList.setVisible(false);
        panelDetails.setVisible(false);
    }

    private void showCategoriesPanel() {
        animatePanel(panelList, false);
        animatePanel(panelDetails, false);
        animatePanel(panelCategories, true);
    }

    private void showListPanel(String category) {
        currentCategory = category;
        titleListText.setText(category);
        loadItems(category);
        animatePanel(panelCategories, false);
        animatePanel(panelDetails, false);
        animatePanel(panelList, true);
    }

    private void showDetailsPanel(JSONObject item, String name, String imagePath, String color, String category) {
        showDetails(item, name, imagePath, color, category);
        titleDetailsText.setText(name);
        animatePanel(panelList, false);
        animatePanel(panelCategories, false);
        animatePanel(panelDetails, true);
    }

    private void animatePanel(VBox panel, boolean show) {
        if (show) {
            panel.setVisible(true);
            TranslateTransition tt = new TranslateTransition(Duration.millis(180), panel);
            tt.setFromX(300);
            tt.setToX(0);
            tt.setOnFinished(ev -> panel.setTranslateX(0));
            tt.play();
        } else {
            TranslateTransition tt = new TranslateTransition(Duration.millis(180), panel);
            tt.setFromX(0);
            tt.setToX(300);
            tt.setOnFinished(ev -> panel.setVisible(false));
            tt.play();
        }
    }

    // Similar al de ControllerDesktop
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

                itemTemplate.setOnMouseClicked(e -> showDetailsPanel(item, name, imagePath, color, category));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    // private HashMap getDetails(JSONObject item) {
    //     HashMap<String, String> details;
    //     details.put("name", item.getString("name"));
    // }

    // Igual que en ControllerDesktop
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