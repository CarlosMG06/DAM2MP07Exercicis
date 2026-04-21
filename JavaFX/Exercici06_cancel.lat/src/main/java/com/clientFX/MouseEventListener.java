package com.clientFX;

import org.json.JSONObject;

import com.clientFX.Main;
import com.clientFX.Controllers.CtrlGame;
import com.shared.ClientData;
import com.shared.GameObject;

import javafx.scene.input.MouseEvent;

public class MouseEventListener {

    private final CtrlGame ctrlGame;

    public MouseEventListener(CtrlGame ctrlGame) {
        this.ctrlGame = ctrlGame;
    }

    // Al mover el mouse
    public void onMouseMoved(MouseEvent e) {
        double x = e.getX();
        double y = e.getY();

        String color = Main.clients.stream()
            .filter(c -> c.name.equals(Main.clientName))
            .map(c -> c.color)
            .findFirst()
            .orElse("gray");

        ClientData cd = new ClientData(
            Main.clientName,
            color,
            (int) x,
            (int) y,
            ctrlGame.playGrid.isPositionInsideGrid(x, y) ? ctrlGame.playGrid.getRow(y) : -1,
            ctrlGame.playGrid.isPositionInsideGrid(x, y) ? ctrlGame.playGrid.getCol(x) : -1
        );

        JSONObject msg = new JSONObject();
        msg.put("type", "clientMouseMoving"); //envias que cliente esta moviendo el mouse
        msg.put("value", cd.toJSON());

        if (Main.wsClient != null) Main.wsClient.safeSend(msg.toString());
    }

    // Al pulsar el mouse
    public void onMousePressed(MouseEvent e) {
        if (ctrlGame.block || Main.partidaFinalizada) {
            return;
        }

        String colorActual = Main.getClientColor(); 

        for (GameObject go : Main.objects) { //con esto miramos las fichas del jugador actual(si no esta colocada,si es de su color,y es correcta)
            if (go.isPiece && go.color.equalsIgnoreCase(colorActual) &&
                insideCircle(e.getX(), e.getY(), go.x, go.y, go.radius)) {

                ctrlGame.draggedPiece = go;
                ctrlGame.dragStartX = e.getX() - go.x;
                ctrlGame.dragStartY = e.getY() - go.y;
                ctrlGame.isDragging = true;

                JSONObject msg = new JSONObject();
                msg.put("type", "PeticioSelect");
                msg.put("player", Main.clientName);
                msg.put("color", colorActual);
                msg.put("value", go.toJSON()); //Envia el objeto actualizado

                if (Main.wsClient != null) Main.wsClient.safeSend(msg.toString());
                break;
            }
        }
    }

    // -Al arrastrar al mouse
    public void onMouseDragged(MouseEvent e) {
        if (ctrlGame.block || Main.partidaFinalizada) {
            return;
        }
            
        if (!ctrlGame.isDragging || ctrlGame.draggedPiece == null) {
            return;
        }

        ctrlGame.draggedPiece.x = (int) (e.getX() - ctrlGame.dragStartX);
        ctrlGame.draggedPiece.y = (int) (e.getY() - ctrlGame.dragStartY);

        JSONObject msg = new JSONObject();
        msg.put("type", "clientObjectMoving"); //Mensaje de que esta moviendo la ficha
        msg.put("value", ctrlGame.draggedPiece.toJSON());

        if (Main.wsClient != null) {
            Main.wsClient.safeSend(msg.toString());
        }

        onMouseMoved(e);         // Actualizamos también la posición del mouse

    }

    // -Al soltar el mouse
    public void onMouseReleased(MouseEvent e) {
        if (ctrlGame.block || Main.partidaFinalizada) {
            return;
        }
            
        if (ctrlGame.draggedPiece == null) {
            return;
        }

        int col = ctrlGame.playGrid.getCol(e.getX());


        if (col >= 0 && col < ctrlGame.COLS) {
            JSONObject obj = new JSONObject();
            obj.put("type", "ColocarFitxa");
            obj.put("name", Main.clientName);
            obj.put("color", Main.getClientColor());
            obj.put("col", col);
            obj.put("id", ctrlGame.draggedPiece.id);

            if (Main.wsClient != null){
                Main.wsClient.safeSend(obj.toString());
            } 
        }

        ctrlGame.draggedPiece = null;
        ctrlGame.isDragging = false;
    }

    // comprobar si el mouse esta tocando ficha.
    private boolean insideCircle(double x, double y, double cx, double cy, double r) {
        double dx = x - cx;
        double dy = y - cy;
        return dx * dx + dy * dy <= r * r;
    }
}
