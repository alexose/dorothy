# Dorothy Hub

The purpose of the Dorothy Hub is to rebroadcast [Dorothy](https://www.thingiverse.com/thing:6170483)'s LoRa messages
directly to an [InfluxDB](https://docs.influxdata.com/) server.

It uses the [Heltec WiFi LoRa 32](https://heltec.org/project/wifi-lora-32/), placed inside of this cool
[minimalist case](https://www.thingiverse.com/thing:3783207).

## Setting up InfluxDB

Because it's not possible to run InfluxDB on our ESP32 board, you'll need to get it running elsewhere.

While it is possible to use [InfluxDB Cloud](https://www.influxdata.com/products/influxdb-cloud/), I prefer to run it
for free on a local server. InfluxDB is quite snappy and runs just fine on a Raspberry Pi 3.

Check out [this page](https://pimylifeup.com/raspberry-pi-influxdb/) For a full tutorial on how to install InfluxDB on a
Raspberry Pi, as well as Grafana, a companion visualization library which outputs pretty graphs.

When you have a working InfluxDB installation, note the IP address of the device it's running on. You'll be needing it
later.

## Materials

Begin by sourcing all of the necessary materials:

-   One [Heltec WiFi LoRa 32](https://heltec.org/project/wifi-lora-32-v3)
-   One
    [Mini battery pack with JST connector](https://www.amazon.com/EEMB-2000mAh-Battery-Rechargeable-Connector/dp/B08214DJLJ)
    (optional, but allows for battery backup if your power goes out)
-   Around 10g of PLA filament

## 3D Printing

Use your favorite 3D printing software to print the
[Heltec WiFi LoRa 32 (V2) minimalist case](https://www.thingiverse.com/thing:3783207) at the highest quality settings.
It should only take you about an hour.

## Flashing

Connect your Heltec WiFi LoRa 32 board to your computer using a USB cable. Using the
[Arduino IDE](https://www.arduino.cc/en/software/), open the
[dorothy_hub.ino](https://github.com/alexose/3D-Printing/blob/main/Dorothy/hub/code/dorothy_hub/dorothy_hub.ino) file in
this repo.

You'll need to edit a few lines in order to point it at your network's correct SSID and password. Then, a few lines
below, edit the IP address to match the device that's running InfluxDB.

Now that you've edited the file to match your network, click the "Upload" button to send it to your device. This should
take about 20 seconds. Once your device reboots, it should connect to your WiFi network and start listening for incoming
LoRa messages.

You may now disconnect the device from your computer, connect the optional battery pack, connect the antenna, and
assemble the case as described in the [case documentation](https://www.thingiverse.com/thing:3783207).

Congratulations, you're now ready to receive and record measurements via the Dorothy platform!
