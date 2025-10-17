package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import javafx.event.ActionEvent;
import javafx.application.Platform;
import java.net.URL;
import java.util.ResourceBundle;
import javafx.fxml.Initializable;

import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest.BodyPublishers;
import java.nio.charset.StandardCharsets;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.InputStream;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Base64;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import javafx.stage.FileChooser;

import org.json.JSONArray;
import org.json.JSONObject;

public class Controller implements Initializable {

    // Models
    private static final String TEXT_MODEL   = "gemma3:1b";
    private static final String VISION_MODEL = "llava-phi3";

    @FXML private Button btnAddPicture, btnSend, btnBreak;
    @FXML private TextField chatInput;
    @FXML private Text infoLog;
    @FXML private VBox chatHistory;

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private CompletableFuture<HttpResponse<InputStream>> streamRequest;
    private CompletableFuture<HttpResponse<String>> completeRequest;
    private final AtomicBoolean isCancelled = new AtomicBoolean(false);
    private InputStream currentInputStream;
    private final ExecutorService executorService = Executors.newSingleThreadExecutor();
    private Future<?> streamReadingTask;
    private volatile boolean isFirst = false;

    private File selectedImageFile = null;
    private ControllerMessage lastAIMsgController = null;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        setButtonsIdle();
    }

    @FXML
    private void actionAddPicture(ActionEvent event) {
        // Choose image file
        FileChooser fc = new FileChooser();
        fc.setTitle("Select an image");
        fc.getExtensionFilters().addAll(
            new FileChooser.ExtensionFilter("Images", "*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp", "*.gif")
        );

        // set default dir to current working directory
        File initialDir = new File(System.getProperty("user.dir"));
        if (initialDir.exists() && initialDir.isDirectory()) {
            fc.setInitialDirectory(initialDir);
        }

        File file = fc.showOpenDialog(btnAddPicture.getScene().getWindow());
        if (file != null) {
            selectedImageFile = file;
            infoLog.setText("Selected image: " + file.getName());
        } else {
            infoLog.setText("No image selected.");
        }
    }
    @FXML
    private void actionSend(ActionEvent event) {
        String prompt = chatInput.getText();
        if (prompt == null || prompt.isBlank()) return;
        addMessageToHistory(prompt, false);
        chatInput.setText("");
        if (selectedImageFile != null) {
            callPicture(event, prompt);
        } else {
            callStream(event, prompt);
        }
    }

    private void addMessageToHistory(String message, boolean isAI) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/assets/chatMessage.fxml"));
            Parent msgTemplate = loader.load();
            ControllerMessage msgController = loader.getController();

            if (isAI) {
                msgController.setProfilePicture("/assets/images/ieti.png");
                msgController.setUsername("Xat IETI");
                lastAIMsgController = msgController;
            } else {
                msgController.setProfilePicture("/assets/images/you.png");
                msgController.setUsername("You");
                if (selectedImageFile != null) {
                    msgController.addPicture(selectedImageFile.getAbsolutePath());
                }
            }
            msgController.setTextMessage(message);

            chatHistory.getChildren().add(msgTemplate);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // --- UI actions ---

    private void callStream(ActionEvent event, String prompt) {
        infoLog.setText("");
        setButtonsRunning();
        isCancelled.set(false);

        ensureModelLoaded(TEXT_MODEL).whenComplete((v, err) -> {
            if (err != null) {
                Platform.runLater(() -> { infoLog.setText("Error loading model."); setButtonsIdle(); });
                return;
            }
            executeTextRequest(TEXT_MODEL, prompt);
        });
    }

    private void callPicture(ActionEvent event, String prompt) {
        infoLog.setText("");
        setButtonsRunning();
        isCancelled.set(false);

        // Read file -> base64
        final String base64Image;
        try {
            byte[] bytes = Files.readAllBytes(selectedImageFile.toPath());
            base64Image = Base64.getEncoder().encodeToString(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            Platform.runLater(() -> { infoLog.setText("Error reading image."); setButtonsIdle(); });
            return;
        }

        ensureModelLoaded(VISION_MODEL).whenComplete((v, err) -> {
            if (err != null) {
                Platform.runLater(() -> { infoLog.setText("Error loading model."); setButtonsIdle(); });
                return;
            }
            executeImageRequest(VISION_MODEL, prompt, base64Image);
        });
    }

    @FXML
    private void callBreak(ActionEvent event) {
        isCancelled.set(true);
        cancelStreamRequest();
        Platform.runLater(() -> {
            infoLog.setText("Request cancelled.");
            setButtonsIdle();
        });
    }

    // --- Request helpers ---

    // Text-only (stream)
    private void executeTextRequest(String model, String prompt) {
        JSONObject body = new JSONObject()
            .put("model", model)
            .put("prompt", prompt)
            .put("stream", true)
            .put("keep_alive", "10m");

        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("http://localhost:11434/api/generate"))
            .header("Content-Type", "application/json")
            .POST(BodyPublishers.ofString(body.toString()))
            .build();

        Platform.runLater(() -> infoLog.setText("Wait stream ... "));
        isFirst = true;

        streamRequest = httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofInputStream())
            .thenApply(response -> {
                currentInputStream = response.body();
                streamReadingTask = executorService.submit(this::handleStreamResponse);
                infoLog.setText("...");
                return response;
            })
            .exceptionally(e -> {
                if (!isCancelled.get()) e.printStackTrace();
                Platform.runLater(this::setButtonsIdle);
                return null;
            });
    }

    // Image + prompt (non-stream) using vision model
    private void executeImageRequest(String model, String prompt, String base64Image) {
        Platform.runLater(() -> infoLog.setText("Thinking..."));

        JSONObject body = new JSONObject()
            .put("model", model)
            .put("prompt", prompt)
            .put("images", new JSONArray().put(base64Image))
            .put("stream", false)
            .put("keep_alive", "10m")
            .put("options", new JSONObject()
                .put("num_ctx", 2048)     // lower context to reduce memory
                .put("num_predict", 256)  // shorter output to avoid OOM
            );

        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create("http://localhost:11434/api/generate"))
            .header("Content-Type", "application/json")
            .POST(BodyPublishers.ofString(body.toString()))
            .build();

        completeRequest = httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofString())
            .thenApply(resp -> {
                int code = resp.statusCode();
                String bodyStr = resp.body();

                String msg = tryParseAnyMessage(bodyStr);
                if (msg == null || msg.isBlank()) {
                    msg = (code >= 200 && code < 300) ? "(empty response)" : "HTTP " + code + ": " + bodyStr;
                }

                final String toShow = msg;
                Platform.runLater(() -> {
                    addMessageToHistory(toShow, true);
                    infoLog.setText("...");
                    setButtonsIdle(); 
                });
                return resp;
            })
            .exceptionally(e -> {
                if (!isCancelled.get()) e.printStackTrace();
                Platform.runLater(() -> { infoLog.setText("Request failed."); setButtonsIdle(); });
                return null;
            });
    }

    // Stream reader for text responses
    private void handleStreamResponse() {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(currentInputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (isCancelled.get()) break;
                if (line.isBlank()) continue;

                JSONObject jsonResponse = new JSONObject(line);
                String chunk = jsonResponse.optString("response", "");
                if (chunk.isEmpty()) continue;

                if (isFirst) {
                    Platform.runLater(() -> addMessageToHistory(chunk, true));
                    isFirst = false;
                } else {
                    Platform.runLater(() -> {
                        String currentText = lastAIMsgController.getTextMessage();
                        lastAIMsgController.setTextMessage(currentText + chunk);
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            Platform.runLater(() -> { infoLog.setText("Error during streaming."); setButtonsIdle(); });
        } finally {
            try { if (currentInputStream != null) currentInputStream.close(); } catch (Exception ignore) {}
            Platform.runLater(this::setButtonsIdle);
        }
    }

    // --- Small utils ---

    private String safeExtractTextResponse(String bodyStr) {
        // Extract "response" or fallback to error/message if present
        try {
            JSONObject o = new JSONObject(bodyStr);
            String r = o.optString("response", null);
            if (r != null && !r.isBlank()) return r;
            if (o.has("message")) return o.optString("message");
            if (o.has("error"))   return "Error: " + o.optString("error");
        } catch (Exception ignore) {}
        return bodyStr != null && !bodyStr.isBlank() ? bodyStr : "(empty)";
    }

    private String tryParseAnyMessage(String bodyStr) {
        try {
            JSONObject o = new JSONObject(bodyStr);
            if (o.has("response")) return o.optString("response", "");
            if (o.has("message"))  return o.optString("message", "");
            if (o.has("error"))    return "Error: " + o.optString("error", "");
        } catch (Exception ignore) {}
        return null;
    }

    private void cancelStreamRequest() {
        if (streamRequest != null && !streamRequest.isDone()) {
            try {
                if (currentInputStream != null) {
                    System.out.println("Cancelling InputStream");
                    currentInputStream.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            System.out.println("Cancelling StreamRequest");
            if (streamReadingTask != null) {
                streamReadingTask.cancel(true);
            }
            streamRequest.cancel(true);
        }
    }

    private void setButtonsRunning() {
        btnAddPicture.setDisable(true);
        btnSend.setDisable(true);
        btnBreak.setDisable(false);
    }

    private void setButtonsIdle() {
        btnAddPicture.setDisable(false);
        btnSend.setDisable(false);
        btnBreak.setDisable(true);
        streamRequest = null;
        completeRequest = null;
    }

    // Ensure given model is in memory; preload if needed
    private CompletableFuture<Void> ensureModelLoaded(String modelName) {
        return httpClient.sendAsync(
                HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:11434/api/ps"))
                    .GET()
                    .build(),
                HttpResponse.BodyHandlers.ofString()
            )
            .thenCompose(resp -> {
                boolean loaded = false;
                try {
                    JSONObject o = new JSONObject(resp.body());
                    JSONArray models = o.optJSONArray("models");
                    if (models != null) {
                        for (int i = 0; i < models.length(); i++) {
                            String name = models.getJSONObject(i).optString("name", "");
                            String model = models.getJSONObject(i).optString("model", "");
                            if (name.startsWith(modelName) || model.startsWith(modelName)) { loaded = true; break; }
                        }
                    }
                } catch (Exception ignore) {}

                if (loaded) return CompletableFuture.completedFuture(null);

                Platform.runLater(() -> infoLog.setText("Loading model ..."));

                String preloadJson = new JSONObject()
                    .put("model", modelName)
                    .put("stream", false)
                    .put("keep_alive", "10m")
                    .toString();

                HttpRequest preloadReq = HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:11434/api/generate"))
                    .header("Content-Type", "application/json")
                    .POST(BodyPublishers.ofString(preloadJson))
                    .build();

                return httpClient.sendAsync(preloadReq, HttpResponse.BodyHandlers.ofString())
                        .thenAccept(r -> { /* warmed */ });
            });
    }
}
