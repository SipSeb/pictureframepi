#!/usr/bin/python3
import RPi.GPIO as GPIO
import time
import subprocess

GPIO.setmode(GPIO.BOARD)
# set pin 5 to input, and enable the internal pull-up resistor
GPIO.setup(5, GPIO.IN, pull_up_down=GPIO.PUD_UP)

oldButtonState1 = True
while True:
    buttonState1 = GPIO.input(5)

    if buttonState1 != oldButtonState1 and buttonState1 == False :
        print("Power Button pressed")
        subprocess.call("halt", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    oldButtonState1 = buttonState1

    time.sleep(.1)