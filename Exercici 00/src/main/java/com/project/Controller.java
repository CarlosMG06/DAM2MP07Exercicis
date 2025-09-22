package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.text.Text;
import javafx.event.ActionEvent;

public class Controller {

    @FXML
    private Button buttonAdd;
    private Button buttonSubtract;
    private Button buttonMultiply;
    private Button buttonDivide;
    private Button buttonEquals;
    private Button buttonClear;
    private Button button1;
    private Button button2;
    private Button button3;
    private Button button4;
    private Button button5;
    private Button button6;
    private Button button7;
    private Button button8;
    private Button button9;
    private Button button0;

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
        textDisplay.setText("");
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
        textDisplay.setText(textDisplay.getText() + "0");
    }

}
