package com.project;

import javafx.fxml.FXML;
import javafx.scene.text.Text;

public class Controller {

    @FXML
    private Text textDisplay;

    private int n1 = 0;
    private int n2 = 0;
    private int result = 0;
    private String operation = "";
    private boolean divideByZeroError = false;
    private boolean equalsPressed = false;

    @FXML
    private void actionAdd() {
        if (divideByZeroError) {
            return;
        }
        if (textDisplay.getText() != "") {
            if (operation != "") {
                actionEquals();
                if (divideByZeroError) {
                    return;
                }
            }
            n1 = Integer.parseInt(textDisplay.getText());
            textDisplay.setText("");
        }
        operation = "+";
    }
    @FXML
    private void actionSubtract() {
        if (divideByZeroError) {
            return;
        }
        if (textDisplay.getText() != "") {
            if (operation != "") {
                actionEquals();
                if (divideByZeroError) {
                    return;
                }
            }
            n1 = Integer.parseInt(textDisplay.getText());
            textDisplay.setText("");
        }
        operation = "-";
    }
    @FXML
    private void actionMultiply() {
        if (divideByZeroError) {
            return;
        }
        if (textDisplay.getText() != "") {
            if (operation != "") {
                actionEquals();
                if (divideByZeroError) {
                    return;
                }
            }
            n1 = Integer.parseInt(textDisplay.getText());
            textDisplay.setText("");
        }
        operation = "*";
    }
    @FXML
    private void actionDivide() {
        if (divideByZeroError) {
            return;
        }
        if (textDisplay.getText() != "") {
            if (operation != "") {
                actionEquals();
                if (divideByZeroError) {
                    return;
                }
            }
            n1 = Integer.parseInt(textDisplay.getText());
            textDisplay.setText("");
        }
        operation = "/";
    }
    @FXML
    private void actionEquals() {
        if (divideByZeroError || textDisplay.getText() == "") {
            return;
        }
        n2 = Integer.parseInt(textDisplay.getText());
        switch (operation) {
            case "+":
                result = n1 + n2;
                break;
            case "-":
                result = n1 - n2;
                break;
            case "*":
                result = n1 * n2;
                break;
            case "/":
                if (n2 != 0) {
                    result = n1 / n2;
                } else {
                    textDisplay.setText("Error: Divisió per 0");
                    divideByZeroError = true;
                    return;
                }
                break;
            default:
                result = n2;
                break;
        }
        if (!divideByZeroError) {
            textDisplay.setText(String.valueOf(result));
            n1 = result;
            n2 = 0;
            result = 0;
        }
        operation = "";
        equalsPressed = true;
    }
    @FXML
    private void actionClear() {
        textDisplay.setText("0");
        n1 = 0;
        n2 = 0;
        result = 0;
        operation = "";
        equalsPressed = false;
        divideByZeroError = false;
    }
    @FXML
    private void actionButton1() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "1");
    }
    @FXML
    private void actionButton2() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "2");
    }
    @FXML
    private void actionButton3() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "3");
    }
    @FXML
    private void actionButton4() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "4");
    }
    @FXML
    private void actionButton5() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "5");
    }
    @FXML
    private void actionButton6() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "6");
    }
    @FXML
    private void actionButton7() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "7");
    }
    @FXML
    private void actionButton8() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "8");
    }
    @FXML
    private void actionButton9() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "9");
    }
    @FXML
    private void actionButton0() {
        if (divideByZeroError) {
            actionClear();
        }
        if (equalsPressed) {
            textDisplay.setText("");
            equalsPressed = false;
        }
        if (textDisplay.getText() == "0") {
            textDisplay.setText("");
        }
        textDisplay.setText(textDisplay.getText() + "0");
    }

}
